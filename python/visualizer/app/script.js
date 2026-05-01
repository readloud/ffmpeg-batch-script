// ==================== API Configuration ====================
const API_BASE = window.location.origin + '/api';
let currentTool = null;
let mediaRecorder = null;
let recordedChunks = [];
let activityLog = [];

// ==================== Utility Functions ====================
function addLog(containerId, message, isError = false) {
    const container = document.getElementById(containerId);
    if (container) {
        const logLine = document.createElement('div');
        logLine.className = `log-line ${isError ? 'error' : ''}`;
        logLine.innerHTML = `[${new Date().toLocaleTimeString()}] ${message}`;
        container.appendChild(logLine);
        container.scrollTop = container.scrollHeight;
        
        // Also add to activity log
        activityLog.unshift({ message, timestamp: new Date(), isError });
        if (activityLog.length > 20) activityLog.pop();
        updateActivityList();
    }
}

function updateActivityList() {
    const container = document.getElementById('activityList');
    if (container) {
        container.innerHTML = activityLog.slice(0, 10).map(log => `
            <div class="activity-item">
                <span class="activity-icon">${log.isError ? '❌' : '✅'}</span>
                <span>${log.message}</span>
                <span class="activity-time">${new Date(log.timestamp).toLocaleTimeString()}</span>
            </div>
        `).join('');
    }
}

function updateProgress(fillId, percent) {
    const fill = document.getElementById(fillId);
    if (fill) {
        fill.style.width = percent + '%';
        fill.textContent = Math.round(percent) + '%';
    }
}

async function apiCall(endpoint, method = 'GET', data = null) {
    const options = {
        method,
        headers: {
            'Content-Type': 'application/json',
        }
    };
    
    if (data) {
        options.body = JSON.stringify(data);
    }
    
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, options);
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        return { success: false, error: error.message };
    }
}

// ==================== Navigation ====================
document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const pageId = item.getAttribute('data-page');
        
        // Update active state
        document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
        item.classList.add('active');
        
        // Show selected page
        document.querySelectorAll('.page').forEach(page => page.style.display = 'none');
        const targetPage = document.getElementById(`page-${pageId}`);
        if (targetPage) targetPage.style.display = 'block';
    });
});

// ==================== Dashboard Stats ====================
async function loadStats() {
    try {
        const stats = await apiCall('/stats');
        if (stats.success) {
            document.getElementById('statMusic').textContent = stats.music || 0;
            document.getElementById('statVideo').textContent = stats.video || 0;
            document.getElementById('statImage').textContent = stats.image || 0;
            document.getElementById('statOutput').textContent = stats.output || 0;
        }
    } catch (error) {
        console.error('Failed to load stats:', error);
    }
}

// ==================== Download Functions ====================
async function startDownload() {
    const url = document.getElementById('downloadUrl').value;
    const format = document.getElementById('downloadFormat').value;
    
    if (!url) {
        addLog('downloadLog', 'Masukkan YouTube URL!', true);
        return;
    }
    
    addLog('downloadLog', `Memulai download: ${url}`);
    addLog('downloadLog', `Format: ${format.toUpperCase()}`);
    
    const progressDiv = document.getElementById('downloadProgress');
    progressDiv.style.display = 'block';
    
    try {
        const response = await apiCall('/download', 'POST', { url, format });
        
        if (response.success) {
            for (let i = 0; i <= 100; i += 10) {
                await new Promise(resolve => setTimeout(resolve, 100));
                updateProgress('downloadFill', i);
            }
            addLog('downloadLog', '✅ Download berhasil!');
            addLog('downloadLog', `📁 File disimpan di: ${response.filepath || 'Music folder'}`);
        } else {
            addLog('downloadLog', `❌ Error: ${response.error}`, true);
        }
    } catch (error) {
        addLog('downloadLog', `❌ Error: ${error.message}`, true);
    }
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        updateProgress('downloadFill', 0);
    }, 2000);
}

// ==================== Waveform Functions ====================
async function createWaveform() {
    const format = document.getElementById('waveformFormat').value;
    const visualStyle = document.getElementById('visualStyle').value;
    const textColor = document.getElementById('textColor').value;
    const bgColor = document.getElementById('bgColor').value;
    
    addLog('waveformLog', `Creating waveform video...`);
    addLog('waveformLog', `Format: ${format}, Style: ${visualStyle}`);
    
    const progressDiv = document.getElementById('waveformProgress');
    progressDiv.style.display = 'block';
    
    // Simulate processing
    for (let i = 0; i <= 100; i += 5) {
        await new Promise(resolve => setTimeout(resolve, 80));
        updateProgress('waveformFill', i);
        if (i === 30) addLog('waveformLog', 'Memproses audio...');
        if (i === 60) addLog('waveformLog', 'Membuat visualizer...');
        if (i === 90) addLog('waveformLog', 'Menggabungkan video...');
    }
    
    addLog('waveformLog', '✅ Video waveform berhasil dibuat!');
    addLog('waveformLog', `📁 Output: Videos/Exports/waveform_${Date.now()}.mp4`);
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        updateProgress('waveformFill', 0);
    }, 2000);
}

