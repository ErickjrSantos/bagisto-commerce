# 🎯 Quick Reference: Add These Secrets to GitHub

**Go to:** Your Repo → Settings → Secrets and variables → Actions → New repository secret

---

## ✅ ALREADY IN GITHUB (No action needed - 11 secrets)

```
VPS_SSH_KEY
VPS_HOST
VPS_USER
DEPLOY_PATH
APP_NAME
APP_KEY
APP_URL
DB_DATABASE
DB_USERNAME
DB_PASSWORD
MAIL_HOST (optional - keep if already added)
MAIL_PORT (optional - keep if already added)
MAIL_USERNAME (optional - keep if already added)
MAIL_PASSWORD (optional - keep if already added)
MAIL_FROM_ADDRESS (optional - keep if already added)
ADMIN_MAIL_ADDRESS (optional - keep if already added)
```

---

## ⭐ ADD THESE NOW (Required - 2 secrets)

### Database
```
Name: DB_HOST
Value: localhost

Name: DB_PORT
Value: 3306
```

---

## 🔷 ADD THESE IF USING EMAIL (Optional - 7 secrets)

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

## 🔷 ADD THESE IF USING AWS S3 (Optional - 4 secrets)

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

## 🚀 After Adding Secrets

```bash
git add .
git commit -m "Switch to no-Docker deployment"
git push origin main
```

Then watch the magic in **Actions** tab! ✨

---

**Total:** 13 secrets (11 existing + 2 new) or 17 with AWS

**Note:** Mail secrets are optional and can be added later when needed. The app will use `log` driver by default (emails saved to logs).
