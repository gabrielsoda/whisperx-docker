# WhisperX Docker

Containerized [WhisperX](https://github.com/m-bain/whisperX) for portable audio/video transcription. Works on Windows, Linux, macOS, and WSL.

## Features

- CPU and NVIDIA GPU support
- Persistent model cache (download once, use forever)
- Simple wrapper scripts for easy usage
- OpenAI Whisper fallback for WSL2 compatibility
- Works identically across all operating systems

## Available Services

| Service | Engine | WSL2 | Windows | Linux | Use Case |
|---------|--------|------|---------|-------|----------|
| `whisperx` | WhisperX + faster-whisper | ❌ | ✅ | ✅ | Fast transcription with word alignment |
| `whisperx-gpu` | WhisperX + CUDA | ❌ | ✅ | ✅ | GPU-accelerated transcription |
| `whisper` | OpenAI Whisper | ✅ | ✅ | ✅ | WSL2-compatible fallback |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed and running
- For GPU: [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/gabrielsoda/whisperx-docker.git
cd whisperx-docker
```

### 2. Build the image

```bash
# CPU version (Windows/Linux)
docker compose build whisperx

# GPU version (Windows/Linux with NVIDIA)
docker compose build whisperx-gpu

# WSL2 compatible version (see Known Issues section)
docker compose build whisper
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

### WSL2 Users (Important!)

If you're running Docker inside WSL2, use the `whisper` service instead of `whisperx`:

```bash
# WSL2: Use 'whisper' service
docker compose run --rm -v "$(pwd):/app/input" whisper \
  audio.mp3 --model medium --language es --output_format txt
```

See [Known Issues](#known-issues--development-notes) for details.

### Direct Docker Compose

```bash
# Basic transcription (CPU) - Windows/Linux native
docker compose run --rm whisperx audio.mp3 --model large-v3 --language es --output_format txt

# GPU transcription - Windows/Linux native
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
| large-v2 | Slower | Great | ~10 GB | ~16 GB |
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

## Known Issues & Development Notes

### WSL2 Compatibility (ctranslate2)

**Problem:** WhisperX uses [faster-whisper](https://github.com/guillaumekln/faster-whisper) which depends on [ctranslate2](https://github.com/OpenNMT/CTranslate2). The ctranslate2 library requires executable stack memory, which is blocked by the WSL2 kernel's security configuration.

**Error message:**
```
ImportError: libctranslate2-d3638643.so.4.4.0: cannot enable executable stack as shared object requires: Invalid argument
```

**What we tried:**
- Different ctranslate2 versions (4.4.0, 4.3.1, 3.24.0) - Same error
- Docker security options (`--security-opt seccomp=unconfined`) - No effect
- Privileged mode (`--privileged`) - No effect
- Different base images (python:3.10-slim, python:3.10, python:3.12) - Same error

**Root cause:** This is a kernel-level restriction in WSL2 that cannot be bypassed through Docker configuration. The WSL2 kernel blocks `execstack` operations for security reasons.

**Solution:** We added an OpenAI Whisper fallback service (`whisper`) that uses PyTorch directly without ctranslate2. This service works on WSL2 but is slower and lacks some WhisperX features.

### Feature Comparison

| Feature | whisperx | whisper (fallback) |
|---------|----------|-------------------|
| Transcription | ✅ | ✅ |
| Word-level timestamps | ✅ | ❌ |
| Speaker diarization | ✅ | ❌ |
| Speed (CPU) | Fast | Slower |
| WSL2 Docker support | ❌ | ✅ |
| Windows/Linux Docker | ✅ | ✅ |

### NumPy 2.x Compatibility

**Problem:** PyTorch 2.2.0 wheels were compiled with NumPy 1.x and crash with NumPy 2.x.

**Error message:**
```
A module that was compiled using NumPy 1.x cannot be run in NumPy 2.x
```

**Solution:** For older PyTorch versions, pin `numpy<2` in requirements. With PyTorch 2.5.1+, NumPy 2.x is supported.

### Package Index Conflicts

**Problem:** Installing whisperx with PyTorch from the PyTorch index fails because whisperx is only on PyPI.

**Error message:**
```
ERROR: Could not find a version that satisfies the requirement whisperx==3.3.0
```

**Solution:** Split pip install into two commands:
1. Install PyTorch from PyTorch index (`--index-url https://download.pytorch.org/whl/cpu`)
2. Install whisperx from PyPI (default index)

### Environment Reference

This Docker setup was based on a working local environment:
- Python 3.12.11
- whisperx 3.4.3
- faster-whisper 1.2.0
- ctranslate2 4.4.0
- torch 2.8.0+cu126
- numpy 2.1.2

## License

MIT License - See [LICENSE](LICENSE) for details.

## Credits

- [WhisperX](https://github.com/m-bain/whisperX) by Max Bain
- [Faster Whisper](https://github.com/guillaumekln/faster-whisper) by Guillaume Klein
- [OpenAI Whisper](https://github.com/openai/whisper) by OpenAI
