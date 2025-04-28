pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
    GCP_CREDENTIALS = credentials('gcp-credentials')
    GCP_PROJECT_ID = 'laboratorio-final-457821' 
    CLUSTER_NAME = 'jenkins-cluster'             
    CLUSTER_REGION = 'us-central1'                
    DOCKER_USERNAME = 'cristixndr3s'              
    BUILD_VERSION = "v${BUILD_NUMBER}"            
  }

  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'github-token', url: 'https://github.com/Cristixndr3s/kubernetes-microservices-lab.git'
      }
    }

    stage('Build Docker Images') {
      steps {
        sh '''
          docker build -t $DOCKER_USERNAME/accounts-service:$BUILD_VERSION ./accounts
          docker build -t $DOCKER_USERNAME/loans-service:$BUILD_VERSION ./loans
          docker build -t $DOCKER_USERNAME/cards-service:$BUILD_VERSION ./cards
        '''
      }
    }

    stage('Push Docker Images') {
      steps {
        sh '''
          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
          docker push $DOCKER_USERNAME/accounts-service:$BUILD_VERSION
          docker push $DOCKER_USERNAME/loans-service:$BUILD_VERSION
          docker push $DOCKER_USERNAME/cards-service:$BUILD_VERSION
        '''
      }
    }

    stage('Authenticate to GCP') {
      steps {
        sh '''
          echo "$GCP_CREDENTIALS" > gcp-key.json
          gcloud auth activate-service-account --key-file=gcp-key.json
          gcloud config set project $GCP_PROJECT_ID
          gcloud container clusters get-credentials $CLUSTER_NAME --region $CLUSTER_REGION
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s/accounts/
          kubectl apply -f k8s/loans/
          kubectl apply -f k8s/cards/
          
          kubectl set image deployment/accounts-deployment accounts=$DOCKER_USERNAME/accounts-service:$BUILD_VERSION
          kubectl set image deployment/loans-deployment loans=$DOCKER_USERNAME/loans-service:$BUILD_VERSION
          kubectl set image deployment/cards-deployment cards=$DOCKER_USERNAME/cards-service:$BUILD_VERSION
        '''
      }
    }
  }
}
