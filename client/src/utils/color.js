// src/utils/colors.js
export const getTextColor = (hex) => {
  if (!hex) return "#ffffff";
  const c = hex.substring(1); // remove #
  const rgb = parseInt(c, 16);
  const r = (rgb >> 16) & 255;
  const g = (rgb >> 8) & 255;
  const b = rgb & 255;

  return (r * 299 + g * 587 + b * 114) / 1000 > 150
    ? "#000000"
    : "#ffffff";
};
