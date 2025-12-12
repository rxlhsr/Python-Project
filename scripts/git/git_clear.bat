@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo =============================================================
echo                 Git 远程仓库清空脚本
echo =============================================================
echo 警告：此操作将清空远程仓库的所有内容！
echo =============================================================

:: =========================== 项目配置 ===========================
set "GIT_REPO_URL=https://github.com/rxlhsr/Python-Project.git"
set "TARGET_BRANCH=main"
set "AUTHOR_NAME=rxlhsr"
set "COMMIT_MSG= %AUTHOR_NAME% - %date:~3,20% %date:~0,2% %time:~0,8% - 清空仓库"
:: =========================== 配置结束 ===========================

:: =========================== 环境检测 ===========================
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未检测到Git环境，请先安装Git并配置到系统环境变量.
    exit /b 1
)

:: =========================== 确认操作 ===========================
set /p "CONFIRM=确定要清空远程仓库吗？(y/N): "
if /i not "%CONFIRM%"=="y" (
    echo [INFO] 操作已取消.
    exit /b 0
)

:: ================== 创建临时目录并初始化Git仓库 ==================
set "TEMP_DIR=%temp%\git_clear_temp"
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"
cd /d "%TEMP_DIR%"

echo [INFO] 创建临时Git仓库...
git init
git checkout -b %TARGET_BRANCH%

::=========================== 创建空提交===========================
echo [INFO] 创建空提交...
git config user.name "%AUTHOR_NAME%"
git config user.email "%AUTHOR_NAME%@example.com"
git commit --allow-empty -m "%COMMIT_MSG%"

:: =========================== 强制推送===========================
echo [INFO] 强制推送到远程仓库...
git remote add origin "%GIT_REPO_URL%"
git push -f origin %TARGET_BRANCH%
if errorlevel 1 (
    echo [ERROR] 推送失败！请检查.
    echo 1. 仓库是否为私有（需登录GitHub账号）.
    echo 2. 是否有推送权限.
    echo 3. 网络连接是否正常.
    echo 4. 远程仓库URL是否正确.
    cd /d "%~dp0"
    rmdir /s /q "%TEMP_DIR%"
    exit /b 1
)

:: ========================= 清理临时目录 ========================== 
cd /d "%~dp0"
rmdir /s /q "%TEMP_DIR%"

echo.
echo ==============================================================
echo                    ✓ 远程仓库已成功清空 ✓
echo ==============================================================
exit /b 0