-- =====================================================================
-- Portfolio database  |  PostgreSQL 12 or newer  |  import with pgAdmin
-- Run this file first, then seed.sql (or just run portfolio_full.sql).
-- =====================================================================

DROP TABLE IF EXISTS chat_messages, messages, experience, erd_relations, erd_columns, erd_tables,
  project_images, project_challenges, project_results, project_features, project_stack,
  project_tags, projects, skills, skill_groups, profile_highlights, profile, admins CASCADE;

-- Admin accounts (created with: npm run create-admin, in the server folder)
CREATE TABLE admins (
  id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email         varchar(255) NOT NULL UNIQUE,
  password_hash varchar(255) NOT NULL,
  created_at    timestamptz  NOT NULL DEFAULT now()
);

-- Your profile: exactly one row (id is forced to 1)
CREATE TABLE profile (
  id           smallint PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  name         varchar(120) NOT NULL,
  job_title    varchar(120) NOT NULL DEFAULT '',
  bio          text         NOT NULL DEFAULT '',
  available    boolean      NOT NULL DEFAULT true,
  avatar_url   text         NOT NULL DEFAULT '',
  email        varchar(255) NOT NULL DEFAULT '',
  phone        varchar(60)  NOT NULL DEFAULT '',
  location     varchar(255) NOT NULL DEFAULT '',
  github_url   text         NOT NULL DEFAULT '',
  linkedin_url text         NOT NULL DEFAULT '',
  resume_url   text         NOT NULL DEFAULT '',
  updated_at   timestamptz  NOT NULL DEFAULT now()
);

-- "About" cards on the home page
CREATE TABLE profile_highlights (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sort_order smallint     NOT NULL,
  content    varchar(300) NOT NULL
);

-- Work and education timeline
CREATE TABLE experience (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sort_order  smallint     NOT NULL,
  kind        varchar(10)  NOT NULL DEFAULT 'work' CHECK (kind IN ('work','education')),
  title       varchar(150) NOT NULL,
  org         varchar(150) NOT NULL DEFAULT '',
  location    varchar(150) NOT NULL DEFAULT '',
  start_label varchar(40)  NOT NULL DEFAULT '',
  end_label   varchar(40)  NOT NULL DEFAULT '',
  description text         NOT NULL DEFAULT ''
);

-- Skills: groups, then the skills inside each group
CREATE TABLE skill_groups (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sort_order  smallint     NOT NULL,
  title       varchar(120) NOT NULL,
  description varchar(300) NOT NULL DEFAULT ''
);
CREATE TABLE skills (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  group_id   integer     NOT NULL REFERENCES skill_groups(id) ON DELETE CASCADE,
  sort_order smallint    NOT NULL,
  name       varchar(80) NOT NULL
);

-- Projects (one row per case study)
CREATE TABLE projects (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  slug             varchar(80)  NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  sort_order       integer      NOT NULL DEFAULT 0,
  name             varchar(150) NOT NULL,
  summary          varchar(400) NOT NULL DEFAULT '',
  category         varchar(20)  NOT NULL DEFAULT 'web' CHECK (category IN ('web','mobile','other')),
  status           varchar(20)  NOT NULL DEFAULT 'Planned'  CHECK (status IN ('Planned','In Progress','Completed')),
  icon_url         text         NOT NULL DEFAULT '',
  tagline          varchar(300) NOT NULL DEFAULT '',
  description      text         NOT NULL DEFAULT '',
  year_built       smallint,
  hero_url         text         NOT NULL DEFAULT '',
  github_url       text         NOT NULL DEFAULT '',
  live_url         text         NOT NULL DEFAULT '',
  demo_embed       boolean      NOT NULL DEFAULT false,
  demo_html        text         NOT NULL DEFAULT '',
  arch_pattern     varchar(80)  NOT NULL DEFAULT '',
  arch_frontend    varchar(150) NOT NULL DEFAULT '',
  arch_backend     varchar(150) NOT NULL DEFAULT '',
  arch_database    varchar(150) NOT NULL DEFAULT '',
  uml_description  text         NOT NULL DEFAULT '',
  uml_class_url    text         NOT NULL DEFAULT '',
  uml_sequence_url text         NOT NULL DEFAULT '',
  uml_usecase_url  text         NOT NULL DEFAULT '',
  created_at       timestamptz  NOT NULL DEFAULT now(),
  updated_at       timestamptz  NOT NULL DEFAULT now()
);

