
import boto3
import pathlib

def download_directory(destination_path: str, bucket_name: str , prefix: str=""):

    client = boto3.client('s3')
    paginator = client.get_paginator('list_objects')

    for result in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
    # for result in paginator.paginate(Bucket=bucket_name, Prefix=prefix, PaginationConfig={'PageSize': 1}):
        for file in result.get('Contents', []):
            target = (file.get('Key')[len(prefix):])
            size = file.get('Size')
            if size == 0:
                continue
            print(target)
            dest_file = pathlib.Path(destination_path).joinpath(target)
            dest_file.parent.mkdir(parents=True, exist_ok=True)
            client.download_file(bucket_name, file.get('Key'), str(dest_file))

def download_file(destination_path: str, bucket_name: str, object_key: str):
    client = boto3.client('s3')
    client.download_file(bucket_name, object_key, str(destination_path))

def upload_file(source_path: str, bucket_name: str, object_key: str):
    client = boto3.client('s3')
    client.upload_file(str(source_path), bucket_name, object_key)
