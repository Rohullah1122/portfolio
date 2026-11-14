import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import ClientLayout from "./Clients/ClientsLayout";
import AdminLayout from "./Admin/AdminLayout";
import ProjectPreview from "./Clients/layout/preview_layout";

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/clients" replace />} />
        <Route path="/clients" element={<ClientLayout />} />
        <Route path="/clients/projects/:slug" element={<ProjectPreview />} />
        <Route path="/admin/*" element={<AdminLayout />} />
        <Route path="*" element={<Navigate to="/clients" replace />} />
      </Routes>
    </Router>
  );
}
