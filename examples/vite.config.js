const path = require("path");
const fs = require("fs-extra");
const OUT_PATH = "dist";
const templateStr = fs.readFileSync(path.join(__dirname, "template/iframe.ejs"), "utf8");

// 替换 ejs 模版格式的字符串，如 <%= title %>: templateStr.replaceEJS("title","replaced title");
String.prototype.replaceEJS = function (regStr, replaceStr) {
  return this.replace(new RegExp(`<%=\\s*${regStr}\\s*%>`, "g"), replaceStr);
};

const out_p = path.join(__dirname, "./");
console.log(out_p);

const sourceRoot = path.join(__dirname, "./src");

function collectExampleFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      return entry.name.startsWith("_") ? [] : collectExampleFiles(absolutePath);
    }
    return entry.isFile() && entry.name.endsWith(".ts") && !entry.name.startsWith("_") ? [absolutePath] : [];
  });
}

const demoList = collectExampleFiles(sourceRoot)
  .sort()
  .map((absolutePath) => {
    const relativePath = path.relative(sourceRoot, absolutePath);
    const content = fs.readFileSync(absolutePath, "utf8");
    const title = /@title\s+(.+)\b/.exec(content);
    const category = /@category\s+(.+)\b/.exec(content);
    const backend = /@backend\s+(webgl2|webgpu)\b/.exec(content);

    if (!title || !category) {
      throw new Error(`title and category must be set in playground[${relativePath}]`);
    }

    return {
      title: title[1],
      category: category[1],
      backend: backend?.[1] ?? "webgl2",
      file: relativePath.slice(0, -path.extname(relativePath).length).split(path.sep).join("/")
    };
  });

fs.emptyDirSync(path.resolve(__dirname, OUT_PATH));

demoList.forEach(({ title, file }) => {
  const ejs = templateStr.replaceEJS("title", title).replaceEJS("url", `./${path.basename(file)}.ts`);
  const outputModule = path.resolve(__dirname, OUT_PATH, file + ".ts");
  const sourceModule = path.resolve(sourceRoot, file);
  const importPath = path.relative(path.dirname(outputModule), sourceModule).split(path.sep).join("/");

  fs.outputFileSync(outputModule, `import "${importPath.startsWith(".") ? importPath : `./${importPath}`}"`);
  fs.outputFileSync(path.resolve(__dirname, OUT_PATH, file + ".html"), ejs);
});

// output demolist
const demoSorted = {};
demoList.forEach(({ title, category, backend, file }) => {
  if (!demoSorted[category]) {
    demoSorted[category] = [];
  }
  demoSorted[category].push({
    src: file,
    label: title,
    backend
  });
});
Object.values(demoSorted).forEach((demos) => demos.sort((left, right) => left.label.localeCompare(right.label)));

fs.outputJSONSync(path.join(__dirname, OUT_PATH, ".demoList.json"), demoSorted);

module.exports = {
  server: {
    open: true,
    host: "0.0.0.0",
    port: 3000
  },
  resolve: {
    dedupe: ["@galacean/engine"]
  },
  optimizeDeps: {
    exclude: [
      "@galacean/engine",
      "@galacean/engine-physics-physx",
      "@galacean/engine-draco",
      "@galacean/engine-lottie",
      "@galacean/engine-spine",
      "@galacean/engine-shader-compiler",
      "@galacean/engine-shader",
      "@galacean/engine-ui",
      "@galacean/engine-xr",
      "@galacean/engine-xr-webxr",
      "@galacean/tools-baker",
      "@galacean/engine-toolkit",
      "@galacean/engine-toolkit-auxiliary-lines",
      "@galacean/engine-toolkit-controls",
      "@galacean/engine-toolkit-framebuffer-picker",
      "@galacean/engine-toolkit-gizmo",
      "@galacean/engine-toolkit-lines",
      "@galacean/engine-toolkit-outline",
      "@galacean/engine-toolkit-planar-shadow-material",
      "@galacean/engine-toolkit-skeleton-viewer",
      "@galacean/engine-toolkit-grid-material",
      "@galacean/engine-toolkit-navigation-gizmo",
      "@galacean/engine-toolkit-geometry-sketch",
      "@galacean/engine-toolkit-stats",
      "@galacean/engine-toolkit-input-logger",
      "@galacean/engine-toolkit-custom-material"
    ]
  }
};
