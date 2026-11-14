import { useState } from "react";
import { actions, getSaveError, useStore } from "../../store/portfolio";
import { inputCls, Reveal, Section } from "./ui";

export default function Contact() {
  const { profile } = useStore();
  const [f, setF] = useState({ name: "", email: "", body: "" });
  const [errs, setErrs] = useState({});
  const [status, setStatus] = useState("");
  const [copied, setCopied] = useState(false);
  const copyEmail = async () => { try { await navigator.clipboard.writeText(profile.email); setCopied(true); setTimeout(() => setCopied(false), 1500); } catch { /* clipboard blocked */ } };

  const submit = async (e) => {
    e.preventDefault();
    const er = {};
    if (!f.name.trim()) er.name = "Please enter your name.";
    if (!/^\S+@\S+\.\S+$/.test(f.email)) er.email = "Please enter a valid email address.";
    if (f.body.trim().length < 10) er.body = "Write at least 10 characters.";
    setErrs(er);
    if (Object.keys(er).length) return setStatus("");
    if (await actions.addMessage({ name: f.name.trim(), email: f.email.trim(), body: f.body.trim() })) { setF({ name: "", email: "", body: "" }); setStatus("Thanks. Your message was sent."); }
    else setStatus(getSaveError());
  };
  const field = (k, label, props = {}) => (
    <div>
      <label htmlFor={`c-${k}`} className="text-sm text-mute">{label}</label>
      {props.area
        ? <textarea id={`c-${k}`} rows={5} value={f[k]} onChange={(e) => setF({ ...f, [k]: e.target.value })} aria-invalid={Boolean(errs[k])} className={`${inputCls} mt-1 resize-y`} />
        : <input id={`c-${k}`} type={props.type || "text"} value={f[k]} onChange={(e) => setF({ ...f, [k]: e.target.value })} aria-invalid={Boolean(errs[k])} className={`${inputCls} mt-1`} />}
      {errs[k] && <p role="alert" className="mt-1 text-sm text-[#ff7b7b]">{errs[k]}</p>}
    </div>
  );
  const info = [["Location", profile.location], ["Phone", profile.phone, `tel:${profile.phone}`], ["Email", profile.email, `mailto:${profile.email}`]].filter((x) => x[1]);

  return (
    <Section id="contact" kicker="contact" title="Let’s work together.">
      <div className="grid gap-10 md:grid-cols-[1fr_1.2fr]">
        <Reveal>
          <dl className="space-y-6">
            {info.map(([k, v, href]) => (
              <div key={k}><dt className="font-mono text-xs uppercase text-mint">{k}</dt>
                <dd className="mt-1 text-lg text-white">{href ? <a href={href} className="text-white no-underline hover:text-mint">{v}</a> : v}{k === "Email" && <button type="button" onClick={copyEmail} className="ml-3 text-sm text-mute underline hover:text-white">{copied ? "Copied" : "Copy"}</button>}</dd></div>
            ))}
            {(profile.github || profile.linkedin) && (
              <div className="flex gap-5 pt-2">
                {profile.github && <a href={profile.github} target="_blank" rel="noreferrer" className="text-mute no-underline hover:text-white">GitHub ↗</a>}
                {profile.linkedin && <a href={profile.linkedin} target="_blank" rel="noreferrer" className="text-mute no-underline hover:text-white">LinkedIn ↗</a>}
              </div>
            )}
          </dl>
        </Reveal>
        <Reveal>
          <form onSubmit={submit} noValidate className="space-y-4 rounded-xl border border-line bg-panel p-5 md:p-6">
            {field("name", "Your name")}
            {field("email", "Email", { type: "email" })}
            {field("body", "Message", { area: true })}
            <button type="submit" className="rounded-lg bg-mint px-6 py-3 text-sm font-semibold text-ink hover:brightness-110">Send message</button>
            <p role="status" className="text-sm text-mint">{status}</p>
          </form>
        </Reveal>
      </div>
    </Section>
  );
}
