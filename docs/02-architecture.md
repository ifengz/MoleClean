# MoleCleaner 架构边界

## 目标

MoleCleaner 只负责提供原生 SwiftUI 界面；清理规则和系统操作继续由上游 [tw93/Mole](https://github.com/tw93/Mole) 提供。最短且稳定的结构是：

```text
SwiftUI Views / ViewModels
          ↓ typed DTO
   MoleCoreAdapter（唯一边界）
          ↓ 固定且可审计的运行时协议
 Resources/mole（runtime manifest 白名单）
          ↑ 从固定快照生成
 Vendor/MoleSource（完整 release tag 源码）
```

禁止 Views、ViewModels 或业务 Models 直接拼接 Shell、调用 `Process`、解析终端输出或引用 Mole 私有脚本函数。所有引擎变化只能收口在 `MoleCoreAdapter` 内。

## 模块职责

### SwiftUI 层

- 展示应用、扫描结果、风险提示和执行结果。
- 将用户意图转换为 typed request，不接触命令字符串。
- 执行前必须展示 preview；只有用户确认过的 plan 才能交给 adapter 执行。

### MoleCoreAdapter

对 UI 只暴露窄接口，示意如下：

```swift
protocol MoleCoreAdapter {
    func engineInfo() async throws -> MoleEngineInfo
    func preview(_ request: MoleOperationRequest) async throws -> MolePlan
    func execute(_ approvedPlan: ApprovedMolePlan) async throws -> MoleExecutionResult
    func cancel(operationID: UUID) async
}
```

建议的 typed DTO：

- `MoleOperationRequest`：枚举操作类型及明确参数，不允许任意命令字符串。
- `MoleEngineInfo`：tag、commit、校验和与能力集合。
- `MolePlan`：plan ID、操作项、路径、预计大小、动作、风险级别、是否只读审查。
- `ApprovedMolePlan`：绑定 preview 的不可变摘要，防止预览后执行内容漂移。
- `MoleExecutionResult`：退出状态、逐项结果、失败原因与废纸篓位置。

adapter 必须使用参数数组启动进程，不经过 `/bin/sh -c`；路径、应用标识和用户输入不得参与 Shell 拼接。

`execute` 不能重新运行一个会重新扫描文件系统的宽泛命令后假定结果未变。正式实现必须满足：

- preview 输出规范化的路径、文件类型、设备/inode、symlink 目标、动作和 plan digest；
- 用户确认的是该 digest 对应的完整计划；
- execute 只接受 `ApprovedMolePlan`，并在写入前重新核对文件身份；
- 上游没有“按已批准计划执行”的稳定接口时，写操作保持禁用并明确报错，不能退化为重新扫描后直接删除。

## 调用协议风险分层

按以下优先级选择上游接口，不能混用后“猜测成功”：

1. **公开、带版本契约的 JSON**：最低风险。仅当 Mole 官方提供稳定 schema 时采用；DTO 解码失败必须直接报错。
2. **公开 CLI 命令和退出码**：可接受。锁定 tag，并为该版本维护解析 fixture；未知字段或格式变化必须使兼容性测试失败。
3. **面向人的终端文本**：高风险、只允许作为过渡。不得依赖颜色、空格或自然语言判断执行成功。
4. **私有 Shell 函数、脚本内部文件或运行时改写脚本**：禁止。它们不属于公开契约，上游小改动即可静默破坏 GUI。

现有 MoleUI 的 [`CLIExecutor.swift`](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/MoleUI/Model/CLIExecutor.swift) 可作为需要收口的历史实现证据，而不是新架构的调用范本。

## 上游版本管理

- `Vendor/MoleSource` 保存与某个 [Mole release](https://github.com/tw93/Mole/releases) 精确对应的完整源码快照。
- `Resources/mole` 由固定 runtime manifest 从该快照生成，只包含运行所需文件、许可证和 notices。
- 禁止构建时下载 `latest` 或跟随 `main`。
- 同时记录 release tag、commit SHA 和制品 SHA-256；App 展示的版本必须读取同一份元数据，禁止维护两份手写版本号。
- 自动化只负责发现新 release 并创建更新 PR，不自动合并。
- 更新 PR 必须展示 vendor diff、许可证变化和协议兼容性测试结果。
- 只有通过 preview、执行安全性及回滚验证后，才能更新固定版本。

## 测试 seam

测试只替换 `MoleCoreAdapter` 协议实现，不在生产代码中加入 Mock 分支：

- **DTO 单元测试**：命令枚举、路径、风险等级和未知输出均 fail loud。
- **解析契约测试**：保存固定 tag 的真实脱敏输出 fixture，验证 JSON/文本解析；格式漂移必须失败。
- **adapter 集成测试**：在临时目录运行 vendored Mole，验证参数数组、退出码、取消和超时。
- **dry-run 安全测试**：preview 阶段文件系统零写入。
- **确认绑定测试**：执行计划必须与用户确认的 plan 摘要一致；不一致时拒绝执行。
- **危险路径测试**：系统受保护路径、越界路径和 review-only 项不得被静默删除。
- **版本更新门禁**：对新旧固定 tag 运行同一组契约测试，再决定是否升级。

## 权限执行边界

- 普通 App 进程不通过 Shell 拼接 `sudo`，也不持有环境级管理员权限。
- `/Library`、LaunchDaemon、PrivilegedHelper、系统收据等项目默认只读审查，不进入自动删除计划。
- 若未来确需系统级写入，必须另行设计签名的窄权限 helper interface；在此之前不做临时提权补偿。
- 权限不足、部分执行或废纸篓不可用时立即停止，并逐项报告已经完成和未完成的动作。
- 厂商要求专用卸载器的 App 继续交给官方卸载器处理。

## 不变量

- UI 不知道 Shell 命令；Mole 不知道 UI 状态。
- 未 preview、未确认或 plan 已变化时，不能执行写操作。
- 解析失败、权限不足、版本不兼容或部分删除都必须明确失败，禁止降级为“看起来成功”。
- Adapter 必须显式请求并验证废纸篓模式；上游入口无法保证时禁止执行。永久删除必须是单独、明确且可审计的用户动作。
- 不因改 UI 改动 `Resources/mole`；不因更新 Mole 顺带重构 UI。
