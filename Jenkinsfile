pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE_VERSION = "v${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
        DOCKER_USERNAME = 'cristixndr3s'
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
            steps {
                script {
                    def safeDockerPush = { imageName ->
                        int maxRetries = 3
                        int retryDelaySeconds = 10
                        int attempt = 1

                        while (attempt <= maxRetries) {
                            echo "🔄 Intento ${attempt} para subir ${imageName}"
                            def result = sh(script: "docker push ${imageName}", returnStatus: true)

                            if (result == 0) {
                                echo "✅ Imagen ${imageName} subida correctamente"
                                break
                            } else {
                                echo "⚠️ Falló el push de ${imageName} (intento ${attempt})"
                                if (attempt == maxRetries) {
                                    error "❌ No se pudo subir ${imageName} después de ${maxRetries} intentos"
                                }
                                sleep(time: retryDelaySeconds, unit: "SECONDS")
                                attempt++
                            }
                        }
                    }

                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                        def services = [
                            'configserver',
                            'eurekaserver',
                            'gatewayserver',
                            'accounts',
                            'cards',
                            'loans'
                        ]

                        parallel services.collectEntries { service ->
                            ["${service}" : {
                                dir(service) {
                                    def dockerName = "app-microservicios-${service}"
                                    def imageName = "${DOCKER_USERNAME}/${dockerName}:${DOCKER_IMAGE_VERSION}"

                                    sh """
                                        echo ">> Construyendo imagen ${imageName}"
                                        docker build --platform linux/amd64 -t ${imageName} .
                                    """

                                    def exists = sh(
                                        script: "curl --silent -f -lSL https://hub.docker.com/v2/repositories/${DOCKER_USERNAME}/${dockerName}/tags/${DOCKER_IMAGE_VERSION}/ > /dev/null && echo true || echo false",
                                        returnStdout: true
                                    ).trim()

                                    if (exists == "false") {
                                        safeDockerPush(imageName)
                                    } else {
                                        echo ">> La imagen ${imageName} ya existe, omitiendo push"
                                    }
                                }
                            }]
                        }

                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
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
                    services.each { service ->
                        def dockerName = "app-microservicios-${service}"
                        sh """
                            sed -i 's|[^ ]*/${dockerName}:[^ ]*|${DOCKER_USERNAME}/${dockerName}:${DOCKER_IMAGE_VERSION}|' k8s/${service}/deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Deploy to Minikube') {
    steps {
        sh 'kubectl get nodes'
        sh 'kubectl apply -f k8s/configmap.yaml'
        sh 'kubectl apply -f k8s/configserver --recursive'
        sh 'kubectl apply -f k8s/eurekaserver --recursive'
        sh 'kubectl apply -f k8s/gatewayserver --recursive'
        sh 'kubectl apply -f k8s/accounts --recursive'
        sh 'kubectl apply -f k8s/cards --recursive'
        sh 'kubectl apply -f k8s/loans --recursive'
    }
}

    }

    post {
        always {
            cleanWs()
        }
    }
}
