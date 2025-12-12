@echo off
setlocal enabledelayedexpansion

rem 设置控制台输出为UTF-8以支持中文.
chcp 65001 >nul 2>&1

rem 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
if "!SCRIPT_DIR:~-1!"=="\" set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
rem 定义虚拟环境和UI文件夹路径.
set "VENV_DIR=!SCRIPT_DIR!\.venv"
set "UI_DIR=!SCRIPT_DIR!\app\components\ui"
set "OUTPUT_DIR=!SCRIPT_DIR!\app\components"
set "VENV_ACTIVATE=!VENV_DIR!\Scripts\activate"

echo %SCRIPT_DIR%
rem 检查虚拟环境是否存在.
if not exist "!VENV_ACTIVATE!" (
    echo 错误：虚拟环境不存在于 !VENV_DIR!
    echo 请先创建并激活虚拟环境，然后安装PySide6.   
    exit /b 1
)

rem 检查UI文件夹是否存在.
if not exist "!UI_DIR!" (
    echo 错误：UI文件夹不存在于 !UI_DIR!
    pause
    exit /b 1
)

echo 正在激活虚拟环境...
call "!VENV_ACTIVATE!"

if errorlevel 1 (
    echo 错误：无法激活虚拟环境.
    exit /b 1
)

echo 进入UI文件夹...
cd /d "!UI_DIR!"

rem 检查是否有.ui文件.
set "FOUND_UI_FILES=false"
for %%F in (*.ui) do (
    set "FOUND_UI_FILES=true"
    goto :found_ui
)
:found_ui

if "!FOUND_UI_FILES!"=="false" (
    echo 警告：在 !UI_DIR! 中未找到.ui文件.
    exit /b 0
)

echo 开始转换UI文件...
echo.

rem 转换每个.ui文件为同名.py文件.
for %%F in (*.ui) do (
    set "UI_FILE=%%F"
    set "PY_FILE=ui_%%~nF.py"
    set "OUTPUT_FILE=!OUTPUT_DIR!\!PY_FILE!"
    
    echo 转换 !UI_FILE! 到 !OUTPUT_FILE!
    pyside6-uic -g python "!UI_FILE!" -o "!OUTPUT_FILE!"
    
    if errorlevel 1 (
        echo 错误：转换 !UI_FILE! 失败.
    ) else (
        echo 成功：!UI_FILE! 转换为 !OUTPUT_FILE!.
    )
    echo.
)

echo 开始处理资源文件...
echo.

rem 定义资源文件路径.
set "RESOURCES_DIR=!SCRIPT_DIR!\app\resources"
set "RESOURCES_QRC=!RESOURCES_DIR!\resources.qrc"
set "RESOURCES_PY=!RESOURCES_DIR!\resources_rc.py"

rem 检查资源文件是否存在.
if exist "!RESOURCES_QRC!" (
    echo 转换 !RESOURCES_QRC! 到 !RESOURCES_PY!
    pyside6-rcc -g python "!RESOURCES_QRC!" -o "!RESOURCES_PY!"
    
    if errorlevel 1 (
        echo 错误：转换资源文件失败.
    ) else (
        echo 成功：资源文件转换完成.
    )
) else (
    echo 警告：资源文件 !RESOURCES_QRC! 不存在.
)

echo.
echo 所有UI文件和资源文件处理完成.
exit /b 0
