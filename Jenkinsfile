pipeline {
  agent any

  environment {
    DOCKER_HUB_USER = 'cristixndr3s'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'github-token', url: 'https://github.com/Cristixndr3s/kubernetes-microservices-lab.git'
      }
    }

    stage('Build & Push Docker Images') {
      steps {
        script {
          def services = ['accounts', 'cards', 'loans']
          services.each { service ->
            sh """
              docker build -t $DOCKER_HUB_USER/${service}:$IMAGE_TAG $service
              echo "${DOCKER_HUB_USER} DockerHub Login"
              echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin
              docker push $DOCKER_HUB_USER/${service}:$IMAGE_TAG
            """
          }
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GOOGLE_CREDENTIALS')]) {
          sh '''
            gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS
            gcloud container clusters get-credentials jenkins-cluster --zone us-central1

            # Reemplazar los tags en los YAML de Kubernetes con el nuevo IMAGE_TAG
            sed -i "s/TAG_PLACEHOLDER/$IMAGE_TAG/g" k8s/*.yaml

            # Aplicar manifiestos
            kubectl apply -f k8s/
          '''
        }
      }
    }
  }
}
