#!/bin/bash

# Considering login as root -- ?

# Source the environment
if [ -f /etc/bashrc ] ; then
    . /etc/bashrc
fi
if [ -f /etc/profile ] ; then
    . /etc/profile
fi

######################## HELPER FUNCTIONS ############################

# Logging functions
function timestamp() { date "+%F %T"; }
function logInfo() { echo -e "$(timestamp) ${logTag} [INFO]: ${1}" >> ${logFile}; }
function logWarn() { echo -e "$(timestamp) ${logTag} [WARN]: ${1}" >> ${logFile}; }
function logErr() { echo -e "$(timestamp) ${logTag} [ERROR]: ${1}" >> ${logFile}; }


###################### INSTALLING DEPENDENCIES ######################
#sudo yum check-updtaes
#sudo yum -y update

# Openstack
#sudo yum install -y centos-release-openstack-queens
#sudo yum-config-manager enable openstack-queens
#sudo yum update
#sudo yum install -y openstack-packstack
#sudo packstack --allinone

# Wget
#sudo yum install wget

# Python
#sudo yum install python
#sudo yum install python-pip
#pip install boto
#pip install boto3

# AWS CLI
#sudo yum install awscli

###################### SETTING AWS CREDS ######################

NOVARC=$(readlink -f "${BASH_SOURCE:-${0}}" 2>/dev/null) || NOVARC=$(python -c 'import os,sys; print os.path.abspath(os.path.realpath(sys.argv[1]))' "${BASH_SOURCE:-${0}}")
NOVA_KEY_DIR=${NOVARC%/*}
export EC2_ACCESS_KEY=//* ACCESS KEY *//
export EC2_SECRET_KEY=//* SECRET KEY *//
export EC2_URL=https://kaizen.massopen.cloud:13788
export EC2_USER_ID=42 # nova does not use user id, but bundling requires it
export EC2_PRIVATE_KEY=${NOVA_KEY_DIR}/pk.pem
export EC2_CERT=${NOVA_KEY_DIR}/cert.pem
export NOVA_CERT=${NOVA_KEY_DIR}/cacert.pem
export EUCALYPTUS_CERT=${NOVA_CERT} # euca-bundle-image seems to require this set

alias ec2-bundle-image="ec2-bundle-image --cert ${EC2_CERT} --privatekey ${EC2_PRIVATE_KEY} --user 42 --ec2cert ${NOVA_CERT}"
alias ec2-upload-bundle="ec2-upload-bundle -a ${EC2_ACCESS_KEY} -s ${EC2_SECRET_KEY} --url ${S3_URL} --ec2cert ${NOVA_CERT}"

###################### CREATING BUCKETS ######################
#mkdir code
#cd code
{
  echo -e 'import boto3'
  echo -e 'import boto.s3.connection'
  echo -e 'access_key = //* ACCESS KEY *//'
  echo -e 'secret_key = //* SECRET KEY *//'
  echo -e 'conn = boto.s3.connection.S3Connection(aws_access_key_id=access_key,aws_secret_access_key=secret_key,port=443,host="kzn-swift.massopen.cloud",is_secure=True,calling_format=boto.s3.connection.OrdinaryCallingFormat())'
  echo -e '#bucket = conn.create_bucket("versioning-enabled-bucket")'
  echo -e '#bucket.configure_versioning(True)'
  echo -e '#conn.delete_bucket("test-bucket")'
  echo -e 'for bucket in conn.get_all_buckets():'
  echo -e '\tprint "{name}\t{created}".format(name = bucket.name,created = bucket.creation_date)'
  echo -e 'bucket = conn.get_bucket("versioning-enabled-bucket")'
  echo -e 'k = bucket.new_key("sample.txt")'
  echo -e 'k.set_contents_from_filename("sample.txt")'
  echo -e 'for version in bucket.list_versions():'
  echo -e '\tprint(version)'
} >connection.py

python connection.py > output.txt
errMsg=`cat output.txt`
echo $errMsg
