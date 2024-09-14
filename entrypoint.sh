#!/bin/bash

HASHED_CREDS="/workspace/diambra/credentials"

# If the TRAINING_SCRIPT environment variable is set, change the path to /workspace/scripts/
# Otherwise, default to /workspace/scripts/train.py
TRAINING_SCRIPT_BASE=$(basename "${TRAINING_SCRIPT:-train.py}")
TRAINING_SCRIPT="/workspace/scripts/${TRAINING_SCRIPT_BASE}"

# Check if hashed credentials file exists and is non-empty
if [ ! -s "$HASHED_CREDS" ]; then
    echo "Saved credentials not found or empty."
    echo 'Run the Docker container with this command to generate the hashed credentials file:'
    echo 'docker run --privileged -v /PATH/TO/SAVE/CREDENTIALS:/workspace/diambra -it --entrypoint /bin/bash diambra-trainer'
    echo 'Replace /PATH/TO/SAVE/CREDENTIALS with the path to the folder to save the credentials file.'
    echo ''
    echo 'Once inside the container, start the Docker daemon by running the following command:'
    echo 'sudo dockerd > /dev/null 2>&1 &'
    echo ''
    echo 'Then, run this command to generate the hashed credentials file:'
    echo 'diambra run -n --path.credentials "/workspace/diambra/credentials"'
    
    exit 1
fi

# Check if the TRAINING_SCRIPT exists in /workspace/scripts/
if [ ! -s "${TRAINING_SCRIPT}" ]; then
    echo "${TRAINING_SCRIPT} not found. Please mount the training script to /workspace/scripts/."
    exit 1
fi

# Start Docker daemon in the background
echo "Starting Docker Daemon"
sudo dockerd > /dev/null 2>&1 &

sleep 5

echo "Starting Tensorboard"

# Start tensorboard in the background
tensorboard --logdir /workspace/output/logs --bind_all > /dev/null 2>&1 &

echo "Running Diambra Script"

# Run the diambra run command in the background
exec diambra run -s=${SCALE} --path.credentials $HASHED_CREDS \
    python ${TRAINING_SCRIPT} ${EXTRA_ARGS}

echo "Diambra Script Finished. Keeping the container running"

# Keep the container running and provide an interactive shell
exec /bin/bash