CREATE TABLE project_tags (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer     NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint    NOT NULL,
  tag        varchar(60) NOT NULL
);
CREATE TABLE project_stack (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer     NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  kind       varchar(12) NOT NULL CHECK (kind IN ('languages','frameworks','databases','tools')),
  sort_order smallint    NOT NULL,
  name       varchar(80) NOT NULL
);
CREATE TABLE project_features (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer      NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint     NOT NULL,
  content    varchar(400) NOT NULL
);
CREATE TABLE project_results (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer      NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint     NOT NULL,
  content    varchar(400) NOT NULL
);
CREATE TABLE project_challenges (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer  NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint NOT NULL,
  problem    text     NOT NULL,
  solution   text     NOT NULL DEFAULT ''
);
-- Wireframes and finished screens
CREATE TABLE project_images (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer     NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  kind       varchar(10) NOT NULL CHECK (kind IN ('wireframe','screen')),
  sort_order smallint    NOT NULL,
  url        text        NOT NULL
);

-- Database design shown on each project: tables, their columns, and relationships
CREATE TABLE erd_tables (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer     NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint    NOT NULL,
  name       varchar(80) NOT NULL,
  pos_x      integer,
  pos_y      integer
);
CREATE TABLE erd_columns (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  table_id   integer     NOT NULL REFERENCES erd_tables(id) ON DELETE CASCADE,
  sort_order smallint    NOT NULL,
  name       varchar(80) NOT NULL,
  data_type  varchar(60) NOT NULL,
  key_type   varchar(2)  CHECK (key_type IN ('pk','fk','uq'))
);
CREATE TABLE erd_relations (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id integer      NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  sort_order smallint     NOT NULL,
  from_ref   varchar(170) NOT NULL,   -- "table.column" holding the foreign key
  to_ref     varchar(170) NOT NULL,   -- "table.column" it points to
  kind       varchar(3)   NOT NULL DEFAULT 'N:1' CHECK (kind IN ('N:1','1:1'))
);

-- Contact form messages
CREATE TABLE messages (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       varchar(120) NOT NULL,
  email      varchar(255) NOT NULL,
  body       text         NOT NULL,
  is_read    boolean      NOT NULL DEFAULT false,
  created_at timestamptz  NOT NULL DEFAULT now()
);

-- AI chat history (one session_id per visitor chat)
CREATE TABLE chat_messages (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  session_id uuid        NOT NULL,
  role       varchar(10) NOT NULL CHECK (role IN ('user','assistant')),
  content    text        NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_skills_group      ON skills(group_id);
CREATE INDEX idx_tags_project      ON project_tags(project_id);
CREATE INDEX idx_stack_project     ON project_stack(project_id);
CREATE INDEX idx_features_project  ON project_features(project_id);
CREATE INDEX idx_results_project   ON project_results(project_id);
CREATE INDEX idx_challenges_project ON project_challenges(project_id);
CREATE INDEX idx_images_project    ON project_images(project_id);
CREATE INDEX idx_erd_tables_project ON erd_tables(project_id);
CREATE INDEX idx_erd_columns_table ON erd_columns(table_id);
CREATE INDEX idx_erd_rel_project   ON erd_relations(project_id);
CREATE INDEX idx_messages_created  ON messages(created_at DESC);
CREATE INDEX idx_chat_session      ON chat_messages(session_id, created_at);
-- Sample data generated from your existing portfolio. Run after schema.sql.

INSERT INTO profile (id, name, job_title, bio, available, avatar_url, email, phone, location, github_url, linkedin_url, resume_url) VALUES
  (1, 'Rohullah Hussaini', 'Full Stack Developer', 'I build modern, scalable web applications with clean UI and efficient backend architecture using React and Node.js.', true, '/seed/avatar.jpg', 'Rohullah.hussaini567@gmail.com', '+1 403 437 8241', 'Airdrie, Alberta, Canada', 'https://github.com/Rohullah1122', '', '');
INSERT INTO profile_highlights (sort_order, content) VALUES
  (1, 'Built 5 Android apps in Java with Firebase and SQLite'),
  (2, 'Full stack web with React, Node.js, Express and PostgreSQL'),
  (3, 'Real features: sign-in, chat, admin panels, uploads and AI');
INSERT INTO skill_groups (sort_order, title, description) VALUES (1, 'Frontend Development', 'Building modern, responsive, accessible user interfaces.');
INSERT INTO skills (group_id, sort_order, name) VALUES
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 1, 'React'),
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 2, 'JavaScript'),
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 3, 'HTML'),
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 4, 'CSS'),
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 5, 'Tailwind'),
  ((SELECT id FROM skill_groups WHERE sort_order = 1), 6, 'Bootstrap');
