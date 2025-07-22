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
        withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            terraform init
            terraform apply -auto-approve
          '''
        }
      }
    }

    stage('Login to ECR') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text | cut -d '/' -f 1)
          '''
        }
      }
    }
  }
}
