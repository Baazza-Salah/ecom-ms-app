#!/bin/bash

# Keycloak Configuration
KEYCLOAK_URL="http://localhost:8180"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin" # Default, change if needed
REALM_NAME="ecom-realm"
CLIENT_ID="ecom-client"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Getting Admin Token...${NC}"
TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$ADMIN_USER" \
    -d "password=$ADMIN_PASSWORD" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | jq -r '.access_token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo "Failed to get admin token. Check credentials or Keycloak status."
    exit 1
fi

echo -e "${GREEN}Creating Realm '$REALM_NAME'...${NC}"
curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"realm\": \"$REALM_NAME\", \"enabled\": true}"

echo -e "${GREEN}Creating Client '$CLIENT_ID'...${NC}"
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"clientId\": \"$CLIENT_ID\", \"enabled\": true, \"publicClient\": true, \"directAccessGrantsEnabled\": true, \"redirectUris\": [\"*\"]}"

echo -e "${GREEN}Creating Roles...${NC}"
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name": "USER"}'

curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name": "ADMIN"}'

echo -e "${GREEN}Creating Users...${NC}"
# User 1
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username": "user1", "enabled": true, "credentials": [{"type": "password", "value": "1234", "temporary": false}]}'

# Admin 1
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "enabled": true, "credentials": [{"type": "password", "value": "1234", "temporary": false}]}'

echo -e "${GREEN}Assigning Roles...${NC}"
# Get User IDs
USER1_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=user1" | jq -r '.[0].id')
ADMIN_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=admin" | jq -r '.[0].id')

# Get Role IDs
USER_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/USER" | jq -r '.id')
ADMIN_ROLE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/ADMIN" | jq -r '.id')

# Assign Roles
curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$USER1_ID/role-mappings/realm" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "[{\"id\": \"$USER_ROLE_ID\", \"name\": \"USER\"}]"

curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$ADMIN_ID/role-mappings/realm" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "[{\"id\": \"$USER_ROLE_ID\", \"name\": \"USER\"}, {\"id\": \"$ADMIN_ROLE_ID\", \"name\": \"ADMIN\"}]"

echo -e "${GREEN}Keycloak Setup Complete!${NC}"
