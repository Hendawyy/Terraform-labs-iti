pipeline {
    agent any
    parameters {
        choice(name: 'server', choices: ["Dev", "Prod"], description: 'Select environment')
    }
    environment {
        AWS_ACCESS_KEY_ID=credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY=credentials('aws_secret_access_key')
    }
    stages {
        stage("Clone Git Repository") {
            steps {
                git(
                    url: "https://github.com/Hendawyy/Terraform-labs-iti.git",
                    branch: "master",
                    poll: true
                )
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    def env = params.server
                    def terraformVarsFile

                    if (env == 'Dev') {
                        terraformVarsFile = 'dev.tfvars'
                        sh 'terraform workspace new dev || true' 
                        sh 'terraform workspace select dev '
                    } else if (env == 'Prod') {
                        terraformVarsFile = 'prod.tfvars'
                        sh 'terraform workspace new prod || true' 
                        sh 'terraform workspace select prod '
                    }

                    sh "terraform plan -var-file=${terraformVarsFile}"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    def env = params.server
                    def terraformVarsFile

                    if (env == 'Dev') {
                        terraformVarsFile = 'dev.tfvars'
                        sh 'terraform workspace new dev || true' 
                        sh 'terraform workspace select dev '
                    } else if (env == 'Prod') {
                        terraformVarsFile = 'prod.tfvars'
                        sh 'terraform workspace new prod || true' 
                        sh 'terraform workspace select prod '
                    }
                    
                    
                    // sh "terraform import -var-file=${terraformVarsFile} aws_key_pair.tf-key-pairz tf-key-pairz "
                    // sh "terraform init"
                    sh "terraform apply -var-file=${terraformVarsFile} -auto-approve"
                }
            }
        }
    }
}
