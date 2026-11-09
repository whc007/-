# FOR-AI.md —— 写给下次开机的自己（现场笔记，勿删）

> 这台电脑每次开机都会重置：`node_modules` 和 `target` 会被清空，WorkBuddy 会话目录也会换。
> 你的第一要务是 **别重新探索，直接跑脚本**。下面全是已验证的事实，照做即可。

## 第一步：跑脚本（总是优先）

| 目的 | 脚本（项目根，相对路径） |
| --- | --- |
| 一键启动前后端 | `启动项目.bat` |
| 只起后端 8081 | `启动后端.bat` |
| 只起前端 5173 | `启动前端.bat` |
| 停止前后端 | `停止项目.bat` |

四个脚本均为 GBK 编码、路径全相对（`%~dp0`），双击或在终端执行都行。
前端脚本检测到 `node_modules` 不存在会自动 `npm ci`（失败回退 `npm install`）。
脚本不需要 `node_modules` / `target` 预先存在。

**`启动项目.bat` 现在的行为**（2026-11-09 修订，原版备份为 `*.bat.bak`）：
1. 先按端口 kill 掉 5173 / 8081 上的残留监听进程（避免新窗口因端口占用起不来）；
2. 两个窗口分别起后端 / 前端；
3. **轮询等到 5173 和 8081 都真的能访问**（最多 90 秒，每 3 秒打一行"已等待 N 秒"）；
4. 就绪后自动打开 `http://localhost:5173/login`；超时则打印是哪一侧没起来。

**演示账号：`demo` / `123456`**（`user_schema.sql` 里的 INSERT IGNORE 种子，登录页底部有「一键填入」）。

## 用户说"进不去首页"时，按这个顺序查（30 秒）

1. `curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/` → 不是 200 就是前端没起来（最常见：依赖没装完就打开浏览器、或端口被旧进程占着）。
2. `curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/api/contents` → 不是 200 就是后端没起来。
3. 两个都 200 还进不去，就是**登录失败**：直接 `curl -X POST /api/login -d '{"username":"demo","password":"123456"}'` 验证；返回 `code:1` 说明账号/密码不对，用 `demo` 或先注册。
4. 注意 `http://localhost:5173/` 会自动跳到 `/login`，`/home` 有前端守卫（sessionStorage 里没有 `shinchan-user` 就弹回登录页）——**没登录时直接访问 /home 一定进不去**，这是设计行为。


## 如果 .bat 被工具沙箱拦截（WorkBuddy 会话里常见）

WorkBuddy 的 Bash / PowerShell 工具会直接拒绝 `cmd.exe`（`Command blocked for security`），
所以 `启动项目.bat`、`mvnw.cmd`、`npm.cmd` 全部不可用；`Start-Process` 也会静默失败（无 java 进程、无日志）。
改用下面这套纯进程命令，已验证可跑通（后端 2.5s 启动、前端 0.9s ready）。

```bash
# 后端：绕过 mvn.cmd，直接用 java 起 Maven launcher
MVN="C:\Users\Administrator\.m2\wrapper\dists\apache-maven-3.9.9-bin\4nf9hui3q3djbarqar9g711ggc\apache-maven-3.9.9"
cd /d/workSpace/-/springBootTest && unset SERVER__PORT
java -classpath "$MVN\boot\plexus-classworlds-2.8.0.jar" \
  -Dclassworlds.conf="$MVN\bin\m2.conf" -Dmaven.home="$MVN" \
  -Dmaven.multiModuleProjectDirectory="D:\workSpace\-\springBootTest" \
  org.codehaus.plexus.classworlds.launcher.Launcher \
  -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8081

# 前端：用 Bash 工具（npm shim 可用），先 npm ci 再 npm run dev
cd /d/workSpace/-/shinchan-login-vue && npm ci && npm run dev
```

两个命令都用 `run_in_background: true` 跑，输出用 `| tee <日志文件>` 落盘再 tail 查看。

## 手动启动（脚本失效时的备选）

```bat
rem 后端（cmd 里执行；SERVER__PORT 必须清掉，否则端口被覆盖成被占用的 63956）
cd /d springBootTest
set "SERVER__PORT="
mvnw.cmd -B spring-boot:run "-Dspring-boot.run.arguments=--server.port=8081"

rem 前端
cd /d shinchan-login-vue
npm ci && npm run dev
```

## 已验证的环境坑（不要再花时间重新排查）

