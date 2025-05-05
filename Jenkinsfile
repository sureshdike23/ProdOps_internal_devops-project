pipeline {
    agent any
    environment {
        PROJECT_ID = 'suresh-jenkins-project'
        IMAGE_NAME = "gcr.io/${PROJECT_ID}/ci-cd-demo"
        IMAGE_TAG = "${env.BUILD_NUMBER ?: 'latest'}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        CLUSTER_NAME = 'ci-cd-cluster'
        CLUSTER_ZONE = 'asia-south1-c'
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
                        echo "[STEP] Authenticating with GCP..."
                        gcloud auth activate-service-account --key-file=$GCP_KEY
                        gcloud config set project $PROJECT_ID
                        gcloud auth configure-docker

                        echo "[STEP] Building Docker image: $FULL_IMAGE"
                        docker build -t $FULL_IMAGE .

                        echo "[STEP] Pushing Docker image to GCR"
                        docker push $FULL_IMAGE
                    '''
                }
            }
        }
        stage('Configure kubectl') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GCP_KEY')]) {
                    sh '''
                        echo "[STEP] Getting GKE cluster credentials..."
                        gcloud auth activate-service-account --key-file=$GCP_KEY
                        gcloud config set project $PROJECT_ID
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE
                    '''
                }
            }
        }
        stage('Deploy to Dev') {
            steps {
                sh '''
                    echo "[STEP] Deploying to Dev..."
                    sed "s|__IMAGE__|$FULL_IMAGE|" k8s/dev.yaml | kubectl apply -f -
                '''
            }
        }
        stage('Deploy to Test') {
            steps {
                sh '''
                    echo "[STEP] Deploying to Test..."
                    sed "s|__IMAGE__|$FULL_IMAGE|" k8s/test.yaml | kubectl apply -f -
                '''
            }
        }
        stage('Deploy to Prod') {
            steps {
                sh '''
                    echo "[STEP] Deploying to Prod..."
                    sed "s|__IMAGE__|$FULL_IMAGE|" k8s/prod.yaml | kubectl apply -f -
                '''
            }
        }
    }
    post {
        always {
            echo '[CLEANUP] Cleaning workspace...'
            cleanWs()
        }
    }
}
