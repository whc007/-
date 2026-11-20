@echo off
chcp 936 >nul
setlocal EnableExtensions EnableDelayedExpansion
rem ============================================================
rem  启动后端 Spring Boot（端口 8081）
rem  修复版（2026-11-18）：
rem   1) 快速路径改用 target\lib\*.jar 通配符 classpath。
rem      原来用 set /p 读 target\classpath.txt，但 set /p 单行
rem      最多 1023 字符，classpath 长达 9141 字符，只读进
rem      9/84 个 jar，导致 NoClassDefFoundError。通配符无长度限制。
rem   2) target\lib 缺失时自动用 dependency:copy-dependencies 生成（仅一次）
rem   3) 无编译产物（每次开机 target 被清空）时回退 Maven，
rem      加 -Dmaven.test.skip=true 跳过测试编译
rem   4) 清掉 SERVER__PORT，避免覆盖配置里的 8081
rem ============================================================

cd /d "%~dp0springBootTest"

set "SERVER__PORT="

echo.
echo ============================================
echo  后端访问地址（局域网内其他设备可直接用）
echo    地址 http://192.168.68.2:8081
echo    接口 http://192.168.68.2:8081/api/contents
echo ============================================
echo.

set "MAIN_CLASS=com.fenglin.springboottest.SpringBootTestApplication"
set "CLASS_FILE=target\classes\com\fenglin\springboottest\SpringBootTestApplication.class"

set "MVN_CMD="
for /d %%D in ("%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9-bin\*\apache-maven-3.9.9") do (
  if exist "%%D\bin\mvn.cmd" set "MVN_CMD=%%D\bin\mvn.cmd"
)

rem ---------- 快速路径 ----------
if exist "!CLASS_FILE!" (
  if not exist "target\lib\*.jar" (
    echo [后端] 首次生成依赖目录 target\lib（仅一次）...
    if defined MVN_CMD (
      call "!MVN_CMD!" -B -q dependency:copy-dependencies "-DoutputDirectory=target\lib"
    )
  )
  if exist "target\lib\*.jar" (
    echo [后端] 快速启动：直接运行已编译产物...
    java -cp "target\classes;target\lib\*" !MAIN_CLASS! --server.port=8081
    goto :DONE
  )
)

rem ---------- 回退：Maven ----------
echo [后端] 无编译产物，走 Maven 启动（首次较慢，之后会走快速路径）...
if defined MVN_CMD (
  echo [后端] 使用缓存 Maven: !MVN_CMD!
  call "!MVN_CMD!" -B -Dmaven.test.skip=true spring-boot:run "-Dspring-boot.run.arguments=--server.port=8081"
) else (
  echo [后端] 未找到缓存 Maven，用 mvnw.cmd 自动下载并启动
  call mvnw.cmd -B -Dmaven.test.skip=true spring-boot:run "-Dspring-boot.run.arguments=--server.port=8081"
)

:DONE
echo.
echo [后端] 进程已退出。
pause
