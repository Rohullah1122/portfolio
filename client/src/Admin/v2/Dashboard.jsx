import { Link } from "react-router-dom";
import { useStore } from "../../store/portfolio";

export default function Dashboard() {
  const { projects, messages } = useStore();
  const count = (fn) => projects.filter(fn).length;
  const stats = [
    ["Projects", projects.length],
    ["Completed", count((p) => p.status === "Completed")],
    ["With DB design", count((p) => p.fullProject?.erd?.tables?.length)],
    ["Unread messages", messages.filter((m) => !m.read).length],
  ];
  const gaps = (p) => {
    const f = p.fullProject || {};
    return [!f.wireframes?.filter(Boolean).length && "wireframes", !f.uml?.classDiagram && "UML", !f.erd?.tables?.length && "database design", !(f.demo?.srcDoc || f.demo?.embed) && "demo"].filter(Boolean);
  };
  return (
    <div className="max-w-5xl">
      <h1 className="font-display text-3xl font-bold text-white">Dashboard</h1>
      <p className="text-mute mt-1">Everything you change here appears on your public site immediately.</p>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mt-8">
        {stats.map(([k, v]) => (
          <div key={k} className="rounded-xl border border-line bg-panel p-5">
            <p className="text-sm text-mute">{k}</p>
            <p className="font-display text-4xl font-bold text-white mt-2">{v}</p>
          </div>
        ))}
      </div>
      <h2 className="font-display text-xl font-semibold text-white mt-10">Case studies that need content</h2>
      <ul className="mt-4 divide-y divide-line rounded-xl border border-line bg-panel">
        {projects.filter((p) => gaps(p).length).map((p) => (
          <li key={p.slug} className="flex flex-wrap items-center justify-between gap-2 px-5 py-4">
            <div><p className="text-white">{p.name}</p><p className="text-sm text-mute">Missing: {gaps(p).join(", ")}</p></div>
            <Link to={`/admin/projects/${p.slug}`} className="text-sm text-mint! no-underline! hover:underline!">Edit</Link>
          </li>
        ))}
        {!projects.some((p) => gaps(p).length) && <li className="px-5 py-4 text-mute">Every project is complete.</li>}
      </ul>
    </div>
  );
}
