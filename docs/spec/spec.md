# Specification: Ballerina Google Sheets connector

_Authors_: @DimuthuMadushan \
_Reviewers_: @ThisaruGuruge @Nuvindu \
_Created_: 2024/03/29 \
_Updated_: 2024/03/29 \
_Edition_: Swan Lake

## Introduction

The Ballerina Google Sheets connector allows you to connect to the Google Sheets API and perform various operations such as spreadsheet management operations, worksheet management operations and the capability to handle Google Sheets data-level operations.

The Ballerina Google Sheets connector specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

- [1 Overview](#1-overview)
- [2 Client](#2-client)
  - [2.1 Configurations](#21-configurations)
  - [2.2 Initialization](#22-initialization)
  - [2.3 Supported Operations](#23-supported-operations)
    - [2.3.1 Spreadsheet Operations](#231-spreadsheet-operations)
      - [2.3.1.1 Create Spreadsheet](#2311-create-spreadsheet)
      - [2.3.1.2 Open Sheet by ID](#2312-open-spreadsheet-by-id)
      - [2.3.1.3 Open Spreadsheet by URL](#2313-open-spreadsheet-by-url)
    - [2.3.2 Sheet Operations](#232-sheet-operations)
      - [2.3.2.1 Get All Sheets](#2321-get-all-sheets)
      - [2.3.2.2 Get Sheet By Name](#2322-get-sheet-by-name)
      - [2.3.2.3 Add Sheet](#2323-add-sheet)
      - [2.3.2.4 Remove Sheet](#2324-remove-sheet)
      - [2.3.2.5 Remove Sheet By Name](#2325-remove-sheet-by-name)
      - [2.3.2.6 Rename Sheet](#2326-rename-sheet)
      - [2.3.2.7 Append Value](#2372-append-value)
    - [2.3.3 Range Operations](#233-range-operations)
      - [2.3.3.1 Set Range](#2331-set-range)
      - [2.3.3.2 Get Range](#2332-get-range)
      - [2.3.3.3 Clear Range](#2333-clear-range)
    - [2.3.4 Column Operations](#234-column-operations)
      - [2.3.4.1 Add Columns Before](#2341-add-columns-before)
      - [2.3.4.2 Add Columns Before By Sheet Name](#2342-add-columns-before-by-sheet-name)
      - [2.3.4.3 Add Columns After](#2343-add-columns-after)
      - [2.3.4.4 Add Columns After By Sheet Name](#2344-add-columns-after-by-sheet-name)
      - [2.3.4.5 Create or Update Column](#2345-create-or-update-column)
      - [2.3.4.6 Get Column](#2346-get-column)
      - [2.3.4.7 Delete Columns](#2347-delete-columns)
      - [2.3.4.8 Delete Columns By Sheet Name](#2348-delete-columns-by-sheet-name)
    - [2.3.5 Row Operations](#235-row-operations)
      - [2.3.5.1 Add Rows Before](#2351-add-rows-before)
      - [2.3.5.2 Add Rows By Sheet Name](#2352-add-rows-before-by-sheet-name)
      - [2.3.5.3 Add Rows After](#2353-add-rows-after)
      - [2.3.5.4 Add Rows After By Sheet Name](#2354-add-rows-after-by-sheet-name)
      - [2.3.5.5 Create or Update Row](#2355-create-or-update-row)
      - [2.3.5.6 Get Row](#2356-get-row)
      - [2.3.5.7 Delete Rows](#2357-delete-rows)
      - [2.3.5.8 Delete Rows By Sheet Name](#2358-delete-rows-by-sheet-name)
    - [2.3.6 Cell Operations](#236-cell-operations)
      - [2.3.6.1 Set Cell](#2361-set-cell)
      - [2.3.6.2 Get Cell](#2362-get-cell)
      - [2.3.6.3 Clear Cell](#2363-clear-cell)
    - [2.3.7 Append Operations](#237-append-operations)
      - [2.3.7.1 Append Row to Sheet](#2371-append-row-to-sheet)
      - [2.3.7.2 Append Value](#2372-append-value)
      - [2.3.7.3 Append Values](#2373-append-values)
    - [2.3.8 Copy Operations](#238-copy-operations)
      - [2.3.8.1 Copy To](#2381-copy-to)
      - [2.3.8.2 Copt To By Sheet Name](#2382-copy-to-by-sheet-name)
    - [2.3.9 Clear Operations](#239-clear-operations)
      - [2.3.9.1 Clear All](#2391-clear-all)
      - [2.3.9.2 Clear All By Sheet Name](#2392-clear-all-by-sheet-name)
    - [2.3.10 Metadata and Data Filter Operations](#2310-metadata-and-data-filter-operations)
      - [2.3.10.1 Set Row Metadata](#23101-set-row-metadata)
      - [2.3.10.2 Get Row Data By Filter](#23102-get-row-by-data-filter)
      - [2.3.10.3 Update Row Data By Filter](#23103-update-row-by-data-filter)
      - [2.3.10.4 Delete Row By Data Filter](#23104-delete-row-by-data-filter)

## 1. Overview

Google Sheets, developed by Google LLC, enables users to interact programmatically with its platform, facilitating various tasks including data manipulation, analysis, and automation.

The Google Sheets connector provides a set of APIs tailored for connecting and interacting with Google Sheets API endpoints, specifically designed around [Google Sheets API v4](https://developers.google.com/sheets/api/guides/concepts). These APIs streamline integration allows developers to seamlessly perform spreadsheet management operations, worksheet management operations and the capability to handle Google Sheets data-level operations.

This specification defines the Ballerina Google Sheets connector and its components.

## 2. Client

The Google Sheets client facilitates connectivity with the Sheets API endpoint, enabling the execution of various operations.

### 2.1 Configurations

The connection configs can be used to provide configurations related to the Sheets client. Specifically, this can be used to provide the necessary auth tokens to connect to the Google Sheets API.

##### Example

```ballerina
ConnectionConfig config = {
    auth: {
        clientId: "client-id"
        clientSecret: "client-secret"
        refreshToken: "refresh-token"
        refreshUrl: "https://accounts.google.com/o/oauth2/token"
    }
}
```

### 2.2 Initialization

The client init method accepts a parameter `configs` of type `ConnectionConfigs`, and a default parameter `serviceUrl` of type string to initialize the client.

```ballerina
public isolated function init(ConnectionConfig config, service url = BASE_URL) returns error?;
```

##### Example

```ballerina
import ballerinax/googleapis.gsheets;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

gsheets:Client spreadsheetClient = check new ({
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl
    }
});
```

### 2.3 Supported operations

#### 2.3.1 Spreadsheet operations

##### 2.3.1.1 Create spreadsheet

The `createSpreadsheet` method can be used to create a new spreadsheet. It accepts a string type parameter named `name` and returns a `Spreadsheet` record or error in case of failure.

```ballerina
remote isolated function createSpreadsheet(string name) returns Spreadsheet|error;
```

##### 2.3.1.2 Open spreadsheet by id

The `openSpreadsheetById` method can be used to open an existing spreadsheet by providing its unique identifier. It accepts a string parameter `spreadsheetId`, which represents the unique identifier of the spreadsheet, and returns a `Spreadsheet` record if successful or an error if the operation fails.

```ballerina
remote isolated function openSpreadsheetById(string spreadsheetId) returns Spreadsheet|error;
```

##### 2.3.1.3 Open spreadsheet by URL

The `openSpreadsheetByUrl` method enables opening an existing spreadsheet by providing its URL. It accepts a string parameter `url`, representing the URL of the spreadsheet, and returns a `Spreadsheet` record if successful or an error if the operation fails.

```ballerina
remote isolated function openSpreadsheetByUrl(string url) returns Spreadsheet|error;
```

##### 2.3.1.4 Rename spreadsheet

The `renameSpreadsheet` method allows renaming an existing spreadsheet. It accepts two parameters `spreadsheetId`, which is a string representing the unique identifier of the spreadsheet to be renamed, and `name`, which is a string representing the new name for the spreadsheet. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function renameSpreadsheet(string spreadsheetId, string name) returns error?;
```

#### 2.3.2 Sheet operations

##### 2.3.2.1 Get all sheets

The `getSheets` method retrieves all sheets within a given spreadsheet identified by spreadsheet the id. It accepts a string parameter `spreadsheetId`, representing the unique identifier of the spreadsheet, and returns an array of Sheet records if successful or an error if the operation fails.

```ballerina
remote isolated function getSheets(string spreadsheetId) returns Sheet[]|error;
```

##### 2.3.2.2 Get sheet by name

The `getSheetByName` method retrieves a specific sheet from a spreadsheet identified by spreadsheet ID based on its sheet name. It accepts two parameters `spreadsheetId`, a string representing the unique identifier of the spreadsheet, and `sheetName`, a string representing the name of the sheet to retrieve. It returns a `Sheet` record if the sheet is found or an error if the operation fails.

```ballerina
remote isolated function getSheetByName(string spreadsheetId, string sheetName) returns Sheet|error;
```

##### 2.3.2.3 Add sheet

The `addSheet` method adds a new sheet to the specified spreadsheet identified by spreadsheet id with the provided sheet name. It accepts two parameters `spreadsheetId`, a string representing the unique identifier of the spreadsheet, and `sheetName`, a string representing the name of the new sheet to add. It returns a `Sheet` record representing the newly added sheet if successful or an error if the operation fails.

```ballerina
remote isolated function addSheet(string spreadsheetId, string sheetName) returns Sheet|error;
```

##### 2.3.2.4 Remove sheet

The `removeSheet` method removes a sheet from the specified spreadsheet identified by spreadsheet ID based on its sheet ID. It accepts two parameters `spreadsheetId`, a string representing the unique identifier of the spreadsheet, and `sheetId`, an int representing the identifier of the sheet to remove. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function removeSheet(string spreadsheetId, int sheetId) returns error?;
```

##### 2.3.2.5 Remove sheet by name

The `removeSheetByName` method removes a sheet from the specified spreadsheet identified by spreadsheet ID based on its sheet name. It accepts two parameters, `spreadsheetId`, a string representing the unique identifier of the spreadsheet, and `sheetName`, a string representing the name of the sheet to remove. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function removeSheetByName(string spreadsheetId, string sheetName) returns error?;
```

##### 2.3.2.6 Rename sheet

The `renameSheet` method renames a sheet within the specified spreadsheet identified by spreadsheet ID. It accepts three parameters, `spreadsheetId`, a string representing the unique identifier of the spreadsheet, `sheetName`, a string representing the current name of the sheet to rename, and `name`, a string representing the new name for the sheet. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function renameSheet(string spreadsheetId, string sheetName, string name) returns error?;
```

#### 2.3.3 Range operations

##### 2.3.3.1 Set range

The `setRange` method sets the values for a specified range within a sheet in the spreadsheet identified by spreadsheet ID. It accepts four parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetName`, representing the name of the sheet containing the range, `range`, representing the range to be set, and `valueInputOption`, representing the input option for the values. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function setRange(string spreadsheetId, string sheetName, Range range, string? valueInputOption = ()) returns error?;
```

##### 2.3.3.2 Get range

The `getRange` method retrieves the values for a specified range within a sheet in the spreadsheet identified by spreadsheet ID. It accepts four parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetName`, representing the name of the sheet containing the range, `a1Notation`, representing the A1 notation of the range, and `valueRenderOption`, representing the rendering option for the values. It returns a `Range` record if successful or an error if the operation fails.

```ballerina
remote isolated function getRange(string spreadsheetId, string sheetName, string a1Notation,string? valueRenderOption = ()) returns Range|error;
```

##### 2.3.3.3 Clear Range

The `clearRange` method clears the values for a specified range within a sheet in the spreadsheet identified by spreadsheet ID. It accepts three parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetName`, representing the name of the sheet containing the range, and `a1Notation`, representing the A1 notation of the range to be cleared. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function clearRange(string spreadsheetId, string sheetName, string a1Notation) returns error?;
```

#### 2.3.4 Column operations

##### 2.3.4.1 Add columns before

The `addColumnsBefore` method adds a specified number of columns before the given index in a sheet within the spreadsheet identified by spreadsheet ID. It accepts four parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetId`, representing the ID of the sheet, `index`, representing the index before which columns will be added, and `numberOfColumns`, representing the number of columns to add. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function addColumnsBefore(string spreadsheetId, int sheetId, int index, int numberOfColumns) returns error?;
```

##### 2.3.4.2 Add columns before by sheet name

The `addColumnsBeforeBySheetName` method adds a specified number of columns before the given index in a sheet within the spreadsheet identified by spreadsheet ID. It accepts four parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetName`, representing the name of the sheet, `index`, representing the index before which columns will be added, and `numberOfColumns`, representing the number of columns to add. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function addColumnsBeforeBySheetName(string spreadsheetId, string sheetName, int index, int numberOfColumns) returns error?
```

##### 2.3.4.3 Add columns after

The `addColumnsAfter` method adds a specified number of columns after the given index in a sheet within the spreadsheet identified by spreadsheet ID. It accepts four parameters, `spreadsheetId`, representing the unique identifier of the spreadsheet, `sheetId`, representing the ID of the sheet, `index`, representing the index after which columns will be added, and `numberOfColumns`, representing the number of columns to add. It returns an error if the operation encounters any issues.

```ballerina
remote isolated function addColumnsAfter(string spreadsheetId, int sheetId, int index, int numberOfColumns) returns error?;
```

##### 2.3.4.4 Add columns after by sheet name

The `addColumnsAfterBySheetName` method adds a specified number of columns after a given index in a sheet identified by its name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` of the sheet where columns need to be added, the `index` after which columns should be added, and the `numberOfColumns` to be added. It returns an error if the operation fails.

```ballerina
remote isolated function addColumnsAfterBySheetName(string spreadsheetId, string sheetName, int index, int numberOfColumns) returns error?;
```

##### 2.3.4.5 Create or update column

The `createOrUpdateColumn` method creates or updates a column in a specified sheet by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the column exists or should be created, the `column` identifier, an array of `values` to be populated in the column, and an optional `valueInputOption`. It returns an error if the operation fails.

```ballerina
remote isolated function createOrUpdateColumn(string spreadsheetId, string sheetName,  string column, (int|string|decimal)[] values, string? valueInputOption = ()) returns error?;
```

##### 2.3.4.6 Get column

The `getColumn` method retrieves a column from a specified sheet by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the column exists, the `column` identifier, and an optional `valueRenderOption` which determines how values should be rendered in the output. It returns a `Column` or an error if the operation fails.

```ballerina
remote isolated function getColumn(string spreadsheetId, string sheetName, string column, string? valueRenderOption = ()) returns Column|error;
```

##### 2.3.4.7 Delete columns

The `deleteColumns` method removes a specified number of columns starting from a specified column index in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where columns should be deleted, the `column` index of the starting column, and the `numberOfColumns` to be deleted. It returns an error if the operation fails.

```ballerina
remote isolated function deleteColumns(string spreadsheetId, int sheetId, int column, int numberOfColumns) returns error?;
```

##### 2.3.4.8 Delete columns by sheet name

The `deleteColumnsBySheetName` method deletes a specified number of columns starting from a specified column index in a sheet identified by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where columns should be deleted, the `column` index of the starting column, and the `numberOfColumns` to be deleted. It returns an error if the operation fails.

```ballerina
remote isolated function deleteColumnsBySheetName(string spreadsheetId, string sheetName, int column, int numberOfColumns) returns error?;
```

#### 2.3.5 Row operations

##### 2.3.5.1 Add rows before

The `addRowsBefore` method adds a specified number of rows before a given index in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where rows should be added, the `index` before which rows should be added, and the `numberOfRows` to be added. It returns an error if the operation fails.

```ballerina
remote isolated function addRowsBefore(string spreadsheetId, int sheetId, int index, int numberOfRows) returns error?;
```

##### 2.3.5.2 Add rows before by sheet name

The `addRowsBeforeBySheetName` method adds a specified number of rows before a given index in a sheet identified by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where rows should be added, the `index` before which rows should be added, and the `numberOfRows` to be added. It returns an error if the operation fails.

```ballerina
remote isolated function addRowsBeforeBySheetName(string spreadsheetId, string sheetName, int index, int numberOfRows) returns error?;
```

##### 2.3.5.3 Add rows after

The `addRowsAfter` method adds a specified number of rows after a given index in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the sheetId where rows should be added, the `index` after which rows should be added, and the `numberOfRows` to be added. It returns an error if the operation fails.

```ballerina
remote isolated function addRowsAfter(string spreadsheetId, int sheetId, int index, int numberOfRows) returns error?;
```

##### 2.3.5.4 Add rows after by sheet name

The `addRowsAfterBySheetName` method adds a specified number of rows after a given index in a sheet identified by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where rows should be added, the `index` after which rows should be added, and the `numberOfRows` to be added. It returns an error if the operation fails.

```ballerina
remote isolated function addRowsAfterBySheetName(string spreadsheetId, string sheetName, int index, int numberOfRows) returns error?;
```

##### 2.3.5.5 Create or update row

The `createOrUpdateRow` method creates or updates a row in a specified sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the row exists or should be created, the row number, an array of `values` to be populated in the row, and an optional `valueInputOption`. It returns an error if the operation fails.

```ballerina
remote isolated function createOrUpdateRow(string spreadsheetId, string sheetName, int row, (int|string|decimal)[] values, string? valueInputOption = ()) returns error?;
```

##### 2.3.5.6 Get row

The `getRow` method retrieves a row from a specified sheet by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the row exists, the `row` number, and an optional `valueRenderOption`. It returns a Row or an error if the operation fails.

```ballerina
remote isolated function getRow(string spreadsheetId, string sheetName, int row, string? valueRenderOption = ()) returns Row|error;
```

##### 2.3.5.7 Delete rows

The `deleteRows` method removes a specified number of rows starting from a specified row index in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where rows should be deleted, the `row` index of the starting row, and the `numberOfRows` to be deleted. It returns an error if the operation fails.

```ballerina
remote isolated function deleteRows(string spreadsheetId, int sheetId, int row, int numberOfRows) returns error?;
```

##### 2.3.5.8 Delete rows by sheet name

The `deleteRowsBySheetName` method deletes a specified number of rows starting from a given row index in a sheet identified by name. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where rows should be deleted, the `row` index of the starting row, and the `numberOfRows` to be deleted. It returns an error if the operation fails.

```ballerina
remote isolated function deleteRowsBySheetName(string spreadsheetId, string sheetName, int row, int numberOfRows) returns error?;
```

#### 2.3.6 Cell operations

##### 2.3.6.1 Set cell

The `setCell` method sets the value of a specified cell in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the cell exists, the `a1Notation` representing the cell location, the `value` to be set, and an optional `valueInputOption`. It returns an error if the operation fails.

```ballerina
remote isolated function setCell(string spreadsheetId, string sheetName, string a1Notation, int|string|decimal value, string? valueInputOption = ()) returns error?;
```

##### 2.3.6.2 Get cell

The `getCell` method retrieves the contents of a specified cell in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the cell exists, the `a1Notation` representing the cell location, and an optional `valueRenderOption`. It returns a `Cell` or an error if the operation fails.

```ballerina
remote isolated function getCell(string spreadsheetId, string sheetName, string a1Notation,string? valueRenderOption = ()) returns Cell|error;
```

##### 2.3.6.3 Clear cell

The `clearCell` method clears the contents of a specified cell in a sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the cell exists, and the `a1Notation` representing the cell location. It returns an error if the operation fails.

```ballerina
remote isolated function clearCell(string spreadsheetId, string sheetName, string a1Notation) returns error?;
```

#### 2.3.7 Append operations

##### 2.3.7.1 Append row to sheet

The `appendRowToSheet` method appends a row of values to the end of a specified sheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetName` where the row should be appended, an array of `values` to be appended, an optional `a1Notation`, and an optional `valueInputOption`. It returns an error if the operation fails.

```ballerina
remote isolated function appendRowToSheet(string spreadsheetId, string sheetName, (int|string|decimal)[] values, string? a1Notation = (), string? valueInputOption = ()) returns error?
```

##### 2.3.7.2 Append value

The `appendValue` method appends a single value to a specified range in a sheet. It requires the `spreadsheetId` of the target spreadsheet, an array of `values` to be appended, an `a1Range` representing the range where the values should be appended, and an optional `valueInputOption`. It returns a ValueRange or an error if the operation fails.

```ballerina
remote isolated function appendValue(string spreadsheetId, (int|string|decimal|boolean|float)[] values, A1Range a1Range,string? valueInputOption = ()) returns ValueRange|error;
```

##### 2.3.7.3 Append values

The `appendValues` method appends multiple values to a specified range in a sheet. It requires the `spreadsheetId` of the target spreadsheet, a 2D array of `values` to be appended, an `a1Range` representing the range where the values should be appended, and an optional `valueInputOption`. It returns a ValuesRange or an error if the operation fails.

```ballerina
remote isolated function appendValues(string spreadsheetId, (int|string|decimal|boolean|float)[][] values,A1Range a1Range,string? valueInputOption = ()) returns ValuesRange|error;
```

#### 2.3.8 Copy operations

##### 2.3.8.1 Copy to

The `copyTo` method copies the data from one sheet to another within the same spreadsheet or to a different spreadsheet. It requires the `spreadsheetId` of the source spreadsheet, the `sheetId` of the source sheet, and the `destinationId` where the data should be copied. It returns an error if the operation fails.

```ballerina
remote isolated function copyTo(string spreadsheetId, int sheetId, string destinationId) returns error?
```

##### 2.3.8.2 Copy to by sheet name

The `copyToBySheetName` method copies the data from one sheet to another within the same spreadsheet or to a different spreadsheet. It requires the `spreadsheetId` of the source spreadsheet, the `sheetName` of the source sheet, and the `destinationId` where the data should be copied. It returns an error if the operation fails.

```ballerina
remote isolated function copyToBySheetName(string spreadsheetId, string sheetName, string destinationId) returns error?;
```

#### 2.3.9 Clear operations

##### 2.3.9.1 Clear all

The `clearAll` method clears all the data in a specified sheet. It requires the `spreadsheetId` of the target spreadsheet and the `sheetId` of the sheet to be cleared. It returns an error if the operation fails.

```ballerina
remote isolated function clearAll(string spreadsheetId, int sheetId) returns error?;
```

##### 2.3.9.2 Clear all by sheet name

The `clearAllBySheetName` method clears all the data in a specified sheet identified by name. It requires the `spreadsheetId` of the target spreadsheet and the `sheetName` of the sheet to be cleared. It returns an error if the operation fails.

```ballerina
remote isolated function clearAllBySheetName(string spreadsheetId, string sheetName) eturns error?;
```

#### 2.3.10 Metadata and data filter operations

##### 2.3.10.1 Set row metadata

The `setRowMetaData` method allows setting metadata for a specific row in a spreadsheet. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where the row exists, the `rowIndex` indicating the row to which metadata should be applied, the visibility level of the metadata, the `key` representing the metadata key, and the `value` of the metadata. It returns an error if the operation fails.

```ballerina
remote isolated function setRowMetaData(string spreadsheetId, int sheetId, int rowIndex, Visibility visibility, string key, string value) returns error?;
```

##### 2.3.10.2 Get row by data filter

The `getRowByDataFilter` method retrieves rows from a specified sheet based on a data filter. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where the data is located, and a `filter` object specifying the criteria for filtering rows. It returns an array of `ValueRange` representing the matched rows or an error if the operation fails.

```ballerina
remote isolated function getRowByDataFilter(string spreadsheetId, int sheetId, Filter filter) returns ValueRange[]|error;
```

##### 2.3.10.3 Update row by data filter

The `updateRowByDataFilter` method updates rows in a specified sheet based on a data filter. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where the data is located, a `filter` object specifying the criteria for filtering rows, an array of `values` to be updated in the matched rows, and a `valueInputOption` specifying how the input data should be interpreted. It returns an error if the operation fails.

```ballerina
remote isolated function updateRowByDataFilter(string spreadsheetId, int sheetId, Filter filter, (int|string|decimal|boolean|float)[] values, string valueInputOption) returns error?;
```

##### 2.3.10.4 Delete row by data filter

The `deleteRowByDataFilter` method deletes rows in a specified sheet based on a data filter. It requires the `spreadsheetId` of the target spreadsheet, the `sheetId` where the data is located, and a `filter` object specifying the criteria for filtering rows to be deleted. It returns an error if the operation fails.

```ballerina
remote isolated function deleteRowByDataFilter(string spreadsheetId, int sheetId, Filter filter) returns error?;
```
