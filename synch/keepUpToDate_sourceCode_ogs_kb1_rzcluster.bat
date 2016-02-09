@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Provide the password for ssh with:
:: set pwd=****
:: in extra file ..\pwd\%remoteComputer%.bat 
:: (with the setting below the filename is rzcluster.bat)
::

set localComputer=amak
set remoteComputer=rzcluster
set code=ogs
set branch=ogs_kb1
set login=sungw389
set hostname=rzcluster.rz.uni-kiel.de

call F:\testingEnvironment\scripts\icbc\pwds\%remoteComputer%.bat

call F:\testingEnvironment\scripts\icbc\synchronization\keepUpToDate_sourceCode.bat 
