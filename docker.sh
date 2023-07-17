# 

read -p "Enter the name of the container:" name

read -p  "Enter the user name:" userName

read -p "Enter the password: " password

read -p "Enter the host port: " hostPort

read -p "Enter the container port: " containerPort

image="docker.io/library/mariadb:latest"

docker run --name $name --user $userName -e MYSQL_ROOT_PASSWORD=$password -p $hostPort:$containerPort -d $image

echo "$name is running on port $hostPort:$containerPort with the user $userName and the password $password and the image $image"

exit 0