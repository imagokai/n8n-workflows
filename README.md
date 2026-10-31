# n8n workflows

个人使用的 n8n 工作流，把各个渠道的动态统一聚合发送到 Telegram，并在工作流运行出错时发送告警。

每个渠道对应一个独立的工作流，共用同一套推送和告警配置。新增渠道时，只需要添加一个新的工作流，并补充这个渠道特有的配置。

## 工作流

| 名称 | 文件 | 内容 |
|---|---|---|
| Douban to Telegram | `workflows/douban-to-telegram.json` | 把豆瓣上的观影、阅读、游戏动态推送到 Telegram |
| Error alert | `workflows/error-alert.json` | 其他工作流运行出错时，发送告警到 Telegram |

## 配置

`workflows/` 下的文件是模板，个人相关的值用 `__配置项名称__` 格式的占位符代替，比如 `__WF_DOUBAN_USER_ID__`。`build.sh` 读取 `config.env` 中的配置，把占位符替换为实际值，生成可以直接导入 n8n 的工作流。

配置项见 `config.example.env`：

- `WF_TELEGRAM_FEED_CHAT_ID`：动态推送的目标，公开频道填 `@用户名`，私聊或私有频道填数字 ID
- `WF_TELEGRAM_ALERT_CHAT_ID`：告警的目标，格式同上
- `WF_TELEGRAM_PUSH_CREDENTIAL_ID`：推送 bot 凭证的 ID
- `WF_TELEGRAM_ALERT_CREDENTIAL_ID`：告警 bot 凭证的 ID
- `WF_DOUBAN_USER_ID`：豆瓣用户 ID

## 部署

1) 把 n8n 的 `N8N_EDITOR_BASE_URL` 设为 n8n 的对外访问地址，告警中的执行记录链接依赖这个配置
2) 在 n8n 中创建两个 Telegram 凭证，分别用于推送和告警，使用不同的 bot。打开凭证后，地址栏中的 ID 就是凭证 ID
3) 复制 `config.example.env` 为 `config.env` 并填写
4) 生成工作流到 `build/`，需要先安装 `jq`：

   ```bash
   ./build.sh
   ```

5) 在 n8n 所在的环境中导入 `build/` 下的工作流，然后发布：

   ```bash
   n8n import:workflow --separate --input=build/
   ```

   使用 Docker Compose 部署时，先进入 n8n 的 compose 文件所在目录，再复制和导入：

   ```bash
   cd /path/to/n8n-compose
   docker compose cp /path/to/n8n-workflow/build n8n:/tmp/build
   docker compose exec n8n n8n import:workflow --separate --input=/tmp/build
   docker compose exec -u root n8n rm -rf /tmp/build
   ```

> 命令行导入会保留工作流 ID，各工作流与 Error alert 的关联保持不变。如果在界面中通过 **Import from File** 导入，工作流 ID 会重新生成，需要先导入 Error alert，再到其他工作流的 Settings 中重新选择 Error Workflow。

## 修改和新增工作流

1. 在 n8n 中编辑工作流，取消所有 Pin data，确认 Settings 中的 Error Workflow 为 Error alert，然后从右上角 **⋯** 菜单选择 **Download**，保存到 `workflows/`
2. 把文件中的 Chat ID、豆瓣 ID、凭证 ID 等实际值换回占位符，新的配置项补充到 `config.example.env` 和上方的配置列表
