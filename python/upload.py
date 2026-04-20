import os
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from google_auth_oauthlib.flow import InstalledAppFlow

def upload_to_youtube(video_file, thumb_file, title):
    scopes = ["https://www.googleapis.com/auth/youtube.upload"]
    flow = InstalledAppFlow.from_client_secrets_file("client_secrets.json", scopes)
    credentials = flow.run_local_server(port=0)
    youtube = build("youtube", "v3", credentials=credentials)

    request_body = {
        'snippet': {
            'title': title,
            'description': 'Automated upload via Gemini Python Script',
            'tags': ['music', 'visualizer', 'neon'],
            'categoryId': '10' # Music category
        },
        'status': {
            'privacyStatus': 'private', # Start as private to check quality
            'selfDeclaredMadeForKids': False
        }
    }
def generate_description(song_title, artist="Your Brand Name"):
    template = f"""
🎵 Now Playing: {song_title}
Artist: {artist}

Enjoy this high-definition music visualizer. 
Don't forget to Like, Comment, and Subscribe for more daily uploads!

---
🔗 FOLLOW US:
Instagram: https://instagram.com/yourhandle
Spotify: https://spotify.com/yourprofile
Soundcloud: https://soundcloud.com/yourprofile

---
⚠️ COPYRIGHT DISCLAIMER:
If you are the owner of this music and want it removed, please contact us 
at your@email.com and we will take it down immediately.

#Music #Visualizer #Neon #{song_title.replace(' ', '')}
    """
    return template

# Usage inside your loop:
# current_description = generate_description(display_title)
    # Upload Video
    media = MediaFileUpload(video_file, chunksize=-1, resumable=True)
    response = youtube.videos().insert(
        part="snippet,status", body=request_body, media_body=media
    ).execute()

    video_id = response['id']
    print(f"Video uploaded! ID: {video_id}")

    # Upload Thumbnail
    youtube.thumbnails().set(videoId=video_id, media_body=MediaFileUpload(thumb_file)).execute()
    print("Thumbnail set successfully!")