#!/bin/bash

# Docker image variables
MARIADB_IMAGE="docker.io/library/mariadb:latest"
MYSQL_IMAGE="docker.io/library/mysql:latest"
POSTGRESQL_IMAGE="docker.io/library/postgres:latest"
SQLITE_IMAGE="docker.io/library/sqlite:latest"
MONGODB="docker.io/library/mongo:latest"
REDIS="docker.io/library/redis:latest"

# Function to pull Docker image if not available
pullImage() {
  if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "Pulling $IMAGE image..."
    docker pull "$IMAGE"
    echo "Image pulled successfully."
  else
    echo "Image is already available."
  fi
}

# Function to read common inputs
readCommonInputs() {
  read -p "Enter the name of the container: " CONTAINER_NAME
  read -p "Enter the username: " USERNAME
  read -p "Enter the password: " PASSWORD
  read -p "Enter the host port: " HOST_PORT
  read -p "Enter the container port: " CONTAINER_PORT
}

# Function to create a Docker container
createDockerContainer() {
  pullImage
  readCommonInputs

  case "$IMAGE" in
    $MARIADB_IMAGE|$MYSQL_IMAGE|$SQLITE_IMAGE)
      docker run --name "$CONTAINER_NAME" --user "$USERNAME" -e MYSQL_ROOT_PASSWORD="$PASSWORD" -p "$HOST_PORT":"$CONTAINER_PORT" -d "$IMAGE"
      ;;
    $POSTGRESQL_IMAGE)
      docker run --name "$CONTAINER_NAME" --user "$USERNAME" -e POSTGRES_PASSWORD="$PASSWORD" -p "$HOST_PORT":"$CONTAINER_PORT" -d "$IMAGE"
      ;;
    $MONGODB)
      docker run --name "$CONTAINER_NAME" --user "$USERNAME" -e MONGO_INITDB_ROOT_USERNAME="$USERNAME" -e MONGO_INITDB_ROOT_PASSWORD="$PASSWORD" -p "$HOST_PORT":"$CONTAINER_PORT" -d "$IMAGE"
      ;;
    $REDIS)
      docker run --name "$CONTAINER_NAME" --user "$USERNAME" -e REDIS_PASSWORD="$PASSWORD" -p "$HOST_PORT":"$CONTAINER_PORT" -d "$IMAGE"
      ;;
    *)
      echo "Invalid image choice."
      exit 1
      ;;
  esac

  echo "$CONTAINER_NAME is running on port $HOST_PORT:$CONTAINER_PORT with the user $USERNAME and the password $PASSWORD and the image $IMAGE"
}

# Function to create a docker-compose.yml file
createDockerComposeFile() {  
  readCommonInputs

  echo "Creating docker-compose.yml file..."

  case "$IMAGE" in
    $MARIADB_IMAGE|$MYSQL_IMAGE|$SQLITE_IMAGE)
      cat > docker-compose.yml <<EOF
version: '3.1'
services:
  $CONTAINER_NAME:
    image: $IMAGE
    container_name: $CONTAINER_NAME
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $PASSWORD
    ports:
      - $HOST_PORT:$CONTAINER_PORT
    volumes:
      - /var/lib/mysql
EOF
      ;;
    $POSTGRESQL_IMAGE)
      cat > docker-compose.yml <<EOF
version: '3.1'
services:
  $CONTAINER_NAME:
    image: $IMAGE
    container_name: $CONTAINER_NAME
    restart: always
    environment:
      POSTGRES_PASSWORD: $PASSWORD
    ports:
      - $HOST_PORT:$CONTAINER_PORT
    volumes:
      - /var/lib/postgresql/data
EOF
           ;;
    $MONGODB)
      cat > docker-compose.yml <<EOF
version: '3.1'
services:
  $CONTAINER_NAME:
    image: $IMAGE
    container_name: $CONTAINER_NAME
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: $USERNAME
      MONGO_INITDB_ROOT_PASSWORD: $PASSWORD
    ports:
      - $HOST_PORT:$CONTAINER_PORT
    volumes:
      - /data/db
EOF
      ;;
    $REDIS)
      cat > docker-compose.yml <<EOF
version: '3.1'
services:
  $CONTAINER_NAME:
    image: $IMAGE
    container_name: $CONTAINER_NAME
    restart: always
    environment:
      REDIS_PASSWORD: $PASSWORD
    ports:
      - $HOST_PORT:$CONTAINER_PORT
EOF
      ;;
    *)
      echo "Invalid image choice for docker-compose.yml file."
      exit 1
      ;;
  esac

  echo "docker-compose.yml file created successfully."
}

# Main script
read -p "Choose which task you want to do:
  [1] Create a container
  [2] Create a docker-compose.yml file
  [3] Exit
" CHOICE

if [[ "$CHOICE" == "1" ]]; then
  read -p "Choose which database you want to use:
  [1] MariaDB
  [2] MySQL
  [3] PostgreSQL
  [4] SQLite
  [5] MongoDB
  [6] Redis
  [7] Exit
" IMAGE_CHOICE

  case "$IMAGE_CHOICE" in
    1) IMAGE="$MARIADB_IMAGE" ;;
    2) IMAGE="$MYSQL_IMAGE" ;;
    3) IMAGE="$POSTGRESQL_IMAGE" ;;
    4) IMAGE="$SQLITE_IMAGE" ;;
    5) IMAGE="$MONGODB" ;;
    6) IMAGE="$REDIS" ;;
    7) exit 0 ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
  
  createDockerContainer
elif [[ "$CHOICE" == "2" ]]; then
  read -p "Choose which database you want to use:
  [1] MariaDB
  [2] MySQL
  [3] PostgreSQL
  [4] MongoDB
  [5] Redis
  [6] Exit
" IMAGE_CHOICE

  case "$IMAGE_CHOICE" in
    1) IMAGE="$MARIADB_IMAGE" ;;
    2) IMAGE="$MYSQL_IMAGE" ;;
    3) IMAGE="$POSTGRESQL_IMAGE" ;;
    4) IMAGE="$MONGODB" ;;
    5) IMAGE="$REDIS" ;;
    6) exit 0 ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
  
  createDockerComposeFile
else
  exit 0
  echo "test"
fi