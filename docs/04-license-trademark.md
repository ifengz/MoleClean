# MoleCleaner 许可证与商标边界

## 结论

若发布物继续内置并更新到 Mole `V1.46.0` 或之后的版本，最低风险路线是：

1. 将对外发行的完整源码和应用整体按 GPL-3.0 发布；
2. 保留 MoleUI 与历史 Mole 快照的 MIT 版权和许可声明；
3. 随每个二进制版本提供精确对应的源码、vendor 快照及构建和安装脚本；
4. 在 App 的 About / Licenses 页面展示 GPL-3.0、第三方 notices 和源码入口；
5. 对外改用不含 `Mole` 的产品名和自有图标，不暗示上游认可或关联。

当前目录名 `MoleCleaner` 只能作为内部代号。公开仓库名、App 显示名、Bundle 名称、图标、网站和安装包文件名都应在首次发行前完成重命名。

如果暂不接受整个发行物采用 GPL-3.0，则不要合并 Mole `V1.46.0` 更新，也不要分发包含新版 Mole 的构建。可以继续研究或仅内部使用旧的 MIT 快照，但这不等于仍在跟随当前上游。

> 本文是工程风险边界和发布门禁，不是法律意见。UI 与独立 CLI 是否构成 GPL 意义上的单一组合程序，最终取决于具体集成和分发事实；正式商业发行前应由熟悉开源许可证的律师复核。

## 已确认的许可证时间线

