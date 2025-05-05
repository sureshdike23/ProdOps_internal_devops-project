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
    - name: gcp-key
      mountPath: /secret
      readOnly: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
  - name: gcp-key
    secret:
      secretName: jenkins-gcr-key
"""
    }
  }

  environment {
    PROJECT_ID = 'suresh-jenkins-project'
    IMAGE = "gcr.io/$PROJECT_ID/my-app:${env.BUILD_NUMBER}"
    CLUSTER = 'ci-cd-cluster'
    ZONE = 'asia-south1-c'
    GCP_KEY_FILE = '/secret/jenkins-gcr-key.json'
  }

  stages {
    stage('Authenticate') {
      steps {
        container('docker-gcloud') {
          sh 'gcloud auth activate-service-account --key-file=$GCP_KEY_FILE'
          sh 'gcloud config set project $PROJECT_ID'
          sh 'gcloud auth configure-docker --quiet'
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        container('docker-gcloud') {
          sh 'docker build -t $IMAGE .'
          sh 'docker push $IMAGE'
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('docker-gcloud') {
          sh '''
            gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID
            kubectl set image deployment/my-app my-app=$IMAGE
          '''
        }
      }
    }
  }
}
