# Vendored docfx build

`build.ps1` runs `./docfx/docfx` rather than the `docfx` global tool, because this site needs two
options that are not in released docfx yet.

## Why

linq2db documents 17 assemblies in one docfx project and many of them declare the same namespaces, most
of all `LinqToDB`. A docfx UID is derived from the fully qualified name of an API alone, so those APIs
collide: pages overwrite each other, `DuplicateUids` is reported and links resolve to whichever assembly
happened to win. See <https://github.com/dotnet/docfx/issues/8966>.

`source/docfx.json` therefore uses:

- **`assemblyUids`** — the assemblies whose APIs carry the assembly they are declared in as a component of
  their UID, as in `linq2db.Tools::LinqToDB.Tools.Activity.ActivityStatistics`. It sits at the top level of
  `docfx.json` next to `metadata`, because every metadata entry has to agree: an entry mints UIDs for the
  APIs it references as well as the ones it documents.
- **`assemblyUidOverride`** — the component to use for the assemblies one entry documents. The four
  Entity Framework Core entries all build an assembly named `linq2db.EntityFrameworkCore` (see
  `LinqToDB.EntityFrameworkCore.props`), so they cannot be told apart by assembly name and this is the only
  thing that separates them.

The assembly is a component of the identity, not a namespace segment: `LinqToDB` still reads as `LinqToDB`
in titles, breadcrumbs and links, and only the UID and the file name carry the assembly (`::` becomes `--`
in file names, as `:` is not legal there).

This replaces the older `globalPrefix` hack, which produced a malformed `commentId`, unprefixed
namespace and type hrefs, and ~1200 dead in-page anchors, and the `assemblyUidPrefixes` /
`uidPrefixOverride` pair before it, which spelled the assembly as a leading namespace segment and so
surfaced in page titles and the table of contents as a namespace that does not exist.

## How this build is produced

Branch: [`fix/8966-uid-prefixes`](https://github.com/MaceWindu/docfx/pull/2) in
<https://github.com/MaceWindu/docfx>, currently `dd95c86d9` — the branch proposed for upstream, with
nothing added on top.

The previous build needed one extra commit bumping Roslyn to 5.6.0, because with Roslyn 5.0.0 and the
.NET 10 SDK opening the linq2db projects failed with `System.TimeoutException` from
`MSBuildProjectLoader`'s BuildHost. Upstream has since taken that bump (dotnet/docfx#11047), so no custom
commit is required any more.

```powershell
git clone https://github.com/MaceWindu/docfx -b fix/8966-uid-prefixes
cd docfx/templates; npm ci; npm run build; cd ..
dotnet build src/docfx/docfx.csproj -c Release -f net10.0

# then copy into this folder, replacing every tracked file:
#   src/docfx/bin/Release/net10.0/*.{dll,exe,pdb,json,ps1,TXT}
#   src/docfx/bin/Release/net10.0/{BuildHost-net472,BuildHost-netcore,templates}
# `.playwright` is not tracked, leave it alone.
```

`docfx.exe --version` prints the source commit, so the vendored build can always be traced back:

```
1.0.0+dd95c86d963ad33da06d7026899f7b8879a2970a
```

## When can this go away

Once `assemblyUids` and `assemblyUidOverride` ship in a released docfx, drop this folder and switch
`build.ps1` back to the `docfx` global tool. The `source/docfx.json` options themselves do not need to
change.
