pipeline {
    agent any

    environment {
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

        stage('Deploy to Minikube') {
            steps {
                script {
                    def services = [
                        'configserver',
                        'eurekaserver',
                        'gatewayserver',
                        'accounts',
                        'cards',
                        'loans'
                    ]

                    // Aplicar todos los ConfigMaps
                    services.each { svc ->
                        def cfg = "k8s/${svc}/configmap.yaml"
                        if (fileExists(cfg)) {
                            sh "kubectl apply -f ${cfg}"
                        } else {
                            echo "No se encontró ${cfg}, se omite."
                        }
                    }

                    // Aplicar todos los Deployments y Services
                    services.each { svc ->
                        sh "kubectl apply -f k8s/${svc}/deployment.yaml"
                        sh "kubectl apply -f k8s/${svc}/service.yaml"
                    }
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
