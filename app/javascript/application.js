
import React from "react";
import ReactDOM from "react-dom/client";
import ShopifyDashboard from "./components/HelloWorld";

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("react-root");
  if (container) {
    const root = ReactDOM.createRoot(container);
    root.render(<ShopifyDashboard />); // no props needed
  }
});

