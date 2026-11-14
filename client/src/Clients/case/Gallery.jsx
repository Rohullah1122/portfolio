import { useState } from "react";
import Lightbox from "./Lightbox";

export default function Gallery({ title, note, items }) {
  const [open, setOpen] = useState(null);
  if (!items.length) return null;
  return (
    <div>
      <h3 className="font-display text-xl font-semibold text-white">{title}</h3>
      {note && <p className="text-mute mt-1 mb-5 max-w-prose">{note}</p>}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 mt-4">
        {items.map((it, i) => (
          <button key={it.src + i} onClick={() => setOpen(i)} className="group text-left rounded-xl border border-line bg-panel overflow-hidden hover:border-mint/60 transition-colors">
            <img src={it.src} alt={it.label} loading="lazy" className="w-full aspect-[4/3] object-cover bg-raise" />
            <span className="block px-4 py-3 text-sm text-mute group-hover:text-white">{it.label}</span>
          </button>
        ))}
      </div>
      {open !== null && <Lightbox items={items} index={open} onIndex={setOpen} onClose={() => setOpen(null)} />}
    </div>
  );
}
