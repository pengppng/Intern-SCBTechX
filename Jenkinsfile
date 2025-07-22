pipeline {
  agent any

  environment {
    AWS_REGION = 'ap-southeast-1'
    ECR_REPO_NAME = 'preecr'
    IMAGE_TAG = 'latest'
  }

  stages {
    stage('Terraform Init & Apply (Create ECR)') {
      steps {
        sh '''
          terraform init
          terraform apply -auto-approve
        '''
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text | cut -d '/' -f 1)
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)
          docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
          docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)
          docker push $ECR_URI:$IMAGE_TAG
        '''
      }
    }
  }
}
