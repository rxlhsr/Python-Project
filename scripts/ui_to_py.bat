@echo off
chcp 65001 > nul
REM 脚本：将指定文件夹下的.ui文件转换为Python .py文件
REM 用法：ui_to_py.bat [文件夹路径]
REM 默认文件夹路径为 resource/ui/

setlocal enabledelayedexpansion

REM 设置默认文件夹路径
set "UI_DIR=resource/ui/"

REM 如果提供了命令行参数，则使用该参数作为文件夹路径
if "%~1" neq "" (
    set "UI_DIR=%~1"
)

REM 检查文件夹是否存在
if not exist "%UI_DIR%" (
    echo 错误：文件夹 "%UI_DIR%" 不存在
    exit /b 1
)

REM 遍历文件夹下的所有.ui文件
for %%f in ("%UI_DIR%\*.ui") do (
    REM 获取文件名（不含扩展名）
    set "FILENAME=%%~nf"
    
    REM 设置输出文件名（添加_ui后缀）
    set "OUTPUT_FILE=%%~dpf!FILENAME!_ui.py"
    
    echo 正在转换：%%f -^> !OUTPUT_FILE!
    
    REM 使用pyuic5转换文件，并设置类名为文件名（首字母大写）
    REM 先将文件名的首字母转换为大写
    set "CLASS_NAME=!FILENAME:~0,1!"
    for %%c in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
        set "CLASS_NAME=!CLASS_NAME:%%c=%%C!"
    )
    set "CLASS_NAME=!CLASS_NAME!!FILENAME:~1!"
    
    REM 执行转换
    pyuic5 --from-imports --output "!OUTPUT_FILE!" --name "!CLASS_NAME!" "%%f"
    
    if errorlevel 1 (
        echo 转换失败：%%f
    ) else (
        echo 转换成功：%%f
    )
)

echo 所有.ui文件转换完成！
endlocal
pause
