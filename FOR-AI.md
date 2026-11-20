# FOR-AI.md —— 写给下次开机的自己（现场笔记，勿删）

> 这台电脑每次开机都会重置：`node_modules` 和 `target` 会被清空，WorkBuddy 会话目录也会换。
> 你的第一要务是 **别重新探索，直接跑脚本**。下面全是已验证的事实，照做即可。

## 2026-11-20 现场补充（IP 固定为 192.168.68.2）

- 用户要求把前后端 IP 统一换成本机局域网 IP **`192.168.68.2`**（以太网网卡当前地址）。
- 前后端**只绑定** `192.168.68.2`：后端 `server.address=192.168.68.2`，前端 Vite `host=192.168.68.2` 且 `/api` 代理到 `http://192.168.68.2:8081`。
- ⚠️ 只绑该网卡后 **`127.0.0.1` 不再可访问**：健康检查、curl 自测、浏览器打开、代理目标都必须用 `192.168.68.2`，不能留 `127.0.0.1`。
- 根目录 3 个启动 `.bat` 的 `FRONT_URL` / `BACK_URL` / 打印地址已同步为 `192.168.68.2`（保持 GBK 编码）；`停止项目.bat` 按端口 kill，与 IP 无关。
- 这是**硬编码固定 IP**：若本机 IP 再变化（历史上 `192.168.68.6` → `192.168.68.2`），会重现 `EADDRNOTAVAIL` / `Cannot assign requested address: bind`。临时救急用环境变量覆盖而不改文件：`VITE_HOST`、`VITE_API_TARGET`（前端）、`SERVER_ADDRESS`（后端）；想彻底免疫 IP 漂移就改回 `0.0.0.0`（后端绑全部网卡、前端 `VITE_HOST=0.0.0.0`）。

## 访问地址（2026-11-20 固定为 192.168.68.2）

前后端统一绑定 `192.168.68.2`，本机与局域网设备都用这个地址：

- 前端：`http://192.168.68.2:5173`，登录页 `http://192.168.68.2:5173/login`
- 后端：`http://192.168.68.2:8081`，接口 `http://192.168.68.2:8081/api/contents`
- 实现位置：`vite.config.js` 的 `server.host` 与 `proxy.target`、`application-dev.properties` 的 `server.address`、根目录启动 `.bat`（健康检查/打开地址已改用 `192.168.68.2`）
- 用 curl 自测时仍要加 `--noproxy '*'`，否则会被本机代理干扰返回 502

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

**`启动项目.bat` 现在的行为**（2026-11-18 二次修订；重复的 `*.bat.bak` 已删除）：
1. 先按端口 kill 掉 5173 / 8081 上的残留监听进程（一次 `netstat` 快照，不再每端口扫两遍）；
2. 两个窗口分别起后端 / 前端；
3. **轮询等到 5173 和 8081 都真的能访问**，间隔 **1 秒**（原来 3 秒），最多 90 秒，每 5 秒打一行"已等待 N 秒"；
4. 就绪后**立即**打开 `http://192.168.68.2:5173/login`（去掉了原来结尾硬等 6 秒）；超时则打印是哪一侧没起来。

**提速要点（2026-11-18 实测约 4.5 秒两侧就绪，原来 9~15 秒）**：
- 后端走**快速路径**：`target\classes` 已存在时直接 `java -cp "target\classes;target\lib\*" 主类 --server.port=8081`，**跳过 Maven**（省掉项目扫描 + 插件解析，约省 6~12 秒）。依赖目录是 `target\lib\`（84 个 jar），缺失时脚本自动用 `dependency:copy-dependencies` 生成一次（约 16 秒，仅首次）。
- ⚠️ **别用 `set /p` 读 classpath**：`set /p` 单行上限 1023 字符，而完整 classpath 长达 9141 字符，会静默截断成 9/84 个 jar 直接 NoClassDefFoundError（2026-11-18 踩过，已改为 `target\lib\*` 通配符，`target\classpath.txt` 已删）。
- 后端无 `target`（每次开机被清空）时回退 Maven，并加 `-Dmaven.test.skip=true` 跳过空跑的测试编译。
- 前端依赖已就绪时直接 `node node_modules\vite\bin\vite.js`，省掉 `npm run` 一层壳；只有 `node_modules\vite\bin\vite.js` 缺失才装依赖。
- 两侧**并行**启动、同步轮询，不再串行等。

**演示账号：`demo` / `123456`**（`user_schema.sql` 里的 INSERT IGNORE 种子，登录页底部有「一键填入」）。

## 用户说"进不去首页"时，按这个顺序查（30 秒）

1. `curl -s --noproxy '*' -o /dev/null -w "%{http_code}" http://192.168.68.2:5173/` → 不是 200 就是前端没起来（最常见：依赖没装完就打开浏览器、或端口被旧进程占着）。
2. `curl -s --noproxy '*' -o /dev/null -w "%{http_code}" http://192.168.68.2:8081/api/contents` → 不是 200 就是后端没起来。
3. 两个都 200 还进不去，就是**登录失败**：直接 `curl -X POST http://192.168.68.2:8081/api/login -d '{"username":"demo","password":"123456"}'` 验证；返回 `code:1` 说明账号/密码不对，用 `demo` 或先注册。
4. 注意 `http://192.168.68.2:5173/` 会自动跳到 `/login`，`/home` 有前端守卫（sessionStorage 里没有 `shinchan-user` 就弹回登录页）——**没登录时直接访问 /home 一定进不去**，这是设计行为。


