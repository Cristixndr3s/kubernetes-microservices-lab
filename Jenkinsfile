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
                                echo "✅ Imagen ${imageName} subida correctamente en el intento ${attempt}"
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
                            'accounts': 'accounts-service',
                            'cards': 'cards-service',
                            'loans': 'loans-service'
                        ]

                        parallel services.collectEntries { dirName, dockerName ->
                            ["${dirName}" : {
                                dir(dirName) {
                                    def imageName = "$DOCKER_USER/${dockerName}:${DOCKER_IMAGE_VERSION}"

                                    sh """
                                        echo ">> Construyendo imagen ${imageName}"
                                        docker build -t ${imageName} .
                                    """

                                    safeDockerPush(imageName)
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
                        'accounts': 'accounts-service',
                        'cards': 'cards-service',
                        'loans': 'loans-service'
                    ]
                    services.each { dirName, dockerName ->
                        sh """
                            sed -i 's|${dockerName}:[^ ]*|${dockerName}:${DOCKER_IMAGE_VERSION}|' k8s/${dirName}/deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh '''
                        kubectl apply -f k8s/configmap.yaml || true

                        for service in accounts cards loans; do
                            kubectl apply -f k8s/$service/deployment.yaml
                            kubectl apply -f k8s/$service/service.yaml
                        done
                    '''
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
