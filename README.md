# Microservices Template

This is a production-ready template for building microservices applications with Spring Boot and Spring Cloud. It provides the essential infrastructure services (Config, Discovery, and Gateway) pre-configured and ready to use.

## 🏗 Architecture

The template includes the following core components:

1.  **Config Service** (`config-service`): Centralized configuration server.
2.  **Discovery Service** (`discovery-service`): A Eureka Server that acts as a service registry. All microservices register themselves here.
3.  **Gateway Service** (`gateway-service`): An API Gateway based on Spring Cloud Gateway. It provides a single entry point to the system and dynamically routes requests to registered services.

## 🚀 Getting Started

### Prerequisites

*   Java 21
*   Maven 3.8+

### Running the Infrastructure

1.  **Start the Config Service**:
    ```bash
    cd config-service
    ../mvnw spring-boot:run
    ```
    The Config Server will start on port 8888.

2.  **Start the Discovery Service**:
    ```bash
    cd discovery-service
    ../mvnw spring-boot:run
    ```
    Access the Eureka Dashboard at [http://localhost:8761](http://localhost:8761).

3.  **Start the Gateway Service**:
    ```bash
    cd gateway-service
    ../mvnw spring-boot:run
    ```
    The Gateway will be available at [http://localhost:9999](http://localhost:9999).

## 📦 Adding a New Microservice

See [docs/adding-new-service.md](docs/adding-new-service.md) for a step-by-step guide on how to add a new business microservice to this architecture.

## ⚙️ Configuration

### Global Configuration
The root `pom.xml` manages the versions of Spring Boot and Spring Cloud. Update the properties in the root POM to upgrade dependencies for all services.

### Service Configuration
*   **Config Service**: Configured in `config-service/src/main/resources/application.properties`.
*   **Discovery Service**: Configured in `discovery-service/src/main/resources/application.properties`.
*   **Gateway Service**: Configured in `gateway-service/src/main/resources/application.properties`.

## 🤝 Contributing

Feel free to fork this repository and submit pull requests to improve the template.
