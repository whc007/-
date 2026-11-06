@echo off
chcp 936 >nul
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================
rem  启动后端 Spring Boot（端口 8081）
rem  要点：
rem   1) 清掉 SERVER__PORT，避免覆盖配置里的 8081（本机该变量=63956 且被占用）
rem   2) 优先用 Maven wrapper 缓存里的 mvn.cmd，没有再退回 mvnw.cmd 自动下载
rem   3) 不依赖 target 目录，Maven 会重新编译
rem   4) 依赖本机 Java 21 与 MySQL(3306, root/123456)，库表会自动创建
rem ============================================================

cd /d "%~dp0springBootTest"

set "SERVER__PORT="

set "MVN_CMD="
for /d %%D in ("%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9-bin\*\apache-maven-3.9.9") do (
  if exist "%%D\bin\mvn.cmd" set "MVN_CMD=%%D\bin\mvn.cmd"
)

if defined MVN_CMD (
  echo [后端] 使用缓存 Maven: !MVN_CMD!
  call "!MVN_CMD!" -B spring-boot:run "-Dspring-boot.run.arguments=--server.port=8081"
) else (
  echo [后端] 未找到缓存 Maven，用 mvnw.cmd 自动下载并启动（首次较慢）
  call mvnw.cmd -B spring-boot:run "-Dspring-boot.run.arguments=--server.port=8081"
)

echo.
echo [后端] 进程已退出。
pause
