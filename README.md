Here's the full revised README with your requested changes:

---

# Diambra Docker Image

This repository provides a Docker image and entrypoint script for training reinforcement learning models using [DIAMBRA Arena](https://github.com/diambra/arena), [Stable Baselines 3](https://github.com/DLR-RM/stable-baselines3), and PyTorch. The image includes support for CUDA-enabled GPUs, TensorBoard for real-time monitoring, and Docker-in-Docker (DinD) for containerized environments.

## Table of Contents

- [Diambra Docker Image](#diambra-docker-image)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Prerequisites and Preparing Directories](#prerequisites-and-preparing-directories)
    - [Directory Setup](#directory-setup)
    - [Option 1: Use Existing DIAMBRA Credentials](#option-1-use-existing-diambra-credentials)
    - [Option 2: Generate a DIAMBRA Credentials File via Docker](#option-2-generate-a-diambra-credentials-file-via-docker)
  - [Dockerfile Overview](#dockerfile-overview)
  - [Adding Custom Python Packages](#adding-custom-python-packages)
  - [Entrypoint Script](#entrypoint-script)
  - [⚠️ Warning](#️-warning)
  - [Usage](#usage)
    - [Pulling the Docker Image](#pulling-the-docker-image)
    - [Building the Docker Image Locally](#building-the-docker-image-locally)
    - [Running the Container](#running-the-container)
  - [Environment Variables](#environment-variables)
  - [Exposed Ports](#exposed-ports)
  - [Accessing TensorBoard](#accessing-tensorboard)
  - [License](#license)
  - [Contributing](#contributing)

## Features

- **Stable Baselines 3 Integration**: Fully integrated with DIAMBRA Arena for reinforcement learning tasks.
- **PyTorch 2.4.1 with CUDA 12.4**: GPU acceleration for efficient training.
- **DIAMBRA CLI**: Simplified environment setup and management.
- **TensorBoard**: Real-time monitoring of training metrics.
- **Docker-in-Docker (DinD)**: Allows for running Docker containers within the Docker environment.

## Prerequisites and Preparing Directories

Before running the container, you need to set up your directories and provide DIAMBRA credentials. You can either use an existing credentials file or generate a new one inside the Docker container.

### Directory Setup

You will need the following directories on your host machine, which will be mounted into the Docker container:

1. **ROMs Directory**: Contains your game ROMs.
   ```bash
   mkdir -p /path/to/roms
   ```
   
2. **Scripts Directory**: Contains your training scripts (e.g., `train.py`).
   ```bash
   mkdir -p /path/to/scripts
   ```

3. **DIAMBRA Credentials**: You can either copy an existing credentials file or generate one inside the container.
   ```bash
   mkdir -p /path/to/diambra
   ```

4. **Output Directory**: Stores trained models and logs.
   ```bash
   mkdir -p /path/to/output
   ```

### Option 1: Use Existing DIAMBRA Credentials

If you already have a DIAMBRA credentials file, follow these steps:

1. Copy your credentials file into the `diambra` directory on your host machine:
   ```bash
   cp /your/credentials/file /path/to/diambra/credentials
   ```

2. When running the container, mount the credentials file by adding the `-v /path/to/diambra:/workspace/diambra` option to your Docker command.

### Option 2: Generate a DIAMBRA Credentials File via Docker

If you don’t have a credentials file, the container will enter **Setup Mode** when it doesn’t detect the file. Follow these steps inside the container to generate the credentials:

1. Start the container (If you haven't already):
   ```bash
   docker run --privileged -v /path/to/diambra:/workspace/diambra -it mscrnt/diambra-trainer:latest
   ```

2. Inside the container, start the Docker daemon:
   ```bash
   sudo dockerd > /dev/null 2>&1 &
   ```

3. Generate the credentials file using the DIAMBRA CLI:
   ```bash
   diambra run -n --path.credentials "/workspace/diambra/credentials"
   ```

4. Once the credentials file is generated, you can either run the training script manually or restart the container with the saved credentials.

## Dockerfile Overview

The provided `Dockerfile` sets up a comprehensive environment for training reinforcement learning models:

- **Base Image**: Starts from `pytorch/pytorch:2.4.1-cuda12.4-cudnn9-runtime` to leverage PyTorch with CUDA support.
- **System Dependencies**: Installs necessary packages including Docker, Python, and system libraries.
- **User Setup**: Creates a non-root user `diambra` with sudo privileges and adds it to the Docker group.
- **Python Environment**: Sets up a Python virtual environment and installs DIAMBRA packages and dependencies.
- **Workspace Configuration**: Creates and configures the `/workspace` directory for code, data, and logs.
- **Environment Variables**: Sets up default environment variables for customization.
- **Entrypoint**: Uses `entrypoint.sh` to start services and execute the training script.

## Adding Custom Python Packages

If you want to add custom `pip` packages to the Docker image, you can modify the Dockerfile under the section labeled `# Install other necessary packages`. Simply add the desired packages in a new `RUN pip install` command.

For example, to add `numpy` and `pandas`, modify the Dockerfile like this:

```Dockerfile
# Install other necessary packages
RUN pip install tensorboard && \
    pip install opencv-python && \
    pip install colorama && \
    pip install numpy pandas  # Add your custom pip packages here
```

This allows you to customize the Docker image with any additional Python dependencies you need.

## Entrypoint Script

The `entrypoint.sh` script orchestrates the startup sequence:

- **Docker Daemon**: Initializes the Docker daemon for DinD functionality.
- **TensorBoard**: Launches TensorBoard to monitor training progress.
- **Training Script**: Executes the user-provided training script using `diambra run`.
- **Setup Mode**: If the credentials file is missing, the container enters Setup Mode for generating the DIAMBRA credentials manually.

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

- **`SCALE`**: Adjust to change the number of parallel environments (default: `1`).
  ```bash
  -e SCALE=4
  ```
- **`EXTRA_ARGS`**: Pass additional arguments to your training script (default: `""`).
  ```bash
  -e EXTRA_ARGS="--learning-rate 0.0001 --batch-size 64"
  ```
- **`TRAINING_SCRIPT`**: Specify a custom path for the training script (default: `/workspace/scripts/train.py`).
  ```bash
  -e TRAINING_SCRIPT="/path/to/your_training_script.py"
  ```
- **`AUTO`**: Automatically run the training script on startup (default: `true`).
  ```bash
  -e AUTO="true"
  ```
- **`STOP_AFTER_RUN`**: Stop the container after the training script completes (default: `false`).
  ```bash
  -e STOP_AFTER_RUN="true"
  ```
- **`DIAMBRAROMSPATH`**: Path to the directory containing game ROMs (default: `/workspace/roms`).  
  **Note**: It is recommended not to change this unless you are familiar with how DIAMBRA Arena manages ROMs.

## Exposed Ports

- **`6006`**: TensorBoard web interface.

## Accessing TensorBoard

After starting the container, access TensorBoard by navigating to:

```
http://localhost:7007
```

Monitor your training progress with real-time visualizations of metrics like loss and reward.

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or suggestions.
