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

import ballerina/io;
import googlespreadsheet;

public function main (string[] args) {
    endpoint googlespreadsheet:SpreadsheetEndpoint sp {
        oauthClientConfig: {
           accessToken:args[0],
           clientConfig:{},
           refreshToken:args[1],
           clientId:args[2],
           clientSecret:args[3],
           useUriParams:true
        }
    };
    googlespreadsheet:SpreadsheetConnector gs = {};
    googlespreadsheet:Spreadsheet spreadsheet = {};
    googlespreadsheet:SpreadsheetError spreadsheetError = {};
    googlespreadsheet:Sheet sheet = {};
    string spreadsheetId = args[4];
    string sheetName = args[5];
    var spreadsheetRes = sp -> createSpreadsheet("testBalFile");
    io:println(spreadsheetRes);

    spreadsheetRes = sp -> openSpreadsheetById(spreadsheetId);
    match spreadsheetRes {
        googlespreadsheet:Spreadsheet s => spreadsheet = s;
        googlespreadsheet:SpreadsheetError e => io:println(e);
    }
    io:println("--------openSpreadsheetById response is-----------");
    io:println(spreadsheet);
    var sheetRes = spreadsheet.getSheetByName(sheetName);
    io:println("---------getSheetByName--------");
    match sheetRes {
        googlespreadsheet:Sheet s => sheet = s;
        googlespreadsheet:SpreadsheetError e => io:println(e);
    }
    //Get row data
    var rowData = sp -> getRowData(spreadsheetId, sheetName, 1);
    io:println("---------getRowData--------");
    io:println(rowData);

    //Get cell data
    var cellVal = sp -> getCellData(spreadsheetId, sheetName, "C",1);
    io:println("---------getCellData--------");
    io:println(cellVal);

    var colData = sp -> getColumnData(spreadsheetId, sheetName, "B");
    string[] values = [];
    io:println("---------getColumnData--------");
    match colData {
        string[] v => values = v;
        googlespreadsheet:SpreadsheetError e => io:println(e);
    }
    io:println(values);
    int i = 0;
    if (values!= null) {
        foreach val  in values {
            var score = <int> val;
            int row = i + 1;
            match score {
                int intScore => {
                    if (intScore > 75) {
                        var cellRangeResponse = sp -> setCellData(spreadsheetId, sheetName, "C", row, "Exceptional");
                    }
                }
                error e => io:println(e);
            }

            i = i + 1;
        }
    }

    io:println("Update completed");
}
