import { Routes, Route, Navigate } from "react-router-dom";
import { useStore } from "../store/portfolio";
import ServerError from "../Clients/site/ServerError";
import AdminShell from "./v2/AdminShell";
import Login from "./v2/Login";
import Dashboard from "./v2/Dashboard";
import ProjectsAdmin from "./v2/ProjectsAdmin";
import ProjectEditor from "./v2/ProjectEditor";
import ProfileAdmin from "./v2/ProfileAdmin";
import SkillsAdmin from "./v2/SkillsAdmin";
import MessagesAdmin from "./v2/MessagesAdmin";
import ExperienceAdmin from "./v2/experience_admin";

export default function AdminLayout() {
  const { loading, error, isAdmin } = useStore();
  if (loading) return <div className="grid min-h-screen place-items-center bg-ink text-mute" role="status">Loading…</div>;
  if (error) return <ServerError message={error} />;
  if (!isAdmin) return <Login />;
  return (
    <Routes>
      <Route element={<AdminShell />}>
        <Route index element={<Dashboard />} />
        <Route path="projects" element={<ProjectsAdmin />} />
        <Route path="projects/:slug" element={<ProjectEditor />} />
        <Route path="skills" element={<SkillsAdmin />} />
        <Route path="profile" element={<ProfileAdmin />} />
        <Route path="experience" element={<ExperienceAdmin />} />
        <Route path="messages" element={<MessagesAdmin />} />
        <Route path="*" element={<Navigate to="/admin" replace />} />
      </Route>
    </Routes>
  );
}
