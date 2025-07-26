### PayMyBuddy Application
Overview
The PayMyBuddy application is a Java-based application that uses MySQL as its backend database. 

This project uses Docker and Docker Compose to define and orchestrate the environment.

### prerequisites:

Install docker and docker compose

Clone the application: git clone GitHub - kacissokho/bootcamp-project-update

Move to the cloned repos: cd bootcamp-project-update/mini-projet-docker

### Components:
paymybuddy: Java application running on amazoncorretto:17-alpine

paymybuddydb: MySQL database server, Stores users, transactions, and account details

### Networks
paymybuddynetwork: bridge type

### Volumes
db_paymybuddy: Persistent volume used by MySQL to store database data.

### Environment Variables
These variables are defined in the .env file:

SPRING_DATASOURCE_USERNAME: Username for the database connection

SPRING_DATASOURCE_PASSWORD: Password for the database connection

SPRING_DATASOURCE_URL: JDBC URL for connecting to the MySQL database

 #### Database Initialization:
  
The database schema is initialized using the initdb directory, which contains SQL scripts to set up    the required tables and initial data. 


### Build :

Navigate to the directory where the Dockerfile is located and build the image:

Build the image with the command: docker build -t paymybuddy:v1 . 

check the images with the command: docker images


!(images/image-20250726-102559.png)


Docker Registry
Deploy a private registry and store the built images in it.

image-20250726-112448.png
image-20250726-112540.png
image-20250726-112321.png
image-20250726-112223.png

Access Website
Open your browser to access the application:
image-20250726-113057.png
image-20250726-115828.png



Access website :
>>>>>>> 8a4cc18a6c406d3fc8e298b8de202405eb230922


image-20250726-115951.png
