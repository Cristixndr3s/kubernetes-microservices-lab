pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.5-eclipse-temurin-17
    command:
      - cat
    tty: true
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1"
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
      - sleep
    args:
      - "9999"
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
  volumes:
    - name: kaniko-secret
      secret:
        secretName: dockerhub-config
"""
        }
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        PROJECT_ID = 'laboratorio-final-457821'
        CLUSTER_NAME = 'jenkins-cluster'
        LOCATION = 'us-central1'
        DOCKER_IMAGE_VERSION = "v${BUILD_NUMBER}"
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
                        container('maven') {
                            dir('configserver') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
                stage('Eureka Server') {
                    steps {
                        container('maven') {
                            dir('eurekaserver') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
                stage('Gateway Server') {
                    steps {
                        container('maven') {
                            dir('gatewayserver') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
                stage('Accounts') {
                    steps {
                        container('maven') {
                            dir('accounts') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
                stage('Cards') {
                    steps {
                        container('maven') {
                            dir('cards') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
                stage('Loans') {
                    steps {
                        container('maven') {
                            dir('loans') {
                                sh 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
            }
        }

        stage('Build and Push Docker Images with Kaniko') {
            steps {
                container('kaniko') {
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
                            dir("${dirName}") {
                                sh """
                                    /kaniko/executor \
                                      --dockerfile=Dockerfile \
                                      --context=\$(pwd) \
                                      --destination=docker.io/cristixndres/${dockerName}:${DOCKER_IMAGE_VERSION} \
                                      --skip-tls-verify
                                """
                            }
                        }
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
