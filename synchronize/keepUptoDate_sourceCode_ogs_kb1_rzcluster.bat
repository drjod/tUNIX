@echo off


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:::: THIS SCRIPT SETS VARIABLES FOR SYNCHRONIZATION SCRIPT 
:::: keepUptoDate_sourceCode.bat
::
::   Adapt DECLARATIONS to use it 
::   Password variable pwd is set in extra file
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::: DECLARATIONS


set localComputer=amak
set remoteComputer=rzcluster
set code=ogs
set branch=ogs_kb1
set login=sungw389
set hostname=rzcluster.rz.uni-kiel.de

set localRoot=F:\testingEnvironment
set remoteRoot=/home/%login%/testingEnvironment




:: GET PASSWORD
call %localRoot%\scripts\icbc\pwds\%remoteComputer%.bat


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: SYNCHRONIZE
call %localRoot%\scripts\icbc\synchronization\keepUpToDate_sourceCode.bat 

