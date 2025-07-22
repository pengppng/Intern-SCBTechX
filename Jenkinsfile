pipeline {
  agent any

  environment {
    AWS_REGION = "ap-southeast-1"
    ECR_REPO   = "preecr"
    AWS_ACCOUNT_ID = "871762481972"
    ECR_URI    = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    CLUSTER_NAME = "preecr-cluster"
  }

  stages {
    // stage('Checkout') {
    //   steps {
    //     git 'https://github.com/pengppng/intern-techx-.git'
    //   }
    // }

    // stage('Build Docker Image') {
    //   steps {
    //     sh 'docker build -t $ECR_REPO .'
    //   }
    // }

    // stage('Login to ECRs') {
    //   steps {
    //     sh '''
    //       aws ecr get-login-password --region $AWS_REGION \
    //       | docker login --username AWS --password-stdin $ECR_URI
    //     '''
    //   }
    // }

    // stage('Tag and Push Image to ECR') {
    //   steps {
    //     sh '''
    //       docker tag $ECR_REPO:latest $ECR_URI:latest
    //       docker push $ECR_URI:latest
    //     '''
    //   }
    // }

    stage('Terraform Init and Apply') {
      steps {
        dir('terraform') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    // stage('Deploy to EKS') {
    //   steps {
    //     sh '''
    //       aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
    //       kubectl apply -f k8s-deployment.yaml
    //     '''
    //   }
    // }
  }
}
