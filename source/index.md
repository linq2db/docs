---
title: Linq To DB
_disableToc: true
_disableAffix: true
_disableBreadcrumb: true
_disableNextArticle: true
---

<section class="landing-hero">
<div class="landing-hero-inner">
<div class="container-xxl">
<div class="row align-items-center g-5">
<div class="col-lg-6">
<div class="landing-badge mb-3">Open Source ORM for .NET</div>
<h1 class="landing-title">Data access<br/>made <span class="landing-accent">simple</span></h1>
<p class="landing-subtitle">The fastest LINQ database access library. A lightweight, type-safe layer between your POCO objects and your database with full SQL support.</p>
<div class="landing-actions">
<a href="documentation/get-started/install/index.md" class="btn btn-primary btn-lg landing-btn-primary">Get Started <i class="bi bi-arrow-right"></i></a>
<a href="https://github.com/linq2db/linq2db" class="btn btn-outline-light btn-lg landing-btn-secondary"><i class="bi bi-github"></i> GitHub</a>
</div>
<div class="landing-install mt-4">
<code>dotnet add package linq2db</code>
</div>
</div>
<div class="col-lg-6">
<div class="landing-code">
<div class="landing-code-header">
<span class="landing-code-dot"></span>
<span class="landing-code-dot"></span>
<span class="landing-code-dot"></span>
<span class="landing-code-file">Program.cs</span>
</div>
<pre class="landing-code-body"><span class="code-keyword">using</span> LinqToDB;
<span class="code-keyword">using</span> LinqToDB.Data;
&#10;<span class="code-keyword">using var</span> db = <span class="code-keyword">new</span> <span class="code-type">DataConnection</span>(options);
&#10;<span class="code-keyword">var</span> query =
    <span class="code-keyword">from</span> p <span class="code-keyword">in</span> db.GetTable&lt;<span class="code-type">Product</span>&gt;()
    <span class="code-keyword">where</span> p.Category == <span class="code-string">"Electronics"</span>
       &amp;&amp; p.Price &gt; <span class="code-number">99.99m</span>
    <span class="code-keyword">orderby</span> p.Name
    <span class="code-keyword">select new</span> { p.Name, p.Price };
&#10;<span class="code-keyword">await foreach</span> (<span class="code-keyword">var</span> item <span class="code-keyword">in</span> query.AsAsyncEnumerable())
    Console.WriteLine(<span class="code-string">$"</span>{item.Name}: {item.Price}<span class="code-string">"</span>);</pre>
</div>
</div>
</div>
</div>
</div>
</section>

<section class="landing-cards">
<div class="container-xxl">
<div class="row g-4">

<div class="col-md-4">
<a href="documentation/index.md" class="landing-card">
<div class="landing-card-icon-wrap"><i class="bi bi-book"></i></div>
<h3>Documentation</h3>
<p>Installation, core concepts, SQL features, configuration guides, and best practices.</p>
<span class="landing-card-link">Browse docs <i class="bi bi-arrow-right"></i></span>
</a>
</div>

<div class="col-md-4">
<a href="articles/index.md" class="landing-card">
<div class="landing-card-icon-wrap"><i class="bi bi-newspaper"></i></div>
<h3>Articles</h3>
<p>Release notes, announcements, and news from the Linq To DB project.</p>
<span class="landing-card-link">Read articles <i class="bi bi-arrow-right"></i></span>
</a>
</div>

<div class="col-md-4">
<a href="api/linq2db/index.md" class="landing-card">
<div class="landing-card-icon-wrap"><i class="bi bi-code-slash"></i></div>
<h3>API Reference</h3>
<p>Complete API documentation for all packages, extensions, and integrations.</p>
<span class="landing-card-link">Explore API <i class="bi bi-arrow-right"></i></span>
</a>
</div>

</div>
</div>
</section>

<section class="landing-features">
<div class="container-xxl">
<div class="row g-4 g-lg-5">

<div class="col-md-6 col-lg-3">
<div class="landing-feature">
<div class="landing-feature-icon"><i class="bi bi-lightning-charge-fill"></i></div>
<h4>High Performance</h4>
<p>Generates optimized SQL with minimal overhead. No reflection at runtime, no heavy object tracking.</p>
</div>
</div>

<div class="col-md-6 col-lg-3">
<div class="landing-feature">
<div class="landing-feature-icon"><i class="bi bi-database-fill"></i></div>
<h4>Multi-Database</h4>
<p>SQL Server, PostgreSQL, MySQL, SQLite, Oracle, Firebird, ClickHouse, and many more.</p>
</div>
</div>

<div class="col-md-6 col-lg-3">
<div class="landing-feature">
<div class="landing-feature-icon"><i class="bi bi-braces"></i></div>
<h4>Full LINQ</h4>
<p>Type-safe queries with advanced SQL: CTEs, Window Functions, MERGE, Bulk Copy, and more.</p>
</div>
</div>

<div class="col-md-6 col-lg-3">
<div class="landing-feature">
<div class="landing-feature-icon"><i class="bi bi-puzzle-fill"></i></div>
<h4>Extensible</h4>
<p>EF Core integration, ASP.NET Identity, gRPC, SignalR, and HTTP remoting out of the box.</p>
</div>
</div>

</div>
</div>
</section>
