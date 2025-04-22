# Build stage
FROM maven:3.6.3-openjdk-17-slim AS build

COPY pom.xml /app/
COPY src /app/src
RUN mvn -f /app/pom.xml clean package

# Run stage
FROM openjdk:17-jdk-slim

ENV SPRING_PROFILES_ACTIVE=dev
ENV SPRING_CONFIG_IMPORT=configserver:http://configserver:8071/
ENV EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eurekaserver:8070/eureka/

COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8072

ENTRYPOINT ["java", "-jar", "/app/app.jar"]