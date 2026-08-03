# WebGPU 多后端引擎管线设计

## 范围

| 项目 | 当前约束 |
| --- | --- |
| 基线 | `fb443fe48e7ac0c1daba9cf6a1a3681da5299b4f` |
| 默认后端 | WebGL，现有 `WebGLEngine.create` 行为不变 |
| WebGPU 入口 | 独立的 `WebGPUEngine.create` |
| 后端切换 | 销毁当前页面后重新创建页面和 canvas 上下文 |
| 上层 API | Scene、Camera、Mesh、Material、Shader 和资源 API 不区分后端 |
| Shader 源 | ShaderLab 单一源码，由编译器分别生成 GLES 和 WGSL |
| 本阶段内容 | 引擎 RHI、ShaderLab codegen、低层 compute/indirect、管线诊断 |

## 初始化契约

```ts
const webGLEngine = await WebGLEngine.create(configuration);
const webGPUEngine = await WebGPUEngine.create(configuration);
```

初始化之后，两类 Engine 进入相同的 core 生命周期。后端身份由
`IHardwareRenderer.backend` 提供，core 不读取浏览器原生图形对象。
WebGPU 初始化失败时返回错误，不自动创建 WebGL 上下文。

## 模块边界

| 模块 | 负责内容 | 不负责内容 |
| --- | --- | --- |
| `packages/core` | 后端中立资源、Shader、pass 调度和 capability 查询 | WebGPU 原生对象和 bind-group 规则 |
| `packages/design` | RHI、shader compiler 和预编译产物契约 | 任一后端的具体资源实现 |
| `packages/rhi-webgl` | WebGL 状态、资源和 draw 实现 | WebGPU fallback |
| `packages/rhi-webgpu` | WebGPU device、资源、pipeline、bind group 和 command 编码 | 上层场景功能策略 |
| `packages/shader-compiler` | ShaderLab 解析及 GLES/WGSL codegen | 运行时 device 和 pipeline 生命周期 |
| `packages/loader` | 按 Engine 后端加载单目标 shader 产物 | 同时加载多个 target |

WebGPU 原生类型只允许出现在 `packages/rhi-webgpu`。core 与 design 使用
`Buffer`、`IPlatformPrimitive`、`IPlatformComputeProgram` 等中立接口传递资源。

## Shader 产物契约

| 后端 | `platformTarget` | 文件后缀 | 产物内容 |
| --- | --- | --- | --- |
| WebGL | GLES | `.shaderc` | 单目标 GLES 指令及反射 |
| WebGPU | WGSL | `.wgslc` | 单目标 WGSL 指令及反射 |

同一次构建可分别执行两个 target，但每个文件只保存一个 target。
`ShaderLoader` 根据当前 Engine 后端选择后缀，并校验产物的
`platformTarget`。运行时 `Shader.create(source)` 仍接受相同 ShaderLab 源，
由当前 Engine 选择 codegen target。

WGSL codegen 当前包含以下中立语义：

- vertex、fragment、compute stage 入口与反射；
- uniform、texture、sampler 和 storage-buffer binding；
- workgroup 变量、原子操作和 compute dispatch builtin；
- sampled texture、depth texture 和 instance builtin；
- 可选 `shader-f16` 对应的 half 类型 lowering。

## RHI 能力

| 能力 | Core/Design 契约 | WebGL 行为 | WebGPU 行为 |
| --- | --- | --- | --- |
| 后端身份 | `GraphicsBackend` | `webgl` | `webgpu` |
| render-target 原点 | `RenderTargetOrigin` | `lower-left` | `upper-left` |
| compute | `ComputePass`、`IPlatformComputeProgram` | capability 为不支持，调用显式报错 | compute pipeline 与 dispatch |
| storage buffer | `BufferBindFlag.Storage` | 不支持的绑定显式报错 | storage binding 与读写 |
| indirect draw | `Primitive._drawIndirect`、`IPlatformPrimitive.drawIndirect` | 不支持时显式报错 | 原生 indirect command |
| half arithmetic | `ShaderCapabilities.float16` | false | 由 adapter feature 决定 |
| GPU 时间戳 | `GPUTiming` | unsupported | opt-in、异步读取、按 pass 记录 |

Indirect draw 停留在 Primitive/RHI 层。本阶段不向 Renderer、RenderElement
或场景组件增加 buffer 绑定入口，避免把特定 GPU-driven 策略固化进通用管线。

## 管线状态与诊断

`RenderContext.setRenderTarget` 接受可选 pass label。现有渲染阶段只提供诊断名称，
不改变 attachment、clear、draw 和提交顺序。

WebGPU RHI 在单个 render pass 内缓存 pipeline、bind group、vertex buffer、
index buffer、viewport、scissor 和 blend constant 等状态。pass 切换时缓存失效，
状态去重不跨越原生 pass 边界。

GPU 时间戳满足以下约束：

- 创建 Engine 时显式开启；
- 每次请求只覆盖下一次 command submission；
- readback 使用有限槽位并异步完成；
- 槽位耗尽时记录 dropped count，不阻塞帧提交；
- 不支持 timestamp-query 时 `requestSample()` 返回 false。

## 本阶段明确排除

| 排除项 | 边界 |
| --- | --- |
| depth priming | 不保留开关、pass、事件或渲染队列分支 |
| 自定义 after-depth 阶段 | 不增加 core pipeline stage |
| 高层 GPU-driven 消费者 | 不增加 Renderer、RenderElement 或 batcher 专用接口 |
| 遮挡剔除实现 | 只保留可复用的 compute、storage 和 indirect 底层能力 |
| 应用与性能场景 | 不包含示例、性能页面、场景资源或场景测试 |

## 验证记录

| 验证项 | 状态 |
| --- | --- |
| Design/Core/WebGPU RHI/Galacean/Loader 类型构建 | 通过 |
| Shader compiler 构建 | 通过 |
| Engine module 构建 | 通过；24 个内置 ShaderLab 分别生成 `.shaderc` 和 `.wgslc` |
| WebGPU RHI 单测 | 通过；4 files、19 tests |
| Core/ShaderLab/WebGL 定向测试 | 通过；6 browser files、152 tests |
| 原生 WebGPU 可用性 | Chromium 成功取得 adapter/device；WGSL codegen 29 tests 通过 |
| 提交路径与禁用接口审计 | 通过；无示例目录、depth priming 或高层 indirect 消费者 |
