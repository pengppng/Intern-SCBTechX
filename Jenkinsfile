pipeline {
  agent any

  environment {
    AWS_REGION    = 'ap-southeast-1'
    ECR_REPO_NAME = 'preecr'
    IMAGE_TAG     = 'latest'
  }

  stages {
    stage('Install AWS CLI & Terraform') {
  steps {
    sh '''
      echo "===> Installing AWS CLI & Terraform"
      apk add --no-cache curl unzip python3 py3-pip bash aws-cli

      curl -Lo terraform.zip https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_amd64.zip
      unzip terraform.zip
      mv terraform /usr/local/bin/
      terraform version
      aws --version
    '''
  }
}


    stage('Terraform Init & Apply (Create ECR)') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh '''
            echo "===> START Terraform Apply"

            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            terraform init
            terraform apply -auto-approve \
              -var="repository_name=$ECR_REPO_NAME" \
              -var="lifecycle_policy=lifecycle-policy.json"

            echo "===> DONE Terraform Apply"
          '''
        }
      }
    }

    stage('Build & Push Docker to ECR') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'aws-credentials',
            usernameVariable: 'AWS_ACCESS_KEY_ID',
            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
          )
        ]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
            ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

            echo "===> Logging into ECR"
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

            echo "===> Building Docker image"
            docker build -t $ECR_REPO_NAME:$IMAGE_TAG .

            echo "===> Tagging Docker image"
            docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI/$ECR_REPO_NAME:$IMAGE_TAG

            echo "===> Pushing Docker image"
            docker push $ECR_URI/$ECR_REPO_NAME:$IMAGE_TAG

            echo "===> DONE Docker Push"
          '''
        }
      }
    }
  }
}
