@echo off

set CFENGINE_MSIEXEC_TEST=call %~dp0\mock_msi.bat
set msi_module="../../modules/packages/msiexec.bat"
set error=0



echo ========== list-installed test ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo Name=Python 3.7.0 Development Libraries (32-bit)>%temp%\expected.txt
echo Version=3.7.150.0>>%temp%\expected.txt
echo Architecture=x86>>%temp%\expected.txt
echo Name=Приложение (русское)>>%temp%\expected.txt
echo Version=5.2.3790>>%temp%\expected.txt
echo Architecture=x86>>%temp%\expected.txt
echo Name=CFEngine Nova>>%temp%\expected.txt
echo Version=3.12.0.0>>%temp%\expected.txt
echo Architecture=x86>>%temp%\expected.txt

echo [wmic product get name version /value ]>%temp%\msitest-expected.txt


call %msi_module% list-installed >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== get-package-data test - existing file ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo PackageType=file>%temp%\expected.txt
echo Name=CFEngine Nova>>%temp%\expected.txt
echo Version=3.12.0.0>>%temp%\expected.txt

echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductName'"  ]>%temp%\msitest-expected.txt
echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductVersion'"  ]>>%temp%\msitest-expected.txt


echo File=%windir%| call %msi_module% get-package-data >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== get-package-data test - Russian file ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo PackageType=file>%temp%\expected.txt
echo Name=Приложение (русское)>>%temp%\expected.txt
echo Version=3.12.0.0>>%temp%\expected.txt

echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%temp%" "select Value from Property where Property = 'ProductName'"  ]>%temp%\msitest-expected.txt
echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%temp%" "select Value from Property where Property = 'ProductVersion'"  ]>>%temp%\msitest-expected.txt


echo File=%temp%| call %msi_module% get-package-data >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== get-package-data test - not a file, so a repo ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo PackageType=repo>%temp%\expected.txt
echo Name=notexist>>%temp%\expected.txt


echo File=notexist| call %msi_module% get-package-data >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :notexist %temp%\msitest.log



echo ========== get-package-data test - multiple ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo File=app1>%temp%\input.txt
echo File=app (русское)>>%temp%\input.txt
echo Version=10.11>>%temp%\input.txt
echo File=%windir%>>%temp%\input.txt
echo File=%windir%>>%temp%\input.txt
echo Version=12.13>>%temp%\input.txt

echo PackageType=repo>%temp%\expected.txt
echo Name=app1>>%temp%\expected.txt
echo PackageType=repo>>%temp%\expected.txt
echo Name=app (русское)>>%temp%\expected.txt
echo PackageType=file>>%temp%\expected.txt
echo Name=CFEngine Nova>>%temp%\expected.txt
echo Version=3.12.0.0>>%temp%\expected.txt
echo PackageType=file>>%temp%\expected.txt
echo Name=CFEngine Nova>>%temp%\expected.txt
echo Version=3.12.0.0>>%temp%\expected.txt

echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductName'"  ]>%temp%\msitest-expected.txt
echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductVersion'"  ]>>%temp%\msitest-expected.txt
echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductName'"  ]>>%temp%\msitest-expected.txt
echo [cscript /nologo C:\Users\IEUser\\WiRunSQL.vbs "%windir%" "select Value from Property where Property = 'ProductVersion'"  ]>>%temp%\msitest-expected.txt


type %temp%\input.txt | call %msi_module% get-package-data >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== file-install test - existing file ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [msiexec /quiet /qb /norestart /i "%windir%" ]>%temp%\msitest-expected.txt


echo File=%windir%| call %msi_module% file-install >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== file-install test - notexisting file ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo ErrorMessage=File "notexist" not found>%temp%\expected.txt


echo File=notexist| call %msi_module% file-install >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :notexist %temp%\msitest.log



echo ========== file-install test - multiple ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo File=notexist>%temp%\input.txt
echo File=%windir%>>%temp%\input.txt

echo ErrorMessage=File "notexist" not found>%temp%\expected.txt
echo [msiexec /quiet /qb /norestart /i "%windir%" ]>%temp%\msitest-expected.txt


type %temp%\input.txt | call %msi_module% file-install >%temp%\actual.txt


call :diff %temp%\actual.txt %temp%\expected.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - existing file ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [msiexec /quiet /qb /norestart /x "%windir%" ]>%temp%\msitest-expected.txt


echo Name=%windir%| call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - existing software ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [wmic product where "name='notexist'" get LocalPackage /value]>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%windir%" ]>>%temp%\msitest-expected.txt


echo Name=notexist| call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - russian software ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [wmic product where "name='Приложение (русское)'" get LocalPackage /value]>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%temp%" ]>>%temp%\msitest-expected.txt


echo Name=Приложение (русское)| call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - with version ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [wmic product where "name='notexist' and version='1'" get LocalPackage /value]>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%windir%" ]>>%temp%\msitest-expected.txt

echo Name=notexist>%temp%\input.txt
(echo Version=1)>>%temp%\input.txt


type %temp%\input.txt | call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - this version not installed ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo [wmic product where "name='notexist' and version='2'" get LocalPackage /value]>%temp%\msitest-expected.txt

echo Name=notexist>%temp%\input.txt
(echo Version=2)>>%temp%\input.txt


type %temp%\input.txt | call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== remove test - multiple ==========
if exist %temp%\msitest.log del %temp%\msitest.log

echo Name=notexist>%temp%\input.txt
(echo Version=1)>>%temp%\input.txt
echo Name=%windir%>>%temp%\input.txt
echo Name=Приложение (русское)>>%temp%\input.txt
echo Name=%windir%>>%temp%\input.txt
(echo Version=2)>>%temp%\input.txt

echo [wmic product where "name='notexist' and version='1'" get LocalPackage /value]>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%windir%" ]>>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%windir%" ]>>%temp%\msitest-expected.txt
echo [wmic product where "name='Приложение (русское)'" get LocalPackage /value]>>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%temp%" ]>>%temp%\msitest-expected.txt
echo [msiexec /quiet /qb /norestart /x "%windir%" ]>>%temp%\msitest-expected.txt


type %temp%\input.txt | call %msi_module% remove >%temp%\actual.txt


call :empty %temp%\actual.txt
call :diff %temp%\msitest.log %temp%\msitest-expected.txt



echo ========== cleanup ==========
if exist %temp%\input.txt del %temp%\input.txt
if exist %temp%\actual.txt del %temp%\actual.txt
if exist %temp%\expected.txt del %temp%\expected.txt
if exist %temp%\msitest.log del %temp%\msitest.log
if exist %temp%\msitest-expected.txt del %temp%\msitest-expected.txt

exit /b %error%



rem check that two files are the same
:diff
  fc %1 %2 >nul 2>nul
  if errorlevel 1 (
    set error=1
    echo error:
    fc %1 %2
  )
goto :EOF


rem check that file does not exist
:notexist
if exist "%1" (
  set error=1
  echo error: file %1 should NOT exist:
  type %1
)
goto :EOF


rem check that file size is 0
:empty
if not "%~z1"=="0" (
  set error=1
  echo error: file %1 should be empty:
  type %1
)
goto :EOF
