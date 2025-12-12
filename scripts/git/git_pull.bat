@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ==============================================================
echo                 Git 远程仓库内容拉取脚本
echo ==============================================================

:: =========================== 项目配置 ===========================
set "GIT_REPO_URL=https://github.com/rxlhsr/Python-Project.git"
set "TARGET_BRANCH=main"
:: =========================== 配置结束 ===========================

:: =========================== 环境检测 ===========================
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未检测到Git环境，请先安装Git并配置到系统环境变量.
    exit /b 1
)

:: ================== 检查Git仓库状态和远程配置 ====================
if not exist .git (
    echo [INFO] 本地未检测到Git仓库，正在初始化并克隆远程仓库...
    git init
    git remote add origin "%GIT_REPO_URL%"
    echo [INFO] 初始化%TARGET_BRANCH%分支...
    git checkout -b %TARGET_BRANCH%
) else (
    git remote show origin >nul 2>&1
    if errorlevel 1 (
        echo [INFO] 远程仓库origin不存在，正在添加...
        git remote add origin "%GIT_REPO_URL%"
    ) else (
        echo [INFO] 远程仓库origin已存在，正在更新URL...
        git remote set-url origin "%GIT_REPO_URL%"
    )
)

:: ====================== 确保当前在目标分支  ======================
echo [INFO] 确保当前在%TARGET_BRANCH%分支...
git checkout %TARGET_BRANCH% 2>nul || git checkout -b %TARGET_BRANCH%
echo [INFO] 已在%TARGET_BRANCH%分支

::  ========================== 拉取操作  ==========================
echo [INFO] 拉取远程%TARGET_BRANCH%分支最新代码...
git pull origin %TARGET_BRANCH% --allow-unrelated-histories
if errorlevel 1 (
    echo [ERROR] 拉取失败！请检查：
    echo 1. 仓库是否为私有（需登录GitHub账号）
    echo 2. 本地是否已拉取最新代码
    echo 3. 网络连接是否正常
    echo 4. 远程仓库URL是否正确
    exit /b 1
)

echo.
echo ==============================================================
echo                    ✓ 已成功从远程仓库拉取最新内容 ✓
echo ==============================================================
exit /b 0