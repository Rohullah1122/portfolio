import { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import { useStore } from "../store/portfolio";
import Nav from "./site/Nav";
import Hero from "./site/Hero";
import About from "./site/About";
import Skills from "./site/Skills";
import Experience from "./site/experience";
import Projects from "./site/Projects";
import Contact from "./site/Contact";
import ChatWidget from "./site/ChatWidget";
import ServerError from "./site/ServerError";

function ToTop() {
  const [show, setShow] = useState(false);
  useEffect(() => {
    const f = () => setShow(window.scrollY > 800);
    f(); window.addEventListener("scroll", f, { passive: true });
    return () => window.removeEventListener("scroll", f);
  }, []);
  return show ? <a href="#home" aria-label="Back to top" className="fixed bottom-20 right-5 z-40 grid h-11 w-11 place-items-center rounded-full border border-line bg-panel text-white no-underline hover:border-mint">↑</a> : null;
}

export default function ClientLayout() {
  const { profile, loading, error } = useStore();
  const { hash } = useLocation();
  useEffect(() => { if (!loading && hash) document.getElementById(hash.slice(1))?.scrollIntoView(); }, [hash, loading]);

  if (loading) return <div className="grid min-h-screen place-items-center bg-ink text-mute" role="status">Loading…</div>;
  if (error) return <ServerError message={error} />;
  return (
    <>
      <Nav />
      <main><Hero /><About /><Skills /><Projects /><Experience /><Contact /></main>
      <ToTop />
      <ChatWidget />
      <footer className="border-t border-line py-8">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-6 text-sm text-mute md:flex-row">
          <p>© {new Date().getFullYear()} {profile.name}. Built with React, Express and PostgreSQL.</p>
          <div className="flex gap-5">
            {profile.github && <a href={profile.github} target="_blank" rel="noreferrer" className="text-mute no-underline hover:text-white">GitHub</a>}
            {profile.linkedin && <a href={profile.linkedin} target="_blank" rel="noreferrer" className="text-mute no-underline hover:text-white">LinkedIn</a>}
            {profile.email && <a href={`mailto:${profile.email}`} className="text-mute no-underline hover:text-white">Email</a>}
            {profile.resume && <a href={profile.resume} target="_blank" rel="noreferrer" className="text-mute no-underline hover:text-white">Resume</a>}
          </div>
        </div>
      </footer>
    </>
  );
}
