# 🚀 Automated Docker Deployment with GitHub Actions

This setup provides **fully automated deployment** to your VPS using GitHub Actions. Just push to the main branch and everything happens automatically!

## 📋 What Happens Automatically

When you push to `main` branch:
1. ✅ Builds Docker image with your code
2. ✅ Pushes image to GitHub Container Registry (free)
3. ✅ Connects to your VPS via SSH
4. ✅ Deploys containers with new image
5. ✅ Runs migrations and optimizations
6. ✅ Health check to verify deployment
7. ✅ Cleans up old images

## 🔐 Required GitHub Secrets

Go to your GitHub repo: **Settings → Secrets and variables → Actions → New repository secret**

Add these secrets (click "New repository secret" for each):

### VPS Connection
```
VPS_SSH_KEY          # Your SSH private key (entire content of ~/.ssh/id_rsa)
VPS_HOST             # Your VPS IP or domain (e.g., 123.45.67.89)
VPS_USER             # Your VPS username (e.g., marvin)
DEPLOY_PATH          # Path on VPS (e.g., /home/marvin/bagisto-app)
```

### Application
```
APP_NAME             # Bagisto
APP_KEY              # base64:... (generate with: php artisan key:generate)
APP_URL              # https://yourdomain.com or http://your-vps-ip
```

### Database
```
DB_DATABASE          # bagisto_production
DB_USERNAME          # bagisto_user
DB_PASSWORD          # strong_random_password_here
DB_ROOT_PASSWORD     # another_strong_password
```

### Email (SMTP)
```
MAIL_HOST            # smtp.gmail.com (or your provider)
MAIL_PORT            # 587
MAIL_USERNAME        # your@email.com
MAIL_PASSWORD        # your_email_password
MAIL_FROM_ADDRESS    # noreply@yourdomain.com
ADMIN_MAIL_ADDRESS   # admin@yourdomain.com
```

## 🔑 Setting Up SSH Access

### On your VPS:

```bash
# 1. Create the deployment directory
mkdir -p /home/marvin/bagisto-app

# 2. Generate SSH key on your local machine (if you don't have one)
ssh-keygen -t rsa -b 4096 -C "github-actions"

# 3. Copy the public key to your VPS
ssh-copy-id marvin@your-vps-ip

# 4. Test SSH connection
ssh marvin@your-vps-ip
```

### Get your SSH private key:

```bash
# Display your private key (add this to VPS_SSH_KEY secret)
cat ~/.ssh/id_rsa
```

Copy the **entire output** including:
- `-----BEGIN OPENSSH PRIVATE KEY-----`
- All the content
- `-----END OPENSSH PRIVATE KEY-----`

## 🚀 How to Deploy

### First Time Setup:

1. **Add all secrets to GitHub** (see above)
2. **Push to main branch:**

```bash
git add .
git commit -m "Setup automated deployment"
git push origin main
```

3. **Watch the deployment:**
   - Go to your GitHub repo → **Actions** tab
   - Click on the running workflow
   - Watch the magic happen! ✨

### Subsequent Deployments:

Just push to main:
```bash
git add .
git commit -m "Your changes"
git push origin main
```

GitHub Actions will automatically deploy! 🎉

## 🔍 Manual Deployment Trigger

You can also trigger deployment manually:
1. Go to **Actions** tab in GitHub
2. Click **Deploy to VPS with Docker**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 📊 Monitoring Your Deployment

### View Workflow Status:
- GitHub repo → **Actions** tab
- See real-time logs of each step

### Check on VPS:
```bash
# SSH into your VPS
ssh marvin@your-vps-ip

# Go to deployment directory
cd /home/marvin/bagisto-app

# Check running containers
docker ps

# View logs
docker-compose logs -f

# Check specific service
docker-compose logs -f php
docker-compose logs -f nginx
```

## 🛠 Useful Commands on VPS