INSERT INTO skill_groups (sort_order, title, description) VALUES (2, 'Backend & APIs', 'Designing scalable APIs and backend systems.');
INSERT INTO skills (group_id, sort_order, name) VALUES
  ((SELECT id FROM skill_groups WHERE sort_order = 2), 1, 'Node.js'),
  ((SELECT id FROM skill_groups WHERE sort_order = 2), 2, 'Express'),
  ((SELECT id FROM skill_groups WHERE sort_order = 2), 3, 'C#'),
  ((SELECT id FROM skill_groups WHERE sort_order = 2), 4, 'ASP.NET');
INSERT INTO skill_groups (sort_order, title, description) VALUES (3, 'Databases & Cloud', 'Working with structured and cloud-based data.');
INSERT INTO skills (group_id, sort_order, name) VALUES
  ((SELECT id FROM skill_groups WHERE sort_order = 3), 1, 'MongoDB'),
  ((SELECT id FROM skill_groups WHERE sort_order = 3), 2, 'Firebase'),
  ((SELECT id FROM skill_groups WHERE sort_order = 3), 3, 'SQL'),
  ((SELECT id FROM skill_groups WHERE sort_order = 3), 4, 'PostgreSQL'),
  ((SELECT id FROM skill_groups WHERE sort_order = 3), 5, 'SQLite');
INSERT INTO skill_groups (sort_order, title, description) VALUES (4, 'Mobile Development', 'Cross-platform and native mobile applications.');
INSERT INTO skills (group_id, sort_order, name) VALUES
  ((SELECT id FROM skill_groups WHERE sort_order = 4), 1, 'Android (Java)'),
  ((SELECT id FROM skill_groups WHERE sort_order = 4), 3, 'Java'),
  ((SELECT id FROM skill_groups WHERE sort_order = 4), 2, 'Flutter');
INSERT INTO skill_groups (sort_order, title, description) VALUES (5, 'Tools', 'Everyday tools for building and shipping.');
INSERT INTO skills (group_id, sort_order, name) VALUES
  ((SELECT id FROM skill_groups WHERE sort_order = 5), 1, 'VS Code'),
  ((SELECT id FROM skill_groups WHERE sort_order = 5), 2, 'Git'),
  ((SELECT id FROM skill_groups WHERE sort_order = 5), 3, 'NetBeans'),
  ((SELECT id FROM skill_groups WHERE sort_order = 5), 4, 'Visual Studio'),
  ((SELECT id FROM skill_groups WHERE sort_order = 5), 5, 'Android Studio');

