#!/bin/bash
# =====================================================================
# This script is used to create a docker container with mariadb image |
# =====================================================================

read -p "Choose which task you want to do:
  [1] Create a container
  [2] Create a docker-compose.yml file
  [3] Exit
" choice

createContainer() {
  echo "Enter values for the container:"

  read -p "Enter the name of the container:" name

  read -p  "Enter the user name:" userName

  read -p "Enter the password: " password

  read -p "Enter the host port: " hostPort

  read -p "Enter the container port: " containerPort

  image="docker.io/library/mariadb:latest"

docker run --name $name --user $userName -e MYSQL_ROOT_PASSWORD=$password -p $hostPort:$containerPort -d $image

echo "$name is running on port $hostPort:$containerPort with the user $userName and the password $password and the image $image"
}

dockerYmlFile() {

  echo "Enter values for the docker-compose.yml file:"

  read -p "Enter the name of the container:" name

  read -p  "Enter the user name:" userName

  read -p "Enter the password: " password

  read -p "Enter the host port: " hostPort

  read -p "Enter the container port: " containerPort

  image="docker.io/library/mariadb:latest"

echo "version: '3.1'

services:
  $name:
    image: $image
    container_name: $name
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $password
    ports:
      - $hostPort:$containerPort
    volumes:
      - /var/lib/mysql
" > docker-compose.yml

echo "The yml file is created"
}


case $choice in
  1) createContainer;;
  2) dockerYmlFile;;
  3) exit 0;;
  *) echo "Invalid choice";;
esac

