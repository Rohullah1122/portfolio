import { useState } from "react";
import Lightbox from "./Lightbox";

export default function UmlViewer({ diagrams, description }) {
  const [i, setI] = useState(0);
  const [open, setOpen] = useState(false);
  const d = diagrams[i];
  return (
    <div>
      {description && <p className="text-mute mb-5 max-w-prose">{description}</p>}
      <div role="tablist" className="flex gap-2 mb-4 flex-wrap">
        {diagrams.map((x, n) => (
          <button key={x.label} role="tab" aria-selected={n === i} onClick={() => setI(n)}
            className={`px-4 py-2 rounded-lg text-sm border transition-colors ${n === i ? "bg-mint text-ink border-mint font-semibold" : "border-line text-mute hover:text-white"}`}>
            {x.label}
          </button>
        ))}
      </div>
      <button onClick={() => setOpen(true)} className="block w-full rounded-xl border border-line bg-white p-3 cursor-zoom-in" aria-label={`Open ${d.label} full size`}>
        <img src={d.src} alt={d.label} className="mx-auto max-h-[70vh] w-auto object-contain" />
      </button>
      <p className="text-xs text-mute mt-2">Click the diagram to open it full size and zoom.</p>
      {open && <Lightbox items={diagrams} index={i} onIndex={setI} onClose={() => setOpen(false)} />}
    </div>
  );
}
