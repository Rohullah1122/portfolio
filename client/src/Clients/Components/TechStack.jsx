
import React from "react"; // ✅


 function TechStack({ stack }) {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-6">Tech Stack</h2>

      <div className="grid md:grid-cols-3 gap-6">
        {Object.entries(stack).map(([category, items]) => (
          <div
            key={category}
            className="bg-white/5 border border-white/10 rounded-xl p-6"
          >
            <h3 className="font-medium text-lg mb-4 capitalize">
              {category}
            </h3>

            <div className="flex flex-wrap gap-2">
              {items.map(item => (
                <span
                  key={item}
                  className="px-3 py-1 text-sm rounded-full
                  bg-black/40 border border-white/10"
                >
                  {item}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default TechStack;
