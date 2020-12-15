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

import ballerina/lang.'int as ints;
import ballerina/log;

isolated function convertToSpreadsheet(json jsonSpreadsheet, Client spreadsheetClient) returns Spreadsheet {
    string id = jsonSpreadsheet.spreadsheetId.toString();
    json | error spreadsheetProperties = jsonSpreadsheet.properties;
    SpreadsheetProperties properties = !(spreadsheetProperties is error)
    ? convertToSpreadsheetProperties(spreadsheetProperties) : {};
    string spreadsheetUrl = jsonSpreadsheet.spreadsheetUrl.toString();
    Sheet[] sheets = [];
    json | error sheetsJson = jsonSpreadsheet.sheets;
    if (sheetsJson is error) {
        log:print("Could not retrieve the sheets");
    } else {
        sheets = convertToSheets(<json[]>jsonSpreadsheet.sheets, spreadsheetClient, id);
    }
    Spreadsheet spreadsheet = new (spreadsheetClient, id, properties, spreadsheetUrl, sheets);
    return spreadsheet;
}

isolated function convertToSheets(json[] jsonSheets, Client spreadsheetClient, string id) returns Sheet[] {
    int i = 0;
    Sheet[] sheets = [];
    foreach json jsonSheet in jsonSheets {
        sheets[i] = convertToSheet(jsonSheet, spreadsheetClient, id);
        i = i + 1;
    }
    return sheets;
}

isolated function convertToSheet(json jsonSheet, Client spreadsheetClient, string id) returns Sheet {
    json | error spreadsheetProperties = jsonSheet.properties;
    SheetProperties properties = !(spreadsheetProperties is error)
    ? convertToSheetProperties(spreadsheetProperties) : {};
    Sheet sheet = new (properties, spreadsheetClient, id);
    return sheet;
}

isolated function convertToSpreadsheetProperties(json jsonProperties) returns SpreadsheetProperties {
    SpreadsheetProperties spreadsheetProperties = {};
    spreadsheetProperties.title = jsonProperties.title.toString();
    spreadsheetProperties.locale = jsonProperties.locale.toString();
    spreadsheetProperties.timeZone = jsonProperties.timeZone.toString();
    return spreadsheetProperties;
}

isolated function convertToInt(string stringVal) returns int {
    if (stringVal != "") {
        var intVal = ints:fromString(stringVal);
        if (intVal is int) {
            return intVal;
        } else {
            panic error("Error occurred when converting " + stringVal + " to int");
        }
    } else {
        return 0;
    }
}

isolated function convertToBoolean(string stringVal) returns boolean {
    return stringVal == "true";
}

isolated function convertToSheetProperties(json jsonSheetProperties) returns SheetProperties {
    SheetProperties sheetProperties = {};
    sheetProperties.title = jsonSheetProperties.title.toString();
    sheetProperties.sheetId = convertToInt(jsonSheetProperties.sheetId.toString());
    sheetProperties.index = convertToInt(jsonSheetProperties.index.toString());
    sheetProperties.sheetType = jsonSheetProperties.sheetType.toString();
    sheetProperties.hidden = !(jsonSheetProperties.hidden is error)
    ? convertToBoolean(jsonSheetProperties.hidden.toString()) : false;
    sheetProperties.rightToLeft = !(jsonSheetProperties.rightToLeft is error)
    ? convertToBoolean(jsonSheetProperties.rightToLeft.toString()) : false;
    json | error gridProperties = jsonSheetProperties.gridProperties;
    sheetProperties.gridProperties = !(jsonSheetProperties.gridProperties is error)
    ? convertToGridProperties(!(gridProperties is error) ? gridProperties : {}) : {};
    return sheetProperties;
}

isolated function convertToGridProperties(json jsonProps) returns GridProperties {
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

isolated function convertToArray(json jsonResponse) returns (string | int | float)[][] {
    (string | int | float)[][] values = [];
    int i = 0;
    json[] jsonValues = <json[]>jsonResponse.values;
    foreach json value in jsonValues {
        json[] jsonValArray = <json[]>value;
        int j = 0;
        (string | int | float)[] val = [];
        foreach json v in jsonValArray {
            val[j] = getConvertedValue(v);
            j = j + 1;
        }
        values[i] = val;
        i = i + 1;
    }
    return values;
}
