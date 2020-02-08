#!/bin/bash
NAME=myjenkins
IMAGE=jenkins/jenkins:lts
VOLUME=jenkins_home

if [ $(docker ps --filter "name=$NAME" | wc -l) -eq 2 ]
then
  echo "Container is running"
  docker ps --filter "name=$NAME" --format "{{.Status}}"
elif [ $(docker ps -a --filter "name=$NAME" | wc -l) -eq 2 ]
then
  echo "Starting the container"
  docker start $NAME
else
  echo "Creating the container"
  docker run --name $NAME -d -v $VOLUME:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --group-add=$(stat -c %g /var/run/docker.sock) -p 8080:8080 -p 50000:50000 $IMAGE
  # Additional steps
  docker exec -t -u 0 $NAME bash -c "\
    groupadd -g $(stat -c %g /var/run/docker.sock) docker && \
    apt-get update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/debian \$(lsb_release -cs) stable\" && \
    apt-get update && \
    apt-get -y install docker-ce-cli && \
    usermod -aG docker jenkins"
fi

