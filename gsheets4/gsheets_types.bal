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

documentation {
    F{{spreadsheetId}} - Id of the spreadsheet
    F{{properties}} - Properties of a spreadsheet
    F{{sheets}} - The sheets that are part of a spreadsheet
    F{{spreadsheetUrl}} - The url of the spreadsheet
}
public type Spreadsheet object {
    public {
        string spreadsheetId;
        SpreadsheetProperties properties;
        Sheet[] sheets;
        string spreadsheetUrl;
    }

    documentation {Get the name of the spreadsheet
        R{{}} - Name of the spreadsheet object on success and SpreadsheetError on failure
    }
    public function getSpreadsheetName() returns (string)|SpreadsheetError;

    documentation {Get the Id of the spreadsheet
        R{{}} - Id of the spreadsheet object on success and SpreadsheetError on failure
    }
    public function getSpreadsheetId() returns (string)|SpreadsheetError;

    documentation {Get sheets of the spreadsheet
        R{{}} - Sheet array on success and SpreadsheetError on failure
    }
    public function getSheets() returns Sheet[]|SpreadsheetError;

    documentation {Get sheets of the spreadsheet
        P{{sheetName}} - Name of the sheet to retrieve
        R{{}} - Sheet object on success and SpreadsheetError on failure
    }
    public function getSheetByName(string sheetName) returns Sheet|SpreadsheetError;
};

documentation {Spreadsheet properties
    F{{title}} - The title of the spreadsheet
    F{{locale}} - The locale of the spreadsheet
    F{{autoRecalc}} - The amount of time to wait before volatile functions are recalculated
    F{{timeZone}} - The time zone of the spreadsheet
}
public type SpreadsheetProperties {
    string title;
    string locale;
    string autoRecalc;
    string timeZone;
};

documentation {Sheet object
    F{{spreadsheetId}} - The Id of the parent spreadsheet
    F{{properties}} - The properties of the sheet
}
public type Sheet {
    string spreadsheetId;
    SheetProperties properties;
};

documentation {Sheet properties
    F{{sheetId}} - The ID of the sheet
    F{{title}} - The name of the sheet
    F{{index}} - The index of the sheet within the spreadsheet
    F{{sheetType}} - The type of sheet
    F{{gridProperties}} - Additional properties of the sheet if this sheet is a grid
    F{{hidden}} - True if the sheet is hidden in the UI, false if it is visible
    F{{rightToLeft}} - True if the sheet is an RTL sheet instead of an LTR sheet
}
public type SheetProperties {
    int sheetId;
    string title;
    int index;
    string sheetType;
    GridProperties gridProperties;
    boolean hidden;
    boolean rightToLeft;
};

documentation {Grid properties
    F{{rowCount}} - The number of rows in the grid
    F{{columnCount}} - The number of columns in the grid
    F{{frozenRowCount}} - The number of rows that are frozen in the grid
    F{{frozenColumnCount}} - The number of columns that are frozen in the grid
    F{{hideGridlines}} - True if the grid is not showing gridlines in the UI
}
public type GridProperties {
    int rowCount;
    int columnCount;
    int frozenRowCount;
    int frozenColumnCount;
    boolean hideGridlines;
};

documentation {Spreadsheet error
    F{{message}} - Error message
    F{{cause}} - The error which caused the GMail error
    F{{statusCode}} - The status code
}
public type SpreadsheetError {
    string message;
    error? cause;
    int statusCode;
};

//Functions binded to Spreadsheet struct
public function Spreadsheet::getSpreadsheetName() returns (string)|SpreadsheetError {
    SpreadsheetError spreadsheetError = {};
    string title = "";
    if (self.properties == null) {
        spreadsheetError.message = "Spreadsheet properties cannot be null";
        return spreadsheetError;
    } else {
        return self.properties.title;
    }
}

public function Spreadsheet::getSpreadsheetId() returns (string)|SpreadsheetError {
    SpreadsheetError spreadsheetError = {};
    string spreadsheetId = "";
    if (self.spreadsheetId == null) {
        spreadsheetError.message = "Unable to find the spreadsheet id";
        return spreadsheetError;
    }
    return self.spreadsheetId;
}

public function Spreadsheet::getSheets() returns Sheet[]|SpreadsheetError {
    SpreadsheetError spreadsheetError = {};
    if (self.sheets == null) {
        spreadsheetError.message = "No sheets found";
        return spreadsheetError;
    }
    return self.sheets;
}

public function Spreadsheet::getSheetByName(string sheetName) returns Sheet|SpreadsheetError {
    Sheet[] sheets = self.sheets;
    Sheet sheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    if (sheets == null) {
        spreadsheetError.message = "No sheet found";
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
