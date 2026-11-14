import pool from "./db.js";

export const httpError = (status, message) => Object.assign(new Error(message), { status });

// ---------- cleaning helpers (never trust the browser) ----------
const s = (v, max) => String(v ?? "").trim().slice(0, max);
const arr = (v, max, len = 60) => (Array.isArray(v) ? v : []).map((x) => s(x, max)).filter(Boolean).slice(0, len);
export const safeUrl = (v) => {
  const t = s(v, 2000);
  return /^(https?:\/\/|\/(?!\/))/i.test(t) ? t : "";
};
const KEYS = ["pk", "fk", "uq"];

function cleanErd(e) {
  if (!e || !Array.isArray(e.tables)) return null;
  const tables = e.tables.slice(0, 40).map((t) => ({
    name: s(t.name, 80),
    x: t.x == null || !Number.isFinite(+t.x) ? null : Math.round(+t.x),
    y: t.y == null || !Number.isFinite(+t.y) ? null : Math.round(+t.y),
    cols: (Array.isArray(t.cols) ? t.cols : []).slice(0, 60)
      .map((c) => ({ n: s(c.n, 80), t: s(c.t, 60) || "TEXT", k: KEYS.includes(c.k) ? c.k : null }))
      .filter((c) => c.n),
  })).filter((t) => t.name);
  const relations = (Array.isArray(e.relations) ? e.relations : []).slice(0, 80)
    .map((r) => ({ from: s(r.from, 170), to: s(r.to, 170), kind: r.kind === "1:1" ? "1:1" : "N:1" }))
    .filter((r) => r.from.includes(".") && r.to.includes("."));
  return tables.length ? { tables, relations } : null;
}

export function cleanProject(b) {
  const f = b.fullProject || {}, a = f.architecture || {}, u = f.uml || {}, l = f.links || {}, d = f.demo || {}, st = f.stack || {};
  const slug = s(b.slug, 80).toLowerCase();
  const name = s(b.name, 150);
  if (!name) throw httpError(400, "Name is required.");
  if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(slug)) throw httpError(400, "The page address can only use lowercase letters, numbers and single dashes.");
  const year = Number(f.year);
  return {
    slug, name,
    summary: s(b.info, 400),
    category: ["web", "mobile", "other"].includes(b.category) ? b.category : "web",
    status: ["Planned", "In Progress", "Completed"].includes(b.status) ? b.status : "Planned",
    icon: safeUrl(b.icon), tagline: s(f.tagline, 300), description: s(f.description, 10000),
    year: Number.isInteger(year) && year > 1990 && year < 2100 ? year : null,
    hero: safeUrl(f.heroImage), github: safeUrl(l.github), live: safeUrl(l.liveDemo),
    demoEmbed: Boolean(d.embed), demoHtml: String(d.srcDoc ?? "").slice(0, 50000),
    arch: { pattern: s(a.pattern, 80), frontend: s(a.frontend, 150), backend: s(a.backend, 150), database: s(a.database, 150) },
    uml: { description: s(u.description, 2000), cls: safeUrl(u.classDiagram), seq: safeUrl(u.sequenceDiagram), uc: safeUrl(u.useCaseDiagram) },
    tags: arr(b.tech, 60, 20),
    stack: Object.fromEntries(["languages", "frameworks", "databases", "tools"].map((k) => [k, arr(st[k], 80, 30)])),
    features: arr(f.features, 400, 40), results: arr(f.results, 400, 20),
    challenges: (Array.isArray(f.challenges) ? f.challenges : [])
      .map((c) => ({ problem: s(c?.problem, 2000), solution: s(c?.solution, 2000) })).filter((c) => c.problem).slice(0, 30),
    wireframes: (Array.isArray(f.wireframes) ? f.wireframes : []).map(safeUrl).filter(Boolean).slice(0, 30),
    gallery: (Array.isArray(f.gallery) ? f.gallery : []).map(safeUrl).filter(Boolean).slice(0, 30),
    erd: cleanErd(f.erd),
  };
}

// ---------- reading ----------
const group = (rows, key) => rows.reduce((m, r) => ((m[r[key]] ||= []).push(r), m), {});

