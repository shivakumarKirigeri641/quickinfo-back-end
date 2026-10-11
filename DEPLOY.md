# Deploying QuickInfo

Target: an Ubuntu server with nginx, Node.js, PM2 and PostgreSQL. This is the same kind of box that runs ServerPe. QuickInfo uses the **same database** as serverpe-back-end.

| Host | Served by |
| --- | --- |
| `quickinfo.in`, `www.quickinfo.in` | nginx, static files in `/var/www/quickinfo-site` |
| `api.quickinfo.in` | nginx proxy to Node on `127.0.0.1:7788` (PM2 app `quickinfo-api`) |

The first deploy is steps 1 to 10. Every later deploy is step 11 only.

---

## 1. DNS

At your domain registrar, create three **A records** pointing to the server's public IP:

```
quickinfo.in        A   <server-ip>
www.quickinfo.in    A   <server-ip>
api.quickinfo.in    A   <server-ip>
```

Check from your laptop before step 9. Each name must print the server IP:

```bash
nslookup quickinfo.in
nslookup api.quickinfo.in
```

## 2. Server software (skip what is already installed)

```bash
sudo apt update
sudo apt install -y nginx git rsync curl certbot python3-certbot-nginx

# Node.js 20 LTS, if `node -v` is missing or older than v18
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

sudo npm install -g pm2

# Firewall: allow HTTP and HTTPS
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
```

## 3. Folders and code

Clone both repos side by side under `/var/www`. `deploy/deploy.sh` expects that layout.

```
/var/www/quickinfo-back-end    API source and its .env  (never served by nginx)
/var/www/quickinfo-front-end   website source; builds into dist/
/var/www/quickinfo-site        the published website     (nginx root)
```

```bash
cd /var/www
sudo git clone https://github.com/shivakumarKirigeri641/quickinfo-back-end.git
sudo git clone https://github.com/shivakumarKirigeri641/quickinfo-front-end.git
sudo mkdir -p /var/www/quickinfo-site

# Your user owns them, so npm, git pull and pm2 run without sudo
sudo chown -R $USER:$USER /var/www/quickinfo-back-end /var/www/quickinfo-front-end /var/www/quickinfo-site
```

nginx serves only `/var/www/quickinfo-site`, never the repo folders, so the back-end `.env` is not reachable from the web.

## 4. Back-end `.env`

```bash
cd /var/www/quickinfo-back-end
cp .env.example .env
chmod 600 .env
nano .env
```

Fill it in like this:

```ini
PORT=7788
CORS_ORIGINS=https://quickinfo.in,https://www.quickinfo.in
SECRET_KEY=<paste output of: openssl rand -hex 32>

# Same values as serverpe-back-end/.env on this server
PGHOST=localhost
PGPORT=5432
PGDATABASEMAIN=...
PGUSER=...
PGPASSWORD=...

PLATFORM_NAME=QuickInfo
POWERED_BY=ServerPe App Solutions
PUBLIC_WEBSITE=www.quickinfo.in

MAIL_HOST=...
MAIL_PORT=465
MAIL_SECURE=true
NOREPLYMAIL=...
NOREPLYMAIL_PASSWORD=...
MAIL_FROM_NAME=QuickInfo
ADMINMAIL=...

QUICKINFO_WA_ACK_ENABLED=false
```

Generate a **new** `SECRET_KEY` for production; don't reuse the one from your laptop. The website build reads it from this file automatically.

## 5. Install and migrate the database

```bash
cd /var/www/quickinfo-back-end
npm ci --omit=dev
npm run migrate:check     # expect 200, 201, 202 as PENDING
npm run migrate           # creates the quickinfo_* tables and their content
npm run migrate:check     # expect "Schema is up to date."
```

The migrations only add `quickinfo_` tables. ServerPe's tables are not touched.

## 6. Start the API with PM2

```bash
cd /var/www/quickinfo-back-end
mkdir -p logs
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup               # run the command it prints, once, so PM2 starts on boot

curl -s http://127.0.0.1:7788/    # expect {"encrypted":true,...}
pm2 logs quickinfo-api --lines 20 # expect "PostgreSQL connected"
```

## 7. Build and publish the website

```bash
cd /var/www/quickinfo-front-end
npm ci
SECRET_KEY="$(grep -E '^SECRET_KEY=' ../quickinfo-back-end/.env | cut -d= -f2-)"
VITE_API_BASE=https://api.quickinfo.in/api VITE_SECRET_KEY="$SECRET_KEY" npm run build
rsync -a --delete dist/ /var/www/quickinfo-site/
```

## 8. nginx: sites-available and sites-enabled

```bash
sudo cp /var/www/quickinfo-back-end/deploy/nginx-quickinfo.conf /etc/nginx/sites-available/quickinfo
sudo ln -s /etc/nginx/sites-available/quickinfo /etc/nginx/sites-enabled/quickinfo
sudo nginx -t             # must say "syntax is ok" and "test is successful"
sudo systemctl reload nginx
```

`sites-available` holds the config. The link in `sites-enabled` is what turns it on. To take the site offline, remove only the link and reload nginx.

## 9. HTTPS with certbot

Do this only after step 1's DNS check passes.

```bash
sudo certbot --nginx -d quickinfo.in -d www.quickinfo.in -d api.quickinfo.in
# choose "redirect" so http:// goes to https://
sudo certbot renew --dry-run   # confirms auto-renewal works
```

## 10. Verify

```bash
curl -I https://quickinfo.in/privacy-policy        # 200
curl -s https://api.quickinfo.in/                   # {"encrypted":true,...}
curl -s https://api.quickinfo.in/api/quickinfo/platform/public/services | head -c 80
```

Then in a browser:

1. Open https://quickinfo.in. The six solution cards should load.
2. Open the Privacy Policy and Terms pages and reload each. Both should show content, not a 404.
3. Submit one real enquiry with your own email. Confirm the thank-you email and the admin alert both arrive.

---

## 11. Every later deploy

Push your changes to GitHub, then on the server:

```bash
cd /var/www/quickinfo-back-end
chmod +x deploy/deploy.sh     # first time only
./deploy/deploy.sh
```

It pulls both repos, installs dependencies and runs any new migrations. Then it builds and publishes the website and reloads the API.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Site loads but cards and policies fail | Browser console. A CORS error means `CORS_ORIGINS` is missing the exact site URL. A decrypt error means the site was built with a different `SECRET_KEY`. Rerun step 7 |
| 502 Bad Gateway on api.quickinfo.in | `pm2 status` and `pm2 logs quickinfo-api` |
| `/privacy-policy` gives 404 on reload | The `try_files` line in the nginx config is missing or the config was not reloaded |
| API logs "Connection failed" | `PG*` values in `.env`. Compare with serverpe-back-end's `.env` |
| No emails | `MAIL_*` values in `.env`. Failures are logged as "notification failed" in `pm2 logs` |
