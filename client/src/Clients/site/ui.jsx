import { useEffect, useRef, useState } from "react";
import { brandMap } from "../../brandMap";

export const inputCls = "w-full rounded-lg border border-line bg-panel px-4 py-3 text-white placeholder:text-mute focus:border-mint focus:outline-none";

export function Reveal({ children, className = "" }) {
  const ref = useRef(null);
  const [on, setOn] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el || !("IntersectionObserver" in window)) { setOn(true); return; }
    const io = new IntersectionObserver(([e]) => { if (e.isIntersecting) { setOn(true); io.disconnect(); } }, { threshold: 0.1 });
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return <div ref={ref} className={`reveal ${on ? "in" : ""} ${className}`}>{children}</div>;
}

export const Section = ({ id, kicker, title, children }) => (
  <section id={id} className="py-14 md:py-20 border-t border-line/60">
    <div className="mx-auto max-w-6xl px-6">
      <Reveal>
        <p className="font-mono text-sm text-mint">{`// ${kicker}`}</p>
        <h2 className="font-display text-3xl md:text-4xl font-bold tracking-tight text-white mt-2">{title}</h2>
      </Reveal>
      <div className="mt-8">{children}</div>
    </div>
  </section>
);

export function Chip({ name }) {
  const b = brandMap[name];
  return (
    <span className="inline-flex items-center gap-2 rounded-full border border-line bg-raise px-2.5 py-1 text-sm text-[#cdd8ea]">
      {b && <img src={b.icon} alt="" className="h-4 w-4 rounded bg-white/90 p-0.5" />}
      {name}
    </span>
  );
}
