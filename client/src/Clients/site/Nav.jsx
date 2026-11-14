import { useEffect, useState } from "react";
import { useStore } from "../../store/portfolio";

const ALL_LINKS = [["home", "Home"], ["about", "About"], ["skills", "Skills"], ["projects", "Projects"], ["experience", "Experience"], ["contact", "Contact"]];

export default function Nav() {
  const { profile, experience } = useStore();
  const links = ALL_LINKS.filter(([id]) => id !== "experience" || experience.length);
  const [active, setActive] = useState("home");
  const [open, setOpen] = useState(false);
  const [first, ...rest] = profile.name.trim().split(" ");

  useEffect(() => {
    const io = new IntersectionObserver((es) => es.forEach((e) => e.isIntersecting && setActive(e.target.id)), { rootMargin: "-45% 0px -50% 0px" });
    links.forEach(([id]) => { const el = document.getElementById(id); if (el) io.observe(el); });
    return () => io.disconnect();
  }, [links.length]);

  const link = (id, label, extra = "") => (
    <a key={id} href={`#${id}`} onClick={() => setOpen(false)} aria-current={active === id ? "true" : undefined}
      className={`text-sm no-underline transition-colors ${active === id ? "text-mint" : "text-mute hover:text-white"} ${extra}`}>{label}</a>
  );

  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-line bg-ink/80 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-6">
        <a href="#home" className="font-display text-xl font-bold text-white no-underline">
          {first}<span className="text-mint">.{rest.length ? rest[rest.length - 1][0] : ""}</span>
        </a>
        <div className="hidden md:flex items-center gap-8">
          <nav aria-label="Main" className="flex gap-8">{links.filter(([id]) => id !== "contact").map(([id, l]) => link(id, l))}</nav>
          <a href="#contact" className="rounded-lg bg-mint px-4 py-2 text-sm font-semibold text-ink no-underline hover:brightness-110">Let’s talk</a>
        </div>
        <button className="md:hidden rounded-lg border border-line px-3 py-1.5 text-sm text-white" aria-expanded={open} aria-controls="mobile-menu" onClick={() => setOpen(!open)}>
          {open ? "Close" : "Menu"}
        </button>
      </div>
      {open && <nav id="mobile-menu" aria-label="Mobile" className="md:hidden flex flex-col gap-4 border-t border-line bg-panel px-6 py-5">{links.map(([id, l]) => link(id, l, "text-base"))}</nav>}
    </header>
  );
}
