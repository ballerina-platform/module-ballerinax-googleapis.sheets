Ballerina Google Sheets Connector
===================

[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-googleapis.sheets.svg?branch=master)](https://travis-ci.org/ballerina-ballerinax-platform/module-ballerinax-googleapis.sheets)
[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.sheets.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Google Sheets](https://developers.google.com/sheets/api) is an online spreadsheet that lets users create and format spreadsheets and simultaneously work with other people. It lets us manage spreadsheets, manage worksheets, read, write, update and clear data from worksheets and do column wise, row wise and cell wise operations. The Google Spreadsheet endpoint allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The Google Spreadsheet [Ballerina](https://ballerina.io/) Connector allows you to access the [Google Spreadsheet API Version v4](https://developers.google.com/sheets/api) through Ballerina. The connector can be used to implement some of the most common use cases of Google Spreadsheets. The connector provides the capability to programmatically manage spreadsheets, manage worksheets, do CRUD operations on worksheets, and do column wise, row wise and cell wise operations through the connector endpoints. 

The Google Spreadsheet [Ballerina](https://ballerina.io/) listener allows you to listen to Google Sheets events. It can listen to events triggered  when a spreadsheet is edited such as when a row is appended to a spreadsheet or when a row is updated in a spreadsheet.

For more information, go to the module(s).
- [ballerinax/googleapis.sheets](https://central.ballerina.io/ballerinax/googleapis.sheets)

## Building from the Source

### Setting Up the Prerequisites

1. Download and install Java SE Development Kit (JDK) version 11 (from one of the following locations).

   * [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)

   * [OpenJDK](https://adoptopenjdk.net/)

        > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina](https://ballerina.io/). 

### Building the Source

Execute the commands below to build from the source after installing Ballerina.

1. To clone the repository:
Clone this repository using the following command:
```shell
    git clone https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets
```
Execute the commands below to build from the source after installing Ballerina.

2. To build the package:
Run this command from the module-ballerinax-googleapis.sheets root directory:
```shell script
    bal build -c
```

3. To build the module without the tests:
```shell script
    bal build -c --skip-tests
```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/gsheet/CONTRIBUTING.md).

## Code of Conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful Links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.

## How you can contribute

Clone the repository by running the following command
`git clone https://github.com/ballerina-platform/module-googlespreadsheet.git`

As an open source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/ballerina-platform/module-googlespreadsheet/issues) for open issues that interest you. We look forward to receiving your contributions.
