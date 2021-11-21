CLS

WHERE nuget.exe >nul 2>&1
IF %errorlevel% NEQ 0 (
ECHO Cannot find nuget.exe. Add it to PATH or place it to current folder
ECHO nuget.exe could be downloaded from https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
GOTO :EOF
)

powershell build/build.ps1 0
