Param(
    [Parameter(Mandatory=$true)][bool]$deploy
)

Write-Host Building documentation

Write-Host Cleanup previous build artifacts...
if ([System.IO.Directory]::Exists('_site')) { Remove-Item _site -Recurse -Force }
if ([System.IO.Directory]::Exists('source/api')) { Remove-Item source/api -Recurse -Force }
if ([System.IO.Directory]::Exists('linq2db.github.io')) { Remove-Item linq2db.github.io -Recurse -Force }

Write-Host Prepare tooling...
dotnet tool install docfx -g

Write-Host Restore...
# workaround for https://github.com/dotnet/docfx/pull/8375
# also works as workaround for https://github.com/dotnet/docfx/issues/9775
# -p: flags suppress IDE0390/IDE0391 enforcement in Release config. Newer Roslyn (SDK 10.0.x+
# on the CI windows-2025 image) enforces these as errors via TreatWarningsAsErrors=true; the
# F# pre-build builds the consumed LinqToDB.csproj transitively across all 5 TFMs and trips
# on a few `Method can be made synchronous` sites. Docs only needs API surface, not pristine
# style output. Older SDKs (some local dev boxes) don't enforce — the CI hit is the canonical
# trigger.
dotnet build -c Release -p:RunAnalyzersDuringBuild=false -p:EnforceCodeStyleInBuild=false 'submodules/linq2db/Source/LinqToDB.FSharp/LinqToDB.FSharp.fsproj'

if ($LASTEXITCODE -ne 0)
{
    throw "F# pre-build failed";
}

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
