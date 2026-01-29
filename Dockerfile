# WhisperX CLI - CPU Version
# Based on working whisperx-env configuration

FROM python:3.12

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    libgomp1 \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies matching whisperx-env
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    torch==2.5.1 \
    torchaudio==2.5.1 \
    --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir \
    whisperx==3.4.3

# Create directories for cache and output
RUN mkdir -p /root/.cache/huggingface /app/output /app/input

# Set working directory for transcriptions
WORKDIR /app/input

# Default entrypoint
ENTRYPOINT ["whisperx"]

# Default help command
CMD ["--help"]
