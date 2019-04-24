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
	logInfo "Updating yum packages..."
	sudo yum -y update
	logInfo "Success"
	logInfo "Installing epel..."
	sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	logInfo "Success"
	logInfo "Installing python..."
	sudo yum -y install python
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
	logInfo "Installing config"
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
    pip install --uppgrade decorate
    pip install --upgrade decorator
    logIndo "Success"
}
function get_scripts() {
	cd /
	mkdir code
	chmod 700 code
	curl -o token_parser.py https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/token_parser.py
	curl -o Create_Log_Bucket.py https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/Create_Log_Bucket.py


	cd /media
	curl -o ObjectStorageAPI.py https://github.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/blob/master/ObjectStorageAPI.py
	{
		echo -e "\"echo Starting Obejct Storage API\""
		echo -e "python /media/ObjectStorageAPI.py"
	} > StartAPI.sh

}
function gen_keys() {
	# Creating folder to store credentials with only root access
	cd /
	mkdir inf
	chmod 700 inf
	# Set authentication URL to Keystone endpoint
	declare -x OS_AUTH_URL="https://kaizen.massopen.cloud:13000"
	# Create scoped token for keystone authentication (required for curl requests to Barbican)
	openstack --os-identity-api-version 3 --os-username=$OS_USERNAME --os-user-domain-name=default --os-password=$OS_PASSWORD --os-project-name=$OS_USERNAME --os-project-domain-name=default token issue > /inf/auth_token.txt
	# Extract token and put it in a script to set variable TOKEN --- this is also to be downloaded from git on VM init
	python /code/token_parser.py
	# Get permission to execute the shell script generated by the python script
	chmod 700 /inf/token.sh
	# Run the script that sets the token 
	bash /inf/token.sh

	logInfo "Generating keys for object storage buckets..."
	declare -x OS_AUTH_URL="https://kaizen.massopen.cloud:13000"

	# Generate key for object storage buckets
	curl -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "data_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders

	# Generate key for log storage bucket
	curl -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "log_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders

	logInfo "Success"
}
function set_up_bucket() {
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
chmod 700 /var/log
mkdir -p ${logDir}
chmod 700 ${logDir}
touch ${logFile}
chmod 644 ${logFile}
main
cat ${logFile}