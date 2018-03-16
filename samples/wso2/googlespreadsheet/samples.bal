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
        create googlespreadsheet:GoogleSpreadsheetClientConnector(args[1], args[2], args[3], args[4]);
    }
    googlespreadsheet:SpreadsheetError spreadsheetError = {};
    googlespreadsheet:Spreadsheet spreadsheet = {};
    googlespreadsheet:Sheet sheet = {};
    googlespreadsheet:Range range = {};
    string[] values = [];
    string sheetName = args[6];
    //googlespreadsheetEP.init(args[1], args[2], args[3], args[4]);
    googlespreadsheetEP.init();

    //Create spreadsheet by name
    //spreadsheet, spreadsheetError = googlespreadsheetEP.createSpreadsheet(args[5]);
    //io:println(spreadsheet);

    //Get sheets
    //googlespreadsheet:Sheet[] sheets = spreadsheet.getSheets();
    //io:println(sheets);

    //Open th spreadsheet by id
    spreadsheet, spreadsheetError = googlespreadsheetEP.openSpreadsheetById(args[5]);

    //Get the sheet
    sheet, spreadsheetError = spreadsheet.getSheetByName(sheetName);
    io:println(sheet);

    //Get row data
    values, spreadsheetError = sheet.getRowData("1");
    io:println(values);

    //Get cell data
    string cellVal="";
    cellVal, spreadsheetError = sheet.getCellData("1","C");
    io:println("Cell value is : " + cellVal);

    //Get column data
    values, spreadsheetError = sheet.getColumnData("B");
    io:println(values);
    int i = 0;
    if (values!= null) {
        foreach val  in values {
            int score = 0;
            score, _ = <int> val;
            googlespreadsheet:Range cellRange = {};
            googlespreadsheet:Range cellRangeResponse = {};
            string topLeft = "C" + (i + 1);
            cellRange, spreadsheetError = sheet.getRange(topLeft, "");
            if (score > 75) {
                //Update the cell value
                cellRangeResponse, spreadsheetError = cellRange.setValue("Exceptional");
            }
            i = i + 1;
        }
    }
    io:println("Update completed");
}
