# MoleCleaner

MoleCleaner 是一个尚未开始实现的 macOS 清理工具方案：以
[`noah-qin/MoleUI`](https://github.com/noah-qin/MoleUI) 的原生 SwiftUI 界面为候选起点，
把 [`tw93/Mole`](https://github.com/tw93/Mole) 作为独立、可升级、可验证的清理引擎。

> 本仓库以 `code/` 保存 SwiftUI 应用与内置运行时，以 `docs/` 保存决策、架构和实施资料。
> `docs/` 与源码一起提交；它们不属于 Mole 引擎 vendor snapshot。

## 分支策略

- `main-moleui`：从原仓拉入后的原始 MoleUI 基线，固定在开始修改前的最后提交 `697a564`。该分支只用于对照和回溯，不作为日常开发目标。
- `main/blue-theme`：本仓库当前默认主线和稳定开发分支。UI 修改、Mole CLI 内核正式版本更新、发行修复都在这里进行。
- `auto-update-mole-*`：上游内核自动升级时临时创建的分支；升级 PR 合并到 `main/blue-theme` 后删除。

所有新的功能和内核升级 PR 以 `main/blue-theme` 为目标；不要把日常改动合并回 `main-moleui`。

## 当前结论

- 可以基于 MoleUI 修改 UI，同时持续跟随 Mole 的正式 release。
- UI 与 Mole 引擎必须通过单一 `MoleCoreAdapter` seam 交互；View 不直接拼 Shell，也不直接解析终端文本。
- Mole 引擎固定到明确的 tag、commit 和校验和；自动任务只创建升级 PR，不自动合并。
- 先修复引擎更新与合约测试，再改 UI。否则会继续扩大对旧内核的依赖。
- 发行新版 Mole 引擎前必须处理 GPL-3.0 和 Mole 商标要求。

## 已核实的版本状态（2026-07-15）

| 项目 | 当前状态 |
| --- | --- |
| MoleUI release tag | `v0.1.5`，内置 Mole `1.30.0` |
| MoleUI main-moleui | 原始基线快照；本仓当前开发主线为 `main/blue-theme` |
| 两个 `.mole-cli-version` | 都是同一内核的版本标记，不是两套 CLI |
| Mole upstream | `V1.46.0` |
| 自动更新 | 已生成 [PR #58](https://github.com/noah-qin/MoleUI/pull/58)，尚未合并 |
| MoleUI 许可证 | 原创 Swift UI 为 MIT |
| Mole `1.30.0` | 当时为 MIT |
| Mole `1.46.0` | GPL-3.0，并有独立商标要求 |

## 阅读顺序

1. [项目决策](01-decision.md)
2. [架构设计](02-architecture.md)
3. [上游同步](03-upstream-sync.md)
4. [许可证与商标](04-license-trademark.md)
5. [实施计划](05-implementation-plan.md)
6. [UI 开工顺序](06-ui-start.md)
7. [GitHub Actions 构建指南](build.md)

## 硬约束

- 不在普通构建或运行时下载 `latest`。
- 不静默兼容上游破坏性变化；升级合约失败即停止发布。
- 不在真实用户目录执行 CI 卸载测试。
- 不自动永久删除；Adapter 必须显式请求并验证废纸篓模式，无法保证时禁止执行。
- 不继续使用 Mole 名称、图标或文案暗示官方背书，除非获得明确许可。

## 尚待确认

- 新产品名称与图标。
- 是否采用“整个发行物 GPL-3.0、保留继承的 MIT notices”的低风险许可方案。
- 是否公开发布，还是先做仅供自用的测试版本。
