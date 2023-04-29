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
dotnet restore 'submodules/linq2db/Source/LinqToDB/LinqToDB.csproj'
dotnet restore 'submodules/linq2db/Source/LinqToDB.AspNet/LinqToDB.AspNet.csproj'
dotnet restore 'submodules/linq2db/Source/LinqToDB.Remote.Grpc/LinqToDB.Remote.Grpc.csproj'
dotnet restore 'submodules/linq2db/Source/LinqToDB.Remote.Wcf/LinqToDB.Remote.Wcf.csproj'
dotnet restore 'submodules/linq2db/Source/LinqToDB.Tools/LinqToDB.Tools.csproj'
dotnet restore 'submodules/linq2db.EntityFrameworkCore/Source/LinqToDB.EntityFrameworkCore/linq2db.EntityFrameworkCore.csproj'
dotnet restore 'submodules/LinqToDB.Identity/src/LinqToDB.Identity/LinqToDB.Identity.csproj'

Write-Host Build DocFX documentation...
docfx source/docfx.json
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
