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

## 启动后验证（30 秒）

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/
curl -s -X POST http://localhost:8081/api/login -H "Content-Type: application/json" -d "{\"username\":\"probe\",\"password\":\"x\"}"
# 期望：5173 返回 200；接口返回 {"code":1,...}（code=1 说明链路通，只是账号不存在）
```

## 项目结构速查

- `shinchan-login-vue/`：Vue 3.5 + Vite 8 + vue-router。路由 `/login`、`/register`、`/home`（登录后跳转，`App.vue` 共享涂鸦背景与抖动滤镜）。`/api` 由 vite.config.js 代理到 8081。
- `springBootTest/`：Spring Boot 3.4.5 + MyBatis-Plus。统一返回 `Result{code,message,data}`，code=0 成功。接口：`POST /api/login`、`/api/register`；`GET /api/contents`（首页推荐，12 条上限）、`GET /api/contents/search?keyword=`（标题/描述/标签/分类模糊匹配，空关键词=推荐列表）。登录态未持久化（前端用 sessionStorage 记住当前用户，仅前端层面）。
- 根目录 `package-lock.json` 与 `springBootTest/package-lock.json` 是历史误生成的空壳，无害。
