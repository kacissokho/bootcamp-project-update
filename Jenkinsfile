pipeline {
  agent none

  environment {
    // Image locale
    DOCKER_USERNAME = 'kacissokho'
    IMAGE_NAME      = 'paymybuddy'
    IMAGE_TAG       = 'v1.4'
    PORT_EXPOSED    = '8090'     // pour le smoke test local (facultatif)

    // Apps Heroku
    STAGING    = 'paymybuddy-staging'
    PRODUCTION = 'paymybuddy-production'

    // Provisionner l'add-on JawsDB si absent (true/false)
    AUTO_PROVISION_JAWSDB = 'true'

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

    // --- facultatif : smoke test local ---
    // stage('Run container (smoke test)') { ... }
    // stage('Clean container de test') { ... }

    stage('Heroku: préparer & déployer STAGING') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
set -eu

heroku container:login

APP="${STAGING}"

# Créer l'app si besoin + passer sur stack container
heroku apps:info -a "$APP" >/dev/null 2>&1 || heroku create "$APP"
heroku stack:set container -a "$APP"

ensure_db() {
  local app="$1"
  local auto="${AUTO_PROVISION_JAWSDB}"

  # Lire JAWSDB_URL (peut renvoyer 0 même si vide)
  local jurl
  jurl="$(heroku config:get JAWSDB_URL -a "$app" || true)"

  if [ -z "$jurl" ] && [ "$auto" = "true" ]; then
    echo "JawsDB absent sur $app → provisioning…"
    heroku addons:create jawsdb:kitefin -a "$app"
    jurl="$(heroku config:get JAWSDB_URL -a "$app")"
  fi

  if [ -z "$jurl" ]; then
    echo "ERREUR: JAWSDB_URL est vide/inexistant sur $app. Abandon."
    exit 1
  fi

  # Parser JAWSDB_URL -> JDBC + creds
  local user pass host db
  user="$(echo "$jurl" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\1|')"
  pass="$(echo "$jurl" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\2|')"
  host="$(echo "$jurl" | sed -E 's|mysql://[^@]+@([^/]+)/.*|\\1|')"
  db="$(  echo "$jurl" | sed -E 's|.*/([^?]+).*|\\1|')"

  heroku config:set -a "$app" \
    SPRING_DATASOURCE_URL="jdbc:mysql://${host}/${db}?useSSL=false&serverTimezone=UTC" \
    SPRING_DATASOURCE_USERNAME="${user}" \
    SPRING_DATASOURCE_PASSWORD="${pass}"
}

ensure_db "$APP"

# Tag -> push -> release
docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${APP}/web
docker push registry.heroku.com/${APP}/web
heroku container:release -a "$APP" web

# S'assurer que le dyno démarre
heroku ps:scale web=1 -a "$APP" || true
heroku releases -a "$APP" | head -n 5
'''
      }
    }

    stage('Heroku: préparer & déployer PROD') {
      when { expression { env.GIT_BRANCH == 'origin/master' || env.BRANCH_NAME == 'master' } }
      agent any
      steps {
        sh '''
set -eu

heroku container:login

APP="${PRODUCTION}"

heroku apps:info -a "$APP" >/dev/null 2>&1 || heroku create "$APP"
heroku stack:set container -a "$APP"

ensure_db() {
  local app="$1"
  local auto="${AUTO_PROVISION_JAWSDB}"

  local jurl
  jurl="$(heroku config:get JAWSDB_URL -a "$app" || true)"

  if [ -z "$jurl" ] && [ "$auto" = "true" ]; then
    echo "JawsDB absent sur $app → provisioning…"
    heroku addons:create jawsdb:kitefin -a "$app"
    jurl="$(heroku config:get JAWSDB_URL -a "$app")"
  fi

  if [ -z "$jurl" ]; then
    echo "ERREUR: JAWSDB_URL est vide/inexistant sur $app. Abandon."
    exit 1
  fi

  local user pass host db
  user="$(echo "$jurl" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\1|')"
  pass="$(echo "$jurl" | sed -E 's|mysql://([^:]+):([^@]+)@.*|\\2|')"
  host="$(echo "$jurl" | sed -E 's|mysql://[^@]+@([^/]+)/.*|\\1|')"
  db="$(  echo "$jurl" | sed -E 's|.*/([^?]+).*|\\1|')"

  heroku config:set -a "$app" \
    SPRING_DATASOURCE_URL="jdbc:mysql://${host}/${db}?useSSL=false&serverTimezone=UTC" \
    SPRING_DATASOURCE_USERNAME="${user}" \
    SPRING_DATASOURCE_PASSWORD="${pass}"
}

ensure_db "$APP"

docker tag ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} registry.heroku.com/${APP}/web
docker push registry.heroku.com/${APP}/web
heroku container:release -a "$APP" web

heroku ps:scale web=1 -a "$APP" || true
heroku releases -a "$APP" | head -n 5
'''
      }
    }
  }

  post {
    always { echo 'Pipeline terminé.' }
  }
}
