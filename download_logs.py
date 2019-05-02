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

recent="https://kaizen.massopen.cloud:13311/v1/secrets/386e3d58-40cc-4820-afd8-44dc46d35bdd"


GET_COMMAND='openstack --os-identity-api-version 3 --os-username '+os.environ.get('OS_USERNAME')+ ' --os-password '+os.environ.get('OS_PASSWORD')+' secret get '
buffSz=1024*64
stri=os.popen(GET_COMMAND + recent + " --payload").read()#.encode()
stri=stri.split("|")

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

task = eval(input('''Enter: 
                     1. Download all log files
                     2. Download dated log file ''')
                     
if task == 1:
    bucket = conn.get_bucket(bucket_name)     
    for key in bucket.list(): 
        print(key)
        logging.info('log download from '+ 'log_bucket' + ' ' + str(datetime.datetime.now()))
        try:
            k = bucket.get_key(key)
            encFileSz=os.stat('encTmp.aes').st_size
            pathDec = key+'.dec'
            k.get_contents_to_filename(key)
            with open(key, 'rb') as infile:
                with open(pathDec, 'wb') as outfile:
                    pyAesCrypt.decryptStream(infile,outfile,password,buffSz,encFileSz)    
            replaceCommand='mv ' + pathDec + ' ' + key 
            os.system(replaceCommand)
        except:
            logging.error('download_log() - file could not be downloaded from bucket')
elif task == 2:
    year = input('Enter year of the log file (YYYY):')
    month = input('Enter month of the log file (MM):')
    day = input('Enter day of the log file (dd):')
    logFile = 'log_' + year + '-' + month + '-' + day;
    logging.info('log download from '+ 'log_bucket' + ' ' + str(datetime.datetime.now()))
    try:
        bucket = conn.get_bucket(bucket_name)
        k = bucket.get_key(logFile)
        encFileSz=os.stat('encTmp.aes').st_size
        pathDec = logFile+'.dec'
        k.get_contents_to_filename(logFile)
        with open(logFile, 'rb') as infile:
            with open(pathDec, 'wb') as outfile:
                pyAesCrypt.decryptStream(infile,outfile,password,buffSz,encFileSz)    
        replaceCommand='mv ' + pathDec + ' ' + logFile 
        os.system(replaceCommand)
    except:
        logging.error('download_log() - file could not be downloaded from bucket')
