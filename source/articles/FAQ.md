# Mapping

## Do I need to use Attribute and/or Code first Mapping?

Not strictly. It is possible to use linq2db with simple, non-attributed POCOs, however there will be specific limitations. 
 - The biggest of these is that the `string` type is nullable by default in .NET, and unlike with `int` or `double` there is no way for linq2db to infer nullability. This can cause problems in certain cases, such as if you are ever required to join two `VARCHAR` fields together.

 - Table and column names will have to match the class and property names.
   - You can get around this for the class itself by using the `.TableName()` Method after your `GetTable<>` call (e.x.  `conn.GetTable<MyCleanClassName>().TableName("my_not_so_clean_table_name")` )

 - Unless using the explicit insert/update syntax (i.e. `.Value()`/`.Set()`), all columns will be written off the supplied POCO.

## How can I use calculated fields?

You need to mark them to be ignored during insert or update operations, e.g. using `ColumnAttribute` attribute:
```cs
public class MyEntity
{
    [Column(SkipOnInsert = true, SkipOnUpdate = true)]
    public int CalculatedField { get; set; }
}
```

## How can I use SQL Server spatial types

Spatial types for SQL Server provided by:
- [`Microsoft.SqlServer.Types`](https://www.nuget.org/packages/Microsoft.SqlServer.Types/) assembly from Microsoft for .NET Framework
- [`dotMorten.Microsoft.SqlServer.Types`](https://www.nuget.org/packages/dotMorten.Microsoft.SqlServer.Types/) assembly from [Morten Nielsen](https://github.com/dotMorten) for .NET Core

For .net core we recommend to use at least linq2db 2.9.0 as it contains several important fixes in this area for .net core projects.

First of all it is recommended to register types assembly in linq2db using following call:
```cs
SqlServerTools.ResolveSqlTypes(typeof(SqlGeography).Assembly);
```

Main problem that people hit with SQL Server spatial types is following error on select queries: `Can't create '<DB_NAME>.sys.<SPATIAL_TYPE_NAME>' type or '' specific type for <COLUMN_NAME>.`

This happens due to different versions of `Microsoft.SqlServer.Types` assembly, requested by SqlClient, and assembly, referenced by your project.

#### How to fix it

For .NET Framework you just need to add assembly bindings redirect to your configuration file to redirect all assembly load requests to your version (make sure that `newVersion` contains proper version of assembly you have):
```xml
<runtime>
  <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
    <dependentAssembly>
      <assemblyIdentity name="Microsoft.SqlServer.Types" publicKeyToken="89845dcd8080cc91" culture="neutral"/>
      <bindingRedirect oldVersion="0.0.0.0-14.0.0.0" newVersion="14.0.0.0" />
    </dependentAssembly>
  </assemblyBinding>
</runtime>
```

For .NET Core it is a bit tricky because:
- .NET Core doesn't support binding redirects
- You need to use 3rd-party assembly with non-Microsoft public key and binding redirects doesn't allow such redirects anyway

To workaround it you need to add custom assembly resolver to your code:
```cs
// subscribe to assembly load request event somewhere in your init code
AssemblyLoadContext.Default.Resolving += OnAssemblyResolve;

Assembly OnAssemblyResolve(AssemblyLoadContext assemblyLoadContext, AssemblyName assemblyName)
{
  try
  {
    // you need to unsubscribe here to avoid StackOverflowException,
    // as LoadFromAssemblyName will go in recursion here otherwise
    AssemblyLoadContext.Default.Resolving -= OnAssemblyResolve;
    // return resolved assembly for cases when it can be resolved
    return assemblyLoadContext.LoadFromAssemblyName(assemblyName);
  }
  catch
  {
    // on failue - check if it failed to load our types assembly
    // and explicitly return it
    if (assemblyName.Name == "Microsoft.SqlServer.Types")
      return typeof(SqlGeography).Assembly;
    // if it failed to load some other assembly - just pass exception as-is
    throw;
  }
  finally
  {
    // don't forget to restore our load handler
    AssemblyLoadContext.Default.Resolving += OnAssemblyResolve;
  }
}
```
