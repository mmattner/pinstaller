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
REM Construct a script in %ELEVATED_SCRIPTNAME% (this is hardcoded to Temp\elevated_script.bat
REM and cannot change as the value is shared by pinstall_runelevated.vbs). The content of the
REM script is passed in as arguments to this function. Once created, determine if user has admin
REM privs or not, if they do, call the script directly, if not use UAC to request permission.
REM
REM Usage: CALL pinstall_utils.bat <some command to run>
REM -----------------------------------------------------------------------------------------------
:run_elevated
	REM populate the script
	ECHO %* > %ELEVATED_SCRIPTNAME%
		
	REM Attempt to run a non-intrusive command known to fail of not admin, to confirm
	REM if script is being run as admin or not
	C:\Windows\System32\NET FILE > nul 2>&1
	ECHO ::::%ERRORLEVEL%
	IF %ERRORLEVEL% == 0 (
		ECHO ** Already running as administrator
		CALL %ELEVATED_SCRIPTNAME%
	) ELSE (
		ECHO.
		ECHO *******************************************************************************
		ECHO *******************************************************************************
		ECHO **
		ECHO ** Not running as administrator, requesting privileges to run command:
		ECHO **   %*
		ECHO **
		ECHO *******************************************************************************
		ECHO *******************************************************************************
		ECHO.
		"%SystemRoot%\System32\WScript.exe" "pinstall_runelevated.vbs" "" ""
	)
	EXIT /B


REM -----------------------------------------------------------------------------------------------
REM Reads application INi file and creates variables for all values with names of form Section.Key
REM where 'Section' corresponds to the label found in the [<Section>] block and 'Key' represents
REM adornments.
REM 
REM Usage: CALL pinstall_utils.bat read_config
REM -----------------------------------------------------------------------------------------------
:read_config
	SET _label=%~1
	FOR /F "usebackq delims=" %%a in ("!INIFILE!") do (
		SET _line=%%a
		IF "x!_line:~0,1!"=="x[" (
			SET _section=!_line!
			SET _section=!_section:[=!
			SET _section=!_section:]=!
		) ELSE IF "!_line:~0,1!" NEQ "#" (
			FOR /F "tokens=1,2 delims==" %%b in ("!_line!") do (
				SET _key=%%b
				SET _value=%%c
				CALL :log %INFO% !_label! Set !_section!.!_key! = !_value!
				SET !_section!_!_key!=!_value!
			)
		)
	)
	EXIT /B	
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Check that a variable has been assigned a value.
REM Usage: CALL pinstall_utils.bat check_variable_set <label> <variablename> <variablevalue>"
REM Where:
REM     <label>: Is a string prefix used in log messages
REM     <variablename>: Is the name of the variable being checked
REM     <variablevalue>: Is the value assigned to the variable
REM Returns ERRORCODE 0 if variable was set, 1 otherwise
REM -----------------------------------------------------------------------------------------------
:check_variable_set
	SET _label=%~1
	SET _variablename=%~2
	SET _variablevalue=%~3
	IF "%_variablevalue%" == "" (
		CALL :log %ERROR% %_label% Mandatory variable '%_variablename%' not supplied in INI file
		EXIT /B 1
	) ELSE (
		CALL :log %INFO% %_label% Mandatory variable '%_variablename%' was supplied in INI file
	)
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Check that a requested file has been found.
REM Usage: CALL pinstall_utils.bat check_file_exists <label> <filename>
REM Where:
REM     <label>: Is a string prefix used in log messages
REM     <filename>: Is the name of the file being checked (relative to parent installer directory)
REM Returns ERRORCODE 0 if the file was found, 1 otherwise
REM -----------------------------------------------------------------------------------------------
:check_file_exists
	SET _label=%~1
	SET _filename=%~2
	IF EXIST "%_filename%" (
		CALL :log %INFO% %_label% Located install-file: %_filename%
		EXIT /B 0
	) ELSE (
		CALL :log %ERROR% %_label% Requested install-file %_filename% not located
		EXIT /B 1
	)
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:unzip
	SET _label=%~1
	SET _filename=%~2
	SET _destination=%3
	7z x %_filename% -o%_destination% -y >nul 2>&1
	SET _result=%ERRORLEVEL%
	SET _returnval=0
	IF %_result% GTR 0 (
		CALL :log %ERROR% %_label% Failed to unzip %_filename%
		EXIT /B 1
	)
	CALL :log %INFO% %_label% Unzipped %_filename% to %_destination%
	EXIT /B 0
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM TODO
:copydircontent
	SETLOCAL
	SET _label=%~1
	SET _sourcedir=%~2
	SET _destdir=%3

	IF EXIST "%_sourcedir%" (
		REM archive has already been unzipped to "%temp_dir%%sourcedir%", copy the contents
		XCOPY /S /Y "%_sourcedir%\*" %_destdir% > nul 2>&1
		CALL :log %INFO% %_label% Applied "%_sourcedir%" patch.
	) ELSE (
		CALL :log %INFO% %_label% No "%_sourcedir%" required to apply, continuing.
	)
	ENDLOCAL
	EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Look for a Key in a standard ini file section and if found update it.
