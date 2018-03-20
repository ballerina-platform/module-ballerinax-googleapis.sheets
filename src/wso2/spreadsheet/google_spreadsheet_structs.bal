// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package src.wso2.spreadsheet;

@Description {value: "Struct to define the spreadsheet."}
public struct Spreadsheet {
    string spreadsheetId;
    SpreadsheetProperties properties;
    Sheet[] sheets;
    NamedRange[] namedRanges;
    string spreadsheetUrl;
}

@Description {value: "Struct to define the named range."}
public struct NamedRange {
    string namedRangeId;
    string name;
    GridRange range;
}

@Description {value: "Struct to define the spreadsheet properties."}
public struct SpreadsheetProperties {
    string title;
    string locale;
    string autoRecalc;
    string timeZone;
}

@Description {value: "Struct to define the sheet."}
public struct Sheet {
    string spreadsheetId;
    SheetProperties properties;
}

@Description {value: "Struct to define the sheet properties."}
public struct SheetProperties {
    int sheetId;
    string title;
    int index;
    string sheetType;
    GridProperties gridProperties;
    boolean hidden;
    boolean rightToLeft;
}

@Description {value: "Struct to define the grid properties."}
public struct GridProperties {
    int rowCount;
    int columnCount;
    int frozenRowCount;
    int frozenColumnCount;
    boolean hideGridlines;
}

@Description {value: "Struct to define the grid range."}
public struct GridRange {
    int sheetId;
    int startRowIndex;
    int endRowIndex;
    int startColumnIndex;
    int endColumnIndex;
}

@Description {value: "Struct to define the range."}
public struct Range {
    Sheet sheet;
    string spreadsheetId;
    string a1Notation;
    int sheetId;
}

@Description {value: "Struct to define the error."}
public struct SpreadsheetError {
    int statusCode;
    string errorMessage;
}

//Functions binded to Spreadsheet struct

@Description {value : "Get the name of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Name of the spreadsheet"}
public function <Spreadsheet spreadsheet> getSpreadsheetName() (string, SpreadsheetError) {
    SpreadsheetError spreadsheetError = {};
    string title = "";
    if (spreadsheet.properties == null) {
        spreadsheetError.errorMessage = "Spreadsheet properties cannot be null";
    } else {
        title = spreadsheet.properties.title;
    }
    return title, spreadsheetError;
}

@Description {value : "Get the name of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Id of the spreadsheet"}
public function <Spreadsheet spreadsheet> getSpreadsheetId() (string) {
    return spreadsheet.spreadsheetId;
}

@Description {value : "Get sheets of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Sheet objects"}
public function <Spreadsheet spreadsheet> getSheets() (Sheet[]) {
    return spreadsheet.sheets;
}

@Description {value : "Get sheet by name"}
@Param {value : "sheetName: Name of the sheet"}
@Return {value : "sheet: Sheet object"}
public function <Spreadsheet spreadsheet> getSheetByName(string sheetName) (Sheet, SpreadsheetError){
    Sheet[] sheets = spreadsheet.sheets;
    Sheet sheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    if (sheets == null) {
        spreadsheetError.errorMessage = "No sheet found";
    } else {
        foreach sheet in sheets {
            if (sheet.properties != null) {
                if (sheet.properties.title.equalsIgnoreCase(sheetName)) {
                    sheetResponse = sheet;
                    break;
                }
            }
        }
        sheetResponse.spreadsheetId = spreadsheet.spreadsheetId;
    }
    return sheetResponse, spreadsheetError;
}

//Functions binded to Sheet struct

@Description {value : "Get data range of a sheet"}
@Return {value : "range: Range object"}
public function <Sheet sheet> getDataRange() (Range) {
    Range range = {};
    range.sheet = sheet;
    range.a1Notation = sheet.properties.title;
    range.spreadsheetId = sheet.spreadsheetId;
    return range;
}

