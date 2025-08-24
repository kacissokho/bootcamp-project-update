pipeline {
  agent none

  environment {
    // Image locale
    DOCKER_USERNAME = 'kacissokho'
    IMAGE_NAME      = 'paymybuddy'
    IMAGE_TAG       = 'v1.4'
    PORT_EXPOSED    = '8090'     // utilisé pour le smoke test local

    // Apps Heroku
    STAGING    = 'paymybuddy-staging'
    PRODUCTION = 'paymybuddy-production'

    // Clé API Heroku (Credentials > Secret text, id: heroku_api_key)
    HEROKU_API_KEY = credentials('heroku_api_key')
  }

  stages {

    stage('Checkout') {
      agent any
      steps { checkout scm }
    }

    stage('Build image') {
      agent any
      steps {
        sh 'docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Run container (smoke test)') {
      agent any
      steps {
        sh '''
          set -eu
          docker rm -f ${IMAGE_NAME} 2>/dev/null || true
          # IMPORTANT : l'app doit écouter sur $PORT (voir note Dockerfile ci-dessous)
          docker run --name ${IMAGE_NAME} -d \
            -p ${PORT_EXPOSED}:${PORT_EXPOSED} \
            -e PORT=${PORT_EXPOSED} \
            ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

          # Smoke test simple (remplace "/" par /actuator/health si dispo)
          for i in $(seq 1 15); do
            if curl -fsS "http://127.0.0.1:${PORT_EXPOSED}/" >/dev/null; then
              echo "Smoke test OK"; exit 0
            fi
            echo "En attente du service... ($i/15)"; sleep 2
          done
          echo "Smoke test FAILED"; exit 1
        '''
      }
    }

    stage('Clean container de test') {
      agent any
      steps {
        sh '''
          docker stop ${IMAGE_NAME} 2>/dev/null || true
          docker rm   ${IMAGE_NAME} 2>/dev/null || true
        '''
      }
    }

    stage('Heroku: préparer STAGING') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
          set -eu
          heroku container:login

          # Créer l'app si besoin + passer sur le stack container
          heroku apps:info -a "${STAGING}" >/dev/null 2>&1 || heroku create "${STAGING}"
          heroku stack:set container -a "${STAGING}"

          # (Optionnel) Mapper JAWSDB_URL -> variables Spring si l'add-on existe
          if heroku config:get JAWSDB_URL -a "${STAGING}" >/dev/null 2>&1; then
            JURL=$(heroku config:get JAWSDB_URL -a "${STAGING}")
            USER=$(echo "$JURL" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\1|')
            PASS=$(echo "$JURL" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\2|')
            HOST=$(echo "$JURL" | sed -E 's|mysql://[^@]+@([^/]+)/.*|\\1|')
            DB=$(  echo "$JURL" | sed -E 's|.*/([^?]+).*|\\1|')
            heroku config:set -a "${STAGING}" \
              SPRING_DATASOURCE_URL="jdbc:mysql://$HOST/$DB?useSSL=false&serverTimezone=UTC" \
              SPRING_DATASOURCE_USERNAME="$USER" \
              SPRING_DATASOURCE_PASSWORD="$PASS" || true
          fi
        '''
      }
    }

    stage('Deploy STAGING') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
          set -eu
          # Tag -> push -> release
          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${STAGING}/web
          docker push registry.heroku.com/${STAGING}/web
          heroku container:release -a "${STAGING}" web

          # S'assurer que dyno démarre
          heroku ps:scale web=1 -a "${STAGING}" || true
          heroku releases -a "${STAGING}" | head -n 5
        '''
      }
    }

    stage('Heroku: préparer PROD') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
          set -eu
          heroku container:login
          heroku apps:info -a "${PRODUCTION}" >/dev/null 2>&1 || heroku create "${PRODUCTION}"
          heroku stack:set container -a "${PRODUCTION}"

          if heroku config:get JAWSDB_URL -a "${PRODUCTION}" >/dev/null 2>&1; then
            JURL=$(heroku config:get JAWSDB_URL -a "${PRODUCTION}")
            USER=$(echo "$JURL" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\1|')
            PASS=$(echo "$JURL" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\2|')
            HOST=$(echo "$JURL" | sed -E 's|mysql://[^@]+@([^/]+)/.*|\\1|')
            DB=$(  echo "$JURL" | sed -E 's|.*/([^?]+).*|\\1|')
            heroku config:set -a "${PRODUCTION}" \
              SPRING_DATASOURCE_URL="jdbc:mysql://$HOST/$DB?useSSL=false&serverTimezone=UTC" \
              SPRING_DATASOURCE_USERNAME="$USER" \
              SPRING_DATASOURCE_PASSWORD="$PASS" || true
          fi
        '''
      }
    }

    stage('Deploy PROD') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
          set -eu
          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${PRODUCTION}/web
          docker push registry.heroku.com/${PRODUCTION}/web
          heroku container:release -a "${PRODUCTION}" web
          heroku ps:scale web=1 -a "${PRODUCTION}" || true
          heroku releases -a "${PRODUCTION}" | head -n 5
        '''
      }
    }
  }

  post {
    always {
      echo 'Pipeline terminé.'
    }
  }
}
