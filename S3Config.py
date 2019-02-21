import boto3
#import boto.s3.connection
import os
import uuid

#access_key = os.environ.get('AWS_ACCESS_KEY')
#secret_key = os.environ.get('AWS_ACCESS_KEY')
#session=boto3.Session(profile_name='default')
s3_resource = boto3.client('s3')

def create_bucket_name(bucket_prefix):
    # The generated bucket name must be between 3 and 63 chars long
    return ''.join([bucket_prefix, str(uuid.uuid4())])

BUCKET=create_bucket_name('devsecops-')
print(BUCKET)
s3_resource.create_bucket(Bucket=BUCKET)
#logging = s3_resource(BUCKET)  WHERE WAS I GOING WITH THIS ONE?

cors_configuration = {
	'CORSRules': [{
        'AllowedHeaders': ['Authorization'],
        'AllowedMethods': ['GET', 'PUT'],
        'AllowedOrigins': ['*'],
        'ExposeHeaders': ['GET', 'PUT'],
        'MaxAgeSeconds': 3000
    }]
}
s3_resource.put_bucket_cors(Bucket=BUCKET, CORSConfiguration=cors_configuration)

'''
conn = boto.connect_s3(
        aws_access_key_id = access_key,
        aws_secret_access_key = secret_key,
        host = 'objects.dreamhost.com', #change this
        #is_secure=False,               # uncomment if you are not using ssl
        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
        )
#print(access_key)
bucket = conn.create_bucket('my-new-bucket')
'''
