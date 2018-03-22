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

package samples.wso2.spreadsheet;

import ballerina.io;
import src.wso2.spreadsheet;

public function main (string[] args) {
    spreadsheet:GoogleSpreadsheetClientConnector gs = {};
    spreadsheet:Spreadsheet spreadsheet = {};
    spreadsheet:SpreadsheetError spreadsheetError = {};
    spreadsheet:Sheet sheet = {};
    string[] values = [];
    gs.init(args[0], args[1], args[2], args[3]);
    var spreadsheetRes = gs.createSpreadsheet("testBalFile");
    io:println(spreadsheetRes);

    spreadsheetRes = gs.openSpreadsheetById(args[4]);
    match spreadsheetRes {
        spreadsheet:Spreadsheet s => spreadsheet = s;
        spreadsheet:SpreadsheetError e => io:println(e);
    }
    io:println("--------RESPONSE IS-----------");
    io:println(spreadsheet);
    var sheetRes = spreadsheet.getSheetByName(args[5]);
    io:println("---------getSheetByName--------");
    match sheetRes {
        spreadsheet:Sheet s => sheet = s;
        spreadsheet:SpreadsheetError e => io:println(e);
    }
    io:println(sheet);
    //Get data range
    var dataRange = sheet.getDataRange();
    io:println("-----------getDataRange------");
    io:println(dataRange);
    //Get row data
    var rowData = sheet.getRowData("1");
    io:println("---------getRowData--------");
    io:println(rowData);

    //Get cell data
    var cellVal = sheet.getCellData("C","1");
    io:println("---------getCellData--------");
    io:println(cellVal);

    var colData = sheet.getColumnData("B");
    io:println("---------getColumnData--------");
    match colData {
        string[] v => values = v;
        spreadsheet:SpreadsheetError e => io:println(e);
    }
    io:println(values);
    int i = 0;
    if (values!= null) {
        foreach val  in values {
            var score, _ = <int> val;
            spreadsheet:Range cellRange = {};
            //spreadsheet:Range cellRangeResponse = {};
            int row = i + 1;
            if (score > 75) {
                var cellRangeResponse = sheet.setCellData("C", <string>row, "Exceptional");
            }
            i = i + 1;
        }
    }

    io:println("Update completed");
}
