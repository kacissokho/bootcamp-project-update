FROM amazoncorretto:17-alpine

WORKDIR /app

COPY target/paymybuddy.jar /app/paymybuddy.jar

CMD ["java", "-jar" , "paymybuddy.jar"]
