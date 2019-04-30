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
logTag="environment"
logDir="/var/log/cons3rt"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
######################### GLOBAL VARIABLES #########################
######################## HELPER FUNCTIONS ############################
# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }
######################## ENVIRONMENT VARS ############################
function add_environment_vars() {
	logInfo "Adding environment variables"

	if [ -f vars.txt ]; then
        logInfo "Removing existing: vars.txt"
        rm -f vars.txt
    fi

	{
		echo -e "export OS_USERNAME='/* USERNAME */'"
		echo -e "export OS_PROJECT='/* PROJECT NAME */'"
		echo -e "export OS_PASSWORD='/* PASSWORD */'"
		echo -e "export OS_AUTH_URL='https://kaizen.massopen.cloud:13000'"
	} > vars.txt 
	if [ $? -ne 0 ]; then logErr "There was a problem adding root variables"; return 1; fi
	cat vars.txt >> /root/.bash_profile

	rm -f vars.txt

	if [ -f /etc/profile.d/object_keys.sh ]; then
        logInfo "Removing existing: /etc/profile_d/object_keys.sh"
        rm -f /etc/profile.d/object_keys.sh
    fi

	cd /etc/profile.d
	{
		echo -e "export OS_ACCESS_KEY='/* ACCESS KEY */'";
		echo -e "export OS_SECRET_KEY='/* SECRET KEY */'";
	} > object_keys.sh
	if [ $? -ne 0 ]; then logErr "There was a problem creating user variables"; return 2; fi
	chmod 755 object_keys.sh
	logInfo "Success"
	return 0
}
function create_clouds() {
	logInfo "Creating clouds.yaml...."

	if [ -f /media/clouds.yaml ]; then
        logInfo "Removing existing: /media/clouds.yaml"
        rm -f /media/clouds.yaml
    fi

	cd /media
	{
		echo -e 'clouds:'
        echo -e '  moc_old:'
        echo -e '    auth:'
        echo -e '      auth_url: https://kaizenold.massopen.cloud:5000/'
        echo -e '      project_name: /* PROJECT NAME */'
        echo -e '      username: /* USERNAME */'
        echo -e '      password: /* PASSWORD */'
        echo -e '    operation_log:'
        echo -e '      logging: TRUE'
        echo -e '      file: /var/log/openstack/openstack_old.log'
        echo -e '      level: info'
        echo -e '  moc_new:'
        echo -e '    auth:'
        echo -e '      auth_url: https://kaizen.massopen.cloud:13000/'
        echo -e '      project_name: /* PROJECT NAME */'
        echo -e '      username: /* USERNAME */'
        echo -e '      password: /* PASSWORD */'
        echo -e '    operation_log:'
        echo -e '      logging: TRUE'
        echo -e '      file: /var/log/openstack/openstack_new.log'
        echo -e '      level: info'
	} > clouds.yaml
	if [ $? -ne 0 ]; then logErr "There was a problem creating clouds.yaml"; return 1; fi
	logInfo "Success"
	return 0
}
############################## MAIN #########################################################
function main(){
	add_environment_vars
	if [ $? -ne 0 ]; then logErr "There was a problem in add_environment_vars"; return 1; fi
	create_clouds
	if [ $? -ne 0 ]; then logErr "There was a problem in create_clouds"; return 2; fi
	return 0
}
################################ COMMANDS ###################################################
mkdir -p ${logDir}
chmod 700 ${logDir}
touch ${logFile}
chmod 644 ${logFile}
main
logInfo "Exiting MasterScript_Install with log error : $?"
cat ${logFile}