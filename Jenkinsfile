pipeline {
  agent {
    docker {
      image 'hashicorp/terraform:1.8.4'  // หรือ version ล่าสุด
      args '--entrypoint=""'
    }
  }

  environment {
    AWS_REGION = 'ap-southeast-1'
  }

  stages {
    stage('Terraform Init & Plan & apply(Create ECR)') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh '''
            echo START apply
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            terraform init
            terraform apply -auto-approve
            echo DONE apply
          '''
        }
      }
    }
    stage('Login to ECR') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh '''
            echo "===> Logging in to ECR"
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin \
              $(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text | cut -d '/' -f 1)
          '''
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        sh '''
          echo "===> Building Docker Image"
          ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)

          docker build -t $ECR_REPO_NAME:$IMAGE_TAG .
          docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
        '''
      }
    }
    stage('Push to ECR') {
      steps {
        sh '''
          echo "===> Pushing Docker Image to ECR"
          ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)

          docker push $ECR_URI:$IMAGE_TAG
        '''
      }
    }
  }
}
