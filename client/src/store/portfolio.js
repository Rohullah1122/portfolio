// The website's data. Loaded from the Express + PostgreSQL server; the admin saves back to it.
import { useSyncExternalStore } from "react";
import { api, getToken, setToken } from "../api/client";

export const blankProject = () => ({
  name: "", slug: "", info: "", tech: [], category: "web", status: "Planned", icon: "",
  fullProject: {
    title: "", tagline: "", description: "", year: new Date().getFullYear(), heroImage: "",
    stack: { languages: [], frameworks: [], databases: [], tools: [] },
    features: [], results: [], challenges: [],
    architecture: { pattern: "", frontend: "", backend: "", database: "" },
    uml: { description: "", classDiagram: "", sequenceDiagram: "", useCaseDiagram: "" },
    wireframes: [], gallery: [], erd: null,
    demo: { embed: false, srcDoc: "" }, links: { github: "", liveDemo: "" },
  },
});

const emptyProfile = { name: "", role: "", bio: "", available: false, avatar: "", email: "", phone: "", location: "", github: "", linkedin: "", resume: "", about: [] };

let state = { loading: true, error: "", isAdmin: Boolean(getToken()), projects: [], skills: [], experience: [], profile: emptyProfile, messages: [] };
let saveError = null;
const listeners = new Set();
const set = (patch) => { state = { ...state, ...patch }; listeners.forEach((l) => l()); };

export const useStore = () => useSyncExternalStore((cb) => { listeners.add(cb); return () => listeners.delete(cb); }, () => state);
export const getSaveError = () => saveError;

export async function loadAll() {
  set({ loading: true, error: "" });
  try { set({ ...(await api("/api/portfolio")), loading: false }); }
  catch (e) { set({ loading: false, error: e.message }); }
}

window.addEventListener("portfolio:unauthorized", () => { setToken(null); set({ isAdmin: false, messages: [] }); });

// Every action resolves to true (worked) or false (failed, see getSaveError()).
const run = async (fn) => {
  try { await fn(); saveError = null; return true; }
  catch (e) { saveError = e.message; return false; }
};
const enc = encodeURIComponent;

export const actions = {
  // returns an error message, or null when signed in
  async login(email, password) {
    try {
      const { token } = await api("/api/auth/login", { method: "POST", body: { email, password } });
      setToken(token); set({ isAdmin: true });
      return null;
    } catch (e) { return e.message; }
  },
  logout() { setToken(null); set({ isAdmin: false, messages: [] }); },

  saveProject: (project, originalSlug) => run(async () => {
    const saved = originalSlug
      ? await api(`/api/admin/projects/${enc(originalSlug)}`, { method: "PUT", body: project })
      : await api("/api/admin/projects", { method: "POST", body: project });
    set({ projects: originalSlug ? state.projects.map((p) => (p.slug === originalSlug ? saved : p)) : [...state.projects, saved] });
  }),
  deleteProject: (slug) => run(async () => {
    await api(`/api/admin/projects/${enc(slug)}`, { method: "DELETE" });
    set({ projects: state.projects.filter((p) => p.slug !== slug) });
  }),
  saveProfile: (profile) => run(async () => set({ profile: await api("/api/admin/profile", { method: "PUT", body: profile }) })),
  saveSkills: (skills) => run(async () => set({ skills: await api("/api/admin/skills", { method: "PUT", body: skills }) })),
  saveExperience: (list) => run(async () => set({ experience: await api("/api/admin/experience", { method: "PUT", body: list }) })),

  addMessage: (m) => run(() => api("/api/messages", { method: "POST", body: m })),
  loadMessages: () => run(async () => set({ messages: await api("/api/admin/messages") })),
  setMessageRead: (id, read) => run(async () => {
    await api(`/api/admin/messages/${id}`, { method: "PATCH", body: { read } });
    set({ messages: state.messages.map((m) => (m.id === id ? { ...m, read } : m)) });
  }),
  deleteMessage: (id) => run(async () => {
    await api(`/api/admin/messages/${id}`, { method: "DELETE" });
    set({ messages: state.messages.filter((m) => m.id !== id) });
  }),
};

loadAll();
