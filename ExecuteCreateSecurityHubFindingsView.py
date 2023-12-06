import boto3
import os
import json
import uuid
import random
import string

def execute_queries(athena_client, queries, database, workgroup, output_bucket):
    print(queries)
    for query in queries:
        try:
            print(query)
            queryId = athena_client.get_named_query(
            NamedQueryId=query
            )
            print(queryId['NamedQuery']['QueryString'])
            response = athena_client.start_query_execution(
                QueryString=queryId['NamedQuery']['QueryString'],
                QueryExecutionContext={
                    'Database': database
                },
                ResultConfiguration={
                    'OutputLocation': f"s3://{output_bucket}/athena-results/"
                },
                WorkGroup=workgroup
            )

            query_execution_id = response['QueryExecutionId']
            print(f"QueryExecutionId: {query_execution_id}")

        except Exception as e:
            print(f"Error executing query: {str(e)}")

def refresh_data_set(data_set_id,awsAccountId,res):
    refresh_schedule = boto3.client('quicksight')
    response = refresh_schedule.create_ingestion(
        DataSetId= data_set_id,
        AwsAccountId = awsAccountId,
        IngestionId   = res,
        IngestionType='FULL_REFRESH'
    )
    print (response)


def lambda_handler(event, context):
    athena_client = boto3.client('athena')
    # Retrieve environment variables
    named_queries = os.environ.get('NAMED_QUERIES')
    named_queries = named_queries.split(',')
    # named_queries = [uuid.UUID(element) for element in named_queries.split(',')]
    database = os.environ.get('ATHENA_DATABASE')
    workgroup = os.environ.get('ATHENA_WORKGROUP')
    output_bucket = os.environ.get('ATHENA_OUTPUT_BUCKET')
    data_set_id = os.environ.get('DATA_SET_ID')
    awsAccountId = os.environ.get('AWSACCOUNTId')
    res = ''.join(random.choices(string.ascii_lowercase + string.digits, k=5))
    print(res)

    if not named_queries or not database or not workgroup or not output_bucket:
        print("Missing required environment variables.")
        return {
            'statusCode': 500,
            'body': 'Missing required environment variables.'
        }

    execute_queries(athena_client, named_queries, database, workgroup, output_bucket)
    refresh_data_set(data_set_id,awsAccountId,res)

    return {
        'statusCode': 200,
        'body': 'Queries submitted successfully.'
    }