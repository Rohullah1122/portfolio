# Portfolio: React + Express + PostgreSQL + AI chat

```
client/    the website and admin panel (React + Vite)      runs on http://localhost:5173
server/    the API (Express) and AI chat                    runs on http://localhost:4000
database/  PostgreSQL files to import in pgAdmin
```

You need: **Node.js 18.11+** (nodejs.org, LTS) and **PostgreSQL 12+** (postgresql.org, it installs pgAdmin too).

---

## 1. Create the database in pgAdmin

1. Open pgAdmin and connect to your server (it asks for the `postgres` password you chose at install).
2. Right-click **Databases > Create > Database…**, name it `portfolio`, click **Save**.
3. Right-click the new **portfolio** database > **Query Tool**.
4. Click the **folder icon (Open File)**, choose `database/portfolio_full.sql`, then press **Execute (▶ or F5)**.
5. Right-click **portfolio > Schemas > public > Tables > Refresh**. You should see **17 tables** (projects, profile, skills, messages, and so on) with your sample data inside.

`portfolio_full.sql` is `schema.sql` (tables) followed by `seed.sql` (your current projects, skills and profile). Running it again later wipes the tables and starts fresh.

### Already have the database? Upgrade it to version 2

If you set up the database before, **don't** run `portfolio_full.sql` again (it wipes your admin account and messages). Instead:

1. In pgAdmin, right-click **portfolio** > **Query Tool**.
2. Open `database/update_v2.sql` and press **Execute (F5)**.

It adds the Experience table and resume link, switches project tabs to Web / Mobile / Other, and replaces the sample projects with your real ones. Your admin account, messages and chat history stay. Running it twice is safe.

## 2. Start the server

Open a terminal in the `server` folder:

```
copy .env.example .env
```

Open `server\.env` and set:
- `DATABASE_URL`: replace `YOUR_PG_PASSWORD` with your postgres password. If it contains symbols, encode them (`@` becomes `%40`, `#` becomes `%23`).
- `JWT_SECRET`: any long random text, 32+ characters.

Then (run `npm install` again in **both** folders after this update):

```
npm install
npm run create-admin -- you@example.com "a-long-password"
npm run dev
```

You should see `API running on http://localhost:4000`. Check http://localhost:4000/api/health. It should show `{"ok":true}`.

## 3. Start the website

Open a **second** terminal in the `client` folder:

```
npm install
npm run dev
```

- Website: http://localhost:5173/clients
- Admin: http://localhost:5173/admin (sign in with the email and password from `create-admin`)

In the admin you can also add your **Experience** (jobs and education, shown as a timeline) and upload your **resume PDF** under **Profile > Resume** (adds a Download resume button).

Anything you save in the admin is written to PostgreSQL and shows on the website straight away. Contact form messages land in **Admin > Messages**.

## 4. AI chat (optional)

The chat bubble on your site answers visitors' questions about you, using your own profile, skills and projects as its only source of facts.

- **Without a key** it still works, giving simple answers from your data (no AI).
- **With a key** it uses Claude. Create a key at https://console.anthropic.com (API billing is separate from a claude.ai subscription), put it in `server\.env` as `ANTHROPIC_API_KEY=...`, and restart the server. The key stays on the server and never reaches the browser.
- Limits: 20 questions per 10 minutes per visitor. Conversations are saved in the `chat_messages` table.

## Troubleshooting

| Message | Fix |
|---|---|
| `Setup problem: open server/.env…` | `.env` is missing, or `JWT_SECRET` / `DATABASE_URL` is not set. |
| `password authentication failed` | The password in `DATABASE_URL` is wrong. |
| `ECONNREFUSED 127.0.0.1:5432` | PostgreSQL is not running. Start the service (Windows: Services > postgresql). |
| `database "portfolio" does not exist` | Step 1 was not done, or the name differs from `DATABASE_URL`. |
| `relation "profile" does not exist` | `portfolio_full.sql` was run on a different database. Run it on `portfolio`. |
| Website says "Can't load the portfolio" | The server is not running, or it cannot reach the database. Read the server terminal. |
| Port 4000 already in use | Set `PORT=4001` in `.env` and change both `4000` values in `client/vite.config.js`. |

## Put it online (Vercel)

The repo is ready for Vercel: the React site is built from `client/`, and the Express API runs as one Vercel function (`api/index.js`). Every deploy also runs `server/scripts/migrate.js`, which sets up the database and applies any new files in `database/migrations/`.

1. In Vercel, **Add New > Project** and import this repo. Leave the settings as they are (`vercel.json` has them).
2. In the project, open **Storage** and create a **Neon (Postgres)** database and a **Blob** store, both connected to this project. They add `DATABASE_URL` and `BLOB_READ_WRITE_TOKEN` for you.
3. In **Settings > Environment Variables**, add:
   - `ADMIN_EMAIL` and `ADMIN_PASSWORD`: your admin login (created on the first deploy)
   - `JWT_SECRET` is optional on Vercel: if you leave it out, the database setup makes one
   - `ANTHROPIC_API_KEY` (optional, for the AI chat)
4. **Deployments > Redeploy.** The site is live at your `.vercel.app` address, and the admin is at `/admin`.

To change content later, use the admin panel. Code changes go live when you push to `main`.

## Before putting it online

- Use a strong `JWT_SECRET` and admin password. Vercel serves everything over HTTPS.
- Back up the database now and then (Neon dashboard, or pgAdmin: right-click the database > Backup…).
