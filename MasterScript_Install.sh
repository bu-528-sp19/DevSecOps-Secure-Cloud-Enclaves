#!/bin/bash
#Considering login as root -- ?
#Source the environment
if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
if [ -f /etc/profile ] ; then
    . /etc/profile
fi
# Establish a log file and log tag
logTag="logging_config"
logDir="/var/log/cons3rt"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
######################### GLOBAL VARIABLES #########################
######################## HELPER FUNCTIONS ############################
# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }
###################### INSTALLING DEPENDENCIES ######################
function install_dependencies() {
	echo "Installing dependencies..."
	logInfo "Updating yum packages..."
	sudo yum -y update
	logInfo "Success"
	logInfo "Installing epel..."
	sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	logInfo "Success"
	logInfo "Installing python..."
	sudo yum -y install python
	sudo yum install centos-release-scl
	sudo yum install rh-python36
	scl enable rh-python36 bash
	sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
        sudo yum -y install python36u python36u-devel python36u-pip
	logInfo "Success"
	logInfo "Installing java..."
	sudo yum -y install java
	logInfo "Success"
	logInfo "Installing pip..."
	sudo yum -y install python-pip
	logInfo "Success"
	logInfo "Installing wheel..."
	sudo yum -y install python-wheel
	logInfo "Success"
	logInfo "Installing devel..."
	sudo yum -y install python-devel
	logInfo "Success"
	logInfo "Installing setuptools..."
	sudo yum -y install python-setuptools
	logInfo "Success"
	logInfo "Installing crypto..."
	sudo yum -y install python-crypto
        sudo pip3.6 install PyAesCrypt
	logInfo "Success"
	logInfo "Installing gcc"
	sudo yum -y install gcc
	logInfo "Success"
	logInfo "Creating Elastic Repo"
	sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
	cd /etc/yum.repos.d/
	{
		echo -e	"[elastic-6.x]"
		echo -e "name=Elastic repository for 6.x packages"
		echo -e "baseurl=https://artifacts.elastic.co/packages/6.x/yum"
		echo -e "gpgcheck=1"
		echo -e "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch"
		echo -e "enabled=1"
		echo -e "autorefresh=1"
		echo -e "type=rpm-md"
	} > elastic.repo
	logInfo "Success"
	logInfo "Installing boto..."
	pip install boto
	logInfo "Success"
	logInfo "Installing boto3..."
	pip install boto3
	logInfo "Success"
	logInfo "Installing filebeat..."
	sudo yum -y install filebeat
	logInfo "Success"
	logInfo "Installing logstash..."
	sudo yum -y install logstash
	logInfo "Success"
	logInfo "Installing Fail2Ban"
    sudo yum -y install fail2ban fail2ban-systemd
    logInfo "Success"
    logInfo "Installing python-openstackclient..."
    pip install python-openstackclient
    pip install --upgrade decorate
    pip install --upgrade decorator
    logInfo "Success"
    logInfo "Installing python-barbicanclient"
    pip install python-barbicanclient
    logInfo "Success"
}
function get_scripts() {
	echo "Getting scripts..."
	cd /
	mkdir code
	chmod 755 code
	curl -o /code/token_parser.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/token_parser.py
	curl -o /code/Create_Log_Bucket.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/Create_Log_Bucket.py
	curl -o /code/write_logs.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/write_logs.py
	curl -o /code/ObjectStorageAPI.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/ObjectStorageAPI.py
	cd code
	chmod 755 write_logs.py
	chmod 755 ObjectStorageAPI.py
	chmod 755 token_parser.py
	chmod 755 Create_Log_Bucket.py

	cd /media
	{
		echo -e "echo \"Starting Obejct Storage API\""
		echo -e "python /code/ObjectStorageAPI.py"
	} > StartAPI.sh

	mkdir /var/log/object_store
	touch /var/log/object_store/object_store.log
}
function gen_keys() {
	echo 'Generating keys...'
	# Creating folder to store credentials with only root access
	cd /
	mkdir inf
	chmod 700 inf
	# Set authentication URL to Keystone endpoint
	declare -x OS_AUTH_URL=https://kaizen.massopen.cloud:13000
	# Create scoped token for keystone authentication (required for curl requests to Barbican)
	openstack --os-identity-api-version 3 --os-username=$OS_USERNAME --os-user-domain-name=default --os-password=$OS_PASSWORD --os-project-name=$OS_USERNAME --os-project-domain-name=default token issue > /inf/auth_token.txt
	# Extract token and put it in a script to set variable TOKEN --- this is also to be downloaded from git on VM init
	python /code/token_parser.py
	# Get permission to execute the shell script generated by the python script
	chmod 700 /inf/token.sh
	# Run the script that sets the token 
	source /inf/token.sh

	echo $TOKEN 

	logInfo "Generating keys for object storage buckets..."
	cd /inf
	# Generate key for object storage buckets
	curl -o store_key.json -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "data_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders

	# Generate key for log storage bucket
	curl -o log_key.json -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "log_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders

	logInfo "Success"
}
function set_up_bucket() {
	echo 'Creating Log Bucket...'
	cd /code
	python Create_Log_Bucket.py
}
############################## MAIN #########################################################
function main(){
	install_dependencies
	get_scripts
	gen_keys
	set_up_bucket
}
################################ COMMANDS ###################################################
main
cat ${logFile}
