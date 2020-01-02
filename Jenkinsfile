pipeline {

  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  parameters {
    choice(choices: ['dev','test'], description: 'Name of the environment', name: 'ENV')
    string(defaultValue: "1.0", description: 'Version', name: 'APP_VERSION')
  }

  environment {
    MYAPP = "flask-app"
  }
  
  stages {
    stage("Build") {
      steps {
        script {
          def appImage = docker.build("myapp:${env.BUILD_ID}", ${env.MYAPP})
        }
      }
    }
    
    stage("Test - Unit tests") {
      steps { runUnittests() }
    }

    stage("Deploy - Dev") {
      steps { deploy('dev') }
    }

    stage("Test - UAT Dev") {
      steps { runUAT(8888) }
    }
/*
    stage("Deploy - Stage") {
      steps { deploy('stage') }
    }

    stage("Test - UAT Stage") {
      steps { runUAT(80) }
    }
*/
  }
}


def deploy(environment) {

  def containerName = ''
  def port = ''

  if ("${environment}" == 'dev') {
    containerName = "app_dev"
    port = "8888"
  }
  else if ("${environment}" == 'stage') {
    containerName = "app_stage"
    port = "80"
  }
  else {
    println "Environment not valid"
    System.exit(0)
  }

  // Ensure the container is first stopped and removed (if it was running)
  sh "docker ps -f name=${containerName} -q | xargs --no-run-if-empty docker stop"
  sh "docker ps -a -f name=${containerName} -q | xargs -r docker rm"

  def appContainer = docker.image("myapp:${env.BUILD_ID}").run("-d -p ${port}:5000 --name ${containerName}")

}

def runUnittests() {
  def appContainer = docker.image("myapp:${env.BUILD_ID}").inside("-e PYTHONPATH=${env.WORKSPACE}/${env.MYAPP}") {
    sh "python3 ${env.MYAPP}/tests/test_flask_app.py"
  }
}


def runUAT(port) {
  def ip = sh(returnStdout: true, script: "docker inspect -f '{{ .NetworkSettings.IPAddress }}' app_dev").trim()
  sh "${env.MYAPP}/tests/runUAT.sh ${ip} 5000"
}
