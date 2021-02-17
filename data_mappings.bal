// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/lang.array as arrlib;

isolated function convertJSONToSpreadsheet(json spreadsheetJsonObject) returns Spreadsheet|error {
    SpreadsheetProperties spreadsheetProperties = {};
    spreadsheetProperties.title = spreadsheetJsonObject.properties.title.toString();
    spreadsheetProperties.locale = spreadsheetJsonObject.properties.locale.toString();
    spreadsheetProperties.autoRecalc = spreadsheetJsonObject.properties.autoRecalc.toString();
    spreadsheetProperties.timeZone = spreadsheetJsonObject.properties.timeZone.toString();

    Spreadsheet spreadsheet = {};
    spreadsheet.spreadsheetId = spreadsheetJsonObject.spreadsheetId.toString();
    spreadsheet.properties = spreadsheetProperties;
    spreadsheet.sheets = check convertJSONToSheetArray(spreadsheetJsonObject.sheets);
    spreadsheet.spreadsheetUrl = spreadsheetJsonObject.spreadsheetUrl.toString();
    // spreadsheet1.properties = check spreadsheetJsonObject.properties.cloneWithType(SpreadsheetProperties);
    return spreadsheet;
}

isolated function convertJSONToSheetArray(json|error sheetListJson) returns Sheet[]|error {
    Sheet[] sheets = [];
    if (sheetListJson is json[]) { // When there are multiple sheets, it will be a json[]
        foreach json sheetJsonObject in sheetListJson {
            Sheet sheet = check convertJSONToSheet(sheetJsonObject);
            arrlib:push(sheets, sheet);
        }
    } else if (sheetListJson is json) { // When there is only one sheet, it will be a json
        Sheet sheet = check convertJSONToSheet(sheetListJson);
        arrlib:push(sheets, sheet);
    }
    return sheets;
}

isolated function convertJSONToSheet(json sheetJsonObject) returns Sheet|error {
    SheetProperties sheetProperties = {};
    sheetProperties.sheetId = convertToInt(sheetJsonObject.properties.sheetId.toString());
    sheetProperties.title = sheetJsonObject.properties.title.toString();
    sheetProperties.index = convertToInt(sheetJsonObject.properties.index.toString());
    sheetProperties.sheetType = sheetJsonObject.properties.sheetType.toString();
    sheetProperties.hidden = convertToBoolean(sheetJsonObject.properties.hidden.toString());
    sheetProperties.rightToLeft = convertToBoolean(sheetJsonObject.properties.rightToLeft.toString());
    sheetProperties.gridProperties = convertToGridProperties(check sheetJsonObject.properties.gridProperties);

    Sheet sheet = {};
    sheet.properties = sheetProperties;

    return sheet;
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

isolated function convertToFiles(json payload) returns File[]|error {
    FilesResponse|error res = payload.cloneWithType(FilesResponse);
    if (res is FilesResponse) {
        return res.files;
    } else {
        return res;
    }
}
