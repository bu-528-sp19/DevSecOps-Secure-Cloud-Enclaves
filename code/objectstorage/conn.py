import boto
import boto.s3.connection
access_key = '08f1ed3eacab4d9dbea7ffe2bde56b7f'
secret_key = 'b62363429ac145b78912638ecbecddc9'

conn = boto.connect_s3(
        aws_access_key_id = access_key,
        aws_secret_access_key = secret_key,
        host = 'https://kzn-swift.massopen.cloud/swift/v1',
        #is_secure=False,               # uncomment if you are not using ssl
        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
        )
for bucket in conn.get_all_buckets():
        print "hey"
	print "{name}\t{created}".format(
                name = bucket.name,
                created = bucket.creation_date,
        )
bucket = conn.create_bucket('heyheyec528bucketdevsecopsbucketyeahhhhh')



