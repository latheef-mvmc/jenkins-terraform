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
                git branch: 'terra-workspace',
                    url: 'https://github.com/latheef-mvmc/jenkins-terraform.git'
            }
        }

        stage('Fetch AWS Credentials') {
            steps {
                script {
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
                sh 'terraform init'
            }
        }

        stage('Workspace Setup') {
            steps {
                sh '''
                terraform workspace select ${ENV} || terraform workspace new ${ENV}
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan -var-file="${ENV}.tfvars"
                '''
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh '''
                        terraform apply -auto-approve -var-file="${ENV}.tfvars"
                        '''
                    } else if (params.ACTION == 'destroy') {
                        sh '''
                        terraform destroy -auto-approve -var-file="${ENV}.tfvars"
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS for ${params.ENV} (${params.ACTION})"
        }
        failure {
            echo "FAILED for ${params.ENV} (${params.ACTION})"
        }
    }
}
