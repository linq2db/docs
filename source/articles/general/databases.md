# Supported Databases

[Current list](https://linq2db.github.io/api/LinqToDB.ProviderName.html).

One database may have several providers because of:

* using different ADO .Net implementations (as for SQLite)
* SQL compatibility level, that allows using new SQL features of the database engine (as for MS SQL Server)

| Database| Provider name |
|--|--|
|DB2 (LUW, z/OS)| DB2<br/>DB2.LUW<br/>DB2.z/OS |
|Firebird |Firebird |
|Informix |Informix |
|Microsoft Access |Access |
|Microsoft Sql Azure | |
|Microsoft Sql Server |SqlServer - default compatibility level SQL Server 2008<br/>SqlServer.2000<br/>SqlServer.2005<br/>SqlServer.2008<br/>SqlServer.2012<br/>SqlServer.2014<br/>SqlServer.2017 |
|Microsoft SqlCe |SqlCe |
|MySql |MySql<br/>MySqlConnector<br/>MySql.Official |
|Oracle |Oracle<br/>Oracle.Managed</br>Oracle.Native |
|PostgreSQL |PostgreSQL<br/>PostgreSQL.9.2<br/>PostgreSQL.9.3<br/>PostgreSQL.9.5 |
|SQLite |SQLite, SQLite.Classic - using System.Data.Sqlite<br>SQLite.MS - using Microsoft.Data.Sqlite |
|SAP HANA |SapHana |
|Sybase ASE |Sybase - using Native SAP/Sybase ASE provider<br/>Sybase.Managed - using Managed Sybase/SAP ASE provider from [DataAction](https://github.com/DataAction/AdoNetCore.AseClient) |
|[DB2 iSeries](https://github.com/LinqToDB4iSeries/Linq2DB4iSeries) |iSeriesProvider |
