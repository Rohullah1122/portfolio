// Brings the database up to date. Runs on every Vercel deploy (and you can run it locally: npm run migrate).
// Each file in database/migrations runs once, in name order, and is remembered in schema_migrations.
// If ADMIN_EMAIL and ADMIN_PASSWORD are set and no admin exists yet, it also creates the first admin.
import "dotenv/config";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import bcrypt from "bcryptjs";
import pool from "../src/db.js";

const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..", "database", "migrations");

const run = async () => {
    if (!process.env.DATABASE_URL) {
        console.log("migrate: no DATABASE_URL, skipping database setup.");
        return;
    }

    await pool.query("CREATE TABLE IF NOT EXISTS schema_migrations (name text PRIMARY KEY, ran_at timestamptz NOT NULL DEFAULT now())");
    const done = new Set((await pool.query("SELECT name FROM schema_migrations")).rows.map((r) => r.name));
    const ALF = fs.readdirSync(dir).filter((f) => f.endsWith(".sql")).sort();

    // a database made before migrations existed already has the tables, so never run the first file (it drops them) there
    const existing = (await pool.query("SELECT to_regclass('public.projects') IS NOT NULL AS yes")).rows[0].yes;
    if (!done.size && existing && ALF[0]) {
        await pool.query("INSERT INTO schema_migrations (name) VALUES ($1)",[ALF[0]]);
        done.add(ALF[0]);
        console.log(`migrate: tables already exist, marked ${ALF[0]} as done`);
    }

    for (const f of ALF) {
        if (done.has(f)) continue;
        const sql = fs.readFileSync(path.join(dir,f),"utf8");
        const c = await pool.connect();
        try {
            await c.query("BEGIN");
            await c.query(sql);
            await c.query("INSERT INTO schema_migrations (name) VALUES ($1)",[f]);
            await c.query("COMMIT");
            console.log(`migrate: ran ${f}`);
        } catch (e) {
            await c.query("ROLLBACK");
            throw new Error(`${f} failed: ${e.message}`);
        } finally {
            c.release();
        }
    }

    const { ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;
    const admins = (await pool.query("SELECT count(*)::int AS n FROM admins")).rows[0].n;
    if (!admins && ADMIN_EMAIL && ADMIN_PASSWORD) {
        if (ADMIN_PASSWORD.length < 10) throw new Error("ADMIN_PASSWORD must be at least 10 characters.");
        const hash = await bcrypt.hash(ADMIN_PASSWORD,12);
        await pool.query("INSERT INTO admins (email, password_hash) VALUES ($1,$2)",[ADMIN_EMAIL.toLowerCase(),hash]);
        console.log(`migrate: created admin ${ADMIN_EMAIL.toLowerCase()}`);
    }
    if (!admins && !(ADMIN_EMAIL && ADMIN_PASSWORD)) console.log("migrate: no admin yet. Set ADMIN_EMAIL and ADMIN_PASSWORD in Vercel, then redeploy.");
};

run()
    .catch((e) => { console.error("migrate:", e.message); process.exitCode = 1; })
    .finally(() => pool.end());
