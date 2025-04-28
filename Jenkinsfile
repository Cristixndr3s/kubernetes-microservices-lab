pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:4.10-3
      resources:
        requests:
          memory: "512Mi"
          cpu: "250m"
    - name: maven
      image: maven:3.8.6-openjdk-17
      command:
      - cat
      tty: true
      resources:
        requests:
          memory: "1Gi"
          cpu: "500m"
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      args:
        - --dockerfile=/workspace/Dockerfile
        - --context=dir:///workspace
        - --destination=docker.io/tu_usuario/tu_microservicio:latest
        - --skip-tls-verify
      volumeMounts:
        - name: dockerhub-config
          mountPath: /kaniko/.docker
      resources:
        requests:
          memory: "512Mi"
          cpu: "250m"
  volumes:
    - name: dockerhub-config
      secret:
        secretName: dockerhub-config
"""
        }
    }

    environment {
        DOCKER_CONFIG = '/kaniko/.docker'
    }

    stages {
        stage('Build and Push with Kaniko') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
                container('kaniko') {
                    sh 'echo Kaniko build starting...'
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