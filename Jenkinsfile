pipeline {
  agent any

  environment {
    PROJECT_ID = 'suresh-jenkins-project'
    IMAGE = "gcr.io/$PROJECT_ID/my-app:${env.BUILD_NUMBER}"
    CLUSTER = 'ci-cd-cluster'
    ZONE = 'asia-south1-c'
  }

  stages {
    stage('Clone Repo') {
      steps {
        git credentialsId: 'github-creds-id', url: 'https://github.com/sureshdike23/ProdOps_internal_devops-project.git'
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        sh 'gcloud auth configure-docker'
        sh 'docker build -t $IMAGE .'
        sh 'docker push $IMAGE'
      }
    }

    stage('Deploy to GKE') {
      steps {
        sh '''
        gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID
        kubectl set image deployment/my-app-deployment my-app-container=$IMAGE
        '''
      }
    }
  }
}
