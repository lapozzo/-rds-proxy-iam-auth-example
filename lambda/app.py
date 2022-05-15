import mysql.connector
import os
import boto3
from aws_lambda_powertools import Logger

logger = Logger()

ENDPOINT=os.environ['ENDPOINT']
PORT=os.environ['PORT']
USER=os.environ['USER']
DBNAME=os.environ['DBNAME']
REGION='us-east-1'
os.environ['LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN'] = '1'

#IAM AUTH Token
client = boto3.client('rds')
token = client.generate_db_auth_token(DBHostname=ENDPOINT, Port=PORT, DBUsername=USER, Region=REGION)

@logger.inject_lambda_context(log_event=True)
def lambda_handler(event, context):
    try:
        conn =  mysql.connector.connect(host=ENDPOINT, user=USER, passwd=token, port=PORT, database=DBNAME, ssl_ca='SSLCERTIFICATE')
        cur = conn.cursor()
        cur.execute("""SELECT now()""")
        query_results = cur.fetchall()
        logger.info(query_results)
    except Exception as e:
        logger.exception("Database connection failed due to {}".format(e))          
                    