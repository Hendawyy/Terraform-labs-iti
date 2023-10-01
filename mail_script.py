import boto3

def lambda_handler(event, context):
    ses = boto3.client('ses', region_name='eu-central-1')
    sender_email = 'seifhendawy1@gmail.com'
    recipient_email = 'seifhendawy1@gmail.com'
    subject = 'Hello'
    body = "This is a lambda Function implemented in python to send email"
    response = ses.send_email(
        Source=sender_email,  # Corrected variable name
        Destination={
            'ToAddresses': [
                recipient_email,
            ],
        },
        Message={
            'Subject': {
                'Data': subject,
            },
            'Body': {
                'Text': {
                    'Data': body,
                },
            },
        },
    )

    return {
        'statusCode': 200,
        'body': 'Email sent successfully.',
    }
