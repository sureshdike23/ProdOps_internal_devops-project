pipeline {
    agent any
    environment {
        PROJECT_ID = 'suresh-jenkins-project'
        IMAGE_NAME = "gcr.io/$PROJECT_ID/ci-cd-demo"
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/sureshdike23/ProdOps_internal_devops-project.git'
            }
        }
        stage('Build & Push Docker Image') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GCP_KEY')]) {
                    sh '''
                        gcloud auth activate-service-account --key-file=$GCP_KEY
                        gcloud config set project $PROJECT_ID
                        gcloud auth configure-docker
                        docker build -t $IMAGE_NAME:latest .
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }
        stage('Deploy to Dev') {
            steps {
                sh 'kubectl apply -f k8s/dev.yaml'
            }
        }
        stage('Deploy to Test') {
            steps {
                sh 'kubectl apply -f k8s/test.yaml'
            }
        }
        stage('Deploy to Prod') {
            steps {
                sh 'kubectl apply -f k8s/prod.yaml'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}