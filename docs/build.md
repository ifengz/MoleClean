# GitHub Actions 构建指南

仓库地址：[ifengz/MoleClean](https://github.com/ifengz/MoleClean)

## 分支规则

```text
main-moleui       原始 MoleUI 基线，只用于对照和回溯
main/blue-theme   当前默认主线，所有开发、更新和发布都使用它
auto-update-*     Mole CLI 内核升级时临时创建的分支
```
所有新的 PR 目标分支都选择 `main/blue-theme`。不要把日常改动合并回 `main-moleui`。

## 普通 CI

代码推送到 `main/blue-theme` 后，GitHub 会自动运行 `CI` workflow。

检查内容包括：

- SwiftFormat
- SwiftLint
- macOS 编译
- 单元测试
- UI 测试
- 安全扫描

也可以手动运行：

1. 打开仓库的 `Actions` 页面。
2. 选择 `CI`。
3. 点击右侧 `Run workflow`。
4. Branch 选择 `main/blue-theme`。
5. 点击 `Run workflow`。

## 构建 DMG

1. 打开 `Actions`。
2. 选择 `Build & Release`。
3. 点击 `Run workflow`。
4. Branch 选择 `main/blue-theme`。
5. 点击 `Run workflow`。
6. 等待 workflow 完成。
7. 打开本次 Run 页面，在底部 `Artifacts` 下载 `MoleClean-xxxxxxx.dmg`。

没有配置签名 Secrets 时，也会生成 DMG，但它是未签名版本，仅适合测试。

正式签名和公证需要配置以下 GitHub Secrets：

- `CERTIFICATE_P12`
- `CERTIFICATE_PASSWORD`
- `APPLE_ID`
- `APP_PASSWORD`
- `TEAM_ID`

## 更新 Mole CLI 内核

1. 打开 `Actions`。
2. 选择 `Auto Update Mole CLI`。
3. 点击 `Run workflow`。
4. Branch 选择 `main/blue-theme`。
5. 点击 `Run workflow`。

workflow 会检查上游 Mole 正式版本，更新内核并执行兼容性检查。检查通过后会创建临时
`auto-update-mole-*` 分支，并创建目标为 `main/blue-theme` 的 PR。

确认 PR 后合并到 `main/blue-theme`，再删除对应的临时分支。

首次使用前，需要在仓库 `Settings` -> `Actions` -> `General` 的 `Workflow permissions` 中选择
`Read and write permissions`，并勾选 `Allow GitHub Actions to create and approve pull requests`。
否则更新、构建和兼容性检查仍会完成，但最后创建 PR 会失败。

## 命令行触发

需要安装并登录 GitHub CLI：

```bash
gh auth login
```

手动运行 CI：

```bash
gh workflow run CI.yml --ref main/blue-theme
```

手动构建 DMG：

```bash
gh workflow run release.yml --ref main/blue-theme
```

查看运行状态：

```bash
gh run list --branch main/blue-theme
```

## 本地构建对照

GitHub Actions 使用 macOS runner 和完整 Xcode。本地需要安装完整 Xcode，不能只安装
CommandLineTools。

```bash
cd /Users/ifengz/CodingCase/MoleClean/code

xcodebuild \
  -project MoleUI.xcodeproj \
  -scheme MoleUI \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 首次打开提示

如果 macOS 因为下载来源或隔离属性阻止打开已经确认可信的 App，可以移除该 App 的
quarantine 属性：

```bash
xattr -dr com.apple.quarantine "/Applications/Mole Clean.app"
```

只对确认来自本仓库构建流程或可信来源的 `Mole Clean.app` 使用此命令。执行后重新打开 App。
