#Source the environment
if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
if [ -f /etc/profile ] ; then
    . /etc/profile
fi
# Establish a log file and log tag
logTag="logging_config"
logDir="/home/centos/"
logFile="${logDir}/${logTag}-$(date "+%Y%m%d-%H%M%S").log"
######################### GLOBAL VARIABLES #########################
######################## HELPER FUNCTIONS ############################
# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }
function install_fail2ban() {
        echo "Installiong epel..."
        logInfo "Installing epel..."
        sudo yum -y  install epel-release
        logInfo "Success"
        echo "Success"
        echo "Installing python..."
        logInfo "Installing python..."
        sudo yum -y install python
        logInfo "Success"
        echo "Success"
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
        logInfo "Installing Fail2Ban"
        sudo yum -y install fail2ban fail2ban-systemd
        logInfo "Success"
}
############################### MODIFY CONFIG FILE ##########################################
function fail2ban_config() {
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
}
############################## LAUNCH SERVICE ##############################################

function start_fail2ban() {
  systemctl enable firewalld
  systemctl start firewalld
  systemctl enable fail2ban
  systemctl start fail2ban
}
############################## MAIN #########################################################
function main(){
        install_fail2ban
        fail2ban_config
        start_fail2ban
}
main
