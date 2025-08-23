pipeline {
    agent none
    environment {
        DOCKERHUB_AUTH = credentials('dockerhub')
        ID_DOCKER = "${DOCKERHUB_AUTH_USR}"
        PORT_EXPOSED = "8090"
        IMAGE_NAME = "paymybuddy"
        IMAGE_TAG = "v1.4"
        DOCKER_USERNAME = 'kacissokho'
    }
    stages {
      stage ('Build image'){
          agent any
          steps {
            script {
                sh 'docker build -t ${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }
      }
     /* stage('Run container based on builded image and test') {
        agent any
        steps {
         script {
           sh '''
              echo "Clean Environment"
              docker rm -f $IMAGE_NAME || echo "container does not exist"
              docker-compose up -d
              sleep 5
              
           '''
         }
        }
      }
      
      stage('Clean Container'){
          agent any
          steps {
              script {
                  sh '''
                      docker stop $IMAGE_NAME
                      docker rm $IMAGE_NAME
                  '''
              }
          }
      }
      */
        
      stage('Login and Push Image on docker hub'){
          agent any
          steps {
              script {
                  sh '''
                    docker login -u $DOCKERHUB_AUTH_USR -p $DOCKERHUB_AUTH_PSW
                    docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                  '''
              }
          }
      }

      /* stage('Deploy in staging'){
          agent any
            environment {
                SERVER_IP = "35.175.226.181"
            }
          steps {
            sshagent(['SSH_AUTH_SERVER']) {
                sh '''
                    ssh -o StrictHostKeyChecking=no -l ubuntu $SERVER_IP "docker rm -f $IMAGE_NAME || echo 'All deleted'"
                    ssh -o StrictHostKeyChecking=no -l ubuntu $SERVER_IP "docker pull $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG || echo 'Image Download successfully'"
                    sleep 30
                    ssh -o StrictHostKeyChecking=no -l ubuntu $SERVER_IP "git clone https://github.com/kacissokho/bootcamp-project-update.git || echo 'le clone existe dejà"
                    ssh -o StrictHostKeyChecking=no -l ubuntu $SERVER_IP "cd /home/ubuntu/bootcamp-project-update && docker-compose up -d" 
                    sleep 5
                    
                '''
            }
          }
      }
      */
stage('Deploy in staging') {
  agent any
  environment {
    SERVER_IP = "35.175.226.181"
  }
  steps {
    sshagent(credentials: ['SSH_AUTH_SERVER']) {
      sh '''
        set -euo pipefail

        # Prépare ~/.ssh
        mkdir -p ~/.ssh
        chmod 0700 ~/.ssh

        # Ajoute la clé d'hôte (ne pas échouer si rien n'est renvoyé)
        ssh-keyscan -H -t rsa,ecdsa,ed25519 "${SERVER_IP}" >> ~/.ssh/known_hosts 2>/dev/null || true

        # Transfert du dossier deploy vers /home/ubuntu
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=~/.ssh/known_hosts \
            -r deploy ubuntu@"${SERVER_IP}":/home/ubuntu/

        # Prépare les commandes distantes (tout en chemins absolus)
        remote_prep="mkdir -p /home/ubuntu/deploy/{secrets,env}"

        remote_login="cd /home/ubuntu/deploy && echo \\"${DOCKERHUB_AUTH_PSW}\\" | docker login -u \\"${DOCKERHUB_AUTH_USR}\\" --password-stdin"

        remote_env="cd /home/ubuntu/deploy && \
          echo \\"IMAGE_VERSION=${DOCKERHUB_AUTH_USR}/${IMAGE_NAME}:${IMAGE_TAG}\\" > .env && \
          echo \\"${MYSQL_AUTH_PSW}\\" > secrets/db_password.txt && \
          echo \\"${MYSQL_AUTH_USR}\\" > secrets/db_user.txt && \
          { \
            echo \\"SPRING_DATASOURCE_URL=jdbc:mysql://paymybuddydb:3306/db_paymybuddy\\"; \
            echo \\"SPRING_DATASOURCE_PASSWORD=${MYSQL_AUTH_PSW}\\"; \
            echo \\"SPRING_DATASOURCE_USERNAME=${MYSQL_AUTH_USR}\\"; \
          } > env/paymybuddy.env"

        remote_deploy="cd /home/ubuntu/deploy && \
          (docker compose down || true) && \
          docker pull ${DOCKERHUB_AUTH_USR}/${IMAGE_NAME}:${IMAGE_TAG} && \
          docker compose up -d"

        # Exécution sur le serveur
        ssh -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=~/.ssh/known_hosts \
            ubuntu@"${SERVER_IP}" \
            bash -lc "$remote_prep && $remote_login && $remote_env && $remote_deploy"
      '''
    }
  }
}


      stage('Deploy in prod'){
          agent any
            environment {
                HOSTNAME_DEPLOY_PROD = "98.83.222.91"
            }
          steps {
            sshagent(credentials: ['SSH_AUTH_SERVER']) {
                sh '''
                    [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                    ssh-keyscan -t rsa,dsa ${HOSTNAME_DEPLOY_PROD} >> ~/.ssh/known_hosts
                    command1="docker login -u $DOCKERHUB_AUTH_USR -p $DOCKERHUB_AUTH_PSW"
                    command2="docker pull $DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG"
                    command3="docker rm -f alpinebootcampp || echo 'app does not exist'"
                    command4="docker compose up -d"
                    ssh -o StrictHostKeyChecking=no ubuntu@${HOSTNAME_DEPLOY_PROD} \
                        -o SendEnv=IMAGE_NAME \
                        -o SendEnv=IMAGE_TAG \
                        -o SendEnv=DOCKERHUB_AUTH_USR \
                        -o SendEnv=DOCKERHUB_AUTH_PSW \
                        -C "$command1 && $command2 && $command3 && $command4"
                '''
            }
          }
      }        

    }
}
