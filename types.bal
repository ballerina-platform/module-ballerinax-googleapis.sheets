// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# Spreadsheet properties.
# + title - The title of the spreadsheet
# + locale - The locale of the spreadsheet
# + autoRecalc - The amount of time to wait before volatile functions are recalculated
# + timeZone - The time zone of the spreadsheet
public type SpreadsheetProperties record {|
    string title = "";
    string locale = "";
    string autoRecalc = "";
    string timeZone = "";
|};

# Sheet properties.
# + sheetId - The ID of the sheet
# + title - The name of the sheet
# + index - The index of the sheet within the spreadsheet
# + sheetType - The type of sheet
# + gridProperties - Additional properties of the sheet if this sheet is a grid
# + hidden - True if the sheet is hidden in the UI, false if it is visible
# + rightToLeft - True if the sheet is an RTL sheet instead of an LTR sheet
public type SheetProperties record {|
    int sheetId = 0;
    string title = "";
    int index = 0;
    string sheetType = "";
    GridProperties gridProperties = {};
    boolean hidden = false;
    boolean rightToLeft = false;
|};

# Grid properties.
# + rowCount - The number of rows in the grid
# + columnCount - The number of columns in the grid
# + frozenRowCount - The number of rows that are frozen in the grid
# + frozenColumnCount - The number of columns that are frozen in the grid
# + hideGridlines - True if the grid is not showing gridlines in the UI
public type GridProperties record {|
    int rowCount = 0;
    int columnCount = 0;
    int frozenRowCount = 0;
    int frozenColumnCount = 0;
    boolean hideGridlines = false;
|};

# Single cell or a group of adjacent cells in a sheet.
#
# + a1Notation - The column letter followed by the row number.
#               For example for a single cell "A1" refers to the intersection of column "A" with row "1",
#               and for a range of cells "A1:D5" refers to the top left cell and the bottom right cell of a range
# + values - Values of the given range
public type Range record {
   string a1Notation;
   (int|string|float)[][] values;
};

public type FilesResponse record {|
    string kind;
    boolean incompleteSearch;
    File[] files;
|};

public type File record {|
    string kind;
    string id;
    string name;
    string mimeType;
|};
