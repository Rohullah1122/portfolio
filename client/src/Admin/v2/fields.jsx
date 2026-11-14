import { useId, useState } from "react";
import { api } from "../../api/client";

const input = "w-full rounded-lg border border-line bg-ink px-3 py-2 text-sm text-white placeholder:text-mute focus:border-mint focus:outline-none";
const ghost = "rounded-lg border border-line px-3 py-2 text-sm text-mute hover:text-white hover:border-mint/60";

export const Card = ({ title, hint, children }) => (
  <section className="rounded-xl border border-line bg-panel p-5">
    <h2 className="font-display text-lg font-semibold text-white">{title}</h2>
    {hint && <p className="mt-1 text-sm text-mute">{hint}</p>}
    <div className="mt-4 space-y-4">{children}</div>
  </section>
);

export function Field({ label, children }) {
  const id = useId();
  return (
    <div>
      <label htmlFor={id} className="text-xs uppercase tracking-wide text-mute">{label}</label>
      <div className="mt-1">{typeof children === "function" ? children(id) : children}</div>
    </div>
  );
}

export const Group = ({ label, children }) => (
  <div role="group" aria-label={label}>
    <p className="text-xs uppercase tracking-wide text-mute mb-1">{label}</p>
    {children}
  </div>
);

export const Input = ({ label, ...p }) => <Field label={label}>{(id) => <input id={id} {...p} className={input} />}</Field>;
export const Area = ({ label, rows = 4, ...p }) => <Field label={label}>{(id) => <textarea id={id} rows={rows} {...p} className={`${input} resize-y`} />}</Field>;
export const Select = ({ label, options, ...p }) => (
  <Field label={label}>{(id) => <select id={id} {...p} className={input}>{options.map((o) => <option key={o} value={o}>{o}</option>)}</select>}</Field>
);
export const Btn = ({ kind = "ghost", className = "", ...p }) => (
  <button type="button" {...p} className={`${kind === "primary" ? "rounded-lg bg-mint px-4 py-2 text-sm font-semibold text-ink hover:brightness-110" : ghost} ${className}`} />
);

// List of text values (features, tags, results...)
export function StringList({ label, value = [], onChange, placeholder }) {
  const set = (i, v) => onChange(value.map((x, n) => (n === i ? v : x)));
  return (
    <Group label={label}>
      <div className="space-y-2">
        {value.map((v, i) => (
          <div key={i} className="flex gap-2">
            <input aria-label={`${label} ${i + 1}`} value={v} placeholder={placeholder} onChange={(e) => set(i, e.target.value)} className={input} />
            <Btn onClick={() => onChange(value.filter((_, n) => n !== i))} aria-label={`Remove ${label} ${i + 1}`}>✕</Btn>
          </div>
        ))}
        <Btn onClick={() => onChange([...value, ""])}>+ Add</Btn>
      </div>
    </Group>
  );
}

// Resize uploads so they fit in browser storage.
const shrink = (file) => new Promise((resolve) => {
  const r = new FileReader();
  r.onload = () => {
    const img = new Image();
    img.onload = () => {
      const k = Math.min(1, 1200 / Math.max(img.width, img.height));
      const c = document.createElement("canvas");
      c.width = img.width * k; c.height = img.height * k;
      const ctx = c.getContext("2d");
      ctx.fillStyle = "#fff"; ctx.fillRect(0, 0, c.width, c.height);
      ctx.drawImage(img, 0, 0, c.width, c.height);
      resolve(c.toDataURL("image/jpeg", 0.8));
    };
    img.src = r.result;
  };
  r.readAsDataURL(file);
});

export function ImageInput({ label, value, onChange }) {
  const id = useId();
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const pick = async (e) => {
    const f = e.target.files[0]; e.target.value = "";
    if (!f) return;
    setBusy(true); setErr("");
    try { const { url } = await api("/api/admin/upload", { method: "POST", body: { dataUrl: await shrink(f) } }); onChange(url); }
    catch (x) { setErr(x.message); }
    finally { setBusy(false); }
  };
  return (
    <Group label={label}>
      <div className="flex gap-3 items-start">
        <div className="h-20 w-28 shrink-0 overflow-hidden rounded-lg border border-line bg-ink grid place-items-center text-xs text-mute">
          {value ? <img src={value} alt="" className="h-full w-full object-cover" /> : "No image"}
        </div>
        <div className="flex-1 space-y-2">
          <input aria-label={`${label} URL`} value={value?.startsWith("data:") ? "" : value || ""} placeholder={value?.startsWith("data:") ? "Uploaded image" : "Paste an image URL"} onChange={(e) => onChange(e.target.value)} className={input} />
          <div className="flex gap-2">
            <label htmlFor={id} className={`${ghost} cursor-pointer`}>{busy ? "Uploading…" : "Upload"}</label>
            <input id={id} type="file" accept="image/*" onChange={pick} className="sr-only" />
            {value && <Btn onClick={() => onChange("")}>Remove</Btn>}
          </div>
          {err && <p role="alert" className="text-sm text-[#ff7b7b]">{err}</p>}
        </div>
      </div>
    </Group>
  );
}

export function ImageList({ label, value = [], onChange }) {
  return (
    <Group label={label}>
      <div className="space-y-4">
        {value.map((v, i) => (
          <div key={i} className="rounded-lg border border-line p-3">
            <ImageInput label={`${label} ${i + 1}`} value={v} onChange={(x) => onChange(value.map((y, n) => (n === i ? x : y)))} />
            <Btn className="mt-2" onClick={() => onChange(value.filter((_, n) => n !== i))}>Delete this image</Btn>
          </div>
        ))}
        <Btn onClick={() => onChange([...value, ""])}>+ Add image</Btn>
      </div>
    </Group>
  );
}

// PDF upload (resume). No resizing, sent as it is.
const readfile = (file) => new Promise((resolve,reject) => {
    const r = new FileReader();
    r.onload = () => resolve(r.result);
    r.onerror = () => reject(new Error("Could not read that file."));
    r.readAsDataURL(file);
});

export const FileInput = ({ label, value, onChange, accept = "application/pdf" }) => {
    const id = useId();
    const [busy,setbusy] = useState(false);
    const [err,seterr] = useState("");

    const pick = async (e) => {
        const file = e.target.files[0]; e.target.value = "";
        if (!file) return;
        if (file.type !== "application/pdf") return seterr("Please choose a PDF file.");
        if (file.size > 6 * 1024 * 1024) return seterr("That file is too large (6 MB maximum).");

        setbusy(true); seterr("");
        try {
            const { url } = await api("/api/admin/upload",{ method:"POST",body:{ dataUrl: await readfile(file) } });
            onChange(url);
        } catch (x) { seterr(x.message); }
        finally { setbusy(false); }
    };


    return (
        <Group label={label}>
            <div className="space-y-2">
                <input aria-label={`${label} URL`} value={value || ""} placeholder="Paste a link, or upload a PDF" onChange={(e) => onChange(e.target.value)} className={input} />
                <div className="flex flex-wrap items-center gap-2">
                    <label htmlFor={id} className={`${ghost} cursor-pointer`}>{busy ? "Uploading…" : "Upload PDF"}</label>
                    <input id={id} type="file" accept={accept} onChange={pick} className="sr-only" />
                    {value && <a href={value} target="_blank" rel="noreferrer" className="text-sm text-link! no-underline!">Open ↗</a>}
                    {value && <Btn onClick={() => onChange("")}>Remove</Btn>}
                </div>
                {err && <p role="alert" className="text-sm text-[#ff7b7b]">{err}</p>}
            </div>
        </Group>
    );
};
