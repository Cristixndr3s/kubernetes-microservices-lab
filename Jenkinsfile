pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_USER = 'cristixndr3s'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Cristixndr3s/kubernetes-microservices-lab.git'
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    def services = ['accounts', 'cards', 'configserver', 'eurekaserver', 'gatewayserver', 'loans']
                    services.each { service ->
                        dir(service) {
                            sh """
                                echo "Building $service"
                                docker build -t $DOCKER_USER/${service}:latest .
                                echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin
                                docker push $DOCKER_USER/${service}:latest
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    echo "Applying manifests from k8s/"
                    kubectl apply -f k8s/
                """
            }
        }
    }
}
