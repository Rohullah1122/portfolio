import { useState } from "react";

// Shows the project inside a browser or phone frame.
// Source: inline HTML mock-up, a live URL that allows embedding, or screenshots.
export default function DemoFrame({ demo }) {
  const hasLive = Boolean(demo.srcDoc || (demo.embed && demo.url));
  const hasShots = demo.screens.length > 0;
  const [device, setDevice] = useState("mobile");
  const [mode, setMode] = useState(hasLive ? "live" : "screens");
  const [n, setN] = useState(0);
  const mobile = device === "mobile";

  const pill = (active) => `px-4 py-2 rounded-lg text-sm border transition-colors ${active ? "bg-mint text-ink border-mint font-semibold" : "border-line text-mute hover:text-white"}`;

  const content = mode === "live" && hasLive ? (
    <iframe title="Project demo" sandbox="allow-scripts" {...(demo.srcDoc ? { srcDoc: demo.srcDoc } : { src: demo.url })} className="w-full h-full bg-white" />
  ) : (
    <div className="relative w-full h-full bg-ink">
      <img src={demo.screens[n]?.src} alt={demo.screens[n]?.label} className="w-full h-full object-cover" />
      {demo.screens.length > 1 && (
        <div className="absolute inset-x-0 bottom-3 flex justify-center gap-2">
          {demo.screens.map((s, i) => (
            <button key={s.src + i} aria-label={`Show ${s.label}`} onClick={() => setN(i)} className={`h-2.5 rounded-full transition-all ${i === n ? "w-6 bg-mint" : "w-2.5 bg-white/60"}`} />
          ))}
        </div>
      )}
    </div>
  );

  return (
    <div>
      <div className="flex flex-wrap items-center gap-2 mb-6">
        <div role="group" aria-label="Device" className="flex gap-2">
          <button className={pill(mobile)} onClick={() => setDevice("mobile")}>Phone</button>
          <button className={pill(!mobile)} onClick={() => setDevice("desktop")}>Desktop</button>
        </div>
        {hasLive && hasShots && (
          <div role="group" aria-label="Source" className="flex gap-2 sm:ml-4">
            <button className={pill(mode === "live")} onClick={() => setMode("live")}>Live</button>
            <button className={pill(mode === "screens")} onClick={() => setMode("screens")}>Screenshots</button>
          </div>
        )}
        {demo.url && <a href={demo.url} target="_blank" rel="noreferrer" className="ml-auto text-sm text-link hover:underline">Open in new tab</a>}
      </div>

      <div className="grid place-items-center rounded-2xl border border-line bg-panel py-10 px-4">
        {mobile ? (
          <div className="w-[300px] h-[610px] rounded-[42px] border-[10px] border-[#05080f] bg-black overflow-hidden shadow-2xl ring-1 ring-line relative">
            <div className="absolute top-2 left-1/2 -translate-x-1/2 h-5 w-24 rounded-full bg-[#05080f] z-10" />
            {content}
          </div>
        ) : (
          <div className="w-full max-w-4xl rounded-xl overflow-hidden border border-line shadow-2xl">
            <div className="flex items-center gap-2 bg-raise px-4 py-2.5">
              <span className="h-3 w-3 rounded-full bg-[#ff5f57]" /><span className="h-3 w-3 rounded-full bg-[#febc2e]" /><span className="h-3 w-3 rounded-full bg-[#28c840]" />
              <span className="ml-3 flex-1 truncate rounded-md bg-ink px-3 py-1 text-xs text-mute font-mono">{demo.url || "localhost:5173"}</span>
            </div>
            <div className="aspect-[16/10]">{content}</div>
          </div>
        )}
        {!hasLive && <p className="mt-6 text-sm text-mute max-w-md text-center">Showing screenshots. Add a demo link that allows embedding, or paste an HTML mock-up in the admin panel, to make this interactive.</p>}
      </div>
    </div>
  );
}
