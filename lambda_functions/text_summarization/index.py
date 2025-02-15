import json
import boto3
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

# Create client connection with Bedrock and S3 Services
bedrock_client = boto3.client('bedrock-runtime')



def handler(event, context):
    try:
        # Extract text summarization prompt from API Gateway request
        input_prompt = event['prompt']
        """
        Example request body:
        {
            "prompt": "lorem ipsum dolor sit amet",
        }
        """
        text_prompt = input_prompt['prompt'] 
        
        # Call Bedrock API to generate text summarization
        prompt_response = bedrock_client.invoke_model(
            modelId='cohere.command-light-text-v14', 
            contentType='application/json',
            accept='application/json', 
            body=json.dumps({
                "prompt": text_prompt,
                "temperature": 0.9,
                "p": 0.75,
                "k": 0,
                "max_tokens": 100,
            }), 
        )  


        # Parse the response from Bedrock
        response_body = json.loads(prompt_response['body'].read())
        summary = response_body['generations'][0][0]['text']

        # Return success response with download URL
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'data': summary
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