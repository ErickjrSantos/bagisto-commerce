# Quick Start Commands

## First Time Setup
```bash
# 1. Copy environment file
cp .env.docker.example .env.docker

# 2. Edit with your values
nano .env.docker

# 3. Run deployment script
./deploy.sh
```

## Your application will be available at:
- Frontend: http://your-vps-ip
- Admin: http://your-vps-ip/admin

## Common Commands
```bash
# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Stop all
docker-compose -f docker-compose.prod.yml down

# Run artisan commands
docker-compose -f docker-compose.prod.yml exec php php artisan [command]
```

For complete documentation, see DOCKER-SETUP.md
