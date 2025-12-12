@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ============== 初始化配置 ==============
set "VENV_DIR=.venv"
set "REQUIREMENTS_FILE=requirements.txt"
set "SUCCESSFUL_PACKAGES="
set "FAILED_PACKAGES="

:: ============== 检查虚拟环境 ==============
:check_venv
if not exist "%VENV_DIR%" (
    echo 警告：虚拟环境目录 "%VENV_DIR%" 不存在！
    echo 自动创建虚拟环境...
    python -m venv "%VENV_DIR%"
    if !errorlevel! equ 0 (
        echo 虚拟环境创建成功！
        echo.
        echo ==============================================
        echo 创建虚拟环境使用的Python版本信息：
        echo ==============================================
        python --version
        echo ==============================================
        echo.
    ) else (
        echo 创建虚拟环境失败！
        exit /b 1
    )
)

if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo 错误：未找到虚拟环境激活脚本！
    exit /b 1
)

:: ============== 激活虚拟环境 ==============
echo ==============================================
echo 正在激活虚拟环境...
echo ==============================================
call "%VENV_DIR%\Scripts\activate.bat" || (
    echo 错误：激活虚拟环境失败！
    exit /b 1
)

echo.
echo ==============================================
echo 虚拟环境中Python版本信息：
echo ==============================================
python --version
echo ==============================================
echo.

:: ============== 更新pip ==============
echo ==============================================
echo 正在更新 pip...
echo ==============================================
python -m pip install --upgrade pip || (
    echo 警告：pip 更新失败，可能影响后续包安装！
)

:: ============== 检查并安装requirements.txt中的包 ==============
echo ==============================================
echo 正在安装依赖包...
echo ==============================================
if exist "!REQUIREMENTS_FILE!" (
    echo.
echo ==============================================
echo 检测到 requirements.txt 文件，开始安装依赖包...
echo ==============================================
    
    echo 正在从 !REQUIREMENTS_FILE! 安装包...
    pip install -r "!REQUIREMENTS_FILE!"
    if !errorlevel! equ 0 (
        echo 成功：所有 requirements.txt 中的包安装完成！
        set "REQUIREMENTS_SUCCESS=true"
    ) else (
        echo 警告：requirements.txt 中的部分包安装失败！
        echo 建议：请检查 requirements.txt 文件格式或网络连接
        set "REQUIREMENTS_SUCCESS=false"
    )
) else (
    echo ==============================================
    echo 未找到 requirements.txt 文件，跳过依赖安装
    echo ==============================================
)

:: ============== 显示虚拟环境详细信息 ==============
echo.
echo ==============================================
echo 虚拟环境详细信息：
echo ==============================================
echo 虚拟环境路径：%CD%\%VENV_DIR%
echo Python解释器路径：%CD%\%VENV_DIR%\Scripts\python.exe
echo 虚拟环境配置文件：%CD%\%VENV_DIR%\pyvenv.cfg
echo ==============================================
echo.

:: ============== 显示已安装的依赖包列表 ==============
echo ==============================================
echo 虚拟环境中已安装的依赖包列表：
echo ==============================================
pip list
echo ==============================================
echo.

:END_INSTALL
echo ==============================================
echo 虚拟环境初始化完成！
echo ==============================================
endlocal