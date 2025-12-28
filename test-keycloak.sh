#!/bin/bash

# Configuration
KEYCLOAK_URL="http://localhost:8180"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
REALM_NAME="ecom-realm"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing Keycloak Configuration..."

# 1. Get Admin Token
echo -n "Getting Admin Token... "
TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$ADMIN_USER" \
    -d "password=$ADMIN_PASSWORD" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | jq -r '.access_token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}FAILED${NC}"
    echo "Could not authenticate as admin. Check credentials or if Keycloak is running."
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# 2. Check Realm
echo -n "Checking Realm '$REALM_NAME'... "
REALM_CHECK=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME" | jq -r '.realm')

if [ "$REALM_CHECK" == "$REALM_NAME" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Realm not found."
fi

# 3. Check Client
echo -n "Checking Client 'ecom-client'... "
CLIENT_CHECK=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients?clientId=ecom-client" | jq -r '.[0].clientId')

if [ "$CLIENT_CHECK" == "ecom-client" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "Client not found."
fi

# 4. Check Users
check_user() {
    local username=$1
    echo -n "Checking User '$username'... "
    local user_id=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users?username=$username" | jq -r '.[0].id')
    
    if [ "$user_id" != "null" ] && [ -n "$user_id" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAILED${NC}"
    fi
}

check_user "user1"
check_user "admin"

# 5. Check Roles
check_role() {
    local role=$1
    echo -n "Checking Role '$role'... "
    local role_name=$(curl -s -H "Authorization: Bearer $TOKEN" "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/$role" | jq -r '.name')
    
    if [ "$role_name" == "$role" ]; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAILED${NC}"
    fi
}

check_role "USER"
check_role "ADMIN"

echo "--------------------------------"
echo "Verification Complete."
