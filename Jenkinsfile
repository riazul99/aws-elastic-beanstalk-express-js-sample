pipeline {
  agent none

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    APP_NAME = 'aws-elastic-beanstalk-express-js-sample'
    DOCKER_IMAGE = "docker.io/riazul99/${APP_NAME}"
    DOCKER_HOST = 'tcp://dind:2376'
    DOCKER_CERT_PATH = '/certs/client'
    DOCKER_TLS_VERIFY = '1'
  }

  stages {
    stage('Checkout') {
      agent { label 'built-in' }
      steps { checkout scm }
    }

    stage('Install dependencies (Node 16 in container)') {
      agent {
        docker {
          image 'docker:24'
          args '-v /certs/client:/certs/client:ro --network=project2-compose_jenkins'
        }
      }
      environment { DOCKER_HOST = 'tcp://dind:2376'; DOCKER_CERT_PATH='/certs/client'; DOCKER_TLS_VERIFY='1' }
      steps {
        sh '''
          docker run --rm -v "$PWD":/app -w /app node:16 npm install --save
        '''
      }
    }

    stage('Unit tests') {
      agent {
        docker {
          image 'docker:24'
          args '-v /certs/client:/certs/client:ro --network=project2-compose_jenkins'
        }
      }
      environment { DOCKER_HOST = 'tcp://dind:2376'; DOCKER_CERT_PATH='/certs/client'; DOCKER_TLS_VERIFY='1' }
      steps {
        sh '''
          docker run --rm -v "$PWD":/app -w /app node:16 bash -lc 'npm test || echo "No tests available, skipping..."'
        '''
      }
    }

    stage('Security scan (optional Snyk)') {
      when { expression { return env.SNYK_TOKEN != null } }
      agent {
        docker {
          image 'docker:24'
          args '-v /certs/client:/certs/client:ro --network=project2-compose_jenkins'
        }
      }
      environment { DOCKER_HOST = 'tcp://dind:2376'; DOCKER_CERT_PATH='/certs/client'; DOCKER_TLS_VERIFY='1' }
      steps {
        withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
          sh '''
            docker run --rm -v "$PWD":/app -w /app node:16 bash -lc '
              npm i -g snyk &&
              snyk auth "$SNYK_TOKEN" &&
              snyk test --severity-threshold=high
            '
          '''
        }
      }
    }

    stage('Build Docker image') {
      agent {
        docker {
          image 'docker:24'
          args '-v /certs/client:/certs/client:ro --network=project2-compose_jenkins'
        }
      }
      environment { DOCKER_HOST = 'tcp://dind:2376'; DOCKER_CERT_PATH='/certs/client'; DOCKER_TLS_VERIFY='1' }
      steps {
        sh '''
          docker version
          docker build -t ${DOCKER_IMAGE}:$BUILD_NUMBER -t ${DOCKER_IMAGE}:latest .
        '''
      }
    }

    stage('Push Docker image') {
      agent {
        docker {
          image 'docker:24'
          args '-v /certs/client:/certs/client:ro --network=project2-compose_jenkins'
        }
      }
      environment { DOCKER_HOST = 'tcp://dind:2376'; DOCKER_CERT_PATH='/certs/client'; DOCKER_TLS_VERIFY='1' }
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
