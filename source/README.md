# Documentation

The LINQ to DB documentation uses [DocFX](https://dotnet.github.io/docfx/) to generate the doc site: https://linq2db.github.io

## Getting Started

1. Run `local.cmd` build script
2. The previous step builds the site under `_site` folder. If you open the `index.html` from that folder you'll see a few CORS errors. To work around this issue, one possible solution is to access the site through a local web server like IIS (see steps below).
3. Edit your hosts file (c:\Windows\System32\drivers\etc\hosts) and add new line: 127.0.0.1	linq2dbdocs.local
4. From IIS Manager -> Site -> (right click) Add Website -> point path to the "_site" folder above and the host name to what you added to your hosts file (linq2dbdocs.local).
5. You should now be able to access the site via http://linq2dbdocs.local