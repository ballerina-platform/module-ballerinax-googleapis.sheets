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

package googlespreadsheet4;

@Description {value:"Struct to initialize the Spreadsheet connector."}
public struct SpreadsheetConnector {
    oauth2:OAuth2Endpoint oauth2EP;
}

@Description {value:"Struct to define the Google Spreadsheet configuration."}
public struct SpreadsheetConfiguration {
    oauth2:OAuth2Configuration oauthClientConfig;
}

@Description {value:"Google Spreadsheet Endpoint struct."}
public struct SpreadsheetEndpoint {
    SpreadsheetConfiguration spreadsheetConfig;
    SpreadsheetConnector spreadsheetConnector;
}

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
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <Spreadsheet spreadsheet> getSpreadsheetName() returns (string) | SpreadsheetError {
    SpreadsheetError spreadsheetError = {};
    string title = "";
    if (spreadsheet.properties == null) {
        spreadsheetError.errorMessage = "Spreadsheet properties cannot be null";
        return spreadsheetError;
    } else {
        return spreadsheet.properties.title;
    }
}

@Description {value : "Get the name of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Id of the spreadsheet"}
public function <Spreadsheet spreadsheet> getSpreadsheetId() returns (string) | SpreadsheetError {
    SpreadsheetError spreadsheetError = {};
    string spreadsheetId = "";
    if (spreadsheet.spreadsheetId == null) {
        spreadsheetError.errorMessage = "Unable to find the spreadsheet id";
        return spreadsheetError;
    }
    return spreadsheet.spreadsheetId;
}

@Description {value : "Get sheets of the spreadsheet"}
@Param {value : "spreadsheet: Spreadsheet object"}
@Return {value : "Sheet objects"}
public function <Spreadsheet spreadsheet> getSheets() returns Sheet[] | SpreadsheetError {
    Sheet[] sheets = [];
    SpreadsheetError spreadsheetError = {};
    if (spreadsheet.sheets == null) {
        spreadsheetError.errorMessage = "No sheets found";
        return spreadsheetError;
    }
    return spreadsheet.sheets;
}

@Description {value : "Get sheet by name"}
@Param {value : "sheetName: Name of the sheet"}
@Return {value : "sheet: Sheet object"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <Spreadsheet spreadsheet> getSheetByName(string sheetName) returns Sheet | SpreadsheetError {
    Sheet[] sheets = spreadsheet.sheets;
    Sheet sheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    if (sheets == null) {
        spreadsheetError.errorMessage = "No sheet found";
        return spreadsheetError;
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
        return sheetResponse;
    }
}
