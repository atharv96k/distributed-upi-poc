# Stage 1: Build the application
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app

# Copy Maven wrapper and POM first to leverage Docker layer caching for dependencies
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Ensure the Maven wrapper is executable (permission can be lost on Windows checkouts)
RUN chmod +x mvnw

# Download dependencies (fail-safe fallback if dependencies offline fails)
RUN ./mvnw dependency:go-offline -B || true

# Copy source code and package application (skipping tests for faster builds)
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Create a non-privileged user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy the built executable jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Set ownership
RUN chown -R appuser:appuser /app
USER appuser

# Expose the default Spring Boot port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
