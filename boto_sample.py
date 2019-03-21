import boto
import boto.s3.connection
access_key = '08f1ed3eacab4d9dbea7ffe2bde56b7f'
secret_key = 'b62363429ac145b78912638ecbecddc9'


conn = boto.s3.connection.S3Connection(
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    port=443,
    host='kzn-swift.massopen.cloud',
    is_secure=True,
    calling_format=boto.s3.connection.OrdinaryCallingFormat())

#bucket = conn.create_bucket('versioning-enabled-bucket')
#bucket.configure_versioning(True)
        #conn.delete_bucket('test-bucket')
#for bucket in conn.get_all_buckets():
#      print "{name}\t{created}".format(
#                name = bucket.name,
#                created = bucket.creation_date,
# )
bucket = conn.get_bucket('versioning-enabled-bucket')
k = bucket.new_key('sample.txt')
k.set_contents_from_filename('sample.txt')

for version in bucket.list_versions():
    print(version)



