import "dotenv/config";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import express from "express";
import cors from "cors";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import pool from "./db.js";
import { deleteProject, httpError, listMessages, loadPortfolio, saveExperience, saveProfile, saveProject, saveSkills } from "./data.js";
import { chatReply, logChat, refreshPortfolio } from "./ai.js";

const { JWT_SECRET, CLIENT_ORIGIN = "http://localhost:5173", BLOB_READ_WRITE_TOKEN, VERCEL } = process.env;
const envsecret = JWT_SECRET && JWT_SECRET.length >= 32 && !JWT_SECRET.startsWith("change-this") ? JWT_SECRET : null;
// local: needs JWT_SECRET in .env. Vercel: if JWT_SECRET isn't set, the secret made by the database setup is used.
export const setupok = Boolean(process.env.DATABASE_URL && (envsecret || VERCEL));

let jwtsecret = envsecret;
const getsecret = async () => {
  if (jwtsecret) return jwtsecret;
  const r = await pool.query("SELECT value FROM app_settings WHERE key = 'jwt_secret'");
  if (!r.rows[0]) throw httpError(500, "Login is not set up yet. Redeploy so the database setup can run.");
  return (jwtsecret = r.rows[0].value);
};

// on Vercel the disk is read-only, so uploads go to Vercel Blob; on your computer they go to server/uploads
const uploadsDir = VERCEL ? path.join("/tmp", "uploads") : path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "uploads");
fs.mkdirSync(uploadsDir, { recursive: true });
const DUMMY_HASH = bcrypt.hashSync("not-a-real-password", 10);
const str = (v, max) => String(v ?? "").trim().slice(0, max);

// ---- tiny in-memory rate limiter ----
const hits = new Map();
const limit = (name, max, windowMs) => (req, res, next) => {
  const key = `${name}:${req.ip}`, now = Date.now();
  const recent = (hits.get(key) || []).filter((t) => now - t < windowMs);
  if (recent.length >= max) return res.status(429).json({ error: "Too many requests. Please try again later." });
  recent.push(now); hits.set(key, recent); next();
};
setInterval(() => { const now = Date.now(); for (const [k, v] of hits) if (!v.some((t) => now - t < 3_600_000)) hits.delete(k); }, 600_000).unref();

const h = (fn) => (req, res, next) => fn(req, res, next).catch(next);
const app = express();
app.use(cors({ origin: CLIENT_ORIGIN }));
app.use((req, res, next) => { res.set({ "X-Content-Type-Options": "nosniff", "Referrer-Policy": "strict-origin-when-cross-origin" }); next(); });
app.use(express.json({ limit: "8mb" }));
app.use("/api", (req, res, next) => (setupok ? next() : res.status(500).json({ error: "Server setup problem: DATABASE_URL and a JWT_SECRET of 32+ characters are needed." })));
app.use("/uploads", express.static(uploadsDir, { maxAge: "7d" }));

async function requireAdmin(req, res, next) {
  const token = (req.headers.authorization || "").replace(/^Bearer /, "");
  let secret;
  try { secret = await getsecret(); } catch (e) { return next(e); }
  try { req.admin = jwt.verify(token, secret); next(); }
  catch { res.status(401).json({ error: "Please sign in again." }); }
}

// ---------- public ----------
app.get("/api/health", h(async (req, res) => { await pool.query("SELECT 1"); res.json({ ok: true }); }));
app.get("/api/portfolio", h(async (req, res) => res.json(await loadPortfolio())));

app.post("/api/messages", limit("message", 5, 3_600_000), h(async (req, res) => {
  const name = str(req.body.name, 120), email = str(req.body.email, 255), body = str(req.body.body, 5000);
  if (!name || !/^\S+@\S+\.\S+$/.test(email) || body.length < 10) throw httpError(400, "Please fill in your name, a valid email and a message of at least 10 characters.");
  await pool.query("INSERT INTO messages (name, email, body) VALUES ($1,$2,$3)", [name, email, body]);
  res.status(201).json({ ok: true });
}));

app.post("/api/chat", limit("chat", 20, 600_000), h(async (req, res) => {
  const sessionId = /^[0-9a-f-]{36}$/i.test(req.body.sessionId || "") ? req.body.sessionId : crypto.randomUUID();
  let history = (Array.isArray(req.body.messages) ? req.body.messages : [])
    .filter((m) => (m?.role === "user" || m?.role === "assistant") && typeof m.content === "string" && m.content.trim())
    .map((m) => ({ role: m.role, content: m.content.trim().slice(0, 1000) })).slice(-10);
  while (history.length && history[0].role !== "user") history.shift();
  if (!history.length || history[history.length - 1].role !== "user") throw httpError(400, "Please type a question.");
  const reply = await chatReply(history);
  logChat(sessionId, history[history.length - 1].content, reply);
  res.json({ reply });
}));