-- Portfolio Website
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('portfolio-website', 1, 'Portfolio Website', 'This site: a full stack portfolio with an admin panel and an AI assistant.', 'web', 'Completed', '/seed/covers/portfolio-website.svg', 'React front end, Express API, PostgreSQL and a Claude-powered chat', 'The portfolio you are looking at. Every project, skill and profile detail comes from a PostgreSQL database and is edited from a private admin panel, so nothing is hard-coded. Visitors can read full case studies with database diagrams, send a message, or ask the AI assistant questions that it answers only from the portfolio data.', 2026, '/seed/covers/portfolio-website.svg', '', '', false, '', 'Client / REST API', 'React + Vite', 'Node.js + Express', 'PostgreSQL', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 1, 'React'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 2, 'Node.js'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 3, 'Express'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 4, 'PostgreSQL'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 5, 'Tailwind');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'languages', 1, 'JavaScript'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'languages', 2, 'SQL'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'frameworks', 1, 'React'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'frameworks', 2, 'Express'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'frameworks', 3, 'Tailwind'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'databases', 1, 'PostgreSQL'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'tools', 1, 'VS Code'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'tools', 2, 'Vite'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'tools', 3, 'Git'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 'tools', 4, 'pgAdmin');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 1, 'Admin panel to manage projects, skills, profile, experience and messages'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 2, 'Case study pages with database diagrams, UML and screenshots'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 3, 'Contact form saved to the database, with read and unread messages'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 4, 'AI chat assistant that answers questions about me from my own data'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 5, 'Image and resume uploads, saved as files on the server'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 6, 'Sign-in with hashed passwords and JWT, plus rate limiting');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 1, 'Letting an AI answer questions without making things up', 'The server builds the assistant''s instructions from the database on each request and tells it to use only those facts. Without an API key it falls back to simple answers from the same data.'),
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 2, 'Keeping the admin safe', 'Passwords are hashed with bcrypt, every admin route checks a signed token, and login, chat and contact requests are rate limited.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 1, 'projects', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'projects'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'projects'), 2, 'slug', 'VARCHAR(80)', 'uq'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'projects'), 3, 'name', 'VARCHAR(150)', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'projects'), 4, 'status', 'VARCHAR(20)', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 2, 'project_tags', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'project_tags'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'project_tags'), 2, 'project_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'project_tags'), 3, 'tag', 'VARCHAR(60)', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 3, 'messages', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'messages'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'messages'), 2, 'name', 'VARCHAR(120)', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'messages'), 3, 'email', 'VARCHAR(255)', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'messages'), 4, 'is_read', 'BOOLEAN', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 4, 'admins', 20, 250);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'admins'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'admins'), 2, 'email', 'VARCHAR(255)', 'uq'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'portfolio-website') AND name = 'admins'), 3, 'password_hash', 'VARCHAR(255)', NULL);
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'portfolio-website'), 1, 'project_tags.project_id', 'projects.id', 'N:1');

-- Hussaini's Restaurant
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('hussainis-restaurant', 2, 'Hussaini''s Restaurant', 'Restaurant website: browse the menu, order for pickup or delivery, book a table and ask the AI assistant.', 'web', 'Completed', '/seed/projects/hussainis-restaurant/icon.svg', 'A full restaurant experience in React, from menu to admin dashboard', 'A restaurant website built with React for a college final project (team of two). Customers search and filter the menu by category, diet and price, add items to a cart, order for pickup or delivery, follow their order status, book tables or events, and ask a chat assistant about specials and dietary options. Admins add, edit and remove menu items, update order status and confirm reservations. All data is kept in React state and saved to the browser, so it works without a backend.', 2026, '/seed/projects/hussainis-restaurant/home.webp', 'https://github.com/Rohullah1122/Restaurant-System', 'https://frontend-lake-rho-45.vercel.app/', true, '', 'Single-page app', 'React + React Router', 'None (Part 1 frontend)', 'Browser localStorage', 'Use cases for customers and admins, and the order flow from adding to the cart to the admin updating the status.', '', '/seed/projects/hussainis-restaurant/order_flow.webp', '/seed/projects/hussainis-restaurant/use_cases.webp');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 1, 'React'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 2, 'Vite'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 3, 'React Router');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'languages', 1, 'JavaScript'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'languages', 2, 'CSS'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'frameworks', 1, 'React 18'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'frameworks', 2, 'React Router 6'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'frameworks', 3, 'Vite'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'databases', 1, 'Browser localStorage'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'tools', 1, 'VS Code'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'tools', 2, 'Git'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'tools', 3, 'Vercel');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 1, 'Menu search with category, diet and price filters'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 2, 'Cart with quantities, pickup or delivery'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 3, 'My Orders page with live status updates'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 4, 'Table and event reservations'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 5, 'Chat assistant with quick questions'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 6, 'Admin dashboard for menu, orders and reservations');
INSERT INTO project_images (project_id, kind, sort_order, url) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 1, '/seed/projects/hussainis-restaurant/home.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 2, '/seed/projects/hussainis-restaurant/menu.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 3, '/seed/projects/hussainis-restaurant/cart.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 4, '/seed/projects/hussainis-restaurant/reservation.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 5, '/seed/projects/hussainis-restaurant/ai_assistant.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 6, '/seed/projects/hussainis-restaurant/login.webp'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 'screen', 7, '/seed/projects/hussainis-restaurant/intro.webp');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 1, 'Sharing data between many pages without a backend', 'All shared data lives in App.jsx and is passed down as props; every change is saved to localStorage so nothing is lost on refresh.'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 2, 'Two people working on the same app', 'Each person owned different files, with a written task list, so merges never overwrote each other''s work.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 1, 'menu_items', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 2, 'name', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 3, 'category', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 4, 'price', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 5, 'dietary', 'STRING[]', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'menu_items'), 6, 'available', 'BOOLEAN', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 2, 'orders', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 2, 'customer', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 3, 'type', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 4, 'address', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 5, 'total', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'orders'), 6, 'status', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 3, 'reservations', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 1, 'id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 2, 'customer', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 3, 'date', 'DATE', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 4, 'time', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 5, 'guests', 'INT', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'reservations'), 6, 'status', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 4, 'accounts', 20, 250);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'accounts'), 1, 'email', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'accounts'), 2, 'name', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'hussainis-restaurant') AND name = 'accounts'), 3, 'role', 'STRING', NULL);
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 1, 'orders.customer', 'accounts.email', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'hussainis-restaurant'), 2, 'reservations.customer', 'accounts.email', 'N:1');

