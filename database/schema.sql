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
