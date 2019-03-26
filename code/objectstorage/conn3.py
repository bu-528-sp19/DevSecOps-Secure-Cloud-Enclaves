import boto
import boto.s3.connection
access_key = '08f1ed3eacab4d9dbea7ffe2bde56b7f' 
secret_key = 'b62363429ac145b78912638ecbecddc9'
#conn = boto.connect_s3(
#	aws_access_key_id = access_key,
#	aws_secret_access_key = secret_key,
#	#host ='https://kaizen.massopen.cloud:13788 ',
#	host ='https://kaizen.massopen.cloud:13000/v3',
#	#is_secure=False,
#	calling_format = boto.s3.connection.OrdinaryCallingFormat(),
#	)

conn = boto.s3.connection.S3Connection(
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    port=443,
    host='kzn-swift.massopen.cloud',
    is_secure=True,
    calling_format=boto.s3.connection.OrdinaryCallingFormat())

#bucket = conn.create_bucket('test-bucket')
	#conn.delete_bucket('test-bucket')
for bucket in conn.get_all_buckets():
      print "{name}\t{created}".format(
                name = bucket.name,
                created = bucket.creation_date,
)

