# 🎯 Quick Reference: GitHub Secrets Setup

**Go to:** Your Repo → Settings → Secrets and variables → Actions → New repository secret

---

## ✅ REQUIRED SECRETS (13 total)

### VPS Connection (4 secrets)
### VPS Connection (4 secrets)
```
Name: VPS_SSH_KEY
Value: [Your entire SSH private key]

Name: VPS_HOST
Value: your-vps-ip-or-domain

Name: VPS_USER
Value: marvin

Name: DEPLOY_PATH
Value: /var/www/bagisto
```

### Application (3 secrets)
```
Name: APP_NAME
Value: Bagisto

Name: APP_KEY
Value: base64:your_key_here

Name: APP_URL
Value: http://your-domain.com
```

### Database (5 secrets)
```
Name: DB_HOST
Value: localhost

Name: DB_PORT
Value: 3306

Name: DB_DATABASE
Value: mutindo

Name: DB_USERNAME
Value: bagisto

Name: DB_PASSWORD
Value: your_secure_password
```

---

## 🔷 OPTIONAL SECRETS

### Email (7 secrets) - Add when ready

### Email (7 secrets) - Add when ready
```
Name: MAIL_MAILER
Value: smtp

Name: MAIL_HOST
Value: smtp.gmail.com

Name: MAIL_PORT
Value: 587

Name: MAIL_USERNAME
Value: your@email.com

Name: MAIL_PASSWORD
Value: your_password

Name: MAIL_ENCRYPTION
Value: tls

Name: MAIL_FROM_ADDRESS
Value: noreply@yourdomain.com
```

### AWS S3 (4 secrets) - Add if using S3 storage

```
Name: AWS_ACCESS_KEY_ID
Value: your_aws_access_key

Name: AWS_SECRET_ACCESS_KEY
Value: your_aws_secret_key

Name: AWS_DEFAULT_REGION
Value: us-east-1

Name: AWS_BUCKET
Value: your_bucket_name
```

---

## ❌ DELETE THESE FROM GITHUB (No longer needed - 5 secrets)

```
DB_ROOT_PASSWORD
DOCKER_IMAGE
NGINX_PORT
NGINX_SSL_PORT
PHP_MEMORY_LIMIT
```

---

## ❌ DELETE THESE FROM GITHUB (No longer needed - 5 secrets)

```
DB_ROOT_PASSWORD
DOCKER_IMAGE
NGINX_PORT
NGINX_SSL_PORT
PHP_MEMORY_LIMIT
```

---

## 🚀 After Adding Secrets

```bash
git add .
git commit -m "Setup automated deployment"
git push origin main
```

Then watch the deployment in **Actions** tab! ✨

---

**Total Required:** 13 secrets
**Optional:** 7 (email) + 4 (AWS) = 11 more if needed
