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
    io:println("Hello, World!");
    spreadsheet:GoogleSpreadsheetClientConnector gs = {};
    spreadsheet:Spreadsheet spreadsheet;
    spreadsheet:SpreadsheetError spreadsheetError = {};
    spreadsheet:Sheet sheet;
    string[] values = [];
    gs.init(args[0], args[1], args[2], args[3]);
    spreadsheet, spreadsheetError = gs.openSpreadsheetById(args[4]);
    io:println("--------RESPONSE IS-----------");
    io:println(spreadsheet);
    sheet, spreadsheetError = spreadsheet.getSheetByName(args[5]);
    io:println("---------getSheetByName--------");
    io:println(sheet);
    //Get row data
    values, spreadsheetError = sheet.getRowData("1");
    io:println("---------getRowData--------");
    io:println(values);

    //Get cell data
    string cellVal="";
    cellVal, spreadsheetError = sheet.getCellData("C","1");
    io:println("---------getCellData--------");
    io:println("Cell value is : " + cellVal);
    values, _ = sheet.getColumnData("B");
    io:println("---------getColumnData--------");
    io:println(values);
    int i = 0;
    if (values!= null) {
        foreach val  in values {
            int score = 0;
            score, _ = <int> val;
            spreadsheet:Range cellRange = {};
            spreadsheet:Range cellRangeResponse = {};
            int row = i + 1;
            if (score > 75) {
                cellRangeResponse, spreadsheetError = sheet.setCellData("C", <string>row, "Exceptional");
            }
            //string topLeft = "C" + (i + 1);
            //cellRange, spreadsheetError = sheet.getRange(topLeft, "");
            //if (score > 75) {
            //    //Update the cell value
            //    cellRangeResponse, spreadsheetError = cellRange.setValue("Exceptional");
            //}
            i = i + 1;
        }
    }
    io:println("Update completed");
}
