# VPS SSH Setup and Laravel Backend Deployment Guide

## Step 1: Generate SSH Key Pair for VPS

Generate a dedicated SSH key for your VPS:

```powershell
ssh-keygen -t ed25519 -C "vps-deployment" -f ~\.ssh\vps_deploy_key
```

**When prompted:**
- Press Enter to accept the default location
- Set a passphrase for extra security (recommended)

## Step 2: Configure SSH Config

Create or edit `~\.ssh\config` file:

```ssh-config
# VPS Server Configuration
Host vps
    HostName YOUR_VPS_IP_OR_DOMAIN
    User YOUR_SSH_USERNAME
    Port 22
    IdentityFile ~/.ssh/vps_deploy_key
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Alternative: Use IP directly
Host vps-production
    HostName 123.456.789.0
    User root
    Port 22
    IdentityFile ~/.ssh/vps_deploy_key
    ServerAliveInterval 60
```

**Replace:**
- `YOUR_VPS_IP_OR_DOMAIN` with your VPS IP or domain (e.g., `ekray.com` or `123.456.789.0`)
- `YOUR_SSH_USERNAME` with your SSH username (usually `root` or your username)

## Step 3: Copy Public Key to VPS

### Option A: Using ssh-copy-id (Linux/Mac)
```bash
ssh-copy-id -i ~/.ssh/vps_deploy_key.pub vps
```

### Option B: Manual Copy (Windows)
1. Copy your public key:
```powershell
cat ~\.ssh\vps_deploy_key.pub | clip
```

2. SSH into your VPS:
```powershell
ssh vps
```

3. Add the key to authorized_keys:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## Step 4: Test SSH Connection

```powershell
ssh vps
```

If successful, you'll be logged into your VPS without entering a password.

## Step 5: Create Deployment Script

Create a deployment script `deploy-backend.ps1`:

```powershell
# Laravel Backend Deployment Script
param(
    [string]$Environment = "production"
)

$VPS_HOST = "vps"
$LARAVEL_PATH = "/var/www/laravel"  # Update with your Laravel path
$BRANCH = "main"

Write-Host "Deploying Laravel backend to VPS..." -ForegroundColor Green

# SSH commands to run on VPS
$commands = @"
cd $LARAVEL_PATH
git pull origin $BRANCH
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
"@

# Execute commands on VPS
ssh $VPS_HOST $commands

Write-Host "Deployment completed!" -ForegroundColor Green
```

## Step 6: Create Deployment Script for VPS (Bash)

Create `deploy.sh` on your VPS server:

```bash
#!/bin/bash
# Laravel Deployment Script
# Place this file in /var/www/laravel/deploy.sh

set -e

LARAVEL_PATH="/var/www/laravel"
BRANCH="main"

echo "Starting deployment..."

cd $LARAVEL_PATH

# Pull latest code
git pull origin $BRANCH

# Install dependencies
composer install --no-dev --optimize-autoloader

# Run migrations
php artisan migrate --force

# Clear and cache config
php artisan config:clear
php artisan config:cache

# Clear and cache routes
php artisan route:clear
php artisan route:cache

# Clear and cache views
php artisan view:clear
php artisan view:cache

# Optimize
php artisan optimize

# Restart services (if using supervisor/queue workers)
# sudo supervisorctl restart laravel-worker:*

echo "Deployment completed successfully!"
```

Make it executable:
```bash
chmod +x /var/www/laravel/deploy.sh
```

## Step 7: GitHub Actions Workflow for Auto-Deployment

Create `.github/workflows/deploy-backend.yml`:

```yaml
name: Deploy Laravel Backend to VPS

on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'  # Only deploy when backend files change
      - '.github/workflows/deploy-backend.yml'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup SSH
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.VPS_SSH_PRIVATE_KEY }}" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh-keyscan -H ${{ secrets.VPS_HOST }} >> ~/.ssh/known_hosts
      
      - name: Deploy to VPS
        env:
          VPS_HOST: ${{ secrets.VPS_HOST }}
          VPS_USER: ${{ secrets.VPS_USER }}
          LARAVEL_PATH: ${{ secrets.LARAVEL_PATH }}
        run: |
          ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST << EOF
            cd $LARAVEL_PATH
            git pull origin main
            composer install --no-dev --optimize-autoloader
            php artisan migrate --force
            php artisan config:cache
            php artisan route:cache
            php artisan view:cache
            php artisan optimize
          EOF
```

## Step 8: Add GitHub Secrets

Go to GitHub → Settings → Secrets and variables → Actions, add:

- `VPS_HOST`: Your VPS IP or domain
- `VPS_USER`: SSH username (e.g., `root`)
- `VPS_SSH_PRIVATE_KEY`: Contents of `~/.ssh/vps_deploy_key` (private key, NOT public)
- `LARAVEL_PATH`: Path to Laravel on VPS (e.g., `/var/www/laravel`)

## Step 9: Secure SSH Configuration on VPS

Edit `/etc/ssh/sshd_config` on your VPS:

```bash
# Disable password authentication (use key only)
PasswordAuthentication no
PubkeyAuthentication yes

# Change default port (optional, for security)
Port 2222

# Restrict users
AllowUsers YOUR_USERNAME

# Restart SSH service
sudo systemctl restart sshd
```

## Step 10: Manual Deployment Commands

### Quick Deploy (from local machine):
```powershell
ssh vps "cd /var/www/laravel && git pull && composer install --no-dev && php artisan migrate --force && php artisan optimize"
```

### Or use the deploy script:
```powershell
ssh vps "bash /var/www/laravel/deploy.sh"
```

## Troubleshooting

### SSH Connection Refused
- Check firewall: `sudo ufw status`
- Verify SSH port: `sudo netstat -tlnp | grep :22`
- Check SSH service: `sudo systemctl status ssh`

### Permission Denied
- Check file permissions: `chmod 600 ~/.ssh/deploy_key`
- Verify authorized_keys: `cat ~/.ssh/authorized_keys`
- Check SSH config: `ssh -v vps`

### Git Pull Fails
- Check Git credentials on VPS
- Verify repository URL: `git remote -v`
- Check branch: `git branch`

### Laravel Commands Fail
- Check PHP version: `php -v`
- Check Composer: `composer --version`
- Check file permissions: `ls -la storage/ bootstrap/cache/`

## Security Best Practices

1. **Use SSH keys, not passwords**
2. **Disable root login** (create a sudo user)
3. **Change default SSH port** (optional)
4. **Use firewall** (UFW or iptables)
5. **Keep system updated**: `sudo apt update && sudo apt upgrade`
6. **Use fail2ban** to prevent brute force attacks
7. **Regular backups** of database and files

## Next Steps

1. Set up SSH config
2. Test SSH connection
3. Add GitHub secrets
4. Create deployment script
5. Test manual deployment
6. Enable auto-deployment via GitHub Actions