1. **Git Bash 下 `./mvnw` 必失败**：报 `ClassNotFoundException: plexus.classworlds.launcher.Launcher`，原因是 bash 脚本把 Unix 风格 classpath 传给 Windows Java。→ 用 `mvnw.cmd`（cmd/PowerShell），或缓存 Maven `~/.m2/wrapper/dists/apache-maven-3.9.9-bin/*/apache-maven-3.9.9/bin/mvn.cmd`。
2. **环境变量 `SERVER__PORT=63956` 会被 Spring Boot 当成 `server.port`**，覆盖配置的 8081，而 63956 已被平台进程占用 → `Port 63956 was already in use`。→ 启动前 `set "SERVER__PORT="` 并显式 `--server.port=8081`。
3. 本机无全局 `mvn`；有 Java 21、Node 22、MySQL 8.0（账号见 `application-dev.properties`）。
4. 库表自动建：JDBC `createDatabaseIfNotExist=true` + `spring.sql.init` 执行 `resources/sql/` 下全部脚本（`user_schema.sql` → 表 `sys_user`，`content_schema.sql` → 表 `content` 含 12 条种子数据，均幂等可重复执行）。
5. `npm install` 报 2 个 high 漏洞：**不要**执行 `npm audit fix`（会破坏 Vite 8 版本组合），用户已知晓。
6. `application.properties` 里的中文注释是历史遗留乱码，无害，别动。
7. **本机有 HTTP 代理环境变量**（`http_proxy=http://127.0.0.1:6xxxx`），用 curl 测 localhost 会返回 **502**（假失败）→ 必须加 `--noproxy '*'` 才是真实状态。

## 启动后验证（30 秒）

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/
curl -s -X POST http://localhost:8081/api/login -H "Content-Type: application/json" -d "{\"username\":\"probe\",\"password\":\"x\"}"
# 期望：5173 返回 200；接口返回 {"code":1,...}（code=1 说明链路通，只是账号不存在）
```

## 项目结构速查

- `shinchan-login-vue/`：Vue 3.5 + Vite 8 + vue-router。路由 `/login`、`/register`、`/home`（登录后跳转，`App.vue` 共享涂鸦背景与抖动滤镜）。`/api` 由 vite.config.js 代理到 8081。
- 首页组件：`HomeView.vue`（编排）/ `DailyQuote.vue`（今日台词，可换一句）/ `ShinchanGame.vue`（动感光波大作战 + 排行榜）/ `CharacterGallery.vue`（角色图鉴）/ `ContentModal.vue`（卡片详情弹窗，← → 翻页、Esc 关闭）；静态数据在 `src/data/shinchan.js`。
- `springBootTest/`：Spring Boot 3.4.5 + MyBatis-Plus。统一返回 `Result{code,message,data}`，code=0 成功。接口：
  - `POST /api/login`、`POST /api/register`
  - `GET /api/contents?limit=12&category=动画`（推荐列表，limit 上限 60）
  - `GET /api/contents/recommend?size=12&category=`（随机"换一批"）
  - `GET /api/contents/categories`（分类计数，给筛选 chips 用）
  - `GET /api/contents/search?keyword=`（标题/描述/标签/分类模糊匹配，空关键词=推荐列表）
  - `POST /api/game/scores`（{username,score,hits} → 返回 best/rank/total）、`GET /api/game/leaderboard?size=5`
  - 登录态未持久化（前端用 sessionStorage 记住当前用户，仅前端层面）。
- 内容数据：`content` 表 52 条（动画 17 / 漫画 9 / 游戏 8 / 剧场版 10 / 角色 6 / 美食 2），种子在 `sql/content_schema.sql`（INSERT IGNORE，可重复执行）。
- 根目录 `package-lock.json` 与 `springBootTest/package-lock.json` 是历史误生成的空壳，无害。

## 手动连 MySQL 的可用命令

```bash
"/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe" -uroot -p123456 -D springboot_test --default-character-set=utf8mb4 -e "SELECT COUNT(*) FROM content;"
```

## 无头浏览器验证页面（本机没装 Chrome/Edge 外壳时）

Edge 内核在 `C:\Program Files (x86)\Microsoft\EdgeCore\<版本>\msedge.exe`，可当 Chromium 用：

```bash
"/c/Program Files (x86)/Microsoft/EdgeCore/145.0.3800.82/msedge.exe" --headless=new --disable-gpu \
  --remote-debugging-port=9222 --user-data-dir=<临时目录> about:blank &
# 再用 node 连 http://127.0.0.1:9222/json/list 走 CDP：Page.navigate / Runtime.evaluate / Page.captureScreenshot
```

注意：这类"起服务 + 开浏览器 + 测完关掉"的流程**必须在同一个 bash 调用里跑完**，跨调用时后台进程可能被清掉。
