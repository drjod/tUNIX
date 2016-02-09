@echo off

:: assumes that local computer runs with windows and remote with linux
::
:: set the following parameters previsouly:
:: localComputer, set remoteComputer, code, branch, login, pwd, hostName
:: a file winscp_keepUpToDate.txt will be generated in temporary folder - you can delete that then

echo.
echo __()_()________________________________________________________________________
echo __('.')__________________________ KEEPING UP TO DATE __________________________
echo __()  icbc 0.2 __________________ %code% %branch%      _________
echo _________________________________ ON %remoteComputer% ___________________________
echo.
:::::::::::::::

set tempFolder=C:\Windows\Temp
set winscpScript=%tempFolder%\winscp_keepUpToDate_%code%_%branch%_%remoteComputer%.txt


echo option batch abort > %winscpScript%
echo option confirm off >> %winscpScript%
echo open sftp://%login%:%pwd%@%hostName%/ >> %winscpScript%
echo keepuptodate F:\testingEnvironment\%localComputer%\%code%\%branch%\sources /home/%login%/testingEnvironment/%remoteComputer%/%code%/%branch%/sources >> %winscpScript%


set WINSCP=C:\"Program Files (x86)"\WinSCP\WinSCP.com
call %WINSCP% /script=%winscpScript%

: del F:\tools\winscp\winscp_keepUpToDate.txt
: removed since it does not delete

: pause
