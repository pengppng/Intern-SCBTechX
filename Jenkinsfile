pipeline {
  agent {
    docker {
      image 'amazon/aws-cli:2.15.20' // มี AWS CLI ให้พร้อม
    }
  }

  environment {
    AWS_REGION = 'ap-southeast-1'
  }

  stages {
    stage('Terraform Init & Apply (ECR Only)') {
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
  }
}
