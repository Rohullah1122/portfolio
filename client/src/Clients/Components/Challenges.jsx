import React from "react"; // ✅


function Challenges({ challenges }) {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-6">
        Challenges & Solutions
      </h2>

      <div className="space-y-4">
        {challenges.map((c, i) => (
          <div
            key={i}
            className="bg-white/5 border border-white/10 rounded-xl p-6"
          >
            <p className="text-red-400 font-medium">Challenge</p>
            <p className="text-gray-300 mb-3">{c.problem}</p>

            <p className="text-green-400 font-medium">Solution</p>
            <p className="text-gray-300">{c.solution}</p>
          </div>
        ))}
      </div>
    </div>
  );
}


export default Challenges;