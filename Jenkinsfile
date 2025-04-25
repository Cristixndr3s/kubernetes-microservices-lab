yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - sleep
    args:
    - "9999999"
    volumeMounts:
      - name: kaniko-secret
        mountPath: /kaniko/.docker
  volumes:
    - name: kaniko-secret
      secret:
        secretName: regcred
"""
        }
    }
    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub'
        DOCKERHUB_USERNAME = 'cristixndres'
        REPO_NAME = 'kubernetes-microservices-lab'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Cristixndr3s/kubernetes-microservices-lab.git'
            }
        }
        stage('Build and Push Docker Images') {
            steps {
                container('kaniko') {
                    sh '''
                    echo "🔧 Building and pushing Docker images..."

                    microservices=(accounts cards configserver eurekaserver gatewayserver loans)

                    for service in "${microservices[@]}"; do
                      /kaniko/executor \
                        --dockerfile=$service/Dockerfile \
                        --context=./$service \
                        --destination=$DOCKERHUB_USERNAME/$service:latest \
                        --skip-tls-verify=true
                    done
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    echo "🚀 Deploying to Kubernetes..."

                    kubectl apply -f k8s/configmap.yaml
                    kubectl apply -f k8s/accounts/
                    kubectl apply -f k8s/cards/
                    kubectl apply -f k8s/configserver/
                    kubectl apply -f k8s/eurekaserver/
                    kubectl apply -f k8s/gatewayserver/
                    kubectl apply -f k8s/loans/
                    '''
                }
            }
        }
    }
}