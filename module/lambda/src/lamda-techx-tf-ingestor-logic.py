import json
import boto3
import urllib.request
from boto3.dynamodb.conditions import Key

# CONFIG
REGION = "us-east-1"
SECRET_NAME = "techx_youtube_api_key" 
TABLE_NAME = "techx-tf-main-table"

def get_api_key():
    client = boto3.client("secretsmanager", region_name=REGION)
    try:
        resp = client.get_secret_value(SecretId=SECRET_NAME)
        return json.loads(resp['SecretString'])['YOUTUBE_API_KEY']
    except Exception as e:
        print(f"Secret Error: {e}")
        raise e

def fetch_playlist_items(api_key, playlist_id):
    videos = []
    next_token = ""
    base_url = "https://www.googleapis.com/youtube/v3/playlistItems"
    
    while True:
        url = f"{base_url}?part=snippet,contentDetails&maxResults=50&playlistId={playlist_id}&key={api_key}&pageToken={next_token}"
        
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            
            for item in data.get('items', []):
                try:
                    videos.append({
                        "id": item["contentDetails"]["videoId"],
                        "title": item["snippet"]["title"],
                        "thumbnail": item["snippet"]["thumbnails"]["high"]["url"]
                    })
                except:
                    continue 
            
            next_token = data.get('nextPageToken')
            if not next_token:
                break
    return videos

def lambda_handler(event, context):
    try:
        # Security Check: In a real app, we check claims['cognito:groups'] here too.
        # But for now, we rely on API Gateway to block non-admins.
        
        body = json.loads(event.get('body', '{}'))
        playlist_id = body.get('playlistId')
        course_title = body.get('courseTitle')
        
        if not playlist_id or not course_title:
            return {'statusCode': 400, 'body': json.dumps({'error': 'Missing playlistId or courseTitle'})}

        api_key = get_api_key()
        videos = fetch_playlist_items(api_key, playlist_id)
        
        dynamodb = boto3.resource('dynamodb', region_name=REGION)
        table = dynamodb.Table(TABLE_NAME)
        
        course_id = course_title.strip().replace(" ", "-").upper()
        
        with table.batch_writer() as batch:
            # Metadata
            batch.put_item(Item={
                "PK": f"COURSE#{course_id}",
                "SK": "METADATA",
                "Type": "COURSE",
                "Title": course_title,
                "TotalVideos": len(videos)
            })
            # Videos
            for index, vid in enumerate(videos):
                batch.put_item(Item={
                    "PK": f"COURSE#{course_id}",
                    "SK": f"VIDEO#{index+1:03d}#{vid['id']}",
                    "Type": "VIDEO",
                    "VideoTitle": vid['title'],
                    "YouTubeID": vid['id'],
                    "Thumbnail": vid['thumbnail']
                })

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,Authorization'
            },
            'body': json.dumps({'message': f"Successfully imported {len(videos)} videos for {course_title}"})
        }
        
    except Exception as e:
        return {'statusCode': 500, 'headers': {'Access-Control-Allow-Origin': '*'}, 'body': json.dumps({'error': str(e)})}