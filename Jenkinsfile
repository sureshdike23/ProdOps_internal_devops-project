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
    IMAGE = "gcr.io/$PROJECT_ID/my-app:${env.BUILD_NUMBER}"
    CLUSTER = 'ci-cd-cluster'
    ZONE = 'asia-south1-c'
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('docker-gcloud') {
          withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
            sh '''
              gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
              gcloud auth configure-docker --quiet
              docker build -t $IMAGE .
              docker push $IMAGE
            '''
          }
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('docker-gcloud') {
          withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
            sh '''
              gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
              gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID
              kubectl set image deployment/my-app-deployment my-app-container=$IMAGE
            '''
          }
        }
      }
    }
  }
}
