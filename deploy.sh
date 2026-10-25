#!/bin/sh

set -e

php artisan down

git fetch --prune
git reset --hard '@{upstream}'

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

npm ci --no-audit --no-fund
npm run build

APP_ENV=$(grep '^APP_ENV=' .env | cut -d '=' -f2-)

if [ "$APP_ENV" = "local" ]; then
	composer install --no-interaction --prefer-dist
else
	composer install --optimize-autoloader --no-dev --no-interaction --prefer-dist
fi

php artisan optimize
php artisan migrate --force
php artisan reload
php artisan up
