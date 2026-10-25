#!/bin/sh

set -e

php artisan down

git fetch --prune
git reset --hard '@{upstream}'

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if [ -f package.json ]; then
	if { [ -f bun.lock ] || [ -f bun.lockb ]; } && command -v bun >/dev/null 2>&1; then
		bun install --frozen-lockfile
		bun run build
	elif [ -f pnpm-lock.yaml ] && command -v pnpm >/dev/null 2>&1; then
		pnpm install --frozen-lockfile
		pnpm run build
	elif [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
		if [ "$(yarn --version | cut -d. -f1)" -ge 2 ]; then
			yarn install --immutable
		else
			yarn install --frozen-lockfile
		fi
		yarn run build
	elif command -v npm >/dev/null 2>&1; then
		npm ci --no-audit --no-fund
		npm run build
	fi
fi

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
