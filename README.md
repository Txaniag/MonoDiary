# 墨记 MonoDiary

一款 iOS 日记应用。黑白、留白、衬线字体，参考 Emil Kowalski 的设计工程哲学打磨细节。
支持将日记一键生成为优雅的分享卡片图，并带有全局黑白 UI 模式。

## ✨ 功能

- 📖 日记列表：按天分组、搜索、滑动/详情删除
- ✍️ 写 / 编辑日记：标题、正文、心情标签、日期选择
- 🖼️ 日记成图：把一篇日记渲染成 3 种风格的卡片图（留白 / 墨夜 / 信纸），保存相册或分享
- ⚫ 黑白 UI 设置：一键把整个界面还原为纯粹的黑与白
- 🌗 外观设置：浅色 / 深色 / 跟随系统
- 🎨 主题色：朱砂 / 黛蓝 / 松绿（黑白模式下自动隐藏）
- 📱 微交互：按压缩放、轻触震动、列表渐入

## 🛠 技术栈

- SwiftUI + SwiftData（iOS 17+）
- `ImageRenderer` 生成高分辨率日记卡片 PNG
- 无第三方依赖

## 📁 目录结构

```
MonoDiary.xcodeproj            # Xcode 工程（可直接打开）
MonoDiary/
├─ MonoDiaryApp.swift          # App 入口
├─ Models/                     # SwiftData 数据模型、心情枚举
├─ Theme/AppSettings.swift     # 主题色 / 黑白模式 / 外观设置
├─ Views/                      # 首页、编辑、详情、日记成图、设置
└─ Assets.xcassets/            # App 图标、主题色
.github/workflows/build-ipa.yml # GitHub Actions：一键构建 IPA
scripts/
├─ build_ipa.sh                # Mac 本地一键构建 IPA
└─ generate_icon.ps1           # 重新生成 App 图标
```

## 📦 如何获得 IPA

### 方式一：GitHub Actions（Windows 也能拿到 IPA）

1. 把本目录推送到 GitHub 仓库（例如 `git init && git add -A && git commit -m "init" && git push`）。
2. 打开仓库页面 → **Actions** → 左侧选择 **Build IPA** → 点 **Run workflow**。
3. 等待约 3-5 分钟，构建完成后在 workflow 页面底部 **Artifacts** 下载 `MonoDiary-IPA`。
4. 解压得到 `MonoDiary-unsigned.ipa`。

### 方式二：Mac 本地构建

```bash
chmod +x scripts/build_ipa.sh
./scripts/build_ipa.sh
```

产物在 `build/ipa/MonoDiary-unsigned.ipa`。

### 方式三：直接用 Xcode 运行 / 真机调试

用 Xcode 16+ 打开 `MonoDiary.xcodeproj`，选择你的 iPhone，在 Signing & Capabilities 里选择你的 Team 后直接 Run。

## 🔑 安装 / 签名说明

`MonoDiary-unsigned.ipa` 未签名，需要用免费 Apple ID 重新签名后安装。推荐工具：

- **Sideloadly**（Windows / Mac）：拖入 IPA，输入 Apple ID 自动签名安装。
- **AltStore / AltServer**（Windows / Mac）：长期使用更稳定。
- **爱思助手**（Windows）：一键签名安装。
- 越狱设备可直接安装。

签名工具会覆盖应用签名，不影响功能。

## 🎨 设计说明

UI 遵循 [emilkowalski/skills](https://github.com/emilkowalski/skills) 的设计工程理念：

- **动画克制**：列表渐入 200-300ms `ease-out`，按压缩放 0.97，不做高频无意义动画
- **字体**：全局衬线字体（serif），中文自动落到宋体，营造书写与纸张感
- **留白与层次**：卡片圆角 16-20pt、1pt 细描边、柔和低对比阴影
- **反馈**：保存 / 生成图片时触发轻震动
- **黑白模式**：全屏饱和度归零 + 纯黑白色板，切换带 0.35s 过渡

## 🧩 后续可扩展

- iCloud 同步（SwiftData 原生支持）
- 日记导出 PDF / 多图拼接
- 桌面小组件（WidgetKit）
- 生物识别锁
