import json
import boto3
import base64
import datetime
import os

# Create client connection with Bedrock and S3 Services
client_bedrock = boto3.client('bedrock-runtime')
client_s3 = boto3.client('s3')

def handler(event, context): 
    try:
        # Extract text summarization prompt from API Gateway request
        request_body = json.loads(event['prompt'])
        text_prompt = request_body['prompt']

        print(f"Text prompt: {text_prompt}")
        
        
           
    
            
        # Return success response with download URL
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'data': 'success'
            })
        }
        
    except Exception as e:
        # Log error and return error response
        print(f"Error: {str(e)}")  # This will log to CloudWatch
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }