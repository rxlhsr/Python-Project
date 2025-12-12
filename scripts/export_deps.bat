@echo off
chcp 65001 > nul
REM 脚本：导出项目依赖.
REM 核心依赖（项目文件中直接引入的包）导出到requirements.txt.
REM 全部依赖导出到.lock.

setlocal enabledelayedexpansion

REM 确保在项目根目录下执行.
cd /d "%~dp0\.."

REM 检查是否有requirements.txt文件，如果有则备份.
if exist "requirements.txt" (
    copy "requirements.txt" "requirements.txt.bak"
    echo 已备份requirements.txt到requirements.txt.bak
)

REM 安装pipreqs工具（用于导出核心依赖）.
pip install pipreqs

REM 使用pipreqs导出核心依赖到requirements.txt.
echo 正在导出核心依赖到requirements.txt...
pipreqs . --encoding=utf-8 --force

if errorlevel 1 (
    echo 核心依赖导出失败.
    exit /b 1
) else (
    echo 核心依赖导出成功.
)

REM 安装pipdeptree工具（用于导出全部依赖树）.
pip install pipdeptree

REM 使用pipdeptree导出全部依赖到.lock文件.
echo 正在导出全部依赖到.lock...
pipdeptree -f > .lock

if errorlevel 1 (
    echo 全部依赖导出失败.
    exit /b 1
) else (
    echo 全部依赖导出成功.
)

echo 依赖导出完成.
echo 核心依赖：requirements.txt
 echo 全部依赖：.lock

endlocal
pause
