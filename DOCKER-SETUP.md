# Bagisto Docker Setup - Complete Guide

## 🚀 Quick Start

This setup provides a complete Docker environment for Bagisto with:
- **Nginx** - Web server
- **PHP-FPM 8.3** - With Composer pre-installed
- **MySQL 8.0** - Database
- **Redis** - Cache and session storage
- **Node.js 20** - For asset compilation
- **Elasticsearch** - Search functionality
- **Mailpit** - Email testing

## 📋 Prerequisites

- Docker installed on your VPS
- Docker Compose v2 or higher
- Git (for CI/CD)

## 🔧 Setup Instructions

### 1. Initial Setup

```bash
# Create .env.docker from example
cp .env.docker.example .env.docker

# Edit .env.docker with your production values
nano .env.docker
```

**Important Environment Variables to Change:**
- `APP_KEY` - Generate with: `php artisan key:generate`
- `APP_URL` - Your domain (https://yourdomain.com)
- `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_ROOT_PASSWORD`
- `MAIL_*` - Your email service credentials

### 2. Deploy

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### 3. Manual Deployment (Alternative)

```bash
# Build and start containers
docker-compose -f docker-compose.prod.yml up -d --build

# Install dependencies
docker-compose -f docker-compose.prod.yml run --rm composer install --optimize-autoloader --no-dev

# Run migrations
docker-compose -f docker-compose.prod.yml exec php php artisan migrate --force

# Create storage link
docker-compose -f docker-compose.prod.yml exec php php artisan storage:link

# Cache configuration
docker-compose -f docker-compose.prod.yml exec php php artisan config:cache
docker-compose -f docker-compose.prod.yml exec php php artisan route:cache
docker-compose -f docker-compose.prod.yml exec php php artisan view:cache

# Build frontend assets
docker-compose -f docker-compose.prod.yml run --rm node sh -c "npm install && npm run build"
```

## 🔐 CI/CD Setup with Secrets

### GitHub Actions Secrets Required:

Navigate to: `Settings > Secrets and variables > Actions > New repository secret`

**Required Secrets:**
```
VPS_SSH_KEY          # Your VPS SSH private key
VPS_HOST             # VPS IP address or domain
VPS_USER             # SSH user (e.g., your new user)
APP_KEY              # Laravel app key (generate with: php artisan key:generate)
APP_URL              # Your domain (https://yourdomain.com)
DB_DATABASE          # Database name
DB_USERNAME          # Database user
DB_PASSWORD          # Database password
DB_ROOT_PASSWORD     # MySQL root password
MAIL_HOST            # SMTP host
MAIL_PORT            # SMTP port (587/465)
MAIL_USERNAME        # SMTP username
MAIL_PASSWORD        # SMTP password
MAIL_FROM_ADDRESS    # From email address
ADMIN_MAIL_ADDRESS   # Admin email address
```

### Setup GitHub Actions:

```bash
# Create workflow directory
mkdir -p .github/workflows

# Copy the example workflow
cp .github-workflow-example.yml .github/workflows/deploy.yml

# Edit the workflow file and update the deployment path
nano .github/workflows/deploy.yml
```

Update the path `/path/to/bagisto` in the workflow file to your actual VPS path.

## 🛠 Useful Docker Commands

```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker-compose -f docker-compose.prod.yml logs -f php
docker-compose -f docker-compose.prod.yml logs -f nginx

# Access PHP container
docker-compose -f docker-compose.prod.yml exec php bash

# Run artisan commands
docker-compose -f docker-compose.prod.yml exec php php artisan [command]

# Run composer commands
docker-compose -f docker-compose.prod.yml exec php composer [command]

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Stop all containers
docker-compose -f docker-compose.prod.yml down

# Stop and remove volumes (⚠️ This deletes data!)
docker-compose -f docker-compose.prod.yml down -v

# Rebuild containers
docker-compose -f docker-compose.prod.yml up -d --build --force-recreate
```

## 📁 Project Structure

```
bagisto-commerce/
├── docker/
│   ├── nginx/
│   │   ├── default.conf       # Nginx configuration
│   │   └── logs/              # Nginx logs
│   ├── php/
│   │   └── local.ini          # PHP configuration
│   └── mysql/
│       └── my.cnf             # MySQL configuration
├── Dockerfile                 # PHP-FPM image
├── docker-compose.prod.yml    # Production docker compose
├── .env.docker.example        # Example environment file
├── .dockerignore              # Docker ignore file
├── deploy.sh                  # Deployment script
└── .github-workflow-example.yml # CI/CD example
```

## 🔒 Security Best Practices

1. **Never commit .env.docker** - Add it to .gitignore
2. **Use strong passwords** for database and root access
3. **Enable SSL/TLS** - Use Let's Encrypt for free certificates
4. **Restrict database access** - Only allow from PHP container
5. **Keep Docker images updated** - Regularly rebuild with latest patches
6. **Use secrets management** - For CI/CD pipelines
7. **Enable firewall** - Only expose necessary ports (80, 443)

## 🌐 SSL/HTTPS Setup (Recommended)

To add SSL support, you can use Certbot with Nginx:

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Or use a Certbot Docker container
docker run -it --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  -p 80:80 \
  certbot/certbot certonly --standalone -d yourdomain.com
```

Then update the Nginx configuration to include SSL certificates.

## 🐛 Troubleshooting

### Container won't start
```bash
docker-compose -f docker-compose.prod.yml logs
```

### Permission issues
```bash
docker-compose -f docker-compose.prod.yml exec php chown -R bagisto:www-data /var/www/html/storage
docker-compose -f docker-compose.prod.yml exec php chmod -R 775 /var/www/html/storage
```

### Database connection fails
- Check if MySQL container is healthy
- Verify DB credentials in .env.docker
- Ensure DB_HOST is set to "mysql" (container name)

### Clear all caches
```bash
docker-compose -f docker-compose.prod.yml exec php php artisan cache:clear
docker-compose -f docker-compose.prod.yml exec php php artisan config:clear
docker-compose -f docker-compose.prod.yml exec php php artisan route:clear
docker-compose -f docker-compose.prod.yml exec php php artisan view:clear
```

## 📊 Monitoring

Monitor your containers:
```bash
# Container stats
docker stats

# Container health
docker-compose -f docker-compose.prod.yml ps
```

## 🔄 Updates and Maintenance

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker-compose -f docker-compose.prod.yml exec php php artisan migrate --force

# Clear and cache
docker-compose -f docker-compose.prod.yml exec php php artisan optimize:clear
docker-compose -f docker-compose.prod.yml exec php php artisan optimize
```

## 📞 Support

For issues related to:
- **Bagisto**: https://github.com/bagisto/bagisto
- **Docker**: https://docs.docker.com/
- **Laravel**: https://laravel.com/docs
