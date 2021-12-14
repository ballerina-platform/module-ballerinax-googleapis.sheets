Ballerina Google Sheets Connector
===================

[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-googleapis.sheets.svg?branch=master)](https://travis-ci.org/ballerina-ballerinax-platform/module-ballerinax-googleapis.sheets)
[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.sheets.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/commits/master)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Google Sheets](https://developers.google.com/sheets/api) is an online spreadsheet that allows you to create and format spreadsheets. It facilitates multiple users to work on the same spreadsheets simultaneously. It allows you to manage spreadsheets, manage worksheets, read, write, update, and clear data from worksheets. The API also allows you to perform column-wise, row-wise, and cell-wise operations.

The Google Sheets [Ballerina](https://ballerina.io/) connector exposes the [Google Sheets API v4](https://developers.google.com/sheets/api) through Ballerina. The connector makes it convenient to implement some of the most common use cases of Google Spreadsheets. With this connector, you can programmatically manage spreadsheets, manage worksheets, perform CRUD operations on worksheets, and perform column-level, row-level, and cell-level operations. 

The Google Sheets [Ballerina](https://ballerina.io/) listener allows you to listen to Google Sheets events. It listens to events triggered when a spreadsheet is edited. For example, when a row is appended, when a row is updated, etc.

For more information, go to the module(s).
- [googleapis.sheets](gsheet/Module.md)
- [googleapis.sheets.'listener](gsheet/modules/listener/Module.md)

## Building from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/). 

### Building the source

Execute the commands below to build from the source.

- To build the package:
    ```shell
    bal pack
    ```
- To test the package: 
    ```shell
    bal test
    ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/gsheet/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
