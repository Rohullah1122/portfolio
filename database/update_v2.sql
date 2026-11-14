-- =====================================================================
-- Update an EXISTING portfolio database to version 2.
-- Keeps your admin account, messages and chat history.
-- Replaces the sample projects with your real ones.
-- pgAdmin: right-click "portfolio" > Query Tool > open this file > Execute (F5)
-- =====================================================================
BEGIN;

ALTER TABLE profile ADD COLUMN IF NOT EXISTS resume_url text NOT NULL DEFAULT '';

CREATE TABLE IF NOT EXISTS experience (
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

-- project tabs are now Web / Mobile / Other
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_category_check;
UPDATE projects SET category = 'web' WHERE category NOT IN ('web','mobile','other');
ALTER TABLE projects ALTER COLUMN category SET DEFAULT 'web';
ALTER TABLE projects ADD CONSTRAINT projects_category_check CHECK (category IN ('web','mobile','other'));

-- profile: city only, GitHub link
UPDATE profile SET location = 'Airdrie, Alberta, Canada', github_url = 'https://github.com/Rohullah1122', updated_at = now() WHERE id = 1;
DELETE FROM profile_highlights;
INSERT INTO profile_highlights (sort_order, content) VALUES
  (1, 'Built 5 Android apps in Java with Firebase and SQLite'),
  (2, 'Full stack web with React, Node.js, Express and PostgreSQL'),
  (3, 'Real features: sign-in, chat, admin panels, uploads and AI');

-- skills: add the databases and language your projects use
INSERT INTO skills (group_id, sort_order, name)
SELECT g.id, 90 + v.n, v.name FROM skill_groups g
CROSS JOIN (VALUES (1, 'PostgreSQL'), (2, 'SQLite')) AS v(n, name)
WHERE g.title = 'Databases & Cloud' AND NOT EXISTS (SELECT 1 FROM skills s WHERE s.group_id = g.id AND s.name = v.name);
INSERT INTO skills (group_id, sort_order, name)
SELECT g.id, 90, 'Java' FROM skill_groups g
WHERE g.title = 'Mobile Development' AND NOT EXISTS (SELECT 1 FROM skills s WHERE s.group_id = g.id AND s.name = 'Java');

-- projects: remove the samples, add the real ones
DELETE FROM projects WHERE slug IN ('chat-app','saas-dashboard','ai-mobile-app','backend-api','portfolio-website','fitness-app',
  'property-dealer','book-store','blood-bank','note-app','biography');

-- Portfolio Website
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('portfolio-website', 1, 'Portfolio Website', 'This site: a full stack portfolio with an admin panel and an AI assistant.', 'web', 'Completed', '/seed/covers/portfolio-website.svg', 'React front end, Express API, PostgreSQL and a Claude-powered chat', 'The portfolio you are looking at. Every project, skill and profile detail comes from a PostgreSQL database and is edited from a private admin panel, so nothing is hard-coded. Visitors can read full case studies with database diagrams, send a message, or ask the AI assistant questions that it answers only from the portfolio data.', 2026, '/seed/covers/portfolio-website.svg', '', '', false, '', 'Client / REST API', 'React + Vite', 'Node.js + Express', 'PostgreSQL');
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

-- Property Dealer
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('property-dealer', 2, 'Property Dealer', 'Android app for listing houses for rent and finding a place to live.', 'mobile', 'Completed', '/seed/covers/property-dealer.svg', 'Owners post houses, renters browse, save and chat', 'An Android app that connects house owners with people looking to rent. Owners sign in with their phone number and post a house with photos, rent, size and room details. Renters browse and search listings, save the ones they like, rate them and message the owner directly in the app.', 2021, '/seed/covers/property-dealer.svg', 'https://github.com/Rohullah1122/property_dealer', '', false, '', 'Activities + Fragments', 'Android (Java, XML, ViewBinding)', 'Firebase Authentication', 'Firebase Realtime Database + Storage');
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
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('book-store', 3, 'Book Store', 'Android book shop with a customer app and an admin panel.', 'mobile', 'Completed', '/seed/covers/book-store.svg', 'Browse and buy books, while the admin manages stock and sales', 'An Android book store with two sides. Customers browse and search books, read the details, buy them and chat with the store. The admin side adds and updates books with cover images, prices and stock, and reviews sales, purchases and users. A later version added unread message counts.', 2022, '/seed/covers/book-store.svg', 'https://github.com/Rohullah1122/Book_store', '', false, '', 'Activities + Fragments', 'Android (Java, XML, ViewBinding)', 'Firebase Authentication', 'Firebase Realtime Database + Storage');
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
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('blood-bank', 4, 'Blood Bank', 'Android app to find blood donors by blood group and location.', 'mobile', 'Completed', '/seed/covers/blood-bank.svg', 'Find a donor nearby and message them in the app', 'An Android app that helps people find blood donors quickly. Donors create a profile with their blood group, location and photo. Anyone can search by blood group, save donors, rate them and start a conversation in the built-in chat.', 2022, '/seed/covers/blood-bank.svg', 'https://github.com/Rohullah1122/Blood-Bank', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'Firebase Authentication', 'Firebase Realtime Database + Storage');
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
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('note-app', 5, 'Note App', 'Offline notes app for Android using SQLite.', 'mobile', 'Completed', '/seed/covers/note-app.svg', 'Write, edit and delete notes, with no internet needed', 'A simple offline notes app. Notes are stored on the phone in a SQLite database. You can add a note, open and edit it, and long-press to delete it. If you leave without saving, the app asks whether to save or go back.', 2022, '/seed/covers/note-app.svg', 'https://github.com/Rohullah1122/note_app', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'None (offline)', 'SQLite (SQLiteOpenHelper)');
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
INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES
  ('biography', 6, 'Biography', 'Android app for registering people with their photo and details.', 'mobile', 'In Progress', '/seed/covers/biography.svg', 'Register a person with a photo, saved on the device', 'An Android app for creating short profiles. A user registers with a name, last name, age, phone number and a photo picked from the gallery. Everything, including the image, is saved in a local SQLite database. The home screen has an image slideshow and a navigation drawer.', 2023, '/seed/covers/biography.svg', 'https://github.com/Rohullah1122/biography', '', false, '', 'Activities + Fragments', 'Android (Java, XML)', 'None (offline)', 'SQLite (SQLiteOpenHelper)');
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

COMMIT;
