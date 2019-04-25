# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 17:43:34 2019

@author: AvantikaDG
"""

import boto
import os
import uuid

access_key = os.environ.get('OS_ACCESS_KEY')
secret_key = os.environ.get('OS_SECRET_KEY')



conn = boto.s3.connection.S3Connection(
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    port=443,
    host='swift-kaizen.massopen.cloud',
    is_secure=True,
    calling_format=boto.s3.connection.OrdinaryCallingFormat())

bucket = conn.create_bucket('log_bucket')
bucket.configure_versioning(True)