export async function loadPortfolio() {
  const q = (sql) => pool.query(sql).then((r) => r.rows);
  const [profile, hl, sg, sk, pj, tg, st, ft, rs, ch, im, et, ec, er, ex] = await Promise.all([
    q("SELECT * FROM profile WHERE id = 1"),
    q("SELECT content FROM profile_highlights ORDER BY sort_order"),
    q("SELECT id, title, description FROM skill_groups ORDER BY sort_order"),
    q("SELECT group_id, name FROM skills ORDER BY group_id, sort_order"),
    q("SELECT * FROM projects ORDER BY sort_order, id"),
    q("SELECT project_id, tag FROM project_tags ORDER BY project_id, sort_order"),
    q("SELECT project_id, kind, name FROM project_stack ORDER BY project_id, sort_order"),
    q("SELECT project_id, content FROM project_features ORDER BY project_id, sort_order"),
    q("SELECT project_id, content FROM project_results ORDER BY project_id, sort_order"),
    q("SELECT project_id, problem, solution FROM project_challenges ORDER BY project_id, sort_order"),
    q("SELECT project_id, kind, url FROM project_images ORDER BY project_id, sort_order"),
    q("SELECT id, project_id, name, pos_x, pos_y FROM erd_tables ORDER BY project_id, sort_order"),
    q("SELECT table_id, name, data_type, key_type FROM erd_columns ORDER BY table_id, sort_order"),
    q("SELECT project_id, from_ref, to_ref, kind FROM erd_relations ORDER BY project_id, sort_order"),
    q("SELECT kind, title, org, location, start_label, end_label, description FROM experience ORDER BY sort_order"),
  ]);
  const [tgG, stG, ftG, rsG, chG, imG, etG, erG, ecG] = [tg, st, ft, rs, ch, im, et, er].map((r) => group(r, "project_id")).concat(group(ec, "table_id"));
  const p = profile[0];

  const projects = pj.map((r) => {
    const tables = (etG[r.id] || []).map((t, i) => ({
      name: t.name, x: t.pos_x ?? (i % 3) * 320 + 20, y: t.pos_y ?? Math.floor(i / 3) * 220 + 20,
      cols: (ecG[t.id] || []).map((c) => ({ n: c.name, t: c.data_type, ...(c.key_type ? { k: c.key_type } : {}) })),
    }));
    const images = imG[r.id] || [];
    const stack = stG[r.id] || [];
    return {
      slug: r.slug, name: r.name, info: r.summary, category: r.category, status: r.status, icon: r.icon_url,
      tech: (tgG[r.id] || []).map((x) => x.tag),
      fullProject: {
        title: r.name, tagline: r.tagline, description: r.description, year: r.year_built ?? "", heroImage: r.hero_url,
        stack: Object.fromEntries(["languages", "frameworks", "databases", "tools"].map((k) => [k, stack.filter((x) => x.kind === k).map((x) => x.name)])),
        features: (ftG[r.id] || []).map((x) => x.content),
        results: (rsG[r.id] || []).map((x) => x.content),
        challenges: (chG[r.id] || []).map((x) => ({ problem: x.problem, solution: x.solution })),
        architecture: { pattern: r.arch_pattern, frontend: r.arch_frontend, backend: r.arch_backend, database: r.arch_database },
        uml: { description: r.uml_description, classDiagram: r.uml_class_url, sequenceDiagram: r.uml_sequence_url, useCaseDiagram: r.uml_usecase_url },
        wireframes: images.filter((x) => x.kind === "wireframe").map((x) => x.url),
        gallery: images.filter((x) => x.kind === "screen").map((x) => x.url),
        erd: tables.length ? { tables, relations: (erG[r.id] || []).map((x) => ({ from: x.from_ref, to: x.to_ref, kind: x.kind })) } : null,
        demo: { embed: r.demo_embed, srcDoc: r.demo_html },
        links: { github: r.github_url, liveDemo: r.live_url },
      },
    };
  });

  return {
    profile: p
      ? { name: p.name, role: p.job_title, bio: p.bio, available: p.available, avatar: p.avatar_url, email: p.email, phone: p.phone,
          location: p.location, github: p.github_url, linkedin: p.linkedin_url, resume: p.resume_url, about: hl.map((x) => x.content) }
      : { name: "", role: "", bio: "", available: false, avatar: "", email: "", phone: "", location: "", github: "", linkedin: "", resume: "", about: [] },
    skills: sg.map((g) => ({ title: g.title, desc: g.description, items: sk.filter((x) => x.group_id === g.id).map((x) => x.name) })),
    projects,
    experience: ex.map((x) => ({ kind: x.kind, title: x.title, org: x.org, location: x.location, start: x.start_label, end: x.end_label, desc: x.description })),
  };
}

