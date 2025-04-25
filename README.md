Primera prueba de CI/CD
# kubernetes-microservices-lab
Laboratorio 3: Despliegue de microservicios con Kubernetes y Minikube. Continuación del laboratorio anterior basado en Docker.

# Kubernetes Microservices Lab 🚀

Este repositorio contiene el **Laboratorio 3** de la serie de prácticas sobre microservicios, donde migramos una arquitectura basada en Docker Compose hacia un entorno orquestado por Kubernetes utilizando Minikube.

## 🔍 Descripción

En este laboratorio se dockerizó una aplicación Java basada en Spring Boot compuesta por los siguientes microservicios:

- Config Server
- Eureka Server
- Gateway Server
- Accounts Service
- Loans Service
- Cards Service

Cada servicio fue empaquetado en una imagen Docker y desplegado como un Deployment en Kubernetes, junto con su respectivo Service. Minikube fue utilizado como entorno de pruebas local.

## 🧪 Objetivos

- Construir imágenes Docker para cada microservicio.
- Publicar las imágenes en Docker Hub.
- Crear archivos de configuración YAML para Kubernetes (`Deployment`, `Service`, `ConfigMap`).
- Ejecutar y validar el sistema en Minikube.
- Probar la integración vía Gateway con Postman.

## 🛠️ Requisitos

- Docker
- Minikube
- kubectl
- Maven
- Java 17+

## 🚀 Cómo ejecutar el laboratorio

1. Clona este repositorio:
    ```bash
    git clone https://github.com/Cristixndr3s/kubernetes-microservices-lab.git
    cd kubernetes-microservices-lab
    ```

2. Inicia Minikube:
    ```bash
    minikube start
    ```

3. Aplica la configuración:
    ```bash
    kubectl apply -f k8s/
    ```

4. Verifica los pods:
    ```bash
    kubectl get pods
    ```

5. Expón el Gateway:
    ```bash
    minikube service gatewayserver-service
    ```

6. Prueba la API desde Postman (ruta de ejemplo):
    ```
    POST http://<minikube-ip>:<node-port>/bank/accounts/myCustomerDetails
    ```

## 🖼️ Arquitectura

```text
            +---------------------+
            |   Config Server     |
            +---------------------+

+-----------+         +--------------------+         +--------------------+
| Accounts  | <-----> |                    | <-----> |      Loans         |
| Service   |         |     Gateway        |         |      Service       |
+-----------+         |      Server        |         +--------------------+
                      |                    | <-----> +--------------------+
                      +--------------------+         |      Cards         |
                                                     |      Service       |
                                                     +--------------------+

            +---------------------+
            |   Eureka Server     |
            +---------------------+



📚 Repositorio anterior
Este laboratorio continúa el trabajo del Laboratorio 2 con Docker Compose.

🧑‍💻 Autor
Cristian Andrés López
