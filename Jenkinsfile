pipeline {
  agent none
  environment {
    // Image Docker locale
    DOCKER_USERNAME = 'kacissokho'
    IMAGE_NAME      = 'paymybuddy'
    IMAGE_TAG       = 'v1.4'
    PORT_EXPOSED    = '8090'   // Port utilisé pour le run de test local

    // Apps Heroku (à adapter si nécessaire)
    STAGING    = 'paymybuddy-staging'
    PRODUCTION = 'paymybuddy-production'
  }

  stages {

    stage('Build image') {
      agent any
      steps {
        sh 'docker build -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

   /* stage('Run container (smoke test)') {
      agent any
      steps {
        sh '''
          set -eu
          docker rm -f ${IMAGE_NAME} 2>/dev/null || true
          docker run --name ${IMAGE_NAME} -d -p ${PORT_EXPOSED}:${PORT_EXPOSED} \
            -e PORT=${PORT_EXPOSED} ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}

          # Test basique : page d'accueil répond (HTTP 2xx)
          # Si ton app a une route santé, remplace par /actuator/health ou similaire.
          for i in $(seq 1 10); do
            if curl -fsS "http://127.0.0.1:${PORT_EXPOSED}/" >/dev/null; then
              echo "Smoke test OK"; exit 0
            fi
            echo "En attente du service... ($i/10)"; sleep 2
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
*/
    stage('Push + Release sur Heroku (staging)') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }
      steps {
        sh '''
          set -eu

          # Connexion au registre Heroku
          heroku container:login

          # Crée l’app si elle n’existe pas (idempotent)
          heroku apps:info -a "${STAGING}" >/dev/null 2>&1 || heroku create "${STAGING}"
           # <<< FIX >>> bascule sur le stack container
          heroku stack:set container -a "${STAGING}"

          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${STAGING}/web
          docker push registry.heroku.com/${STAGING}/web
          heroku container:release -a "${STAGING}" web

          # Tag l'image locale vers le registre Heroku et pousse cette image (évite un rebuild)
          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${STAGING}/web
          docker push registry.heroku.com/${STAGING}/web

          # Release
          heroku container:release -a "${STAGING}" web
        '''
      }
    }

    stage('Push + Release sur Heroku (production)') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }
      steps {
        sh '''
          set -eu

          heroku container:login
          heroku apps:info -a "${PRODUCTION}" >/dev/null 2>&1 || heroku create "${PRODUCTION}"
          # <<< FIX >>> bascule sur le stack container
          heroku stack:set container -a "${PRODUCTION}"

          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${PRODUCTION}/web
          docker push registry.heroku.com/${PRODUCTION}/web
          heroku container:release -a "${PRODUCTION}" web

          docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${PRODUCTION}/web
          docker push registry.heroku.com/${PRODUCTION}/web

          heroku container:release -a "${PRODUCTION}" web
        '''
      }
    }
  }
}
