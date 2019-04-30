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
	if [ $? -ne 0 ]; then logErr "There was a problem starting filebeat"; return 1; fi
	logInfo "Success"
	return 0
}
function start_logstash() {
	logInfo "Launching logstash..."
	cd /usr/share/logstash
	bin/logstash --path.settings /etc/logstash &
	if [ $? -ne 0 ]; then logErr "There was a problem starting logstash"; return 1; fi
	logInfo "Success"
	return 0
}
function start_fail2ban() {
	logInfo "Launching fail2ban..."
	systemctl enable firewalld
  	systemctl start firewalld
  	if [ $? -ne 0 ]; then logErr "There was a problem starting firewalld"; return 1; fi
  	systemctl enable fail2ban
  	systemctl start fail2ban
  	if [ $? -ne 0 ]; then logErr "There was a problem starting fail2ban"; return 2; fi
  	logInfo "Success"
  	return 0
}
############################## MAIN #########################################################
function main(){
	start_filebeat
	if [ $? -ne 0 ]; then logErr "There was a problem in start_filebeat"; return 1; fi
	start_logstash
	if [ $? -ne 0 ]; then logErr "There was a problem in start_logstash"; return 2; fi
	start_fail2ban
	if [ $? -ne 0 ]; then logErr "There was a problem in start_fail2ban"; return 3; fi
	return 0
}
################################ COMMANDS ###################################################
main
logInfo "Exiting MasterScript_Install with log error : $?"
cat ${logFile}
