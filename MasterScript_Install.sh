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
}
############################## MAIN #########################################################
function main(){
	install_dependencies
}
################################ COMMANDS ###################################################
chmod 700 /var/log
mkdir -p ${logDir}
chmod 700 ${logDir}
touch ${logFile}
chmod 644 ${logFile}
main
cat ${logFile}
