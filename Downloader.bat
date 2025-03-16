@echo off
setlocal enabledelayedexpansion

:: Define paths
set "batFilesLocal=%LOCALAPPDATA%\Bat-Files"
set "batFilesPrograms=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Bat-Files"
set "desktopFolder=%USERPROFILE%\Desktop"
set "binFolder=%CD%\bin"

:: Step 1: Create "Bat Files" folder in LOCAL if it doesn't exist
if not exist "%batFilesLocal%" (
    mkdir "%batFilesLocal%"
)

:: Step 2: Create "Bat Files" folder in PROGRAMS if it doesn't exist
if not exist "%batFilesPrograms%" (
    mkdir "%batFilesPrograms%"
)

:: Step 3: Look for subfolders in "bin" folder and process each subfolder
if exist "%binFolder%" (
    echo Searching for folders in "%binFolder%"...
    for /d %%A in ("%binFolder%\*") do (
        :: Ensure that the folder contains .bat files and subfolders
        if exist "%%A\*" (
            echo Processing folder "%%A"...
            
            :: Step 4: Copy the entire subfolder (with its contents) to Bat-Files directory, overwriting existing files
            echo Copying contents of "%%A" to "%batFilesLocal%\%%~nA"...
            xcopy "%%A\*" "%batFilesLocal%\%%~nA\" /E /H /K /Y
            if errorlevel 1 (
                echo Error occurred during copy operation. Exiting...
				pause
                exit /b
            )

            :: Step 4.1: Check for an icon.ico in the subfolder and copy it to Bat-Files subfolder
            if exist "%%A\icon.ico" (
                echo Copying icon from "%%A\icon.ico" to "%batFilesLocal%\%%~nA\icon.ico"...
                copy /Y "%%A\icon.ico" "%batFilesLocal%\%%~nA\icon.ico" >nul
                if errorlevel 1 (
                    echo Error occurred during icon copy. Exiting...
					pause
                    exit /b
                )
            )

            :: Step 5: Search for .bat files only inside the subfolder itself (not in subdirectories)
            for %%F in ("%%A\*.bat") do (
                set "filePath=%batFilesLocal%\%%~nA\%%~nxF"
                set "fileName=%%~nF"
                set "startInPath=%batFilesLocal%\%%~nA"

                :: Create shortcut in Start Menu
                if exist "%batFilesLocal%\%%~nA\icon.ico" (
                    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%batFilesPrograms%\!fileName!.lnk'); $s.TargetPath='!filePath!'; $s.IconLocation='%batFilesLocal%\%%~nA\icon.ico'; $s.WorkingDirectory='!startInPath!'; $s.Save()"
                ) else (
                    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%batFilesPrograms%\!fileName!.lnk'); $s.TargetPath='!filePath!'; $s.WorkingDirectory='!startInPath!'; $s.Save()"
                )

                :: Create shortcut on Desktop
                if exist "%batFilesLocal%\%%~nA\icon.ico" (
                    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%desktopFolder%\!fileName!.lnk'); $s.TargetPath='!filePath!'; $s.IconLocation='%batFilesLocal%\%%~nA\icon.ico'; $s.WorkingDirectory='!startInPath!'; $s.Save()"
                ) else (
                    powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%desktopFolder%\!fileName!.lnk'); $s.TargetPath='!filePath!'; $s.WorkingDirectory='!startInPath!'; $s.Save()"
                )
            )
        )
    )
) else (
    echo Bin folder not found. Exiting...
	pause
    exit /b
)
echo.
echo.
echo All shortcuts created successfully.
echo.
pause
exit /b