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

@Description {value: "Struct to define the spreadsheet."}
public type Spreadsheet object {
    private {
        string spreadsheetId;
        SpreadsheetProperties properties;
        Sheet[] sheets;
        string spreadsheetUrl;
    }

    //Functions binded to Spreadsheet struct

    @Description {value : "Get the name of the spreadsheet"}
    @Param {value : "spreadsheet: Spreadsheet object"}
    @Return {value : "Name of the spreadsheet"}
    @Return{ value : "SpreadsheetError: Spreadsheet error"}
    public function getSpreadsheetName() returns (string) | SpreadsheetError {
        SpreadsheetError spreadsheetError = {};
        string title = "";
        if (self.properties == null) {
            spreadsheetError.errorMessage = "Spreadsheet properties cannot be null";
            return spreadsheetError;
        } else {
            return self.properties.title;
        }
    }

    @Description {value : "Get the name of the spreadsheet"}
    @Param {value : "spreadsheet: Spreadsheet object"}
    @Return {value : "Id of the spreadsheet"}
    public function getSpreadsheetId() returns (string) | SpreadsheetError {
        SpreadsheetError spreadsheetError = {};
        string spreadsheetId = "";
        if (self.spreadsheetId == null) {
            spreadsheetError.errorMessage = "Unable to find the spreadsheet id";
            return spreadsheetError;
        }
        return self.spreadsheetId;
    }

    @Description {value : "Get sheets of the spreadsheet"}
    @Param {value : "spreadsheet: Spreadsheet object"}
    @Return {value : "Sheet objects"}
    public function getSheets() returns Sheet[] | SpreadsheetError {
        SpreadsheetError spreadsheetError = {};
        if (self.sheets == null) {
            spreadsheetError.errorMessage = "No sheets found";
            return spreadsheetError;
        }
        return self.sheets;
    }

    @Description {value : "Get sheet by name"}
    @Param {value : "sheetName: Name of the sheet"}
    @Return {value : "sheet: Sheet object"}
    @Return{ value : "SpreadsheetError: Spreadsheet error"}
    public function getSheetByName(string sheetName) returns Sheet | SpreadsheetError {
        Sheet[] sheets = self.sheets;
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
            sheetResponse.spreadsheetId = self.spreadsheetId;
            return sheetResponse;
        }
    }
};

@Description {value: "Struct to define the spreadsheet properties."}
public type SpreadsheetProperties {
    string title;
    string locale;
    string autoRecalc;
    string timeZone;
};

@Description {value: "Struct to define the sheet."}
public type Sheet {
    string spreadsheetId;
    SheetProperties properties;
};

@Description {value: "Struct to define the sheet properties."}
public type SheetProperties {
    int sheetId;
    string title;
    int index;
    string sheetType;
    GridProperties gridProperties;
    boolean hidden;
    boolean rightToLeft;
};

@Description {value: "Struct to define the grid properties."}
public type GridProperties {
    int rowCount;
    int columnCount;
    int frozenRowCount;
    int frozenColumnCount;
    boolean hideGridlines;
};

@Description {value: "Struct to define the range."}
public type Range {
    Sheet sheet;
    string spreadsheetId;
    string a1Notation;
    int sheetId;
};

@Description {value: "Struct to define the error."}
public type SpreadsheetError {
    int statusCode;
    string errorMessage;
};
