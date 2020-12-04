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
	SET _step=VPXTableValidate
	ECHO.
	
	REM Ensure target VPX directory exists
	IF NOT EXIST "!INSTALL_VPX_LOC!" (
		CALL pinstall_utils.bat log %ERROR% !_step! The target folder "!INSTALL_VPX_LOC!" does not exist.
		EXIT /B 1
	)
	
	REM Ensure supplied table source directory exists
	IF "!TablesInstall_vpx_tables_src_dir!" == "" (
		CALL pinstall_utils.bat log %INFO% !_step! "[TablesInstall].vpx_tables_src_dir!" not supplied, no tables will be installed.
	) ELSE (
		IF NOT EXIST "!TablesInstall_vpx_tables_src_dir!" (
			CALL pinstall_utils.bat log %ERROR% !_step! The folder "!TablesInstall_vpx_tables_src_dir!" does not exist.
			EXIT /B 1
		)
	)
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:install
	SET _step=VPXTableInstall

	REM Graceful	
	ECHO.
	ECHO  _  _  ____  _  _    ____  __   ____  __    ____  ____ 
	ECHO / )( \(  _ \( \/ )  (_  _)/ _\ (  _ \(  )  (  __)/ ___)
	ECHO \ \/ / ) __/ )  (     )( /    \ ) _ (/ (_/\ ) _) \___ \
	ECHO  \__/ (__)  (_/\_)   (__)\_/\_/(____/\____/(____)(____/
	ECHO ===============================================================================================
	ECHO.

	REM Copy contents of src table folder (which may contain nested folders) to destination
	CALL pinstall_utils.bat log %INFO% !_step! Deploying VPX table files into "%INSTALL_VPX_LOC%".
	CALL pinstall_utils.bat copydircontent !_step! "!TablesInstall_vpx_tables_src_dir!" "%INSTALL_VPX_LOC%"

	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	SET _step=VPXTableUninstall
	ECHO.
	
	CALL pinstall_utils.bat log %INFO% !_step! Table files cannot be uninstalled, but will be removed with full VPX uninstall.
	
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------
