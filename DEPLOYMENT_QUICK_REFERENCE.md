# Laravel Backend Deployment Quick Reference

## Quick Commands

### Test SSH Connection
```powershell
ssh vps
```

### Manual Deployment
```powershell
ssh vps "cd /var/www/laravel && git pull && composer install --no-dev && php artisan migrate --force && php artisan optimize"
```

### Deploy Using Script
```powershell
ssh vps "bash /var/www/laravel/deploy.sh"
```

### Check Laravel Status
```powershell
ssh vps "cd /var/www/laravel && php artisan --version"
```

### View Logs
```powershell
ssh vps "tail -f /var/www/laravel/storage/logs/laravel.log"
```

### Restart Services
```powershell
ssh vps "sudo systemctl restart php8.1-fpm && sudo systemctl restart nginx"
```

## GitHub Secrets Required

Add these in GitHub → Settings → Secrets → Actions:

- `VPS_HOST`: Your VPS IP or domain (e.g., `ekray.com` or `123.456.789.0`)
- `VPS_USER`: SSH username (e.g., `root`)
- `VPS_SSH_PRIVATE_KEY`: Contents of your private SSH key (`~/.ssh/vps_deploy_key`)
- `LARAVEL_PATH`: Path to Laravel on VPS (e.g., `/var/www/laravel`)

## VPS Server Requirements

Ensure your VPS has:
- Git installed
- Composer installed
- PHP 8.1+ with required extensions
- Nginx/Apache configured
- SSH access enabled
- Firewall configured (UFW recommended)

## File Structure on VPS

```
/var/www/laravel/
├── app/
├── routes/
├── database/
├── config/
├── storage/
├── bootstrap/
├── deploy.sh          # Deployment script
└── .env               # Environment configuration
```

