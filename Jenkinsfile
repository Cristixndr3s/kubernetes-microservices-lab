pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.3-eclipse-temurin-17
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    args:
    - --dockerfile=\$(DOCKERFILE)
    - --context=\$(CONTEXT)
    - --destination=\$(DESTINATION_IMAGE)
    - --oci-layout-path=\$(OCI_LAYOUT_PATH)
    - --skip-tls-verify
    env:
    - name: GOOGLE_APPLICATION_CREDENTIALS
      value: /secret/kaniko-secret
    volumeMounts:
    - name: kaniko-secret
      mountPath: /secret
      readOnly: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
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
        DOCKERFILE = "Dockerfile"
        CONTEXT = "."
        DESTINATION_IMAGE = "docker.io/cristixndres/\${JOB_BASE_NAME}:${BUILD_NUMBER}"
        OCI_LAYOUT_PATH = "/kaniko/output"
    }

    stages {
        stage('Build and Push Docker Image') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
                container('kaniko') {
                    sh '/kaniko/executor'
                }
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline finalizado (cleanup)'
        }
    }
}
