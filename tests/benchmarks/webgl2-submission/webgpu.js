/** Count native submissions outside the timed loop, then hash bottom-up RGBA8 to match WebGL readPixels. */
export async function inspectWebGPUFrame(canvas, device, render) {
  const counts = {};
  const restore = [];
  const hooks = [
    [GPURenderPassEncoder, ["draw", "drawIndexed", "setPipeline", "setBindGroup"]],
    [GPUComputePassEncoder, ["dispatchWorkgroups"]],
    [GPUQueue, ["writeBuffer", "submit"]],
    [GPUDevice, ["createRenderPipeline", "createBindGroup"]]
  ];
  try {
    for (const [type, methods] of hooks) {
      for (const name of methods) {
        const proto = type.prototype;
        const previous = proto[name];
        proto[name] = function (...args) {
          counts[name] = (counts[name] ?? 0) + 1;
          return previous.apply(this, args);
        };
        restore.push(() => {
          proto[name] = previous;
        });
      }
    }
    render();
  } finally {
    for (const reset of restore) reset();
  }
  const texture = canvas.getContext("webgpu").getCurrentTexture();
  const { width, height } = texture;
  const stride = Math.ceil((width * 4) / 256) * 256;
  const staging = device.createBuffer({
    size: stride * height,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ
  });
  try {
    const encoder = device.createCommandEncoder();
    encoder.copyTextureToBuffer({ texture }, { buffer: staging, bytesPerRow: stride }, { width, height });
    device.queue.submit([encoder.finish()]);
    await staging.mapAsync(GPUMapMode.READ);
    const data = new Uint8Array(staging.getMappedRange());
    const bgra = texture.format.startsWith("bgra");
    captureRGBA(data,width,height,stride,false,bgra);
    const channels = bgra ? [2, 1, 0, 3] : [0, 1, 2, 3];
    let hash = 0x811c9dc5;
    for (let y = height - 1; y >= 0; --y) {
      for (let i = 0; i < width; ++i) {
        for (const channel of channels) hash = Math.imul(hash ^ data[y * stride + i * 4 + channel], 0x01000193);
      }
    }
    return { counts, hash: (hash >>> 0).toString(16).padStart(8, "0") };
  } finally {
    staging.destroy();
  }
}


export function captureRGBA(bytes, width, height, stride, bottomUp, bgra = false) {
  if (!new URLSearchParams(location.search).has("capture")) return;
  const image = new ImageData(width, height);
  for (let y=0;y<height;y++) {
    const sourceY = bottomUp ? height-1-y : y;
    const row = bytes.subarray(sourceY*stride,sourceY*stride+width*4);
    image.data.set(row, y*width*4);
    if (bgra) for (let x=0; x<width; x++) {
      const i=(y*width+x)*4;
      image.data[i]=row[x*4+2];
      image.data[i+2]=row[x*4];
    }
  }
  const canvas=document.createElement("canvas");
  canvas.width=width; canvas.height=height;
  canvas.getContext("2d").putImageData(image,0,0);
  window.benchmarkCapture = canvas.toDataURL("image/png").split(",")[1];
}
