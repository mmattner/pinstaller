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
	SET _step=DOFLinxValidate
	ECHO.

	REM Ensure DOF install appears to exist.
	IF NOT EXIST "!INSTALL_DOF_LOC!" (
	 	IF !InstallSummary_DOF! NEQ 1 (
	 		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_DOF_LOC%' does not exist.
	 		EXIT /B 1
	 	)
	)
	
	REM Ensure mandatory installer variables were supplied
	SET _missingCfgSetting=0
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].doflinx_archive !Installers_doflinx_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	IF !_missingCfgSetting! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingCfgSetting! mandatory installer file variables were not supplied.
		EXIT /B 1
	)
	
	REM Ensure installer variables that were supplied exist
	SET _missingInstallFile=0
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_doflinx_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF !_missingInstallFile! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingInstallFile! mandatory installer files were not found.
		EXIT /B 1
	)
	
	REM Unpack zip archives to confirm they can be unpacked, store results in temp directory
	REM to avoid needing to unpack a second time
	SET _badArchives=0
	IF "!Installers_doflinx_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_doflinx_archive!" "%TEMP_DIR%doflinx_archive"
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
	SET _step=DOFlinx
	
	REM Graceful
	ECHO.
	ECHO  ____   __  ____  __    __  __ _  _  _ 
	ECHO (    \ /  \(  __)(  )  (  )(  ( \( \/ )
	ECHO  ) D ((  O )) _) / (_/\ )( /    / )  ( 
	ECHO (____/ \__/(__)  \____/(__)\_)__)(_/\_)
	ECHO ===============================================================================================
	ECHO.

	REM Deploy DOFLinx
	CALL pinstall_utils.bat log %INFO% !_step! Installing DOFLinx archive: "!Installers_doflinx_archive!".
	IF "!Installers_doflinx_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%doflinx_archive" "%INSTALL_DOF_LOC%"
	)
	ECHO.

	REM Ensure DOF install appears to exist.
	IF EXIST "!INSTALL_FUTUREPINBALL_LOC!" (
		CALL pinstall_utils.bat log %INFO% !_step! Copying DOFLinx.vbs into Future Pinball scripts folder.
		IF NOT EXIST "!INSTALL_FUTUREPINBALL_LOC!Scripts" (
			MKDIR "!INSTALL_FUTUREPINBALL_LOC!Scripts"
		)
		COPY /Y "!INSTALL_DOF_LOC!DOFLinx.vbs" "!INSTALL_FUTUREPINBALL_LOC!Scripts" > nul 2>&1
	)
	
	REM Copy DOFLinx.ini into place
	REM TODO: This should be modified to generatew the ini file, but for now just use one that works for me
	CALL pinstall_utils.bat log %INFO% !_step! TODO, write a generator to populate this file.
	IF  EXIST "!DOFLINX_CONFIG!" (
		COPY /Y "!DOFLINX_CONFIG!" "%INSTALL_DOF_LOC%" > nul 2>&1
		CALL pinstall_utils.bat log %INFO% !_step! Added DOFLinx.ini into DirectOutput folder.
	)
	
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
	