// ---------- admin login ----------
app.post("/api/auth/login", limit("login", 10, 900_000), h(async (req, res) => {
  const email = str(req.body.email, 255).toLowerCase(), password = String(req.body.password ?? "");
  const r = await pool.query("SELECT id, email, password_hash FROM admins WHERE email = $1", [email]);
  const ok = await bcrypt.compare(password, r.rows[0]?.password_hash || DUMMY_HASH);
  if (!r.rows[0] || !ok) throw httpError(401, "Wrong email or password.");
  res.json({ token: jwt.sign({ sub: r.rows[0].id, email: r.rows[0].email }, await getsecret(), { expiresIn: "7d" }) });
}));

// ---------- admin ----------
const admin = express.Router();
admin.use(requireAdmin);
const changed = (data) => { refreshPortfolio(); return data; };

admin.get("/me", (req, res) => res.json({ email: req.admin.email }));
admin.put("/profile", h(async (req, res) => res.json(changed(await saveProfile(req.body)))));
admin.put("/skills", h(async (req, res) => res.json(changed(await saveSkills(req.body)))));
admin.put("/experience", h(async (req, res) => res.json(changed(await saveExperience(req.body)))));
admin.post("/projects", h(async (req, res) => res.status(201).json(changed(await saveProject(req.body, null)))));
admin.put("/projects/:slug", h(async (req, res) => res.json(changed(await saveProject(req.body, req.params.slug)))));
admin.delete("/projects/:slug", h(async (req, res) => { await deleteProject(req.params.slug); changed(); res.status(204).end(); }));

admin.get("/messages", h(async (req, res) => res.json(await listMessages())));
admin.patch("/messages/:id", h(async (req, res) => {
  await pool.query("UPDATE messages SET is_read = $1 WHERE id = $2", [Boolean(req.body.read), Number(req.params.id) || 0]);
  res.json({ ok: true });
}));
admin.delete("/messages/:id", h(async (req, res) => {
  await pool.query("DELETE FROM messages WHERE id = $1", [Number(req.params.id) || 0]);
  res.status(204).end();
}));

// Images (already shrunk by the admin page) and PDF resumes arrive as a data URL. Saved as files, not in the database.
const filetypes = { "image/png": "png", "image/jpeg": "jpg", "image/webp": "webp", "image/gif": "gif", "application/pdf": "pdf" };
admin.post("/upload", h(async (req, res) => {
  const m = /^data:([a-z]+\/[a-z]+);base64,([A-Za-z0-9+/=]+)$/.exec(req.body.dataUrl || "");
  if (!m || !filetypes[m[1]]) throw httpError(400, "Please upload a PNG, JPG, WebP, GIF image or a PDF.");
  const buf = Buffer.from(m[2], "base64");
  const maxmb = VERCEL ? 3 : 6;
  if (buf.length > maxmb * 1024 * 1024) throw httpError(413, `That file is too large (${maxmb} MB maximum).`);
  if (m[1] === "application/pdf" && buf.subarray(0, 5).toString() !== "%PDF-") throw httpError(400, "That file is not a real PDF.");
  const name = `${crypto.randomBytes(12).toString("hex")}.${filetypes[m[1]]}`;
  if (BLOB_READ_WRITE_TOKEN) {
    const { put } = await import("@vercel/blob");
    const blob = await put(`uploads/${name}`, buf, { access: "public", contentType: m[1] });
    return res.status(201).json({ url: blob.url });
  }
  if (VERCEL) throw httpError(500, "Uploads need Vercel Blob storage. Connect a Blob store to this project in Vercel.");
  await fs.promises.writeFile(path.join(uploadsDir, name), buf);
  res.status(201).json({ url: `/uploads/${name}` });
}));
app.use("/api/admin", admin);

app.use("/api", (req, res) => res.status(404).json({ error: "Not found." }));
app.use((err, req, res, next) => {
  const status = err.status || (err.type === "entity.too.large" ? 413 : 500);
  if (status >= 500) console.error(err);
  res.status(status).json({ error: status < 500 ? err.message : "Something went wrong on the server." });
});

export default app;
