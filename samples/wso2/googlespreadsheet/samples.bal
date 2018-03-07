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

import src.wso2.googlespreadsheet;
import ballerina.io;

function main (string[] args) {
    endpoint<googlespreadsheet:GoogleSpreadsheetClientConnector> googlespreadsheetEP {
    }
    googlespreadsheet:GoogleSpreadsheetClientConnector googlespreadsheetConnector =
    create googlespreadsheet:GoogleSpreadsheetClientConnector(args[1], args[2], args[3], args[4]);
    bind googlespreadsheetConnector with googlespreadsheetEP;
    googlespreadsheet:SpreadsheetError spreadsheetError = {};
    googlespreadsheet:Spreadsheet spreadsheet = {};
    googlespreadsheet:Sheet sheet = {};
    googlespreadsheet:Range range = {};
    string[] values = [];
    string sheetName = "RainFallValues";

    //Open th spreadsheet by id
    spreadsheet, spreadsheetError = googlespreadsheetEP.openById(args[5]);

    //Get the sheet
    sheet, spreadsheetError = spreadsheet.getSheetByName(sheetName);

    //Get row data
    values, spreadsheetError = sheet.getRowData(googlespreadsheetConnector,"1");
    io:println(values);

    //Get cell data
    string val="";
    val, spreadsheetError = sheet.getCellData(googlespreadsheetConnector,"1","C");
    io:println(val);

    //Get column data
    values, spreadsheetError = sheet.getColumnData(googlespreadsheetConnector, "B");
    int i = 0;
    foreach val  in values {
        int score = 0;
        score, _ = <int> val;
        googlespreadsheet:Range cellRange = {};
        googlespreadsheet:Range cellRangeResponse = {};
        string a1Notation = sheetName + "!C" + (i + 1);
        cellRange = sheet.getRange(a1Notation);
        if (score > 75) {
            //Update the cell value
            cellRangeResponse, spreadsheetError = cellRange.setValue(googlespreadsheetConnector, "Exceptional");
        }
        i = i + 1;
    }
}
