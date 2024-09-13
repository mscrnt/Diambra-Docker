#!/bin/bash

# Start Docker daemon in the background
sudo dockerd > /dev/null 2>&1 &

sleep 5

echo "Docker started successfully."

# Start tensorboard in the background
tensorboard --logdir /workspace/logs --bind_all > /dev/null 2>&1 &


# Run the diambra run command in the background
exec diambra run -s=${DIAMBRA_SCALE} --path.credentials ${DIAMBRA_CREDENTIALS_FILE} \
    python /workspace/scripts/train.py ${EXTRA_ARGS}