// ---------- writing ----------
async function insertRows(c, table, cols, rows) {
  if (!rows.length) return;
  const params = [];
  const tuples = rows.map((r) => `(${r.map((v) => (params.push(v), `$${params.length}`)).join(",")})`);
  await c.query(`INSERT INTO ${table} (${cols.join(",")}) VALUES ${tuples.join(",")}`, params);
}

async function inTransaction(fn) {
  const c = await pool.connect();
  try {
    await c.query("BEGIN");
    const out = await fn(c);
    await c.query("COMMIT");
    return out;
  } catch (e) {
    await c.query("ROLLBACK").catch(() => {});
    if (e.code === "23505") throw httpError(409, "Another project already uses that page address.");
    throw e;
  } finally { c.release(); }
}

export async function saveProject(raw, originalSlug) {
  const p = cleanProject(raw);
  await inTransaction(async (c) => {
    const vals = [p.slug, p.name, p.summary, p.category, p.status, p.icon, p.tagline, p.description, p.year, p.hero, p.github, p.live,
      p.demoEmbed, p.demoHtml, p.arch.pattern, p.arch.frontend, p.arch.backend, p.arch.database, p.uml.description, p.uml.cls, p.uml.seq, p.uml.uc];
    let id;
    if (originalSlug) {
      const r = await c.query(
        `UPDATE projects SET slug=$1, name=$2, summary=$3, category=$4, status=$5, icon_url=$6, tagline=$7, description=$8, year_built=$9,
         hero_url=$10, github_url=$11, live_url=$12, demo_embed=$13, demo_html=$14, arch_pattern=$15, arch_frontend=$16, arch_backend=$17,
         arch_database=$18, uml_description=$19, uml_class_url=$20, uml_sequence_url=$21, uml_usecase_url=$22, updated_at=now()
         WHERE slug=$23 RETURNING id`, [...vals, originalSlug]);
      if (!r.rows[0]) throw httpError(404, "Project not found.");
      id = r.rows[0].id;
    } else {
      const r = await c.query(
        `INSERT INTO projects (slug, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url,
         demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database, uml_description, uml_class_url, uml_sequence_url,
         uml_usecase_url, sort_order)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,(SELECT COALESCE(MAX(sort_order),0)+1 FROM projects))
         RETURNING id`, vals);
      id = r.rows[0].id;
    }
    for (const t of ["project_tags", "project_stack", "project_features", "project_results", "project_challenges", "project_images", "erd_tables", "erd_relations"])
      await c.query(`DELETE FROM ${t} WHERE project_id = $1`, [id]);

    await insertRows(c, "project_tags", ["project_id", "sort_order", "tag"], p.tags.map((t, i) => [id, i + 1, t]));
    await insertRows(c, "project_stack", ["project_id", "kind", "sort_order", "name"],
      Object.entries(p.stack).flatMap(([k, list]) => list.map((n, i) => [id, k, i + 1, n])));
    await insertRows(c, "project_features", ["project_id", "sort_order", "content"], p.features.map((t, i) => [id, i + 1, t]));
    await insertRows(c, "project_results", ["project_id", "sort_order", "content"], p.results.map((t, i) => [id, i + 1, t]));
    await insertRows(c, "project_challenges", ["project_id", "sort_order", "problem", "solution"], p.challenges.map((x, i) => [id, i + 1, x.problem, x.solution]));
    await insertRows(c, "project_images", ["project_id", "kind", "sort_order", "url"],
      [...p.wireframes.map((u, i) => [id, "wireframe", i + 1, u]), ...p.gallery.map((u, i) => [id, "screen", i + 1, u])]);
    if (p.erd) {
      for (const [ti, t] of p.erd.tables.entries()) {
        const r = await c.query("INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ($1,$2,$3,$4,$5) RETURNING id", [id, ti + 1, t.name, t.x, t.y]);
        await insertRows(c, "erd_columns", ["table_id", "sort_order", "name", "data_type", "key_type"], t.cols.map((col, ci) => [r.rows[0].id, ci + 1, col.n, col.t, col.k]));
      }
      await insertRows(c, "erd_relations", ["project_id", "sort_order", "from_ref", "to_ref", "kind"], p.erd.relations.map((r, i) => [id, i + 1, r.from, r.to, r.kind]));
    }
  });
  return (await loadPortfolio()).projects.find((x) => x.slug === p.slug);
}