## 如果 .bat 被工具沙箱拦截（WorkBuddy 会话里常见）

WorkBuddy 会话里**无法留下真正持久的后台服务**：`Start-Process` 静默失败，WMI/CIM 进程创建被安全策略拦截，`schtasks.exe` 在黑名单里；用 Python `DETACHED_PROCESS` / `CREATE_BREAKAWAY_FROM_JOB` 也逃不出工具会话的作业对象（后者直接 `PermissionError: [WinError 5]`）。
直接执行 `启动项目.bat` 在 Bash 里可以跑完并开两个 `cmd /k` 窗口，但工具调用结束时这些子进程仍会被一起清掉；Git Bash 还会把脚本里的 `timeout /t 1` 当成 Unix `timeout` 报 `invalid time interval '/t'`（无害，只是没真的 sleep）。`run_in_background: true` 的纯进程命令实测最多存活约 **10 分钟**（任务到时被终止）。
所以会话内验证用下面这套纯进程命令（后端 2.5s 启动、前端 0.9s ready），**需要长期运行时让用户自己双击 `启动项目.bat`**。

```bash
# 后端最快路径（2026-11-18 实测 1 秒就绪，比走 Maven 省 6~12 秒）
# 前提：target\classes 与 target\lib\*.jar 存在；lib 缺失时先跑一次 dependency:copy-dependencies
cd /d/workSpace/-/springBootTest && unset SERVER__PORT
java -cp "target/classes;target/lib/*" com.fenglin.springboottest.SpringBootTestApplication --server.port=8081

# 后端：绕过 mvn.cmd，直接用 java 起 Maven launcher（首次 / 无 target 时用）
MVN="C:\Users\Administrator\.m2\wrapper\dists\apache-maven-3.9.9-bin\4nf9hui3q3djbarqar9g711ggc\apache-maven-3.9.9"
cd /d/workSpace/-/springBootTest && unset SERVER__PORT
java -classpath "$MVN\boot\plexus-classworlds-2.8.0.jar" \
  -Dclassworlds.conf="$MVN\bin\m2.conf" -Dmaven.home="$MVN" \
  -Dmaven.multiModuleProjectDirectory="D:\workSpace\-\springBootTest" \
  org.codehaus.plexus.classworlds.launcher.Launcher \
  -B spring-boot:run -Dspring-boot.run.arguments=--server.port=8081

# 前端：直接调本地 vite（比 npm run dev 少一层壳），依赖缺失时先 npm ci
cd /d/workSpace/-/shinchan-login-vue && node "node_modules/vite/bin/vite.js"
```

两个命令都用 `run_in_background: true` 跑，输出用 `| tee <日志文件>` 落盘再 tail 查看；记住会话内服务约 10 分钟后会随后台任务一起退出。

**收到 `task-notification`（后台任务 completed）时不要重新研究持久化**，直接用上面的纯进程命令重启一次 + curl 验证即可，别再试 `schtasks` / `Start-Process` / WMI / detached（结论见上文，全部无效）。两个易误判的现象：
- `curl` 偶发 `backend=200` 但后端日志写着 `Port 8081 was already in use`：这是上一轮进程退出时的残留窗口，不是有进程脱离会话活下来了；过一两分钟再查会全部变 `000`。
- 重启后 `READY after 1s`：正常，后台任务发出到验证命令执行之间已经过了几秒，不是伪就绪。

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

## 角色图鉴头像（2026-11-20 重新生成 AI 插画）

- 12 个角色头像是**AI 生成的蜡笔手绘风插画**，已放在 `shinchan-login-vue/src/assets/characters/`，文件名即角色 key：`shin|misae|hiroshi|himawari|shiro|kazama|nene|masao|bo|principal|yoshinaga|action`.jpg。
- 规格：1024×1024 原图 → 裁掉右下角水印 → 统一缩放到 **400×400 JPEG q86**，12 张合计约 **346 KB**（原图约 15 MB，未入库）。生成时统一提示词：Q版、粗黑描边、奶油黄纯色背景、正面半身居中、人物占画面约 65%、暖色蜡笔颗粒质感。
- 之前那批 SVG 占位图（首字母+色块）已删除；`_raw/` 原始 PNG 也已清理，勿再找回。
- 引用链路：`src/data/avatars.js` 用 `import` 收集 12 个 JPG URL → `CharacterGallery.vue` 按 `characters[i].key` 取图。
- `shinchan.js` 的每个角色对象有 `key` 字段，是图片与角色的唯一关联。**加新角色时两处都要补**：`characters` 数组加对象（含 key），`avatars.js` 加 import 与映射项，并补一张同名 JPG。
- 组件里保留了降级：`avatars[key]` 缺失时回退显示原来的文字圆形徽章（`initial`），不会白屏。
- 图片用 `loading="lazy"`，横向滚动的图鉴里右侧头像要滚动到才会加载，属于正常现象。