-- Rahmani's Junkyard
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('rahmanis-junkyard', 3, 'Rahmani''s Junkyard', 'Online storefront and admin system for a car salvage yard: inventory, sales, customers and suppliers.', 'web', 'Completed', '/seed/projects/rahmanis-junkyard/icon.webp', 'Online storefront and admin system for a car salvage yard', 'A full stack web app that brings a car junkyard online. Customers search vehicles by make and model, submit their own car for sale with four required photos, and contact the business. Staff use a secure admin panel to add vehicles and parts, record sales and payments, manage customers and suppliers, see sales and revenue charts, and reply to messages. Admins can reset their password by email.', 2025, '/seed/projects/rahmanis-junkyard/hero.webp', 'https://github.com/Rohullah1122/Rahmani-s-Group', '', false, '', 'Client / REST API', 'React', 'Node.js + Express', 'SQL database', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 1, 'React'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 2, 'Node.js'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 3, 'Express'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 4, 'SQL');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'languages', 1, 'JavaScript'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'languages', 2, 'SQL'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'frameworks', 1, 'React'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'frameworks', 2, 'Express'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'databases', 1, 'SQL database'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 1, 'VS Code'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 2, 'Git'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 3, 'Multer'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 4, 'Nodemailer'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 5, 'bcrypt'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'tools', 6, 'Passport');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 1, 'Search vehicles by make and model, with photos'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 2, 'Sell My Car form that requires 4 photos'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 3, 'Admin dashboard with sales and purchase charts and total revenue'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 4, 'Add vehicles with supplier, parts, pricing and stock'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 5, 'Manage customers, suppliers and sales, with paid and pending payments'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 6, 'Password reset for admins by email');
INSERT INTO project_images (project_id, kind, sort_order, url) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 1, '/seed/projects/rahmanis-junkyard/welcome_page.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 2, '/seed/projects/rahmanis-junkyard/inventory.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 3, '/seed/projects/rahmanis-junkyard/car_info.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 4, '/seed/projects/rahmanis-junkyard/sell_mycar.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 5, '/seed/projects/rahmanis-junkyard/adming_dashboard.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 6, '/seed/projects/rahmanis-junkyard/add_vehicale.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 7, '/seed/projects/rahmanis-junkyard/vehicle_inventory.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 8, '/seed/projects/rahmanis-junkyard/payments.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 9, '/seed/projects/rahmanis-junkyard/customers.webp'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 'screen', 10, '/seed/projects/rahmanis-junkyard/contact.webp');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 1, 'Turning one car into many sellable parts', 'Each car is stored once, its parts reference it, and inventory tracks stock and status per part, so a single vehicle feeds many sales.'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 2, 'Keeping money records consistent', 'Every purchase and sale also writes a transaction row, so revenue charts and payment status always add up.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 1, 'suppliers', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'suppliers'), 1, 'supplier_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'suppliers'), 2, 'name', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'suppliers'), 3, 'phone', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'suppliers'), 4, 'email', 'VARCHAR', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 2, 'cars', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 1, 'car_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 2, 'supplier_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 3, 'vin_number', 'VARCHAR', 'uq'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 4, 'make', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 5, 'model', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 6, 'year', 'INT', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'cars'), 7, 'purchase_price', 'DECIMAL', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 3, 'parts', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 1, 'part_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 2, 'car_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 3, 'part_name', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 4, 'condition', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 5, 'selling_price', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'parts'), 6, 'status', 'VARCHAR', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 4, 'inventory', 20, 250);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'inventory'), 1, 'inventory_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'inventory'), 2, 'part_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'inventory'), 3, 'quantity', 'INT', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'inventory'), 4, 'status', 'VARCHAR', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 5, 'customers', 340, 250);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'customers'), 1, 'customer_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'customers'), 2, 'First_name', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'customers'), 3, 'Last_name', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'customers'), 4, 'email', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'customers'), 5, 'phone', 'VARCHAR', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 6, 'sales', 660, 250);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 1, 'sale_id', 'INT', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 2, 'customer_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 3, 'part_id', 'INT', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 4, 'price_sold', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 5, 'Amount_paid', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 6, 'Amount_pending', 'DECIMAL', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'rahmanis-junkyard') AND name = 'sales'), 7, 'status', 'VARCHAR', NULL);
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 1, 'cars.supplier_id', 'suppliers.supplier_id', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 2, 'parts.car_id', 'cars.car_id', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 3, 'inventory.part_id', 'parts.part_id', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 4, 'sales.customer_id', 'customers.customer_id', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'rahmanis-junkyard'), 5, 'sales.part_id', 'parts.part_id', 'N:1');

