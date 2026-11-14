import "dotenv/config";
import pg from "pg";

// on Vercel each function keeps only a few connections open
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL, max: process.env.VERCEL ? 3 : 10 });
pool.on("error", (e) => console.error("Database connection problem:", e.message));
export default pool;