export async function deleteProject(slug) {
  const r = await pool.query("DELETE FROM projects WHERE slug = $1", [slug]);
  if (!r.rowCount) throw httpError(404, "Project not found.");
}

export async function saveProfile(b) {
  const name = s(b.name, 120);
  if (!name) throw httpError(400, "Name is required.");
  await inTransaction(async (c) => {
    await c.query(
      `INSERT INTO profile (id, name, job_title, bio, available, avatar_url, email, phone, location, github_url, linkedin_url, resume_url)
       VALUES (1,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, job_title=EXCLUDED.job_title, bio=EXCLUDED.bio, available=EXCLUDED.available,
         avatar_url=EXCLUDED.avatar_url, email=EXCLUDED.email, phone=EXCLUDED.phone, location=EXCLUDED.location,
         github_url=EXCLUDED.github_url, linkedin_url=EXCLUDED.linkedin_url, resume_url=EXCLUDED.resume_url, updated_at=now()`,
      [name, s(b.role, 120), s(b.bio, 2000), Boolean(b.available), safeUrl(b.avatar), s(b.email, 255), s(b.phone, 60), s(b.location, 255), safeUrl(b.github), safeUrl(b.linkedin), safeUrl(b.resume)]);
    await c.query("DELETE FROM profile_highlights");
    await insertRows(c, "profile_highlights", ["sort_order", "content"], arr(b.about, 300, 12).map((t, i) => [i + 1, t]));
  });
  return (await loadPortfolio()).profile;
}

export async function saveSkills(groups) {
  if (!Array.isArray(groups)) throw httpError(400, "Skills must be a list.");
  await inTransaction(async (c) => {
    await c.query("DELETE FROM skill_groups");
    for (const [i, g] of groups.slice(0, 30).entries()) {
      const title = s(g.title, 120);
      if (!title) continue;
      const r = await c.query("INSERT INTO skill_groups (sort_order, title, description) VALUES ($1,$2,$3) RETURNING id", [i + 1, title, s(g.desc, 300)]);
      await insertRows(c, "skills", ["group_id", "sort_order", "name"], arr(g.items, 80, 60).map((n, k) => [r.rows[0].id, k + 1, n]));
    }
  });
  return (await loadPortfolio()).skills;
}

// ---------- experience (work + education) ----------
export const saveExperience = async (list) => {
    if (!Array.isArray(list)) throw httpError(400, "Experience must be a list.");
    const ALE = list.slice(0, 40)
        .map((x) => ({ kind: x?.kind === "education" ? "education" : "work", title: s(x?.title, 150), org: s(x?.org, 150), location: s(x?.location, 150),
            start: s(x?.start, 40), end: s(x?.end, 40), desc: s(x?.desc, 2000) }))
        .filter((x) => x.title);

    await inTransaction(async (c) => {
        await c.query("DELETE FROM experience");
        await insertRows(c, "experience", ["sort_order", "kind", "title", "org", "location", "start_label", "end_label", "description"],
            ALE.map((x, i) => [i + 1, x.kind, x.title, x.org, x.location, x.start, x.end, x.desc]));
    });
    return (await loadPortfolio()).experience;
};

// ---------- messages ----------
export const listMessages = () =>
  pool.query('SELECT id, name, email, body, is_read AS "read", created_at AS "at" FROM messages ORDER BY created_at DESC LIMIT 500').then((r) => r.rows);
