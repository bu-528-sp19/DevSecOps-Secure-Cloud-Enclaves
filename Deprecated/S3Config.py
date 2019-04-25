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

BUCKET=create_bucket_name('devsecops5280-')
print(BUCKET)

s3_resource.create_bucket(Bucket=BUCKET)
accessPol = {
    'Grants': [
        {
            'Grantee': {
                'DisplayName': 'dharmit',
                'EmailAddress': 'dharmitdalvi2@gmail.com',
                'ID': '9a863af7bade0c82afeb34996f853c5a3ec40ac7bb5482b0f98b2c08be3dbae1',
                'Type': 'CanonicalUser',
            },
            'Permission': 'FULL_CONTROL'
        },
    ],
    'Owner': {
        'DisplayName': 'joshemb',
        'ID': ' 392007875efaa233c657fcd554bd85a02caed1e3347d6cd8e561fe9b2188fda7'
    }
}
response = s3_resource.put_bucket_acl(AccessControlPolicy=accessPol,Bucket=BUCKET)



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

'''

s3_resource.put_bucket_acl(ACL='private',
    AccessControlPolicy={
        'Grants': [
            {
                'Grantee':{
                    'DisplayName': 'dharmit',
                    'EmailAddress': 'dharmitdalvi2@gmail.com',
                    'ID': '9a863af7bade0c82afeb34996f853c5a3ec40ac7bb5482b0f98b2c08be3dbae1',
                    'Type': 'CanonicalUser'
                },
            'Permission': 'FULL_CONTROL'
            },
        ],
        'Owner':{
            'DisplayName':'joshemb',
            'ID':' 392007875efaa233c657fcd554bd85a02caed1e3347d6cd8e561fe9b2188fda7'
        }
    },
    Bucket=BUCKET
)'''
s3_resource.put_bucket_cors(Bucket=BUCKET, CORSConfiguration=cors_configuration)
fam = s3_resource.get_bucket_acl(Bucket=BUCKET)
#print(fam)
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
