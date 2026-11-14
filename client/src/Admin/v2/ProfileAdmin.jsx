import { useState } from "react";
import { actions, getSaveError, useStore } from "../../store/portfolio";
import { Area, Btn, Card, FileInput, ImageInput, Input, StringList } from "./fields";

export default function ProfileAdmin() {
  const { profile } = useStore();
  const [d, setD] = useState(() => JSON.parse(JSON.stringify(profile)));
  const [msg, setMsg] = useState("");
  const set = (k, v) => { setD((p) => ({ ...p, [k]: v })); setMsg(""); };
  const text = (k) => ({ value: d[k] ?? "", onChange: (e) => set(k, e.target.value) });
  const save = async () => {
    if (!d.name.trim()) return setMsg("Name is required.");
    setMsg((await actions.saveProfile(d)) ? "Saved. Your site is updated." : getSaveError());
  };
  return (
    <div className="max-w-3xl pb-28">
      <h1 className="font-display text-3xl font-bold text-white">Profile</h1>
      <p className="mt-1 text-mute">Your name, bio, photo and contact details on the home, about and contact sections.</p>
      <div className="mt-8 space-y-6">
        <Card title="Introduction">
          <div className="grid gap-4 md:grid-cols-2"><Input label="Full name" {...text("name")} /><Input label="Role" {...text("role")} /></div>
          <Area label="Short bio (home page)" rows={4} {...text("bio")} />
          <label className="flex items-center gap-2 text-sm text-white">
            <input type="checkbox" checked={Boolean(d.available)} onChange={(e) => set("available", e.target.checked)} /> Show “Available for work”
          </label>
          <ImageInput label="Photo" value={d.avatar} onChange={(v) => set("avatar", v)} />
        </Card>
        <Card title="About section" hint="Each line becomes a numbered card.">
          <StringList label="Highlights" value={d.about} onChange={(v) => set("about", v)} />
        </Card>
        <Card title="Contact and links" hint="Leave a link empty to hide its button on the site.">
          <div className="grid gap-4 md:grid-cols-2">
            <Input label="Email" {...text("email")} /><Input label="Phone" {...text("phone")} />
            <Input label="GitHub URL" {...text("github")} /><Input label="LinkedIn URL" {...text("linkedin")} />
          </div>
          <Input label="Location" {...text("location")} />
        </Card>
        <Card title="Resume" hint="Shows a “Download resume” button on your site. Leave empty to hide it.">
          <FileInput label="Resume (PDF)" value={d.resume} onChange={(v) => set("resume", v)} />
        </Card>
      </div>
      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-panel/95 backdrop-blur md:left-60">
        <div className="mx-auto flex max-w-3xl items-center gap-3 px-5 py-3">
          <p role="status" className="flex-1 text-sm text-mint">{msg}</p>
          <Btn kind="primary" onClick={save}>Save profile</Btn>
        </div>
      </div>
    </div>
  );
}
