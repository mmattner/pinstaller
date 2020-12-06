REM Installer log error levels
SET DEBUG=0
SET INFO=1
SET WARN=2
SET ERROR=3

REM Main INI File
SET INIFILE=pinstall.ini

REM Packaged applications
SET SQLLITE=Tools\sqlite\sqlite3.exe

REM Installer source folders
SET DIRBASE=InstallPack\
SET INSTALL_DIR=%DIRBASE%Installers\
SET DOF_CONFIG_DIR=%DIRBASE%DOFConfig\
SET DOF_CONFIG_ARCHIVE=%DOF_CONFIG_DIR%directoutputconfig.zip
SET DOF_CONFIG_CABINET=%DOF_CONFIG_DIR%cabinet.xml
SET DOF_CONFIG_GLOBALB2S_CONFIG=%DOF_CONFIG_DIR%GlobalConfig_B2SServer.xml
SET TEMP_DIR=Temp\
SET ELEVATED_SCRIPTNAME=%TEMP_DIR%\elevated_script.bat

REM Destination folders
SET INSTALLBASE_LOC=C:\

REM VPX Installation locations
SET INSTALL_VPX_LOC=%INSTALLBASE_LOC%Visual Pinball\
SET INSTALL_VPX_TABLES_LOC=%INSTALL_VPX_LOC%Tables\
SET INSTALL_VPX_B2S_PLUGINS_LOC=%INSTALL_VPX_TABLES_LOC%Plugins\
SET INSTALL_VPX_MAME_LOC=%INSTALL_VPX_LOC%VPinMAME\
SET VPX_UNINSTALL=%INSTALL_VPX_LOC%uninstall.exe

REM DOF Installation locations
SET INSTALL_DOF_LOC=%INSTALLBASE_LOC%DirectOutput\

REM PinUp System Installation locations
SET INSTALL_PINUP_LOC=%INSTALLBASE_LOC%PinUpSystem\
SET INSTALL_PINUP_PUPVIDEOS_LOC=%INSTALL_PINUP_LOC%PUPVideos\


REM PINUP Related
SET PUPDATABASE=%INSTALL_PINUP_LOC%PUPDatabase.db

REM Mapping of Pinup display names to INFO
SET TopperName=INFO
SET DMDName=INFO1
SET BackglassName=INFO2
SET PlayfieldName=INFO3
SET MusicName=INFO4
SET ApronFullDMDName=INFO5
SET GameSelectName=INFO6
SET LoadingName=INFO7
SET Other2Name=INFO8
SET GameInfoName=INFO9
SET GameHelpName=INFO10

REM Mapping of Pinup key uniqueIDs as found in the table: PinUPFunctions in PUPDatabase.db
REM To read (using sqllite execute command: "SELECT * FROM 'PinUPFunctions'"
SET GamePriorId=1
SET GameNextId=2
SET ListNextId=3
SET ListPriorId=4
SET PagePriorId=5
SET PageNextId=6
SET GameStartId=7
SET HomeMenuId=8
SET GameMenuId=9
SET GameInfoFlyerId=10
SET MenuSystemExitId=11
SET SystemShutdownId=12
SET MenuReturnId=13
SET MenuSelectId=14
SET ExitEmulatorsId=15
SET SystemMenuId=16
SET GameHelpId=17
SET RecordStartStopId=18
SET ShowOtherId=19
SET PauseGameId=20
SET InGameScriptId=21
SET PlayOnlyModeId=22