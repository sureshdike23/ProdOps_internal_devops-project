pipeline {
  agent {
    kubernetes {
      label 'gke-agent'
      defaultContainer 'gcloud'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: gcloud
      image: gcr.io/cloud-builders/gcloud
      command: ['cat']
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
        container('gcloud') {
          sh '''
            gcloud auth activate-service-account --key-file=$CREDENTIALS_PATH
            gcloud config set project $PROJECT_ID
          '''
        }
      }
    }

    stage('Build & Push Image with Cloud Build') {
      steps {
        container('gcloud') {
          sh '''
            gcloud builds submit --tag gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('gcloud') {
          sh '''
            gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID
            kubectl set image deployment/$IMAGE_NAME $IMAGE_NAME=gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }
  }
}
