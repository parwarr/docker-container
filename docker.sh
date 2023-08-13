#!/bin/bash

MARIADB_IMAGE="docker.io/library/mariadb:latest"
MYSQL_IMAGE="docker.io/library/mysql:latest"
POSTGRESQL_IMAGE="docker.io/library/postgres:latest"
MONGODB="docker.io/library/mongo:latest"
REDIS="docker.io/library/redis:latest"


pullImage() {
  if ! docker image inspect "$IMAGE" &>/dev/null; then
    echo "Pulling $IMAGE image..."
    docker pull "$IMAGE"
    echo "Image pulled successfully."
  else
    echo "Image is already available."
  fi
}

readCommonInputs() {
  read -p "Enter the name of the container: " NAME
  read -p "Enter the username: " USERNAME
  read -p "Enter the password: " PASSWORD
  read -p "Enter the host port: " HOST_PORT
  read -p "Enter the container port: " CONTAINER_PORT
}

createContainerWithMariaDB() {
  pullImage
  readCommonInputs
  docker run --name "$NAME" --user "$USERNAME" -e MYSQL_ROOT_PASSWORD="$PASSWORD" -p "$HOST_PORT":"$CONTAINER_PORT" -d "$IMAGE"
  echo "$NAME is running on port $HOST_PORT:$CONTAINER_PORT with the user $USERNAME and the password $PASSWORD and the image $IMAGE"
}

dockerYmlFile() {
  pullImage
  readCommonInputs
  echo "version: '3.1'

services:
  $NAME:
    image: $IMAGE
    container_name: $NAME
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $PASSWORD
    ports:
      - $HOST_PORT:$CONTAINER_PORT
    volumes:
      - /var/lib/mysql
" > docker-compose.yml
  echo "The yml file is created"
}

read -p "Choose which task you want to do:
  [1] Create a container
  [2] Create a docker-compose.yml file
  [3] Exit
" CHOICE

if [[ $CHOICE == '1' || $CHOICE == '2' ]]; then
  read -p "Choose which database you want to use:
  [1] MariaDB
  [2] MySQL
  [3] PostgreSQL
  [4] SQLite
  [5] MongoDB
  [6] Redis
  [7] Exit
" IMAGE

  if [[ $IMAGE == '7' ]]; then
    exit 0
  fi
  
else
  exit 0

  case $IMAGE in
    1) IMAGE="$MARIADB_IMAGE";;
    2) IMAGE="$MYSQL_IMAGE";;
    3) IMAGE="$POSTGRESQL_IMAGE";;
    4) IMAGE="$SQLITE_IMAGE";;
    5) IMAGE="$MONGODB";;
    6) IMAGE="$REDIS";;
    7) exit 0;;
    *) echo "Invalid choice"; exit 1;;
  esac
fi

case $CHOICE in
  1) createContainerWithMariaDB;;
  2) dockerYmlFile;;
  3) exit 0;;
  *) echo "Invalid choice"; exit 1;
esac