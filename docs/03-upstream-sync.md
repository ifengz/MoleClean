# Mole 上游同步与版本锁定

- 状态：方案已定，尚未实施
- 核验日期：2026-07-15
- 目标：让 GUI 持续跟随 Mole 正式 release，同时保证每次构建可复现、升级可审阅、失败可回滚

## 当前事实

MoleUI 当前并不存在“两套 CLI”。仓库只有一套 vendored Mole，位于
[`Resources/mole/`](https://github.com/noah-qin/MoleUI/tree/f7825a298546560120ff5d8bcc19bfbf193626b6/Resources/mole)。
以下两个文件只是同一套内核的重复版本标记，当前内容都为 `1.30.0`：

- [根目录 `.mole-cli-version`](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/.mole-cli-version)
- [App 内 `.mole-cli-version`](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/MoleUI/.mole-cli-version)

上游 Mole 当前正式版是
[`V1.46.0`](https://github.com/tw93/Mole/releases/tag/V1.46.0)，对应 commit
`181569409a0627087c24d3edb12718366fd93f75`。从 `V1.30.0` 到 `V1.46.0` 的完整变化可在
[官方 compare](https://github.com/tw93/Mole/compare/V1.30.0...V1.46.0) 中审阅。

MoleUI 已由自动任务创建
[`PR #58`](https://github.com/noah-qin/MoleUI/pull/58) 尝试升级到 `1.46.0`；在 2026-07-15
核验时状态为 `OPEN` 且尚未进入 `main`。GitHub 的 merge status 会动态变化，
不作为文档中的稳定验收事实。因此“有升级 PR”不等于“主分支已经升级”。

## 现有自动更新能力与缺口

现有 [`auto-update-mole.yml`](https://github.com/noah-qin/MoleUI/blob/f7825a298546560120ff5d8bcc19bfbf193626b6/.github/workflows/auto-update-mole.yml)
每天 `00:00 UTC` 运行，也支持手动触发。它会：

1. 读取根目录 `.mole-cli-version`，查询 GitHub latest release。
2. 下载对应 tag 的源码归档，整体替换 `Resources/mole`。
3. 重建 arm64、x86_64 helper，并合成 universal Mach-O。
4. 执行文件存在性、JSON 可解析和各命令 `--dry-run` 冒烟检查。
5. 兼容时更新两个版本标记并创建 PR；不兼容时创建 Issue。

当前 workflow 只在兼容性、许可证/商标门禁和 CI 都通过后自动合并更新 PR，并生成未签名测试 DMG artifact；它不会自动创建公开 Release。当前缺口是：

- 只记录易漂移的版本字符串，没有锁定 tag 对应 commit 和下载制品 SHA-256。
- 两个版本文件依赖同步写入，仍可能出现显示版本与实际 vendor 不一致。
- “JSON 能解析”和“命令退出成功”只能证明基本可运行，不能证明字段语义、删除计划和零写入约束未变化。
- PR 没有强制合约测试、人工审核和发行门禁时，仍不能安全进入 GUI release。

## 推荐同步模型

### 1. 单一锁文件

新增一个版本事实源，例如 `Mole.lock.json`。至少固定：

```json
{
  "tag": "V1.46.0",
  "commit": "181569409a0627087c24d3edb12718366fd93f75",
  "sourceTarballSHA256": "<verified-sha256>",
  "statusHelperSHA256": "<verified-sha256>",
  "analyzeHelperSHA256": "<verified-sha256>",
  "licenseSHA256": "<verified-sha256>"
}
```

`tag`、`commit` 与所有 SHA-256 必须在升级 PR 中一次性生成并审核。SHA-256 用于完整性和复现锁定，
不能单独证明首次下载内容来自可信发布者。源码身份以审阅过的 Git commit 为锚；helper 优先同时核验上游
`SHA256SUMS` 和可用的 GitHub build provenance。App 的 About 信息、构建脚本和必要的兼容版本文件都从该锁文件生成，禁止人工维护两份版本号。

### 2. 升级 bot 只准备 PR

升级 bot 的职责限定为：

1. 只检测 [Mole 正式 release](https://github.com/tw93/Mole/releases)，不跟随 `main`。
2. 解析 tag 到不可变 commit；下载归档后先计算并写入 SHA-256。
3. 替换完整 vendor snapshot，重建 helper，更新 lock 和生成文件。
4. 输出上游 release notes、vendor diff、许可证及商标文件变化。
5. 运行全部合约测试；通过后创建升级 PR，失败则创建阻塞 Issue。

自动化只生成未签名测试 DMG，不创建公开 Release 或 release tag。`LICENSE`、`TRADEMARK.md` 或合约门禁变化时必须停止并转人工处理。

### 3. vendor snapshot 优先

版本库保留与 tag 对应的完整、可审阅源码快照；App 安装包只复制运行时白名单。二者是不同层：

- `Vendor/MoleSource`：用于源码审查、许可证合规和可复现构建的完整 tag 快照。
- `Resources/mole`：由固定 manifest 从源码快照生成，只包含运行所需脚本、helper、许可证和 notices。

该模型具备以下性质：

- PR 能直接展示实际进入 App 的 Shell、Go 源码、资源和许可证变化。
- checkout 后即可复现，不依赖递归初始化或构建时网络。
- 一个 Git commit 可以同时固定 vendor、lock、Adapter 兼容改动和测试 fixture。

若确实需要保留上游提交历史，可以使用 `git subtree`，但同步命令和 squash 规则必须固定。它的维护成本高于普通 vendor snapshot，因此不是首选。

不建议使用 submodule：常规 PR 主要显示指针变化，容易漏掉递归 checkout，也不能自动解决 helper 重建、签名、fixture 和许可证审查。禁止在 build time 下载 `latest`：同一 GUI commit 会随时间产出不同二进制，既不可复现，也扩大供应链风险。

## 升级合约测试

每个 Mole 升级 PR 至少通过以下门禁，任一失败都必须停止合并：

1. **版本一致性**：tag 可解析到 lock 中的 commit；vendor、helper、About 与生成的版本文件全部匹配 lock。
2. **制品完整性**：源码归档和打包 helper 的 SHA-256 与 lock 一致；helper 同时包含 arm64 与 x86_64，且签名步骤成功。
3. **接口契约**：`status`、`analyze`、`health` 和 GUI 实际使用的命令以固定真实 fixture 验证字段类型、必填字段、退出码与错误语义；未知结构直接失败。
4. **Dry Run 零写入**：在隔离临时 `HOME` 中对 clean、optimize、purge、installer、uninstall 执行 dry run，前后文件树摘要必须一致。
5. **计划绑定**：preview 生成的计划与执行时的 plan digest、规范路径和文件身份必须一致；重新扫描、路径或 symlink 漂移时拒绝执行。
6. **删除模式**：每条写命令必须显式请求并验证废纸篓模式；入口默认永久删除或无法验证时禁止执行。
7. **危险路径**：系统保护路径、越界路径、symlink 逃逸和 review-only 项不得进入自动删除集合。
8. **失败语义**：权限不足、解析失败、部分删除、取消和超时必须返回明确失败，不得被转换成“成功”。
9. **许可证门禁**：Mole 的 `LICENSE`、`TRADEMARK.md` 或 notices 发生变化时，PR 必须要求人工审核。

生产代码不加入 Mock 分支。测试通过 Adapter 的替代实现、真实脱敏 fixture 和临时目录完成；任何会删除文件的集成测试都不得指向真实用户目录。

## 升级 PR 验收清单

- [ ] 目标是正式 release tag，不是 `main`、分支或 `latest` 浮动引用。
- [ ] lock 记录完整 tag、40 位 commit 和全部要求的 SHA-256。
- [ ] `Vendor/MoleSource` 与 lock 对应的完整 tag 快照一致。
- [ ] `Resources/mole` 由 runtime manifest 生成，没有混入旧脚本、旧 helper 或开发期文件。
- [ ] 两个旧版本标记由 lock 自动生成，或已收口为单一事实源。
- [ ] PR 清楚展示 vendor diff、release notes、许可证和商标变化。
- [ ] 新旧引擎均通过同一组 Adapter 合约测试。
- [ ] Dry Run 零写入、危险路径、部分失败和取消测试通过，且无跳过项。
- [ ] arm64、x86_64 helper 与最终 App 的签名、公证前检查通过。
- [ ] 自动化只在兼容性、许可证/商标门禁和 CI 都通过后合并；其他情况创建阻塞 Issue。
- [ ] bot 不自动创建公开 Release 或 release tag。
- [ ] App 内可显示所用 Mole tag、commit，并能追溯到对应源码。

## 回滚策略

回滚单位必须是“vendor snapshot + lock + Adapter 兼容改动 + fixture”的完整升级提交，不能只替换某个 helper 或版本字符串。

1. **合并前失败**：保留失败日志，关闭升级 PR 或转为 draft；旧锁定版本不动。
2. **合并后、发布前失败**：revert 整个升级提交，重新运行旧版本全部门禁后再构建。
3. **发布后回归**：基于上一个已验证 lock 发布修复版本；同时下架或停止推送问题版本，记录受影响操作。
4. **恢复验证**：确认 About、vendor、helper 校验和与回滚后的 lock 完全一致，并重复零写入与卸载 preview 测试。

禁止把用户本机安装的未知 `mo`、运行时下载的 `latest`，或“新脚本 + 旧 helper”的混合组合当作回滚补偿。无法验证一致性时必须停止发布并明确报错。
