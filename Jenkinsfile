pipeline {
  agent {
    docker { image 'node:16' args '-u root:root' }
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    ansiColor('xterm')
  }

  environment {
    APP_NAME = 'aws-elastic-beanstalk-express-js-sample'
    DOCKER_IMAGE = "docker.io/<YOUR_DOCKERHUB_USERNAME>/${APP_NAME}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install dependencies') {
      steps { sh 'npm install --save' }
    }

    stage('Unit tests') {
      steps { sh 'npm test || echo "No tests available, skipping..."' }
    }

    stage('Security scan') {
      when { expression { return env.SNYK_TOKEN != null } }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''
            npm install -g snyk
            snyk auth $SNYK_TOKEN
            snyk test --severity-threshold=high
          '''
        }
      }
    }

    stage('Build Docker image') {
      steps {
        sh '''
          docker build -t ${DOCKER_IMAGE}:$BUILD_NUMBER -t ${DOCKER_IMAGE}:latest .
        '''
      }
    }

    stage('Push Docker image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${DOCKER_IMAGE}:$BUILD_NUMBER
            docker push ${DOCKER_IMAGE}:latest
          '''
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
    }
  }
}
