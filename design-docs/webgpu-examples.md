# WebGPU 原子案例规划

## 漏项分析

| 现象 | 代码与历史事实 | 原因 |
| --- | --- | --- |
| WebGPU 分类为空 | 当前分支的引擎收口提交明确把示例排除在范围外；备份分支只有单体 benchmark | 引擎能力实现与可运行案例没有被设为同一个验收门槛 |
| 子目录案例无法出现在导航 | 原 `vite.config.js` 只读取 `examples/src` 第一层 `.ts` 文件 | examples 发现器不支持按能力分层的目录 |
| Advance 混入 Splat | `gaussian-splatting.ts` 来自分叉基线，早于 WebGPU RHI 提交 | 收口时只审计新增文件，没有按当前分支职责审计继承案例 |
| 页面可 ready 但没有画面 | 旧验收依赖状态字段和静态检查 | 没有把 canvas 实际像素和运行时错误纳入案例门槛 |

## 目录契约

```text
examples/src/webgpu/
├── _shared/       # 后端选择、Engine 初始化、ready/error 契约
├── basics/        # Engine、swapchain、ShaderLab
├── resources/     # Buffer、uniform、texture、sampler
├── render/        # draw、instancing、render target、depth、MSAA
├── compute/       # compute、storage、atomic
├── diagnostics/   # GPU timing
└── benchmark/     # 双后端性能基线
```

- WebGPU 分类中的案例默认创建 `WebGPUEngine`；引擎全局默认行为仍是 `WebGLEngine`。
- 双后端案例可切换到 WebGL2；WebGPU-only 案例只创建 `WebGPUEngine`。
- 后端切换更新 URL 并刷新页面；每个页面只创建一个 Engine 和一个 canvas 上下文。
- 案例只能使用 Galacean 公共 API；不访问 `navigator.gpu`、WebGPU 原生对象、private RHI 或 demo 专用接口。
- `_` 开头的目录和文件只承载共享实现，不作为案例进入导航。
- 原子案例必须让被测能力在画面中可辨认；只有 ShaderLab 基础绘制、MSAA 边缘等能力本身需要三角形时才保留三角形画面。

## 当前覆盖

| 目录        | 案例                    | 支持后端        | 验证内容                                                |
| ----------- | ----------------------- | --------------- | ------------------------------------------------------- |
| basics      | Backend Initialization  | WebGL2 / WebGPU | `WebGLEngine` / `WebGPUEngine`、swapchain、公共材质绘制 |
| basics      | ShaderLab Triangle      | WebGL2 / WebGPU | 同一 ShaderLab 源生成 GLES/WGSL 并绘制                  |
| resources   | Index Buffer            | WebGL2 / WebGPU | index buffer 绑定与 indexed draw                        |
| resources   | Buffer Update           | WebGL2 / WebGPU | vertex buffer 运行时更新                                |
| resources   | Uniform Update          | WebGL2 / WebGPU | material uniform 更新                                   |
| resources   | Texture Sampling        | WebGL2 / WebGPU | Texture2D、sampler、mipmap                              |
| resources   | Cube Texture            | WebGL2 / WebGPU | TextureCube 上传与采样                                  |
| render      | Instanced Draw          | WebGL2 / WebGPU | `gl_InstanceID` 和单次 instanced draw                   |
| render      | Render Target           | WebGL2 / WebGPU | 离屏渲染、render texture 采样、后端原点一致性           |
| render      | Depth Test              | WebGL2 / WebGPU | 深度测试与遮挡顺序                                      |
| render      | MSAA Render Target      | WebGL2 / WebGPU | 4x MSAA attachment 与 resolve                           |
| compute     | Compute Sampled Texture | WebGPU          | compute sampled texture、storage/vertex buffer 复用     |
| compute     | Compute Storage Buffer  | WebGPU          | compute 写 storage buffer 后直接绘制                    |
| compute     | Compute Atomics         | WebGPU          | 原子写入及后续 compute 消费                             |
| diagnostics | GPU Timing              | WebGPU          | opt-in timestamp query 与异步结果                       |
| benchmark   | Grasslands Benchmark    | WebGL2 / WebGPU | Grasslands 草簇、实例数量滑杆、常驻 FPS 与双后端重载    |

## 暂不展示

| 能力                           | 当前边界                                                       |
| ------------------------------ | -------------------------------------------------------------- |
| indirect draw                  | 只有 `Primitive._drawIndirect` 内部入口，没有公共消费者 API    |
| Texture2DArray                 | 当前双后端 ShaderLab target 契约未形成可复用案例               |
| shader-f16                     | adapter capability 已在 RHI 层，案例层没有公共 capability 分支 |
| GPU 遮挡剔除                   | 未实现；缺少 depth pyramid、可见性/压缩 compute 和公开 indirect 消费管线 |
| occlusion query、render bundle | 当前 RHI 未实现                                                |
| blit、copy、transform feedback | 当前公共管线未实现或不属于 WebGPU 通用路径                     |
| World 地形、Grasslands runtime、Splat | 不进入原子 RHI 案例；benchmark 只复用草簇几何，不依赖 World 模块 |

## E2E 门槛

每个案例必须同时满足：

- 页面没有 `pageerror`、console error 或请求失败；
- `exampleReady` 只在实际绘制若干帧后设置；
- canvas 截图包含非背景像素；
- 双后端案例使用相同 workload，截图平均像素差异小于 5%；
- 后端 selector 切换后旧 document sentinel 消失，证明 Engine 通过刷新页面重建。
- benchmark 默认显示 WebGPU、常驻 FPS，并能用 candidates 滑杆把 WebGL2 压到交互帧预算以下。
