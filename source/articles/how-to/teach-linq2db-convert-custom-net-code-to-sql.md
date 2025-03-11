# How to teach LINQ to DB convert custom .NET methods and objects to SQL
You may run into a situation when LINQ to DB does not know how to convert some .NET method, property or object to SQL. But that is not a problem because LINQ to DB likes to learn. Just teach it :). In one of our previous blog posts we wrote about using MapValueAttribute to control mapping. In this article we will go a little bit deeper.
There are multiple ways to teach LINQ to DB how to convert custom properties and methods into SQL, but the primary ones are:
