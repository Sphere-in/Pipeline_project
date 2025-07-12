pipeline{
    agent any

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

        stage ("Initialize Infrastructure") {
            steps{
                script {
                try {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'SSH_KEY_PATH', usernameVariable: 'SSH_USER')]) {

                        sh '''
                            chmod 400 $SSH_KEY_PATH
                            export TF_VAR_private_key_path=$SSH_KEY_PATH
                            terraform plan
                            terraform apply --auto-approve
                        '''
                    } 
                }
                catch (Exception e) {
                    echo "Error Occur in Terraform Stage "
                    currentBuild.result = 'Failure'
                    error "Infrastructure Failed ${e}"
                }
                }
            }  
        }

        stage('Configure with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'PEM_FILE', usernameVariable: 'SSH_USER')]) {

                    dir('Ansible') {
                        sh '''
                        chmod 400 $PEM_FILE

                        # Optional: dynamic inventory script can be used
                        echo "[web]" > hosts
                        echo "$(terraform -chdir=../terraform output -raw instance_ip)" ansible_user=ec2-user ansible_ssh_private_key_file=$PEM_FILE >> hosts
                        cd /Ansible
                        ansible-playbook -i hosts playbook.yml
                        '''
                    }
                }
            }
        }
        
        stage ("Install Dependencies"){
            steps{
                echo "Installing dependencies"
                sh '''
                if command -v node > dev/null 1>&2; then
                    echo "Node JS Installed"
                else
                    curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | bash -s 22
                    echo "Installing Nodejs"
                    apt install -y nodejs
                '''
            }
        }

        stage ("Build"){
            steps{
            echo "Building the application"
                script {
                try{
                sh '''
                    cp 
                    npm install
                    npm run build
                    sudo rm -rf /var/www/myapp
                    sudo mkdir -p /var/www/myapp
                    sudo cp -r .next public package.json /var/www/myapp/
                    cd /var/www/myapp/
                '''
                } catch (Exception e){
                    echo "Build Failure: ${e.getMessage()}"
                    currentBuild.result = 'Failure'
                    error "Build failed"
                } 
                }
            }
        }

        stage ("Run"){
            steps{
                echo "Running The application"
                script{
                try {
                    sh 'npm start'
                } catch (Exception e){
                    echo "Run Failure: ${e.getMessage()}"
                    currentBuild.result = 'Failure'
                    error "Run failed"
                }
                }
            }
        }
    }
}
    
