// Usage:  npm run create-admin -- you@example.com "YourLongPassword"
import "dotenv/config";
import bcrypt from "bcryptjs";
import pool from "../src/db.js";

const [email, password] = process.argv.slice(2);
if (!email || !password || password.length < 10 || !/^\S+@\S+\.\S+$/.test(email)) {
  console.error('Usage: npm run create-admin -- you@example.com "password-of-10-or-more-characters"');
  process.exit(1);
}
try {
  const hash = await bcrypt.hash(password, 12);
  await pool.query(
    "INSERT INTO admins (email, password_hash) VALUES ($1,$2) ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash",
    [email.toLowerCase(), hash]);
  console.log(`Admin ready: ${email.toLowerCase()}`);
} catch (e) {
  console.error("Could not create the admin:", e.message);
  process.exitCode = 1;
} finally { await pool.end(); }
