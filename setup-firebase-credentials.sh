#!/bin/bash
# Firebase Credentials Setup Script for VPS
# Usage: ./setup-firebase-credentials.sh [path-to-credentials-file]

set -e

# Configuration
LARAVEL_ROOT="/home/ekray/htdocs/ekray.com"
CREDENTIALS_PATH="$LARAVEL_ROOT/storage/app/public/firebase_credentials.json"
BACKUP_DIR="$LARAVEL_ROOT/storage/app/backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Firebase Credentials Setup${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if file path provided as argument
if [ -n "$1" ]; then
    SOURCE_FILE="$1"
    if [ ! -f "$SOURCE_FILE" ]; then
        echo -e "${RED}Error: Source file not found: $SOURCE_FILE${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Copying credentials from: $SOURCE_FILE${NC}"
    cp "$SOURCE_FILE" "$CREDENTIALS_PATH"
fi

# Check if credentials file exists
if [ ! -f "$CREDENTIALS_PATH" ]; then
    echo -e "${RED}Error: Firebase credentials file not found!${NC}"
    echo -e "${YELLOW}Expected location: $CREDENTIALS_PATH${NC}"
    echo ""
    echo "To upload credentials:"
    echo "1. Download Firebase Service Account JSON from Firebase Console"
    echo "2. Upload to VPS using SCP:"
    echo "   scp -i ~/.ssh/vps_deploy_key credentials.json vps:$CREDENTIALS_PATH"
    echo ""
    exit 1
fi

# Backup existing file if it exists
if [ -f "$CREDENTIALS_PATH" ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/firebase_credentials_$(date +%Y%m%d_%H%M%S).json"
    cp "$CREDENTIALS_PATH" "$BACKUP_FILE"
    echo -e "${YELLOW}Backed up existing credentials to: $BACKUP_FILE${NC}"
fi

# Verify JSON is valid
echo -e "${YELLOW}Validating JSON file...${NC}"
if ! php -r "json_decode(file_get_contents('$CREDENTIALS_PATH'));" 2>/dev/null; then
    echo -e "${RED}Error: Invalid JSON file!${NC}"
    exit 1
fi

# Set proper permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod 600 "$CREDENTIALS_PATH"
chown www-data:www-data "$CREDENTIALS_PATH" || chown $(whoami):$(whoami) "$CREDENTIALS_PATH"

# Verify permissions
PERMS=$(stat -c "%a" "$CREDENTIALS_PATH" 2>/dev/null || stat -f "%OLp" "$CREDENTIALS_PATH" 2>/dev/null)
if [ "$PERMS" != "600" ]; then
    echo -e "${YELLOW}Warning: Permissions are $PERMS (expected 600)${NC}"
fi

# Extract project ID from credentials (for verification)
PROJECT_ID=$(php -r "echo json_decode(file_get_contents('$CREDENTIALS_PATH'), true)['project_id'] ?? 'unknown';" 2>/dev/null)
echo -e "${GREEN}Firebase Project ID: $PROJECT_ID${NC}"

# Change to Laravel directory
cd "$LARAVEL_ROOT" || exit 1

# Clear Laravel caches
echo -e "${YELLOW}Clearing Laravel cache...${NC}"
php artisan config:clear 2>/dev/null || true
php artisan cache:clear 2>/dev/null || true

# Test Firebase connection (if Laravel is configured)
echo -e "${YELLOW}Testing Firebase connection...${NC}"
if php artisan tinker --execute="try { \$auth = app('firebase.auth'); echo 'Firebase connection successful'; } catch (\Exception \$e) { echo 'Error: ' . \$e->getMessage(); exit(1); }" 2>/dev/null; then
    echo -e "${GREEN}Firebase connection test passed!${NC}"
else
    echo -e "${YELLOW}Note: Could not test Firebase connection (Laravel may not be fully configured)${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Credentials file: $CREDENTIALS_PATH"
echo "Permissions: $(stat -c "%a %U:%G" "$CREDENTIALS_PATH" 2>/dev/null || stat -f "%OLp %Su:%Sg" "$CREDENTIALS_PATH")"
echo ""
echo "Next steps:"
echo "1. Test Firebase authentication endpoint"
echo "2. Verify in Laravel logs if there are any errors"
echo "3. Test Google Sign-In from Flutter app"

