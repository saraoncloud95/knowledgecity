pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VERSION = '1.5.0'
        // Set AWS credentials in Jenkins (env vars or withCredentials)
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform --version'
                sh 'terraform init -input=false'
            }
        }

        stage('Lint & Static Analysis') {
            steps {
                sh 'tflint --init'
                sh 'tflint'
                sh 'checkov -d . --quiet'
            }
        }

        stage('Terraform Format & Validate') {
            steps {
                sh 'terraform fmt -check -recursive'
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
            }
        }

        stage('Terraform Apply (Manual Approval)') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Approve to apply Terraform changes to AWS?'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        failure {
            mail to: 'devops@knowledgecity.com',
                 subject: "Jenkins Pipeline Failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}]",
                 body: "Check Jenkins for details: ${env.BUILD_URL}"
        }
    }
}