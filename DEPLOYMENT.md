# 🚀 Automated Deployment Guide

Bagisto is configured for automated deployment to your VPS using GitHub Actions.

## How It Works

Every time you push to the `main` or `production` branch, GitHub Actions will automatically:

1. ✅ Connect to your VPS via SSH
2. ✅ Clone or update the code
3. ✅ Install Composer dependencies
4. ✅ Run database migrations
5. ✅ Build frontend assets
6. ✅ Optimize for production
7. ✅ Restart services
8. ✅ Verify deployment

## Quick Setup

### 1. Add GitHub Secrets

Go to: **Settings → Secrets and variables → Actions**

See [SECRETS-CHECKLIST.md](SECRETS-CHECKLIST.md) for the complete list of required secrets.

**Minimum required (13 secrets):**
- VPS connection: `VPS_SSH_KEY`, `VPS_HOST`, `VPS_USER`, `DEPLOY_PATH`
- Application: `APP_NAME`, `APP_KEY`, `APP_URL`
- Database: `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`

### 2. Prepare Your VPS

Your VPS needs:
- PHP 8.2+ with extensions (mysql, xml, mbstring, curl, zip, gd, bcmath, intl)
- Composer
- Node.js & npm
- Nginx or Apache
- MySQL

See [SECRETS-CHECKLIST.md](SECRETS-CHECKLIST.md) for detailed VPS setup instructions.

### 3. Deploy

```bash
git add .
git commit -m "Your changes"
git push origin main
```

Watch the deployment in the **Actions** tab!

## Manual Trigger

You can also trigger deployment manually:

1. Go to **Actions** tab
2. Click **Deploy to VPS**
3. Click **Run workflow**
4. Select branch and run

## Monitoring

### Check Deployment Status
- GitHub: **Actions** tab shows real-time logs

### On VPS
```bash
# View Laravel logs
tail -f /var/www/bagisto/storage/logs/laravel.log

# View Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check PHP-FPM status
sudo systemctl status php8.2-fpm

# Run artisan commands
cd /var/www/bagisto
php artisan about
```

## Troubleshooting

### Deployment Failed?

1. Check GitHub Actions logs for error details
2. Verify all secrets are set correctly
3. SSH into VPS and check logs
4. Ensure VPS has all required software installed

### Common Issues

**Permission errors:**
```bash
cd /var/www/bagisto
sudo chown -R $USER:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

**Database connection failed:**
- Verify database credentials in GitHub secrets
- Check MySQL is running: `sudo systemctl status mysql`

**502 Bad Gateway:**
- Check PHP-FPM is running: `sudo systemctl restart php8.2-fpm`
- Check Nginx config: `sudo nginx -t`

## Optional Features

### Email Configuration
Add mail secrets when ready to send emails. See [QUICK-SECRETS-REFERENCE.md](QUICK-SECRETS-REFERENCE.md).

### AWS S3 Storage
Add AWS secrets to use S3 for file storage. See [QUICK-SECRETS-REFERENCE.md](QUICK-SECRETS-REFERENCE.md).

### SSL/HTTPS
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com
```

## Queue Workers

To process background jobs:

```bash
# Create systemd service
sudo nano /etc/systemd/system/bagisto-queue.service
```

```ini
[Unit]
Description=Bagisto Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/bagisto
ExecStart=/usr/bin/php /var/www/bagisto/artisan queue:work --sleep=3 --tries=3
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl enable bagisto-queue
sudo systemctl start bagisto-queue
```

## Support

For detailed setup instructions, see:
- [SECRETS-CHECKLIST.md](SECRETS-CHECKLIST.md) - Complete setup guide
- [QUICK-SECRETS-REFERENCE.md](QUICK-SECRETS-REFERENCE.md) - Quick secrets reference

---

**Your Bagisto store will be live at:** `APP_URL` 🎉