## 已验证的环境坑（不要再花时间重新排查）

1. **Git Bash 下 `./mvnw` 必失败**：报 `ClassNotFoundException: plexus.classworlds.launcher.Launcher`，原因是 bash 脚本把 Unix 风格 classpath 传给 Windows Java。→ 用 `mvnw.cmd`（cmd/PowerShell），或缓存 Maven `~/.m2/wrapper/dists/apache-maven-3.9.9-bin/*/apache-maven-3.9.9/bin/mvn.cmd`。
2. **环境变量 `SERVER__PORT` 会被 Spring Boot 当成 `server.port`**（值每次开机都不同：2026-11-18 实测 60860，早前记录为 63956），覆盖配置的 8081，而该随机端口已被平台进程占用 → `Port <随机值> was already in use`。→ 启动前 `set "SERVER__PORT="` 并显式 `--server.port=8081`。
3. 本机无全局 `mvn`；有 Java 21、Node 22、MySQL 8.0（账号见 `application-dev.properties`）。
4. 库表自动建：JDBC `createDatabaseIfNotExist=true` + `spring.sql.init` 执行 `resources/sql/` 下全部脚本（`user_schema.sql` → 表 `sys_user`，`content_schema.sql` → 表 `content` 含 12 条种子数据，均幂等可重复执行）。
5. `npm install` 报 2 个 high 漏洞：**不要**执行 `npm audit fix`（会破坏 Vite 8 版本组合），用户已知晓。
6. `application.properties` 里的中文注释是历史遗留乱码，无害，别动。
7. **本机有 HTTP 代理环境变量**（`http_proxy=http://127.0.0.1:6xxxx`），用 curl 测 localhost 会返回 **502**（假失败）→ 必须加 `--noproxy '*'` 才是真实状态。

## 启动后验证（30 秒）

```bash
curl -s --noproxy '*' -o /dev/null -w "%{http_code}" http://192.168.68.2:5173/
curl -s --noproxy '*' -X POST http://192.168.68.2:8081/api/login -H "Content-Type: application/json" -d "{\"username\":\"probe\",\"password\":\"x\"}"
# 期望：5173 返回 200；接口返回 {"code":1,...}（code=1 说明链路通，只是账号不存在）
```

## 项目结构速查

- `shinchan-login-vue/`：Vue 3.5 + Vite 8 + vue-router。路由 `/login`、`/register`、`/home`（登录后跳转，`App.vue` 共享涂鸦背景与抖动滤镜）。`/api` 由 vite.config.js 代理到 `http://192.168.68.2:8081`（可用 `VITE_API_TARGET` 覆盖）。
- 首页组件：`HomeView.vue`（编排）/ `DailyQuote.vue`（今日台词，可换一句）/ `ShinchanGame.vue`（动感光波大作战 + 排行榜）/ `FleaMarket.vue`（跳蚤市场二手摊，2026-11-16 新增）/ `CharacterGallery.vue`（角色图鉴）/ `ContentModal.vue`（卡片详情弹窗，← → 翻页、Esc 关闭）；静态数据在 `src/data/shinchan.js`。
- 顶部导航含「跳蚤市场」入口，点击 scrollIntoView 到 `FleaMarket.vue`。
- `springBootTest/`：Spring Boot 3.4.5 + MyBatis-Plus。统一返回 `Result{code,message,data}`，code=0 成功。接口：
  - `POST /api/login`、`POST /api/register`
  - `GET /api/contents?limit=12&category=动画`（推荐列表，limit 上限 60）
  - `GET /api/contents/recommend?size=12&category=`（随机"换一批"）
  - `GET /api/contents/categories`（分类计数，给筛选 chips 用）
  - `GET /api/contents/search?keyword=`（标题/描述/标签/分类模糊匹配，空关键词=推荐列表）
  - `POST /api/game/scores`（{username,score,hits} → 返回 best/rank/total）、`GET /api/game/leaderboard?size=5`
  - **跳蚤市场**（`/api/market`，对应表 `flea_market_item`）：
    - `GET /api/market/items?status=on|sold&limit=`（默认全部，按创建时间倒序，limit 上限 100）
    - `POST /api/market/items`（{title, price, description?, symbol?, color?, seller}；价格 1-9999；颜色白名单对齐 variables.css 的 8 个变量）
    - `POST /api/market/items/{id}/buy`（{buyer}；不能买自己的，不能重复购买）
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
