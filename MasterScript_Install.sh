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
logTag="install"
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
	if [ $? -ne 0 ]; then logErr "There was a problem updating yum"; return 1; fi
	logInfo "Success"
	logInfo "Installing epel..."
	sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	if [ $? -ne 0 ]; then logErr "There was a problem installing epel"; return 2; fi
	logInfo "Success"
	logInfo "Installing python..."
	sudo yum -y install python
	if [ $? -ne 0 ]; then logErr "There was a problem installing python"; return 3; fi
	logInfo "Installing centos-release-scl..."
	sudo yum -y install centos-release-scl
	if [ $? -ne 0 ]; then logErr "There was a problem installing centos-release-scl"; return 4; fi
	logInfo "Installing rh-python36"
	sudo yum -y install rh-python36
	if [ $? -ne 0 ]; then logErr "There was a problem starting installing rh-python36"; return 5; fi
	logInfo "Success"
	logInfo "Installing iuscommunity..."
	sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
	if [ $? -ne 0 ]; then logErr "There was a problem installing ius-release"; return 6; fi
	logInfo "Installing python36u..."
    sudo yum -y install python36u python36u-devel python36u-pip
    if [ $? -ne 0 ]; then logErr "There was a problem installing python36u tools"; return 7; fi
    logInfo "Installing PyAesCrypt..."
	sudo pip3.6 install PyAesCrypt
	if [ $? -ne 0 ]; then logErr "There was a problem installing PyAesCrypt"; return 8; fi
	logInfo "Success"
	logInfo "Installing java..."
	sudo yum -y install java
	if [ $? -ne 0 ]; then logErr "There was a problem installing java"; return 9; fi
	logInfo "Success"
	logInfo "Installing pip..."
	sudo yum -y install python-pip
	if [ $? -ne 0 ]; then logErr "There was a problem installing pip"; return 10; fi
	logInfo "Success"
	logInfo "Installing wheel..."
	sudo yum -y install python-wheel
	if [ $? -ne 0 ]; then logErr "There was a problem installing wheel"; return 11; fi
	logInfo "Success"
	logInfo "Installing devel..."
	sudo yum -y install python-devel
	if [ $? -ne 0 ]; then logErr "There was a problem installing devel"; return 12; fi
	logInfo "Success"
	logInfo "Installing setuptools..."
	sudo yum -y install python-setuptools
	if [ $? -ne 0 ]; then logErr "There was a problem installing setuptools"; return 13; fi
	logInfo "Success"
	logInfo "Installing crypto..."
	sudo yum -y install python-crypto
	if [ $? -ne 0 ]; then logErr "There was a problem installing python-crypto"; return 14; fi
	logInfo "Success"
	logInfo "Installing gcc"
	sudo yum -y install gcc
	if [ $? -ne 0 ]; then logErr "There was a problem installing gcc"; return 15; fi
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
	if [ $? -ne 0 ]; then logErr "There was a problem installing the elastic repo"; return 16; fi
	logInfo "Success"
	logInfo "Installing boto..."
	pip install boto
	pip3.6 install boto
	if [ $? -ne 0 ]; then logErr "There was a problem installing boto"; return 17; fi
	logInfo "Success"
	logInfo "Installing boto3..."
	pip install boto3
	pip3.6 install boto3
	if [ $? -ne 0 ]; then logErr "There was a problem installing boto3"; return 18; fi
	logInfo "Success"
	logInfo "Installing filebeat..."
	sudo yum -y install filebeat
	if [ $? -ne 0 ]; then logErr "There was a problem installing filebeat"; return 19; fi
	logInfo "Success"
	logInfo "Installing logstash..."
	sudo yum -y install logstash
	if [ $? -ne 0 ]; then logErr "There was a problem installing logstash"; return 20; fi
	logInfo "Success"
	logInfo "Installing Fail2Ban"
    sudo yum -y install fail2ban fail2ban-systemd
    if [ $? -ne 0 ]; then logErr "There was a problem installing fail2ban"; return 21; fi
    logInfo "Success"
    logInfo "Installing python-openstackclient..."
    pip install python-openstackclient
    pip install --upgrade decorate
    pip install --upgrade decorator
    if [ $? -ne 0 ]; then logErr "There was a problem installing python-openstackclient"; return 22; fi
    logInfo "Success"
    logInfo "Installing python-barbicanclient"
    pip install python-barbicanclient
    if [ $? -ne 0 ]; then logErr "There was a problem installing barbican"; return 23; fi
    logInfo "Success"
	return 0
}
function get_scripts() {
	echo "Getting scripts..."
	cd /
	mkdir code
	if [ $? -ne 0 ]; then logErr "There was a problem making the code folder"; return 1; fi
	chmod 755 code
	curl -o /code/token_parser.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/token_parser.py
	if [ $? -ne 0 ]; then logErr "There was a problem downloading token_parser.py"; return 2; fi
	curl -o /code/Create_Log_Bucket.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/Create_Log_Bucket.py
	if [ $? -ne 0 ]; then logErr "There was a problem downloading Create_Log_Bucket.py"; return 3; fi
	curl -o /code/write_logs.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/write_logs.py
	if [ $? -ne 0 ]; then logErr "There was a problem downloading write_logs.py"; return 4; fi
	curl -o /code/ObjectStorageAPI.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/ObjectStorageAPI.py
	if [ $? -ne 0 ]; then logErr "There was a problem installing ObjectStorageAPI.py"; return 5; fi
	curl -o /code/download_logs.py https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/download_logs.py
	if [ $? -ne 0 ]; then logErr "There was a problem installing download_logs.py"; return 6; fi
	cd code
	chmod 700 write_logs.py
	chmod 755 ObjectStorageAPI.py
	chmod 755 token_parser.py
	chmod 700 Create_Log_Bucket.py
	chmod 700 download_logs.py

	{
		echo -e "source /etc/profile.d/object_keys.sh"
		echo -e "source /root/.bash_profile"
		echo -e "/bin/python3.6 /code/write_logs.py"
	} > cron.sh

	chmod 700 cron.sh

	cd /media
	{
		echo -e "echo \"Starting Obejct Storage API\""
		echo -e "python3.6 /code/ObjectStorageAPI.py"
	} > StartAPI.sh

	chmod 755 StartAPI.sh

	if [ $? -ne 0 ]; then logErr "There was a problem creating the API script"; return 6; fi
	mkdir /var/log/object_store
	touch /var/log/object_store/object_store.log
	logInfo "Success"
	return 0
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
	if [ $? -ne 0 ]; then logErr "There was a problem getting the token"; return 1; fi
	# Extract token and put it in a script to set variable TOKEN --- this is also to be downloaded from git on VM init
	python /code/token_parser.py
	# Get permission to execute the shell script generated by the python script
	chmod 700 /inf/token.sh
	# Run the script that sets the token 
	source /inf/token.sh
	if [ $? -ne 0 ]; then logErr "There was a problem sourcing the TOKEN"; return 2; fi
	echo $TOKEN 

	logInfo "Generating keys for object storage buckets..."
	cd /inf
	# Generate key for object storage buckets
	curl -o store_key.json -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "data_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders
	if [ $? -ne 0 ]; then logErr "There was a problem getting the object_storage key"; return 3; fi
	# Generate key for log storage bucket
	curl -o log_key.json -X POST -H "X-Auth-Token: $TOKEN" -H "content-type:application/json" -d '{
	"type":"key", "meta": { "name": "log_key", "algorithm": "aes",
	"bit_length": 256, "mode": "cbc", "payload_content_type": "application/octet-stream"}
	}' https://kaizen.massopen.cloud:13311/v1/orders
	if [ $? -ne 0 ]; then logErr "There was a problem getting the log_storage key"; return 4; fi

	logInfo "Success"
	return 0
}
function set_up_bucket() {
	echo 'Creating Log Bucket...'
	cd /code
	python Create_Log_Bucket.py
	if [ $? -ne 0 ]; then logErr "There was a problem creating the log_bucket"; return 1; fi
	logInfo "Success"
	return 0
}
############################## MAIN #########################################################
function main(){
	install_dependencies
	if [ $? -ne 0 ]; then logErr "There was a problem in install_dependecies"; return 1; fi
	get_scripts
	if [ $? -ne 0 ]; then logErr "There was a problem in get_scripts"; return 2; fi
	gen_keys
	if [ $? -ne 0 ]; then logErr "There was a problem in gen_keys"; return 3; fi
	set_up_bucket
	if [ $? -ne 0 ]; then logErr "There was a problem in set_up_bucket"; return 4; fi
	return 0
}
################################ COMMANDS ###################################################
main
logInfo "Exiting MasterScript_Install with log error : $?"
cat ${logFile}