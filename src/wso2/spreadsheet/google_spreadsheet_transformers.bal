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

package src.wso2.spreadsheet;

transformer <json jsonSpreadsheet, Spreadsheet spreadsheet> convertToSpreadsheet() {
    spreadsheet.spreadsheetId = jsonSpreadsheet.spreadsheetId.toString();
    spreadsheet.properties = jsonSpreadsheet.properties != null ?
                             <SpreadsheetProperties, convertToSpreadsheetProperties()>jsonSpreadsheet.properties : {};
    spreadsheet.spreadsheetUrl = jsonSpreadsheet.spreadsheetUrl.toString();
    spreadsheet.sheets = jsonSpreadsheet.sheets != null ?
                         convertToSheets(jsonSpreadsheet.sheets, jsonSpreadsheet.spreadsheetId.toString()):[];
    spreadsheet.namedRanges = jsonSpreadsheet.namedRanges != null ?
                              convertToNamedRanges(jsonSpreadsheet.namedRanges) : [];
}

function convertToSheets (json jsonSheets, string spreadsheetId) returns Sheet[] {
    int i = 0;
    Sheet[] sheets = [];
    foreach jsonSheet in jsonSheets {
        sheets[i] = <Sheet, convertToSheet(spreadsheetId)> jsonSheet;
        i = i +1;
    }
    return sheets;
}

function convertToNamedRanges(json jsonNamedRanges) returns NamedRange[] {
    int i = 0;
    NamedRange[] namedRanges = [];
    foreach jsonNamedRange in jsonNamedRanges {
        namedRanges[i] = <NamedRange, convertToNamedRange()>jsonNamedRange;
        i = i + 1;
    }
    return namedRanges;
}

transformer <json jsonRange, NamedRange namedRange> convertToNamedRange() {
    namedRange.name = jsonRange.namedRange.toString();
    namedRange.namedRangeId = jsonRange.namedRangeId.toString();
    namedRange.range = jsonRange.range != null ? <GridRange, convertToGridRange()>jsonRange.range : {};
}

transformer <json jsonGridRange, GridRange range> convertToGridRange() {
    range.sheetId = <int, convertToInt()>jsonGridRange.sheetId;
    range.startRowIndex = <int, convertToInt()>jsonGridRange.startRowIndex;
    range.startColumnIndex = <int, convertToInt()>jsonGridRange.startColumnIndex;
    range.endRowIndex = <int, convertToInt()>jsonGridRange.endRowIndex;
    range.endColumnIndex = <int, convertToInt()>jsonGridRange.endColumnIndex;
}

transformer <json jsonProperties, SpreadsheetProperties spreadsheetProperties> convertToSpreadsheetProperties() {
    spreadsheetProperties.title = jsonProperties.title.toString();
    spreadsheetProperties.locale = jsonProperties.locale.toString();
    spreadsheetProperties.timeZone = jsonProperties.timeZone.toString();
}

transformer <json jsonVal, int intVal> convertToInt() {
    var value, conversionErr = (int) jsonVal;
    intVal = conversionErr == null ? value : 0;
}

transformer <json jsonVal, float floatVal> convertToFloat() {
    var value, conversionErr = (float) jsonVal;
    floatVal = conversionErr == null ? value : 0;
}

transformer <json jsonVal, boolean booleanVal> convertToBoolean() {
    var value, conversionErr = (boolean) jsonVal;
    booleanVal = conversionErr == null ? value : false;
}

transformer <json jsonSheet, Sheet sheet> convertToSheet(string spreadsheetId) {
    sheet.spreadsheetId = spreadsheetId;
    sheet.properties = jsonSheet.properties != null ?
                       <SheetProperties, convertToSheetProperties()>jsonSheet.properties : {};
}

transformer <json jsonSheetProperties, SheetProperties sheetProperties> convertToSheetProperties() {
    sheetProperties.title = jsonSheetProperties.title.toString();
    sheetProperties.sheetId = <int, convertToInt()> jsonSheetProperties.sheetId;
    sheetProperties.index = <int, convertToInt()> jsonSheetProperties.index;
    sheetProperties.sheetType = jsonSheetProperties.sheetType.toString();
    sheetProperties.hidden = jsonSheetProperties.hidden != null ?
                             <boolean, convertToBoolean()>jsonSheetProperties.hidden : false;
    sheetProperties.rightToLeft = jsonSheetProperties.rightToLeft != null ?
                                  <boolean, convertToBoolean()>jsonSheetProperties.rightToLeft : false;
    sheetProperties.gridProperties = jsonSheetProperties.gridProperties != null ?
                                     <GridProperties, convertToGridProperties()>jsonSheetProperties.gridProperties : {};
}

transformer <json jsonProps, GridProperties gridProperties> convertToGridProperties() {
    gridProperties.rowCount = jsonProps.rowCount != null ? <int, convertToInt()>jsonProps.rowCount : 0;
    gridProperties.columnCount = jsonProps.columnCount != null ? <int, convertToInt()>jsonProps.columnCount : 0;
    gridProperties.frozenRowCount = jsonProps.frozenRowCount != null ?
                                    <int, convertToInt()>jsonProps.frozenRowCount : 0;
    gridProperties.frozenColumnCount = jsonProps.frozenColumnCount != null ?
                                       <int, convertToInt()>jsonProps.frozenColumnCount : 0;
    gridProperties.hideGridlines = jsonProps.hideGridlines != null ?
                                   <boolean, convertToBoolean()>jsonProps.hideGridlines : false;
}

transformer <json jsonRange, Range range> convertToRange() {
    range.spreadsheetId = jsonRange.spreadsheetId.toString();
    range.a1Notation = jsonRange.updatedRange.toString();
}