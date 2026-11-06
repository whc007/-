@echo off
chcp 936 >nul
setlocal EnableExtensions
rem ============================================================
rem  启动项目（后端 8081 + 前端 5173）
rem  说明：
rem   - 所有路径都相对本脚本所在目录（%~dp0），不硬编码盘符
rem   - node_modules / target 每次开机前会被清空：
rem     前端脚本会自动补装依赖，后端由 Maven 重新编译
rem   - 依赖本机已有：Java、Node、MySQL(3306)、Maven wrapper 缓存
rem ============================================================

set "ROOT=%~dp0"

rem 清掉会覆盖 Spring Boot server.port 的环境变量（本机 SERVER__PORT=63956 被平台占用）
set "SERVER__PORT="

start "shinchan-backend-8081" cmd /k call "%ROOT%启动后端.bat"
start "shinchan-frontend-5173" cmd /k call "%ROOT%启动前端.bat"

echo.
echo 已在新窗口启动：
echo   后端  http://localhost:8081
echo   前端  http://localhost:5173
echo.
echo 停止项目请运行：停止项目.bat
echo.
timeout /t 5 >nul
