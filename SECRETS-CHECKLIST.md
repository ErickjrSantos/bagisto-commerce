# GitHub Secrets Checklist

This checklist contains all required secrets for automated deployment.

Go to: **Your Repo → Settings → Secrets and variables → Actions → New repository secret**

---

## ✅ VPS Connection (4 secrets)
- [ ] `VPS_SSH_KEY` - Your SSH private key (get with: `cat ~/.ssh/id_rsa`)
- [ ] `VPS_HOST` - Your VPS IP or domain (e.g., `123.45.67.89`)
- [ ] `VPS_USER` - Your VPS username (e.g., `marvin`)
- [ ] `DEPLOY_PATH` - Deployment path (e.g., `/var/www/bagisto`)

## ✅ Application (3 secrets)
- [ ] `APP_NAME` - `Bagisto`
- [ ] `APP_KEY` - Your existing base64 key
- [ ] `APP_URL` - Your domain or `http://your-vps-ip`

## ✅ Database (5 secrets)
- [ ] `DB_HOST` - Database host (e.g., `localhost` or `127.0.0.1`)
- [ ] `DB_PORT` - Database port (usually `3306`)
- [ ] `DB_DATABASE` - Database name (e.g., `mutindo`)
- [ ] `DB_USERNAME` - Database user (e.g., `bagisto`)
- [ ] `DB_PASSWORD` - Database password

## ⚡ Email (7 secrets) - **OPTIONAL** (Can configure later)
- [ ] `MAIL_MAILER` - Mail driver (e.g., `smtp`)
- [ ] `MAIL_HOST` - SMTP host (e.g., `smtp.gmail.com`)
- [ ] `MAIL_PORT` - Usually `587` or `465`
- [ ] `MAIL_USERNAME` - Your email username
- [ ] `MAIL_PASSWORD` - Your email password
- [ ] `MAIL_ENCRYPTION` - Encryption type (e.g., `tls`)
- [ ] `MAIL_FROM_ADDRESS` - From email
- [ ] `ADMIN_MAIL_ADDRESS` - Admin email
- [ ] `CONTACT_MAIL_ADDRESS` - Contact form email

## ⚡ AWS (Optional - 4 secrets) - **NEW**
- [ ] `AWS_ACCESS_KEY_ID` - AWS access key (if using S3 for storage)
- [ ] `AWS_SECRET_ACCESS_KEY` - AWS secret key
- [ ] `AWS_DEFAULT_REGION` - AWS region (e.g., `us-east-1`)
- [ ] `AWS_BUCKET` - S3 bucket name

---

## 📝 Commands to Generate Values

```bash
# Generate APP_KEY (if you need a new one)
php artisan key:generate --show

# Get SSH private key
cat ~/.ssh/id_rsa

# Generate random password
openssl rand -base64 32

# Get your VPS IP
ip addr show | grep "inet " | grep -v 127.0.0.1
```

---

## 🚀 VPS Server Requirements

Before deployment, ensure your VPS has:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2/8.3 and extensions
sudo apt install -y php8.3 php8.3-fpm php8.3-mysql php8.3-xml php8.3-mbstring \
  php8.3-curl php8.3-zip php8.3-gd php8.3-bcmath php8.3-intl php8.3-redis

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Nginx
sudo apt install -y nginx

# Install MySQL
sudo apt install -y mysql-server

# Configure MySQL
sudo mysql_secure_installation
```

---

## 🔒 Configure VPS for Deployment

### 1. Setup Database

```bash
# Login to MySQL
sudo mysql

# Create database and user
CREATE DATABASE mutindo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'bagisto'@'localhost' IDENTIFIED BY 'your_password_here';
GRANT ALL PRIVILEGES ON mutindo.* TO 'bagisto'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 2. Configure Nginx

Create `/etc/nginx/sites-available/bagisto`:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/bagisto/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/bagisto /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 3. Set Proper Permissions

```bash
sudo mkdir -p /var/www/bagisto
sudo chown -R $USER:www-data /var/www/bagisto
sudo chmod -R 755 /var/www/bagisto
```

### 4. Setup SSH for GitHub Actions

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -C "github-actions"

# Add public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Get private key for GitHub secret
cat ~/.ssh/id_rsa
```

---

## 🚀 Deploy Your Application

After adding all secrets to GitHub:

```bash
git add .
git commit -m "Setup CI/CD deployment without Docker"
git push origin main
```

Then go to **Actions** tab to watch the deployment! 🎉

---

## 📊 Post-Deployment Commands

```bash
# SSH into your VPS
ssh your-user@your-vps-ip

# Navigate to deployment directory
cd /var/www/bagisto

# Check application status
php artisan about

# View logs
tail -f storage/logs/laravel.log

# Run commands
php artisan cache:clear
php artisan config:cache
php artisan queue:work
```

---

## 🔧 Optional: Setup Queue Worker

Create `/etc/systemd/system/bagisto-queue.service`:

```ini
[Unit]
Description=Bagisto Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/bagisto
ExecStart=/usr/bin/php /var/www/bagisto/artisan queue:work --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable bagisto-queue
sudo systemctl start bagisto-queue
sudo systemctl status bagisto-queue
```

---

## 🔒 Setup SSL/HTTPS with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is configured automatically
# Test renewal
sudo certbot renew --dry-run
```

---

## 📈 Monitoring & Logs

```bash
# Nginx error log
sudo tail -f /var/log/nginx/error.log

# Nginx access log
sudo tail -f /var/log/nginx/access.log

# PHP-FPM log
sudo tail -f /var/log/php8.3-fpm.log

# Laravel log
tail -f /var/www/bagisto/storage/logs/laravel.log

# System resources
htop
```

---

## 🎯 Next Steps

1. ✅ Add all required secrets to GitHub
2. ✅ Configure your VPS server
3. ✅ Setup database and Nginx
4. ✅ Setup SSH access
5. ✅ Push to main branch
6. ✅ Watch deployment in Actions tab
7. 🎉 Access your site!

**Your site will be available at:** `http://your-vps-ip` or `https://your-domain.com`
