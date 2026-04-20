import soundfile as sf
from voxcpm import VoxCPM

# Load model (auto-downloads on first run)
model = VoxCPM.from_pretrained("openbmb/VoxCPM-0.5B")

# Synthesize speech
wav = model.generate(
    text="Hello, welcome to the VoxCPM text-to-speech system.",
    prompt_wav_path=None,      # Voice cloning path — None uses random voice
    cfg_value=2.0,             # Higher values = more similar to prompt voice
    inference_timesteps=10     # Higher steps = better quality, slower speed
)

# Save file
sf.write("output.wav", wav, 16000)
print("Speech generated and saved as output.wav")