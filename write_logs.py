import boto
import boto.s3.connection
import boto.s3
import logging
import datetime 
import os
import uuid
import pyAesCrypt
access_key = os.environ.get('OS_ACCESS_KEY')
secret_key = os.environ.get('OS_SECRET_KEY')

#recent="https://kaizen.massopen.cloud:13311/v1/secrets/386e3d58-40cc-4820-afd8-44dc46d35bdd"
with open('/inf/log_key.json','r') as file:
    data = file.read().replace('\n','')

import re
q=re.findall("(?P<url>https?://[^\s]+)",data)
 
recent=q[0][:-2]

print(recent)
print(recent)
#GET_COMMAND='openstack --os-identity-api-version 3 --os-username '+ os.environ.get('OS_USERNAME')+ ' --os-password '+os.environ.get('OS_PASSWORD')+' secret get '
GET_COMMAND='openstack --os-identity-api-version 3 --os-username '+os.environ.get('OS_USERNAME')+ ' --os-password '+os.environ.get('OS_PASSWORD')+' secret get '
buffSz=1024*64
stri=os.popen(GET_COMMAND + recent + " --payload").read()#.encode()
stri=stri.split("|")
print("Stri")
print(stri)
indxOfSecret = stri.index(" Payload ") + 1
password=stri[indxOfSecret]
password=password[1:-1]

conn = boto.s3.connection.S3Connection(
	aws_access_key_id=access_key,
	aws_secret_access_key=secret_key,
	port=443,
	host='kzn-swift.massopen.cloud',
	is_secure=True,
	calling_format=boto.s3.connection.OrdinaryCallingFormat()) 

logging.info('log upload to '+ 'log_bucket' + ' ' + str(datetime.datetime.now()))
try:
    filePath='/store_log/log_' + str(datetime.datetime.now().date())
    fileToEncrypt = filePath+'.txt'
    fileEncryption = filePath + '.aes'
    with open(fileToEncrypt,'rb') as fIn:
        with open(fileEncryption,'wb') as fOut:
            pyAesCrypt.encryptStream(fIn,fOut,password,buffSz)
    bucket = conn.get_bucket('log_bucket')
    k = bucket.new_key('log_'+str(datetime.datetime.now().date()))
    k.set_contents_from_filename(fileEncryption)
except:
    logging.error('upload_to_bucket() - file could not be uploaded to bucket')
