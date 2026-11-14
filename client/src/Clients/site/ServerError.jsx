import { loadAll } from "../../store/portfolio";

export default function ServerError({ message }) {
  return (
    <div className="grid min-h-screen place-items-center bg-ink px-6 text-center">
      <div>
        <h1 className="font-display text-2xl font-bold text-white">Can’t load the portfolio</h1>
        <p className="mx-auto mt-2 max-w-md text-mute">{message}</p>
        <p className="mx-auto mt-2 max-w-md text-sm text-mute">Make sure the server is running (<code>npm run dev</code> in the server folder) and the database is set up.</p>
        <button onClick={loadAll} className="mt-6 rounded-lg bg-mint px-5 py-2.5 text-sm font-semibold text-ink">Try again</button>
      </div>
    </div>
  );
}
