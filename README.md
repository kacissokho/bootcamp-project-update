# PayMyBuddy Application

## Overview

The PayMyBuddy application is a Java-based application that uses MySQL as its backend database.

This project uses Docker and Docker Compose to define and orchestrate the environment.

---

## Prerequisites

- Install Docker
- Install Docker Compose

Clone the application :

```bash
git clone https://github.com/kacissokho/bootcamp-project-update
cd bootcamp-project-update/mini-projet-docker
Architecture
Components
paymybuddy: Java application running on amazoncorretto:17-alpine

paymybuddydb: MySQL database server (stores users, transactions, and account details)

Networks
paymybuddynetwork: bridge type

Volumes
db_paymybuddy: Persistent volume used by MySQL to store database data

Variables
These variables are in the .env file locally:

SPRING_DATASOURCE_USERNAME: Username for the database connection

SPRING_DATASOURCE_PASSWORD: Password for the database connection

SPRING_DATASOURCE_URL: JDBC URL for connecting to the MySQL database

Database Initialization
The database schema is initialized using the initdb/ directory, which contains SQL scripts to set up the required tables and initial data.

Build
Go to the directory where the Dockerfile is located and build the image:

bash
Copy
Edit
docker build -t paymybuddy:v1 .
docker images


Docker Registry
Deploy a private registry and store the built images in it.






Infrastructure as Code
Go to the directory where the docker-compose.yml is located.

Run the services:

bash
Copy
Edit
docker-compose up -d



Access Website


yaml
Copy
Edit

---

✅ **À faire maintenant :**
1. Assure-toi que **toutes les images `.png` sont dans le même dossier** que ton `README.md`.
2. Commit et push ton `README.md` et tes images dans ton dépôt GitHub ou GitLab.

Souhaites-tu que je te génère ce fichier prêt à copier-coller ?







You said:
oui


ChatGPT said:
Voici ton README.md prêt à copier-coller avec les images intégrées proprement en Markdown :

markdown
Copy
Edit
# PayMyBuddy Application

## Overview

The PayMyBuddy application is a Java-based application that uses MySQL as its backend database.

This project uses Docker and Docker Compose to define and orchestrate the environment.

---

## Prerequisites

- Install Docker
- Install Docker Compose

Clone the application:

```bash
git clone https://github.com/kacissokho/bootcamp-project-update
cd bootcamp-project-update/mini-projet-docker
Architecture
Components
paymybuddy: Java application running on amazoncorretto:17-alpine

paymybuddydb: MySQL database server (stores users, transactions, and account details)

Networks
paymybuddynetwork: bridge type

Volumes
db_paymybuddy: Persistent volume used by MySQL to store database data

Environment Variables
These variables are defined in the .env file:

SPRING_DATASOURCE_USERNAME: Username for the database connection

SPRING_DATASOURCE_PASSWORD: Password for the database connection

SPRING_DATASOURCE_URL: JDBC URL for connecting to the MySQL database

Database Initialization
The database schema is initialized using the initdb/ directory, which contains SQL scripts to set up the required tables and initial data.

Build
Navigate to the directory where the Dockerfile is located and build the image:

bash
Copy
Edit
docker build -t paymybuddy:v1 .
docker images


Docker Registry
Deploy a private registry and store the built images in it.






Infrastructure as Code
Navigate to the directory containing the docker-compose.yml file.

Start the services:

bash
Copy
Edit
docker-compose up -d



Access Website
Open your browser to access the application:


