import { useEffect, useState } from "react";

// Full-screen image viewer: Esc closes, arrow keys move, click image to zoom.
export default function Lightbox({ items, index, onIndex, onClose }) {
  const [zoom, setZoom] = useState(false);
  const item = items[index];
  const go = (d) => { setZoom(false); onIndex((index + d + items.length) % items.length); };

  useEffect(() => {
    const key = (e) => {
      if (e.key === "Escape") onClose();
      if (e.key === "ArrowRight") go(1);
      if (e.key === "ArrowLeft") go(-1);
    };
    document.addEventListener("keydown", key);
    document.body.style.overflow = "hidden";
    return () => { document.removeEventListener("keydown", key); document.body.style.overflow = ""; };
  });

  const btn = "h-10 w-10 rounded-full bg-white/10 text-white hover:bg-white/20 grid place-items-center";
  return (
    <div role="dialog" aria-modal="true" aria-label={item.label} className="fixed inset-0 z-[100] bg-black/90 flex flex-col">
      <div className="flex items-center justify-between px-5 py-3 text-sm text-white">
        <span>{item.label} <span className="text-mute">({index + 1} of {items.length})</span></span>
        <button onClick={onClose} className={btn} aria-label="Close">✕</button>
      </div>
      <div className={`flex-1 min-h-0 ${zoom ? "overflow-auto" : "overflow-hidden"} grid place-items-center px-14`}>
        <img
          src={item.src}
          alt={item.label}
          onClick={() => setZoom(!zoom)}
          className={zoom ? "max-w-none w-[200%] cursor-zoom-out" : "max-h-full max-w-full object-contain cursor-zoom-in"}
        />
      </div>
      {items.length > 1 && (
        <>
          <button onClick={() => go(-1)} className={`${btn} absolute left-3 top-1/2`} aria-label="Previous">‹</button>
          <button onClick={() => go(1)} className={`${btn} absolute right-3 top-1/2`} aria-label="Next">›</button>
        </>
      )}
      <p className="text-center text-xs text-mute py-2">{zoom ? "Click to fit" : "Click image to zoom"}</p>
    </div>
  );
}
