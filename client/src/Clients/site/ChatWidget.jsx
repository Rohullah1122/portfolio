import { useEffect, useRef, useState } from "react";
import { api } from "../../api/client";
import { useStore } from "../../store/portfolio";

const newId = () => (crypto.randomUUID ? crypto.randomUUID() : "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, () => ((Math.random() * 16) | 0).toString(16)));
const SUGGESTIONS = ["What projects are featured here?", "Which technologies are used most?", "How do I get in touch?"];

export default function ChatWidget() {
  const { profile } = useStore();
  const first = profile.name.split(" ")[0] || "me";
  const [open, setOpen] = useState(false);
  const [msgs, setMsgs] = useState([]);
  const [text, setText] = useState("");
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const session = useRef(newId());
  const endRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => { if (open) inputRef.current?.focus(); }, [open]);
  useEffect(() => { endRef.current?.scrollIntoView({ block: "end" }); }, [msgs, busy, open]);
  useEffect(() => {
    if (!open) return;
    const k = (e) => e.key === "Escape" && setOpen(false);
    document.addEventListener("keydown", k);
    return () => document.removeEventListener("keydown", k);
  }, [open]);

  const send = async (q) => {
    const content = (q ?? text).trim();
    if (!content || busy) return;
    const next = [...msgs, { role: "user", content }];
    setMsgs(next); setText(""); setErr(""); setBusy(true);
    try {
      const { reply } = await api("/api/chat", { method: "POST", body: { sessionId: session.current, messages: next } });
      setMsgs([...next, { role: "assistant", content: reply }]);
    } catch (e) { setErr(e.message); }
    finally { setBusy(false); }
  };

  if (!open) {
    return (
      <button onClick={() => setOpen(true)} className="fixed bottom-5 right-5 z-50 flex items-center gap-2 rounded-full bg-mint px-5 py-3 text-sm font-semibold text-ink shadow-lg hover:brightness-110">
        <span aria-hidden>✦</span> Ask AI about {first}
      </button>
    );
  }
  return (
    <div role="dialog" aria-label={`Chat about ${first}`} className="fixed bottom-5 right-5 z-50 flex h-[30rem] w-[min(23rem,calc(100vw-2.5rem))] flex-col overflow-hidden rounded-2xl border border-line bg-panel shadow-2xl">
      <div className="flex items-center justify-between border-b border-line px-4 py-3">
        <p className="font-display font-semibold text-white">Ask about {first}</p>
        <button onClick={() => setOpen(false)} aria-label="Close chat" className="text-mute hover:text-white">✕</button>
      </div>
      <div role="log" aria-live="polite" className="flex flex-1 flex-col gap-3 overflow-y-auto px-4 py-4">
        {!msgs.length && (
          <>
            <p className="rounded-xl bg-raise px-3 py-2 text-sm text-white">Hi! I can answer questions about {first}’s skills, projects and how to get in touch.</p>
            <div className="flex flex-col items-start gap-2">
              {SUGGESTIONS.map((s) => <button key={s} onClick={() => send(s)} className="rounded-full border border-line px-3 py-1.5 text-left text-sm text-mute hover:border-mint/60 hover:text-white">{s}</button>)}
            </div>
          </>
        )}
        {msgs.map((m, i) => (
          <p key={i} className={`max-w-[85%] whitespace-pre-wrap rounded-xl px-3 py-2 text-sm ${m.role === "user" ? "self-end bg-mint text-ink" : "bg-raise text-white"}`}>{m.content}</p>
        ))}
        {busy && <p className="self-start rounded-xl bg-raise px-3 py-2 text-sm text-mute" aria-label="Assistant is typing">Thinking…</p>}
        {err && <p role="alert" className="text-sm text-[#ff7b7b]">{err}</p>}
        <div ref={endRef} />
      </div>
      <form onSubmit={(e) => { e.preventDefault(); send(); }} className="border-t border-line p-3">
        <div className="flex gap-2">
          <input ref={inputRef} value={text} onChange={(e) => setText(e.target.value)} maxLength={500} aria-label="Your question" placeholder="Type your question"
            className="min-w-0 flex-1 rounded-lg border border-line bg-ink px-3 py-2 text-sm text-white placeholder:text-mute focus:border-mint focus:outline-none" />
          <button type="submit" disabled={busy || !text.trim()} className="rounded-lg bg-mint px-4 py-2 text-sm font-semibold text-ink disabled:opacity-50">Send</button>
        </div>
        <p className="mt-2 text-xs text-mute">AI can make mistakes. Check important details with {first}.</p>
      </form>
    </div>
  );
}
