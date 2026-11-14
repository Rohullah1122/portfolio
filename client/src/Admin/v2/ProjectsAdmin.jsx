import { useState } from "react";
import { Link } from "react-router-dom";
import { useStore, actions, getSaveError } from "../../store/portfolio";

export default function ProjectsAdmin() {
  const { projects } = useStore();
  const [q, setQ] = useState("");
  const shown = projects.filter((p) => `${p.name} ${p.slug} ${p.status}`.toLowerCase().includes(q.toLowerCase()));
  return (
    <div className="max-w-5xl">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-3xl font-bold text-white">Projects</h1>
        <Link to="/admin/projects/new" className="rounded-lg bg-mint px-4 py-2 text-sm font-semibold text-ink! no-underline!">+ New project</Link>
      </div>
      <input aria-label="Search projects" value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search projects"
        className="mt-6 w-full max-w-sm rounded-lg border border-line bg-panel px-3 py-2 text-sm text-white focus:border-mint focus:outline-none" />
      <ul className="mt-6 divide-y divide-line rounded-xl border border-line bg-panel">
        {shown.map((p) => (
          <li key={p.slug} className="flex flex-wrap items-center gap-4 px-5 py-4">
            <img src={p.icon || p.fullProject?.heroImage} alt="" className="h-12 w-12 rounded-lg object-cover bg-raise" />
            <div className="min-w-0 flex-1">
              <p className="truncate text-white">{p.name}</p>
              <p className="text-sm text-mute">{p.status} · {p.category}</p>
            </div>
            <div className="flex gap-4 text-sm">
              <a href={`/clients/projects/${p.slug}`} target="_blank" rel="noreferrer" className="text-link! no-underline!">View</a>
              <Link to={`/admin/projects/${p.slug}`} className="text-mint! no-underline!">Edit</Link>
              <button onClick={async () => { if (window.confirm(`Delete “${p.name}”?`) && !(await actions.deleteProject(p.slug))) alert(getSaveError()); }} className="text-[#ff7b7b]">Delete</button>
            </div>
          </li>
        ))}
        {!shown.length && <li className="px-5 py-8 text-center text-mute">No projects found.</li>}
      </ul>
    </div>
  );
}
