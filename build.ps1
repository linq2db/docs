Param(
    [Parameter(Mandatory=$true)][bool]$deploy
)

Write-Host Building documentation

# Disable Roslyn analyzers + code-style enforcement for both the F# pre-build
# and docfx's internal MSBuild invocations during metadata extraction.
# linq2db source ships with rules (IDE0390/IDE0391 etc.) that are warnings-as-errors
# under TreatWarningsAsErrors=true; the linq2db CI test-all path bypasses these via
# `RunAnalyzersDuringBuild=false` too. Docs only needs the API surface, not the
# style rules — disabling here matches that intent and unblocks docs builds for
# releases whose source happens to trip rules new in the toolchain.
$env:RunAnalyzersDuringBuild = 'false'
$env:EnforceCodeStyleInBuild = 'false'

Write-Host Cleanup previous build artifacts...
if ([System.IO.Directory]::Exists('_site')) { Remove-Item _site -Recurse -Force }
if ([System.IO.Directory]::Exists('source/api')) { Remove-Item source/api -Recurse -Force }
if ([System.IO.Directory]::Exists('linq2db.github.io')) { Remove-Item linq2db.github.io -Recurse -Force }

Write-Host Prepare tooling...
dotnet tool install docfx -g

Write-Host Restore...
# workaround for https://github.com/dotnet/docfx/pull/8375
# also works as workaround for https://github.com/dotnet/docfx/issues/9775
dotnet build -c Release 'submodules/linq2db/Source/LinqToDB.FSharp/LinqToDB.FSharp.fsproj'

Write-Host Build DocFX documentation...
# docfx source/docfx.json
# use custom build
./docfx/docfx source/docfx.json

if ($LASTEXITCODE -ne 0)
{
    throw "DocFx build failed";
}
Write-Host Done

if ($deploy)
{
    Write-Host Prepare site for deploy...
    git clone https://github.com/linq2db/linq2db.github.io.git -b master linq2db.github.io -q
    Copy-Item linq2db.github.io/.git _site -Recurse
    Remove-Item linq2db.github.io -Recurse -Force
    Set-Location _site
    git add -A
    git config user.name "Azure Pipelines"
    git config user.email docfx@linq2db.com
    git commit -a -m "DocFX update by CI" -q
    git push "https://docfx:$env:GITHUB_PAT@github.com/linq2db/linq2db.github.io.git" master -q
    Write-Host Done
}
