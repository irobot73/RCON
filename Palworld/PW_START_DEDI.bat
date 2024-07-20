@echo off
title PW_Dedi
setlocal enabledelayedexpansion

REM Place this .BAT in your Palworld server's root folder
REM     and edit the 'User Configuration' sections as needed

REM Get External IP address
For /f %%A in (
  'powershell -nop -c "(Invoke-RestMethod http://ipinfo.io/json).IP"'
) Do Set ExtIP=%%A

REM ******************
REM User Configuration
REM ******************

set "svrCheckIntervalMinutes=3"
set "bkupIntervalMinutes=30"
set "backupIntervalMinutes=30"
set "palworldServer=D:\palworld_svr\PalServer.exe"
set "serverParameters=-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS -publiclobby -log -publicip=%ExtIP% -bIsUseBackupSaveData=True -PlayerStomachDecreaceRate=0.300000 -PlayerStaminaDecreaceRate=0.200000 -PlayerAutoHPRegeneRate=2.000000 -Difficulty=None -DayTimeSpeedRate=.5000000 -NightTimeSpeedRate=1.000000 -ExpRate=2.000000 -PalCaptureRate=2.500000 -PalSpawnNumRate=1.000000 -PalDamageRateAttack=2.000000 -PalDamageRateDefense=3.000000 -PlayerDamageRateAttack=2.000000 -PlayerDamageRateDefense=1.000000 -PlayerAutoHpRegeneRateInSleep=1.000000 -PalStomachDecreaceRate=0.100000 -PalStaminaDecreaceRate=0.100000 -PalAutoHPRegeneRate=2.000000 -PalAutoHpRegeneRateInSleep=2.000000 -BuildObjectDamageRate=0.100000 -BuildObjectDeteriorationDamageRate=0.100000 -CollectionDropRate=4.000000 -CollectionObjectHpRate=1.000000 -CollectionObjectRespawnSpeedRate=5.000000 -EnemyDropItemRate=3.000000 -DeathPenalty=None -bEnablePlayerToPlayerDamage=False -bEnableFriendlyFire=False -bEnableInvaderEnemy=True -bActiveUNKO=False -bEnableAimAssistPad=True -bEnableAimAssistKeyboard=False -DropItemMaxNum=30000 -DropItemMaxNum_UNKO=100 -BaseCampMaxNum=128 -BaseCampWorkerMaxNum=20 -DropItemAliveMaxHours=2.000000 -bAutoResetGuildNoOnlinePlayers=False -bShowPlayerList=True -AutoResetGuildTimeNoOnlinePlayers=999.000000 -GuildPlayerMaxNum=10 -PalEggDefaultHatchingTime=0.000000 -WorkSpeedRate=2.000000 -bIsMultiplay=True -bIsPvP=False -bCanPickupOtherGuildDeathPenaltyDrop=False -bEnableNonLoginPenalty=False -bEnableFastTravel=True -bIsStartLocationSelectByMap=True -bExistPlayerAfterLogout=False -bEnableDefenseOtherGuildPlayer=True -CoopPlayerMaxNum=10 -ServerPlayerMaxNum=20 -ServerName=^"kimba Dynomite^" -port=8211 -players=21 -ServerDescription=^"Please come join our Discord at https://discord.gg/mPrKGA7a3k^" -AdminPassword=^"Mimmetta@!2^" -PublicPort=8211 -RCONEnabled=True -RCONPort=8215 -Region=^"NA^" -bUseAuth=True"

REM ******
REM Do NOT edit this section (unless you know what you're doing)
REM ******
set /a "svrCheckIntervalSeconds=%svrCheckIntervalMinutes%*60"
set /a "bkupIntervalSeconds=%bkupIntervalMinutes%*60"
set /a "elapsedTime=0"
set /a "svrUpTime=0"

REM Ensure server is running
:check_server
tasklist | find /i "PalServer.exe" > nul
REM %errorlevel% = 0 for not found and 1 for found
if %errorlevel% neq 0 (
    tasklist | find /i "PalServer-Win64-Test-Cmd.exe" && taskkill /im notepad.exe /F || echo [%DATE% %TIME%] Process 'PalServer-Win64-Test-Cmd.exe' not running.
    tasklist | find /i "PalServer.exe" && taskkill /im notepad.exe /F || echo [%DATE% %TIME%] Process 'PalServer.exe"' not running.

    set /a "svrUpTimeInMinutes=0"
    if !svrUpTime! geq 1 (
    	set /a "svrUpTimeInMinutes=!%svrUpTime!/60"
    )
    echo [%DATE% %TIME%] [Re]Starting the server.  Prior server uptime: !svrUpTimeInMinutes!-mins.
    set /a "svrUpTime=0"

    start "" %palworldServer% %serverParameters%

    REM Give the server some time to get up and running
    timeout /t 60 /nobreak > NUL 2>&1
) else (
    echo [%DATE% %TIME%] Server running normally.
)

REM Run backup at start-up and every {X} 'backupIntervalMinutes
:backup
set /a "remainder=%svrUpTime% %% %bkupIntervalSeconds%"
if %svrUpTime% == 0 (
    echo [%DATE% %TIME%] ...Backup requested.
    START /MIN cmd /c ".\BACKUP.bat"
) else (
    if %remainder% == 0 (
	    echo [%DATE% %TIME%] ...Backup requested.
        START /MIN cmd /c ".\BACKUP.bat"
    )
)

:time_loop
timeout /nobreak /t 60 > nul

set /a "elapsedTime+=60"
set /a "svrUpTime+=60"

if %elapsedTime% geq %svrCheckIntervalSeconds% (
    set /a "elapsedTime=0"
    goto :check_server
) else (
    echo [%DATE% %TIME%] ......ping
)
goto :time_loop