@Description {value : "Get range of a sheet"}
@Param {value: "a1Notation: The A1 notation of the range"}
@Return {value : "range: Range object"}
public function <Sheet sheet> getRange(string topLeftCell, string bottomRightCell) (Range, SpreadsheetError){
    Range range = {};
    SpreadsheetError spreadsheetError = {};
    range.sheet = sheet;
    if (sheet.properties == null || sheet.properties.title == "") {
        spreadsheetError.errorMessage = "Sheet title cannot be null";
        return null, spreadsheetError;
    }
    string a1Notation = sheet.properties.title + "!" + topLeftCell;
    if (bottomRightCell != "" && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    range.a1Notation = a1Notation;
    range.spreadsheetId = sheet.spreadsheetId;
    return range, spreadsheetError;
}

@Description {value : "Get column data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "column: The column to retrieve the values"}
@Return {value : "Column data"}
public function <Sheet sheet> getColumnData(string column) (string[], SpreadsheetError){
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    if (sheet.spreadsheetId =="" || sheet.properties == null || sheet.properties.title == "") {
        spreadsheetError.errorMessage = "Spreadsheet Id or sheet title cannot be null";
        return null, spreadsheetError;
    }
    string a1Notation = sheet.properties.title + "!" + column + ":" + column;
    return gsClientGlobal.getColumnData(sheet.spreadsheetId, a1Notation);
}

@Description {value : "Get row data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "row: The row to retrieve the values"}
@Return {value : "Row data"}
public function <Sheet sheet> getRowData(string row) (string[], SpreadsheetError){
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    if (sheet.spreadsheetId =="" || sheet.properties == null || sheet.properties.title == "") {
        spreadsheetError.errorMessage = "Spreadsheet Id or sheet title cannot be null";
        return null, spreadsheetError;
    }
    string a1Notation = sheet.properties.title + "!" + row + ":" + row;
    return gsClientGlobal.getRowData(sheet.spreadsheetId, a1Notation);
}

@Description {value : "Get cell data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "row: The row of the cell to retrieve the value"}
@Param {value: "column: The column of the cell to retrieve the value"}
@Return {value : "Cell data"}
public function <Sheet sheet> getCellData(string column, string row) (string, SpreadsheetError){
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    if (sheet.spreadsheetId =="" || sheet.properties == null || sheet.properties.title == "") {
        spreadsheetError.errorMessage = "Spreadsheet Id or sheet title cannot be null";
        return null, spreadsheetError;
    }
    string a1Notation = sheet.properties.title + "!" + column + row;
    return gsClientGlobal.getCellData(sheet.spreadsheetId, a1Notation);
}

@Description {value : "Set cell data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "row: The row of the cell to retrieve the value"}
@Param {value: "column: The column of the cell to retrieve the value"}
@Return {value : "Cell data"}
public function <Sheet sheet> setCellData(string column, string row, string value) (Range, SpreadsheetError){
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    if (sheet.spreadsheetId =="" || sheet.properties == null || sheet.properties.title == "") {
        spreadsheetError.errorMessage = "Spreadsheet Id or sheet title cannot be null";
        return null, spreadsheetError;
    }
    string a1Notation = sheet.properties.title + "!" + column + row;
    return gsClientGlobal.setValue(sheet.spreadsheetId, a1Notation, value);
}

//Functions binded to Range struct
@Description {value : "Get sheet values"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Return {value : "Sheet values"}
public function <Range range> getSheetValues() (string[][], SpreadsheetError) {
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    return gsClientGlobal.getSheetValues(range.spreadsheetId, range.a1Notation);
}

@Description {value : "Set cell data"}
@Param {value: "googleSpreadsheetClientConnector: Google Spreadsheet Connector instance"}
@Param {value: "value: The value to set"}
@Return {value : "Updated range"}
public function <Range range> setValue(string value) (Range, SpreadsheetError) {
    SpreadsheetError spreadsheetError = {};
    if (!isConnectorInitialized) {
        spreadsheetError.errorMessage = "Connector is not initalized. Invoke init method first.";
        return null, spreadsheetError;
    }
    return gsClientGlobal.setValue(range.spreadsheetId, range.a1Notation, value);
}