| 对象 | 许可证事实 | 工程含义 |
| --- | --- | --- |
| MoleUI `v0.1.5` | 顶层 [`LICENSE`](https://github.com/noah-qin/MoleUI/blob/v0.1.5/LICENSE) 是 MIT | 既有 SwiftUI 代码可以按 MIT 条款继续使用、修改和再许可，但必须保留原版权及许可声明 |
| MoleUI `v0.1.5` 内置 Mole `1.30.0` | [`Resources/mole/LICENSE`](https://github.com/noah-qin/MoleUI/blob/v0.1.5/Resources/mole/LICENSE) 是 MIT | 该固定历史快照仍受 MIT 许可；后续改许可证不追溯改变已经取得的 MIT 权利 |
| tw93/Mole，2026-06-11 | 上游先从 MIT 改为 AGPL-3.0，提交说明明确写明旧 MIT release 不追溯；随后同日切换为 GPL-3.0（[`a1b5581`](https://github.com/tw93/Mole/commit/a1b5581883b4528515cd7959c8cce84b3d1c57f2)、[`1ff8220`](https://github.com/tw93/Mole/commit/1ff8220130bcf05810931b08cc8512c4c776b75c)） | 更新新版 vendor 时不能继续把 Mole 当作 MIT 依赖 |
| Mole `V1.46.0` | GitHub 识别其 [`LICENSE`](https://github.com/tw93/Mole/blob/V1.46.0/LICENSE) 为 GPL-3.0；对应 [release](https://github.com/tw93/Mole/releases/tag/V1.46.0) 发布于 2026-07-11 | 将该版本带入安装包后，发行流程必须满足 GPL-3.0 |
| MoleUI PR #58 | [`Update Mole CLI to 1.46.0`](https://github.com/noah-qin/MoleUI/pull/58) 同时引入新版 `Resources/mole/LICENSE` 和 `TRADEMARK.md` | 合并 vendor 文件本身不等于完成合规；顶层许可证、源码发布、notices、About 页面和品牌仍需同步处理 |

## GPL-3.0 对发行物的最低要求

以下门禁基于 [GNU GPL-3.0 正文](https://www.gnu.org/licenses/gpl-3.0.html)：

- 保留版权、许可证及无担保声明，并向接收者提供 GPL-3.0 文本（第 4 节）。
- 对修改过的版本作显著修改声明并给出相关日期；若发行物构成一个基于 GPL 程序的整体，该整体须按 GPL-3.0 授权（第 5 节）。
- 分发 DMG、ZIP 或其他目标代码时，以许可证允许的方式同步提供机器可读的 Corresponding Source（第 6 节）。最直接的实现是：每个 release 的二进制旁放置对应源码归档和清晰源码链接，且不额外收费。
- Corresponding Source 不只是 Swift / Shell / Go 源文件。GPL 第 1 节还将生成、安装、运行和修改目标代码所需的源码及控制这些活动的脚本纳入范围，因此 Xcode 工程、依赖锁定、vendor 元数据、打包和安装脚本也必须可复现地提供。
- 不得给接收者附加限制其 GPL 权利的条款（第 10 节）。发布页、EULA、自动更新条款和下载条款都不能与 GPL 冲突。
- GPL 不自动授予商标权；第 7(e) 节也明确允许拒绝授予商标使用权。代码可用不等于名称和图标可用。

建议仓库至少包含：

```text
LICENSE                         # GPL-3.0 完整文本
THIRD_PARTY_NOTICES.md          # MoleUI MIT、历史 Mole MIT 及其他依赖 notices
Resources/mole/LICENSE          # 与固定上游 tag 完全一致
Resources/mole/TRADEMARK.md     # 与固定上游 tag 完全一致
Resources/mole/VERSION.json     # tag、commit SHA、制品 SHA-256
scripts/                        # 构建、vendor 更新、打包与安装所需脚本
```

MIT 代码兼容纳入 GPL 发行物，但不能删除原 MIT notice。顶层采用 GPL-3.0 时，应在 `THIRD_PARTY_NOTICES.md` 明确保留 MoleUI 原作者和 tw93 历史快照的版权与 MIT 文本，避免让“整体 GPL”被误读为抹去既有署名或历史许可。

## UI 与 CLI 的组合边界

FSF 的 [GPL FAQ：aggregate 与组合程序](https://www.gnu.org/licenses/gpl-faq.en.html#MereAggregation) 说明，判断重点不只在是否分成两个进程，还包括通信机制和交换信息的语义：简单的命令行参数、pipe 或 socket 通常更接近独立程序；共享复杂内部数据结构或紧密控制流则可能形成组合程序。其 [plug-in 说明](https://www.gnu.org/licenses/gpl-faq.en.html#GPLPlugins) 也指出，`fork` / `exec` 本身不是自动隔离许可证责任的万能边界。

因此不能仅凭“SwiftUI 是 MIT、Mole 是单独进程”就断言整个 DMG 可以继续只标 MIT。风险会被以下行为放大：

- 将 Mole 源码直接 vendor 并与 App 一体打包、共同安装和共同升级；
- 运行时改写 Mole 私有脚本或调用内部函数；
- 依赖未版本化的内部文本、复杂结构或控制流；
- 产品离开内置 Mole 就不具备其核心用途。

工程上应继续采用 `MoleCoreAdapter`，只调用固定 release 的公开 CLI 契约，并使用参数数组而不是 `/bin/sh -c`。这能降低耦合和升级风险，但不能代替法律判断。鉴于当前目标就是把 Mole 内置为产品核心引擎，本项目不把“两个进程”当作规避 GPL 的发行策略，默认按完整发行物 GPL-3.0 收口。

## 商标与品牌门禁

上游当前 [`TRADEMARK.md`](https://github.com/tw93/Mole/blob/V1.46.0/TRADEMARK.md) 要求公开 fork 使用自己的名称和图标，不得暗示获得 Mole 认可或关联，也不得用 Mole 名称营销付费或竞争产品；`Mole for Mac` 还是单独的专有产品名称和资产。

首次公开前必须完成：

- 产品名、公开仓库名、Bundle display name 和安装包名不包含 `Mole`；
- 替换 Mole 名称、鼹鼠图标、截图、宣传素材和相似度过高的视觉资产；
- About 页面只用描述性文字说明“使用 tw93/Mole 的 GPL-3.0 代码”，并明确“非官方、未获认可、与 Mole 项目及 Mole for Mac 无关联”；
- 不使用上游名称作为域名、商店关键词或主要营销标识；
- 如确需保留任何品牌元素，先取得上游书面许可并归档授权范围。

## 每次上游更新的许可证门禁

自动化只在许可证/商标文件未变化、兼容性与 CI 均通过时自动合并并生成测试 DMG；一旦 `LICENSE` 或 `TRADEMARK.md` 变化，必须停止并转人工处理。更新必须同时验证：

1. 固定 tag、commit SHA 和下载制品 SHA-256；
2. 比对 `LICENSE`、`TRADEMARK.md`、`NOTICE`、依赖清单和发布说明；
3. 展示完整源码快照 diff，但 App Resources 只允许包含 runtime manifest 白名单内的文件；
4. 验证 adapter 契约、dry-run 零写入、确认后执行和失败暴露；
5. 更新 About / Licenses 页面、第三方 notices 和对应源码归档；
6. 用干净环境从同一 tag 源码重建安装包，确认源码与二进制一致；
7. 由发布负责人确认产品名、图标和文案没有回引上游商标。

PR #58 只能作为“把 Mole 代码更新到 `1.46.0`”的输入，不能直接作为可发行状态。以上七项未全部通过时，禁止发布包含该 vendor 更新的 DMG。

## 发布决策

| 场景 | 可以做 | 不可以宣称或执行 |
| --- | --- | --- |
| 仅本地研究，不向他人提供副本 | 修改、运行和验证新 Mole；准备 GPL 收口 | 不能把本地验证描述为发行合规已完成 |
| 继续分发旧 `1.30.0` MIT 快照 | 保留全部 MIT notices 后分发固定旧版 | 不能宣称跟随当前 Mole，也不能混入 `V1.46.0` 代码后仍只用 MIT |
| 分发内置 `V1.46.0` 的新 App | 按本文最低风险路线整体 GPL-3.0、提供对应源码并彻底换品牌 | 不能只替换 `Resources/mole/LICENSE` 就发布；不能沿用 `MoleCleaner` 公开品牌 |

最终建议（待用户确认）：**整体 GPL-3.0、保留所有 MIT notices、对外改名换图标后，再开始 UI 重构和上游持续更新。** 在确认前不得视为已作出的发行决策；如不接受其中任一项，先停止公开发行，不做许可证降级补偿。

## 一手资料

- [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html)
- [FSF GPL FAQ：aggregate 与组合程序](https://www.gnu.org/licenses/gpl-faq.en.html#MereAggregation)
- [FSF GPL FAQ：主程序与 plug-in 的边界](https://www.gnu.org/licenses/gpl-faq.en.html#GPLPlugins)
- [GitHub Docs：Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [MoleUI `v0.1.5` LICENSE](https://github.com/noah-qin/MoleUI/blob/v0.1.5/LICENSE)
- [MoleUI `v0.1.5` bundled Mole LICENSE](https://github.com/noah-qin/MoleUI/blob/v0.1.5/Resources/mole/LICENSE)
- [Mole `V1.46.0` LICENSE](https://github.com/tw93/Mole/blob/V1.46.0/LICENSE)
- [Mole `V1.46.0` TRADEMARK.md](https://github.com/tw93/Mole/blob/V1.46.0/TRADEMARK.md)
- [MoleUI PR #58](https://github.com/noah-qin/MoleUI/pull/58)
