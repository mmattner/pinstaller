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
	SET _step=PupPacksValidate
	ECHO.
	
	REM Ensure target Pinup directory exists
	IF NOT EXIST "!INSTALL_PINUP_LOC!" (
	 	IF !InstallSummary_PinupPlayer! NEQ 1 (
	 		CALL pinstall_utils.bat log %ERROR% !_step! The target folder "!INSTALL_PINUP_LOC!" does not exist.
	 		EXIT /B 1
	 	)
	)
	
	REM Ensure supplied pinup videos source directory exists
	IF "!TablesInstall_pinup_puppacks_src_dir!" == "" (
		CALL pinstall_utils.bat log %INFO% !_step! "[TablesInstall].pinup_pupvideos_src_dir!" not supplied, no PUP Packs will be installed.
	) ELSE (
		IF NOT EXIST "!TablesInstall_pinup_puppacks_src_dir!" (
			CALL pinstall_utils.bat log %ERROR% !_step! The folder "!TablesInstall_pinup_puppacks_src_dir!" does not exist.
			EXIT /B 1
		)
	)
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:install
	SET _step=PupPacks

	REM Graceful	
	ECHO.
	ECHO  ____  _  _  ____    ____   __    ___  __ _  ____ 
	ECHO (  _ \/ )( \(  _ \  (  _ \ / _\  / __)(  / )/ ___)
	ECHO  ) __/) \/ ( ) __/   ) __//    \( (__  )  ( \___ \
	ECHO (__)  \____/(__)    (__)  \_/\_/ \___)(__\_)(____/
	ECHO ===============================================================================================
	ECHO.

	REM Copy contents of src pinup videos folder (which may contain nested folders) to destination
	CALL pinstall_utils.bat log %INFO% !_step! Deploying PinUp PUP Packs into "%INSTALL_PINUP_PUPVIDEOS_LOC%".
	CALL pinstall_utils.bat copydircontent !_step! "!TablesInstall_pinup_puppacks_src_dir!" "%INSTALL_PINUP_PUPVIDEOS_LOC%"

	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------
