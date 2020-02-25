# jenkins-docker
Jenkins with Docker experiments

The `jenkins.sh` script installs Jenkins with Docker. It bind mounts the Docker socket to give access to the existing Docker daemon from inside the container. The container has a volume to persist your changes between restarts.

If you want to play with this demo, you can fork this repository. Edit the Jenkinsfile to fit your needs.

## Using Jenkins from the command line
Visit the endpoint http://localhost:8080/cli and it will give you a link to download the `jenkins-cli.jar`.

### Create a credential for Docker Hub

Clone or download the repo, edit the `credentials1.xml` file and set your username/password credentials. Be careful and DO NOT PUSH this file to a repository.
```
java -jar jenkins-cli.jar -s http://localhost:8080 -auth <user>:<pass> create-credentials-by-xml system::system::jenkins _ < credentials1.xml
```

### Create the example pipeline

Clone or download the repo, edit the `pipeline1.xml` file and change the repository URL to point to your repo.
```
java -jar jenkins-cli.jar -s http://localhost:8080 -auth <user>:<pass> create-job pipeline1 < pipeline1.xml
```

### Build the job

This command will run the example pipeline.
```
java -jar jenkins-cli.jar -s http://localhost:8080 -auth <user>:<pass> build pipeline1 -p ENV=stage -s -v
```

