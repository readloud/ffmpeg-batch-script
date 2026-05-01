## Dependensi yang diperlukan:

`ffmpeg dan ffprobe` - untuk processing audio/video
`yt-dlp` - untuk download dari YouTube
`whisper` - untuk transkripsi (opsional)
`PowerShell` - untuk TTS (Windows)

Instalasi dependensi Python:

```bash
pip install openai-whisper  # untuk transkripsi
```

## Perbedaan utama dari batch script:

	*Menggunakan fungsi terstruktur*
	*Error handling yang lebih baik*
	*Path handling cross-platform (dengan catatan)*

## Fitur yang belum diimplementasikan sepenuhnya:
	
	*Beberapa filter kompleks mungkin perlu penyesuaian*
	*Device detection untuk webcam/microphone lebih sederhana*

Untuk menjalankan:

```bash
python visualizer.py
```

## Fitur yang Tersedia di Web Version:

Aplikasi web ini menyediakan UI modern dengan semua fungsionalitas dari batch script asli, dengan beberapa fitur yang bekerja langsung di browser!

### ✅ Fitur yang Berfungsi Penuh (Client-side):
1. **Screen & Camera Recorder** - Menggunakan MediaRecorder API
2. **TTS Speech Synthesizer** - Menggunakan Web Speech API
3. **Settings Panel** - Penyimpanan konfigurasi lokal
4. **UI/UX** - Responsive design dengan animasi

### ⚠️ Fitur yang Membutuhkan Backend:
1. **YouTube Download** - Memerlukan yt-dlp di server
2. **Audio/Video Conversion** - Memerlukan FFmpeg di server
3. **Whisper Transcription** - Memerlukan OpenAI Whisper
4. **File Processing** - Konversi format file

## Cara Menjalankan:

### Opsi 1: Langsung di Browser
```bash
# Simpan sebagai visualizer.html dan buka dengan browser
start visualizer.html
```

### Opsi 2: Dengan Server Backend (Full Features)

**Instalasi Backend:**
```bash
pip install flask flask-cors
python backend.py
```

## Catatan Penting:

1. **Browser Support**: Gunakan Chrome/Edge untuk Web Speech API
2. **HTTPS Required**: Untuk camera/screen recording di beberapa browser
3. **Backend Required**: Untuk full video processing features
4. **Storage**: File disimpan di folder Downloads pengguna

## Web Hosting - Full Stack Web Application

Berikut adalah aplikasi web lengkap yang siap di-deploy ke web hosting (Python backend + HTML/CSS/JS frontend):

## Struktur File untuk Hosting

```
visualizer/
├── index.html          # Frontend utama
├── style.css           # Styling
├── script.js           # Frontend logic
├── backend.py          # Flask backend (Python)
├── requirements.txt    # Dependencies
├── .htaccess          # Apache config (opsional)
└── vercel.json        # Untuk deploy ke Vercel
```
---

## 1. File `index.html` - Frontend Utama
## 3. File `script.js` - Frontend Logic
## 4. File `backend.py` - Flask Backend
## 5. File `requirements.txt`
## 6. File `vercel.json` (Untuk deploy ke Vercel)
## 7. File `.htaccess` (Untuk Apache hosting)

---

## Cara Deploy ke Berbagai Platform

### 1. **PythonAnywhere (Free Hosting)**
```bash
# Upload file via Web UI atau git
# Setup web app dengan Python 3.11
# Install dependencies: pip install -r requirements.txt
# Set WSGI configuration file
```

### 2. **Render.com (Recommended)**
```bash
# Connect GitHub repository
# Create new Web Service
# Build Command: pip install -r requirements.txt
# Start Command: gunicorn backend:app
```

### 3. **Railway.app**
```bash
# Connect repository
# Railway会自动检测Python项目
# Add environment variables if needed
```

### 4. **Vercel (Serverless)**
```bash
npm install -g vercel
vercel deploy
```

### 5. **Traditional Hosting (cPanel)**
```bash
# Upload all files via FTP
# Setup Python App in cPanel
# Point to backend.py
```

---

## Catatan Penting untuk Hosting:

1. **FFmpeg Requirement**: Pastikan hosting memiliki FFmpeg terinstall
2. **Storage**: File temporary akan terhapus otomatis
3. **Rate Limiting**: Tambahkan rate limiting untuk production
4. **Authentication**: Tambahkan API key untuk keamanan
5. **Background Tasks**: Gunakan Celery/Redis untuk processing lama

Aplikasi ini siap deploy ke berbagai platform hosting dengan full features!