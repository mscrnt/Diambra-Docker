# Diambra Trainer Docker Image

This repository provides a Docker image and entrypoint script for training reinforcement learning models using [DIAMBRA Arena](https://github.com/diambra/arena), [Stable Baselines 3](https://github.com/DLR-RM/stable-baselines3), and PyTorch. The image includes support for CUDA-enabled GPUs, TensorBoard for real-time monitoring, and Docker-in-Docker (DinD) for containerized environments.

## Table of Contents

- [Features](#features)
- [Dockerfile Overview](#dockerfile-overview)
- [Entrypoint Script](#entrypoint-script)
- [Usage](#usage)
  - [Building the Docker Image](#building-the-docker-image)
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

## Usage

### Building the Docker Image

Clone this repository and build the Docker image:

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
- **DIAMBRA Credentials**: Contains your DIAMBRA credentials file.
  ```bash
  mkdir -p /path/to/diambra
  touch /path/to/diambra/credentials
  ```
- **Output Directory**: Stores trained models and logs.
  ```bash
  mkdir -p /path/to/output
  ```
- **Logs Directory**: Stores TensorBoard logs.
  ```bash
  mkdir -p /path/to/logs
  ```

### Running the Container

Use the following command to run the Docker container:

```bash
docker run --privileged \
  -v /path/to/roms:/workspace/roms \
  -v /path/to/scripts:/workspace/scripts \
  -v /path/to/diambra:/workspace/diambra \
  -v /path/to/output:/workspace/output \
  -v /path/to/logs:/workspace/logs \
  -e DIAMBRA_SCALE=2 \
  -p 6006:6006 \
  --name diambra-trainer \
  -it diambra-trainer
```

- **`--privileged`**: Required for DinD to function properly.
- **Volume Mounts (`-v`)**: Mounts your host directories into the container.
- **Environment Variables (`-e`)**: Sets the number of DIAMBRA environments.
- **Port Mapping (`-p`)**: Exposes TensorBoard on port `6006`.

## Environment Variables

- **`DIAMBRA_SCALE`**: Number of DIAMBRA environments to run (default: `1`).
- **`EXTRA_ARGS`**: Additional arguments passed to your training script.
- **`DIAMBRA_CREDENTIALS_PATH`**: Path to DIAMBRA credentials (default: `/workspace/diambra`).
- **`DIAMBRA_CREDENTIALS_FILE`**: Credentials file path (default: `/workspace/diambra/credentials`).

## Exposed Ports

- **`6006`**: TensorBoard web interface.

## Accessing TensorBoard

After starting the container, access TensorBoard by navigating to:

```
http://localhost:6006
```

Monitor your training progress with real-time visualizations of metrics like loss and reward.

## Customization

- **Training Script Arguments**: Use the `EXTRA_ARGS` environment variable to pass additional arguments to your `train.py` script.
  ```bash
  -e EXTRA_ARGS="--learning-rate 0.0001 --batch-size 64"
  ```
- **Scaling Environments**: Adjust `DIAMBRA_SCALE` to change the number of parallel environments.
  ```bash
  -e DIAMBRA_SCALE=4
  ```

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or suggestions.

