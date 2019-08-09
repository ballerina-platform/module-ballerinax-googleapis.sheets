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

import ballerina/'lang\.int as ints;

function convertToSpreadsheet(json jsonSpreadsheet) returns Spreadsheet {
    Spreadsheet spreadsheet = new;
    spreadsheet.spreadsheetId = jsonSpreadsheet.spreadsheetId.toString();
    json|error spreadsheetProperties= jsonSpreadsheet.properties;
    spreadsheet.properties = !(spreadsheetProperties is error)
                             ? convertToSpreadsheetProperties(spreadsheetProperties) : {};
    spreadsheet.spreadsheetUrl = jsonSpreadsheet.spreadsheetUrl.toString();
    spreadsheet.sheets = !(jsonSpreadsheet.sheets is error)
                         ? convertToSheets(<json[]> jsonSpreadsheet.sheets) : [];

    return spreadsheet;
}

function convertToSheets(json[] jsonSheets) returns Sheet[] {
    int i = 0;
    Sheet[] sheets = [];
    foreach json jsonSheet in jsonSheets {
        sheets[i] = convertToSheet(jsonSheet);
        i = i + 1;
    }
    return sheets;
}

function convertToSheet(json jsonSheet) returns Sheet {
    Sheet sheet = {};
    json|error spreadsheetProperties= jsonSheet.properties;
    sheet.properties = spreadsheetProperties != null
                       ? convertToSheetProperties(!(spreadsheetProperties is error) ? spreadsheetProperties : {}) : {};
    return sheet;
}

function convertToSpreadsheetProperties(json jsonProperties) returns SpreadsheetProperties {
    SpreadsheetProperties spreadsheetProperties = {};
    spreadsheetProperties.title = jsonProperties.title.toString();
    spreadsheetProperties.locale = jsonProperties.locale.toString();
    spreadsheetProperties.timeZone = jsonProperties.timeZone.toString();
    return spreadsheetProperties;
}

function convertToInt(string stringVal) returns int {
    if (stringVal != "") {
        var intVal = ints:fromString(stringVal);
        if (intVal is int) {
            return intVal;
        } else {
            error err = error(SPREADSHEET_ERROR_CODE,
                        message = "Error occurred when converting " + stringVal + " to int");
            panic err;
        }
    } else {
        return 0;
    }
}

function convertToBoolean(string stringVal) returns boolean {
    return stringVal == "true";
}

function convertToSheetProperties(json jsonSheetProperties) returns SheetProperties {
    SheetProperties sheetProperties = {};
    sheetProperties.title = jsonSheetProperties.title.toString();
    sheetProperties.sheetId = convertToInt(jsonSheetProperties.sheetId.toString());
    sheetProperties.index = convertToInt(jsonSheetProperties.index.toString());
    sheetProperties.sheetType = jsonSheetProperties.sheetType.toString();
    sheetProperties.hidden = !(jsonSheetProperties.hidden is error)
                             ? convertToBoolean(jsonSheetProperties.hidden.toString()) : false;
    sheetProperties.rightToLeft = !(jsonSheetProperties.rightToLeft is error)
                                  ? convertToBoolean(jsonSheetProperties.rightToLeft.toString()) : false;

    json|error gridProperties= jsonSheetProperties.gridProperties;
    sheetProperties.gridProperties = !(jsonSheetProperties.gridProperties is error)
                                     ? convertToGridProperties(!(gridProperties is error) ? gridProperties : {}) : {};
    return sheetProperties;
}

function convertToGridProperties(json jsonProps) returns GridProperties {
    GridProperties gridProperties = {};
    gridProperties.rowCount = !(jsonProps.rowCount is error) ? convertToInt(jsonProps.rowCount.toString()) : 0;
    gridProperties.columnCount = !(jsonProps.columnCount is error) ? convertToInt(jsonProps.columnCount.toString()) : 0;
    gridProperties.frozenRowCount = !(jsonProps.frozenRowCount is error)
                                    ? convertToInt(jsonProps.frozenRowCount.toString()) : 0;
    gridProperties.frozenColumnCount = !(jsonProps.frozenColumnCount is error)
                                       ? convertToInt(jsonProps.frozenColumnCount.toString()) : 0;
    gridProperties.hideGridlines = !(jsonProps.hideGridlines is error)
                                   ? convertToBoolean(jsonProps.hideGridlines.toString()) : false;
    return gridProperties;
}
