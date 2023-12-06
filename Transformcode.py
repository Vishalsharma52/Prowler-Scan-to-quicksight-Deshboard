import base64
import base64
print('Loading function')
def lambda_handler(event, context):
    output = []
    print(event)
    for record in event['records']:
        print(record['recordId'])
        payload = base64.b64decode(record['data']).decode('utf-8')
        print('decoded payload: ' + str(payload))
        payload = str(payload) + '\n'
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload.encode('utf-8'))
            }
        output.append(output_record)
    print('Successfully processed {} records.'.format(len(event['records'])))
    return {'records': output}