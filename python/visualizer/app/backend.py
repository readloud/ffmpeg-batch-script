#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
READLOUD Visualizer - Backend API
Untuk deploy ke web hosting (PythonAnywhere, Render, Railway, dll)
"""

import os
import subprocess
import json
import uuid
import shutil
from pathlib import Path
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from werkzeug.utils import secure_filename
import yt_dlp
import whisper
from pydub import AudioSegment
import tempfile

app = Flask(__name__)
CORS(app)

# ==================== Konfigurasi ====================
app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # 500MB max
app.config['UPLOAD_FOLDER'] = '/tmp/visualizer_uploads'
app.config['OUTPUT_FOLDER'] = '/tmp/visualizer_outputs'

# Buat direktori jika belum ada
Path(app.config['UPLOAD_FOLDER']).mkdir(parents=True, exist_ok=True)
Path(app.config['OUTPUT_FOLDER']).mkdir(parents=True, exist_ok=True)

ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'avi', 'mov', 'mkv', 'webm'}
ALLOWED_AUDIO_EXTENSIONS = {'mp3', 'wav', 'm4a', 'opus'}
ALLOWED_IMAGE_EXTENSIONS = {'jpg', 'jpeg', 'png', 'gif', 'webp'}

# ==================== Helper Functions ====================
def allowed_file(filename, allowed_set):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_set

def get_duration(filepath):
    """Get duration of audio/video file in seconds"""
    try:
        result = subprocess.run(
            ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
             '-of', 'default=noprint_wrappers=1:nokey=1', filepath],
            capture_output=True, text=True, check=True
        )
        return float(result.stdout.strip())
    except:
        return 0

def sanitize_filename(name):
    """Bersihkan nama file"""
    name = name.replace('_', ' ')
    name = ''.join(c for c in name if c.isalnum() or c in ' .()-')
    return name.strip()

# ==================== API Endpoints ====================

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get system statistics"""
    return jsonify({
        'success': True,
        'music': 0,  # In production, scan actual directories
        'video': 0,
        'image': 0,
        'output': 0
    })

