# Vendored docfx build

`build.ps1` runs `./docfx/docfx` rather than the `docfx` global tool, because this site needs two
options that are not in released docfx yet.

## Why

linq2db documents 17 assemblies in one docfx project and many of them declare the same namespaces, most
of all `LinqToDB`. A docfx UID is derived from the fully qualified name of an API alone, so those APIs
collide: pages overwrite each other, `DuplicateUids` is reported and links resolve to whichever assembly
happened to win. See <https://github.com/dotnet/docfx/issues/8966>.

`source/docfx.json` therefore uses:

- **`assemblyUidPrefixes`** — maps assembly name to UID prefix. It is project wide: the maps of all
  metadata entries are combined before any is processed, which is what makes references *between*
  entries resolve, so the whole map is declared once on the first entry.
- **`uidPrefixOverride`** — a per entry prefix, for the assemblies that entry documents. The four
  Entity Framework Core entries all build an assembly named `linq2db.EntityFrameworkCore` (see
  `LinqToDB.EntityFrameworkCore.props`), so they cannot be keyed by assembly name and this is the only
  thing that separates them.

This replaces the older `globalPrefix` hack, which produced a malformed `commentId`, unprefixed
namespace and type hrefs, and ~1200 dead in-page anchors.

## How this build is produced

Branch: [`custom/linq2db-uidprefix`](https://github.com/MaceWindu/docfx/tree/custom/linq2db-uidprefix)
in <https://github.com/MaceWindu/docfx>, currently `5534e75af`. It is
[`fix/8966-uid-prefixes`](https://github.com/MaceWindu/docfx/pull/2) — the branch proposed for upstream
— plus one commit bumping Roslyn to 5.6.0.

The Roslyn bump is required, not cosmetic: with Roslyn 5.0.0 and the .NET 10 SDK, opening the linq2db
projects fails with `System.TimeoutException` from `MSBuildProjectLoader`'s BuildHost. It is kept off the
upstream branch because it would churn docfx's snapshot tests.

```powershell
git clone https://github.com/MaceWindu/docfx -b custom/linq2db-uidprefix
cd docfx/templates; npm ci; npm run build; cd ..
dotnet build src/docfx/docfx.csproj -c Release -f net10.0

# then copy into this folder, replacing every tracked file:
#   src/docfx/bin/Release/net10.0/*.{dll,exe,pdb,json,ps1,TXT}
#   src/docfx/bin/Release/net10.0/{BuildHost-net472,BuildHost-netcore,templates}
# `.playwright` is not tracked, leave it alone.
```

`docfx.exe --version` prints the source commit, so the vendored build can always be traced back:

```
1.0.0+5534e75af19bc47ed4b4695520935b506fb52a9e
```

## When can this go away

Once `assemblyUidPrefixes` and `uidPrefixOverride` ship in a released docfx, drop this folder and switch
`build.ps1` back to the `docfx` global tool. The `source/docfx.json` options themselves do not need to
change.
