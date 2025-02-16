import json
import boto3

bedrock_client = boto3.client('bedrock-runtime')
#print(boto3.__version__)

def handler(event, context):
    # Extract the prompt from the incoming event
    try:
        # Check if the body is a string (API Gateway sends the body as a string)
        if 'body' in event:
            body = json.loads(event['body'])
            user_prompt = body['prompt']
        else:
            # Direct invocation case
            user_prompt = event['prompt']
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'Invalid request format. Please provide a prompt in the request body.',
                'details': str(e)
            })
        }

    print(f"Processing prompt: {user_prompt}")
   
    # Make API call to Bedrock with text generation parameters
    bedrock_response = bedrock_client.invoke_model(
       contentType='application/json',
       accept='application/json',
       modelId='cohere.command-light-text-v14',
       body=json.dumps({
        "prompt": f"Summarize the following text. Be concise and to the point. {user_prompt}",
        "temperature": 0.9,
        "p": 0.75,
        "k": 0,
        "max_tokens": 100}))

    response_bytes = bedrock_response['body'].read()
    
    # Convert JSON response to Python dictionary
    response_json = json.loads(response_bytes)

    generated_text = response_json['generations'][0]['text'].strip()

    # Return the generated text with success status code
    return {
        'statusCode': 200,
        'body': json.dumps({
            'summary': generated_text
        })
    }