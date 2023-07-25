#!/bin/bash
# =====================================================================
# This script is used to create a docker container with mariadb image |
# =====================================================================

read -p "Choose which task you want to do:
  [1] Create a container
  [2] Exit
" choice

createContainer() {
  echo "Creating a container..."

read -p "Enter the name of the container:" name

read -p  "Enter the user name:" userName

read -p "Enter the password: " password

read -p "Enter the host port: " hostPort

read -p "Enter the container port: " containerPort

image="docker.io/library/mariadb:latest"

docker run --name $name --user $userName -e MYSQL_ROOT_PASSWORD=$password -p $hostPort:$containerPort -d $image

echo "$name is running on port $hostPort:$containerPort with the user $userName and the password $password and the image $image"

}

case $choice in
  1) createContainer;;
  2) exit 0;;
  *) echo "Invalid choice";;
esac

