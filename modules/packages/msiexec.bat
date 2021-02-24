@echo off
setlocal ENABLEDELAYEDEXPANSION

rem Use real applications or testing stub for testing

set MSIEXEC=msiexec
set WMIC=wmic
set CSCRIPT=cscript

if not "%CFENGINE_MSIEXEC_TEST%"=="" (
  set MSIEXEC=%CFENGINE_MSIEXEC_TEST% msiexec
  set WMIC=%CFENGINE_MSIEXEC_TEST% wmic
  set CSCRIPT=%CFENGINE_MSIEXEC_TEST% cscript
)

rem choose a function to execute

if "%1"=="supports-api-version" echo 1
if "%1"=="get-package-data"   goto :get_package_data_list
if "%1"=="list-installed"     goto :list_installed
if "%1"=="list-updates"       rem not implemented
if "%1"=="list-updates-local" rem not implemented
if "%1"=="repo-install"       rem not implemented
if "%1"=="file-install"       goto :file_install_list
if "%1"=="remove"             goto :remove_list

goto :EOF



rem Reads all stdin lines, for each line which starts with
rem "File=" call the next function
:get_package_data_list
  for /F "tokens=*" %%a in ('more') do (
    rem Assign for-loop %%a variable to "normal" %_q% variable to extract substrings
    rem via %name:~begin,length% expansion (negative value means length of string - value)
    set "_q=%%a"
    rem * Use "Delayed Expansion" of variables (surround them with ! instead of %)
    if "!_q:~0,5!"=="File=" call :get_package_data_one "!_q:~5!"
  )
goto :EOF


rem Choose one of two following functions to call based on whether file exists or not
:get_package_data_one
  rem This function called with an argument in quotes, so:
  rem use %1 when you need value in quotes,
  rem use %~1 when you need without
  if not exist %1 call :get_package_data_repo %1
  if     exist %1 call :get_package_data_file %1
goto :EOF


rem Print package information for an existing file
:get_package_data_file
  echo PackageType=file
  rem %~dp0 expands to drive and path of current script
  rem TODO: if name is multi-line, print "Name=" only once
  for /f "usebackq delims=" %%b in (`%CSCRIPT% /nologo "%~dp0\WiRunSQL.vbs" %1
    "select Value from Property where Property = 'ProductName'"`
  ) do echo Name=%%b
  for /f "usebackq delims=" %%b in (`%CSCRIPT% /nologo "%~dp0\WiRunSQL.vbs" %1
    "select Value from Property where Property = 'ProductVersion'"`
  ) do echo Version=%%b
goto :EOF


rem If file does not exist - assume it's a repo
:get_package_data_repo
  echo PackageType=repo
  echo Name=%~1
goto :EOF



rem Call vbs script to read installed software from registry
:list_installed
  %CSCRIPT% /nologo "%~dp0\msiexec-list.vbs"
goto :EOF



rem Reads all stdin lines, for each line which starts with "File=" call the next function
:file_install_list
  for /F "tokens=*" %%a in ('more') do (
    set "_q=%%a"
    if "!_q:~0,5!"=="File=" call :file_install_one "!_q:~5!"
  )
goto :EOF


rem Install this file if it exists
:file_install_one
  if not exist %1 (
    echo ErrorMessage=File %1 not found!
    goto :EOF
  )

  set log_dir="\cfengine_package_logs\"
  if not exist %log_dir% (
    mkdir %log_dir%
  )
  for /F "delims=" %%i in (%1) do @set basename="%%~ni"
  REM %log_dir:"=% replaces quotes with nothing, otherwise you get two double-quotes which causes failures
  set log_file="%log_dir:"=%%basename:"=%_install.log"
  %MSIEXEC% /quiet /passive /qn /norestart /l*vx %log_file% /i %1
  if not errorlevel 0 (
    echo ErrorMessage=msiexec.exe ErrorLevel was %ErrorLevel% for file %1 log at %log_file%
  )
goto :EOF



rem Reads all stdin lines, calls next function for each of them
:remove_list
  for /F "tokens=*" %%a in ('more') do (
    call :remove_line "%%a"
  )
  call :remove_one
goto :EOF


rem processes line of input, saves name and version, and calls
rem next function before new block (which starts with "Name=" line)
:remove_line
  set "_q=%~1"
  if "%_q:~0,5%"=="Name=" (
    call :remove_one
    set "_name=%_q:~5%"
    set _ver=
  )

  if "%_q:~0,8%"=="Version=" (
    set "_ver=%_q:~8%"
  )
goto :EOF


rem Remove file or software stored in "%_name%" env variable, if it's set.
rem If such file does not exist - remove an installed program with such name
:remove_one
  if "%_name%"=="" goto :EOF

  if exist "%_name%" (
    call :remove_file "%_name%"
    goto :EOF
  )

  if "%_ver%"=="" (
    set "_condition=name='%_name%'"
  ) else (
    set "_condition=name='%_name%' and version='%_ver%'"
  )

  rem Characters > and & chars in for expression must be escaped
  for /f "delims=" %%a in (
      '%WMIC% product where "%_condition%" get LocalPackage /value 2^>^&1'
  ) do (
    set "_q=%%a"
    if "!_q:~0,13!"=="LocalPackage=" call :remove_file "!_q:~13!"
  )
goto :EOF


rem Remove software from MSI package which name is passed as argument
:remove_file
  %MSIEXEC% /quiet /passive /qn /norestart /x %1
  rem TODO options, error checking
goto :EOF
