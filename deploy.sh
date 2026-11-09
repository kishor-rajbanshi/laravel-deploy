#!/bin/sh

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:${PNPM_HOME:-$HOME/.local/share/pnpm}:$HOME/.yarn/bin:$PATH"

set -e

php artisan down

git fetch --prune
git reset --hard '@{upstream}'

if [ -f package.json ]; then
	if [ -f bun.lock ] || [ -f bun.lockb ]; then
		bun install --frozen-lockfile
		bun run build
	elif [ -f pnpm-lock.yaml ]; then
		pnpm install --frozen-lockfile
		pnpm run build
	elif [ -f yarn.lock ]; then
		if [ "$(yarn --version | cut -d. -f1)" -ge 2 ]; then
			yarn install --immutable
		else
			yarn install --frozen-lockfile
		fi
		yarn run build
	else
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
