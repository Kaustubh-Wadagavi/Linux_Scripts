@echo off
setlocal enabledelayedexpansion

:: Main function
:main
if not "%~1"=="" (
    call :startSessions
    call :getFileId
    call :createAndRunTheImportJob
    call :checkJobStatusAndDownloadReport
) else (
    echo Usage: %~nx0 ^<config file^>
    echo Please provide a config file with command line parameters.
    exit /b 1
)

:: Function to check job status and download report
:checkJobStatusAndDownloadReport
if not "%TOKEN%"=="" (
    curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/"
    set "CURRENT_RUNNING_JOB="
    for /f "delims=" %%i in ('curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/" ^| jq "max_by(.id)") do set "CURRENT_RUNNING_JOB=%%i"
    set "JOB_ID=!CURRENT_RUNNING_JOB.id!"
    set "JOB_STATUS=!CURRENT_RUNNING_JOB.status!"
) else (
    echo JOB is not created. Please check what's went wrong.
    exit /b 0
)

if "!JOB_STATUS!"=="FAILED" (
    curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/!JOB_ID!/output" >> failed_report_!JOB_ID!.csv
    echo The Import Job is failed. Downloaded the report to: failed_report_!JOB_ID!.csv
) else if "!JOB_STATUS!"=="COMPLETED" (
    curl -H "X-OS-API-TOKEN: %TOKEN%" -X GET "%URL%/rest/ng/import-jobs/!JOB_ID!/output" >> success_report_!JOB_ID!.csv
    echo The import job is successfully completed saved in: success_report_!JOB_ID!.csv
) else if "!JOB_STATUS!"=="IN_PROGRESS" (
    echo The import job is running. Please wait.....
    timeout /t 5 /nobreak
    goto checkJobStatusAndDownloadReport
)

:: Function to create and run the import job
:createAndRunTheImportJob
if not "%TOKEN%"=="" (
    if not "%FILE_ID%"=="" (
        curl -H "X-OS-API-TOKEN: %TOKEN%" -X POST -H "Content-Type: application/json" -d ^^^^{
            "objectType": "%OBJECT_TYPE%",
            "importType": "%IMPORT_TYPE%",
            "inputFileId": "%FILE_ID%",
            "dateFormat": "%DATE_FORMAT%",
            "timeFormat": "%TIME_FORMAT%",
            "objectParams": ^^^^{
                "entityType": "%ENTITY_TYPE%",
                "formName": "%FORM_NAME%",
                "cpId": -1
            ^^^^},
            "atomic": true
        ^^^^} "%URL%/rest/ng/import-jobs"
    ) else (
        echo The Input file is not accepted by Server. Please send CSV file.
        exit /b 0
    )
) else (
    echo Authentication is not done. Please enter correct username and password.
    exit /b 0
)

:: Function to get file ID
:getFileId
if not "%TOKEN%"=="" (
    for /f "delims=" %%i in ('curl -H "X-OS-API-TOKEN: %TOKEN%" -X POST --form "file=@%FILE%" "%URL%/rest/ng/import-jobs/input-file" ^| jq -r ".fileId"') do set "FILE_ID=%%i"
) else (
    echo Authentication is not done. Please enter correct username and password.
    exit /b 0
)

:: Function to start sessions
:startSessions
for /f "delims=" %%i in ('curl -u %USERNAME%:%PASSWORD% -X POST -H "Content-Type: application/json" -d ^^^^{
    "loginName":"%USERNAME%",
    "password":"%PASSWORD%"
^^^} "%URL%/rest/ng/sessions" ^| jq -r ".token"') do set "TOKEN=%%i"

:end
