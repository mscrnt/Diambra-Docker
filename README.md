# Diambra Trainer Docker Image

This repository provides a Docker image and entrypoint script for training reinforcement learning models using [DIAMBRA Arena](https://github.com/diambra/arena), [Stable Baselines 3](https://github.com/DLR-RM/stable-baselines3), and PyTorch. The image includes support for CUDA-enabled GPUs, TensorBoard for real-time monitoring, and Docker-in-Docker (DinD) for containerized environments.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
  - [Option 1: Use Existing DIAMBRA Credentials](#option-1-use-existing-diambra-credentials)
  - [Option 2: Generate a DIAMBRA Credentials File via Docker](#option-2-generate-a-diambra-credentials-file-via-docker)
- [Dockerfile Overview](#dockerfile-overview)
- [Entrypoint Script](#entrypoint-script)
- [⚠️ Warning](#️-warning)
- [Usage](#usage)
  - [Pulling the Docker Image](#pulling-the-docker-image)
  - [Building the Docker Image Locally](#building-the-docker-image-locally)
  - [Preparing Directories](#preparing-directories)
  - [Running the Container](#running-the-container)
- [Environment Variables](#environment-variables)
- [Exposed Ports](#exposed-ports)
- [Accessing TensorBoard](#accessing-tensorboard)
- [Customization](#customization)
- [License](#license)
- [Contributing](#contributing)

## Features

- **Stable Baselines 3 Integration**: Fully integrated with DIAMBRA Arena for reinforcement learning tasks.
- **PyTorch 2.4.1 with CUDA 12.4**: GPU acceleration for efficient training.
- **DIAMBRA CLI**: Simplified environment setup and management.
- **TensorBoard**: Real-time monitoring of training metrics.
- **Docker-in-Docker (DinD)**: Allows for running Docker containers within the Docker environment.

## Prerequisites

Before running the container, ensure you have the following options:

### Option 1: Use Existing DIAMBRA Credentials

- **DIAMBRA Credentials**: Place your credentials file in the `/path/to/diambra` directory on your host machine. This is required for authentication with DIAMBRA Arena.

    ```bash
    mkdir -p /path/to/diambra
    cp /your/credentials/file /path/to/diambra/credentials
    ```

### Option 2: Generate a DIAMBRA Credentials File via Docker

If you don't have a credentials file, follow these steps to generate one using the Docker container:

1. Run the following Docker command to start the container in interactive mode:

    ```bash
    docker run --privileged -v /PATH/TO/SAVE/CREDENTIALS:/workspace/diambra -it --entrypoint /bin/bash diambra-trainer
    ```

2. Once inside the container, start the Docker daemon:

    ```bash
    sudo dockerd > /dev/null 2>&1 &
    ```

3. Generate the credentials file using the `diambra` CLI:

    ```bash
    diambra run --path.credentials "/workspace/diambra/credentials"
    ```

4. Exit the container, and the credentials file will be saved in the `/workspace/diambra` directory you mounted.

## Dockerfile Overview

The provided `Dockerfile` sets up a comprehensive environment for training reinforcement learning models:

- **Base Image**: Starts from `pytorch/pytorch:2.4.1-cuda12.4-cudnn9-runtime` to leverage PyTorch with CUDA support.
- **System Dependencies**: Installs necessary packages including Docker, Python, and system libraries.
- **User Setup**: Creates a non-root user `diambra` with sudo privileges and adds it to the Docker group.
- **Python Environment**: Sets up a Python virtual environment and installs DIAMBRA packages and dependencies.
- **Workspace Configuration**: Creates and configures the `/workspace` directory for code, data, and logs.
- **Environment Variables**: Sets up default environment variables for customization.
- **Entrypoint**: Uses `entrypoint.sh` to start services and execute the training script.

## Entrypoint Script

The `entrypoint.sh` script orchestrates the startup sequence:

- **Docker Daemon**: Initializes the Docker daemon for DinD functionality.
- **TensorBoard**: Launches TensorBoard to monitor training progress.
- **Training Script**: Executes the user-provided training script using `diambra run`.

## ⚠️ Warning

> **Do not place untrusted code in the mounted `scripts` folder.**
>
> The container runs with privileged access, which could pose a security risk if untrusted scripts are executed.

## Usage

### Pulling the Docker Image

You can pull the pre-built image from Docker Hub:

```bash
docker pull mscrnt/diambra-trainer:latest
```

### Building the Docker Image Locally

Alternatively, if you want to build the Docker image yourself, clone this repository and run the following command:

```bash
docker build -t diambra-trainer .
```

### Preparing Directories

Create the following directories on your host machine to be mounted into the Docker container:

- **ROMs Directory**: Contains your game ROMs.
  ```bash
  mkdir -p /path/to/roms
  ```
- **Scripts Directory**: Contains your training scripts (e.g., `train.py`).
  ```bash
  mkdir -p /path/to/scripts
  ```
- **DIAMBRA Credentials**: Copy your DIAMBRA credentials file to the appropriate directory.
  ```bash
  mkdir -p /path/to/diambra
  cp /your/credentials/file /path/to/diambra/credentials
  ```
- **Output Directory**: Stores trained models and logs.
  ```bash
  mkdir -p /path/to/output
  ```

### Running the Container

Use the following command to run the Docker container:

```bash
docker run --privileged \
  -v /path/to/roms:/workspace/roms \
  -v /path/to/scripts:/workspace/scripts \
  -v /path/to/diambra:/workspace/diambra \
  -v /path/to/output:/workspace/output \
  -e SCALE=2 \
  -e EXTRA_ARGS="--batch-size 64" \
  -e TRAINING_SCRIPT="/path/to/your_training_script.py" \
  -p 7007:6006 \
  --name diambra-trainer \
  -it mscrnt/diambra-trainer:latest
```

- **`--privileged`**: Required for DinD to function properly.
- **Volume Mounts (`-v`)**: Mounts your host directories into the container.
- **Environment Variables (`-e`)**: Sets the number of DIAMBRA environments, additional arguments, and specifies the training script.
- **Port Mapping (`-p`)**: Exposes TensorBoard on port `6006` and maps it to `7007` on the host.

## Environment Variables

- **`SCALE`**: Number of DIAMBRA environments to run (default: `1`).
- **`EXTRA_ARGS`**: Additional arguments passed to your training script.
- **`TRAINING_SCRIPT`**: Specify a custom path for the training script (default: `/workspace/scripts/train.py`).

## Exposed Ports

- **`6006`**: TensorBoard web interface.

## Accessing TensorBoard

After starting the container, access TensorBoard by navigating to:

```
http://localhost:7007
```

Monitor your training progress with real-time visualizations of metrics like loss and reward.

## Customization

- **Training Script Arguments**: Use the `EXTRA_ARGS` environment variable to pass additional arguments to your training script.
  ```bash
  -e EXTRA_ARGS="--learning-rate 0.0001 --batch-size 64"
  ```
- **Scaling Environments**: Adjust `SCALE` to change the number of parallel environments.
  ```bash
  -e SCALE=4
  ```

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or suggestions.
