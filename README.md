# n8n workflows

个人使用的 n8n 工作流，把各个渠道的动态统一聚合发送到 Telegram，并在工作流运行出错时发送告警。

每个渠道对应一个独立的工作流，共用同一套推送和告警配置。新增渠道时，添加一个工作流，并补上这个渠道特有的配置。

## 工作流

| 名称 | 文件 | 内容 |
|---|---|---|
| Douban to Telegram | `workflows/douban-to-telegram.json` | 把豆瓣的观影、阅读和游戏记录发到 Telegram |
| YouTube to Telegram | `workflows/youtube-to-telegram.json` | 把 YouTube 播放列表中的新视频发到 Telegram |
| Blog to Telegram | `workflows/blog-to-telegram.json` | 把博客的新文章发到 Telegram |
| Error alert | `workflows/error-alert.json` | 工作流运行出错时，把告警发到 Telegram |

## 配置

`workflows/` 下的文件是模板。个人相关的值写成 `__配置项名称__`，例如 `__WF_DOUBAN_USER_ID__`。`build.sh` 读取 `config.env`，把占位符换成实际值，生成可以直接导入 n8n 的工作流。

配置项见 `config.example.env`。每一项都是「填什么，到哪里看」：

- `WF_TELEGRAM_FEED_CHAT_ID`：动态的发送目标。公开频道填 `@用户名`，私聊或私有频道填数字 ID
- `WF_TELEGRAM_ALERT_CHAT_ID`：告警的发送目标。公开频道填 `@用户名`，私聊或私有频道填数字 ID
- `WF_TELEGRAM_CREDENTIAL_ID`：Telegram 凭证 ID，动态和告警共用。在 n8n 中打开该凭证，地址栏末尾就是 ID
- `WF_DOUBAN_USER_ID`：豆瓣用户 ID。个人主页网址里 `people/` 后面的一段
- `WF_YOUTUBE_PLAYLIST_ID`：YouTube 播放列表 ID。播放列表网址里 `list=` 后面的一段
- `WF_YOUTUBE_CREDENTIAL_ID`：YouTube 凭证 ID。在 n8n 中打开该凭证，地址栏末尾就是 ID
- `WF_BLOG_FEED_URL`：博客的 Atom 或 RSS 地址

## 部署

1. 把 n8n 的 `N8N_EDITOR_BASE_URL` 设为 n8n 的对外访问地址。告警里的执行记录链接用这个地址
2. 在 n8n 中创建 Telegram 凭证和 YouTube 凭证
3. 复制 `config.example.env` 为 `config.env`，按上一节填写
4. 生成工作流到 `build/`。需要先安装 `jq`：

   ```bash
   ./build.sh
   ```

5. n8n 在本机运行时，导入 `build/` 下的工作流，然后发布：

   ```bash
   ./import.sh local
   ```

6. n8n 在 Docker Compose 中运行时，传入 compose 文件所在目录，再导入并发布。容器里的服务名需要是 `n8n`：

   ```bash
   ./import.sh docker /path/to/n8n-compose
   ```

> 命令行导入会保留工作流 ID，各工作流与 Error alert 的关联保持不变。在界面中通过 **Import from File** 导入时，工作流 ID 会重新生成。先导入 Error alert，再在其他工作流的 Settings 里重新选择 Error Workflow。

## 修改和新增工作流

1. 在 n8n 中编辑工作流，取消所有 Pin data，确认 Settings 中的 Error Workflow 为 Error alert。从右上角 **⋯** 菜单选择 **Download**，保存到 `workflows/`
2. 把文件中的实际值换回占位符。新的配置项补进 `config.example.env` 和上方的配置列表
