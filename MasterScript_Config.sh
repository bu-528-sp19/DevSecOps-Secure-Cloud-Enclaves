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
############################### MODIFY CONFIG FILES ##########################################
function filebeat_config() {
	logInfo "Configuring filebeat..."
	rm -f /etc/filebeat/filebeat.yml
	curl -o /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/filebeat.yml
	logInfo "Success"
}
function logstash_config() {
	logInfo "Configuring logstash..."
	rm -f /etc/logstash/conf.d/logstash.conf
	curl -o /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/bu-528-sp19/DevSecOps-Secure-Cloud-Enclaves/master/Configs/logstash.conf
	mkdir -p /store_log
	chmod 700 /store_log
	logInfo "Success"
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
    cd /
    logInfo "Success"
}
function cron_config() {
    logInfo "Configuring log cron job..."
    { 
        echo -e '@hourly    0    cron.hourly             nice run-parts /etc/cron.hourly'
    } > cron.txt

    cat cron.txt >> /etc/anacrontab
    rm -f cron.txt

    cd /etc/cron.hourly
    {
        echo -e "python /code/write_logs.py"
    } > log.cron
    chmod 755 log.cron
    logInfo "Success"

}
function openstack_config() {
    logInfo "Configuring openstack..."
    cd /etc
    mkdir openstack
    cd openstack
    mv /media/clouds.yaml clouds.yaml
    logInfo "Success"
}
############################## MAIN #########################################################
function main(){
    filebeat_config
    logstash_config
    fail2ban_config
    cron_config
    openstack_config
}
main
cat ${logFile}