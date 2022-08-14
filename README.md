[![Build Status](https://dev.azure.com/linq2db/linq2db/_apis/build/status/linq2db.docs?branchName=master)](https://dev.azure.com/linq2db/linq2db/_build/latest?definitionId=2&branchName=master)

This repository hosts documentation sources and build scripts for all Linq To DB projects: [linq2db.github.io](https://linq2db.github.io).

Documentation generated using  [DocFX](https://dotnet.github.io/docfx/) generator.

## Local Build

1. Run `submodules.cmd` to update submodules to recent release. Submodules link other Linq To DB repositories and used as source for  API documentation.
1. Run `local.cmd` build script to generate static documentation site in `_site` folder (you will need `nuget.exe` in repository root or in path)
1. Open the `_site\index.html` (or you can configure web-server, e.g. IIS to this folder)
