# Dockerized WordPress Stack

This repository lets you run a full WordPress site (PHP–FPM, MySQL, nginx) in Docker with minimal fuss—just supply an `.env` file.

## Features

- **PHP-FPM** (configurable via `WP_VERSION` & `PHP_VERSION`)
- **nginx** with custom DNS + template
- **MySQL** 5.7 with healthcheck
- **Automated backups** of both files and database
- **Custom WordPress CLI** container for db dumps
- **Single-command install** via `scripts/install.sh`

## Quick Start

1. **Clone**  
```bash
   git clone https://github.com/you/your-repo.git
   cd your-repo
```

2. **Configure**

Copy `.env.example` to `.env`, then edit to suit:

```bash
   cp .env.example .env
```

3. **Install**

```bash
   bash scripts/install.sh
```

4. **Visit**
   Your site will be up at:
   `http://${APP_MAIN_DOMAIN}:${APP_PORT}`


## Customization

* **Change WP version**: Set `WP_VERSION` in `.env` (e.g. `6.2`).
* **PHP version**: Set `PHP_VERSION` (e.g. `8.1`).
* **Backup schedule**: Adjust `BACKUP_CRON_EXPRESSION`.
* **Restart policies**: Tweak `RESTART_POLICY`.

## Volumes & Backups

* **wp\_data** and **db\_data** are persisted on host.
* **backups/** is bind-mounted for archives—excluded from git.

## Advanced

* Use Traefik labels (already in compose) for TLS & host routing.
* Swap MySQL for MariaDB by changing the image in `docker-compose.yml`.
