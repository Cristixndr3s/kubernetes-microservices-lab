pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins/kaniko-pod.yaml'
        }
    }
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub' // ID de tus credenciales en Jenkins
        DOCKERHUB_USERNAME = 'cristixndres'
        REPO_NAME = 'kubernetes-microservices-lab'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Cristixndr3s/kubernetes-microservices-lab.git'
            }
        }
        stage('Build and Push Docker Images') {
            steps {
                container('kaniko') {
                    sh '''
                    echo "Building and pushing microservices..."

                    microservices=(accounts cards configserver eurekaserver gatewayserver loans)

                    for service in "${microservices[@]}"; do
                      /kaniko/executor \
                        --dockerfile=$service/Dockerfile \
                        --context=./$service \
                        --destination=$DOCKERHUB_USERNAME/$service:latest \
                        --skip-tls-verify=true
                    done
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                echo "Deploying to Kubernetes..."

                kubectl apply -f k8s/configmap.yaml
                kubectl apply -f k8s/accounts/
                kubectl apply -f k8s/cards/
                kubectl apply -f k8s/configserver/
                kubectl apply -f k8s/eurekaserver/
                kubectl apply -f k8s/gatewayserver/
                kubectl apply -f k8s/loans/
                '''
            }
        }
    }
}
