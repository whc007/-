@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  启动前端 Vite 开发服务器（端口 5173）
rem  说明：node_modules 每次开机前会被清空，检测到不存在就先装依赖。
rem  依赖本机 Node 22；/api 已由 vite.config.js 代理到 http://localhost:8081
rem ============================================================

cd /d "%~dp0shinchan-login-vue"

if not exist "node_modules" (
  echo [前端] node_modules 不存在，安装依赖（有 npm 缓存时很快）...
  call npm ci || (
    echo [前端] npm ci 失败，改用 npm install
    call npm install
  )
) else (
  echo [前端] node_modules 已存在，跳过依赖安装
)

call npm run dev

echo.
echo [前端] 进程已退出。
pause
