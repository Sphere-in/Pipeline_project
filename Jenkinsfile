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
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-key', keyFileVariable: 'PEM_FILE', usernameVariable: 'SSH_USER')]) {

                    dir('Ansible') {
                        sh '''
                        chmod 400 $PEM_FILE

                        echo "[web]" > hosts
                        echo "$(terraform -chdir=../terraform output -raw instance_ip)" ansible_user=ec2-user ansible_ssh_private_key_file=$PEM_FILE >> hosts
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
    
