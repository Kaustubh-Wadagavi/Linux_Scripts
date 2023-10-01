@echo off
setlocal enabledelayedexpansion

rem Check if a command-line argument is provided
if "%~1"=="" (
  echo Usage: %0 ^<config file^>
  echo Please provide a config file with command line parameters.
  exit /b 1
)

set "CONFIG_FILE=%~1"

rem Check if the configuration file exists
if not exist "%CONFIG_FILE%" (
  echo Error: Configuration file '%CONFIG_FILE%' not found.
  exit /b 1
)

:: Read and set variables from the configuration file
for /f "usebackq tokens=1,* delims==" %%A in ("%CONFIG_FILE%") do (
  set "%%A=%%B"
)

:: Check if the FILE parameter ends with '.csv'
if not "!FILE:~-4!"==".csv" (
  echo Error: The FILE parameter must end with '.csv'.
  exit /b 1
)

:: Define your functions and use the variables within them
:startSessions
  echo Starting Sessions...
  for /f "tokens=*" %%I in ('curl -u !USERNAME!:!PASSWORD! -X POST -H "Content-Type: application/json" -d "{""loginName"":""!USERNAME!"",""password"":""!PASSWORD!""}" "!URL!rest/ng/sessions" 2^>^&1') do (
    set "JSON_RESPONSE=%%I"
  )

  :: Use jq to extract the "token" value
  for /f "tokens=*" %%A in ('echo !JSON_RESPONSE! ^| jq -r ".token"') do (
    set "TOKEN=%%A"
  )

:getFileId
  echo Getting file ID...
  if not "!TOKEN!"=="" (
      :: Perform the POST request to get file ID
      for /f "tokens=*" %%I in ('curl -H "X-OS-API-TOKEN: !TOKEN!" -X POST --form "file=@!FILE!" "!URL!rest/ng/import-jobs/input-file" 2^>^&1') do (
        set "FILE_ID_DETAILS=%%I"
      )

      :: Use jq to extract the "fileId" value
      for /f "tokens=*" %%A in ('echo !FILE_ID_DETAILS! ^| jq -r ".fileId"') do (
        set "FILE_ID=%%A"
      )
  ) else (
      echo Authentication is not done. Please enter correct username and password.
      exit /b 1
  )

:createAndRunTheImportJob
  echo Creating and running the Import Job...
  if not "!TOKEN!" == "" if not "!FILE_ID!" == "" (
    set "JSON_DATA={"
    set "JSON_DATA=!JSON_DATA!"objectType":"!OBJECT_TYPE!","
    set "JSON_DATA=!JSON_DATA!"importType":"!IMPORT_TYPE!","
    set "JSON_DATA=!JSON_DATA!"inputFileId":"!FILE_ID!","
    set "JSON_DATA=!JSON_DATA!"dateFormat":"!DATE_FORMAT!","
    set "JSON_DATA=!JSON_DATA!"timeFormat":"!TIME_FORMAT!","
    set "JSON_DATA=!JSON_DATA!"objectParams":{"
    set "JSON_DATA=!JSON_DATA!"entityType":"!ENTITTY_TYPE!","
    set "JSON_DATA=!JSON_DATA!"formName":"kw_participant_extension","
    set "JSON_DATA=!JSON_DATA!"cpId":-1"
    set "JSON_DATA=!JSON_DATA!},"
    set "JSON_DATA=!JSON_DATA!"atomic":false"
    set "JSON_DATA=!JSON_DATA!}"
    echo !JSON_DATA!>"temp.json"

    for /F "tokens=*" %%I in ('curl -H "X-OS-API-TOKEN: !TOKEN!" -X POST -H "Content-Type: application/json" -d @temp.json "!URL!rest/ng/import-jobs" 2^>^&1') do (
        set "IMPORT_JOB_DETAILS=%%I"
    )
    del temp.json

    set "JOB_ID="
    for /f %%J in ('echo !IMPORT_JOB_DETAILS! ^| jq -r ".id"') do (
      set "JOB_ID=%%J"
    )

    if not "!JOB_ID!" == "" (
      echo "Import job created with JOB_ID: !JOB_ID!"
    ) else (
      echo "Failed to create import job."
    )
  ) else (
     echo The Input file is not accepted by Server. Please send a CSV file.
     exit /b
  )

:checkJobStatusAndDownloadReport
  echo Checking job status and downloading the report...
  for /f %%i in ('curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/%JOB_ID%" ^| jq -r ".id"') do set "JOB_ID=%%i"
  for /f %%s in ('curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/%JOB_ID%" ^| jq -r ".status"') do set "JOB_STATUS=%%s"

  if "%JOB_STATUS%"=="FAILED" (
   curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/!JOB_ID!/output" >> "failed_report_!JOB_ID!.csv"
   echo The Import Job is failed. Downloaded the report to: failed_report_!JOB_ID!.csv
  ) else if "%JOB_STATUS%"=="COMPLETED" (
   curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/!JOB_ID!/output" >> "success_report_!JOB_ID!.csv"
   echo The import job is successfully completed saved in: success_report_!JOB_ID!.csv
  ) else if "%JOB_STATUS%"=="IN_PROGRESS" (
   echo The import job is running. Please wait.....
   timeout /t 5 /nobreak
   call :checkJobStatusAndDownloadReport
  ) else if "%JOB_STATUS%"=="QUEUED" (
   echo The import job is running. Please wait.....
   timeout /t 5 /nobreak
   call :checkJobStatusAndDownloadReport
  )

endlocal
exit /b
