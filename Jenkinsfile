pipeline {
  agent any

  environment {
    KUBECONFIG = '/var/jenkins_home/.kube/config'
  }

  stages {
    stage('Verificar conexión con Minikube') {
      steps {
        sh 'kubectl version'
        sh 'kubectl get nodes'
      }
    }

    stage('Desplegar microservicio accounts') {
      steps {
        sh 'kubectl apply -f k8s/accounts/configmap.yaml'
        sh 'kubectl apply -f k8s/accounts/deployment.yaml'
        sh 'kubectl apply -f k8s/accounts/service.yaml'
      }
    }
  }
}