```bash
# View all containers
docker-compose ps

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Run artisan commands
docker-compose exec php php artisan [command]

# Access database
docker-compose exec mysql mysql -u bagisto_user -p bagisto_production

# Stop everything
docker-compose down

# Update and redeploy (GitHub Actions does this automatically)
docker-compose pull
docker-compose up -d
```

## 🔒 Security Best Practices

1. **Never commit secrets** to your repository
2. **Use strong passwords** for all database credentials
3. **Enable firewall** on your VPS:
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   sudo ufw allow 443/tcp   # HTTPS
   sudo ufw enable
   ```
4. **Setup SSL/TLS** - Use Let's Encrypt (see SSL section)
5. **Regular updates:**
   ```bash
   # On VPS
   sudo apt update && sudo apt upgrade -y
   docker system prune -f
   ```

## 🌐 Setting Up SSL (HTTPS)

### Option 1: Using Certbot (Recommended)

```bash
# Install certbot on VPS
sudo apt install certbot python3-certbot-nginx

# Stop nginx container temporarily
cd /home/marvin/bagisto-app
docker-compose stop nginx

# Get certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Certificates will be in: /etc/letsencrypt/live/yourdomain.com/
```

Then update [docker/nginx/default.conf](docker/nginx/default.conf) to add SSL:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    
    # ... rest of your config
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

Update docker-compose.prod.yml nginx volumes:
```yaml
volumes:
  - /etc/letsencrypt:/etc/letsencrypt:ro
```

## 🐛 Troubleshooting

### Deployment Failed?

1. **Check GitHub Actions logs:**
   - Go to Actions tab
   - Click on failed workflow
   - Expand failed step to see error

2. **Common issues:**

   **SSH Connection Failed:**
   ```bash
   # Test SSH manually
   ssh -i ~/.ssh/id_rsa marvin@your-vps-ip
   
   # Check VPS_SSH_KEY secret format (must include BEGIN/END lines)
   ```

   **Docker Image Pull Failed:**
   ```bash
   # On VPS, login to GitHub registry
   echo $GITHUB_TOKEN | docker login ghcr.io -u yourusername --password-stdin
   ```

   **Database Connection Failed:**
   - Check DB credentials in GitHub secrets
   - Verify MySQL container is running: `docker-compose ps`

   **Permission Errors:**
   ```bash
   # On VPS
   cd /home/marvin/bagisto-app
   docker-compose exec php chown -R bagisto:www-data /var/www/html/storage
   docker-compose exec php chmod -R 775 /var/www/html/storage
   ```

### Application Not Loading?

```bash
# Check if containers are running
docker-compose ps

# Check logs
docker-compose logs

# Restart all services
docker-compose restart

# Check nginx logs
docker-compose logs nginx

# Check PHP logs
docker-compose logs php
```

## 📈 Workflow Customization

Edit [.github/workflows/deploy.yml](.github/workflows/deploy.yml) to:

- **Deploy on different branches:**
  ```yaml
  on:
    push:
      branches:
        - main
        - staging
        - develop
  ```

- **Add Slack/Discord notifications:**
  ```yaml
  - name: Notify Slack
    uses: 8398a7/action-slack@v3
    with:
      status: ${{ job.status }}
      webhook_url: ${{ secrets.SLACK_WEBHOOK }}
  ```

- **Run tests before deployment:**
  ```yaml
  - name: Run tests
    run: |
      docker-compose exec -T php php artisan test
  ```

## 📦 What's Included

- **Nginx** - Web server (port 80/443)
- **PHP 8.3-FPM** - With all Laravel extensions + Composer
- **MySQL 8.0** - Database with persistent storage
- **Redis** - Cache and sessions
- **Elasticsearch** - Search (optional)
- **Mailpit** - Email testing (port 8025)

## 🎯 Next Steps

1. ✅ Add all GitHub secrets
2. ✅ Setup SSH access to VPS
3. ✅ Push to main branch
4. ✅ Watch deployment in Actions tab
5. ✅ Access your site at APP_URL
6. 🎉 Enjoy automated deployments!

---

**Need help?** Check the workflow logs in GitHub Actions for detailed error messages.
