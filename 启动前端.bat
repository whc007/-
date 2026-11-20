@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  启动前端 Vite 开发服务器（端口 5173）
rem  优化版（2026-11-18）：
rem   1) 检测到依赖已就绪时，直接 node 调本地 vite，省掉 npm 一层壳
rem   2) node_modules 被清空时才装依赖（npm ci 失败回退 npm install）
rem ============================================================

cd /d "%~dp0shinchan-login-vue"

where node >nul 2>nul
if errorlevel 1 (
  echo [前端] 没找到 node，请先安装 Node.js 18+ 并加入 PATH
  pause
  exit /b 1
)

if not exist "node_modules\vite\bin\vite.js" (
  echo [前端] 依赖缺失，安装中（有 npm 缓存时很快）...
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
)

echo.
echo ============================================
echo  前端访问地址（局域网内其他设备可直接用）
echo    首页 http://192.168.68.2:5173
echo    登录 http://192.168.68.2:5173/login
echo ============================================
echo.
echo [前端] 启动 Vite...
node "node_modules\vite\bin\vite.js"

echo.
echo [前端] 进程已退出，上面一行就是退出原因。
pause
