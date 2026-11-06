@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  停止项目：按端口找到 5173 / 8081 的监听进程并结束
rem ============================================================

for %%P in (5173 8081) do (
  for /f "tokens=5" %%A in ('netstat -ano ^| findstr /r ":%%P " ^| findstr /i "LISTENING"') do (
    echo 停止端口 %%P 的进程 PID=%%A
    taskkill /F /PID %%A >nul 2>nul && echo   已停止 || echo   停止失败（可能已退出）
  )
)

echo.
echo 完成。
timeout /t 5 >nul
