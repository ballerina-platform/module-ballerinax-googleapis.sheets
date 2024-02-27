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
    json|error title = spreadsheetJsonObject.properties.title;
    if title is json {
        spreadsheetProperties.title = title.toString();
    }
    json|error locale = spreadsheetJsonObject.properties.locale;
    if locale is json {
        spreadsheetProperties.locale = locale.toString();
    }
    json|error autoRecalc = spreadsheetJsonObject.properties.autoRecalc;
    if autoRecalc is json {
        spreadsheetProperties.autoRecalc = autoRecalc.toString();
    }
    json|error timeZone = spreadsheetJsonObject.properties.timeZone;
    if timeZone is json {
        spreadsheetProperties.timeZone = timeZone.toString();
    }

    Spreadsheet spreadsheet = {};
    json|error spreadsheetId = spreadsheetJsonObject.spreadsheetId;
    if spreadsheetId is json {
        spreadsheet.spreadsheetId = spreadsheetId.toString();
    }
    spreadsheet.properties = spreadsheetProperties;
    spreadsheet.sheets = check convertJSONToSheetArray(spreadsheetJsonObject.sheets);
    json|error spreadsheetUrl = spreadsheetJsonObject.spreadsheetUrl;
    if spreadsheetUrl is json {
        spreadsheet.spreadsheetUrl = spreadsheetUrl.toString();
    }
    // spreadsheet1.properties = check spreadsheetJsonObject.properties.cloneWithType(SpreadsheetProperties);
    return spreadsheet;
}

isolated function convertJSONToSheetArray(json|error sheetListJson) returns Sheet[]|error {
    Sheet[] sheets = [];
    if sheetListJson is json[] { // When there are multiple sheets, it will be a json[]
        foreach json sheetJsonObject in sheetListJson {
            Sheet sheet = check convertJSONToSheet(sheetJsonObject);
            arrlib:push(sheets, sheet);
        }
    } else if sheetListJson is json { // When there is only one sheet, it will be a json
        Sheet sheet = check convertJSONToSheet(sheetListJson);
        arrlib:push(sheets, sheet);
    }
    return sheets;
}

isolated function convertJSONToSheet(json sheetJsonObject) returns Sheet|error {
    SheetProperties sheetProperties = {};
    json|error sheetId = sheetJsonObject.properties.sheetId;
    if sheetId is json {
        sheetProperties.sheetId = convertToInt(sheetId.toString());
    }
    json|error title = sheetJsonObject.properties.title;
    if title is json {
        sheetProperties.title = title.toString();
    }
    json|error index = sheetJsonObject.properties.index;
    if index is json {
        sheetProperties.index = convertToInt(index.toString());
    }
    json|error sheetType = sheetJsonObject.properties.sheetType;
    if sheetType is json {
        sheetProperties.sheetType = sheetType.toString();
    }
    json|error hidden = sheetJsonObject.properties.hidden;
    if hidden is json {
        sheetProperties.hidden = convertToBoolean(hidden.toString());
    }
    json|error rightToLeft = sheetJsonObject.properties.rightToLeft;
    if rightToLeft is json {
        sheetProperties.rightToLeft = convertToBoolean(rightToLeft.toString());
    }
    sheetProperties.gridProperties = convertToGridProperties(check sheetJsonObject.properties.gridProperties);

    Sheet sheet = {};
    sheet.properties = sheetProperties;

    return sheet;
}

isolated function convertToGridProperties(json jsonProps) returns GridProperties {
    GridProperties gridProperties = {};
    json|error rowCount = jsonProps.rowCount;
    gridProperties.rowCount = rowCount is json ? convertToInt(rowCount.toString()) : 0;
    json|error columnCount = jsonProps.columnCount;
    gridProperties.columnCount = columnCount is json ? convertToInt(columnCount.toString()) : 0;
    json|error frozenRowCount = jsonProps.frozenRowCount;
    gridProperties.frozenRowCount = frozenRowCount is json ? convertToInt(frozenRowCount.toString()) : 0;
    json|error frozenColumnCount = jsonProps.frozenColumnCount;
    gridProperties.frozenColumnCount = frozenColumnCount is json ? convertToInt(frozenColumnCount.toString()) : 0;
    json|error hideGridlines = jsonProps.hideGridlines;
    gridProperties.hideGridlines = hideGridlines is json ? convertToBoolean(hideGridlines.toString()) : false;
    return gridProperties;
}

isolated function convertToInt(string stringVal) returns int {
    if stringVal != "" {
        int|error intVal = ints:fromString(stringVal);
        if intVal is int {
            return intVal;
        }
        panic error("Error occurred when converting " + stringVal + " to int");
    }
    return 0;
}

isolated function convertToBoolean(string stringVal) returns boolean {
    return stringVal == "true";
}

isolated function convertToArray(json jsonResponse) returns (string|int|decimal)[][] {
    (string|int|decimal)[][] values = [];
    int i = 0;
    json|error jsonResponseValues = jsonResponse.values;
    json[] jsonValues = [];
    if jsonResponseValues is json[] {
        jsonValues = jsonResponseValues;
    }
    foreach json value in jsonValues {
        json[] jsonValArray = <json[]>value;
        int j = 0;
        (string|int|decimal)[] val = [];
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
    FilesResponse res = check payload.cloneWithType(FilesResponse);
    return res.files;
}
