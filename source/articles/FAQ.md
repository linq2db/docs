# Toc

- General
  - [Which async model Linq To DB use?](#which-async-model-linq-to-db-use)
  - [I need to configure connection before or immediately after it opened (e.g. set SQL Server AccessToken or SQLite encryption key)](#i-need-to-configure-connection-before-or-immediately-after-it-opened-eg-set-sql-server-accesstoken-or-sqlite-encryption-key)
- Mapping
  - [Do I need to use Attribute and/or Code first Mapping?](#do-i-need-to-use-attribute-andor-code-first-mapping)
  - [How can I use calculated fields?](#how-can-i-use-calculated-fields)
  - [How can I use SQL Server spatial types](#how-can-i-use-sql-server-spatial-types)
  
# General

## Which async model Linq To DB use?

By default it use `await awaitable.ConfigureAwait(false)` (same as `await awaitable`) mode for internal asyn calls.
If you need it to use another mode you can change it by setting following configuration option:

```cs
// switch to await awaitable.ConfigureAwait(true)
Configuration.ContinueOnCapturedContext = true;
```

Note that in versions before 4.0 this setting was set to `true` by default.

## I need to configure connection before or immediately after it opened (e.g. set SQL Server AccessToken or SQLite encryption key)

> [!WARNING]
> Answer below is for older versions of LinqToDB. Starting with Linq To DB 4.0 you should use [interceptors](xref:Interceptors).

If you are using `DataConnection` to access database, you can subscribe to those events (each came in pair of sync and async events) and configure your connection there.

Configure connection before it opened (SQL Server AccessToken example):

```cs
// or do it in constructor of DataConnection-based class
public class MyDb : DataConnection
{
  public MyDb() : base(...)
  {
    this.OnBeforeConnectionOpen += (db, cn)
      => ((SqlConnection)cn).AccessToken = GetAccessToken();

    // code for this event could be the same, but you still need both
    // events to handle both sync and async connection open operations
    this.OnBeforeConnectionOpenAsync += async (db, cn, token) 
      => ((SqlConnection)cn).AccessToken = await GetAccessTokenAsync(token);
  }
}

using (var db = new MyDb())
{
  // queries here will get pre-configured connection
}
```

Configure connection immediately after it opened (SQLite encryption example):

```cs
// or do it in constructor of DataConnection-based class
public class MyDb : DataConnection
{
  public MyDb() : base(...)
  {
    this.OnConnectionOpened += (db, cn)
      => db.Execute($"PRAGMA key = {GetQuotedPassword()}");

    // code for this event could be the same, but you still need both
    // events to handle both sync and async connection open operations
    this.OnConnectionOpenedAsync += async (db, cn, token) 
      => await db.ExecuteAsync(
          $"PRAGMA key = {await GetQuotedPasswordAsync(token)}", token);
  }
}

using (var db = new MyDb())
{
  // queries here will get connection with encryption key set
}
```

If you need to do it also for other use-cases, e.g. for `DataContext`, it is not so convenient, but still possible (it will also handle `DataConnection` case).

One option is to derive from your provider and override `CreateConnectionInternal` method. If you need to perform connection configuration after connection opened, you allowed to open created connection in this method (but you will loose `OpenAsync()` benefits for providers that support it).

```cs
public class MySqliteProvider : SQLiteDataProvider
{
  public MySqliteProvider()
	  : base(...)
  {
  }

  protected override IDbConnection CreateConnectionInternal(
            string connectionString)
  {
    var cn = new SqliteConnection(connectionString);
    cn.Open();
    using (var cmd = cn.CreateCommand())
    {
      cmd.CommandText = $"PRAGMA key = {GetQuotedPassword()}";
      cmd.ExecuteNonQuery();
    }

    return cn;
  }
}
```

Another option if you just need to configure non-opened connection, you can do it by using `DataProviderBase.OnConnectionCreated` callback:

```cs
// note that:
// - this is not event, so you cannot have multiple subscribers
// - it is called for all connection creation operations
// for all providers
DataProviderBase.OnConnectionCreated = (p, cn) =>
{
  // this is global handler, so if you use multiple databases,
  // you need to check here if you need to handle it
  if (cn is SqlConnection connection)
  {
    connection.AccessToken = GetAccessToken();
  }

  return cn;
};
```

# Mapping

## Do I need to use Attribute and/or Code first Mapping?

Not strictly. It is possible to use linq2db with simple, non-attributed POCOs, however there will be specific limitations:

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
- [`dotMorten.Microsoft.SqlServer.Types`](https://www.nuget.org/packages/dotMorten.Microsoft.SqlServer.Types/) assembly from [Morten Nielsen](https://github.com/dotMorten) for .NET Core. v1.x versions are for `System.Data.SqlClient` provider and v2.x versions are for `Microsoft.Data.SqlClient` provider

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
