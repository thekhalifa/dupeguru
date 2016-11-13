@echo off
REM =======================================================
REM ============== dupeGuru Build Script ==================
REM =======================================================

REM Variables used throughout the script
SET PYTHONCMD=python
SET PYTHONVENV=env
SET NSISPATH="C:\Program Files (x86)\NSIS"

REM Check what we're supposed to do or exit
if "%1" == "bootstrap" goto bootstrapsection
if "%1" == "build" goto buildsection
if "%1" == "clean" goto cleansection
if "%1" == "package" goto packagesection
echo Expecting one of these: bootstrap ^| build ^| clean ^| package
goto end

:bootstrapsection
REM BEGIN Bootstrap section

if not exist ".git" goto skipsubs
REM check that we have git in the path
@call git --version
if errorlevel 1 (
   echo GIT was not found on the path, make sure to initialise and update submodules or the build will fail
   goto skipsubs
)
call git submodule init
call git submodule update
:skipsubs

if exist %PYTHONVENV% goto venvavailable
echo No virtualenv. Creating one
%PYTHONCMD% -m venv %PYTHONVENV%
if errorlevel 1 (
   echo Creation of our virtualenv failed. Failure Reason Given is %errorlevel%
   exit /b %errorlevel%
)
:venvavailable

echo Activating virtual environment
call %PYTHONVENV%\Scripts\activate.bat

echo Installing pip requirements
%PYTHONVENV%\Scripts\pip.exe install -r requirements-win.txt
REM PyQt5 should be installed through requirements-win, but kept the check for it
REM May decide to expand these checks to other libs
echo Checking for PyQt5
%PYTHONVENV%\Scripts\python.exe -c "import PyQt5"
if errorlevel 1 (
   echo PyQt 5.4+ required. Install it and try again. Aborting
   exit /b %errorlevel%
)

echo Deactivating virtual environment
call %PYTHONVENV%\Scripts\deactivate.bat

echo Bootstrapping complete! You can now build dupeGuru using this script
echo     ^> winmake build
goto end
REM END Bootstrap section

:buildsection
REM BEGIN Build section

if exist %PYTHONVENV% goto venvavailable
echo No virtualenv, you should run this script with bootstrap parameter first
exit /b %errorlevel%

:venvavailable

echo Activating virtual environment
call %PYTHONVENV%\Scripts\activate.bat

echo Running build script
%PYTHONVENV%\Scripts\python.exe build.py
if errorlevel 1 (
   echo build failed
   call %PYTHONVENV%\Scripts\deactivate.bat
   exit /b %errorlevel%
)

echo Deactivating virtual environment
call %PYTHONVENV%\Scripts\deactivate.bat

echo Build complete! You can now run dupeGuru using:
echo     ^> python run.py

goto end
REM END Build section

:cleansection
REM BEGIN Clean section

if not exist %PYTHONVENV% goto novenv
echo Deactivating python environment
call %PYTHONVENV%\Scripts\deactivate.bat
echo Removing python environment
rmdir /s /q %PYTHONVENV%
:novenv

if not exist dist goto nodist
echo Removing dist directory
rmdir /s /q dist
:nodist

if not exist build goto nobld
echo Removing build directory
rmdir /s /q build
:nobld

echo Clean complete!

goto end
REM END Clean section


:packagesection
REM BEGIN Package section

if exist %PYTHONVENV% goto venvavailable
echo No virtualenv, you should run this script to bootstrap and build first
exit /b %errorlevel%

:venvavailable

echo Activating virtual environment
call %PYTHONVENV%\Scripts\activate.bat

setlocal
SET PATH=%PATH%;%NSISPATH%
echo Running package script
%PYTHONVENV%\Scripts\python.exe package.py
if errorlevel 1 (
   echo package failed
   call %PYTHONVENV%\Scripts\deactivate.bat
   exit /b %errorlevel%
)

endlocal
echo Deactivating virtual environment
call %PYTHONVENV%\Scripts\deactivate.bat
echo Package complete! You can now run dupeGuru

goto end
REM END Package section

:end
