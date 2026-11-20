@echo off
chcp 936 >nul
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================
rem  启动项目（后端 8081 + 前端 5173）
rem  优化版（2026-11-18）：
rem   1) 端口清理改为一次 netstat 快照，不再每端口扫两遍
rem   2) 轮询间隔 1 秒（原来 3 秒），服务通常 1-3 秒就绪，能立刻发现
rem   3) 就绪后立即打开登录页，去掉原来结尾硬等的 6 秒
rem  依赖：Java 21、Node 22、MySQL(3306)、Maven wrapper 缓存
rem ============================================================

set "ROOT=%~dp0"
set "FRONT_URL=http://192.168.68.2:5173"
set "BACK_URL=http://192.168.68.2:8081"

rem 清掉会覆盖 Spring Boot server.port 的环境变量
set "SERVER__PORT="

echo [1/3] 清理占用 5173 / 8081 的旧进程...
for /f "tokens=5" %%A in ('netstat -ano ^| findstr /i "LISTENING" ^| findstr /r /c:":5173 " /c:":8081 "') do (
  taskkill /F /PID %%A >nul 2>nul
)

echo [2/3] 启动前后端（会新开两个窗口，别关掉它们）...
start "shinchan-backend-8081" cmd /k call "%ROOT%启动后端.bat"
start "shinchan-frontend-5173" cmd /k call "%ROOT%启动前端.bat"

echo [3/3] 等待服务就绪...
set /a WAITED=0

:WAIT_LOOP
curl -s -m 1 --noproxy "*" -o nul "%FRONT_URL%/" || goto TICK
curl -s -m 1 --noproxy "*" -o nul "%BACK_URL%/api/contents" || goto TICK
goto READY

:TICK
set /a WAITED+=1
if !WAITED! GEQ 90 goto TIMEOUT
set /a TICK_MOD=!WAITED! %% 5
if !TICK_MOD! EQU 0 echo    已等待 !WAITED! 秒...
timeout /t 1 >nul
goto WAIT_LOOP

:READY
echo.
echo ---- 就绪：以下地址局域网内均可访问 ----
echo    前端   %FRONT_URL%
echo    后端   %BACK_URL%
echo    登录页 %FRONT_URL%/login
echo    试用账号 demo / 123456（页面底部「一键填入」）
echo    停止项目：停止项目.bat
echo.
start "" "%FRONT_URL%/login"
exit /b 0

:TIMEOUT
echo.
echo ---- 超时：有服务没起来 ----
curl -s -m 2 --noproxy "*" -o nul "%BACK_URL%/api/contents" && echo    后端 8081 OK || echo    后端 8081 未就绪，看 backend 窗口的报错
curl -s -m 2 --noproxy "*" -o nul "%FRONT_URL%/" && echo    前端 5173 OK || echo    前端 5173 未就绪，看 frontend 窗口的报错（常见：npm 依赖没装完 / 端口被占）
echo.
echo 仍然可以手动打开：%FRONT_URL%/login
pause
exit /b 1
