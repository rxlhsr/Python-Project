@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ==============================================================
echo                  Git 版本控制自动提交并推送脚本 (V2)
echo ==============================================================

:: =========================== 项目配置 ===========================
set "GIT_REPO_URL=https://github.com/rxlhsr/Python-Project.git"
set "TARGET_BRANCH=main"
set "AUTHOR_NAME=rxlhsr"
set "REPO_FOLDER=project_repo"  :: 仓库专用文件夹名称
set "COMMIT_MSG= %AUTHOR_NAME% - %date:~3,20% %date:~0,2% %time:~0,8% - 自动更新"
:: =========================== 配置结束 ===========================

:: =========================== 环境检测 ===========================
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未检测到Git环境，请先安装Git并配置到系统环境变量.
    exit /b 0
)

:: =================== 检查Git仓库状态和远程配置 ===================
if not exist .git (
    echo [INFO] 本地未检测到Git仓库，正在初始化...
    git init
    echo [INFO] 初始化%TARGET_BRANCH%分支...
    git checkout -b %TARGET_BRANCH%
    
    :: 创建仓库专用文件夹
    echo [INFO] 创建仓库专用文件夹：%REPO_FOLDER%
    mkdir "%REPO_FOLDER%"
    echo [INFO] 仓库专用文件夹创建完成
)

:: ===================== 确保当前在目标分支 ========================
echo [INFO] 确保当前在%TARGET_BRANCH%分支...
git checkout %TARGET_BRANCH% 2>nul || git checkout -b %TARGET_BRANCH%
echo [INFO] 已在%TARGET_BRANCH%分支

:: ===================== 检查并添加远程仓库origin =================
git remote show origin >nul 2>&1
if errorlevel 1 (
    echo [INFO] 远程仓库origin不存在，正在添加...
    git remote add origin "%GIT_REPO_URL%"
) else (
    echo [INFO] 远程仓库origin已存在，正在更新URL...
    git remote set-url origin "%GIT_REPO_URL%"
)

:: ====================== 将项目文件复制到专用文件夹 ========================
echo [操作] 将项目文件复制到仓库专用文件夹...
:: 复制除了.git文件夹和专用文件夹本身以外的所有文件和文件夹
for /d %%i in (*) do (
    if not "%%i" == ".git" if not "%%i" == "%REPO_FOLDER%" (
        echo [复制] %%i 到 %REPO_FOLDER%/%%i
        xcopy /E /I /Y "%%i" "%REPO_FOLDER%/%%i" > nul
    )
)
:: 复制根目录下的文件
for %%i in (*.*) do (
    if not "%%i" == ".git" if not "%%i" == "%REPO_FOLDER%" (
        echo [复制] %%i 到 %REPO_FOLDER%/%%i
        copy /Y "%%i" "%REPO_FOLDER%/%%i" > nul
    )
)
echo [操作] 文件复制完成.

:: ============================ 环境检测结束 ============================

:: ============================ 提交操作 ============================
:: ------------ 拉取远程分支最新代码 ------------
echo [INFO] 拉取远程%TARGET_BRANCH%分支最新代码...
git pull origin %TARGET_BRANCH% --allow-unrelated-histories
if errorlevel 1 (
    echo [WARNING] 拉取最新代码失败（可能分支为空或历史不相关），继续执行推送.
)

:: ------------ 添加所有修改的文件到暂存区 ------------
echo [INFO] 暂存所有修改的文件到Git...
git add .

:: ------------ 检查是否有更改需要提交 ------------
git diff --quiet && git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [WARNING] 没有检测到更改，无需提交和推送.
    exit /b 0
)

:: ------------ 执行提交 ------------
echo [INFO] 提交文件...
git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
    echo [WARNING] 提交失败，跳过推送.
    exit /b 1
)
:: =========================== 提交结束 ===========================

:: =========================== 推送操作 ===========================
echo [INFO] 推送到"%GIT_REPO_URL%"的"%TARGET_BRANCH%"分支...
git push -u origin %TARGET_BRANCH%
if errorlevel 1 (
    echo [ERROR] 推送失败！请检查：.
    echo 1. 仓库是否为私有（需登录GitHub账号）.
    echo 2. 本地是否已拉取最新代码.
    echo 3. 网络连接是否正常.
    echo 4. 远程仓库URL是否正确.
    exit /b 1
)

echo.
echo ==============================================================
echo                    ✓ 修改已成功推送到远程仓库 ✓
echo ==============================================================
exit /b 0