import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { useProject } from "../../api/projects";
import { useStore } from "../../store/portfolio";
import ChatWidget from "../site/ChatWidget.jsx";
import ServerError from "../site/ServerError.jsx";
import TechStack from "../Components/TechStack.jsx";
import Features from "../Components/Features.jsx";
import Challenges from "../Components/Challenges.jsx";
import Gallery from "../case/Gallery.jsx";
import UmlViewer from "../case/UmlViewer.jsx";
import ErdDiagram from "../case/ErdDiagram.jsx";
import DemoFrame from "../case/DemoFrame.jsx";

const TABS = [["overview", "Overview"], ["design", "Design"], ["uml", "UML"], ["database", "Database"], ["architecture", "Architecture"], ["demo", "Demo"]];

function Architecture({ a }) {
  const layers = [["Frontend", a.frontend], ["Backend", a.backend], ["Database", a.database]].filter(([, v]) => v && v !== "N/A");
  return (
    <div>
      <p className="text-mute mb-6">Pattern: <span className="text-white font-medium">{a.pattern}</span></p>
      <div className="flex flex-col md:flex-row items-stretch gap-3">
        {layers.map(([name, value], i) => (
          <div key={name} className="flex flex-col md:flex-row items-center gap-3 md:flex-1">
            <div className="w-full flex-1 self-stretch rounded-xl border border-line bg-panel p-5">
              <p className="text-sm text-mute">{name}</p>
              <p className="font-display text-lg text-white mt-1">{value}</p>
            </div>
            {i < layers.length - 1 && <span aria-hidden className="text-mint text-xl rotate-90 md:rotate-0">⇄</span>}
          </div>
        ))}
      </div>
    </div>
  );
}

export default function ProjectPreview() {
  const { slug } = useParams();
  const p = useProject(slug);
  const { loading, error } = useStore();
  const [tab, setTab] = useState(() => window.location.hash.slice(1) || "overview");

  useEffect(() => { window.scrollTo(0, 0); }, [slug]);

  if (loading) return <div className="min-h-screen bg-ink" role="status" aria-label="Loading" />;
  if (error) return <ServerError message={error} />;
  if (!p) {
    return (
      <div className="cs min-h-screen bg-ink text-white grid place-items-center font-sans">
        <div className="text-center">
          <h1 className="font-display text-3xl font-bold">Project not found</h1>
          <p className="text-mute mt-2">No project uses the address “{slug}”.</p>
          <Link to="/clients" className="inline-block mt-6 text-mint hover:underline">Back to portfolio</Link>
        </div>
      </div>
    );
  }

  const has = {
    overview: true,
    design: p.wireframes.length + p.screens.length > 0,
    uml: p.diagrams.length > 0,
    database: Boolean(p.erd),
    architecture: Boolean(p.architecture),
    demo: Boolean(p.demo.srcDoc || (p.demo.embed && p.demo.url) || p.demo.screens.length),
  };
  const tabs = TABS.filter(([id]) => has[id]);
  const active = has[tab] ? tab : "overview";
  const pick = (id) => { setTab(id); window.history.replaceState(null, "", `#${id}`); };

  return (
    <div className="cs min-h-screen bg-ink text-[#e6edf7] font-sans">
      <header className="max-w-6xl mx-auto px-6 pt-6">
        <Link to="/clients#projects" className="text-sm text-mute! no-underline! hover:text-white!">‹ All projects</Link>
        <div className="grid gap-8 lg:grid-cols-[1.1fr_1fr] items-center mt-5">
          <div>
            <div className="flex flex-wrap items-center gap-3 text-sm">
              {p.status && <span className="rounded-full bg-mint/15 text-mint px-3 py-1">{p.status}</span>}
              {p.year && <span className="text-mute">{p.year}</span>}
            </div>
            <h1 className="font-display text-4xl md:text-5xl font-bold tracking-tight text-white mt-4">{p.title}</h1>
            <p className="text-lg text-mute mt-3 max-w-prose">{p.tagline}</p>
            <div className="flex flex-wrap gap-3 mt-6">
              {p.links.live && <a href={p.links.live} target="_blank" rel="noreferrer" className="rounded-lg bg-mint text-ink! no-underline! font-semibold px-5 py-2.5 hover:brightness-110">Open live demo</a>}
              {p.links.github && <a href={p.links.github} target="_blank" rel="noreferrer" className="rounded-lg border border-line text-white! no-underline! px-5 py-2.5 hover:border-mint/60">View source on GitHub</a>}
            </div>
          </div>
          {p.hero && <img src={p.hero} alt={`${p.title} preview`} className="w-full rounded-2xl border border-line object-cover aspect-[16/10]" />}
        </div>
      </header>

      <nav className="sticky top-0 z-40 mt-8 bg-ink/90 backdrop-blur border-b border-line">
        <div role="tablist" aria-label="Project sections" className="max-w-6xl mx-auto px-6 flex gap-1 overflow-x-auto">
          {tabs.map(([id, label]) => (
            <button key={id} role="tab" aria-selected={active === id} onClick={() => pick(id)}
              className={`px-4 py-3 text-sm whitespace-nowrap border-b-2 transition-colors ${active === id ? "border-mint text-white" : "border-transparent text-mute hover:text-white"}`}>
              {label}
            </button>
          ))}
        </div>
      </nav>

      <main className="max-w-6xl mx-auto px-6 py-8 space-y-8">
        {active === "overview" && (
          <>
            <p className="text-lg leading-relaxed max-w-prose text-[#cdd8ea]">{p.description}</p>
            {p.results.length > 0 && (
              <ul className="grid gap-4 md:grid-cols-3">
                {p.results.map((r) => <li key={r} className="rounded-xl border border-line bg-panel p-5 text-white">{r}</li>)}
              </ul>
            )}
            <Features features={p.features} />
            <TechStack stack={p.stack} />
            <Challenges challenges={p.challenges} />
          </>
        )}
        {active === "design" && (
          <>
            <Gallery title="Wireframes" note="Early layouts, before any visual styling." items={p.wireframes} />
            <Gallery title="Screens" note="The finished interface." items={p.screens} />
          </>
        )}
        {active === "uml" && <UmlViewer diagrams={p.diagrams} description={p.umlDescription} />}
        {active === "database" && <ErdDiagram erd={p.erd} />}
        {active === "architecture" && <Architecture a={p.architecture} />}
        {active === "demo" && <DemoFrame demo={p.demo} />}
      </main>
      <ChatWidget />
    </div>
  );
}
