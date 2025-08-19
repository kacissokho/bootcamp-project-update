pipeline {
  agent any

  environment {
    DOCKERHUB_AUTH = credentials('dockerhub')   // => DOCKERHUB_AUTH_USR / DOCKERHUB_AUTH_PSW
    MYSQL_AUTH     = credentials('MYSQL_AUTH')  // => MYSQL_AUTH_USR / MYSQL_AUTH_PSW
    IMAGE_NAME     = 'paymybuddy'
    IMAGE_TAG      = 'latest'
    HOSTNAME_DEPLOY_STAGING = '54.92.175.115'
    HOSTNAME_DEPLOY_PROD    = '54.226.144.55'
  }

  options {
    timestamps()
    ansiColor('xterm')
    skipDefaultCheckout(true)
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Push image') {
      // Utilise une image qui contient le CLI Docker + buildx et monte la socket
      agent {
        docker {
          image 'docker:24-cli'
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        // IMPORTANT : block shell en quotes simples pour éviter l'interpolation Groovy des secrets
        sh '''
          set -euxo pipefail
          docker version
          export DOCKER_BUILDKIT=1

          echo "$DOCKERHUB_AUTH_PSW" | docker login -u "$DOCKERHUB_AUTH_USR" --password-stdin

          docker build --progress=plain \
            --secret id=db_user,env=SPRING_DATASOURCE_USER \
            --secret id=db_password,env=SPRING_DATASOURCE_PASSWORD \
            -t "$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG" .

          docker push "$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG"
        '''
      }
    }

    stage('Deploy in staging') {
      when { anyOf { branch 'master'; branch 'main' } }
      steps {
        sshagent(credentials: ['SSH_AUTH_SERVER']) {
          sh '''
            set -euxo pipefail
            mkdir -p ~/.ssh && chmod 0700 ~/.ssh
            ssh-keyscan -t rsa,ecdsa,ed25519 "$HOSTNAME_DEPLOY_STAGING" >> ~/.ssh/known_hosts
            scp -r deploy ubuntu@"$HOSTNAME_DEPLOY_STAGING":/home/ubuntu/

            # On exécute tout côté remote dans un bash -s (et on alimente les secrets via env)
            ssh ubuntu@"$HOSTNAME_DEPLOY_STAGING" bash -s <<'REMOTE'
              set -euxo pipefail
              cd deploy
              echo "$DOCKERHUB_AUTH_PSW" | docker login -u "$DOCKERHUB_AUTH_USR" --password-stdin
              echo "IMAGE_VERSION=$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG" > .env
              mkdir -p secrets
              printf "%s" "$MYSQL_AUTH_PSW" > secrets/db_password.txt
              printf "%s" "$MYSQL_AUTH_USR" > secrets/db_user.txt
              COMPOSE="docker compose"; $COMPOSE version >/dev/null 2>&1 || COMPOSE="docker-compose"
              $COMPOSE down || true
              docker pull "$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG"
              $COMPOSE up -d
            REMOTE
          '''
        }
      }
    }

    stage('Test Staging') {
      when { anyOf { branch 'master'; branch 'main' } }
      steps {
        // Pas d’apt-get : on utilise une image curl éphémère
        sh '''
          set -euxo pipefail
          sleep 15
          docker run --rm curlimages/curl -fsS "http://$HOSTNAME_DEPLOY_STAGING:8080"
        '''
      }
    }

    stage('Deploy in prod') {
      when { anyOf { branch 'master'; branch 'main' } }
      steps {
        sshagent(credentials: ['SSH_AUTH_SERVER']) {
          sh '''
            set -euxo pipefail
            mkdir -p ~/.ssh && chmod 0700 ~/.ssh
            ssh-keyscan -t rsa,ecdsa,ed25519 "$HOSTNAME_DEPLOY_PROD" >> ~/.ssh/known_hosts
            scp -r deploy ubuntu@"$HOSTNAME_DEPLOY_PROD":/home/ubuntu/

            ssh ubuntu@"$HOSTNAME_DEPLOY_PROD" bash -s <<'REMOTE'
              set -euxo pipefail
              cd deploy
              echo "$DOCKERHUB_AUTH_PSW" | docker login -u "$DOCKERHUB_AUTH_USR" --password-stdin
              echo "IMAGE_VERSION=$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG" > .env
              mkdir -p secrets
              printf "%s" "$MYSQL_AUTH_PSW" > secrets/db_password.txt
              printf "%s" "$MYSQL_AUTH_USR" > secrets/db_user.txt
              COMPOSE="docker compose"; $COMPOSE version >/dev/null 2>&1 || COMPOSE="docker-compose"
              $COMPOSE down || true
              docker pull "$DOCKERHUB_AUTH_USR/$IMAGE_NAME:$IMAGE_TAG"
              $COMPOSE up -d
            REMOTE
          '''
        }
      }
    }

    stage('Test Prod') {
      when { anyOf { branch 'master'; branch 'main' } }
      steps {
        sh '''
          set -euxo pipefail
          sleep 15
          docker run --rm curlimages/curl -fsS "http://$HOSTNAME_DEPLOY_PROD:8080"
        '''
      }
    }
  }
}
