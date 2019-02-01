@echo off
setlocal ENABLEDELAYEDEXPANSION

rem You can not have closing bracket character inside brackets
rem So we assign it to a variable, and will use it, instead.
set cb=)

echo [%1 %2 %3 %4 %5 %6 %7]>>%temp%\msitest.log

if "%1 %2 %3"=="wmic product where"                 goto :get_msi_by_name
if "%1 %2 %3"=="wmic product get"                   goto :list_packages

if "%1 %2 %3"=="cscript /nologo %~dp0\WiRunSQL.vbs" goto :get_package_data
if "%1 %2 %3 %4"=="msiexec /quiet /qb /norestart"   goto :msiexec

goto :error

:list_packages
  if not "%*"=="wmic product get name,version /value" goto :error

  echo Name=Python 3.7.0 Development Libraries (32-bit)x
  echo Version=3.7.150.0x
  echo.
  echo.
  echo Name=Приложение (русское)x
  echo Version=5.2.3790x
  echo.
  echo.
  echo Name=CFEngine Novax
  echo Version=3.12.0.0x
  echo.
  echo.
goto :EOF

:get_package_data
  if not "%6"=="" goto :error
  if %4=="%windir%" goto :get-package_data_windir
  if %4=="%temp%"   goto :get-package_data_temp
goto :error

:get_package_data_windir
  rem TODO: check that first and last characters of %5 are quotes and that it
  rem doesn't have any quotes inside so it's safe to put it in `if` unquoted
  if %5=="select Value from Property where Property = 'ProductName'" (
    echo CFEngine Nova
    echo.
    goto :EOF
  )
  if %5=="select Value from Property where Property = 'ProductVersion'" (
    echo 3.12.0.0
    echo.
    goto :EOF
  )
goto :error


:get_package_data_temp
  if %5=="select Value from Property where Property = 'ProductName'" (
    echo Приложение (русское!cb!
    echo.
    goto :EOF
  )
  if %5=="select Value from Property where Property = 'ProductVersion'" (
    echo 3.12.0.0
    echo.
    goto :EOF
  )
goto :error


:msiexec
  if not %6=="%windir%" if not %6=="%temp%" goto :error

  if "%5 %7"=="/i " goto :EOF
  if "%5 %7"=="/x " goto :EOF
goto :error


:get_msi_by_name
  if not "%5 %6 %7 %8"=="get LocalPackage /value " goto :error

  rem decide what kind of output we want to present:
  rem 0 - unrecognized input
  rem 1,3 - have such package
  rem 2 - have no such package
  set output=0
  if %4=="name='notexist'" set output=1
  if %4=="name='notexist' and version='1'" set output=1
  if %4=="name='notexist' and version='2'" set output=2
  if %4=="name='Приложение (русское)'" set output=3

  rem now act on our decision
  if "%output%"=="0" goto :error
  if "%output%"=="1" echo LocalPackage=%windir%
  if "%output%"=="2" echo no packages
  if "%output%"=="3" echo LocalPackage=%temp%

goto :EOF

:error
echo ERROR: unexpected arguments >>%temp%\msitest.log
