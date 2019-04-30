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
logTag="launch"
logDir="/var/log/cons3rt"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
######################## HELPER FUNCTIONS ############################
# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }
############################## LAUNCH SERVICES ##############################################
function start_filebeat() {
	logInfo "Launching filebeat..."
	cd /usr/share/filebeat
	bin/filebeat --path.config /etc/filebeat &
	logInfo "Success"
}
function start_logstash() {
	logInfo "Launching logstash..."
	cd /usr/share/logstash
	bin/logstash --path.settings /etc/logstash &
}
function start_fail2ban() {
	logInfo "Launching fail2ban..."
	systemctl enable firewalld
  	systemctl start firewalld
  	systemctl enable fail2ban
  	systemctl start fail2ban
  	logInfo "Success"
}
############################## MAIN #########################################################
function main(){
	start_filebeat
	start_logstash
	start_fail2ban
}
################################ COMMANDS ###################################################
main
cat ${logFile}
