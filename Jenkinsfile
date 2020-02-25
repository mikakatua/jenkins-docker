def appImage

pipeline {
    // Set the agent according to your Jenkins setup
    //agent any
    agent { label 'jenkins-jnlp-slave' }

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {
        choice(choices: ['dev','stage','live'], description: 'Name of the environment', name: 'ENV')
        string(defaultValue: "1.0", description: 'Version', name: 'APP_VERSION')
    }

    environment {
        MYAPP = 'flask-app'
        MYREPO = 'mikakatua' // <-- Change this to your dockerhub repo
    }
 
   stages {
        stage('Build Image') {
            steps {
                script {
                    appImage = docker.build("${env.MYREPO}/myapp:${params.APP_VERSION}", "${env.MYAPP}")
                }
            }
        }

        stage("Test - Unit tests") {
            steps {
                script {
                    def appContainer = appImage.inside("-e PYTHONPATH=${env.WORKSPACE}/${env.MYAPP}") {
                        sh "python3 ${env.MYAPP}/tests/test_flask_app.py" 
                        
                    }
                }
            }
        }       

        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry( '', 'dockerhub_login') {
                        appImage.push('latest')
                    }
                }
            }
        }

        stage("Deploy") {
            steps {
                echo "Deploying to ${params.ENV}"
                deploy("${params.ENV}")
            }
        }

        stage("Test - UAT") {
            steps { runUAT(5000) }
        }

    }
}

def deploy(environment) {

  def containerName = "app_${environment}"
  def port = ''

  if (environment == 'dev') {
    port = "8888"
  }
  else if (environment == 'stage') {
    port = "88"
  }
  else if (environment == 'live') {
    port = "80"
  }
  else {
    println "Environment not valid"
    System.exit(0)
  }

  // Ensure the container is first stopped and removed (if it was running)
  sh "docker ps -f name=${containerName} -q | xargs --no-run-if-empty docker stop"
  sh "docker ps -a -f name=${containerName} -q | xargs -r docker rm"

  def appContainer = docker.image("${env.MYREPO}/myapp:${params.APP_VERSION}").run("-d -p ${port}:5000 --name ${containerName}")
}

def runUAT(port) {
  def ip = sh(returnStdout: true, script: "docker inspect -f '{{ .NetworkSettings.IPAddress }}' app_${params.ENV}").trim()
  sh "${env.MYAPP}/tests/runUAT.sh ${ip} ${port}"
}

