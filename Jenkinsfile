pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:3307.v632ed11b_3a_c7-2
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1"
"""
        }
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        PROJECT_ID = 'laboratorio-final-457821'
        CLUSTER_NAME = 'jenkins-cluster'
        LOCATION = 'us-central1'
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
                            sh 'chmod +x mvn'
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Eureka Server') {
                    steps {
                        dir('eurekaserver') {
                            sh 'chmod +x mvn'
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Gateway Server') {
                    steps {
                        dir('gatewayserver') {
                            sh 'chmod +x mvn'
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Accounts') {
                    steps {
                        dir('accounts') {
                            sh 'chmod +x mvn'
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Cards') {
                    steps {
                        dir('cards') {
                            sh 'chmod +x mvn'
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Loans') {
                    steps {
                        dir('loans') {
                            sh 'chmod +x mvn'
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
                        int delaySeconds = 10
                        int attempt = 1

                        while (attempt <= maxRetries) {
                            echo "🔄 Intento ${attempt} para subir ${imageName}"
                            def result = sh(script: "docker push ${imageName}", returnStatus: true)

                            if (result == 0) {
                                echo "✅ Imagen ${imageName} subida correctamente"
                                break
                            } else {
                                echo "⚠️ Falló el push (intento ${attempt})"
                                if (attempt == maxRetries) {
                                    error "❌ No se pudo subir ${imageName} después de ${maxRetries} intentos"
                                }
                                sleep(time: delaySeconds, unit: "SECONDS")
                                attempt++
                            }
                        }
                    }

                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                        def services = [
                            'configserver': 'configserver',
                            'eurekaserver': 'eurekaserver',
                            'gatewayserver': 'gatewayserver',
                            'accounts': 'accounts-service',
                            'cards': 'cards-service',
                            'loans': 'loans-service'
                        ]

                        parallel services.collectEntries { dirName, dockerName ->
                            ["${dirName}": {
                                dir(dirName) {
                                    def imageName = "cristixndres/${dockerName}:${DOCKER_IMAGE_VERSION}"

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
                        'configserver': 'configserver',
                        'eurekaserver': 'eurekaserver',
                        'gatewayserver': 'gatewayserver',
                        'accounts': 'accounts-service',
                        'cards': 'cards-service',
                        'loans': 'loans-service'
                    ]
                    services.each { dirName, dockerName ->
                        sh """
                            sed -i 's|cristixndres/${dockerName}:[^ ]*|cristixndres/${dockerName}:${DOCKER_IMAGE_VERSION}|' k8s/${dirName}/deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    script {
                        sh '''
                            gcloud auth activate-service-account --key-file=$GCP_KEY
                            gcloud container clusters get-credentials $CLUSTER_NAME --region $LOCATION --project $PROJECT_ID

                            kubectl apply -f k8s/configmap.yaml

                            for service in configserver eurekaserver gatewayserver accounts loans cards; do
                                kubectl apply -f k8s/$service/deployment.yaml
                                kubectl apply -f k8s/$service/service.yaml
                            done
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline finalizado (cleanup)"
        }
    }
}
