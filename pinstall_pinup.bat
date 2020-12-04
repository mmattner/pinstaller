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
	IF EXIST "!INSTALL_PINUP_LOC!" (
		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_PINUP_LOC%' already exists.
		EXIT /B 1
	)
	
	REM Ensure mandatory installer variables were supplied
	SET _missingCfgSetting=0
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].pinupplayer_archive !Installers_pinupplayer_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].pinuppopper_archive !Installers_pinuppopper_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	IF !_missingCfgSetting! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingCfgSetting! mandatory installer file variables were not supplied.
		EXIT /B 1
	)
	
	REM Ensure installer variables that were supplied exist
	SET _missingInstallFile=0
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_pinupplayer_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_pinuppopper_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF !_missingInstallFile! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingInstallFile! mandatory installer files were not found.
		EXIT /B 1
	)
	
	REM Unpack zip archives to confirm they can be unpacked, store results in temp directory
	REM to avoid needing to unpack a second time
	SET _badArchives=0
	IF "!Installers_pinupplayer_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_pinupplayer_archive!" "%TEMP_DIR%%pinupplayer_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF "!Installers_pinuppopper_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_pinuppopper_archive!" "%TEMP_DIR%%pinuppopper_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:install
	SET _step=PinupPrep
	
	REM Graceful
	ECHO.
	ECHO   ____  __  __ _  _  _  ____    ____  _  _  ____  ____  ____  _  _ 
	ECHO  (  _ \(  )(  ( \/ )( \(  _ \  / ___)( \/ )/ ___)(_  _)(  __)( \/ )
	ECHO   ) __/ )( /    /) \/ ( ) __/  \___ \ )  / \___ \  )(   ) _) / \/ \
	ECHO  (__)  (__)\_)__)\____/(__)    (____/(__/  (____/ (__) (____)\_)(_/
	ECHO ===============================================================================================
	ECHO.

	CALL pinstall_utils.bat log %INFO% !_step! Creating dirtectory "%INSTALL_PINUP_LOC%"
	MKDIR "%INSTALL_VPX_LOC%" > nul 2>&1

	REM Deploy Pinup Player
	SET _step=PinupPlayer
	CALL pinstall_utils.bat log %INFO% !_step! Installing Pinup Player.
	IF "!Installers_pinupplayer_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%pinupplayer_archive" "%INSTALL_PINUP_LOC%"
	)
	
	
	
	REM Setup Pinup Displays
	SET _step=ConfigureDisplays
	CALL pinstall_utils.bat log %INFO% !_step! Configuring Topper display
	IF "!PinupScreens_TopperState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO hidestopped !PinupScreens_TopperState!	)
	IF "!PinupScreens_TopperXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenXPos !PinupScreens_TopperXPos!	)
	IF "!PinupScreens_TopperYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenYPos !PinupScreens_TopperYPos!	)
	IF "!PinupScreens_TopperWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenWidth !PinupScreens_TopperWidth!	)
	IF "!PinupScreens_TopperHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenHeight !PinupScreens_TopperHeight! )
	IF "!PinupScreens_TopperRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenRotation !PinupScreens_TopperRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Configuring DMD display
	IF "!PinupScreens_DMDState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 hidestopped !PinupScreens_DMDState!	)
	IF "!PinupScreens_DMDXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenXPos !PinupScreens_DMDXPos!	)
	IF "!PinupScreens_DMDYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenYPos !PinupScreens_DMDYPos!	)
	IF "!PinupScreens_DMDWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenWidth !PinupScreens_DMDWidth!	)
	IF "!PinupScreens_DMDHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenHeight !PinupScreens_DMDHeight! )
	IF "!PinupScreens_DMDRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenRotation !PinupScreens_DMDRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Configuring Backglass display
	IF "!PinupScreens_BackglassState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 hidestopped !PinupScreens_BackglassState!	)
	IF "!PinupScreens_BackglassXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenXPos !PinupScreens_BackglassXPos!	)
	IF "!PinupScreens_BackglassYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenYPos !PinupScreens_BackglassYPos!	)
	IF "!PinupScreens_BackglassWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenWidth !PinupScreens_BackglassWidth!	)
	IF "!PinupScreens_BackglassHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenHeight !PinupScreens_BackglassHeight! )
	IF "!PinupScreens_BackglassRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenRotation !PinupScreens_BackglassRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Configuring DMD display
	IF "!PinupScreens_PlayfieldState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 hidestopped !PinupScreens_PlayfieldState!	)
	IF "!PinupScreens_PlayfieldXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenXPos !PinupScreens_PlayfieldXPos!	)
	IF "!PinupScreens_PlayfieldYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenYPos !PinupScreens_PlayfieldYPos!	)
	IF "!PinupScreens_PlayfieldWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenWidth !PinupScreens_PlayfieldWidth!	)
	IF "!PinupScreens_PlayfieldHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenHeight !PinupScreens_PlayfieldHeight! )
	IF "!PinupScreens_PlayfieldRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenRotation !PinupScreens_PlayfieldRotation! )
	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	SET _step=PinupUnininstall
	ECHO.
	CALL pinstall_utils.bat log %INFO% !_step! Removing directory "%INSTALL_PINUP_LOC%".
	RMDIR /S /Q "%INSTALL_PINUP_LOC%" > nul 2>&1
	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------
