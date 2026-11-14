// Runs the API on your computer. On Vercel, api/index.js uses app.js directly.
import app, { setupok } from "./app.js";

const port = process.env.PORT || 4000;

if (!setupok) {
    console.error("Setup problem: open server/.env and set DATABASE_URL and a real JWT_SECRET (32+ characters). See .env.example.");
    process.exit(1);
}

app.listen(port,() => console.log(`API running on http://localhost:${port}`));
