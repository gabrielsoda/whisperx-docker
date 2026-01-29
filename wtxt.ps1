# wtxt.ps1 - WhisperX transcription wrapper for Docker (PowerShell)
# Usage: wtxt <audio_file> [additional whisperx options]
#
# Examples:
#   wtxt audio.mp3
#   wtxt video.mp4 --language en
#   wtxt podcast.wav --model medium --output_format srt

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$AudioFile,

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ExtraArgs
)

# Configuration - edit these defaults as needed
$DEFAULT_MODEL = "large-v3"
$DEFAULT_LANGUAGE = "es"
$DEFAULT_FORMAT = "txt"
$USE_GPU = $env:WHISPERX_GPU -eq "true"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if Docker is running
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running" -ForegroundColor Red
    exit 1
}

# Show help if no arguments
if (-not $AudioFile) {
    Write-Host "Usage: wtxt <audio_file> [whisperx options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  wtxt audio.mp3"
    Write-Host "  wtxt video.mp4 --language en"
    Write-Host "  wtxt podcast.wav --model medium"
    Write-Host ""
    Write-Host "Environment variables:"
    Write-Host "  `$env:WHISPERX_GPU='true'    Use GPU acceleration"
    Write-Host ""
    Write-Host "Defaults: --model $DEFAULT_MODEL --language $DEFAULT_LANGUAGE --output_format $DEFAULT_FORMAT"
    exit 0
}

# Check if file exists
if (-not (Test-Path $AudioFile)) {
    Write-Host "Error: File not found: $AudioFile" -ForegroundColor Red
    exit 1
}

# Get absolute path
$InputPath = Resolve-Path $AudioFile
$InputDir = Split-Path -Parent $InputPath
$InputName = Split-Path -Leaf $InputPath

# Select service
if ($USE_GPU) {
    $Service = "whisperx-gpu"
    Write-Host "Using GPU acceleration" -ForegroundColor Green
} else {
    $Service = "whisperx"
    Write-Host "Using CPU" -ForegroundColor Green
}

# Build arguments
$Args = @()
$ArgsString = $ExtraArgs -join " "

if ($ArgsString -notmatch "--model") {
    $Args += "--model"
    $Args += $DEFAULT_MODEL
}

if ($ArgsString -notmatch "--language") {
    $Args += "--language"
    $Args += $DEFAULT_LANGUAGE
}

if ($ArgsString -notmatch "--output_format") {
    $Args += "--output_format"
    $Args += $DEFAULT_FORMAT
}

$Args += $ExtraArgs

Write-Host "Transcribing: $InputName" -ForegroundColor Green
Write-Host "Options: $($Args -join ' ')"
Write-Host ""

# Convert Windows path to Docker-compatible path
$DockerInputDir = $InputDir -replace '\\', '/' -replace '^([A-Za-z]):', '/$1'
$DockerInputDir = $DockerInputDir.ToLower()

# Run whisperx in Docker
$dockerArgs = @(
    "compose", "-f", "$SCRIPT_DIR\docker-compose.yml",
    "run", "--rm",
    "-v", "${InputDir}:/app/input",
    "-w", "/app/input",
    $Service,
    $InputName
) + $Args

& docker @dockerArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Transcription complete!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Transcription failed!" -ForegroundColor Red
}
