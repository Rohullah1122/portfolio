-- Settings the server keeps for itself. jwt_secret signs admin logins when JWT_SECRET isn't set (on Vercel).
CREATE TABLE IF NOT EXISTS app_settings (
  key   text PRIMARY KEY,
  value text NOT NULL
);

INSERT INTO app_settings (key, value)
VALUES ('jwt_secret', replace(gen_random_uuid()::text || gen_random_uuid()::text || gen_random_uuid()::text, '-', ''))
ON CONFLICT (key) DO NOTHING;
