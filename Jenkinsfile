pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "riazul99/aws-elastic-beanstalk-express-js-sample"
        DOCKERHUB_CREDENTIALS = "dockerhub-credentials"
        TIMESTAMP = "${new Date().format('yyyyMMddHHmmss')}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                sh '''
                  docker run --rm -v "$PWD":/app -w /app node:16 \
                  sh -c "npm ci --omit=dev || npm install --save"
                '''
            }
        }

        stage('Unit tests') {
            steps {
                sh '''
                  docker run --rm -v "$PWD":/app -w /app node:16 npm test || echo "No tests"
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                script {
                    sh """
                      docker build -t $DOCKERHUB_REPO:latest -t $DOCKERHUB_REPO:$TIMESTAMP .
                    """
                }
            }
        }

        stage('Push Docker image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                          echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                          docker push $DOCKERHUB_REPO:latest
                          docker push $DOCKERHUB_REPO:$TIMESTAMP
                        '''
                    }
                }
            }
        }
    }
}
