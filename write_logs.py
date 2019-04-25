import boto
import boto.s3.connection
import boto.s3
import logging
import datetime 
import os
import uuid

access_key = os.environ.get('OS_ACCESS_KEY')
secret_key = os.environ.get('OS_SECRET_KEY')


conn = boto.s3.connection.S3Connection(
	aws_access_key_id=access_key,
	aws_secret_access_key=secret_key,
	port=443,
	host='kzn-swift.massopen.cloud',
	is_secure=True,
	calling_format=boto.s3.connection.OrdinaryCallingFormat()) 

logging.info('log upload to '+ 'log_bucket' + ' ' + str(datetime.datetime.now()))
try:
    bucket = conn.get_bucket('log_bucket')
    k = bucket.new_key('log_'+str(datetime.datetime.now().date()))
    k.set_contents_from_filename('/store_log/log_' + str(datetime.datetime.now().date()))
except:
    logging.error('upload_to_bucket() - file could not be uploaded to bucket')
