import { useState } from "react";
import { actions } from "../../store/portfolio";
import { Btn, Input } from "./fields";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    setBusy(true); setError("");
    const err = await actions.login(email, password);
    setBusy(false);
    if (err) setError(err);
  };
  return (
    <div className="grid min-h-screen place-items-center bg-ink px-5 font-sans text-[#e6edf7]">
      <form onSubmit={submit} className="w-full max-w-sm space-y-5 rounded-xl border border-line bg-panel p-6">
        <div>
          <p className="font-display text-2xl font-bold text-white">Admin<span className="text-mint">.</span></p>
          <p className="text-sm text-mute">Sign in to manage your portfolio.</p>
        </div>
        <Input label="Email" type="email" autoComplete="username" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <Input label="Password" type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        <p role="alert" className="min-h-5 text-sm text-[#ff7b7b]">{error}</p>
        <Btn kind="primary" type="submit" disabled={busy} className="w-full">{busy ? "Signing in…" : "Sign in"}</Btn>
      </form>
    </div>
  );
}
