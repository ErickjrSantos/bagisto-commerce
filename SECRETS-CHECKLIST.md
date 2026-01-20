# GitHub Secrets Checklist

Copy this to add all required secrets to GitHub.

Go to: **Your Repo → Settings → Secrets and variables → Actions → New repository secret**

## ✅ VPS Connection (4 secrets)
- [ ] `VPS_SSH_KEY` - Your SSH private key (get with: `cat ~/.ssh/id_rsa`)
- [ ] `VPS_HOST` - Your VPS IP or domain (e.g., `123.45.67.89`)
- [ ] `VPS_USER` - Your VPS username (e.g., `marvin`)
- [ ] `DEPLOY_PATH` - Deployment path (e.g., `/home/marvin/bagisto-app`)

## ✅ Application (3 secrets)
- [ ] `APP_NAME` - `Bagisto`
- [ ] `APP_KEY` - Generate with: `php artisan key:generate --show`
- [ ] `APP_URL` - Your domain or `http://your-vps-ip`

## ✅ Database (4 secrets)
- [ ] `DB_DATABASE` - `bagisto_production`
- [ ] `DB_USERNAME` - `bagisto_user`
- [ ] `DB_PASSWORD` - Use a strong random password
- [ ] `DB_ROOT_PASSWORD` - Use a different strong password

## ✅ Email (5 secrets)
- [ ] `MAIL_HOST` - SMTP host (e.g., `smtp.gmail.com`)
- [ ] `MAIL_PORT` - Usually `587` or `465`
- [ ] `MAIL_USERNAME` - Your email username
- [ ] `MAIL_PASSWORD` - Your email password or app-specific password
- [ ] `MAIL_FROM_ADDRESS` - From email (e.g., `noreply@yourdomain.com`)
- [ ] `ADMIN_MAIL_ADDRESS` - Admin email (e.g., `admin@yourdomain.com`)

---

## 📝 Commands to Generate Values

```bash
# Generate APP_KEY
php artisan key:generate --show

# Get SSH private key
cat ~/.ssh/id_rsa

# Generate random password (Linux/Mac)
openssl rand -base64 32

# Get your VPS IP
ip addr show | grep "inet " | grep -v 127.0.0.1
```

---

## 🚀 After Adding All Secrets

```bash
# Commit and push to trigger deployment
git add .
git commit -m "Configure automated deployment"
git push origin main
```

Then go to **Actions** tab to watch the deployment! 🎉