REM Ini files are expected to contain multiple sections, with key=value pairs within each section.
REM Note that sections are unique within the file and keys are unique within their section. ie:
REM [Block 1]
REM Key1=Value1
REM Key2=Value2
REM [Block2]
REM Key3=Value3
REM Key1=ThisIsOkAsItsANewBlock
REM
REM Usage:    CALL pinstall_utils.bat <label> <inifile> <section> <key> <value>
REM Where:
REM     <label>: Is a string prefix used in log messages
REM    <inifile>: The ini file to update
REM    <section>: Section block in th ini file, ie '[BLOCKNAME]' (without braces)
REM    <key>: The attribute within the selected section to update
REM    <value>: The value to assign to the key, ie KEY=VALUE
:updateinifile
	SETLOCAL
	SET _label=%1%
	SET _cfg_file=%2%
	SET _section=%3%
	SET _section=!_section:"=!
	SET _key=%4%
	SET _key=!_key:"=!
	SET _value=%5%
	SET _value=!_value:"=!
	SET _tmp_file=%_cfg_file%.tmp

	REM Flag set to 1 when parser is on the block marked by '[%_section%]'
	SET _section_matches=0
	REM Set to 1 for the first file being processed and 0 otherwise
	SET _first_line=1
	REM The last line read, and in turn the next line to add        
	SET _line_to_add=

	FOR /F "tokens=1* delims=]" %%a in ('type %_cfg_file% ^| find /V /N ""') do (
		SET _line=%%b

		REM New file lines are added in a lagging pattern, ie each iteration the previous iterations
		REM source line is added, this is done because we need to make the final iteration a special
		REM case and this is simplere than line counting and parsing. The special case is to strip
		REM a final trailing newline. As such this check just skips over the first iteration to avoid
		REM adding a 'previous line' that doesn't exist.
		IF !_first_line! == 0 (
			IF "!_line_to_add!" == "" (
				ECHO.>> %_tmp_file%
			) ELSE (
				ECHO !_line_to_add!>> %_tmp_file%
			)
		)
		SET _first_line=0
		
		REM for each line check if its the start of a new section, if it is, check if the section is the
		REM section of interest, if the line is not a new section, look for a KEY=VALUE entry where KEY
		REM matches the required KEY to update.
		SET _key_matches=0
		IF "x!_line:~0,1!"=="x[" (
			IF "!_line!"=="[!_section!]" (
				SET _section_matches=1
			) ELSE (
				SET _section_matches=0
			)
		) ELSE IF "!_line:~0,1!" NEQ "#" (
			IF !_section_matches!==1 (
				FOR /F "tokens=1,2 delims==" %%b in ("!_line!") do (
					SET _file_key=%%b
					SET _file_key=!_file_key: =!
					IF "%_key%"=="!_file_key!" (
						SET _key_matches=1
					)
					SET _file_key=%%b
					SET _file_val=%%c
				)
			)
		)
		
		REM Store the next line to add, which is either a copy of the source line, or if we have found our
		REM target KEY, it will be a generated line with the new requested value set.
		SET _line_to_add=!_line!
		IF !_key_matches!==1 (
			REM set the new line, try to preserve any original formatting around the '='
			SET _line_to_add=!_file_key!=%_value%
			IF " " == "!_file_val:~0,1!" ( SET _line_to_add=!_file_key!= %_value% )
			CALL :log %INFO% %_label% "Updated "!_cfg_file!", SET [!_section!]: !_line_to_add!"
		)
	)

	REM Add the final line without a trailing carriage return, then move the file back over the top of
	REM the source config file.
	ECHO | SET /P="!_line_to_add!">>%_tmp_file%
	MOVE /Y %_tmp_file% %_cfg_file% > nul 2>&1
	ENDLOCAL
	EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Take the supplied integer and convert to a dword suitable for registry. The result is stored in
REM the global variable __dec2dwordresult.
REM
REM Usage:    CALL :dec2dword <integer>
REM            .... and then in calling proc echo !__dec2dwordresult!
REM Where:
REM    <integer>: Is an integer to convert to hex
:dec2dword
	SET _dec=%~1
	FOR /F "tokens=* USEBACKQ" %%F IN (`PowerShell -Command "$hex=\"{0:x}\" -f %_dec%; $hex.PadLeft(8, '0')"`) DO ( SET _result=%%F )
	SET __dec2dwordresult=!_result!
	EXIT /B
REM -----------------------------------------------------------------------------------------------


REM -----------------------------------------------------------------------------------------------
REM Adds a log message with given adornments.
REM Usage: CALL :log <level> <step> <msg>
REM Where:
REM     <level>: Integer log level indicatinh severity of message 
REM     <label>: Is a string prefix to allow grouping of messages
REM     <msg>: Is message to display
:log
	SETLOCAL
	SET _level=%~1
    SET _label=%~2
	FOR /f "tokens=2,* delims= " %%a in ("%*") DO SET _msg=%%b
	SET _prefix=UNKNOWN: 
	IF "%_level%" == "%DEBUG%" (
		SET _prefix=DEBUG  : 
	) ELSE IF "%_level%" == "%INFO%" (
		SET _prefix=INFO   : 
	) ELSE IF "%_level%" == "%WARN%" (
		SET _prefix=WARN   : 
	) ELSE IF "%_level%" == "%ERROR%" (
		SET _prefix=ERROR  : 
	)
	ECHO !_prefix!%_label%: %_msg%
	EXIT /B
	ENDLOCAL
REM -----------------------------------------------------------------------------------------------