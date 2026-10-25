#!/bin/sh

set -e

while true; do
	printf "Which branch do you want to run this workflow on? "
	read -r branch </dev/tty
	[ -n "$branch" ] && break
	echo "Branch name cannot be empty." >&2
done

branch_slug=$(
	printf '%s' "$branch" |
		tr '[:upper:]' '[:lower:]' |
		tr -cs 'a-z0-9' '-' |
		sed 's/^-//;s/-$//'
)

branch_escaped=$(
	printf '%s' "$branch" |
		sed 's/[&/\]/\\&/g'
)

remote_url="https://raw.githubusercontent.com/kishor-rajbanshi/laravel-deploy/refs/heads/main"
workflow_src="$remote_url/deploy.yml"
workflows_dir=".github/workflows"
workflow_dest="$workflows_dir/deploy${branch_slug:+-$branch_slug}.yml"
deploy_src="$remote_url/deploy.sh"
deploy_dest="deploy.sh"

if [ -f "$workflow_dest" ]; then
	echo "Error: '$workflow_dest' already exists. Aborting." >&2
	exit 1
fi

if [ -f "$deploy_dest" ]; then
	echo "Error: '$deploy_dest' already exists. Aborting." >&2
	exit 1
fi

mkdir -p "$workflows_dir"

curl -fsSL "$workflow_src?_=$(date +%s)" |
	sed "s/{branch}/${branch_escaped}/g" >"$workflow_dest"

curl -fsSL "$deploy_src?_=$(date +%s)" -o "$deploy_dest"

echo ""
echo "Create a GitHub environment named '$branch':"
echo "  Repository → Settings → Environments → New environment"
echo ""
echo "Then add the following, either at the repository level (shared by all"
echo "environments) or in the '$branch' environment (overrides the repository value):"
echo ""
echo "Secrets"
echo "  SSH_KEY    : SSH private key (contents of id_ed25519)"
echo ""
echo "Variables"
echo "  HOST       : IP address or hostname of the remote server"
echo "  PORT       : SSH port (optional, defaults to 22)"
echo "  USERNAME   : Username used for SSH authentication"
echo "  BASE_PATH  : Absolute path to the project's root directory on the remote server"
echo ""
