#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Microservices Infrastructure...${NC}\n"

# Function to check if a service is healthy
check_health() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${YELLOW}Waiting for $service_name to be ready...${NC}"
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name is ready!${NC}\n"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo -e "${RED}✗ $service_name failed to start${NC}\n"
    return 1
}

# Start Config Service
echo -e "${YELLOW}[1/3] Starting Config Service on port 8888...${NC}"
cd config-service
../mvnw spring-boot:run > ../logs/config-service.log 2>&1 &
CONFIG_PID=$!
cd ..

# Wait for Config Service to be ready
if ! check_health 8888 "Config Service"; then
    echo -e "${RED}Failed to start Config Service. Check logs/config-service.log${NC}"
    exit 1
fi

# Start Discovery Service
echo -e "${YELLOW}[2/3] Starting Discovery Service on port 8761...${NC}"
cd discovery-service
../mvnw spring-boot:run > ../logs/discovery-service.log 2>&1 &
DISCOVERY_PID=$!
cd ..

# Wait for Discovery Service to be ready
if ! check_health 8761 "Discovery Service"; then
    echo -e "${RED}Failed to start Discovery Service. Check logs/discovery-service.log${NC}"
    exit 1
fi

# Start Gateway Service
echo -e "${YELLOW}[3/3] Starting Gateway Service on port 9999...${NC}"
cd gateway-service
../mvnw spring-boot:run > ../logs/gateway-service.log 2>&1 &
GATEWAY_PID=$!
cd ..

# Wait for Gateway Service to be ready
if ! check_health 9999 "Gateway Service"; then
    echo -e "${RED}Failed to start Gateway Service. Check logs/gateway-service.log${NC}"
    exit 1
fi

# All services started successfully
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All services started successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "Service URLs:"
echo -e "  • Config Service:    ${GREEN}http://localhost:8888${NC}"
echo -e "  • Discovery Service: ${GREEN}http://localhost:8761${NC}"
echo -e "  • Gateway Service:   ${GREEN}http://localhost:9999${NC}\n"

echo -e "Process IDs:"
echo -e "  • Config Service:    ${YELLOW}$CONFIG_PID${NC}"
echo -e "  • Discovery Service: ${YELLOW}$DISCOVERY_PID${NC}"
echo -e "  • Gateway Service:   ${YELLOW}$GATEWAY_PID${NC}\n"

echo -e "Logs are available in the ${YELLOW}logs/${NC} directory\n"

echo -e "${YELLOW}To stop all services, run:${NC}"
echo -e "  pkill -f 'spring-boot:run'\n"
