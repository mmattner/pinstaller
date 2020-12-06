@ECHO OFF
@SETLOCAL enableextensions enabledelayedexpansion
CALL pinstall_variables.bat
SET _step=Prep

ECHO.
ECHO  ===============================================================================================
ECHO     ooooooooo.    o8o                           .             oooo  oooo                     
ECHO     `888   `Y88.  `"'                         .o8             `888  `888                     
ECHO      888   .d88' oooo  ooo. .oo.    .oooo.o .o888oo  .oooo.    888   888   .ooooo.  oooo d8b 
ECHO      888ooo88P'  `888  `888P"Y88b  d88(  "8   888   `P  )88b   888   888  d88' `88b `888""8P 
ECHO      888          888   888   888  `"Y88b.    888    .oP"888   888   888  888ooo888  888     
ECHO      888          888   888   888  o.  )88b   888 . d8(  888   888   888  888    .o  888     
ECHO     o888o        o888o o888o o888o 8""888P'   "888" `Y888""8o o888o o888o `Y8bod8P' d888b    
ECHO  ====================================================================================/ v 0.1 \==
ECHO.


REM Validate arguments and determine whether request is for an install or uninstall
SET uninstall=0
IF "%1"=="" (
     SET uninstall=0
    CALL pinstall_utils.bat log %INFO% !_step! Performing install
)
IF "%2" NEQ "" (
    ECHO Usage:
	ECHO   To perform an install: "%0%" 
	ECHO   To perform an uninstall: "%0% uninstall"
	EXIT /B 1
)
IF "%1%"=="uninstall" (
    SET uninstall=1
    CALL pinstall_utils.bat log %INFO% !_step! Performing uninstall
)


REM Ensure that 7z executable was found (set path to include default install location)
SET PATH=%PATH%;C:\Program Files\7-Zip
WHERE 7z > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    CALL pinstall_utils.bat log %INFO% !_step! 7-Zip does not appear to be installed - 7z.exe not found in path. Terminating.
    EXIT /B
) ELSE (
	CALL pinstall_utils.bat log %INFO% !_step! 7-Zip was detected
)


REM Unblock all source files
CALL pinstall_utils.bat log %INFO% !_step! Unblocking all installer Media in %INSTALL_DIR%.
PowerShell -Command "dir ""%INSTALL_DIR%"" -Recurse | Unblock-File"
IF %ERRORLEVEL% NEQ 0 (
    CALL pinstall_utils.bat log %ERROR% !_step! An error occured unblocking files in %INSTALL_DIR%. Terminating.
    EXIT /B
)


REM read the configuration file for all parametewrs. Therse aren't needed as much for an uninstall
REM but read for consistency.
ECHO.
CALL pinstall_utils.bat read_config Initialisation


REM determine whether an install or uninstall is being performed. If it in an install, call all
REM components validators to ensure everything is in order (to the extent that can be checked) and if sort
REM kick of install
IF %uninstall% == 0 (
	SET validationErrors=0
	IF !InstallSummary_VPX! == 1 (
		REM VPX Validation
		CALL pinstall_vpx.bat validate
		SET /A validationErrors=!validationErrors! + %ERRORLEVEL%
	)
	IF !InstallSummary_DOF! == 1 (
		REM DOF Validation
		CALL pinstall_dof.bat validate
		SET /A validationErrors=!validationErrors! + %ERRORLEVEL%
	)
	IF !InstallSummary_PinupPlayer! == 1 (
		REM Pinup Player Validation
		CALL pinstall_pinupplayer.bat validate
		SET /A validationErrors=!validationErrors! + %ERRORLEVEL%
	)
	IF !InstallSummary_PinupPopper! == 1 (
		REM Pinup Popper Validation
		CALL pinstall_pinuppopper.bat validate
		SET /A validationErrors=!validationErrors! + %ERRORLEVEL%
	)
	IF !InstallSummary_Tables! == 1 (
		REM Tables and Media Validation
		CALL pinstall_vpx_tables.bat validate
		SET /A validationErrors=!validationErrors! + %ERRORLEVEL%
	)
	
	REM If no errors were detected process installers in turn for enabled components
	IF !validationErrors! == 0 (
		IF !InstallSummary_VPX! == 1 ( CALL pinstall_vpx.bat install )
		IF !InstallSummary_DOF! == 1 ( CALL pinstall_dof.bat install )
		IF !InstallSummary_PinupPlayer! == 1 ( CALL pinstall_pinupplayer.bat install )
		IF !InstallSummary_PinupPopper! == 1 ( CALL pinstall_pinuppopper.bat install )
		IF !InstallSummary_Tables! == 1 (
			IF !InstallSummary_VPX! == 1 ( CALL pinstall_vpx_tables.bat install )
			IF !InstallSummary_PinupPlayer! == 1 ( CALL pinstall_pinup_tables.bat install )
		)
	) ELSE (
		CALL pinstall_utils.bat log %ERROR% Validation Validators failed, instalation halted.
	)
) ELSE ( 
	REM Perform uninstall
	IF !InstallSummary_VPX! == 1 ( CALL pinstall_vpx.bat uninstall )
	IF !InstallSummary_DOF! == 1 ( CALL pinstall_dof.bat uninstall )
	IF !InstallSummary_PinupPlayer! == 1 ( CALL pinstall_pinupplayer.bat uninstall )
	IF !InstallSummary_PinupPopper! == 1 ( CALL pinstall_pinuppopper.bat uninstall )
	IF !InstallSummary_Tables! == 1 (
		IF !InstallSummary_VPX! == 1 ( CALL pinstall_vpx_tables.bat uninstall )
		IF !InstallSummary_PinupPlayer! == 1 ( CALL pinstall_pinup_tables.bat uninstall )
	)
)

ECHO.

