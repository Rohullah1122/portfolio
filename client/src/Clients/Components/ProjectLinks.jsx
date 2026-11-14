import React from "react"; // ✅

function ProjectLinks({ links }) {
  return (
    <div className="flex gap-6 justify-center pt-8">
      <a
        href={links.github}
        className="px-6 py-3 rounded-xl bg-white/10 hover:bg-white/20 transition"
      >
        GitHub
      </a>

      <a
        href={links.live}
        className="px-6 py-3 rounded-xl bg-green-500 text-black font-medium hover:bg-green-400 transition"
      >
        Live Demo
      </a>
    </div>
  );
}



export default ProjectLinks;