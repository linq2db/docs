This page contains changes and fixes that were not inluded in any release yet and available only through MyGet feed. 

[![MyGet](https://img.shields.io/myget/linq2db/vpre/linq2db.svg)](https://www.myget.org/gallery/linq2db)

# Will be included into next post-2.0 release

none yet

## ASP.NET Core support
LINQ To DB now has support for ASP.NET Dependancy injection. Here's a simple example of how to add it to dependancy injection
```C#
public class Startup
{
    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        //...
        //using LinqToDB.AspNet
        services.AddLinqToDbContext<AppDataConnection>((provider, options) => {
            options
            //will configure the AppDataConnection to use
            //SqlServer with the provided connection string
            //there are methods for each supported database
            .UseSqlServer(Configuration.GetConnectionString("Default"))

            //default logging will log everything using
            //an ILoggerFactory configured in the provider
            .UseDefaultLogging(provider);
        });
        //...
    }
}
```

In addition to these configuration options the following are also supported
* `UseOracle(string connectionString)`
* `UsePostgreSQL(string connectionString)`
* `UseMySql(string connectionString)`
* `UseSQLite(string connectionString)`
* `UseConnectionString(string providerName, string connectionString)`
* `UseConnectionString(IDataProvider dataProvider, string connectionString)`
* `UseConfigurationString(string configurationString)`
* `UseConnectionFactory(IDataProvider dataProvider, Func<IDbConnection> connectionFactory)`
* `UseConnection(IDataProvider dataProvider, IDbConnection connection, bool disposeConnection = false)`
* `UseTransaction(IDataProvider dataProvider, IDbTransaction transaction)`

We've done our best job to allow any existing use case to be migrated to using the new configuration options, please create an issue if something isn't supported.
There's also some methods to setup tracing and mapping schema.

You'll need to update your data connection to accept the new options class too.

```C#
public class AppDataConnection: DataConnection
{
    public AppDataConnection(LinqToDbConnectionOptions<AppDataConnection> options)
        :base(options)
    {

    }
}
```
`DataConnection` will used the options passed into the base constructor to setup the connection. 
> [!NOTE]  
> `DataConnection` supports `LinqToDbConnectionOptions`. However `DataContext` is not yet supported.
