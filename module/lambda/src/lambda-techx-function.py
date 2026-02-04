import json
import boto3
from decimal import Decimal
from boto3.dynamodb.conditions import Key, Attr

# --- CONFIGURATION ---
# Ensure this matches your actual Table Region (us-east-1 or us-east-2)
DYNAMO_REGION = 'us-east-1' 
TABLE_NAME = "techx-tf-main-table"

dynamodb = boto3.resource('dynamodb', region_name=DYNAMO_REGION)
table = dynamodb.Table(TABLE_NAME)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    # Enable CORS for every response
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': 'http://localhost:5173',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'OPTIONS,GET,POST'
    }

    try:
        http_method = event.get('httpMethod')
        path = event.get('path')
        
        # Log for debugging
        print(f"Request: {http_method} {path}")

        if http_method == 'OPTIONS':
            return {'statusCode': 200, 'headers': headers, 'body': ''}

        # --- ROUTE 1: GET /courses (Public Catalog) ---
        if path == '/courses' and http_method == 'GET':
            query_params = event.get('queryStringParameters') or {}
            search_term = query_params.get('search')

            if search_term:
                response = table.scan(
                    FilterExpression=Attr('SK').eq('METADATA') & Attr('Title').contains(search_term)
                )
            else:
                response = table.scan(FilterExpression=Attr('SK').eq('METADATA'))
            
            return {
                'statusCode': 200, 
                'headers': headers,
                'body': json.dumps(response.get('Items', []), cls=DecimalEncoder)
            }

        # --- ROUTE 2: GET /courses/{id} (Course Details) ---
        elif path and path.startswith('/courses/') and http_method == 'GET':
            course_id = path.split('/')[-1]
            response = table.query(KeyConditionExpression=Key('PK').eq(f"COURSE#{course_id}"))
            return {
                'statusCode': 200, 'headers': headers,
                'body': json.dumps(response.get('Items', []), cls=DecimalEncoder)
            }

        # --- ROUTE 3: USER ROUTES (Protected) ---
        elif path == '/user':
            
            # A. WRITE DATA (POST)
            if http_method == 'POST':
                body = json.loads(event.get('body', '{}'))
                user_id = body.get('userId')
                action_type = body.get('type') # <--- Defined here, safe for all blocks below

                if not user_id or not action_type:
                     return {'statusCode': 400, 'headers': headers, 'body': json.dumps({"error": "Missing userId or type"})}

                # 1. ENROLL
                if action_type == 'ENROLL':
                    table.put_item(Item={
                        'PK': f"USER#{user_id}",
                        'SK': f"COURSE#{body['courseId']}",
                        'Title': body.get('title'),
                        'TotalVideos': body.get('totalVideos', 0),
                        'Status': 'IN_PROGRESS',
                        'LastAccess': 'NOW'
                    })
                    return {'statusCode': 200, 'headers': headers, 'body': json.dumps({"message": "Enrolled"})}

                # 2. WATCH (Progress Tracking)
                elif action_type == 'WATCH':
                    table.put_item(Item={
                        'PK': f"USER#{user_id}",
                        'SK': f"WATCHED#{body['videoId']}",
                        'VideoId': body['videoId'],
                        'CourseId': body.get('courseId'), # Critical for progress bar
                        'Completed': True
                    })
                    return {'statusCode': 200, 'headers': headers, 'body': json.dumps({"message": "Marked watched"})}

                # 3. BOOKMARK
                elif action_type == 'BOOKMARK':
                    table.put_item(Item={
                        'PK': f"USER#{user_id}",
                        'SK': f"BOOKMARK#{body['courseId']}",
                        'Title': body.get('title'),
                        'TotalVideos': body.get('totalVideos'),
                        'Thumbnail': body.get('thumbnail')
                    })
                    return {'statusCode': 200, 'headers': headers, 'body': json.dumps({"message": "Bookmarked"})}
                
                # 4. REMOVE BOOKMARK
                elif action_type == 'REMOVE_BOOKMARK':
                    table.delete_item(Key={
                        'PK': f"USER#{user_id}",
                        'SK': f"BOOKMARK#{body['courseId']}"
                    })
                    return {'statusCode': 200, 'headers': headers, 'body': json.dumps({"message": "Bookmark Removed"})}

                # 5. SAVE NOTE
                elif action_type == 'NOTE':
                    table.put_item(Item={
                        'PK': f"USER#{user_id}",
                        'SK': f"NOTE#{body['courseId']}#{body['videoId']}",
                        'NoteText': body.get('text'),
                        'VideoId': body['videoId'],
                        'Updated': 'NOW'
                    })
                    return {'statusCode': 200, 'headers': headers, 'body': json.dumps({"message": "Note Saved"})}

                else:
                    return {'statusCode': 400, 'headers': headers, 'body': json.dumps({"error": "Invalid Action Type"})}
            
            # B. READ DATA (GET) - Dashboard
            elif http_method == 'GET':
                query_params = event.get('queryStringParameters') or {}
                user_id = query_params.get('userId')
                
                if not user_id:
                    return {'statusCode': 400, 'headers': headers, 'body': json.dumps({"error": "Missing userId"})}

                response = table.query(KeyConditionExpression=Key('PK').eq(f"USER#{user_id}"))
                return {
                    'statusCode': 200, 'headers': headers,
                    'body': json.dumps(response.get('Items', []), cls=DecimalEncoder)
                }

        return {'statusCode': 400, 'headers': headers, 'body': json.dumps({'error': 'Invalid Route'})}

    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}")
        # Return the actual error so we can see it in the browser console
        return {
            'statusCode': 500, 
            'headers': headers, 
            'body': json.dumps({"error": f"Server Crash: {str(e)}"})
        }