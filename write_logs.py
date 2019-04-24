import boto
import boto.s3.connection
import boto.s3
import logging
import datetime 


conn = boto.s3.connection.S3Connection(
	aws_access_key_id=$OS_ACCESS_KEY,
	aws_secret_access_key=$OS_SECRET_KEY,
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
