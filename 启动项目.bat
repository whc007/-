@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  启动项目（后端 8081 + 前端 5173）
rem  修订说明：
rem   1) 启动前先释放 5173 / 8081 上的残留进程，避免新窗口因端口占用起不来
rem   2) 前后端各开一个窗口，报错信息留在窗口里
rem   3) 轮询等待两个端口真正可用（最多 90 秒），然后再打开登录页
rem  依赖：Java 21、Node 22、MySQL(3306)、Maven wrapper 缓存
rem ============================================================

set "ROOT=%~dp0"

rem 清掉会覆盖 Spring Boot server.port 的环境变量
set "SERVER__PORT="

echo [1/3] 清理占用 5173 / 8081 的旧进程...
for %%P in (5173 8081) do (
  for /f "tokens=5" %%A in ('netstat -ano ^| findstr /r ":%%P " ^| findstr /i "LISTENING"') do (
    taskkill /F /PID %%A >nul 2>nul
  )
)

echo [2/3] 启动前后端（会新开两个窗口，别关掉它们）...
start "shinchan-backend-8081" cmd /k call "%ROOT%启动后端.bat"
start "shinchan-frontend-5173" cmd /k call "%ROOT%启动前端.bat"

echo [3/3] 等待服务就绪，最多 90 秒（首次启动前端要先装依赖）...
set /a WAITED=0

:WAIT_LOOP
curl -s -m 2 http://localhost:5173/ >nul 2>nul && curl -s -m 2 http://localhost:8081/api/contents >nul 2>nul && goto READY
set /a WAITED+=3
if %WAITED% GEQ 90 goto TIMEOUT
timeout /t 3 >nul
echo    已等待 %WAITED% 秒...
goto WAIT_LOOP

:READY
echo.
echo ---- 就绪 ----
echo    后端 http://localhost:8081   前端 http://localhost:5173
echo    登录页 http://localhost:5173/login
echo    试用账号 demo / 123456（页面底部「一键填入」）
echo    停止项目：停止项目.bat
echo.
start "" "http://localhost:5173/login"
timeout /t 6 >nul
exit /b 0

:TIMEOUT
echo.
echo ---- 超时：有服务没起来 ----
curl -s -m 2 http://localhost:8081/api/contents >nul 2>nul && echo    后端 8081 OK || echo    后端 8081 未就绪，看 backend 窗口的报错
curl -s -m 2 http://localhost:5173/ >nul 2>nul && echo    前端 5173 OK || echo    前端 5173 未就绪，看 frontend 窗口的报错（常见：npm 依赖没装完 / 端口被占）
echo.
echo 仍然可以手动打开：http://localhost:5173/login
pause
exit /b 1