@app.route('/api/download', methods=['POST'])
def download_audio():
    """Download audio from YouTube"""
    data = request.json
    url = data.get('url')
    format_type = data.get('format', 'mp3')
    
    if not url:
        return jsonify({'success': False, 'error': 'URL required'}), 400
    
    try:
        output_template = os.path.join(app.config['UPLOAD_FOLDER'], '%(title)s.%(ext)s')
        
        ydl_opts = {
            'format': 'bestaudio/best',
            'postprocessors': [{
                'key': 'FFmpegExtractAudio',
                'preferredcodec': format_type,
                'preferredquality': '320',
            }],
            'outtmpl': output_template,
            'quiet': True,
        }
        
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            filename = ydl.prepare_filename(info)
            if format_type != 'mp3':
                filename = filename.rsplit('.', 1)[0] + f'.{format_type}'
            
            return jsonify({
                'success': True,
                'filepath': filename,
                'title': info.get('title', 'Unknown')
            })
            
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/waveform', methods=['POST'])
def create_waveform():
    """Create waveform video from audio"""
    if 'audio' not in request.files:
        return jsonify({'success': False, 'error': 'No audio file'}), 400
    
    audio_file = request.files['audio']
    format_type = request.form.get('format', 'yt')
    visual_style = request.form.get('style', 'waveform')
    
    if not audio_file:
        return jsonify({'success': False, 'error': 'No audio file'}), 400
    
    # Save audio
    audio_path = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(audio_file.filename))
    audio_file.save(audio_path)
    
    # Get duration
    duration = get_duration(audio_path)
    
    # Generate output filename
    output_filename = f"waveform_{uuid.uuid4().hex}.mp4"
    output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
    
    # Configure dimensions
    if format_type == 'yt':
        width, height = '1920', '1080'
    elif format_type == 'shorts':
        width, height = '1080', '1920'
    else:
        width, height = '1080', '1080'
    
    try:
        # Build ffmpeg command for waveform
        cmd = [
            'ffmpeg', '-y', '-i', audio_path,
            '-filter_complex', f'[0:a]showwaves=s={width}x{height}:mode=cline:rate=25:colors=0x00FF88[v]',
            '-map', '[v]', '-map', '0:a',
            '-c:v', 'libx264', '-preset', 'fast', '-crf', '23',
            '-c:a', 'aac', '-b:a', '192k', '-shortest', output_path
        ]
        
        subprocess.run(cmd, capture_output=True, check=True)
        
        return jsonify({
            'success': True,
            'output_file': output_filename,
            'download_url': f'/api/download_file/{output_filename}'
        })
        
    except subprocess.CalledProcessError as e:
        return jsonify({'success': False, 'error': e.stderr.decode()}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/transcribe', methods=['POST'])
def transcribe_audio():
    """Transcribe audio/video using Whisper"""
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file'}), 400
    
    file = request.files['file']
    language = request.form.get('language', 'id')
    model_size = request.form.get('model', 'base')
    
    if not file:
        return jsonify({'success': False, 'error': 'No file'}), 400
    
    # Save file
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(file.filename))
    file.save(filepath)
    
    try:
        # Load Whisper model
        model = whisper.load_model(model_size)
        
        # Transcribe
        result = model.transcribe(filepath, language=language)
        
        # Generate SRT
        srt_content = ""
        for i, segment in enumerate(result['segments']):
            start = segment['start']
            end = segment['end']
            text = segment['text'].strip()
            
            start_time = f"{int(start//3600):02d}:{int((start%3600)//60):02d}:{int(start%60):02d},{int((start%1)*1000):03d}"
            end_time = f"{int(end//3600):02d}:{int((end%3600)//60):02d}:{int(end%60):02d},{int((end%1)*1000):03d}"
            
            srt_content += f"{i+1}\n{start_time} --> {end_time}\n{text}\n\n"
        
        srt_filename = f"{uuid.uuid4().hex}.srt"
        srt_path = os.path.join(app.config['OUTPUT_FOLDER'], srt_filename)
        with open(srt_path, 'w', encoding='utf-8') as f:
            f.write(srt_content)
        
        return jsonify({
            'success': True,
            'text': result['text'],
            'segments': result['segments'],
            'srt_file': srt_filename,
            'download_url': f'/api/download_file/{srt_filename}'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/tts', methods=['POST'])
def generate_tts():
    """Generate TTS using Azure/Cognitive Services or local"""
    data = request.json
    text = data.get('text')
    voice = data.get('voice', 'id-ID-ArdiNeural')
    
    if not text:
        return jsonify({'success': False, 'error': 'Text required'}), 400
    
    # For demo, return mock response
    # In production, integrate with Azure TTS or Edge TTS
    
    return jsonify({
        'success': True,
        'message': 'TTS feature requires Azure Cognitive Services API key',
        'text': text,
        'voice': voice
    })

@app.route('/api/merge', methods=['POST'])
def merge_videos():
    """Merge multiple videos"""
    if 'videos' not in request.files:
        return jsonify({'success': False, 'error': 'No video files'}), 400
    
    videos = request.files.getlist('videos')
    if not videos:
        return jsonify({'success': False, 'error': 'No video files'}), 400
    
    # Save all videos
    video_paths = []
    for video in videos:
        path = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(video.filename))
        video.save(path)
        video_paths.append(path)
    
    # Create concat file
    concat_file = os.path.join(app.config['UPLOAD_FOLDER'], 'concat.txt')
    with open(concat_file, 'w') as f:
        for path in video_paths:
            f.write(f"file '{path}'\n")
    
    output_filename = f"merged_{uuid.uuid4().hex}.mp4"
    output_path = os.path.join(app.config['OUTPUT_FOLDER'], output_filename)
    
    try:
        cmd = [
            'ffmpeg', '-y', '-f', 'concat', '-safe', '0',
            '-i', concat_file, '-c', 'copy', output_path
        ]
        subprocess.run(cmd, capture_output=True, check=True)
        
        return jsonify({
            'success': True,
            'output_file': output_filename,
            'download_url': f'/api/download_file/{output_filename}'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/download_file/<filename>')
def download_file(filename):
    """Download generated file"""
    filepath = os.path.join(app.config['OUTPUT_FOLDER'], filename)
    if os.path.exists(filepath):
        return send_file(filepath, as_attachment=True)
    return jsonify({'success': False, 'error': 'File not found'}), 404

@app.route('/api/cleanup', methods=['POST'])
def cleanup():
    """Clean temporary files"""
    try:
        for f in os.listdir(app.config['UPLOAD_FOLDER']):
            os.remove(os.path.join(app.config['UPLOAD_FOLDER'], f))
        for f in os.listdir(app.config['OUTPUT_FOLDER']):
            os.remove(os.path.join(app.config['OUTPUT_FOLDER'], f))
        return jsonify({'success': True, 'message': 'Cleanup complete'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'version': '2.0.0'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)