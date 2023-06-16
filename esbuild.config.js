const { stimulusPlugin } = require('esbuild-plugin-stimulus');
const path = require('path')

require("esbuild").build({
  entryPoints: ["application.js"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  publicPath: "assets",
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  watch: process.argv.includes("--watch"),
  plugins: [stimulusPlugin()],
  sourcemap: 'inline',
}).catch(() => process.exit(1))
