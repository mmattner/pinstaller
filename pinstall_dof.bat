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
	SET _step=DOFValidate
	ECHO.

	REM Ensure VPX install doesn't already appear to exist
	IF EXIST "!INSTALL_DOF_LOC!" (
		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_DOF_LOC%' already exists.
		EXIT /B 1
	)
	
	REM Ensure mandatory installer variables were supplied
	SET _missingCfgSetting=0
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].dof_installer !Installers_dof_installer!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	IF !_missingCfgSetting! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingCfgSetting! mandatory installer file variables were not supplied.
		ECHO OutValidate1
		EXIT /B 1
	)
	
	REM Ensure installer variables that were supplied exist
	SET _missingInstallFile=0
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_dof_installer!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF !_missingInstallFile! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingInstallFile! mandatory installer files were not found.
		EXIT /B 1
	)
	
	REM Unpack zip archives to confirm they can be unpacked, store results in temp directory
	REM to avoid needing to unpack a second time
	IF EXIST "!DOF_CONFIG_ARCHIVE!" (
		SET _badArchives=0
		CALL pinstall_utils.bat unzip !_step! "!DOF_CONFIG_ARCHIVE!" "%TEMP_DIR%%directoutputconfig"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
		IF !_badArchives! GTR 0 (
			CALL pinstall_utils.bat log %ERROR% !_step! !_badArchives! archives could not be unpacked.
			EXIT /B 1
		)
	) ELSE (
		CALL pinstall_utils.bat log %WARN% !_step! "!DOF_CONFIG_ARCHIVE!" was not provided, DOF will be degraded until supplied.
	)
	IF NOT EXIST "!DOF_CONFIG_CABINET!" (
		CALL pinstall_utils.bat log %WARN% !_step! "!DOF_CONFIG_CABINET!" was not provided, DOF will be degraded until supplied.
	)
	IF NOT EXIST "!DOF_CONFIG_GLOBALB2S_CONFIG!" (
		CALL pinstall_utils.bat log %WARN% !_step! "!DOF_CONFIG_GLOBALB2S_CONFIG!" was not provided, DOF will be degraded until supplied.
	)
	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:install
	SET _step=DOFPrep
	
	REM Graceful
	ECHO.
	ECHO  ____   __  ____ 
	ECHO (    \ /  \(  __)
	ECHO  ) D ((  O )) _) 
	ECHO (____/ \__/(__)  
	ECHO ===============================================================================================
	ECHO.

	REM Copy any prepared DOF config files into temporary location
	IF EXIST "!DOF_CONFIG_CABINET!" (
	  COPY /Y "!DOF_CONFIG_CABINET!" "%TEMP_DIR%directoutputconfig" > nul 2>&1
	  CALL pinstall_utils.bat log %INFO% !_step! Added cabinet.xml to DOF config folder
	)
	IF  EXIST "!DOF_CONFIG_GLOBALB2S_CONFIG!" (
	  COPY /Y "!DOF_CONFIG_GLOBALB2S_CONFIG!" "%TEMP_DIR%directoutputconfig" > nul 2>&1
	  CALL pinstall_utils.bat log %INFO% !_step! Added GlobalConfig_B2SServer.xml to DOF config folder
	)
	ECHO.

	SET _step=DOFInstall
	REM Perform DOF install
	CALL pinstall_utils.bat log %INFO% !_step! Performing DOF installation
	CALL "%INSTALL_DIR%!Installers_dof_installer!" > nul 2>&1
	ECHO.

	SET _step=DOFConfig
	REM Apply any patches and updates
	CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%directoutputconfig" "%INSTALL_DOF_LOC%Config"
	ECHO.

	SET _step=DOFRegister
	CALL pinstall_utils.bat log %INFO% !_step! Registering DOF installation with B2S
	CALL "%INSTALL_DOF_LOC%RegisterDirectOutputComObject.exe" > nul 2>&1
	ECHO.

    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	SET _step=DOFUnininstall
	ECHO.
	CALL pinstall_utils.bat log %INFO% !_step! Removing directory "%INSTALL_DOF_LOC%".
	RMDIR /S /Q "%INSTALL_DOF_LOC%" > nul 2>&1
	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------
