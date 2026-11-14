import { useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { actions, blankProject, getSaveError, useStore } from "../../store/portfolio";
import { Area, Btn, Card, Input, ImageInput, ImageList, Select, StringList } from "./fields";

const clone = (o) => JSON.parse(JSON.stringify(o));
const slugify = (s) => s.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
const cell = "rounded-md border border-line bg-ink px-2 py-1.5 text-sm text-white focus:border-mint focus:outline-none min-w-0";

function ErdEditor({ value, onChange }) {
  const erd = value || { tables: [], relations: [] };
  const upd = (fn) => { const n = clone(erd); fn(n); onChange(n); };
  const refs = erd.tables.flatMap((t) => t.cols.map((c) => `${t.name}.${c.n}`)).filter((r) => !r.endsWith("."));
  return (
    <div className="space-y-5">
      {erd.tables.map((t, ti) => (
        <div key={ti} className="rounded-lg border border-line p-4 space-y-2">
          <div className="flex gap-2">
            <input aria-label="Table name" value={t.name} placeholder="table_name" onChange={(e) => upd((n) => { n.tables[ti].name = e.target.value; })} className={`${cell} flex-1 font-mono`} />
            <Btn onClick={() => upd((n) => { const gone = n.tables.splice(ti, 1)[0].name; n.relations = n.relations.filter((r) => !r.from.startsWith(gone + ".") && !r.to.startsWith(gone + ".")); })}>Delete table</Btn>
          </div>
          {t.cols.map((c, ci) => (
            <div key={ci} className="grid grid-cols-[1fr_1fr_5rem_auto] gap-2">
              <input aria-label="Column name" value={c.n} placeholder="column" onChange={(e) => upd((n) => { n.tables[ti].cols[ci].n = e.target.value; })} className={`${cell} font-mono`} />
              <input aria-label="Column type" value={c.t} placeholder="VARCHAR(80)" onChange={(e) => upd((n) => { n.tables[ti].cols[ci].t = e.target.value; })} className={`${cell} font-mono`} />
              <select aria-label="Key" value={c.k || ""} onChange={(e) => upd((n) => { n.tables[ti].cols[ci].k = e.target.value || undefined; })} className={cell}>
                <option value="">none</option><option value="pk">PK</option><option value="fk">FK</option><option value="uq">UQ</option>
              </select>
              <Btn aria-label="Remove column" onClick={() => upd((n) => { n.tables[ti].cols.splice(ci, 1); })}>✕</Btn>
            </div>
          ))}
          <Btn onClick={() => upd((n) => { n.tables[ti].cols.push({ n: "", t: "INT" }); })}>+ Column</Btn>
        </div>
      ))}
      <Btn onClick={() => upd((n) => { n.tables.push({ name: "", cols: [{ n: "id", t: "INT", k: "pk" }] }); })}>+ Add table</Btn>

      <div className="space-y-2 pt-2">
        <p className="text-xs uppercase tracking-wide text-mute">Relationships (foreign key points to primary key)</p>
        {erd.relations.map((r, i) => (
          <div key={i} className="grid grid-cols-[1fr_1fr_5rem_auto] gap-2">
            <select aria-label="From column" value={r.from} onChange={(e) => upd((n) => { n.relations[i].from = e.target.value; })} className={`${cell} font-mono`}>
              <option value="">from…</option>{refs.map((x) => <option key={x}>{x}</option>)}
            </select>
            <select aria-label="To column" value={r.to} onChange={(e) => upd((n) => { n.relations[i].to = e.target.value; })} className={`${cell} font-mono`}>
              <option value="">to…</option>{refs.map((x) => <option key={x}>{x}</option>)}
            </select>
            <select aria-label="Kind" value={r.kind} onChange={(e) => upd((n) => { n.relations[i].kind = e.target.value; })} className={cell}><option>N:1</option><option>1:1</option></select>
            <Btn aria-label="Remove relationship" onClick={() => upd((n) => { n.relations.splice(i, 1); })}>✕</Btn>
          </div>
        ))}
        <Btn onClick={() => upd((n) => { n.relations.push({ from: "", to: "", kind: "N:1" }); })}>+ Relationship</Btn>
      </div>
    </div>
  );
}

export default function ProjectEditor() {
  const { slug } = useParams();
  const nav = useNavigate();
  const { projects } = useStore();
  const isNew = slug === "new";
  const found = projects.find((p) => p.slug === slug);
  const [d, setD] = useState(() => (isNew ? blankProject() : found ? clone(found) : null));
  const [slugTouched, setSlugTouched] = useState(!isNew);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  if (!d) return <div><p className="text-white">Project not found.</p><Link to="/admin/projects" className="text-mint!">Back to projects</Link></div>;

  const get = (path) => path.split(".").reduce((o, k) => o?.[k], d);
  const set = (path, val) => setD((prev) => {
    const n = clone(prev); const keys = path.split("."); let o = n;
    keys.slice(0, -1).forEach((k) => { o = o[k] ??= {}; });
    o[keys[keys.length - 1]] = val;
    return n;
  });
  const text = (path) => ({ value: get(path) ?? "", onChange: (e) => set(path, e.target.value) });
  const list = (path) => ({ value: get(path) || [], onChange: (v) => set(path, v) });
  const challenges = get("fullProject.challenges") || [];

  const save = async () => {
    if (!d.name.trim()) return setError("Give the project a name.");
    const s = slugify(d.slug || d.name);
    if (!s) return setError("The address (slug) can only use letters, numbers and dashes.");
    if (projects.some((p) => p.slug === s && p.slug !== (isNew ? null : slug))) return setError(`Another project already uses “${s}”.`);
    const out = clone(d);
    out.slug = s;
    out.tech = out.tech.filter(Boolean);
    out.fullProject.title ||= out.name;
    out.fullProject.erd?.tables.forEach((t, i) => { t.x ??= (i % 3) * 320 + 20; t.y ??= Math.floor(i / 3) * 220 + 20; });
    setSaving(true); setError("");
    const ok = await actions.saveProject(out, isNew ? null : slug);
    setSaving(false);
    if (!ok) return setError(getSaveError());
    nav("/admin/projects");
  };

  return (
    <div className="max-w-4xl pb-28">
      <Link to="/admin/projects" className="text-sm text-mute! no-underline! hover:text-white!">‹ Projects</Link>
      <h1 className="font-display text-3xl font-bold text-white mt-3">{isNew ? "New project" : d.name || "Edit project"}</h1>

      <div className="mt-8 space-y-6">
        <Card title="Basics" hint="Shown on the project card and at the top of the case-study page.">
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Name" value={d.name} onChange={(e) => { set("name", e.target.value); if (!slugTouched) set("slug", slugify(e.target.value)); }} />
            <Input label="Page address (slug)" value={d.slug} onChange={(e) => { setSlugTouched(true); set("slug", e.target.value); }} />
            <Select label="Status" options={["Planned", "In Progress", "Completed"]} {...text("status")} />
            <Select label="Shown under tab" options={["web", "mobile", "other"]} {...text("category")} />
            <Input label="Year" {...text("fullProject.year")} />
            <Input label="Tagline" {...text("fullProject.tagline")} />
          </div>
          <Input label="Card summary (one line)" {...text("info")} />
          <Area label="Full description" rows={5} {...text("fullProject.description")} />
          <StringList label="Card tags" placeholder="React" {...list("tech")} />
          <ImageInput label="Card icon" value={d.icon} onChange={(v) => set("icon", v)} />
          <ImageInput label="Hero image" value={get("fullProject.heroImage")} onChange={(v) => set("fullProject.heroImage", v)} />
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="GitHub link" {...text("fullProject.links.github")} />
            <Input label="Live demo link" {...text("fullProject.links.liveDemo")} />
          </div>
        </Card>

        <Card title="Tech stack">
          <div className="grid gap-6 md:grid-cols-2">
            {["languages", "frameworks", "databases", "tools"].map((k) => <StringList key={k} label={k[0].toUpperCase() + k.slice(1)} {...list(`fullProject.stack.${k}`)} />)}
          </div>
        </Card>

        <Card title="Content">
          <StringList label="Key features" {...list("fullProject.features")} />
          <StringList label="Results" placeholder="Cut load time by 40%" {...list("fullProject.results")} />
          <div role="group" aria-label="Challenges" className="space-y-3">
            <p className="text-xs uppercase tracking-wide text-mute">Challenges and solutions</p>
            {challenges.map((c, i) => (
              <div key={i} className="grid gap-2 rounded-lg border border-line p-3">
                <Input label="Problem" value={c.problem || ""} onChange={(e) => set("fullProject.challenges", challenges.map((x, n) => (n === i ? { ...x, problem: e.target.value } : x)))} />
                <Input label="Solution" value={c.solution || ""} onChange={(e) => set("fullProject.challenges", challenges.map((x, n) => (n === i ? { ...x, solution: e.target.value } : x)))} />
                <Btn onClick={() => set("fullProject.challenges", challenges.filter((_, n) => n !== i))}>Remove</Btn>
              </div>
            ))}
            <Btn onClick={() => set("fullProject.challenges", [...challenges, { problem: "", solution: "" }])}>+ Add challenge</Btn>
          </div>
        </Card>

        <Card title="Architecture" hint="Appears as the Architecture tab. Leave the pattern empty to hide it.">
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Pattern" placeholder="MVC" {...text("fullProject.architecture.pattern")} />
            <Input label="Frontend" {...text("fullProject.architecture.frontend")} />
            <Input label="Backend" {...text("fullProject.architecture.backend")} />
            <Input label="Database" {...text("fullProject.architecture.database")} />
          </div>
        </Card>

        <Card title="Design" hint="Wireframes and finished screens. Visitors can click them to zoom.">
          <ImageList label="Wireframe" {...list("fullProject.wireframes")} />
          <ImageList label="Screen" {...list("fullProject.gallery")} />
        </Card>

        <Card title="UML diagrams">
          <Input label="Description" {...text("fullProject.uml.description")} />
          <ImageInput label="Class diagram" value={get("fullProject.uml.classDiagram")} onChange={(v) => set("fullProject.uml.classDiagram", v)} />
          <ImageInput label="Sequence diagram" value={get("fullProject.uml.sequenceDiagram")} onChange={(v) => set("fullProject.uml.sequenceDiagram", v)} />
          <ImageInput label="Use case diagram" value={get("fullProject.uml.useCaseDiagram")} onChange={(v) => set("fullProject.uml.useCaseDiagram", v)} />
        </Card>

        <Card title="Database design" hint="Builds the ER diagram and the SQL schema on the Database tab. This is also the plan for your real SQL tables.">
          <ErdEditor value={get("fullProject.erd")} onChange={(v) => set("fullProject.erd", v)} />
        </Card>

        <Card title="Demo" hint="Paste an HTML mock-up to show how the interface looks, or let visitors embed your live site.">
          <label className="flex items-center gap-2 text-sm text-white">
            <input type="checkbox" checked={Boolean(get("fullProject.demo.embed"))} onChange={(e) => set("fullProject.demo.embed", e.target.checked)} />
            Embed my live demo link in the page (only works if that site allows embedding)
          </label>
          <Area label="HTML mock-up" rows={8} placeholder="<h1>My app</h1>" {...text("fullProject.demo.srcDoc")} />
        </Card>
      </div>

      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-panel/95 backdrop-blur md:left-60">
        <div className="mx-auto flex max-w-4xl items-center gap-3 px-5 py-3">
          <p role="alert" className="flex-1 text-sm text-[#ff7b7b]">{error}</p>
          <Btn onClick={() => nav("/admin/projects")}>Cancel</Btn>
          <Btn kind="primary" onClick={save} disabled={saving}>{saving ? "Saving…" : "Save project"}</Btn>
        </div>
      </div>
    </div>
  );
}
