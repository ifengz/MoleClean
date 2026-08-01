# UI 开工顺序

## 结论

第一轮不做 Dashboard 美化，也不继续扩展现有的“Clean All”按钮。
先完成一个安全、可审阅的操作计划界面：扫描只生成 plan，用户审阅 plan 后才可确认执行。

## 前置门禁

开始 UI 实现前必须完成：

1. 确定公开产品名称、图标和 Bundle ID；公开发行不使用 Mole 名称或图标。
2. 确定 GPL-3.0 发行策略；未确认前只进行本地验证，不发布。
3. 建立 `Mole.lock.json` 和 `MoleCoreAdapter`；View 不能直接引用 `CLIExecutor`、Shell 命令或 stdout。
4. 在 `code/` 下完成 GUI 源码与 runtime 的同步、合约和零写入测试。

## 第一轮界面

入口：替换现有 Clean 页面。

1. 点击“扫描”只调用 `adapter.preview(request)`。
2. 显示 `MolePlan`：操作项、规范化路径、预计大小、风险级别、动作和 plan digest。
3. 默认选中“移至废纸篓”；review-only 或无法确认废纸篓的项不可执行。
4. 用户确认后，把同一份 `ApprovedMolePlan` 交给 `adapter.execute`。
5. 展示逐项结果、失败原因、废纸篓位置和可恢复入口。

## 不做的事

- 不把 Shell 命令、私有脚本路径或 ANSI/终端文本带进 View。
- 不在确认后重新扫描并直接删除。
- 不把永久删除作为默认操作。
- 不为旧 `CleanModel`、`SafetyController` 或 `CLIExecutor` 增加兼容分支。

## 验收

- 每一次写操作都能追溯到用户确认的 plan digest。
- plan 发生路径、inode 或 symlink 漂移时，执行明确拒绝。
- Preview 阶段零写入；权限不足、解析失败或废纸篓不可用时明确失败。
- UI 测试只替换 `MoleCoreAdapter`，生产代码不含 Mock 分支。
