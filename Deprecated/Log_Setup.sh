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
	logInfo "Installing filebeat..."
	sudo yum -y install filebeat
	logInfo "Success"
	#sudo chkconfig --add filebeat #start on boot
	logInfo "Installing logstash..."
	sudo yum -y install logstash
	logInfo Success
}
############################### MODIFY CONFIG FILES ##########################################
function filebeat_config() {
	cd /etc/filebeat
	rm filebeat.yml
	{
		echo -e "filebeat:"
		echo -e "  prospectors:"
		echo -e "  - type: log"
		echo -e "    enabled: true"
		echo -e "    paths:"
		echo -e "      - /var/log/*.log"
		echo -e "      - /var/log/secure*"
		echo -e "      - /var/log/messages*"
		echo -e "      - /var/log/*/*.log"
		echo -e "    registry_file: /var/lib/filebeat/registry"
		echo -e "output:"
		echo -e "  logstash:"
		echo -e "    enabled: true"
		echo -e "    hosts: [\"localhost:5044\"]"
		echo -e "shipping:"
		echo -e "logging:"
		echo -e "  to_files: true"
		echo -e "  json: true"
		echo -e "  files:"
		echo -e "    path: /var/log/filebeat"
		echo -e "    rotateeverybytes: 10485760"
	} > filebeat.yml
	cd /
}
function logstash_config() {
	cd /etc/logstash/conf.d
	{ 
		echo -e "input {"
		echo -e "	beats {"
		echo -e "		port=>5044"
		echo -e "	}"
		echo -e "}"
		echo -e "filter {"
		echo -e "	mutate {"
		echo -e "		remove_field=>[\"beat\", \"tags\", \"prospector\", \"input\", \"@version\", \"log\"]"
		echo -e "	}"
		echo -e "}"
		echo -e "output {"
		echo -e "	file {"
		echo -e "		path => \"/test_log/DEMO_1.txt\""
		echo -e "	}"
		echo -e "}"
	} > logstash.conf	
}
############################## LAUNCH SERVICES ##############################################
function start_filebeat() {
	cd /usr/share/filebeat
	bin/filebeat --path.config /etc/filebeat &
}
function start_logstash() {
	cd /usr/share/logstash
	bin/logstash --path.settings /etc/logstash &
}
############################## MAIN #########################################################
function main(){
	install_dependencies
	filebeat_config
	logstash_config
	start_filebeat
	start_logstash
}
################################ COMMANDS ###################################################
mkdir -p ${logDir}
chmod 700 ${logDir}
touch ${logFile}
chmod 644 ${logFile}
main
cat ${logFile}
