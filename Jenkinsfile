pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  namespace: ci-cd
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
    - name: gcp-key
      mountPath: /secrets
      readOnly: true
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: gcp-key
    secret:
      secretName: jenkins-gcr-key
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
    GOOGLE_APPLICATION_CREDENTIALS = '/secrets/jenkins-gcr-key.json'
  }

  stages {
    stage('Authenticate & Build') {
      steps {
        container('docker-gcloud') {
          sh '''
            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
            gcloud auth configure-docker --quiet
            docker build -t $IMAGE .
            docker push $IMAGE
          '''
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        container('docker-gcloud') {
          sh '''
            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
            gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID
            kubectl set image deployment/my-app my-app=$IMAGE
          '''
        }
      }
    }
  }
}
