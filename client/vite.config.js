import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// The website talks to the Express server through these proxies (server runs on port 4000).
const api = { "/api": "http://localhost:4000", "/uploads": "http://localhost:4000" }

export default defineConfig({
  plugins: [react()],
  server: { proxy: api },
  preview: { proxy: api },
})
