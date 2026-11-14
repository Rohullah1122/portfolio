import React from "react"; // ✅


function Features({ features }) {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-6">Key Features</h2>

      <ul className="grid md:grid-cols-2 gap-4">
        {features.map(feature => (
          <li
            key={feature}
            className="bg-white/5 border border-white/10 rounded-lg p-4"
          >
            {feature}
          </li>
        ))}
      </ul>
    </div>
  );
}


export default Features;