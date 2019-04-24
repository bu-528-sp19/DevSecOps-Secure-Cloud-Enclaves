
import boto
import boto.s3.connection
import boto.s3
import logging
import datetime
import argparse

access_key = '08f1ed3eacab4d9dbea7ffe2bde56b7f' #Change to OS vars
secret_key = 'b62363429ac145b78912638ecbecddc9' 
logging.basicConfig(filename='example.log',level=logging.DEBUG) #Change to /var/logs/...
#parser = argparse.ArgumentParser()
#parser.add_argument("echo")
#args = parser.parse_args()
#print(args.echo)

def list_buckets():
    logging.info('list_buckets() '+ str(datetime.datetime.now()))
    try:
        for bucket in conn.get_all_buckets():
            print("{name}\t{created}".format(name = bucket.name,created = bucket.creation_date))
    except:
        logging.error('list_buckets() - buckets could not be listed')
    
        
def create_bucket(bucket_name):
    logging.info('create_bucket() %s %s',bucket_name, str(datetime.datetime.now()))
    try:
        for bucket in conn.get_all_buckets():
            if bucket.name == bucket_name:
                raise Exception('create_bucket() - Bucket name '+ bucket_name + ' already in use')
        bucket = conn.create_bucket(bucket_name)
        bucket.configure_versioning(True)
    except Exception as err:
        print(err)
        logging.error(err)

def delete_bucket(bucket_name):
    logging.info('delete_bucket() '+ bucket_name + ' ' + str(datetime.datetime.now()))
    try:
        flag = False
        for bucket in conn.get_all_buckets():
            if bucket.name == bucket_name:
                flag = True
                break
        if not flag:
            raise Exception('delete_bucket() - Bucket name '+ bucket_name + ' does not exist')
        conn.delete_bucket(bucket_name)
    except Exception as err:
        print(err)
        logging.error(err)
    
def list_bucket_versions(bucket_name):
    logging.info('list_bucket_versions() '+ bucket_name + ' ' + str(datetime.datetime.now()))
    try:    
        bucket = conn.get_bucket(bucket_name)
        versions = bucket.list_versions()
        print("Versions: ----------")
        for version in versions:
            print(version)
    except:
        logging.error('list_bucket_versions() - buckets versions could not be listed')
    
def upload_to_bucket(key, path, bucket_name):
    logging.info('upload_to_bucket() '+ bucket_name + ' ' + str(datetime.datetime.now()))
    try:
        bucket = conn.get_bucket(bucket_name)
        k = bucket.new_key(key)
        k.set_contents_from_filename(path)
    except:
        logging.error('upload_to_bucket() - file could not be uploaded to bucket')

    
def download_from_bucket(key, path, bucket_name):
    logging.info('download_from_bucket() '+ bucket_name + ' ' + str(datetime.datetime.now()))
    try:
        bucket = conn.get_bucket(bucket_name)
        k = bucket.get_key(key)
        k.get_contents_to_filename(path)
    except:
        logging.error('download_from_bucket() - file could not be downloaded from bucket')
    
def delete_from_bucket(key, bucket_name):
    logging.info('delete_from_bucket() '+ bucket_name + ' ' + str(datetime.datetime.now()))
    try:
        bucket = conn.get_bucket(bucket_name)
        bucket.delete_key(key)
    except:
        logging.error('download_from_bucket() - file could not be downloaded from bucket')
    
conn = boto.s3.connection.S3Connection(
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    port=443,
    host='kzn-swift.massopen.cloud',
    is_secure=True,
    calling_format=boto.s3.connection.OrdinaryCallingFormat())

while True:
    input1 = input("Do you want to continue? (Y/N)").upper()
    if input1 == 'N':
        conn.close()
        break
    else:
        task = eval(input('''Enter: 
                     1. List bucket
                     2. Create bucket
                     3. Delete bucket
                     4. List bucket versions
                     5. Upload to bucket
                     6. Download from bucket
                     7. Delete from bucket '''))
        if task ==1:
            list_buckets()
        elif task ==2:
            input2 = input("Enter name of the bucket to be created: ")
            create_bucket(input2)
        elif task == 3:
            input2 = input("Enter name of the bucket to be deleted: ")
            delete_bucket(input2)
        elif task == 4:
            input2 = input("Enter name of the bucket for which version is to be obtained: ")
            list_bucket_versions(input2)
        elif task == 5:
            key = eval(input("Enter the key: "))
            path = input("Enter the path :")
            name = input("Enter the bucket name :")
            upload_to_bucket(key,path,name)
        elif task == 6:
            key = eval(input("Enter the key :"))
            path = input("Enter the path :")
            name = input("Enter the bucket name :")
            download_from_bucket(key,path,name)
        elif task == 7:
            key = eval(input("Enter the key :"))
            name = input("Enter the bucket name :")
            delete_from_bucket(key,name)
#list_buckets()
#create_bucket('api-testing-bucket')
#delete_bucket('api-testing-bucket')

#conn.close()