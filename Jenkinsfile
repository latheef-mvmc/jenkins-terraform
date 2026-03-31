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

        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Terraform Action'
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
                    echo "Fetching AWS credentials..."

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
                sh """
                echo "Selecting workspace: ${params.ENV}"
                terraform workspace select ${params.ENV} || terraform workspace new ${params.ENV}
                terraform workspace show
                """
            }
        }

        stage('Terraform Plan') {
            steps {
                sh """
                echo "Running plan for ${params.ENV}"
                terraform plan -var-file="${params.ENV}.tfvars"
                """
            }
        }

        stage('Terraform Action (Apply / Destroy)') {
            steps {
                script {
                    echo "Action: ${params.ACTION}"

                    if (params.ACTION == 'apply') {

                        sh """
                        terraform apply -auto-approve -var-file="${params.ENV}.tfvars"
                        """

                    } else if (params.ACTION == 'destroy') {

                        // Safety confirmation
                        // input message: " Confirm DESTROY for ${params.ENV}?"

                        sh """
                        terraform destroy -auto-approve -var-file="${params.ENV}.tfvars"
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo " SUCCESS: ${params.ACTION} completed for ${params.ENV}"
        }
        failure {
            echo " FAILED: ${params.ACTION} failed for ${params.ENV}"
        }
        always {
            echo "Pipeline execution completed."
        }
    }
}
