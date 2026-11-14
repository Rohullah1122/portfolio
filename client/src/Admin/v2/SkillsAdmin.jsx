import { useState } from "react";
import { actions, getSaveError, useStore } from "../../store/portfolio";
import { Btn, Card, Input, StringList } from "./fields";

export default function SkillsAdmin() {
  const { skills } = useStore();
  const [d, setD] = useState(() => JSON.parse(JSON.stringify(skills)));
  const [msg, setMsg] = useState("");
  const change = (fn) => { setD((p) => { const n = JSON.parse(JSON.stringify(p)); fn(n); return n; }); setMsg(""); };
  const move = (i, k) => change((n) => { const j = i + k; if (j >= 0 && j < n.length) [n[i], n[j]] = [n[j], n[i]]; });
  const save = async () => setMsg((await actions.saveSkills(d)) ? "Saved. Your site is updated." : getSaveError());
  return (
    <div className="max-w-3xl pb-28">
      <h1 className="font-display text-3xl font-bold text-white">Skills</h1>
      <p className="mt-1 text-mute">Groups appear in this order on your site. Names that match a known technology (React, Node.js, Flutter…) get its icon.</p>
      <div className="mt-8 space-y-6">
        {d.map((g, i) => (
          <Card key={i} title={g.title || "New group"}>
            <Input label="Group title" value={g.title} onChange={(e) => change((n) => { n[i].title = e.target.value; })} />
            <Input label="Description" value={g.desc} onChange={(e) => change((n) => { n[i].desc = e.target.value; })} />
            <StringList label="Skills" value={g.items} onChange={(v) => change((n) => { n[i].items = v; })} />
            <div className="flex gap-2">
              <Btn onClick={() => move(i, -1)} disabled={i === 0}>Move up</Btn>
              <Btn onClick={() => move(i, 1)} disabled={i === d.length - 1}>Move down</Btn>
              <Btn onClick={() => change((n) => { n.splice(i, 1); })}>Delete group</Btn>
            </div>
          </Card>
        ))}
        <Btn onClick={() => change((n) => { n.push({ title: "", desc: "", items: [] }); })}>+ Add group</Btn>
      </div>
      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-panel/95 backdrop-blur md:left-60">
        <div className="mx-auto flex max-w-3xl items-center gap-3 px-5 py-3">
          <p role="status" className="flex-1 text-sm text-mint">{msg}</p>
          <Btn kind="primary" onClick={save}>Save skills</Btn>
        </div>
      </div>
    </div>
  );
}
