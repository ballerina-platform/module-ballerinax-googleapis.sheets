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
    json | error spreadsheetId = jsonSpreadsheet.spreadsheetId;
    string id = "";
    if (spreadsheetId is error) {
        panic error("Could not retrieve spreadsheetId");
    } else {
        id = spreadsheetId.toString();
    }

    json | error spreadsheetProperties = jsonSpreadsheet.properties;
    SpreadsheetProperties properties = !(spreadsheetProperties is error)
    ? convertToSpreadsheetProperties(spreadsheetProperties) : {};

    json | error spreadsheetUrlJson = jsonSpreadsheet.spreadsheetUrl;
    string spreadsheetUrl = "";
    if (spreadsheetUrlJson is error) {
        panic error("Could not retrieve spreadsheetUrl");
    } else {
        spreadsheetUrl = spreadsheetUrlJson.toString();
    }

    Sheet[] sheets = [];
    json | error sheetsJson = jsonSpreadsheet.sheets;
    if (sheetsJson is error) {
        log:print("Could not retrieve the sheets");
    } else {
        sheets = convertToSheets(<json[]>sheetsJson, spreadsheetClient, id);
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
    json | error title = jsonProperties.title;
    json | error locale = jsonProperties.locale;
    json | error timeZone = jsonProperties.timeZone;

    if (title is error) {
        panic error("Could not retrieve title");
    } else {
        spreadsheetProperties.title = title.toString();
    }

    if (locale is error) {
        panic error("Could not retrieve locale");
    } else {
        spreadsheetProperties.locale = locale.toString();
    }

    if (timeZone is error) {
        panic error("Could not retrieve timeZone");
    } else {
        spreadsheetProperties.timeZone = timeZone.toString();
    }

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

    json | error title = jsonSheetProperties.title;
    json | error sheetId = jsonSheetProperties.sheetId;
    json | error index = jsonSheetProperties.index;
    json | error sheetType = jsonSheetProperties.sheetType;
    json | error hidden = jsonSheetProperties.hidden;
    json | error rightToLeft = jsonSheetProperties.rightToLeft;

    if (title is error) {
        panic error("Could not retrieve title");
    } else {
        sheetProperties.title = title.toString();
    }

    if (sheetId is error) {
        panic error("Could not retrieve sheetId");
    } else {
        sheetProperties.sheetId = convertToInt(sheetId.toString());
    }

    if (index is error) {
        panic error("Could not retrieve index");
    } else {
        sheetProperties.index = convertToInt(index.toString());
    }

    if (sheetType is error) {
        panic error("Could not retrieve sheetType");
    } else {
        sheetProperties.sheetType = sheetType.toString();
    }

    if (hidden is error) {
        sheetProperties.hidden = false;
    } else {
        sheetProperties.hidden = convertToBoolean(hidden.toString());
    }

    if (rightToLeft is error) {
        sheetProperties.rightToLeft = false;
    } else {
        sheetProperties.rightToLeft = convertToBoolean(rightToLeft.toString());
    }

    json | error gridProperties = jsonSheetProperties.gridProperties;
    sheetProperties.gridProperties = !(jsonSheetProperties.gridProperties is error)
    ? convertToGridProperties(!(gridProperties is error) ? gridProperties : {}) : {};
    return sheetProperties;
}

isolated function convertToGridProperties(json jsonProps) returns GridProperties {
    GridProperties gridProperties = {};

    json | error rowCount = jsonProps.rowCount;
    json | error columnCount = jsonProps.columnCount;
    json | error frozenRowCount = jsonProps.frozenRowCount;
    json | error frozenColumnCount = jsonProps.frozenColumnCount;
    json | error hideGridlines = jsonProps.hideGridlines;

    if (rowCount is error) {
        gridProperties.rowCount = 0;
    } else {
        gridProperties.rowCount = convertToInt(rowCount.toString());
    }

    if (columnCount is error) {
        gridProperties.columnCount = 0;
    } else {
        gridProperties.columnCount = convertToInt(columnCount.toString());
    }

    if (frozenRowCount is error) {
        gridProperties.frozenRowCount = 0;
    } else {
        gridProperties.frozenRowCount = convertToInt(frozenRowCount.toString());
    }

    if (frozenColumnCount is error) {
        gridProperties.frozenColumnCount = 0;
    } else {
        gridProperties.frozenColumnCount = convertToInt(frozenColumnCount.toString());
    }

    if (hideGridlines is error) {
        gridProperties.hideGridlines = false;
    } else {
        gridProperties.hideGridlines = convertToBoolean(hideGridlines.toString());
    }

    return gridProperties;
}

isolated function convertToArray(json jsonResponse) returns (string | int | float)[][] {
    (string | int | float)[][] values = [];
    int i = 0;

    json[] jsonValues = [];
    json | error valuesJson = jsonResponse.values;
    if (valuesJson is error) {
        panic error("Could not retrieve values");
    } else {
        jsonValues = <json[]>valuesJson;
    }
    
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
