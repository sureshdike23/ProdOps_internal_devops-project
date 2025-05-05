pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker-gcloud
    image: gcr.io/google.com/cloudsdktool/cloud-sdk:slim
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
    }
  }

  environment {
    PROJECT_ID = 'suresh-jenkins-project'
    IMAGE_NAME = 'my-app'
    IMAGE_TAG = "${BUILD_NUMBER}"
    IMAGE = "gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"
    CLUSTER = 'ci-cd-cluster'
    ZONE = 'asia-south1-c'
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('docker-gcloud') {
          script {
            sh 'docker --version'
            sh 'gcloud --version'

            sh 'gcloud auth configure-docker --quiet'
            sh "docker build -t $IMAGE ."
            sh "docker push $IMAGE"
          }
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('docker-gcloud') {
          script {
            sh "gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID"
            sh "kubectl set image deployment/my-app-deployment my-app-container=$IMAGE"
          }
        }
      }
    }
  }
}
