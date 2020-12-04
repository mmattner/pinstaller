@ECHO OFF

REM -----------------------------------------------------------------------------------------------
REM This batch file is a collection of functions which are called by passing the function name and
REM required parameters to the batch, ie, to call the :validate function passing it two arguments
REM with values 'a' and 'b', the call to the batch file would be:
REM     "pinstall_vpx.bat validate 'a' 'b'"
REM -----------------------------------------------------------------------------------------------

SET b2s_registry_path=HKEY_CURRENT_USER\SOFTWARE\B2S
set vpx_registry_path=HKEY_CURRENT_USER\SOFTWARE\Visual Pinball
set vpinmame_registry_path=HKEY_CURRENT_USER\SOFTWARE\Freeware\Visual PinMame


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
	SET _step=VPXValidate
	ECHO.

	REM Ensure VPX install doesn't already appear to exist
	IF EXIST "!INSTALL_VPX_LOC!" (
		CALL pinstall_utils.bat log %ERROR% !_step! The folder '%INSTALL_VPX_LOC%' already exists.`Terminating.
		EXIT /B 1
	)

	REM Ensure mandatory installer variables were supplied
	SET _missingCfgSetting=0
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].vpx_installer !Installers_vpx_installer!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	CALL pinstall_utils.bat check_variable_set !_step! [Installers].sambuild_archive !Installers_sambuild_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	CALL pinstall_utils.bat check_variable_set !_step! [VPXInstall].freezy_patch_archive !Installers_freezy_patch_archive!
	SET /A _missingCfgSetting = !_missingCfgSetting! + %ERRORLEVEL%
	IF !_missingCfgSetting! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingCfgSetting! mandatory installer file variables were not supplied.
		EXIT /B 1
	)
	
	REM Ensure installer variables that were supplied exist
	SET _missingInstallFile=0
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_vpx_installer!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF "!Installers_vpx_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_vpx_patch_archive!"
		SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	)
	IF "!Installers_b2s_cust_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_b2s_cust_patch_archive!"
		SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	)
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_sambuild_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_freezy_patch_archive!"
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF "!Installers_flex_dmd_archive!" NEQ "" (
		CALL pinstall_utils.bat check_file_exists !_step! "%INSTALL_DIR%!Installers_flex_dmd_archive!"
		SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	)
	SET /A _missingInstallFile = !_missingInstallFile! + %ERRORLEVEL%
	IF !_missingInstallFile! GTR 0 (
		CALL pinstall_utils.bat log %ERROR% !_step! !_missingInstallFile! mandatory installer files were not found.
		EXIT /B 1
	)
	
	REM Unpack zip archives to confirm they can be unpacked, store results in temp directory
	REM to avoid needing to unpack a second time
	SET _badArchives=0
	IF "!Installers_vpx_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_vpx_patch_archive!" "%TEMP_DIR%%vpx_patch_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF "!Installers_b2s_cust_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_b2s_cust_patch_archive!" "%TEMP_DIR%%b2s_cust_patch_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF "!Installers_sambuild_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_sambuild_archive!" "%TEMP_DIR%%sambuild_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF "!Installers_freezy_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_freezy_patch_archive!" "%TEMP_DIR%%freezy_patch_archive"
		SET /A _badArchives=!_badArchives! + %ERRORLEVEL%
	)
	IF "!Installers_flex_dmd_archive!" NEQ "" (
		CALL pinstall_utils.bat unzip !_step! "%INSTALL_DIR%!Installers_flex_dmd_archive!" "%TEMP_DIR%%flex_dmd_archive"
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
	SET _step=VPXInstall

	REM Graceful
	ECHO.
	ECHO   _  _  __  ____  _  _   __   __      ____  __  __ _  ____   __   __    __   
	ECHO  / )( \(  )/ ___)/ )( \ / _\ (  )    (  _ \(  )(  ( \(  _ \ / _\ (  )  (  )  
	ECHO  \ \/ / )( \___ \) \/ (/    \/ (_/\   ) __/ )( /    / ) _ (/    \/ (_/\/ (_/\
	ECHO   \__/ (__)(____/\____/\_/\_/\____/  (__)  (__)\_)__)(____/\_/\_/\____/\____/
	ECHO ===============================================================================================
	ECHO.

	REM Create initial Visual Pinball folder (the app will be installed over the top), and generate
	REM initial B2S screenres.txt file which uses documented dimensions.
	CALL pinstall_utils.bat log %INFO% !_step! Creating dirtectory "%INSTALL_VPX_TABLES_LOC%"
	MKDIR "%INSTALL_VPX_LOC%" > nul 2>&1
	MKDIR "%INSTALL_VPX_TABLES_LOC%" > nul 2>&1
	
	CALL pinstall_utils.bat log %INFO% !_step! Creating "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_playfield_width! > "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_playfield_height! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_backglass_width! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_backglass_height! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_backglass_screen! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_backglass_x! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_backglass_y! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_led_width! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_led_height! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_led_x! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_led_y! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"
	ECHO !GraphicsConfiguration_led_flip! >> "%INSTALL_VPX_TABLES_LOC%ScreenRes.txt"

	REM Perform standard VPX install
	CALL pinstall_utils.bat log %INFO% !_step! Performing initial VPX installation.
	CALL "%INSTALL_DIR%!Installers_vpx_installer!" > nul 2>&1
	ECHO.

	REM Apply any VPX patches
	SET _step=VPXPatchUpdates
	CALL pinstall_utils.bat log %INFO% !_step! Applying VPX patches.
	IF "!Installers_vpx_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%vpx_patch_archive" "%INSTALL_VPX_LOC%"
	)
	IF "!Installers_b2s_cust_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%b2s_cust_patch_archive" "%INSTALL_VPX_TABLES_LOC%"
	)
	IF "!Installers_sambuild_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%sambuild_archive" "%INSTALL_VPX_MAME_LOC%"
	)
	IF "!Installers_freezy_patch_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%freezy_patch_archive" "%INSTALL_VPX_MAME_LOC%"
	)
	IF "!Installers_flex_dmd_archive!" NEQ "" (
		CALL pinstall_utils.bat copydircontent !_step! "%TEMP_DIR%flex_dmd_archive" "%INSTALL_VPX_MAME_LOC%"
	)
	ECHO.
	
	REM Update DmdDevice.ini to reflect type of DMD being used
	SET _step=VPXDMDDeviceUpdate
	CALL pinstall_utils.bat log %INFO% !_step! Performing updates to DmdDevice.ini based on [DMDDeviceConfig] block.
	FOR /F "usebackq delims=" %%a IN ("!INIFILE!") DO (
		SET _iniline=%%a
		IF "x!_iniline:~0,1!"=="x[" (
			SET _section=!_iniline!
		) ELSE IF "!_iniline:~0,1!" NEQ "#" (
			FOR /F "tokens=1,2 delims==" %%b IN ("!_iniline!") DO (
				SET _inikey=%%b
				SET _inivalue=%%c
				IF "[DMDDeviceConfig]"=="!_section!" (
					REM This is special case where the key is configured as a '_' seperated name which corresponds
					REM to <section>_<key> as found in DMDDevice.ini allowing any settings in there to be overridden				
					FOR /F "tokens=1,2 delims=_" %%a IN ("!_inikey!") DO (
						CALL pinstall_utils.bat updateinifile !_step! "%INSTALL_VPX_MAME_LOC%DmdDevice.ini" "%%a" %%b !_inivalue!
					)
				)
			)
		)
	)
	ECHO.
	
	REM Prepeare B2STableSettings.xml
	CALL pinstall_utils.bat log %INFO% !_step! Prepare initial "%INSTALL_VPX_TABLES_LOC%B2STableSettings.xml".
	ECHO ^<B2STableSettings^> > "%INSTALL_VPX_TABLES_LOC%B2STableSettings.xml"
	ECHO ^<ArePluginsOn^>1^</ArePluginsOn^> >> "%INSTALL_VPX_TABLES_LOC%B2STableSettings.xml"
	ECHO ^</B2STableSettings^> >> "%INSTALL_VPX_TABLES_LOC%B2STableSettings.xml"

	REM Generate registry entires for Visual Pinball based on user seiings in ini file
	SET _step=VPXRegistryUpdate
	
	ECHO Windows Registry Editor Version 5.00 > %TEMP_DIR%VisualPinball.reg"
	ECHO. >> %TEMP_DIR%VisualPinball.reg"
	ECHO [%vpx_registry_path%\Controller] >> %TEMP_DIR%VisualPinball.reg"
	ECHO "ForceDisableB2S"=dword:00000000 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFContactors"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFKnocker"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFChimes"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFBell"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFGear"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFShaker"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFFlippers"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFTargets"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO "DOFDropTargets"=dword:00000002 >> %TEMP_DIR%VisualPinball.reg"
	ECHO. >> %TEMP_DIR%VisualPinball.reg"

	
	ECHO [%vpx_registry_path%\VP10\Player] >> %TEMP_DIR%VisualPinball.reg"
	REM Video/Graphics Options: Display setting (width)
	CALL pinstall_utils.bat dec2dword !GraphicsConfiguration_playfield_width!
	ECHO "Width"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].Width=!__dec2dwordresult!
	REM Video/Graphics Options: Display setting (height)
	CALL pinstall_utils.bat dec2dword !GraphicsConfiguration_playfield_height!
	ECHO "Height"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].Height=!__dec2dwordresult!
	REM Video/Graphics Options: Display setting (Refresh Hz)
	CALL pinstall_utils.bat dec2dword !GraphicsConfiguration_playfield_refresh_hz!
	ECHO "RefreshRate"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].RefreshRate=!__dec2dwordresult!
	REM Video/Graphics Options: Use always FS backdrop settings (Cabinet/Rotated Screen usage)
	CALL pinstall_utils.bat dec2dword 1
	ECHO "BGSet"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].BGSet=!__dec2dwordresult!
	REM Video/Graphics Options: Force exclusive Fullscreen mode
	CALL pinstall_utils.bat dec2dword !GraphicsConfiguration_playfield_exclusive_fullscreen!
	ECHO "FullScreen"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].FullScreen=!__dec2dwordresult!

	REM Loop Through any settigns in [VPXPlayerRegistryOverrides] section of INI file. These will
	REM be added to %VPX_PLAYER_REGISTRY% of registry, allowing for overrides of game settings such as
	REM key codes. Avoid resettings values set above. Only decimal values accepted.
	FOR /F "usebackq delims=" %%a IN ("!INIFILE!") DO (
		SET _line=%%a
		IF "x!_line:~0,1!"=="x[" (
			SET _section=!_line!
		) ELSE IF "!_line:~0,1!" NEQ "#" (
			FOR /F "tokens=1,2 delims==" %%b IN ("!_line!") DO (
				SET _key=%%b
				SET _value=%%c
				IF "[VPXPlayerRegistryOverrides]"=="!_section!" (
					CALL pinstall_utils.bat dec2dword !_value!
					ECHO "!_key!"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
					CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpx_registry_path%\VP10\Player].!_key!=!__dec2dwordresult!
				)
			)
		)
	)
	
	ECHO. >> %TEMP_DIR%VisualPinball.reg"
	ECHO [%b2s_registry_path%] >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat dec2dword 1
	ECHO "Plugins"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%b2s_registry_path%].Plugins=!__dec2dwordresult!

	
	ECHO. >> %TEMP_DIR%VisualPinball.reg"
	ECHO [%vpinmame_registry_path%\default] >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat dec2dword 1
	ECHO "cabinet_mode"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].cabinet_mode=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 50
	ECHO "dmd_antialias"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].dmd_antialias=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 1
	ECHO "dmd_colorize"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].dmd_colorize=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "dmd_compact"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].dmd_compact=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "dmd_doublesize"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].dmd_doublesize=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 100
	ECHO "dmd_opacity"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].dmd_opacity=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "resampling_quality"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].resampling_quality=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 48000
	ECHO "samplerate"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].samplerate=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 1
	ECHO "showpindmd"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].showpindmd=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "showwindmd"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].showwindmd=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "sound_mode"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].sound_mode=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "synclevel"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].synclevel=!__dec2dwordresult!
	CALL pinstall_utils.bat dec2dword 0
	ECHO "vgmwrite"=dword:!__dec2dwordresult! >> %TEMP_DIR%VisualPinball.reg"
	CALL pinstall_utils.bat log %INFO% !_step! Setting [%vpinmame_registry_path%\default].vgmwrite=!__dec2dwordresult!

	CALL pinstall_utils.bat log %INFO% !_step! Updating regsitry with generated settings.
	%TEMP_DIR%VisualPinball.reg
	ECHO.
	
	SET _step=FlexDMD
	IF "!Installers_flex_dmd_archive!" NEQ "" (
		CALL pinstall_utils.bat log %INFO% !_step! Launching FlexDMD GUI to allow registration of FlexDMD
		CALL "%INSTALL_VPX_MAME_LOC%FlexDMDUI.exe" > nul 2>&1
	)

	EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:uninstall
	SET _step=VPXUninstall
	ECHO.

	REM Perform main uninstall, VPX uinstaller doesn't clean up directory or registry properly so
	REM fix this as well
	CALL pinstall_utils.bat log %INFO% !_step! Uninstalling VPX using "%VPX_UNINSTALL%".
	IF EXIST "%VPX_UNINSTALL%" (
		CALL "%VPX_UNINSTALL%"
	)
	CALL pinstall_utils.bat log %INFO% !_step! Removing directory "%INSTALL_VPX_LOC%".
	RMDIR /S /Q "%INSTALL_VPX_LOC%" > nul 2>&1
	CALL pinstall_utils.bat log %INFO% !_step! Removing VPX and B2S registry settings.
	REG DELETE "%b2s_registry_path%" /F > nul 2>&1
	REG DELETE "%vpx_registry_path%" /F > nul 2>&1
    EXIT /B
REM -----------------------------------------------------------------------------------------------


