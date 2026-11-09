@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  启动前端 Vite 开发服务器（端口 5173）
rem  说明：node_modules 每次开机前会被清空，检测到不存在就先装依赖
rem ============================================================

cd /d "%~dp0shinchan-login-vue"

where node >nul 2>nul
if errorlevel 1 (
  echo [前端] 没找到 node，请先安装 Node.js 18+ 并加入 PATH
  pause
  exit /b 1
)

if not exist "node_modules" (
  echo [前端] node_modules 不存在，安装依赖（有 npm 缓存时很快）...
  call npm ci
  if errorlevel 1 (
    echo [前端] npm ci 失败，改用 npm install
    call npm install
    if errorlevel 1 (
      echo [前端] 依赖安装失败，请检查网络或 npm 源
      pause
      exit /b 1
    )
  )
) else (
  echo [前端] node_modules 已存在，跳过依赖安装
)

echo [前端] 启动 Vite（就绪后会自动打开 http://localhost:5173/）...
call npm run dev

echo.
echo [前端] 进程已退出，上面一行就是退出原因。
pause
