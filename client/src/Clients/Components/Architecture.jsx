import React from "react"; // ✅


function Architecture({ uml }) {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-6">Architecture & UML</h2>

      <div className="grid md:grid-cols-2 gap-8">
        <div className="bg-white/5 border border-white/10 rounded-xl p-6">
          <h3 className="mb-3 font-medium">System Overview</h3>
          <p className="text-gray-400 text-sm">{uml.description}</p>
        </div>

        <div className="rounded-xl overflow-hidden border border-white/10">
          <img src={uml.image} alt="UML Diagram" />
        </div>
      </div>
    </div>
  );
}


export default Architecture;