@echo off
REM This script builds a custom node, deploys it to the n8n custom nodes folder,
REM kills any running n8n process (via Docker), and restarts n8n.

REM Exit immediately on error
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM ##############################
REM # Step 0: Get Package Name
REM ##############################

FOR /F "delims=" %%A IN ('node -p "require('./package.json').name"') DO SET PACKAGE_NAME=%%A

IF "%PACKAGE_NAME%"=="" (
    echo Error: Could not determine package name from package.json.
    EXIT /B 1
)

REM Set the target directory based on the package name.
SET TARGET_DIR=C:\Users\Chandresh Olaniya\.n8n\custom\%PACKAGE_NAME%

echo Detected package name: "%PACKAGE_NAME%"
echo Target deployment directory: "%TARGET_DIR%"

REM ##############################
REM # Step 1: Build the Node
REM ##############################
echo Building the node...
call pnpm run build
IF ERRORLEVEL 1 (
    echo Build failed.
    EXIT /B 1
)

REM ##############################
REM # Step 2: Deploy the Build Output
REM ##############################
SET SOURCE_DIR=dist

echo Deploying build output from "%SOURCE_DIR%" to "%TARGET_DIR%"...

REM Remove old deployment directory and recreate it
IF EXIST "%TARGET_DIR%" (
    rmdir /S /Q "%TARGET_DIR%"
)
mkdir "%TARGET_DIR%"

xcopy /E /Y /I "%SOURCE_DIR%\*" "%TARGET_DIR%\"

echo Deployment complete.

REM ##############################
REM # Step 3: Restart n8n
REM ##############################
echo Restarting n8n...
n8n stop
n8n start

#REM Optional: View logs (press Ctrl+C to exit)
#docker logs -f n8n
