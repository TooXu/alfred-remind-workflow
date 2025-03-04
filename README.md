# Alfred Reminders Workflow

一个简单的 Alfred workflow，用于直接在 macOS 的提醒应用中添加提醒事项。

## 功能

- 通过 Alfred 快速添加提醒事项到 macOS 的提醒应用
- 支持设置提醒的标题、日期和时间
- 支持指定提醒的列表（如提醒、提醒事项等）

## 使用方法

1. 在 Alfred 中输入关键词 `r` 或 `remind`
2. 输入提醒内容，例如：`r 明天下午3点买牛奶`
3. 如需指定清单，使用 `@` 符号后跟清单名称，例如：`r 明天下午3点买牛奶 @立马做`
4. 按回车键确认，提醒将被添加到提醒应用中的指定清单

## 安装

1. 下载最新版本的 workflow 文件
2. 双击下载的文件，Alfred 将自动导入此 workflow

## 开发

该 workflow 使用 AppleScript 与 macOS 的提醒应用进行交互。
