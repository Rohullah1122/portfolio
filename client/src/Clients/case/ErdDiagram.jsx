import { useState } from "react";

const W = 240, H = 36, R = 26;
const rowY = (t, col) => t.y + H + Math.max(0, t.cols.findIndex((c) => c.n === col)) * R + R / 2;

export function toSql({ tables, relations }) {
  return tables.map((t) => {
    const pks = t.cols.filter((c) => c.k === "pk").map((c) => c.n);
    const lines = t.cols.map((c) =>
      `  ${c.n} ${c.t}${c.k === "uq" ? " UNIQUE" : ""}${c.k === "pk" && pks.length === 1 ? " PRIMARY KEY" : ""}`);
    if (pks.length > 1) lines.push(`  PRIMARY KEY (${pks.join(", ")})`);
    relations.filter((r) => r.from.startsWith(t.name + ".")).forEach((r) => {
      const [, col] = r.from.split("."); const [rt, rc] = r.to.split(".");
      lines.push(`  FOREIGN KEY (${col}) REFERENCES ${rt}(${rc})`);
    });
    return `CREATE TABLE ${t.name} (\n${lines.join(",\n")}\n);`;
  }).join("\n\n");
}

export default function ErdDiagram({ erd }) {
  const [view, setView] = useState("diagram");
  const [hover, setHover] = useState(null);
  const [copied, setCopied] = useState(false);
  const T = Object.fromEntries(erd.tables.map((t) => [t.name, t]));
  const width = Math.max(...erd.tables.map((t) => t.x + W)) + 50;
  const height = Math.max(...erd.tables.map((t) => t.y + H + t.cols.length * R)) + 30;
  const sql = toSql(erd);

  const copy = async () => {
    try { await navigator.clipboard.writeText(sql); setCopied(true); setTimeout(() => setCopied(false), 1500); } catch { /* clipboard blocked */ }
  };

  const edge = (r) => {
    const [ft, fc] = r.from.split("."), [tt, tc] = r.to.split(".");
    const a = T[ft], b = T[tt], y1 = rowY(a, fc), y2 = rowY(b, tc);
    let x1, x2, s1, s2, m;
    if (a.x + W + 20 <= b.x) { x1 = a.x + W; x2 = b.x; s1 = 1; s2 = -1; m = (x1 + x2) / 2; }
    else if (b.x + W + 20 <= a.x) { x1 = a.x; x2 = b.x + W; s1 = -1; s2 = 1; m = (x1 + x2) / 2; }
    else { x1 = a.x + W; x2 = b.x + W; s1 = 1; s2 = 1; m = Math.max(x1, x2) + 34; }
    const [k1, k2] = r.kind.split(":");
    return { d: `M${x1} ${y1}H${m}V${y2}H${x2}`, x1, y1, x2, y2, s1, s2, k1, k2, on: hover === ft || hover === tt };
  };

  const tab = (id, label) => (
    <button role="tab" aria-selected={view === id} onClick={() => setView(id)}
      className={`px-4 py-2 rounded-lg text-sm border transition-colors ${view === id ? "bg-mint text-ink border-mint font-semibold" : "border-line text-mute hover:text-white"}`}>{label}</button>
  );

  return (
    <div>
      <div role="tablist" className="flex gap-2 mb-4 items-center">
        {tab("diagram", "ER diagram")}{tab("sql", "SQL schema")}
        {view === "sql" && <button onClick={copy} className="ml-auto text-sm text-link hover:underline">{copied ? "Copied" : "Copy SQL"}</button>}
      </div>

      {view === "diagram" ? (
        <div className="rounded-xl border border-line bg-panel overflow-x-auto">
          <svg viewBox={`0 0 ${width} ${height}`} style={{ minWidth: Math.min(width, 720) }} className="w-full" role="img" aria-label="Entity relationship diagram">
            {erd.relations.map((r) => {
              const e = edge(r);
              return (
                <g key={r.from + r.to}>
                  <path d={e.d} fill="none" strokeWidth={e.on ? 2 : 1.4} stroke={e.on ? "var(--color-mint)" : "var(--color-mute)"} opacity={e.on ? 1 : 0.7} />
                  <text x={e.x1 + e.s1 * 12} y={e.y1 - 6} textAnchor="middle" fontSize="12" fill="var(--color-link)" className="font-mono">{e.k1}</text>
                  <text x={e.x2 + e.s2 * 12} y={e.y2 - 6} textAnchor="middle" fontSize="12" fill="var(--color-link)" className="font-mono">{e.k2}</text>
                </g>
              );
            })}
            {erd.tables.map((t) => (
              <g key={t.name} onMouseEnter={() => setHover(t.name)} onMouseLeave={() => setHover(null)}>
                <rect x={t.x} y={t.y} width={W} height={H + t.cols.length * R} rx="8" fill="var(--color-raise)" stroke={hover === t.name ? "var(--color-mint)" : "var(--color-line)"} strokeWidth="1.5" />
                <path d={`M${t.x} ${t.y + H}V${t.y + 8}a8 8 0 0 1 8 -8H${t.x + W - 8}a8 8 0 0 1 8 8V${t.y + H}Z`} fill="var(--color-ink)" />
                <text x={t.x + 14} y={t.y + 23} fontSize="14" fontWeight="600" fill="var(--color-mint)" className="font-mono">{t.name}</text>
                {t.cols.map((c, i) => {
                  const y = t.y + H + i * R + 17;
                  return (
                    <g key={c.n}>
                      <text x={t.x + 14} y={y} fontSize="10" fill="var(--color-key)" className="font-mono">{c.k ? c.k.toUpperCase() : ""}</text>
                      <text x={t.x + 42} y={y} fontSize="12.5" fill="#e6edf7" className="font-mono">{c.n}</text>
                      <text x={t.x + W - 12} y={y} fontSize="11" textAnchor="end" fill="var(--color-mute)" className="font-mono">{c.t}</text>
                    </g>
                  );
                })}
              </g>
            ))}
          </svg>
        </div>
      ) : (
        <pre className="rounded-xl border border-line bg-panel p-5 overflow-x-auto text-sm leading-relaxed font-mono text-[#cfe1ff]"><code>{sql}</code></pre>
      )}
      <p className="text-xs text-mute mt-3">PK is primary key, FK is foreign key, UQ is unique. N and 1 show the relationship: many rows point to one row.</p>
    </div>
  );
}
