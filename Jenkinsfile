pipeline{
    agent any
    environment {
            SSH_KEY_PATH = "${WORKSPACE}/id_rsa"
        }

    stages{
          

        stage ("checkout code"){
            steps{
                echo "Checking out code from SCM"
                checkout scm
            }
        }

        stage ("Initialize Git"){
            steps{
                echo "Initializing Git"
                sh '''
                if command -v git > /dev/null 2>&1; then
                    echo "Git is already installed"
                else
                    echo "Installing Git"
                    sudo apt-get update
                    sudo apt-get install -y git
                fi
                '''
            }
        }

        stage("Initialize Infrastructure") {
            steps {
                script {
                try {
                    withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                    file(credentialsId: 'ssh-private-key', variable: 'SSH_KEY_FILE',)
                    ]) {
                    dir('terraform') {
                        sh '''
                        echo "Path to key: $SSH_KEY_FILE"
                        echo "Path to key: $AWS_ACCESS_KEY_ID"
                        echo "Path to key: $AWS_SECRET_ACCESS_KEY"
                        cp $SSH_KEY_FILE $SSH_KEY_PATH
                        chmod 600 $SSH_KEY_PATH

                        terraform init
                        terraform plan
                        terraform apply --auto-approve 
                        '''
                    }
                    }
                } catch (Exception e) {
                    echo "Error Occurred in Terraform Stage"
                    currentBuild.result = 'FAILURE'
                    error "Infrastructure Failed: ${e}"
                }
                }
            }
        }


        stage('Configure with Ansible') {
            steps {
                script {
                    try {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'PEM_FILE', usernameVariable: 'SSH_USER')]) {

                    dir('Ansible') {
                        sh '''
                        chmod 400 $PEM_FILE

                        echo "[web]" > hosts
                        echo "$(terraform -chdir=../terraform output -raw instance_ip)" ansible_user=$SSH_USER ansible_ssh_private_key_file=$PEM_FILE >> hosts
                        ansible-playbook -i hosts playbook.yml -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

                        '''
                    }
                }
                    } catch (Exception e) {
                        sh 'terraform -chdir=../terraform destroy --auto-approve'
                        echo "Error Occurred in Ansible Stage"
                        currentBuild.result = 'FAILURE'
                        error "Ansible Configuration Failed: ${e}"
                    }
                }
            }
            }
        }

    }
}
    