-- Property Dealer
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('property-dealer', 4, 'Property Dealer', 'Android app for listing houses for rent and finding a place to live.', 'mobile', 'Completed', '/seed/covers/property-dealer.svg', 'Owners post houses, renters browse, save and chat', 'An Android app that connects house owners with people looking to rent. Owners sign in with their phone number and post a house with photos, rent, size and room details. Renters browse and search listings, save the ones they like, rate them and message the owner directly in the app.', 2021, '/seed/covers/property-dealer.svg', 'https://github.com/Rohullah1122/property_dealer', '', false, '', 'Activities + Fragments', 'Android (Java, XML, ViewBinding)', 'Firebase Authentication', 'Firebase Realtime Database + Storage', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 1, 'Android (Java)'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 2, 'Firebase');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'languages', 1, 'Java'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'languages', 2, 'XML'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'frameworks', 1, 'Android SDK'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'frameworks', 2, 'Material Components'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'databases', 1, 'Firebase Realtime Database'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'databases', 2, 'Firebase Storage'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'tools', 1, 'Android Studio'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'tools', 2, 'Glide'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 'tools', 3, 'Git');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 1, 'Phone number sign-in with Firebase Authentication'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 2, 'Post a house with photos, rent, rooms, kitchens, washrooms, size and exact location'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 3, 'Browse and search all listings'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 4, 'Save houses to a personal list'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 5, 'In-app chat between renters and owners'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 6, 'Ratings and feedback on houses');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 1, 'The same house could be saved twice', 'Before saving, the app checks the user''s saves for that house id and shows a message if it is already there.'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 2, 'Loading many house photos smoothly', 'Photos are stored in Firebase Storage and loaded with Glide, using a placeholder while they download.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'property-dealer'), 1, 'Users', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'Users'), 1, 'uid', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'Users'), 2, 'username', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'Users'), 3, 'phone', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'Users'), 4, 'userimg', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'property-dealer'), 2, 'houses', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 1, 'hid', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 2, 'userid', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 3, 'houseloc', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 4, 'houserent', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 5, 'numberofroom', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 6, 'type', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'houses'), 7, 'houseimg', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'property-dealer'), 3, 'saves', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'saves'), 1, 'uid', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'property-dealer') AND name = 'saves'), 2, 'hid', 'STRING', 'fk');
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 1, 'houses.userid', 'Users.uid', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 2, 'saves.uid', 'Users.uid', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'property-dealer'), 3, 'saves.hid', 'houses.hid', 'N:1');

