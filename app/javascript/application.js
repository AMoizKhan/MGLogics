// // Entry point for the build script in your package.json
// import "@hotwired/turbo-rails"
// import "./controllers"
// import React from "react";
// import ReactDOM from "react-dom";
// import ProductList from "./components/ProductList";

// document.addEventListener("DOMContentLoaded", () => {
//   ReactDOM.render(
//     <ProductList />,
//     document.getElementById("react-root")
//   );
// });
// import React from "react";
// import ReactDOM from "react-dom/client";
// import App from "./App";

// document.addEventListener("DOMContentLoaded", () => {
//   const root = ReactDOM.createRoot(document.getElementById("react-root"));
//   root.render(<App />);
// });
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