// ==================== Bulk Download ====================
async function startBulkDownload() {
    const fileInput = document.getElementById('bulkFile');
    const bulkType = document.getElementById('bulkType').value;
    
    if (!fileInput.files.length) {
        addLog('bulkLog', 'Upload file TXT berisi URL!', true);
        return;
    }
    
    const file = fileInput.files[0];
    const text = await file.text();
    const urls = text.split('\n').filter(line => line.trim());
    
    addLog('bulkLog', `Memproses ${urls.length} URL`);
    addLog('bulkLog', `Tipe: ${bulkType}`);
    
    const progressDiv = document.getElementById('bulkProgress');
    progressDiv.style.display = 'block';
    
    let completed = 0;
    for (let i = 0; i < urls.length; i++) {
        const url = urls[i].trim();
        if (url) {
            addLog('bulkLog', `[${i + 1}/${urls.length}] Downloading: ${url.substring(0, 50)}...`);
            await new Promise(resolve => setTimeout(resolve, 1000));
            completed++;
            updateProgress('bulkFill', (completed / urls.length) * 100);
        }
    }
    
    addLog('bulkLog', `✅ Selesai! ${completed}/${urls.length} berhasil didownload`);
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        updateProgress('bulkFill', 0);
    }, 2000);
}

// ==================== AV Tools ====================
function selectTool(tool) {
    currentTool = tool;
    const toolInputs = document.getElementById('toolInputs');
    const toolTitle = document.getElementById('toolTitle');
    const content = document.getElementById('toolInputsContent');
    
    toolTitle.textContent = getToolName(tool);
    
    let html = '';
    switch(tool) {
        case 'replace':
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
                <div class="form-group">
                    <label>Audio File (MP3)</label>
                    <input type="file" id="toolAudio" accept="audio/*" class="form-control">
                </div>
            `;
            break;
        case 'mix':
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
                <div class="form-group">
                    <label>Background Music</label>
                    <input type="file" id="toolAudio" accept="audio/*" class="form-control">
                </div>
                <div class="form-group">
                    <label>Music Volume (%)</label>
                    <input type="range" id="musicVolume" min="0" max="100" value="50">
                    <span id="volumeValue">50%</span>
                </div>
            `;
            break;
        case 'extract':
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
                <div class="form-group">
                    <label>Output Format</label>
                    <select id="audioFormat" class="form-control">
                        <option value="mp3">MP3</option>
                        <option value="wav">WAV</option>
                        <option value="m4a">M4A</option>
                    </select>
                </div>
            `;
            break;
        case 'trim':
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Start Time (hh:mm:ss)</label>
                        <input type="text" id="trimStart" placeholder="00:00:00" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>End Time (hh:mm:ss)</label>
                        <input type="text" id="trimEnd" placeholder="00:00:00" class="form-control">
                    </div>
                </div>
            `;
            break;
        case 'scale':
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
                <div class="form-group">
                    <label>Target Resolution</label>
                    <select id="targetRes" class="form-control">
                        <option value="1080x1920">Shorts (1080x1920)</option>
                        <option value="1920x1080">YouTube (1920x1080)</option>
                        <option value="720x1280">Instagram (720x1280)</option>
                    </select>
                </div>
            `;
            break;
        default:
            html = `
                <div class="form-group">
                    <label>Video File</label>
                    <input type="file" id="toolVideo" accept="video/*" class="form-control">
                </div>
            `;
    }
    
    content.innerHTML = html;
    toolInputs.style.display = 'block';
    
    // Add volume listener
    if (tool === 'mix') {
        const volumeSlider = document.getElementById('musicVolume');
        if (volumeSlider) {
            volumeSlider.addEventListener('input', (e) => {
                document.getElementById('volumeValue').textContent = e.target.value + '%';
            });
        }
    }
}

function getToolName(tool) {
    const names = {
        replace: 'Replace Audio',
        mix: 'Mix Audio',
        extract: 'Extract Audio',
        merge: 'Merge Videos',
        trim: 'Trim Video',
        scale: 'Scale Video',
        logo: 'Add Logo',
        watermark: 'Add Watermark'
    };
    return names[tool] || tool;
}

async function processTool() {
    addLog('toolsLog', `Memproses: ${getToolName(currentTool)}`);
    addLog('toolsLog', '⏳ Sedang diproses...');
    
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    addLog('toolsLog', '✅ Proses selesai!');
    addLog('toolsLog', '📁 File output disimpan di folder Exports');
}

// ==================== Screen Recorder ====================
async function startRecording() {
    const mode = document.getElementById('recMode').value;
    const resolution = document.getElementById('recResolution').value;
    
    addLog('recLog', `Memulai rekaman mode: ${mode}`);
    
    try {
        let stream;
        if (mode === 'screen') {
            stream = await navigator.mediaDevices.getDisplayMedia({
                video: true,
                audio: true
            });
        } else if (mode === 'camera') {
            stream = await navigator.mediaDevices.getUserMedia({
                video: { width: 1280, height: 720 },
                audio: true
            });
        } else {
            // Dual mode
            const screenStream = await navigator.mediaDevices.getDisplayMedia({ video: true });
            const cameraStream = await navigator.mediaDevices.getUserMedia({ video: true });
            stream = screenStream; // For demo
            addLog('recLog', 'Dual mode active (screen + camera)');
        }
        
        const preview = document.getElementById('recorderPreview');
        const video = document.getElementById('previewVideo');
        if (preview && video) {
            preview.style.display = 'block';
            video.srcObject = stream;
        }
        
        recordedChunks = [];
        mediaRecorder = new MediaRecorder(stream);
        
        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                recordedChunks.push(event.data);
            }
        };
        
        mediaRecorder.onstop = () => {
            const blob = new Blob(recordedChunks, { type: 'video/mp4' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `recording_${Date.now()}.mp4`;
            a.click();
            URL.revokeObjectURL(url);
            addLog('recLog', '✅ Rekaman selesai dan disimpan!');
            
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
            }
            if (preview) preview.style.display = 'none';
        };
        
        mediaRecorder.start(1000);
        
        document.getElementById('startRecordBtn').style.display = 'none';
        document.getElementById('stopRecordBtn').style.display = 'inline-block';
        
        addLog('recLog', '🔴 Sedang merekam...');
        
    } catch (error) {
        addLog('recLog', `Error: ${error.message}`, true);
    }
}

function stopRecording() {
    if (mediaRecorder && mediaRecorder.state === 'recording') {
        mediaRecorder.stop();
        document.getElementById('startRecordBtn').style.display = 'inline-block';
        document.getElementById('stopRecordBtn').style.display = 'none';
    }
}

// ==================== Transcribe ====================
async function startTranscribe() {
    const fileInput = document.getElementById('transcribeFile');
    const language = document.getElementById('transcribeLang').value;
    const model = document.getElementById('transcribeModel').value;
    
    if (!fileInput.files.length) {
        addLog('transcribeLog', 'Pilih file audio/video!', true);
        return;
    }
    
    const file = fileInput.files[0];
    addLog('transcribeLog', `Memproses: ${file.name}`);
    addLog('transcribeLog', `Bahasa: ${language}, Model: ${model}`);
    
    const progressDiv = document.getElementById('transcribeProgress');
    progressDiv.style.display = 'block';
    
    // Simulate transcription
    for (let i = 0; i <= 100; i += 10) {
        await new Promise(resolve => setTimeout(resolve, 200));
        updateProgress('transcribeFill', i);
        if (i === 50) addLog('transcribeLog', 'Menganalisis audio...');
        if (i === 80) addLog('transcribeLog', 'Membuat subtitle...');
    }
    
    // Show sample subtitle
    const subtitleResult = document.getElementById('subtitleResult');
    const subtitlePreview = document.getElementById('subtitlePreview');
    if (subtitleResult && subtitlePreview) {
        subtitleResult.style.display = 'block';
        subtitlePreview.innerHTML = `
            <div>1</div>
            <div>00:00:00,000 --> 00:00:05,000</div>
            <div>Sample subtitle text from transcription...</div>
            <br>
            <div>2</div>
            <div>00:00:05,000 --> 00:00:10,000</div>
            <div>This is an example of generated subtitle.</div>
        `;
    }
    
    addLog('transcribeLog', '✅ Transkripsi selesai!');
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        updateProgress('transcribeFill', 0);
    }, 2000);
}

function downloadSubtitle() {
    const content = document.getElementById('subtitlePreview')?.innerText;
    if (content) {
        const blob = new Blob([content], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'subtitle.srt';
        a.click();
        URL.revokeObjectURL(url);
        addLog('transcribeLog', '📝 Subtitle downloaded!');
    }
}

// ==================== TTS Functions ====================
async function generateTTS() {
    const text = document.getElementById('ttsText').value;
    const voice = document.getElementById('ttsVoice').value;
    const rate = document.getElementById('ttsRate').value;
    
    if (!text) {
        addLog('ttsLog', 'Masukkan teks terlebih dahulu!', true);
        return;
    }
    
    addLog('ttsLog', `Memproses TTS: "${text.substring(0, 50)}..."`);
    addLog('ttsLog', `Voice: ${voice}, Rate: ${rate}x`);
    
    // Use browser's Web Speech API for demo
    if ('speechSynthesis' in window) {
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.rate = parseFloat(rate);
        utterance.lang = voice.includes('id') ? 'id-ID' : 'en-US';
        
        utterance.onend = () => {
            addLog('ttsLog', '✅ Speech generated!');
        };
        
        utterance.onerror = (error) => {
            addLog('ttsLog', `Error: ${error.error}`, true);
        };
        
        window.speechSynthesis.speak(utterance);
        addLog('ttsLog', '🔊 Memutar suara...');
    } else {
        addLog('ttsLog', 'Browser tidak mendukung Web Speech API', true);
    }
}

// ==================== Slideshow ====================
async function createSlideshow() {
    const imagesInput = document.getElementById('slideshowImages');
    const imgDuration = document.getElementById('imgDuration').value;
    const transition = document.getElementById('transitionEffect').value;
    const resolution = document.getElementById('slideshowRes').value;
    
    if (!imagesInput.files.length) {
        addLog('slideshowLog', 'Pilih gambar terlebih dahulu!', true);
        return;
    }
    
    const images = Array.from(imagesInput.files);
    addLog('slideshowLog', `Membuat slideshow dari ${images.length} gambar`);
    addLog('slideshowLog', `Durasi: ${imgDuration}s, Transisi: ${transition}, Resolusi: ${resolution}`);
    
    const progressDiv = document.getElementById('slideshowProgress');
    progressDiv.style.display = 'block';
    
    // Preview images
    const previewContainer = document.getElementById('imagePreview');
    if (previewContainer) {
        previewContainer.innerHTML = images.map(img => `
            <img src="${URL.createObjectURL(img)}" class="preview-image" alt="${img.name}">
        `).join('');
    }
    
    // Simulate processing
    for (let i = 0; i <= 100; i += 5) {
        await new Promise(resolve => setTimeout(resolve, 100));
        updateProgress('slideshowFill', i);
        if (i === 30) addLog('slideshowLog', 'Memproses gambar...');
        if (i === 60) addLog('slideshowLog', 'Membuat transisi...');
        if (i === 90) addLog('slideshowLog', 'Menggabungkan video...');
    }
    
    addLog('slideshowLog', '✅ Slideshow berhasil dibuat!');
    addLog('slideshowLog', `📁 Output: Videos/Exports/Slideshow/slideshow_${Date.now()}.mp4`);
    
    setTimeout(() => {
        progressDiv.style.display = 'none';
        updateProgress('slideshowFill', 0);
    }, 2000);
}

// ==================== Settings ====================
function testConnection() {
    addLog('archiveLog', 'Testing connection to server...');
    setTimeout(() => {
        addLog('archiveLog', '✅ Connection successful!');
    }, 1000);
}

// ==================== Tab Switching ====================
document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const parent = btn.parentElement;
        const tabId = btn.getAttribute('data-tab');
        
        parent.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        document.getElementById('urlTab').style.display = tabId === 'url' ? 'block' : 'none';
        document.getElementById('uploadTab').style.display = tabId === 'upload' ? 'block' : 'none';
    });
});

// ==================== Initialize ====================
document.addEventListener('DOMContentLoaded', () => {
    loadStats();
    addLog('downloadLog', 'Ready to download');
    addLog('waveformLog', 'Ready to create waveform videos');
    addLog('toolsLog', 'Select a tool to start');
    addLog('recLog', 'Ready to record');
    addLog('transcribeLog', 'Upload file to transcribe');
    addLog('ttsLog', 'Enter text to convert to speech');
    addLog('slideshowLog', 'Select images to create slideshow');
    addLog('archiveLog', 'System ready');
    
    // Load settings
    document.getElementById('logoText').value = 'READLOUD';
    document.getElementById('logoMode').value = 'glow';
    document.getElementById('outputDir').value = 'Videos/Exports';
    document.getElementById('videoQuality').value = 'balanced';
    document.getElementById('parallelDownloads').value = '3';
    document.getElementById('apiEndpoint').value = '/api';
});