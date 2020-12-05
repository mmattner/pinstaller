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
	SET _step=PinupPlayer
	
	REM Graceful
	ECHO.
	ECHO   ____  __  __ _  _  _  ____    ____  _  _  ____  ____  ____  _  _ 
	ECHO  (  _ \(  )(  ( \/ )( \(  _ \  / ___)( \/ )/ ___)(_  _)(  __)( \/ )
	ECHO   ) __/ )( /    /) \/ ( ) __/  \___ \ )  / \___ \  )(   ) _) / \/ \
	ECHO  (__)  (__)\_)__)\____/(__)    (____/(__/  (____/ (__) (____)\_)(_/
	ECHO ===============================================================================================
	ECHO.

	CALL pinstall_utils.bat log %INFO% !_step! Creating application directory "%INSTALL_PINUP_LOC%".
	MKDIR "%INSTALL_VPX_LOC%" > nul 2>&1

	REM Deploy Pinup Player
	CALL pinstall_utils.bat log %INFO% !_step! Installing Pinup Player archive: "!Installers_pinupplayer_archive!".
	IF "!Installers_pinupplayer_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%pinupplayer_archive" "%INSTALL_PINUP_LOC%"
	)
	ECHO.
	
	REM Setup Pinup Displays
	SET _step=ConfigureDisplays
	CALL pinstall_utils.bat log %INFO% !_step! Configuring all defined PinupScreens.
	CALL pinstall_utils.bat log %INFO% !_step! Note: leaving a screens TopperState config blank disables its update.
	CALL pinstall_utils.bat log %INFO% !_step! Set Topper display: State=!PinupScreens_TopperState! ^
Pos=(!PinupScreens_TopperXPos! !PinupScreens_TopperYPos!) ^
Size=(!PinupScreens_TopperWidth!x!PinupScreens_TopperHeight!) Rotation=!PinupScreens_TopperRotation!
	IF "!PinupScreens_TopperState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO hidestopped !PinupScreens_TopperState!	)
	IF "!PinupScreens_TopperXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenXPos !PinupScreens_TopperXPos!	)
	IF "!PinupScreens_TopperYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenYPos !PinupScreens_TopperYPos!	)
	IF "!PinupScreens_TopperWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenWidth !PinupScreens_TopperWidth!	)
	IF "!PinupScreens_TopperHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenHeight !PinupScreens_TopperHeight! )
	IF "!PinupScreens_TopperRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO ScreenRotation !PinupScreens_TopperRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Set DMD display: State=!PinupScreens_DMDState! ^
Pos=(!PinupScreens_DMDXPos! !PinupScreens_DMDYPos!) ^
Size=(!PinupScreens_DMDWidth!x!PinupScreens_DMDHeight!) Rotation=!PinupScreens_DMDRotation!
	IF "!PinupScreens_DMDState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 hidestopped !PinupScreens_DMDState!	)
	IF "!PinupScreens_DMDXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenXPos !PinupScreens_DMDXPos!	)
	IF "!PinupScreens_DMDYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenYPos !PinupScreens_DMDYPos!	)
	IF "!PinupScreens_DMDWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenWidth !PinupScreens_DMDWidth!	)
	IF "!PinupScreens_DMDHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenHeight !PinupScreens_DMDHeight! )
	IF "!PinupScreens_DMDRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO1 ScreenRotation !PinupScreens_DMDRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Set Backglass display: State=!PinupScreens_BackglassState! ^
Pos=(!PinupScreens_BackglassXPos! !PinupScreens_BackglassYPos!) ^
Size=(!PinupScreens_BackglassWidth!x!PinupScreens_BackglassHeight!) Rotation=!PinupScreens_BackglassRotation!
	IF "!PinupScreens_BackglassState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 hidestopped !PinupScreens_BackglassState!	)
	IF "!PinupScreens_BackglassXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenXPos !PinupScreens_BackglassXPos!	)
	IF "!PinupScreens_BackglassYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenYPos !PinupScreens_BackglassYPos!	)
	IF "!PinupScreens_BackglassWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenWidth !PinupScreens_BackglassWidth!	)
	IF "!PinupScreens_BackglassHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenHeight !PinupScreens_BackglassHeight! )
	IF "!PinupScreens_BackglassRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO2 ScreenRotation !PinupScreens_BackglassRotation! )

	CALL pinstall_utils.bat log %INFO% !_step! Set DMD display: State=!PinupScreens_PlayfieldState! ^
Pos=(!PinupScreens_PlayfieldXPos! !PinupScreens_PlayfieldYPos!) ^
Size=(!PinupScreens_PlayfieldWidth!x!PinupScreens_PlayfieldRotation!) Rotation=!PinupScreens_PlayfieldRotation!
	IF "!PinupScreens_PlayfieldState!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 hidestopped !PinupScreens_PlayfieldState!	)
	IF "!PinupScreens_PlayfieldXPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenXPos !PinupScreens_PlayfieldXPos!	)
	IF "!PinupScreens_PlayfieldYPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenYPos !PinupScreens_PlayfieldYPos!	)
	IF "!PinupScreens_PlayfieldWidth!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenWidth !PinupScreens_PlayfieldWidth!	)
	IF "!PinupScreens_PlayfieldHeight!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenHeight !PinupScreens_PlayfieldHeight! )
	IF "!PinupScreens_PlayfieldRotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" INFO3 ScreenRotation !PinupScreens_PlayfieldRotation! )
	ECHO.
	
	REM copy PUPDMD files into VPX VpinMAME
	SET _step=AddVpinMAMEPupDMD	
	IF EXIST "!INSTALL_VPX_MAME_LOC!" (
		CALL pinstall_utils.bat log %INFO% !_step! Adding PUPDMD Control to VPX VpinMAME.
		CALL pinstall_utils.bat copydircontent !_step! "%INSTALL_PINUP_LOC%PinUPPlayerVPinMame" "%INSTALL_VPX_MAME_LOC%"
		
		REM Register PUMDMD controller
		CALL pinstall_utils.bat log %INFO% !_step! Registering PUPDMD Controller with VpinMAME. [REQUIRES ADMIN PRIVS]
		CALL pinstall_utils.bat run_elevated "!INSTALL_VPX_MAME_LOC!PUPDMDControl.exe" /regserver
	) ELSE (
		CALL pinstall_utils.bat log %ERROR% !_step! Target !INSTALL_VPX_MAME_LOC! does not exist - PUPDMD cannot be deployed.
	)
	ECHO.
	
	REM Create B2S driver softlink
	SET _step=AddB2SPupDriver
	IF EXIST "!INSTALL_VPX_TABLES_LOC!" (
		IF NOT EXIST "!INSTALL_VPX_B2S_PLUGINS_LOC!" (
			CALL pinstall_utils.bat log %INFO% !_step! Creating B2S Plugins file at "!INSTALL_VPX_B2S_PLUGINS_LOC!".
			MKDIR "!INSTALL_VPX_B2S_PLUGINS_LOC!"
		)
		CALL pinstall_utils.bat log %INFO% !_step! Including softlink to PinUp B2S driver in VPX Tables\Plugins. [REQUIRES ADMIN PRIVS]
		CALL pinstall_utils.bat run_elevated mklink /D "%INSTALL_VPX_B2S_PLUGINS_LOC%PinUPPlayerB2SDriver" "%INSTALL_PINUP_LOC%PinUPPlayerB2SDriver"
	) ELSE (
		CALL pinstall_utils.bat log %ERROR% !_step! Target !INSTALL_VPX_TABLES_LOC! does not exist - cannot at B2S plugins.
	)
	
	REM Enable PINUP in DMDDevice.ini
	IF EXIST "%INSTALL_VPX_MAME_LOC%DmdDevice.ini" (
		CALL pinstall_utils.bat log %INFO% !_step! Enabling pinup display in "%INSTALL_VPX_MAME_LOC%DmdDevice.ini".
		CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_VPX_MAME_LOC%DmdDevice.ini" pinup enabled true
	) ELSE (
		CALL pinstall_utils.bat log %ERROR% !_step! "%INSTALL_VPX_MAME_LOC%DmdDevice.ini" not found, VPX does not appear to be correctly set up.
	)
	
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
