import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import elmPlugin from "vite-plugin-elm";

export default defineConfig({
  plugins: [react(), elmPlugin()],
});
