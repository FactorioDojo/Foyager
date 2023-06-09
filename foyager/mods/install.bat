@echo off
setlocal

REM Set the source and destination paths
set "source_folder_1=agent-actions"
set "destination_folder=%APPDATA%\Factorio\mods"
set "version=0.1.0"
set "mod_name_1=agent-actions"
set "zip_file_1=%mod_name_1%_%version%.zip"
set "temp_folder_1=%mod_name_1%_%version%"

REM Repeat the following steps for each source folder

REM Check if the source folder exists
if not exist "%source_folder_1%" (
    echo Source folder "%source_folder_1%" does not exist.
    exit /b
)

REM Delete the existing zip file if present
if exist "%destination_folder%\%zip_file_1%" (
    del "%destination_folder%\%zip_file_1%"
)

REM Create a temporary directory
mkdir "%temp_folder_1%"

REM Copy all the contents of the source folder to the temporary directory
xcopy /e /i "%source_folder_1%" "%temp_folder_1%"

REM Change to the directory containing the temporary directory
pushd "."

REM Create the zip file
powershell -noprofile -command "Compress-Archive -Path '%temp_folder_1%' -DestinationPath '%zip_file_1%' -Force"

REM Move the zip file to the destination folder
move "%zip_file_1%" "%destination_folder%"

REM Clean up
popd
rmdir /s /q "%temp_folder_1%"

endlocal


