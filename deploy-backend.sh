#!/bin/bash
# Laravel Backend Deployment Script
# Usage: ./deploy.sh [environment]
# Example: ./deploy.sh production

set -e  # Exit on error

# Configuration
ENVIRONMENT=${1:-production}
LARAVEL_PATH="/var/www/laravel"
BRANCH="main"
BACKUP_DIR="/var/backups/laravel"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Laravel Backend Deployment${NC}"
echo -e "${GREEN}Environment: $ENVIRONMENT${NC}"
echo -e "${GREEN}========================================${NC}"

# Change to Laravel directory
cd $LARAVEL_PATH || exit 1

# Backup database (if backup script exists)
if [ -f "$LARAVEL_PATH/backup-db.sh" ]; then
    echo -e "${YELLOW}Creating database backup...${NC}"
    bash $LARAVEL_PATH/backup-db.sh
fi

# Pull latest code
echo -e "${YELLOW}Pulling latest code from $BRANCH...${NC}"
git fetch origin
git pull origin $BRANCH

# Install/Update dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
if [ "$ENVIRONMENT" = "production" ]; then
    composer install --no-dev --optimize-autoloader --no-interaction
else
    composer install --optimize-autoloader --no-interaction
fi

# Run migrations
echo -e "${YELLOW}Running migrations...${NC}"
php artisan migrate --force

# Clear caches
echo -e "${YELLOW}Clearing caches...${NC}"
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Cache for production
if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${YELLOW}Caching for production...${NC}"
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Optimize
echo -e "${YELLOW}Optimizing application...${NC}"
php artisan optimize

# Set permissions
echo -e "${YELLOW}Setting permissions...${NC}"
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Restart queue workers (if using)
if command -v supervisorctl &> /dev/null; then
    echo -e "${YELLOW}Restarting queue workers...${NC}"
    supervisorctl restart laravel-worker:* || true
fi

# Reload PHP-FPM (if using)
if command -v systemctl &> /dev/null; then
    echo -e "${YELLOW}Reloading PHP-FPM...${NC}"
    sudo systemctl reload php8.1-fpm || sudo systemctl reload php8.2-fpm || true
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

