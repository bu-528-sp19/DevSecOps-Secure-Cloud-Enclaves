if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
if [ -f /etc/profile ] ; then
    . /etc/profile
fi
# Establish a log file and log tag
logTag="config"
logDir="/var/log/cons3rt"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
######################### GLOBAL VARIABLES #########################
######################## HELPER FUNCTIONS ############################
# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }
############################### MODIFY CONFIG FILES ##########################################
function filebeat_config() {
	logInfo "Configuring filebeat..."

    if [ -f /etc/filebeat/filebeat.yml ]; then
        logInfo "Removing existing: filebeat.yml"
        rm -f /etc/filebeat/filebeat.yml
    fi
	
	curl -o /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/filebeat.yml
    if [ $? -ne 0 ]; then logErr "There was a problem downloading filebeat.yml"; return 1; fi
	logInfo "Success"
    return 0
}
function logstash_config() {
	logInfo "Configuring logstash..."

    if [ -f /etc/logstash/conf.d/logstash.conf ]; then
        logInfo "Removing existing: logstash.conf"
        rm -f /etc/logstash/conf.d/logstash.conf
    fi
	
	curl -o /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/Configs/logstash.conf
    if [ $? -ne 0 ]; then logErr "There was a problem downloading logstash.conf"; return 1; fi
	mkdir -p /store_log
	chmod 700 /store_log
	logInfo "Success"
    return 0
}
function fail2ban_config() {
    logInfo "Configuring fail2ban..."
    cp -pf /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    cd /etc/fail2ban/jail.d/
    {
            echo -e "[sshd]"
            echo -e "enabled = true"
            echo -e "port = ssh"
            echo -e "#action = firewallcmd-ipset"
            echo -e "logpath = %(sshd_log)s"
            echo -e "maxretry = 5"
            echo -e "bantime = 86400"
    } > sshd.local
    if [ $? -ne 0 ]; then logErr "There was a problem setting creating the fail2ban config"; return 1; fi
    cd /
    logInfo "Success"
    return 0
}
function cron_config() {
    logInfo "Configuring log cron job..."

    logInfo "Setting the crontab..."

    if [ -f /root/cron.txt ]; then
        logInfo "Removing existing: /root/crontab.txt"
        rm -f /root/cron.txt
    fi

    logInfo "Creating: /root/crontab.txt to launch /code/write_logs.py 30 mins past every hour..."
    { 
        echo -e '30 * * * * /opt/rh/rh-python36/root/usr/bin/python3.6 /code/write_logs.py'
    } > /root/cron.txt


    logInfo "Setting the crontab from /root/crontab.txt"
    crontab /root/cron.txt
    if [ $? -ne 0 ]; then logErr "There was a problem setting the crontab"; return 1; fi
    
    logInfo "Removing temp file: /root/crontab.txt"
    rm -f /root/cron.txt
    
    logInfo "Completed setting the crontab!"
}
function openstack_config() {
    logInfo "Configuring openstack..."
    cd /etc
    mkdir openstack
    if [ $? -ne 0 ]; then logErr "There was a problem creating the /etc/openstack directory"; return 1; fi
    cd openstack
    mv /media/clouds.yaml clouds.yaml
    if [ $? -ne 0 ]; then logErr "There was a problem adding clouds.yaml"; return 2; fi
    logInfo "Success"
    return 0
}
############################## MAIN #########################################################
function main(){
    filebeat_config
    if [ $? -ne 0 ]; then logErr "There was a problem with filebeat_config"; return 1; fi
    logstash_config
    if [ $? -ne 0 ]; then logErr "There was a problem with logstash_config"; return 2; fi
    fail2ban_config
    if [ $? -ne 0 ]; then logErr "There was a problem with fail2ban_config"; return 3; fi
    cron_config
    if [ $? -ne 0 ]; then logErr "There was a problem with cron_config"; return 4; fi
    openstack_config
    if [ $? -ne 0 ]; then logErr "There was a problem with openstack_config"; return 5; fi
    return 0
}
main
logInfo "Exiting MasterScript_Install with log error : $?"
cat ${logFile}
