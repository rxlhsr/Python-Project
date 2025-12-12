@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ==============================================================
echo                 Git 本地版本自动控制脚本
echo ==============================================================

:: =========================== 脚本配置 ===========================
set "TARGET_BRANCH=main"
set "AUTHOR_NAME=rxlhsr"
set "COMMIT_MSG= %AUTHOR_NAME% - %date:~3,20% %date:~0,2% %time:~0,8% - 自动更新"
:: =========================== 配置结束 ===========================

:: ===================== 检查是否在Git仓库中 ======================
if not exist .git (
    echo [初始化] 检测到未初始化的Git仓库，正在初始化...
    git init
    echo [初始化] Git仓库初始化完成
    
    :: 切换到main分支
    echo [初始化] 切换到main分支...
    git checkout -b %TARGET_BRANCH%
    echo [初始化] 已切换到main分支

    :: -------- 检查是否存在.gitignore文件 ---------
    if not exist .gitignore (
        echo [配置] 未找到.gitignore文件，正在创建标准配置...
        (echo # 虚拟环境
        echo .venv/
        echo env/
        echo venv/
        echo 
        echo # Python生成文件
        echo __pycache__/
        echo *.py[cod]
        echo *$py.class
        echo *.so
        echo .Python
        echo 
        echo # IDE和编辑器
        echo .vscode/
        echo .idea/
        echo *.suo
        echo *.ntvs*
        echo *.njsproj
        echo *.sln
        echo *.sw?
        echo 
        echo # 操作系统文件
        echo .DS_Store
        echo Thumbs.db
        echo 
        echo # 数据文件
        echo data/raw/
        echo data/process/
        echo 
        echo # 日志文件
        echo *.log
        echo logs/) > .gitignore
        echo [配置] .gitignore文件创建完成，包含常用忽略规则.
    )
) else (
    :: 确保当前在main分支
    echo [检查] 确保当前在%TARGET_BRANCH%分支...
    git checkout %TARGET_BRANCH% 2>nul || git checkout -b %TARGET_BRANCH%
    echo [检查] 已确保在main分支
)

:: ====================== 自动添加所有更改 ========================
echo [操作] 正在添加所有更改到暂存区...
git add .
echo [操作] 更改已添加.

echo [信息] 当前工作区状态：
git status

:: =================== 检查是否有更改需要提交 ======================
git diff --quiet && git diff --cached --quiet
if %errorlevel% equ 0 (
    echo [信息] 没有检测到更改，无需提交
    goto end
)

:: =========================== 执行提交 ===========================
echo [提交] 准备提交更改...
echo [提交] 提交信息: %commit_msg%
git commit -m "%commit_msg%"
echo [提交] 提交操作完成.

echo [结果] 最新提交记录：
git log -1 --oneline

echo.
echo ==============================================================
echo                 ✓ 修改已全部提交到本地仓库 ✓
echo ==============================================================
:end
exit /b 0