pipeline {
    agent any

    triggers {
        githubPush()
    }

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'qa', 'prod'],
            description: 'Select Environment'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        SECRET_NAME = 'aws-jenkins-sec-keys'
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Cloning terra-workspace branch..."
                git branch: 'terra-workspace',
                    url: 'https://github.com/latheef-mvmc/jenkins-terraform.git'
            }
        }

        stage('Fetch AWS Credentials') {
            steps {
                script {
                    echo "Fetching AWS credentials from Secrets Manager..."

                    def secret = sh(
                        script: """
                        aws secretsmanager get-secret-value \
                        --secret-id ${SECRET_NAME} \
                        --region ${AWS_DEFAULT_REGION} \
                        --query SecretString \
                        --output text
                        """,
                        returnStdout: true
                    ).trim()

                    def json = readJSON text: secret

                    env.AWS_ACCESS_KEY_ID = json.access_key
                    env.AWS_SECRET_ACCESS_KEY = json.secret_key
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                echo "Initializing Terraform..."
                terraform init
                '''
            }
        }

        stage('Workspace Setup') {
            steps {
                sh '''
                echo "Using workspace: ${ENV}"

                terraform workspace list

                terraform workspace select ${ENV} || terraform workspace new ${ENV}

                terraform workspace show
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                echo "Planning for ${ENV}..."
                terraform plan -var-file="${ENV}.tfvars"
                '''
            }
        }

        stage('Approval for PROD') {
            when {
                expression { params.ENV == 'prod' }
            }
            steps {
                input message: "Do you want to deploy to PROD?"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                echo "Applying Terraform for ${ENV}..."
                terraform apply -auto-approve -var-file="${ENV}.tfvars"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment SUCCESS for ${ENV}"
        }
        failure {
            echo "❌ Deployment FAILED for ${ENV}"
        }
        always {
            echo "Pipeline execution completed."
        }
    }
}
