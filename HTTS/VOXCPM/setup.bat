@echo off
chcp 65001 > nul
title VoxCPM One-Click Setup & Launch Script

echo [1/4] Checking Python environment...

:: Check if Python is installed
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python not detected. Please install Python 3.10 or 3.11 and check "Add Python to PATH".
    pause
    exit /b
)

:: Create and enter project directory
if not exist "VoxCPM_Workspace" mkdir VoxCPM_Workspace
cd VoxCPM_Workspace

echo [2/4] Setting up virtual environment...
:: Create virtual environment (if it doesn't exist)
if not exist "venv" (
    python -m venv venv
)

:: Activate virtual environment
call venv\Scripts\activate.bat

:: Upgrade pip
python -m pip install --upgrade pip

echo [3/4] Installing dependencies and GPU support...
:: Uninstall CPU version of torch (if exists)
pip uninstall torch torchaudio -y

:: Install PyTorch for CUDA 11.8 (modify according to your CUDA version)
:: Visit https://pytorch.org for commands matching your CUDA version
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu118

:: Install VoxCPM main package
pip install voxcpm

:: Optional: install torchcodec for better audio compatibility
pip install torchcodec

echo [4/4] Launching Web UI...
echo Starting up, browser will open the Web interface automatically...
echo Note: First launch will download model files (~4-5GB), please be patient.

:: Launch Gradio interface
voxcpm --share

pause