@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ============================ 项目配置 ============================
set "GIT_REPO_URL=https://github.com/rxlhsr/Python-Project.git"
set "TARGET_BRANCH=main"
set "REMOTE_TARGET_FOLDER=remote_folder" 
set "AUTHOR_NAME=rxlhsr"
set "COMMIT_MSG=%AUTHOR_NAME% - %date:~0,10% %time:~0,8% - 自动更新"
set "EXCLUDE_FILES=.git .venv git_push.bat"
:: ============================ 配置结束 ============================


:: ============================ 环境检测 ============================
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 未检测到Git环境，请先安装Git并配置到系统环境变量.
    pause
    exit /b 1
)

if not exist .git (
    echo [INFO] 本地未检测到Git仓库，正在初始化...
    git init
    git checkout -b %TARGET_BRANCH%
)

git checkout %TARGET_BRANCH% 2>nul || git checkout -b %TARGET_BRANCH%
echo [INFO] 已在%TARGET_BRANCH%分支

git remote show origin >nul 2>&1
if errorlevel 1 (
    echo [INFO] 添加远程仓库origin...
    git remote add origin "%GIT_REPO_URL%"
) else (
    echo [INFO] 更新远程仓库URL...
    git remote set-url origin "%GIT_REPO_URL%"
)
:: ============================ 环境检测结束 ============================


:: ============================ 核心操作 ============================
echo [INFO] 拉取远程%TARGET_BRANCH%分支最新代码...
git pull origin %TARGET_BRANCH% --allow-unrelated-histories 2>nul || (
    echo [WARNING] 拉取失败（分支为空），继续执行.
)

if not exist "%REMOTE_TARGET_FOLDER%" (
    echo [INFO] 创建本地目标文件夹：%REMOTE_TARGET_FOLDER%
    mkdir "%REMOTE_TARGET_FOLDER%"
)

echo [INFO] 复制文件到本地目标文件夹...
for /r %%i in (*) do (
    set "skip=0"
    for %%e in (%EXCLUDE_FILES%) do (
        if "%%~ni"=="%%e" set "skip=1"
        if "%%~di%%~pi"=="%cd%\%%e\" set "skip=1"
    )
    if !skip! equ 0 (
        set "rel_path=%%~pi"
        set "rel_path=!rel_path:%cd%\=!"
        mkdir "%REMOTE_TARGET_FOLDER%\!rel_path!" 2>nul
        copy "%%i" "%REMOTE_TARGET_FOLDER%\!rel_path!" /y >nul
    )
)

echo [INFO] 暂存文件...
git add "%REMOTE_TARGET_FOLDER%/*"

echo [INFO] 提交文件...
git commit -m "%COMMIT_MSG%" 2>nul || (
    echo [WARNING] 无文件变更，跳过推送.
    pause
    exit /b 0
)

echo [INFO] 推送到远程仓库...
git push -u origin %TARGET_BRANCH% || (
    echo [ERROR] 推送失败！请检查GitHub账号是否登录.
    pause
    exit /b 1
)
:: ============================ 操作结束 ============================


echo.
echo [SUCCESS] 已成功推送到：
echo 仓库：%GIT_REPO_URL%
echo 分支：%TARGET_BRANCH%
echo 远程文件夹：%REMOTE_TARGET_FOLDER%
exit /b 0