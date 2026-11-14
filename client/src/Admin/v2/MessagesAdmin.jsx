import { actions, useStore } from "../../store/portfolio";
import { Btn } from "./fields";

export default function MessagesAdmin() {
  const { messages } = useStore();
  return (
    <div className="max-w-3xl">
      <h1 className="font-display text-3xl font-bold text-white">Messages</h1>
      <p className="mt-1 text-mute">Sent from the contact form on your site.</p>
      <ul className="mt-8 space-y-4">
        {messages.map((m) => (
          <li key={m.id} className={`rounded-xl border bg-panel p-5 ${m.read ? "border-line" : "border-mint/60"}`}>
            <div className="flex flex-wrap items-baseline justify-between gap-2">
              <p className="text-white">{m.name} {!m.read && <span className="ml-2 rounded-full bg-mint/15 px-2 py-0.5 text-xs text-mint">New</span>}</p>
              <time dateTime={m.at} className="text-sm text-mute">{new Date(m.at).toLocaleString()}</time>
            </div>
            <a href={`mailto:${m.email}`} className="text-sm text-link! no-underline!">{m.email}</a>
            <p className="mt-3 whitespace-pre-wrap text-[#cdd8ea]">{m.body}</p>
            <div className="mt-4 flex gap-2">
              <Btn onClick={() => actions.setMessageRead(m.id, !m.read)}>{m.read ? "Mark unread" : "Mark read"}</Btn>
              <Btn onClick={() => window.confirm("Delete this message?") && actions.deleteMessage(m.id)}>Delete</Btn>
            </div>
          </li>
        ))}
        {!messages.length && <li className="rounded-xl border border-line bg-panel p-8 text-center text-mute">No messages yet. Try the contact form on your site.</li>}
      </ul>
    </div>
  );
}
