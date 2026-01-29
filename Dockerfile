# WhisperX CLI - CPU Version
# Multi-stage build for smaller image

FROM python:3.10-slim AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    whisperx==3.3.0 \
    faster-whisper==1.1.0 \
    torch==2.2.0 \
    torchaudio==2.2.0 \
    --index-url https://download.pytorch.org/whl/cpu

# Create directories for cache and output
RUN mkdir -p /root/.cache/huggingface /app/output /app/input

# Set working directory for transcriptions
WORKDIR /app/input

# Default entrypoint
ENTRYPOINT ["whisperx"]

# Default help command
CMD ["--help"]