-- Book Store
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('book-store', 5, 'Book Store', 'Android book shop with a customer app and an admin panel.', 'mobile', 'Completed', '/seed/covers/book-store.svg', 'Browse and buy books, while the admin manages stock and sales', 'An Android book store with two sides. Customers browse and search books, read the details, buy them and chat with the store. The admin side adds and updates books with cover images, prices and stock, and reviews sales, purchases and users. A later version added unread message counts.', 2022, '/seed/covers/book-store.svg', 'https://github.com/Rohullah1122/Book_store', '', false, '', 'Activities + Fragments', 'Android (Java, XML, ViewBinding)', 'Firebase Authentication', 'Firebase Realtime Database + Storage', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'book-store'), 1, 'Android (Java)'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 2, 'Firebase');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'languages', 1, 'Java'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'languages', 2, 'XML'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'frameworks', 1, 'Android SDK'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'frameworks', 2, 'Material Components'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'databases', 1, 'Firebase Realtime Database'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'databases', 2, 'Firebase Storage'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'tools', 1, 'Android Studio'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'tools', 2, 'Glide'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 'tools', 3, 'Git');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'book-store'), 1, 'Separate customer and admin areas'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 2, 'Admin adds and updates books: cover, author, pages, price and quantity'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 3, 'Customers browse, search and open book details'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 4, 'Purchases recorded as sales the admin can review'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 5, 'Chat between customers and the store, with unread counts'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 6, 'Ratings and feedback');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'book-store'), 1, 'One app for two kinds of users', 'Admin screens live in their own package and layout, and books store the id of the admin who added them.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'book-store'), 1, 'Users', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Users'), 1, 'uid', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Users'), 2, 'username', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Users'), 3, 'userimg', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'book-store'), 2, 'Book', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 1, 'Bookid', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 2, 'Bookname', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 3, 'Bookauthor', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 4, 'bookprice', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 5, 'bquantity', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'Book'), 6, 'badminid', 'STRING', 'fk');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'book-store'), 3, 'sales', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'sales'), 1, 'Bookid', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'sales'), 2, 'bookprice', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'book-store') AND name = 'sales'), 3, 'insertdate', 'STRING', NULL);
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'book-store'), 1, 'Book.badminid', 'Users.uid', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'book-store'), 2, 'sales.Bookid', 'Book.Bookid', 'N:1');

-- Blood Bank
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('blood-bank', 6, 'Blood Bank', 'Android app to find blood donors by blood group and location.', 'mobile', 'Completed', '/seed/covers/blood-bank.svg', 'Find a donor nearby and message them in the app', 'An Android app that helps people find blood donors quickly. Donors create a profile with their blood group, location and photo. Anyone can search by blood group, save donors, rate them and start a conversation in the built-in chat.', 2022, '/seed/covers/blood-bank.svg', 'https://github.com/Rohullah1122/Blood-Bank', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'Firebase Authentication', 'Firebase Realtime Database + Storage', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 1, 'Android (Java)'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 2, 'Firebase');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'languages', 1, 'Java'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'languages', 2, 'XML'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'frameworks', 1, 'Android SDK'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'frameworks', 2, 'Material Components'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'databases', 1, 'Firebase Realtime Database'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'databases', 2, 'Firebase Storage'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'tools', 1, 'Android Studio'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'tools', 2, 'Glide'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 'tools', 3, 'Git');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 1, 'Donor profiles with blood group, location, phone and photo'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 2, 'Search donors by blood group'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 3, 'Save donors to a personal list'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 4, 'In-app messaging between users'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 5, 'List of people you have messaged'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 6, 'Ratings and feedback');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 1, 'Finding the right donor fast', 'Users are filtered by their blood group field, so a search shows only matching donors.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'blood-bank'), 1, 'Users', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 1, 'hid', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 2, 'uname', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 3, 'blooadgroup', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 4, 'location', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 5, 'phone', 'STRING', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Users'), 6, 'img', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'blood-bank'), 2, 'chats', 340, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'chats'), 1, 'messagesID', 'STRING', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'chats'), 2, 'senderID', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'chats'), 3, 'msgs', 'STRING', NULL);
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'blood-bank'), 3, 'Saves', 660, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Saves'), 1, 'uid', 'STRING', 'fk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'blood-bank') AND name = 'Saves'), 2, 'hid', 'STRING', 'fk');
INSERT INTO erd_relations (project_id, sort_order, from_ref, to_ref, kind) VALUES
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 1, 'chats.senderID', 'Users.hid', 'N:1'),
  ((SELECT id FROM projects WHERE slug = 'blood-bank'), 2, 'Saves.hid', 'Users.hid', 'N:1');

