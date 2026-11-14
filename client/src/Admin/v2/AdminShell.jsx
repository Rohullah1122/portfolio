import { NavLink, Outlet } from "react-router-dom";
import { useEffect } from "react";
import { actions, useStore } from "../../store/portfolio";

const links = [["/admin", "Dashboard", true], ["/admin/projects", "Projects", false], ["/admin/skills", "Skills", false], ["/admin/experience", "Experience", false], ["/admin/profile", "Profile", false], ["/admin/messages", "Messages", false]];

export default function AdminShell() {
  const unread = useStore().messages.filter((m) => !m.read).length;
  useEffect(() => { actions.loadMessages(); }, []);
  return (
    <div className="cs min-h-screen bg-ink text-[#e6edf7] font-sans md:flex">
      <aside className="md:w-60 md:shrink-0 border-b md:border-b-0 md:border-r border-line bg-panel md:min-h-screen md:sticky md:top-0 md:self-start">
        <div className="px-5 py-5">
          <p className="font-display text-xl font-bold text-white">Admin<span className="text-mint">.</span></p>
          <p className="text-xs text-mute">Portfolio control panel</p>
        </div>
        <nav aria-label="Admin" className="flex md:flex-col gap-1 px-3 pb-3 overflow-x-auto">
          {links.map(([to, label, end]) => (
            <NavLink key={to} to={to} end={end}
              className={({ isActive }) => `rounded-lg px-3 py-2 text-sm whitespace-nowrap no-underline! ${isActive ? "bg-mint/15 text-mint!" : "text-mute! hover:text-white!"}`}>
              {label}{label === "Messages" && unread > 0 && <span className="ml-2 rounded-full bg-mint px-2 py-0.5 text-xs font-semibold text-ink">{unread}</span>}
            </NavLink>
          ))}
          <a href="/clients" target="_blank" rel="noreferrer" className="rounded-lg px-3 py-2 text-sm whitespace-nowrap text-link! no-underline! hover:bg-raise">View site ↗</a>
          <button type="button" onClick={actions.logout} className="rounded-lg px-3 py-2 text-left text-sm whitespace-nowrap text-mute hover:text-white">Sign out</button>
        </nav>
      </aside>
      <main className="flex-1 min-w-0 p-5 md:p-8"><Outlet /></main>
    </div>
  );
}
