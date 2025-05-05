pipeline {
  agent {
    kubernetes {
      label 'gke-agent'
      defaultContainer 'kubectl'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kubectl
      image: google/cloud-sdk:latest
      command:
        - cat
      tty: true
      volumeMounts:
        - name: gcp-key
          mountPath: /secrets
          readOnly: true
  volumes:
    - name: gcp-key
      secret:
        secretName: jenkins-gcr-key
"""
    }
  }

  environment {
    PROJECT_ID = 'suresh-jenkins-project'
    IMAGE_NAME = 'my-app'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    CLUSTER_NAME = 'ci-cd-cluster'
    CLUSTER_ZONE = 'asia-south1-c'
    CREDENTIALS_PATH = '/secrets/jenkins-gcr-key.json'
  }

  stages {
    stage('Authenticate with GCP') {
      steps {
        container('kubectl') {
          sh '''
            gcloud auth activate-service-account --key-file=$CREDENTIALS_PATH
            gcloud config set project $PROJECT_ID
          '''
        }
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        container('kubectl') {
          sh '''
            docker build -t gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG .
            docker push gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('kubectl') {
          sh '''
            gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID
            kubectl set image deployment/$IMAGE_NAME $IMAGE_NAME=gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }
}
