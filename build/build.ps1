Param(
	[Parameter(Mandatory=$true)][string]$githubUser,
    [Parameter(Mandatory=$true)][string]$githubAccessToken,
    [Parameter(Mandatory=$true)][string]$githubUserEmail,
    [Parameter(Mandatory=$true)][bool]$gitDeploy
)

Write-Host Building documentation

Write-Host Cleanup previous build artifacts...
if ([System.IO.Directory]::Exists('_site')) { Remove-Item _site -Recurse -Force }
if ([System.IO.Directory]::Exists('source/api')) { Remove-Item source/api -Recurse -Force }
if ([System.IO.Directory]::Exists('linq2db.github.io')) { Remove-Item linq2db.github.io -Recurse -Force }
Write-Host Done

Write-Host Prepare tooling...
Get-Location | Write-Host
if ([System.IO.File]::Exists('./tools/NuGet.exe')) 
{
     Write-Host nuget found
}

if ([System.IO.File]::Exists('d:\a\1\s\tools\NuGet.exe')) 
{
     Write-Host nuget2 found
}

if ([System.IO.File]::Exists('.\tools\NuGet.exe')) 
{
     Write-Host nuget3 found
}

Tree . /F | Select-Object -Skip 2 | Write-Host

./tools/NuGet.exe install msdn.4.5.2 -ExcludeVersion -OutputDirectory tools/packages -Prerelease
./tools/NuGet.exe install docfx.console -ExcludeVersion -OutputDirectory tools/packages
Write-Host Done

Write-Host Build DocFX documentation...
tools/packages/docfx.console/tools/docfx.exe source/docfx.json
if ($LASTEXITCODE -ne 0)
{
    throw "DocFx build failed";
}
Write-Host Done

if ($gitDeploy)
{
    Write-Host Updating site...
    git clone https://github.com/linq2db/linq2db.github.io.git -b master linq2db.github.io -q
    Copy-Item linq2db.github.io/.git _site -Recurse
    Remove-Item linq2db.github.io -Recurse -Force
    Set-Location _site
    #git config core.autocrlf true
    #git config user.name $githubUser
    #git config user.email $githubUserEmail
    #git add -A 2>&1
    #git commit -m "CI docfx update" -q
    #git push "https://$($gitHubUser):$($gitHubAccessToken)@github.com/linq2db/linq2db.github.io.git" master -q
    Write-Host Done
}
