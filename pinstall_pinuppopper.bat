@ECHO OFF

REM -----------------------------------------------------------------------------------------------
REM This batch file is a collection of functions which are called by passing the function name and
REM required parameters to the batch, ie, to call the :validate function passing it two arguments
REM with values 'a' and 'b', the call to the batch file would be:
REM     "pinstall_vpx.bat validate 'a' 'b'"
REM -----------------------------------------------------------------------------------------------


REM Extract the function name and parameter list from the supplied parameters. No checking is
REM performed to ensure corresponding functions exist.
SET function_name=%~1
FOR /f "tokens=1,* delims= " %%a in ("%*") DO SET function_arguments=%%b
CALL :%function_name% %function_arguments%
EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:validate
	SET _step=PinupPopperValidate
	ECHO.

	REM Ensure Pinup System install doesn't already appear to exist
	IF NOT EXIST "!INSTALL_PINUP_LOC!" (
	 	IF !InstallSummary_PinupPlayer! NEQ 1 (
	 		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_PINUP_LOC%' does not exist.
	 		EXIT /B 1
	 	)
	)
	
	REM Ensure mandatory installer variables were supplied
	SET _missingCfgSetting=0
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].pinuppopper_archive !Installers_pinuppopper_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	IF !_missingCfgSetting! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingCfgSetting! mandatory installer file variables were not supplied.
		EXIT /B 1
	)
	
	REM Ensure installer variables that were supplied exist
	SET _missingInstallFile=0
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_pinuppopper_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF !_missingInstallFile! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingInstallFile! mandatory installer files were not found.
		EXIT /B 1
	)
	
	REM Unpack zip archives to confirm they can be unpacked, store results in temp directory
	REM to avoid needing to unpack a second time
	SET _badArchives=0
	IF "!Installers_pinuppopper_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_pinuppopper_archive!" "%TEMP_DIR%%pinuppopper_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF !_badArchives! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_badArchives! archives could not be unpacked.
		EXIT /B 1
	)

    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:install
	SET _step=PinupPopper
	
	REM Graceful
	ECHO.
	ECHO  ____  __  __ _  _  _  ____    ____   __  ____  ____  ____  ____ 
	ECHO (  _ \(  )(  ( \/ )( \(  _ \  (  _ \ /  \(  _ \(  _ \(  __)(  _ \
	ECHO  ) __/ )( /    /) \/ ( ) __/   ) __/(  O )) __/ ) __/ ) _)  )   /
	ECHO (__)  (__)\_)__)\____/(__)    (__)   \__/(__)  (__)  (____)(__\_)
	ECHO ===============================================================================================
	ECHO.

	REM Deploy Pinup Popper
	CALL pinstall_utils.bat log %INFO% !_step! Installing Pinup Popper archive: "!Installers_pinuppopper_archive!".
	IF "!Installers_pinuppopper_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%pinuppopper_archive" "%INSTALL_PINUP_LOC%"
	)
	ECHO.

	REM Register popper components
	CALL pinstall_utils.bat log %INFO% !_step! Registering PinUpDOF.
	CALL pinstall_utils.bat run_elevated "%INSTALL_PINUP_LOC%PinUpDOF.exe" /regserver
	CALL pinstall_utils.bat log %INFO% !_step! Registering PuPServer.
	CALL pinstall_utils.bat run_elevated "%INSTALL_PINUP_LOC%PuPServer.exe" /regserver
	CALL pinstall_utils.bat log %INFO% !_step! Registering PinUpDisplay.
	CALL pinstall_utils.bat run_elevated "%INSTALL_PINUP_LOC%PinUpDisplay.exe" /regserver

	REM Populate keycodes based on those specified
	SET popper_keys_db=%TEMP_DIR%popper_keys.sql
	CALL :add_db_command !_step! "!popper_keys_db!" !GamePriorId! !PopperKeys_GamePrior!
	CALL :add_db_command !_step! "!popper_keys_db!" !GameNextId! !PopperKeys_GameNext!
	CALL :add_db_command !_step! "!popper_keys_db!" !ListNextId! !PopperKeys_ListNext!
	CALL :add_db_command !_step! "!popper_keys_db!" !ListPriorId! !PopperKeys_ListPrior!
	CALL :add_db_command !_step! "!popper_keys_db!" !PagePriorId! !PopperKeys_PagePrior!
	CALL :add_db_command !_step! "!popper_keys_db!" !PageNextId! !PopperKeys_PageNext!
	CALL :add_db_command !_step! "!popper_keys_db!" !GameStartId! !PopperKeys_GameStart!
	CALL :add_db_command !_step! "!popper_keys_db!" !HomeMenuId! !PopperKeys_HomeMenu!
	CALL :add_db_command !_step! "!popper_keys_db!" !GameMenuId! !PopperKeys_GameMenu!
	CALL :add_db_command !_step! "!popper_keys_db!" !GameInfoFlyerId! !PopperKeys_GameInfoFlyer!
	CALL :add_db_command !_step! "!popper_keys_db!" !MenuSystemExitId! !PopperKeys_MenuSystemExit!
	CALL :add_db_command !_step! "!popper_keys_db!" !SystemShutdownId! !PopperKeys_SystemShutdown!
	CALL :add_db_command !_step! "!popper_keys_db!" !MenuReturnId! !PopperKeys_MenuReturn!
	CALL :add_db_command !_step! "!popper_keys_db!" !MenuSelectId! !PopperKeys_MenuSelect!
	CALL :add_db_command !_step! "!popper_keys_db!" !ExitEmulatorsId! !PopperKeys_ExitEmulators!
	CALL :add_db_command !_step! "!popper_keys_db!" !SystemMenuId! !PopperKeys_SystemMenu!
	CALL :add_db_command !_step! "!popper_keys_db!" !GameHelpId! !PopperKeys_GameHelp!
	CALL :add_db_command !_step! "!popper_keys_db!" !RecordStartStopId! !PopperKeys_RecordStartStop!
	CALL :add_db_command !_step! "!popper_keys_db!" !ShowOtherId! !PopperKeys_ShowOther!
	CALL :add_db_command !_step! "!popper_keys_db!" !PauseGameId! !PopperKeys_PauseGame!
	CALL :add_db_command !_step! "!popper_keys_db!" !InGameScriptId! !PopperKeys_InGameScript!
	CALL :add_db_command !_step! "!popper_keys_db!" !PlayOnlyModeId! !PopperKeys_PlayOnlyMode!
	CALL :run_db_script !_step! "!popper_keys_db!"
	
	
	REM Enable DOF and DMD as needed
	SET useDMD=
	SET useDOF=
	IF "%InstallSummary_DOF%" == "1" ( SET useDOF=DOF)
	IF "%InstallSummary_DOFLinx%" == "1" ( SET useDOF=DOF)
	IF "%DMDDeviceConfig_pindmd1_enabled%"=="true" ( SET useDMD=DMD)
	IF "%DMDDeviceConfig_pindmd2_enabled%"=="true" ( SET useDMD=DMD)
	IF "%DMDDeviceConfig_pindmd3_enabled%"=="true" ( SET useDMD=DMD)
	IF "%DMDDeviceConfig_pin2dmd_enabled%"=="true" ( SET useDMD=DMD)
	CALL pinstall_utils.bat log %INFO% !_step! Updating PUPMenuScriptSysOptions.txt to enable the following modules: %useDOF% %useDMD% 
	CALL pinstall_utils.bat log %INFO% !_step! Using config template file "%PINUP_CONFIG_DIR%PUPMenuScriptSysOptions%useDOF%%useDMD%.txt".
	COPY /Y "%PINUP_CONFIG_DIR%PUPMenuScriptSysOptions%useDOF%%useDMD%.txt" "%INSTALL_PINUP_LOC%PUPMenuScriptSysOptions.txt" > nul 2>&1
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------

REM -----------------------------------------------------------------------------------------------
REM Perform any uninstallation required.
REM 
REM Usage: CALL pinstall_utils.bat uninstall
REM -----------------------------------------------------------------------------------------------
:uninstall
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Add an entry into the Sqllite script identified by <filename>, creating the file if needed.
REM The entry will assign a keycode to the identifed key.
REM
REM Usage: CALL :add_db_command <label> <filename> Mkey_id> <keycode>
REM Where:
REM     <label>: Is a string prefix used in log messages
REM     <filename>: Is the name of the database script to generate
REM     <command_id>: Is the uniqueID value of the key as defiend in the underlying database.
REM     <keycode>: Is the keycode to assign to the command, refer to 
REM                https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.keys?view=net-5.0
REM -----------------------------------------------------------------------------------------------
:add_db_command
	SET _label=%~1
	SET _filename=%~2
	SET _command_id=%~3
	SET _keycode=%~4
	
	IF NOT EXIST "!_filename!" (
		COPY NUL "!_filename!"
	)
	
	IF "!_keycode!"=="" (
		SET _keycode=0
	)
	ECHO update PinUPFunctions set CntrlCodes=%_keycode% where uniqueID=%_command_id%; >> %_filename% 
	EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Execute the sqllite SQL commands found in the supplied script against the Pinup Popper database. 
REM
REM Usage: CALL :run_db_script <label> <filename>
REM Where:
REM     <label>: Is a string prefix used in log messages
REM     <filename>: Is the name of the database script to execute
REM -----------------------------------------------------------------------------------------------
:run_db_script
	SET _label=%~1
	SET _filename=%~2
	
	IF NOT EXIST "!_filename!" (
		CALL pinstall_utils.bat log %ERROR% !_label! DB script "!_filename!" does not exist, cannot execute.
	) ELSE (
		CALL pinstall_utils.bat log %INFO% !_label! DB script "!_filename!" being executed.
		TYPE %_filename% | !SQLLITE! %PUPDATABASE%
	)
REM -----------------------------------------------------------------------------------------------
	