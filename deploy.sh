#!/bin/bash

# Bagisto Docker Deployment Script
# This script helps deploy Bagisto using Docker containers

set -e

echo "🚀 Starting Bagisto Docker Deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env.docker exists
if [ ! -f .env.docker ]; then
    echo -e "${YELLOW}⚠️  .env.docker not found. Creating from example...${NC}"
    cp .env.docker.example .env.docker
    echo -e "${RED}⚠️  IMPORTANT: Edit .env.docker with your production values before continuing!${NC}"
    exit 1
fi

# Load environment variables
export $(cat .env.docker | grep -v '^#' | xargs)

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p docker/nginx/logs
mkdir -p storage/app/public
mkdir -p storage/framework/{sessions,views,cache}
mkdir -p bootstrap/cache

# Set permissions
echo "🔒 Setting permissions..."
chmod -R 775 storage bootstrap/cache

# Build and start containers
echo "🐳 Building Docker containers..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo "🚀 Starting Docker containers..."
docker-compose -f docker-compose.prod.yml up -d

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
sleep 10

# Run composer install
echo "📦 Installing Composer dependencies..."
docker-compose -f docker-compose.prod.yml run --rm composer install --optimize-autoloader --no-dev

# Generate application key if needed
if grep -q "GENERATE_NEW_KEY" .env.docker; then
    echo "🔑 Generating application key..."
    docker-compose -f docker-compose.prod.yml exec php php artisan key:generate
fi

# Run migrations
echo "🗄️  Running database migrations..."
docker-compose -f docker-compose.prod.yml exec php php artisan migrate --force

# Seed database (optional - comment out if not needed)
# echo "🌱 Seeding database..."
# docker-compose -f docker-compose.prod.yml exec php php artisan db:seed --force

# Create storage link
echo "🔗 Creating storage symlink..."
docker-compose -f docker-compose.prod.yml exec php php artisan storage:link

# Clear and cache config
echo "🧹 Clearing and caching configuration..."
docker-compose -f docker-compose.prod.yml exec php php artisan config:clear
docker-compose -f docker-compose.prod.yml exec php php artisan cache:clear
docker-compose -f docker-compose.prod.yml exec php php artisan route:clear
docker-compose -f docker-compose.prod.yml exec php php artisan view:clear

echo "📦 Caching configuration..."
docker-compose -f docker-compose.prod.yml exec php php artisan config:cache
docker-compose -f docker-compose.prod.yml exec php php artisan route:cache
docker-compose -f docker-compose.prod.yml exec php php artisan view:cache

# Install npm packages and build assets
echo "🎨 Building frontend assets..."
docker-compose -f docker-compose.prod.yml run --rm node sh -c "npm install && npm run build"

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo "Your Bagisto application is now running:"
echo "🌐 Frontend: http://localhost:${NGINX_PORT}"
echo "🔐 Admin: http://localhost:${NGINX_PORT}/${APP_ADMIN_URL}"
echo ""
echo "To view logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "To stop containers:"
echo "  docker-compose -f docker-compose.prod.yml down"
