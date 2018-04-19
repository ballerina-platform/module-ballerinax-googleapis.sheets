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

function convertToSpreadsheet(json jsonSpreadsheet) returns Spreadsheet {
    Spreadsheet spreadsheet = new;
    spreadsheet.spreadsheetId = jsonSpreadsheet.spreadsheetId.toString();
    spreadsheet.properties = jsonSpreadsheet.properties != null ?
                             convertToSpreadsheetProperties(jsonSpreadsheet.properties) : {};
    spreadsheet.spreadsheetUrl = jsonSpreadsheet.spreadsheetUrl.toString();
    spreadsheet.sheets = jsonSpreadsheet.sheets != null ?
                         convertToSheets(jsonSpreadsheet.sheets, jsonSpreadsheet.spreadsheetId.toString()) : [];

    return spreadsheet;
}

function convertToSheets (json jsonSheets, string spreadsheetId) returns Sheet[] {
    int i = 0;
    Sheet[] sheets = [];
    foreach jsonSheet in jsonSheets {
        sheets[i] = convertToSheet(jsonSheet, spreadsheetId);
        i = i +1;
    }
    return sheets;
}

function convertToSheet(json jsonSheet, string spreadsheetId) returns Sheet {
    Sheet sheet = {};
    sheet.spreadsheetId = spreadsheetId;
    sheet.properties = jsonSheet.properties != null ? convertToSheetProperties(jsonSheet.properties) : {};
    return sheet;
}

function convertToSpreadsheetProperties(json jsonProperties) returns SpreadsheetProperties {
    SpreadsheetProperties spreadsheetProperties = {};
    spreadsheetProperties.title = jsonProperties.title.toString();
    spreadsheetProperties.locale = jsonProperties.locale.toString();
    spreadsheetProperties.timeZone = jsonProperties.timeZone.toString();
    return spreadsheetProperties;
}

function convertToInt(json jsonVal) returns (int){
    string stringVal = jsonVal.toString();
    return check <int> stringVal;
}

function convertToBoolean(json jsonVal) returns (boolean){
    string stringVal = jsonVal.toString();
    return <boolean> stringVal;
}

function convertToSheetProperties(json jsonSheetProperties) returns SheetProperties {
    SheetProperties sheetProperties = {};
    sheetProperties.title = jsonSheetProperties.title.toString();
    sheetProperties.sheetId = convertToInt(jsonSheetProperties.sheetId);
    sheetProperties.index = convertToInt(jsonSheetProperties.index);
    sheetProperties.sheetType = jsonSheetProperties.sheetType.toString();
    sheetProperties.hidden = jsonSheetProperties.hidden != null ? convertToBoolean(jsonSheetProperties.hidden) : false;
    sheetProperties.rightToLeft = jsonSheetProperties.rightToLeft != null ?
                                     convertToBoolean(jsonSheetProperties.rightToLeft) : false;
    sheetProperties.gridProperties = jsonSheetProperties.gridProperties != null ?
                                     convertToGridProperties(jsonSheetProperties.gridProperties) : {};
    return sheetProperties;
}

function convertToGridProperties(json jsonProps) returns GridProperties {
    GridProperties gridProperties = {};
    gridProperties.rowCount = jsonProps.rowCount != null ? convertToInt(jsonProps.rowCount) : 0;
    gridProperties.columnCount = jsonProps.columnCount != null ? convertToInt(jsonProps.columnCount) : 0;
    gridProperties.frozenRowCount = jsonProps.frozenRowCount != null ? convertToInt(jsonProps.frozenRowCount) : 0;
    gridProperties.frozenColumnCount = jsonProps.frozenColumnCount != null ?
                                       convertToInt(jsonProps.frozenColumnCount) : 0;
    gridProperties.hideGridlines = jsonProps.hideGridlines != null ? convertToBoolean(jsonProps.hideGridlines) : false;
    return gridProperties;
}
