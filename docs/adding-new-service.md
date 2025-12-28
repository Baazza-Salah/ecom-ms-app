# Adding a New Microservice

Follow these steps to add a new microservice to the application.

## 1. Create the Module

Create a new Maven module in the root directory. You can use the Spring Initializr or copy an existing structure.

### Using Spring Initializr
1.  Go to [start.spring.io](https://start.spring.io/).
2.  Select:
    *   Project: Maven
    *   Language: Java
    *   Spring Boot: 3.5.7 (or matching the root POM)
    *   Group: `com.microservices.template` (or your group)
    *   Artifact: `your-service-name`
    *   Dependencies: `Eureka Discovery Client`, `Config Client`, `Spring Web`, `Actuator`, `Lombok` (optional).
3.  Generate and unzip the project into the root folder.

## 2. Update the Root POM

Add your new module to the `<modules>` section in the root `pom.xml`:

```xml
<modules>
    <module>discovery-service</module>
    <module>gateway-service</module>
    <module>your-service-name</module> <!-- Add this line -->
</modules>
```

## 3. Configure the New Service POM

Update your service's `pom.xml` to inherit from the parent project:

```xml
<parent>
    <groupId>com.microservices.template</groupId>
    <artifactId>microservices-template</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</parent>
```

Remove the `<groupId>` and `<version>` if they are the same as the parent.

## 4. Configure Application Properties

Edit `src/main/resources/application.properties` (or `.yml`) to configure the service name and port:

```properties
# Service Name (used for registration)
spring.application.name=your-service-name

# Server Port (use 0 for random port or a specific port)
server.port=8081

# Eureka Configuration
spring.cloud.discovery.enabled=true
eureka.client.service-url.defaultZone=http://localhost:8761/eureka/

# Config Server Configuration
spring.config.import=optional:configserver:http://localhost:8888/
```

## 5. Enable Discovery Client

Annotate your main application class with `@EnableDiscoveryClient` (optional in recent Spring Cloud versions, but good practice):

```java
@SpringBootApplication
@EnableDiscoveryClient
public class YourServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(YourServiceApplication.class, args);
    }
}
```

## 6. Verify

1.  Start the Discovery Service.
2.  Start your new service.
3.  Check the Eureka Dashboard at [http://localhost:8761](http://localhost:8761) to see your service registered.
4.  Access your service via the Gateway: `http://localhost:8888/your-service-name/api-endpoint`.
