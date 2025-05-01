pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE_VERSION = "v${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Microservices') {
            parallel {
                stage('Config Server') {
                    steps {
                        dir('configserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Eureka Server') {
                    steps {
                        dir('eurekaserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Gateway Server') {
                    steps {
                        dir('gatewayserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Accounts') {
                    steps {
                        dir('accounts') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Cards') {
                    steps {
                        dir('cards') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Loans') {
                    steps {
                        dir('loans') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Build and Push Docker Images') {
            parallel {
                stage('Config Server') {
                    steps {
                        dir('configserver') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-configserver:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
                stage('Eureka Server') {
                    steps {
                        dir('eurekaserver') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-eurekaserver:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
                stage('Gateway Server') {
                    steps {
                        dir('gatewayserver') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-gatewayserver:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
                stage('Accounts') {
                    steps {
                        dir('accounts') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-accounts:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
                stage('Cards') {
                    steps {
                        dir('cards') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-cards:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
                stage('Loans') {
                    steps {
                        dir('loans') {
                            script {
                                docker.build("cristixndr3s/app-microservicios-loans:${DOCKER_IMAGE_VERSION}").push()
                            }
                        }
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    sh "sed -i s|image:.*app-microservicios-configserver:.*|image: cristixndr3s/app-microservicios-configserver:${DOCKER_IMAGE_VERSION}| k8s/configserver/deployment.yaml"
                    sh "sed -i s|image:.*app-microservicios-eurekaserver:.*|image: cristixndr3s/app-microservicios-eurekaserver:${DOCKER_IMAGE_VERSION}| k8s/eurekaserver/deployment.yaml"
                    sh "sed -i s|image:.*app-microservicios-gatewayserver:.*|image: cristixndr3s/app-microservicios-gatewayserver:${DOCKER_IMAGE_VERSION}| k8s/gatewayserver/deployment.yaml"
                    sh "sed -i s|image:.*app-microservicios-accounts:.*|image: cristixndr3s/app-microservicios-accounts:${DOCKER_IMAGE_VERSION}| k8s/accounts/deployment.yaml"
                    sh "sed -i s|image:.*app-microservicios-cards:.*|image: cristixndr3s/app-microservicios-cards:${DOCKER_IMAGE_VERSION}| k8s/cards/deployment.yaml"
                    sh "sed -i s|image:.*app-microservicios-loans:.*|image: cristixndr3s/app-microservicios-loans:${DOCKER_IMAGE_VERSION}| k8s/loans/deployment.yaml"
                }
            }
        }

        stage('Deploy to Minikube') {
            agent {
                docker {
                    image 'bitnami/kubectl:latest'
                    args '-v /root/.kube:/root/.kube:ro'
                }
            }
            steps {
                script {
                    sh 'kubectl version --client'
                    sh 'kubectl get nodes'

                    sh 'kubectl apply -f k8s/configmap.yaml'
                    sh 'kubectl apply -f k8s/configserver'
                    sh 'kubectl apply -f k8s/eurekaserver'
                    sh 'kubectl apply -f k8s/gatewayserver'
                    sh 'kubectl apply -f k8s/accounts'
                    sh 'kubectl apply -f k8s/cards'
                    sh 'kubectl apply -f k8s/loans'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
