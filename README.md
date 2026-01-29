# WhisperX Docker

Containerized [WhisperX](https://github.com/m-bain/whisperX) for portable audio/video transcription. Works on Windows, Linux, macOS, and WSL.

## Features

- CPU and NVIDIA GPU support
- Persistent model cache (download once, use forever)
- Simple wrapper scripts for easy usage
- Works identically across all operating systems

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- For GPU: [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/whisperx-docker.git
cd whisperx-docker
```

### 2. Build the image

```bash
# CPU version
docker compose build whisperx

# GPU version
docker compose build whisperx-gpu
```

### 3. Transcribe

```bash
# Using docker compose directly
docker compose run --rm whisperx your_audio.mp3 --model large-v3 --language es --output_format txt

# Using the wrapper script (Linux/WSL/macOS)
./wtxt your_audio.mp3

# Using the wrapper script (PowerShell)
.\wtxt.ps1 your_audio.mp3
```

## Usage

### Direct Docker Compose

```bash
# Basic transcription (CPU)
docker compose run --rm whisperx audio.mp3 --model large-v3 --language es --output_format txt

# GPU transcription
docker compose run --rm whisperx-gpu audio.mp3 --model large-v3 --language es --output_format txt

# Multiple output formats
docker compose run --rm whisperx audio.mp3 --model large-v3 --language es --output_format all

# Different model sizes
docker compose run --rm whisperx audio.mp3 --model tiny     # Fastest, less accurate
docker compose run --rm whisperx audio.mp3 --model base
docker compose run --rm whisperx audio.mp3 --model small
docker compose run --rm whisperx audio.mp3 --model medium
docker compose run --rm whisperx audio.mp3 --model large-v3  # Slowest, most accurate
```

### Wrapper Scripts

The wrapper scripts provide sensible defaults and easier syntax.

#### Linux / WSL / macOS

```bash
# Make executable (first time only)
chmod +x wtxt

# Basic usage (uses defaults: large-v3, Spanish, txt)
./wtxt audio.mp3

# Override options
./wtxt audio.mp3 --language en
./wtxt audio.mp3 --model medium --output_format srt

# Use GPU
WHISPERX_GPU=true ./wtxt audio.mp3
```

#### PowerShell (Windows)

```powershell
# Basic usage
.\wtxt.ps1 audio.mp3

# Override options
.\wtxt.ps1 audio.mp3 --language en
.\wtxt.ps1 audio.mp3 --model medium --output_format srt

# Use GPU
$env:WHISPERX_GPU="true"; .\wtxt.ps1 audio.mp3
```

### Adding to PATH

#### Linux / WSL / macOS

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$PATH:/path/to/whisperx-docker"
```

Or create an alias:

```bash
alias wtxt='/path/to/whisperx-docker/wtxt'
```

#### PowerShell

Add to your PowerShell profile (`code $PROFILE`):

```powershell
function wtxt {
    & "C:\path\to\whisperx-docker\wtxt.ps1" @args
}
```

## Configuration

### Default Settings

Edit the wrapper scripts to change defaults:

| Setting | Default | Description |
|---------|---------|-------------|
| `DEFAULT_MODEL` | `large-v3` | Whisper model size |
| `DEFAULT_LANGUAGE` | `es` | Target language |
| `DEFAULT_FORMAT` | `txt` | Output format |

### Available Models

| Model | Speed | Accuracy | VRAM (GPU) | RAM (CPU) |
|-------|-------|----------|------------|-----------|
| tiny | Fastest | Low | ~1 GB | ~2 GB |
| base | Fast | Medium | ~1 GB | ~2 GB |
| small | Medium | Good | ~2 GB | ~4 GB |
| medium | Slow | Better | ~5 GB | ~8 GB |
| large-v3 | Slowest | Best | ~10 GB | ~16 GB |

### Supported Languages

English (en), Spanish (es), French (fr), German (de), Italian (it), Portuguese (pt), Dutch (nl), Russian (ru), Chinese (zh), Japanese (ja), Korean (ko), Arabic (ar), Hindi (hi), and many more.

### Output Formats

- `txt` - Plain text
- `srt` - SubRip subtitles
- `vtt` - WebVTT subtitles
- `json` - JSON with timestamps
- `tsv` - Tab-separated values
- `all` - All formats

## Volume Management

Models are cached in a Docker volume to avoid re-downloading:

```bash
# View cache size
docker volume inspect whisperx-model-cache

# Clear cache (forces re-download)
docker volume rm whisperx-model-cache
```

## GPU Setup

### Windows (Docker Desktop)

1. Install latest NVIDIA drivers
2. Enable WSL2 backend in Docker Desktop
3. GPU passthrough works automatically

### WSL2

```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Linux

```bash
# Install NVIDIA Container Toolkit (Ubuntu/Debian)
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

## Troubleshooting

### "Docker is not running"

Start Docker Desktop or the Docker daemon:

```bash
# Linux
sudo systemctl start docker

# WSL2 (if using systemd)
sudo service docker start
```

### GPU not detected

```bash
# Check NVIDIA driver
nvidia-smi

# Check Docker GPU access
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Out of memory

Use a smaller model:

```bash
./wtxt audio.mp3 --model small
```

### Permission denied (Linux)

```bash
chmod +x wtxt
```

## License

MIT License - See [LICENSE](LICENSE) for details.

## Credits

- [WhisperX](https://github.com/m-bain/whisperX) by Max Bain
- [Faster Whisper](https://github.com/guillaumekln/faster-whisper) by Guillaume Klein
- [OpenAI Whisper](https://github.com/openai/whisper) by OpenAI
