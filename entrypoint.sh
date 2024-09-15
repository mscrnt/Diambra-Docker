#!/bin/bash

HASHED_CREDS="/workspace/diambra/credentials"

# If the TRAINING_SCRIPT environment variable is set, change the path to /workspace/scripts/
# Otherwise, default to /workspace/scripts/train.py
TRAINING_SCRIPT_BASE=$(basename "${TRAINING_SCRIPT:-train.py}")
TRAINING_SCRIPT="/workspace/scripts/${TRAINING_SCRIPT_BASE}"

# Check if hashed credentials file exists and is non-empty
if [ ! -s "$HASHED_CREDS" ]; then
    echo "Saved credentials not found or empty."
    echo 'Running container in Setup Mode:'
    echo ''
    echo 'Please run the following commands to start the Docker daemon:'
    echo 'sudo dockerd > /dev/null 2>&1 &'
    echo ''
    echo 'Then, run this command to generate the hashed credentials file:'
    echo 'diambra run -n --path.credentials "/workspace/diambra/credentials"'
    echo ''
    echo 'After generating the credentials file, you can run the training script manually or restart the container:'
    echo 'diambra run -s=${SCALE} --path.credentials /workspace/diambra/credentials \'
    echo '        python ${TRAINING_SCRIPT} ${EXTRA_ARGS}'
    exec /bin/bash
    exit 1
fi

# Check if $AUTO mode is set to false
if [ "$(echo "$AUTO" | tr '[:upper:]' '[:lower:]')" == "false" ]; then
    echo "AUTO mode is disabled."
    echo "Entering shell mode for manual use."
    exec /bin/bash
    exit 1
fi

# Start Docker daemon in the background
nohup sudo dockerd > /dev/null 2>&1 &

# Wait for Docker daemon to start
timeout=5
while ! docker info > /dev/null 2>&1; do
  echo "Waiting for Docker daemon to start..."
  sleep 1
  timeout=$((timeout - 1))
  if [ $timeout -le 0 ]; then
    echo "Failed to start Docker daemon."
    exit 1
  fi
done

echo "Starting Tensorboard"

# Start tensorboard in the background
tensorboard --logdir /workspace/output/logs --bind_all > /dev/null 2>&1 &

# Check if the TRAINING_SCRIPT does not exist
if [ ! -s "${TRAINING_SCRIPT}" ]; then
    echo "TRAINING_SCRIPT not found."
    echo "Please mount the training script to /workspace/scripts/ and rerun the container."
    exit 1
fi


echo "Running Diambra Script"

# Run the diambra run command without replacing the current shell
diambra run -s=${SCALE} --path.credentials $HASHED_CREDS \
    python ${TRAINING_SCRIPT} ${EXTRA_ARGS}

echo "Diambra Script Finished."

# Optionally remove the container after it finishes
if [ "$(echo "$STOP_AFTER_RUN" | tr '[:upper:]' '[:lower:]')" == "true" ]; then
    echo "Stopping the container as requested..."
else
    echo "Keeping the container running."
    # Provide an interactive shell to keep the container running
    exec /bin/bash
fi
