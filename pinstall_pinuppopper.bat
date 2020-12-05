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

	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------

REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------
