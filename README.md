# Laravel Deploy

A **Continuous Deployment (CD)** workflow powered by GitHub Actions.

## Installation

Run the installer from your Laravel project root. It asks for the branch to deploy and creates the workflow and `deploy.sh`.

```shell
curl -fsSL https://raw.githubusercontent.com/kishor-rajbanshi/laravel-deploy/refs/heads/main/install.sh | sh
```

**Or:**

```shell
wget -qO- https://raw.githubusercontent.com/kishor-rajbanshi/laravel-deploy/refs/heads/main/install.sh | sh
```

## Configuration Guide

### 1. Generate an SSH Key Pair

On your local machine, generate an SSH key pair. Replace `email@example.com` with your email address:

```shell
ssh-keygen -t ed25519 -C "email@example.com"
```

### 2. Add the Public Key to the Server

Copy the generated public key (`id_ed25519.pub`) and add it to the `~/.ssh/authorized_keys` file on the remote server for the user that will be used for SSH access.

### 3. Create a GitHub Environment

The workflow deploys to a GitHub Environment named after the branch (for example, branch `main` uses environment `main`).

In your GitHub repository, navigate to:

#### Settings → Environments → New environment

Create an environment with the same name as the branch you chose during installation.

### 4. Configure the Secret

Add this secret at the repository level (**Settings → Secrets and variables → Actions → Secrets**) if all environments share it, or in the environment (**Settings → Environments → *your environment* → Environment secrets**) if it differs:

* **`SSH_KEY`** — contents of the **private** key file (`id_ed25519`)

### 5. Configure the Variables

Add these variables at the repository level (**Settings → Secrets and variables → Actions → Variables**) if all environments share them, or in the environment (**Settings → Environments → *your environment* → Environment variables**) if they differ:

* **`HOST`** — IP address or hostname of the remote server
* **`PORT`** — SSH port (optional, defaults to `22`)
* **`USERNAME`** — Username used for SSH authentication
* **`BASE_PATH`** — Absolute path to the project’s root directory on the remote server

## Multiple Environments

To deploy several branches (for example, `staging` and `main`), run the installer once per branch. Each run creates a separate workflow file and targets its own environment.

Secret and variable names are identical everywhere. Put values shared by all environments (for example `SSH_KEY`, `USERNAME`, `PORT`) at the repository level, and set only the values that differ (typically `HOST` and `BASE_PATH`) in each environment. An environment-level value overrides a repository-level one with the same name.
