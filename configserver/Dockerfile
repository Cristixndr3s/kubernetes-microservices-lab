# Build stage
FROM maven:3.6.3-openjdk-17-slim AS build

COPY pom.xml /app/
COPY src /app/src
RUN mvn -f /app/pom.xml clean package

# Run stage
FROM openjdk:17-jdk-slim

RUN apt-get update && apt-get install -y curl

COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8071

ENTRYPOINT ["java", "-jar", "/app/app.jar"]