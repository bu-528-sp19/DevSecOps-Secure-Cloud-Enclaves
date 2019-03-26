import boto3
import uuid

# s3 = boto3.resource('s3')

session = boto3.session.Session()

s3_client = session.client(
    service_name='s3',
    aws_access_key_id='08f1ed3eacab4d9dbea7ffe2bde56b7f',
    aws_secret_access_key='b62363429ac145b78912638ecbecddc9',
    endpoint_url='https://kzn-swift.massopen.cloud/swift/v1',
#    endpoint_url='https://kaizen.massopen.cloud:13788'
)
#s3_client.create_bucket(Bucket='avanavanavanheyheyheyec528ec528ec528devsecopsyoohoo')

def create_bucket_name(bucket_prefix):
    # The generated bucket name must be between 3 and 63 chars long
    return ''.join([bucket_prefix, str(uuid.uuid4())])

BUCKET=create_bucket_name('devsecops-')
print(BUCKET)
s3_client.create_bucket(Bucket=BUCKET)


print(s3_client.list_buckets())

