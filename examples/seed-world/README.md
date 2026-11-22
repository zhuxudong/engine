# Seed World on WebGL2 and WebGPU

Preview the Sakura Pearl and Titan Wasteland templates with either renderer. Both builds use the same Seed sources, projects and shaders, the authored spawn camera and the URL seed. The upper-left counter shows engine frames per second.

## Prepare

From an engine checkout with Git history, use Node.js, pnpm 9, Python 3.9+, Git and tar. Install dependencies and build the engine packages, then prepare the previews in a directory outside the checkout.

```sh
pnpm install --frozen-lockfile
pnpm b:module
work=$(mktemp -d)
pnpm seed prepare "$work"
```

Preparation uses the current engine commit and the Seed template revision `experimental/engine-next@679453a52`. It fetches the pinned Seed commit from the official repository if needed. It overlays Seed's native engine changes (including grass feedback, realtime IBL and SSR), applies the integration patch and compiles the shared shader catalog for GLES 3 and WGSL. The two production bundles and their source revisions are recorded under the specified directory. The templates load their original CDN assets at runtime.

## Run

Start these previews from the checkout using the same working directory. Each command prints direct links to both templates.

```sh
pnpm seed serve "$work" --backend webgl2 &
pnpm seed serve "$work" --backend webgpu
```

| Template | WebGL2 | WebGPU |
| --- | --- | --- |
| Sakura Pearl | [Open Sakura](http://127.0.0.1:15483/world/demos/seed-world/index.html?template=sakura-pearl&seed=20261122&view=3d) | [Open Sakura](http://127.0.0.1:15482/world/demos/seed-world/index.html?template=sakura-pearl&seed=20261122&view=3d) |
| Titan Wasteland | [Open Titan](http://127.0.0.1:15483/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d) | [Open Titan](http://127.0.0.1:15482/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d) |

Use a WebGPU-capable browser for the WebGPU preview. Compare the two backends in the foreground with the same template, seed, browser window size and device pixel ratio. Use `--port` to change the port and `fps=0` to hide the counter.

After committing engine changes, rebuild the engine packages, run `pnpm seed prepare "$work"` again and restart the two previews. Previously prepared bundles stay in the working directory so existing servers can finish using them.
