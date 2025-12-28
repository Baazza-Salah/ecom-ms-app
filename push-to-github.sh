#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Repository Setup Script${NC}\n"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}GitHub CLI (gh) is not installed.${NC}"
    echo -e "${YELLOW}Install it with: sudo apt install gh${NC}"
    echo -e "${YELLOW}Or visit: https://cli.github.com/${NC}"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}You need to authenticate with GitHub first.${NC}"
    echo -e "${YELLOW}Run: gh auth login${NC}"
    exit 1
fi

# Get repository name from user
echo -e "${YELLOW}Enter the repository name (e.g., microservices-template):${NC}"
read -r REPO_NAME

if [ -z "$REPO_NAME" ]; then
    echo -e "${RED}Repository name cannot be empty!${NC}"
    exit 1
fi

# Get repository description
echo -e "${YELLOW}Enter a description (optional):${NC}"
read -r REPO_DESC

if [ -z "$REPO_DESC" ]; then
    REPO_DESC="Spring Boot Microservices Template with Config Server, Eureka Discovery, and API Gateway"
fi

# Ask if repository should be public or private
echo -e "${YELLOW}Should the repository be public or private? (public/private) [default: public]:${NC}"
read -r REPO_VISIBILITY

if [ -z "$REPO_VISIBILITY" ]; then
    REPO_VISIBILITY="public"
fi

echo -e "\n${GREEN}Creating GitHub repository...${NC}"

# Create the repository
if [ "$REPO_VISIBILITY" = "private" ]; then
    gh repo create "$REPO_NAME" --description "$REPO_DESC" --private --source=. --remote=origin
else
    gh repo create "$REPO_NAME" --description "$REPO_DESC" --public --source=. --remote=origin
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to create repository!${NC}"
    exit 1
fi

echo -e "${GREEN}Repository created successfully!${NC}\n"

# Stage all files
echo -e "${YELLOW}Staging all files...${NC}"
git add .

# Create initial commit
echo -e "${YELLOW}Creating initial commit...${NC}"
git commit -m "Initial commit: Spring Boot Microservices Template

- Config Service for centralized configuration
- Discovery Service (Eureka) for service registry
- Gateway Service for API routing
- Centralized configuration in config-repo
- Startup script for easy deployment"

# Push to GitHub
echo -e "${YELLOW}Pushing to GitHub...${NC}"
git push -u origin main

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Successfully pushed to GitHub!${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    # Get the repository URL
    REPO_URL=$(gh repo view --json url -q .url)
    echo -e "Repository URL: ${GREEN}$REPO_URL${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Visit your repository: $REPO_URL"
    echo -e "  2. Add a LICENSE file if needed"
    echo -e "  3. Enable GitHub Actions if you want CI/CD"
else
    echo -e "${RED}Failed to push to GitHub!${NC}"
    exit 1
fi
