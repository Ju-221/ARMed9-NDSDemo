@echo off
REM ==========================================================
REM Buildscript — builds sandbox.s into buildNDS/program.NDS
REM No emulator launch. Includes full path validation.
REM ==========================================================

setlocal enabledelayedexpansion

set "BuildFile=sandbox.s"
set "VASM_EXE=Utils\Vasm\vasmarm_std_win32.exe"
set "OutDir=buildNDS"
set "OutFile=%OutDir%\program.NDS"
set "ListingFile=%OutDir%\Listing.txt"

echo --------------------------------------------
echo NDS Build Script
echo --------------------------------------------

REM === Validate vasm executable ===
if not exist "%VASM_EXE%" (
    echo [ERROR] Missing vasm executable:
    echo         "%VASM_EXE%"
    echo Make sure it exists relative to this script.
    exit /b 1
)

REM === Validate source file ===
if not exist "%BuildFile%" (
    echo [ERROR] Source file not found:
    echo         "%BuildFile%"
    exit /b 1
)

REM === Create output folder if missing ===
if not exist "%OutDir%" (
    echo Creating output folder "%OutDir%"...
    mkdir "%OutDir%"
)

REM === Perform build ===
echo Building "%BuildFile%" ...
"%VASM_EXE%" "%BuildFile%" -m7tdmi -noialign -chklabels -nocase -Dvasm=1 ^
    -L "%ListingFile%" -DBuildNDS=1 -Fbin -o "%OutFile%"

if errorlevel 1 (
    echo [ERROR] Build failed!
    exit /b 1
)

echo [SUCCESS] Build completed successfully!
echo Output file: "%OutFile%"

endlocal
exit /b 0
