# 项目决策：以 MoleUI 为界面起点，独立跟踪 Mole 引擎

- 状态：建议采用，尚未进入实现
- 日期：2026-07-15
- 范围：架构与维护策略，不包含本轮代码实施

## 问题

希望保留 Mole 的清理能力和上游更新，同时重做一个免费、原生 SwiftUI 的 macOS GUI。
直接修改 MoleUI 的 View 很容易，但当前 GUI 对上游 Shell 内部实现依赖较深，若没有稳定 seam，
每次 Mole 更新都可能破坏卸载、清理和进度解析。

## 已核实事实

1. `noah-qin/MoleUI` 不是 `tw93/Mole` 的 GitHub fork，而是独立 SwiftUI 衍生项目。
2. 仓库只有一套完整内核：`Resources/mole/`。根目录和 App 目录中的两个
   `.mole-cli-version` 只是重复版本标记，当前都为 `1.30.0`。
3. `Resources/mole/mo` 只是调用 `mole` 的别名脚本，不是第二套 CLI。
4. 上游当前稳定版为 `V1.46.0`。MoleUI 的 [PR #58](https://github.com/noah-qin/MoleUI/pull/58)
   已生成升级快照，但没有进入 `main`。
5. 现有 workflow 已具备“检测 release、替换 vendor、重建 helper、测试并创建 PR”的基础，
   真正缺口是可靠合约和持续人工合并闸门。

证据：

- [根版本标记](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/.mole-cli-version)
- [App 内版本标记](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/MoleUI/.mole-cli-version)
- [内置 Mole 入口](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/Resources/mole/mole)
- [CLI 执行器](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/MoleUI/Model/CLIExecutor.swift)
- [Mole V1.30.0...V1.46.0](https://github.com/tw93/Mole/compare/V1.30.0...V1.46.0)

## 决策

以 MoleUI 作为界面和签名发布流程的候选起点，但不把 Mole 源码合并进 SwiftUI 的日常开发历史。

维护两条清晰主线：

- GUI 主线：自己的 SwiftUI、交互、品牌和发行流程。
- 引擎主线：只吸收 `tw93/Mole` 的正式 release tag，并固定版本、commit 和校验和。

二者只通过 `MoleCoreAdapter` 的窄 interface 相连。上游变更必须先通过 Adapter 合约测试，
再允许进入 GUI release。

## 为什么不直接跟随 `main`

- `main` 随时变化，无法保证 DMG 可复现。
- 上游完整运行时包含 Shell、Go helper 和资源文件，不是单一可替换二进制。
- 当前部分功能依赖人类可读 stdout 和 Shell 私有函数，未形成完整稳定 JSON interface。
- release tag 更适合作为人工审核和回滚锚点。

## 不采用的方案

### 每次构建下载 `latest`

拒绝。会引入网络、供应链、版本漂移和不可复现构建风险。

### 自动检测后直接合并

拒绝。自动任务可以准备升级 PR，但破坏性变更必须由合约测试和人工审核暴露。

### 让每个 View 直接调用 Mole

拒绝。这样上游变化会扩散到所有 View/Model，无法集中修复或验证。

### 把 submodule 当作完整更新方案

不作为默认方案。submodule 的 PR 只显示指针变化，容易漏递归 checkout，且与 helper 重建、
签名、公证和发行审查割裂。优先使用可审阅的 vendor snapshot 或 subtree。

## 非目标

- 本阶段不重写 Mole 的清理算法。
- 本阶段不增加付费、账号或云服务。
- 本阶段不追求跨平台。
- 本阶段不自动清除系统级 daemon、helper 或 PKG。

## 进入实现前的决策门

1. 确定新名称和图标。
2. 确定 GPL-3.0 发行策略。
3. 确定首个支持的 macOS 最低版本。
4. 确定首个目标是自用测试还是公开发行。
