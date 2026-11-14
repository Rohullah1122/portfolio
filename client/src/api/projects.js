// The UI reads projects through these hooks. Later they call Express instead of the store.
import { useMemo } from "react";
import { useStore } from "../store/portfolio";

const real = (url) => (url && url !== "#" ? url : null);

export const useProjects = () => useStore().projects;

export function buildProject(card) {
  if (!card) return null;
  const f = card.fullProject || {};
  const uml = f.uml || {};
  const gallery = (f.gallery || []).filter(Boolean);
  const links = f.links || {};
  const demo = f.demo || {};
  const url = real(links.liveDemo || links.live);
  const screens = gallery.map((src, i) => ({ src, label: `Screen ${i + 1}` }));

  return {
    slug: card.slug,
    title: f.title || card.name,
    tagline: f.tagline || card.info,
    description: f.description || card.info,
    status: card.status,
    year: f.year,
    hero: f.heroImage,
    stack: f.stack || {},
    features: f.features || [],
    results: f.results || [],
    challenges: f.challenges || [],
    architecture: f.architecture && f.architecture.pattern ? f.architecture : null,
    umlDescription: uml.description,
    diagrams: [
      { label: "Class diagram", src: uml.classDiagram },
      { label: "Sequence diagram", src: uml.sequenceDiagram },
      { label: "Use case diagram", src: uml.useCaseDiagram },
    ].filter((d) => d.src),
    wireframes: (f.wireframes || []).filter(Boolean).map((src, i) => ({ src, label: `Wireframe ${i + 1}` })),
    screens,
    erd: f.erd && f.erd.tables && f.erd.tables.length ? f.erd : null,
    demo: { url, embed: Boolean(demo.embed), srcDoc: demo.srcDoc || null, screens },
    links: { github: real(links.github), live: url },
  };
}

export function useProject(slug) {
  const { projects } = useStore();
  return useMemo(() => buildProject(projects.find((p) => p.slug === slug)), [projects, slug]);
}
