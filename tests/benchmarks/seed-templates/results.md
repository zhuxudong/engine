# Seed 樱花与沙漠的桌面 WebGPU 基准

基于 `dev/2.0` 的渲染器版本为 `547c9e892`。两个模板取自 `experimental/engine-next` 的 `92ea60eae`。两端加载相同的樱花 `sakura-pearl`、沙漠 `titan-wasteland` 项目及原始发布资产。比较包含真实草地、岩体、动物、灯光、阴影、水体、屏幕空间反射（SSR）和 Bloom。模板集成修订 `12c41cd38` 和 `23c264df8` 对齐了反射接收区域和湿地材质的屏幕坐标。[复现方法](README.md)

## 测量方法

主机使用 Apple M5 Pro（20 核 GPU）、macOS 26.3.2 和 Chromium 140.0.7339.16。两端均为 960 × 540、DPR 1，使用相同世界种子、五个相机关键帧和固定 1/60 秒的模拟步长。显示刷新间隔、引擎 CPU update 和硬件 GPU 忙时分别采集。硬件计时取 Metal System Trace 中 Chromium GPU 进程在每个帧窗口处于 Active 的时间，各硬件阶段的重叠区间只累计一次。每次新开世界，预热 90 帧、记录 120 帧。完整模板交替访问顺序并各重复两次。API 计时器的计时边界随图形 API 不同，只用于各自后端的诊断。[硬件计时方法](metal/README.md)

## 渲染器与模板的分工

| 模块 | 切换后端时实际执行的工作 | 希望进一步提速时，工作应落在哪里 |
| --- | --- | --- |
| 草地、自然植被 | Seed 自己读取密度、高度并选择草地 LOD。它使用引擎的反馈接口生成记录，WebGL2 执行 transform feedback，WebGPU 在引擎内部执行 compute。普通树木与灌木沿用相同的合批条件，历史 shader 在两端都可走实例绘制。 | 引擎可以合批绘制已提交的实例。将可见性计算也交给 GPU 需要可复用的实例记录、分组边界和可见列表。 |
| 地形遮挡 | Seed 在 CPU 上结合高度场和岩体分组测试地平线，两端执行同一算法。 | 原生遮挡查询允许在没有 compute shader 的情况下测试代理几何体。实例很多时可另用 Hi-Z、compute 和间接绘制，避免将每个实例的可见结果读回 CPU。 |
| SSR | 现有管线构建深度金字塔、追踪并合成反射。切换后端需要渲染器统一裁剪和采样坐标。 | 追踪算法和画质参数决定主要成本。若采用 compute，可以在效果实现内接入，复用场景原有的反射接收材质。 |
| Bloom | 两端都执行既有的多级降采样/上采样全屏绘制。 | 引擎的后处理实现可以改变绘制或计算的组织方式，场景仍使用同一 Bloom 配置。 |

WebGPU 的深度测试会拒绝被遮住的片元。对象级遮挡查询则要求应用或引擎在绘制时显式记录，异步获取是否有样本通过。WebGL2 同样提供 `ANY_SAMPLES_PASSED`。在另一种 GPU 驱动的实现中，compute 批量读取分层深度、写可见实例及间接参数，再由 `drawIndexedIndirect` 消费。Seed 当前的 SSR 深度金字塔服务于反射，岩体地平线测试发生在 CPU。[WebGPU 遮挡查询](https://www.w3.org/TR/webgpu/#occlusion-query) · [WebGL2 查询](https://registry.khronos.org/webgl/specs/latest/2.0/) · [WebGPU 间接绘制](https://www.w3.org/TR/webgpu/#dom-gpurendercommandsmixin-drawindexedindirect)

[草地选择与实例生成](https://github.com/galacean/engine/blob/92ea60eaee49b2f1188b373c178c34ca511c9f87/packages/world-planning/src/runtime/SeedWorldForwardGrass.ts#L1703) · [反馈接口的 WebGPU 实现](../../../packages/rhi-webgpu/src/WebGPUFeedbackKernel.ts) · [网格合批条件](../../../packages/core/src/mesh/MeshRenderer.ts) · [Bloom 通路](../../../packages/core/src/postProcess/PostProcessUberPass.ts)

这个 Seed 版本随项目分发 188 个引擎文件覆盖，其中 119 个属于 core。这是模板分支已有的结构。真正需要额外适配的例子包括叶片纹理表直接向 WebGL2 查询尺寸、砌体生成直接使用 WebGL 缓冲，以及自定义湿地 shader 内嵌的屏幕坐标换算。正常调用引擎 Bloom、实例绘制或反馈接口的代码沿用原来的入口。[Seed 原始覆盖清单](https://github.com/galacean/engine/blob/92ea60eaee49b2f1188b373c178c34ca511c9f87/packages/modify/native-overrides.json) · [模板集成代码](fixture-capabilities.mjs)

## 用真实场景发现的兼容问题

- 历史 shader 的实例化变体曾退回逐个物体提交。修复后，樱花中段的一次检查从 341 个原生 WebGPU draw 降至 162 个，同一镜头的 WebGL2 为 152 个。两端主前向和阴影着色器各有 94 和 30 个 draw，草地实例均为 23,240 个。原生 draw 还包含后端生成 mip 等辅助工作。
- 私有 uniform 缓冲的回收曾将同帧更新拆分成大量复制和渲染 pass。修复前，樱花中段抽查记录了 196 次 buffer-to-buffer 复制、120 段 Camera Forward。修复后，该帧为 0 次复制和一段 Camera Forward。公共缓冲的 Discard 语义由独立回归用例覆盖。
- 沙漠水面暴露了 SSR 裁剪的纵轴错误。在 480 × 270 的追踪纹理上，正确接收区域覆盖下方 120 行，原 WebGPU 实现选中了上方 120 行。在同一水面区域读回 736 个追踪像素，WebGL2 原始命中 714 个，WebGPU 修正前为 0，修正后为 715 个，两端最终历史合成均有 735 个有效像素。2,835 个呈现水面像素的平均 RGB 差从 20.83/255 降至 0.47/255。历史湿地 shader 的屏幕采样方向也已对齐，仅更新原有编译指令中的坐标表达式。
