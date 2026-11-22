# Seed World on WebGL2 and WebGPU

Preview the Sakura Pearl and Titan Wasteland templates with either renderer. Both builds use the same Seed sources, projects and shaders, the authored spawn camera and the URL seed. The upper-left counter shows engine frames per second.

## Prepare

Use Node.js 20.19+, pnpm 9.3.0, Python 3.9+, Git and tar. Start with the experiment branch and its Git history. If you already have this branch checked out, start at `pnpm install` in that checkout.

```sh
GIT_LFS_SKIP_SMUDGE=1 git clone --branch codex/seed-webgpu-warmup --single-branch https://github.com/zhuxudong/engine.git engine-webgpu
cd engine-webgpu
pnpm install --frozen-lockfile
pnpm b:module
pnpm seed prepare ../engine-webgpu-preview
```

The renderer comes from the current engine commit (`HEAD`). The Seed World demo, templates and engine extensions for features such as grass feedback, realtime IBL and SSR come from [the pinned `experimental/engine-next` commit](https://github.com/galacean/engine/commit/679453a52c8aa874b81124b9990320f9580369a8). `prepare` fetches that Git object if needed, applies the integration patch from this branch and compiles the shared shader catalog for GLES 3 and WGSL. The templates load their original CDN assets at runtime.

## Run

From the engine checkout, run the command for the backend you want. To compare both, run one command per terminal. Each prints links to both templates. Another terminal on the same machine can reuse the prepared directory immediately.

```sh
pnpm seed serve ../engine-webgpu-preview --backend webgpu
pnpm seed serve ../engine-webgpu-preview --backend webgl2
```

| Template | WebGL2 | WebGPU |
| --- | --- | --- |
| Sakura Pearl | [Open Sakura](http://127.0.0.1:15483/world/demos/seed-world/index.html?template=sakura-pearl&seed=20261122&view=3d) | [Open Sakura](http://127.0.0.1:15482/world/demos/seed-world/index.html?template=sakura-pearl&seed=20261122&view=3d) |
| Titan Wasteland | [Open Titan](http://127.0.0.1:15483/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d) | [Open Titan](http://127.0.0.1:15482/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d) |

Use a WebGPU-capable browser for the WebGPU preview. Compare the two backends in the foreground with the same template, seed, browser window size and device pixel ratio. Use `--port` to change the port and `fps=0` to hide the counter.

To check exactly what you are serving, read `../engine-webgpu-preview/seed-preview.json`. Its `engine` and `seed` fields identify the source commits, and `build` selects the active build directory. After committing engine changes, rerun `pnpm b:module` and `pnpm seed prepare ../engine-webgpu-preview`, then restart the preview.

## Titan Wasteland shader warmup experiment

After `pnpm seed prepare`, build the additional WebGPU variant and run its local preview.

```sh
pnpm seed warmup ../engine-webgpu-preview
pnpm seed serve ../engine-webgpu-preview --backend webgpu-warmup
```

Open [Titan Wasteland with loading warmup and FPS](http://127.0.0.1:15484/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d&fps=1). The ordinary WebGPU build on port 15482 provides the control using the same spawn, seed and resolution. For a LAN HTTPS server, the warmup document root is `<preview>/<build>/<directory>/webgpu`, where `build` comes from `seed-preview.json` and `directory` comes from that build's `warmup.json`.

The warmup build adds offline WGSL to the 26 pinned Seed shader assets, including the copies in both binary resource bundles. During loading it prepares the desert material variants, eight directions around the spawn, picking and the photo editor. It restores the authored camera before enabling input. The prepared inputs cover the measured desert scene. New materials, views or different device limits can still trigger normal runtime compilation.

To regenerate the offline data after changing the shader sources, see the [shader export instructions](warmup/export/README.md).

## Open on a phone

The preview command listens on the computer's loopback address. For a phone on the same Wi-Fi, serve the generated WebGPU directory as the HTTPS document root. Use a hostname that resolves to the computer's LAN address and a matching certificate the phone trusts.

For example, with Python 3.14 and the paths to the certificate chain and private key in `SEED_TLS_CERT` and `SEED_TLS_KEY`, run this from the engine checkout

```sh
webgpu_dir=$(node -p 'require("node:path").resolve("../engine-webgpu-preview", require("../engine-webgpu-preview/seed-preview.json").build, "webgpu")')
python3.14 -m http.server 8443 --directory "$webgpu_dir" --tls-cert "$SEED_TLS_CERT" --tls-key "$SEED_TLS_KEY"
```

Open `https://<hostname>:8443/world/demos/seed-world/index.html?template=titan-wasteland&seed=20261122&view=3d&fps=1` on the phone. For cherry blossoms, use `template=sakura-pearl`. The served bundle determines the backend. To compare WebGL2 on the phone, serve the sibling `webgl2` directory on a second HTTPS port and keep the template URL parameters identical.
