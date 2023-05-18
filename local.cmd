ECHO OFF
CLS

dotnet tool update docfx -g

powershell -Command .\build.ps1 -deploy $false
