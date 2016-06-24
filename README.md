![BlueGranite](https://raw.githubusercontent.com/BlueGranite/BlueGranite.github.io/master/assets/images/Blue-Granite-Logo.png)

#Microsoft R Resources

Materials from BlueGranite's [Microsoft R: A Revolution in Advanced Analytics](https://www.blue-granite.com/webinar-microsoft-r-a-revolution-of-advanced-analytics) webinar




###[SQL Server 2016](https://github.com/BlueGranite/Microsoft-R-Resources/blob/master/sql-server-r-services/Tutorial.md)
The SQL Server R Services sample files utilize introductory R examples with the new Wide World Importers DW database. The demo utilizes a basic source query from the Fact.Orders table and shows how to work with the same data using R in both a traditional context as well as using RevoScaleR with various rx functions. Shifting to SQL, the same code can be adapted for use in SQL Server and embedded in stored procedures with minimal changes. The final component uses a Reporting Services (SSRS) report to connect to an embedded SQL stored procedure and plot the resulting histogram in SSRS.

In order to work through eveything in the demo, you will need:

- Access to the RevoScaleR functions (i.e. by installing Microsoft R Client)

- Access to a version of SQL Server 2016 with R Services installed 

- The WideWorldImportersDW sample database on the SQL instance

- SQL Server Data Tools (for the Reporting Services content only)

| Category | Application | File Name |
| ------------- |:-:| :-:|
| R | R IDE (RStudio or R Tools for Visual Studio) | RevoScaleR-vs-Traditional.R |
| SQL | Management Studio or Data Tools | R-Services-Example.sql |
| Reporting Services | Data Tools | R-Services-Sample-Reports.zip |
| Reporting Services | Any image viewer | Reporting-Services-Dataset-Setup.png |
| Reporting Services | Any image viewer | Reporting-Services-Image-Setup.png |
| Reporting Services | Any image viewer | Reporting-Services-Final-Plot.png |
| Reporting Services | Any PDF viewer | SampleHistogram.pdf |

*View the SQL Server 2016 [R Services Tutorial](https://github.com/BlueGranite/Microsoft-R-Resources/blob/master/sql-server-r-services/Tutorial.md)*  


###[Power BI](https://github.com/BlueGranite/Microsoft-R-Resources/blob/master/power-bi/Tutorial.md)

In order to view the demo, you will need:

- Microsoft Power BI Desktop

| Category | Application | File Name |
| ------------- |:-:| :-:|
| Power BI  | Power BI Desktop | gameconsole.pbix |
| Data Source | Any text reader | gameconsole.csv |
| Data Source | Excel | gameconsole.xlsx |

*View the [Power BI Tutorial](https://github.com/BlueGranite/Microsoft-R-Resources/blob/master/power-bi/Tutorial.md)* 

