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
	SET _step=PinupValidate
	ECHO.

	REM Ensure Pinup System install doesn't already appear to exist
	IF NOT EXIST "!INSTALL_PINUP_LOC!" (
		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_PINUP_LOC%' does not exist.
		EXIT /B 1
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

	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------

REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------
