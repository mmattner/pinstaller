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
	CALL :updatescreenpos !_step! Topper PinupScreens_Topper
	CALL :updatescreenpos !_step! DMD PinupScreens_DMD
	CALL :updatescreenpos !_step! Backglass PinupScreens_Backglass
	CALL :updatescreenpos !_step! Playfield PinupScreens_Playfield
	CALL :updatescreenpos !_step! Music PinupScreens_Music
	CALL :updatescreenpos !_step! ApronFullDMD PinupScreens_ApronFullDMD
	CALL :updatescreenpos !_step! GameSelect PinupScreens_GameSelect
	CALL :updatescreenpos !_step! Loading PinupScreens_Loading
	CALL :updatescreenpos !_step! Other2 PinupScreens_Other2
	CALL :updatescreenpos !_step! GameInfo PinupScreens_GameInfo
	CALL :updatescreenpos !_step! GameHelp PinupScreens_GameHelp
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
REM Helper function to set screen characteristics in the PinUpPlayer.ini file.
REM 
REM Usage: CALL :updatescreenpos <label> <screenname> <configprefix>
REM     <label>: Is a string prefix used in log messages
REM     <variablename>: Used for logging only, the pretty name of the display being updated
REM     <variablevalue>: Screennames prefix used in variables within pinstall.ini, ie for topper
REM                      display, variables include TopperState, TopperXPos etc, hence the prefix
REM                      is 'Topper'.
REM -----------------------------------------------------------------------------------------------
:updatescreenpos
	SET _label=%~1
	SET _name=%~2
	SET _scr=%~3
	
	CALL pinstall_utils.bat log %INFO% !_label! Set %_name% display: State=!%_scr%State! Pos=(!%_scr%XPos! !%_scr%YPos!) Size=(!%_scr%Width!x!%_scr%Height!) Rotation=!%_scr%Rotation!
	ECHO "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! hidestopped !%_scr%State!
	IF "!%_scr%State!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! hidestopped !%_scr%State!	)
	IF "!%_scr%XPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! ScreenXPos !%_scr%XPos!	)
	IF "!%_scr%YPos!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! ScreenYPos !%_scr%YPos!	)
	IF "!%_scr%Width!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! ScreenWidth !%_scr%Width!	)
	IF "!%_scr%Height!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! ScreenHeight !%_scr%Height! )
	IF "!%_scr%Rotation!" NEQ "" ( CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_PINUP_LOC%PinUpPlayer.ini" !%_name%Name! ScreenRotation !%_scr%Rotation! )
	EXIT /B

REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	SET _step=PinupUnininstall
	ECHO.
	CALL pinstall_utils.bat log %INFO% !_step! Removing directory "%INSTALL_PINUP_LOC%".
	RMDIR /S /Q "%INSTALL_PINUP_LOC%" > nul 2>&1
	
    EXIT /B 0
REM -----------------------------------------------------------------------------------------------
