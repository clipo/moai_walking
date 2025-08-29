# Use official Python runtime as base image
FROM python:3.10.13-slim

# Set working directory in container
WORKDIR /app

# Install system dependencies required by some Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libgeos-dev \
    libspatialindex-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python scripts
COPY *.py ./

# Create figures directory for output
RUN mkdir -p ../figures

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV MPLBACKEND=Agg

# Default command runs the final analysis
CMD ["python", "moai_analyzer_final.py"]