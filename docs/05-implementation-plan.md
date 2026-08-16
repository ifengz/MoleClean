# 实施计划

## 成功标准

完成后应满足：

- UI 改动不需要修改 vendored Mole。
- Mole 升级只改变 vendor snapshot、lock 和 Adapter，不扩散到 View。
- 每个 DMG 能追溯到明确的 Mole tag、commit、校验和和对应源码。
- 所有破坏性操作默认先生成 plan，用户确认后才执行。
- 合约变化会让 CI 明确失败，不允许静默降级。

## Phase 0：建立自己的项目身份

目标：避免在旧名称、旧版本和许可证不清的状态下开始 UI 改造。

- Fork `noah-qin/MoleUI` 作为初始代码来源。
- 配置 `moleui-upstream` 只读 remote，跟踪原 GUI 修复。
- 将 `tw93/Mole` 视为引擎 release 来源，不直接 merge 到 GUI 分支。
- 更换名称、Bundle ID、图标和更新源。
- 明确顶层许可证、第三方 notices 和 About 许可证入口。

验收：产品不会暗示是 Mole 官方 GUI；仓库和 App 能清楚说明两类源码及许可证。

## Phase 1：建立引擎锁文件

目标：让一次构建使用的 Mole 版本可以被复现和审计。

新增单一 `Mole.lock.json`，至少记录：

- release tag
- commit SHA
- source tarball SHA256
- `SHA256SUMS` 与 helper SHA256
- helper 架构
- 构建工具版本
- Mole LICENSE hash

两个 `.mole-cli-version` 改为由锁文件生成，禁止人工分别维护。

验收：删掉构建目录后，仍可从锁文件重建完全相同的 App 资源。

## Phase 2：建立 `MoleCoreAdapter` seam

目标：所有上游不稳定性集中在一个模块内。

正式 interface 与架构文档保持一致：

- `engineInfo()`
- `preview(request) -> MolePlan`
- `execute(approvedPlan: ApprovedMolePlan) -> MoleExecutionResult`
- `cancel(operationID)`

Adapter 返回 typed DTO；View 可以展示 DTO 中规范化的路径，但不构造、解释或执行原始路径，
也不接触 Shell、ANSI 文本或进程退出细节。

在上游没有稳定的“按已批准计划执行”接口前，写操作保持禁用。禁止通过重新扫描并直接执行来模拟计划绑定。

验收：全仓搜索不到 View 直接运行 `/bin/bash`、`mole`、`analyze-go` 或解析 stdout；
preview/execute plan digest 与文件身份不一致时明确拒绝执行；废纸篓模式无法验证时明确拒绝执行。

## Phase 3：升级到 Mole V1.46.0

目标：先消除已知版本债，再继续 UI 工作。

- 以 [PR #58](https://github.com/noah-qin/MoleUI/pull/58) 为输入重新生成受控升级 PR。
- 校验 tag、commit、source/helper SHA256。
- 重新构建并验证 arm64/x86_64 helper。
- 运行 Adapter 合约测试和安全 dry-run fixture。
- 人工审查 GPL、商标文件和 1.30.0→1.46.0 行为变化。

验收：About 显示 `V1.46.0` 和 commit；测试覆盖 GUI 实际调用路径，不只验证命令能退出。

## Phase 4：UI 改造

目标：只在稳定 seam 上重做体验。

优先顺序：

1. Dry Run / 操作 plan
2. App 与残留逐项审阅
3. 默认废纸篓和恢复入口
4. 清理、分析、状态页面
5. 历史记录与许可证页

验收：UI 不包含引擎私有路径或命令知识；所有删除动作都能从界面回溯到同一 plan。

## Phase 5：自动更新与发行

目标：让上游更新持续可维护，而不是再次停在旧版本。

- 定时检测 Mole 正式 release。
- Bot 更新 vendor 与 lock，兼容性、许可证/商标门禁与 CI 都通过后自动合并。
- CI 执行 schema、parser、fixture、架构、签名和零写入测试。
- 自动生成未签名测试 DMG；签名、公证和公开 Release 仍由人工发布流程处理。
- release 同时发布对应源码、许可证和校验和。

验收：发现上游新版本后能稳定形成一个可审阅 PR；合约失败时明确阻止发布。

## 回滚

- App release 与 Mole tag 一一对应。
- 保留最近一个已验证的 vendor snapshot 和 lock。
- 升级出现行为回归时回滚整个 snapshot，不混合新旧 Shell/helper。
- 不通过运行时切换到用户本机的未知 `mo` 版本做补偿。