-- Note App
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('note-app', 7, 'Note App', 'Offline notes app for Android using SQLite.', 'mobile', 'Completed', '/seed/covers/note-app.svg', 'Write, edit and delete notes, with no internet needed', 'A simple offline notes app. Notes are stored on the phone in a SQLite database. You can add a note, open and edit it, and long-press to delete it. If you leave without saving, the app asks whether to save or go back.', 2022, '/seed/covers/note-app.svg', 'https://github.com/Rohullah1122/note_app', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'None (offline)', 'SQLite (SQLiteOpenHelper)', 'Class diagram from the real code: three activities, a fragment, a list adapter, the note model and the SQLite helper. The flow shows adding, opening, updating and deleting a note.', '/seed/projects/note-app/uml_class.webp', '/seed/projects/note-app/flow.webp', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'note-app'), 1, 'Android (Java)'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 2, 'SQLite');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'languages', 1, 'Java'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'languages', 2, 'XML'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'frameworks', 1, 'Android SDK'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'databases', 1, 'SQLite'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'tools', 1, 'Android Studio'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 'tools', 2, 'Git');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'note-app'), 1, 'Create, read, update and delete notes'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 2, 'Long-press a note to delete it, with a confirmation'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 3, 'Warning when leaving a note without saving'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 4, 'Bottom navigation between notes and new note'),
  ((SELECT id FROM projects WHERE slug = 'note-app'), 5, 'Works fully offline');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'note-app'), 1, 'Losing a note by pressing back', 'The back button is overridden to show a dialog with save and back options, and empty fields are flagged before saving.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'note-app'), 1, 'Notes', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'note-app') AND name = 'Notes'), 1, '_id', 'INTEGER', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'note-app') AND name = 'Notes'), 2, 'notetitle', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'note-app') AND name = 'Notes'), 3, 'Notebody', 'VARCHAR', NULL);

-- Biography
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url) VALUES
  ('biography', 8, 'Biography', 'Android app for registering people with their photo and details.', 'mobile', 'In Progress', '/seed/covers/biography.svg', 'Register a person with a photo, saved on the device', 'An Android app for creating short profiles. A user registers with a name, last name, age, phone number and a photo picked from the gallery. Everything, including the image, is saved in a local SQLite database. The home screen has an image slideshow and a navigation drawer.', 2023, '/seed/covers/biography.svg', 'https://github.com/Rohullah1122/biography', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'None (offline)', 'SQLite (SQLiteOpenHelper)', '', '', '', '');
INSERT INTO project_tags (project_id, sort_order, tag) VALUES
  ((SELECT id FROM projects WHERE slug = 'biography'), 1, 'Android (Java)'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 2, 'SQLite');
INSERT INTO project_stack (project_id, kind, sort_order, name) VALUES
  ((SELECT id FROM projects WHERE slug = 'biography'), 'languages', 1, 'Java'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'languages', 2, 'XML'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'frameworks', 1, 'Android SDK'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'frameworks', 2, 'Material Components'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'databases', 1, 'SQLite'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'tools', 1, 'Android Studio'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'tools', 2, 'Glide'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 'tools', 3, 'Git');
INSERT INTO project_features (project_id, sort_order, content) VALUES
  ((SELECT id FROM projects WHERE slug = 'biography'), 1, 'Registration form with input checks'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 2, 'Pick a photo from the gallery'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 3, 'Photos saved in SQLite as images (BLOB)'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 4, 'Image slideshow on the home screen'),
  ((SELECT id FROM projects WHERE slug = 'biography'), 5, 'Navigation drawer and profile screen');
INSERT INTO project_challenges (project_id, sort_order, problem, solution) VALUES
  ((SELECT id FROM projects WHERE slug = 'biography'), 1, 'Saving a photo without a server', 'The picked image is compressed to PNG bytes and stored in a BLOB column next to the person''s details.');
INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ((SELECT id FROM projects WHERE slug = 'biography'), 1, 'userinfo', 20, 20);
INSERT INTO erd_columns (table_id, sort_order, name, data_type, key_type) VALUES
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 1, '_id', 'INTEGER', 'pk'),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 2, 'name', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 3, 'lastname', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 4, 'age', 'VARCHAR', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 5, 'number', 'INTEGER', NULL),
  ((SELECT id FROM erd_tables WHERE project_id = (SELECT id FROM projects WHERE slug = 'biography') AND name = 'userinfo'), 6, 'image', 'BLOB', NULL);
