# Start with the PyTorch base image that includes CUDA and cuDNN support
FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-runtime

# Set environment variable for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies, including Docker, and set up DinD for rootless Docker
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    sudo && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies for Python, if necessary (virtualenv, pip)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user called 'diambra' and give it sudo access
RUN useradd -ms /bin/bash diambra && \
    usermod -aG sudo diambra && \
    echo "diambra ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the entrypoint.sh script into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create docker group if it doesn't exist, and add 'diambra' user to docker group
RUN groupadd docker || true && \
    usermod -aG docker diambra

# Create the /opt/venv directory and set appropriate permissions for the diambra user
RUN mkdir -p /opt/venv && chown diambra:diambra /opt/venv

# Create necessary directories for /workspace as root and set permissions
RUN mkdir -p /workspace && chown diambra:diambra /workspace

# Switch to the 'diambra' user
USER diambra

# Set DOCKER_HOST for non-root user
RUN echo 'export DOCKER_HOST=unix:///var/run/docker.sock' >> /home/diambra/.bashrc

# Create and activate a virtual environment using the built-in venv module
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install DIAMBRA CLI and Arena packages in the virtual environment
RUN pip install diambra && \
    pip install diambra-arena

# Install Stable Baselines 3 support for Diambra Arena
RUN pip install diambra-arena[stable-baselines3]

# Install other necessary packages
RUN pip install tensorboard && \
    pip install opencv-python && \
    pip install colorama

# Create necessary directories under /workspace as diambra
RUN mkdir -p /workspace/diambra && \
    mkdir -p /workspace/roms && \
    chmod 777 /workspace/roms && \
    chmod 777 /workspace/diambra

# Set environment variables
ENV SCALE=1
ENV EXTRA_ARGS=""
ENV TRAINING_SCRIPT="/workspace/scripts/train.py"
ENV DIAMBRAROMSPATH="/workspace/roms"


# Set up a working directory for code
WORKDIR /workspace

# Expose the port for tensorboard
EXPOSE 6006

# Use the entrypoint.sh script to start dockerd and run diambra
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
