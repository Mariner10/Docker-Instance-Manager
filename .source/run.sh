#!/bin/bash

DATA_DIR="./Container_Data"
IMAGE_NAME="debian-linux"
USER="linux"
BASHRC='
source /etc/profile.d/bash_completion.sh\n
clear
'

# Function to display usage
usage() {
    echo "Usage: $0 -d DATA_DIR -i IMAGE_NAME -u USER -b BASHRC"
    exit 1
}

# Parse flags
while getopts ":d:i:u:b:" opt; do
    case ${opt} in
        d )
            DATA_DIR=$OPTARG
            ;;
        i )
            IMAGE_NAME=$OPTARG
            ;;
        u )
            USER=$OPTARG
            ;;
        b )
            BASHRC=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

# 1. Setup Data Directory
mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/.logs"
mkdir -p "$DATA_DIR/.bin"
mkdir -p "$DATA_DIR/.prompts"
echo -e "$BASHRC" > "$DATA_DIR/.bashrc"
if [[ -d ./executables ]]; then
  cp -pR ./executables/. "$DATA_DIR/.bin/"
  rm -rf ./executables/
  find "$DATA_DIR/.bin" -type f -exec chmod +x {} +
fi

if [[ -d ./prompts ]]; then
  cp -pR ./prompts/. "$DATA_DIR/.prompts/"
  rm -rf ./prompts/
fi

if [[ -d ./home_directory_items ]]; then
  cp -pR ./home_directory_items/. "$DATA_DIR/"
  rm -rf ./home_directory_items/
fi




# --- REPLACEMENT BLOCK START ---

# Check if a container with this name already exists
if [ "$(docker ps -a -q -f name=$IMAGE_NAME)" ]; then
    echo "--- Found existing container: $IMAGE_NAME ---"

    # Check if it is currently running
    if [ "$(docker ps -q -f name=$IMAGE_NAME)" ]; then
        echo "Status: RUNNING. Opening a new shell inside it..."
        # 'exec' creates a new process in the running container
        docker exec -it $IMAGE_NAME /bin/bash
    else
        echo "Status: STOPPED. Restarting..."
        docker start $IMAGE_NAME
        docker exec -it $IMAGE_NAME /bin/bash
    fi


else
    echo "--- No container found. Building and Creating New ---"

    # 1. Build the image (Only build if we are creating a new container)
    docker build \
      --build-arg USERNAME=$USER \
      -t $IMAGE_NAME .

    # 2. Define Log paths
    LOG_FILENAME="session-$(date +%Y-%m-%d_%H%M%S).log"
    CONTAINER_LOG_PATH="/home/$USER/.logs/$LOG_FILENAME"

    # 3. Run the new container
    docker run -it \
      --name $IMAGE_NAME \
      --hostname $IMAGE_NAME \
      --cap-add=NET_ADMIN \
      -v "$(pwd)/$DATA_DIR:/home/$USER" \
      $IMAGE_NAME \
      script -q -c "/bin/bash" "$CONTAINER_LOG_PATH"
fi

# --- REPLACEMENT BLOCK END ---
# 5. Post-Run Cleanup Prompt
echo "Exiting container $IMAGE_NAME"
echo "" 


docker stop $IMAGE_NAME 2>/dev/null
