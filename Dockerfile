# Base image with Python 3.11
FROM python:3.11-slim

# Install required tools: curl, gnupg, apt-transport-https for gcloud
USER root
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    openjdk-11-jre \
    git

# Add gcloud repo and install the CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
      > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
 && apt-get update \
 && apt-get install -y google-cloud-sdk

# Create Jenkins user (to match jenkins/inbound-agent behavior)
RUN useradd -m -s /bin/bash jenkins
USER jenkins

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Set default command
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app"]
