[![Build Status](https://travis-ci.org/ballerina-platform/module-ballerinax-googleapis.sheets.svg?branch=master)](https://travis-ci.org/ballerina-ballerinax-platform/module-ballerinax-googleapis.sheets)

# Ballerina Google Spreadsheet Endpoint

Google Sheets is an online spreadsheet that lets users create and format
spreadsheets and simultaneously work with other people. The Google Spreadsheet endpoint allows you to access the Google Spreadsheet API Version v4 through Ballerina.

The following sections provide you with information on how to use the Ballerina Google Spreadsheet endpoint.
- [Compatibility](#compatibility)
- [Getting started](#getting-started)


### Compatibility

| Ballerina Language Versions  | Google Spreadsheet API Version |
|:----------------------------:|:------------------------------:|
|      Swan Lake Preview8      |   V4                           |

##### Prerequisites
Download the ballerina [distribution](https://ballerinalang.org/downloads/).

### Pull and Install

#### Pull the Module
You can pull the Spreadsheet client from Ballerina Central:
```ballerina
$ ballerina pull ballerinax/googleapis.sheets4
```

#### Install from Source
Alternatively, you can install Spreadsheet client from the source using the following instructions.

**Building the source**
1. Clone this repository using the following command:
    ```shell
    $ git clone https://github.com/ballerina-platform/module-googlespreadsheet.git
    ```

2. Run this command from the `module-googlespreadsheet` root directory:
    ```shell
    $ ballerina build googleapis.sheets4
    ```

### Working with GSheets Endpoint actions

First, import the `ballerinax/googleapis.sheets4` module into the Ballerina project.

```ballerina
import ballerinax/googleapis.sheets4;
```

All the actions return valid response or error. If the action is a success, then the requested resource will
be returned. Else error will be returned.

In order for you to use the GSheets Endpoint, first you need to create a GSheets Client endpoint.

```ballerina
import ballerinax/googleapis.sheets4;

sheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: "<accessToken>",
        refreshConfig: {
            clientId: "<clientId>",
            clientSecret: "<clientSecret>",
            refreshUrl: "<refreshUrl>",
            refreshToken: "<refreshToken>"
        }
    }
};

sheets4:Client spreadsheetClient = new (spreadsheetConfig);
```

Then the endpoint actions can be invoked as `var response = spreadsheetClient->actionName(arguments)`.

#### Sample with default truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis.sheets4;

sheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: "<accessToken>",
        refreshConfig: {
            clientId: "<clientId>",
            clientSecret: "<clientSecret>",
            refreshUrl: "<refreshUrl>",
            refreshToken: "<refreshToken>"
        }
    }
};

sheets4:Client spreadsheetClient = new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets4:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

#### Sample with custom truststore
```ballerina
import ballerina/io;
import ballerinax/googleapis.sheets4;

sheets4:SpreadsheetConfiguration spreadsheetConfig = {
    oauth2Config: {
        accessToken: "<accessToken>",
        refreshConfig: {
            clientId: "<clientId>",
            clientSecret: "<clientSecret>",
            refreshUrl: "<refreshUrl>",
            refreshToken: "<refreshToken>"
        }
    },
    secureSocketConfig: {
        trustStore: {
            path: "<fullQualifiedPathToTrustStore>",
            password: "<truststorePassword>"
        }
    }
};

sheets4:Client spreadsheetClient = new (spreadsheetConfig);

public function main(string... args) {
    var response = spreadsheetClient->openSpreadsheetById(<spreadsheet-id>);
    if (response is sheets4:Spreadsheet) {
        io:println("Spreadsheet Details: ", response);
    } else {
        io:println("Error: ", response);
    }
}
```

### How you can contribute

Clone the repository by running the following command
`git clone https://github.com/ballerina-platform/module-googlespreadsheet.git`

As an open source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/ballerina-platform/module-googlespreadsheet/issues) for open issues that interest you. We look forward to receiving your contributions.
