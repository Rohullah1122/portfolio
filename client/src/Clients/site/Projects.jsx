import { useState } from "react";
import { Link } from "react-router-dom";
import { useProjects } from "../../api/projects";
import { Chip, Reveal, Section } from "./ui";

const tone = { Completed: "bg-mint/15 text-mint", "In Progress": "bg-white/10 text-white", Planned: "bg-raise text-mute" };
const tabs = [["all", "All"], ["web", "Web"], ["mobile", "Mobile"], ["other", "Other"]];

function artifacts(p) {
  const f = p.fullProject || {};
  return [
    f.wireframes?.some(Boolean) && "Wireframes",
    f.uml?.classDiagram && "UML",
    f.erd?.tables?.length && "Database",
    (f.demo?.srcDoc || f.demo?.embed) && "Demo",
  ].filter(Boolean);
}

function Card({ p }) {
  const img = p.fullProject?.heroImage || p.icon;
  const tags = artifacts(p);
  return (
    <article className="group flex h-full flex-col overflow-hidden rounded-xl border border-line bg-panel transition-colors hover:border-mint/50">
      <div className="aspect-[16/9] overflow-hidden bg-raise">
        {img ? <img src={img} alt="" loading="lazy" className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105" />
          : <div className="grid h-full place-items-center font-display text-5xl text-line">{p.name[0]}</div>}
      </div>
      <div className="flex flex-1 flex-col p-5">
        <span className={`self-start rounded-full px-3 py-1 text-xs ${tone[p.status] || "bg-raise text-mute"}`}>{p.status}</span>
        <h3 className="mt-3 font-display text-xl font-semibold text-white">{p.name}</h3>
        <p className="mt-2 text-mute">{p.info}</p>
        <div className="mt-3 flex flex-wrap gap-2">{p.tech?.slice(0, 4).map((t) => <Chip key={t} name={t} />)}</div>
        {tags.length > 0 && <p className="mt-4 font-mono text-xs text-mute">{tags.join(" · ")}</p>}
        <Link to={`/clients/projects/${p.slug}`} className="mt-auto pt-4 text-sm font-semibold text-mint no-underline after:absolute after:inset-0">
          View case study →
        </Link>
      </div>
    </article>
  );
}

export default function Projects() {
  const projects = useProjects();
  const [tab, setTab] = useState("all");
  const shown = projects.filter((p) => tab === "all" || p.category === tab);
  return (
    <Section id="projects" kicker="projects" title="Selected work.">
      <div role="tablist" aria-label="Filter projects" className="mb-6 flex flex-wrap gap-2">
        {tabs.filter(([id]) => id === "all" || projects.some((p) => p.category === id)).map(([id, label]) => (
          <button key={id} role="tab" aria-selected={tab === id} onClick={() => setTab(id)}
            className={`rounded-lg border px-4 py-2 text-sm transition-colors ${tab === id ? "border-mint bg-mint font-semibold text-ink" : "border-line text-mute hover:text-white"}`}>{label} <span className="opacity-60">{id === "all" ? projects.length : projects.filter((p) => p.category === id).length}</span></button>
        ))}
      </div>
      <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {shown.map((p) => <Reveal key={p.slug}><div className="relative h-full"><Card p={p} /></div></Reveal>)}
      </div>
      {!shown.length && <p className="rounded-xl border border-line bg-panel p-8 text-center text-mute">Nothing here yet.</p>}
    </Section>
  );
}
