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

import ballerina/config;
import ballerina/io;
import ballerina/test;
import googlespreadsheet4;

string accessToken = setConfParams(config:getAsString("ACCESS_TOKEN"));
string clientId = setConfParams(config:getAsString("CLIENT_ID"));
string clientSecret = setConfParams(config:getAsString("CLIENT_SECRET"));
string refreshToken = setConfParams(config:getAsString("REFRESH_TOKEN"));

endpoint googlespreadsheet4:SpreadsheetEndpoint sp {
    oauthClientConfig: {
       accessToken:accessToken,
       clientConfig:{},
       refreshToken:refreshToken,
       clientId:clientId,
       clientSecret:clientSecret,
       useUriParams:true
    }
};

googlespreadsheet4:Spreadsheet spreadsheet = {};
googlespreadsheet4:Sheet sheet = {};
string spreadsheetName = "testBalFile";
string sheetName;

@test:Config
function testCreateSpreadsheet () {
    io:println("-----------------Test case for createSpreadsheet method------------------");
    var spreadsheetRes = sp -> createSpreadsheet(spreadsheetName);
    match spreadsheetRes {
        googlespreadsheet4:Spreadsheet s => spreadsheet = s;
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
    test:assertNotEquals(spreadsheet.spreadsheetId, null, msg = "Failed to create spreadsheet");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetName () {
    io:println("-----------------Test case for getSpreadsheetName method------------------");

    test:assertEquals(spreadsheet.getSpreadsheetName(), spreadsheetName, msg = "getSpreadsheetName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetId () {
    io:println("-----------------Test case for getSpreadsheetId method------------------");

    test:assertEquals(spreadsheet.getSpreadsheetId(), spreadsheet.spreadsheetId,
                      msg = "getSpreadsheetId() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSheets () {
    io:println("-----------------Test case for getSheets method------------------");
    googlespreadsheet4:Sheet[] sheets = [];
    sheets = spreadsheet.getSheets();
    sheetName = sheets[0].properties.title;
    test:assertEquals(lengthof sheets, 1, msg = "getSheets() method failed");
}

@test:Config{
    dependsOn:["testGetSheets"]
}
function testGetSheetByName () {
    io:println("-----------------Test case for getSheetByName method------------------");
    var sheetRes = spreadsheet.getSheetByName(sheetName);
    match sheetRes {
        googlespreadsheet4:Sheet s => sheet = s;
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
    test:assertEquals(sheet.properties.title, sheetName, msg = "getSheetByName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testOpenSpreadsheetById () {
    io:println("-----------------Test case for openSpreadsheetById method------------------");
    var spreadsheetRes = sp -> openSpreadsheetById(spreadsheet.spreadsheetId);
    match spreadsheetRes {
        googlespreadsheet4:Spreadsheet s => spreadsheet = s;
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
    test:assertNotEquals(spreadsheet.spreadsheetId, null, msg = "Failed to open the spreadsheet");

}

@test:Config{
    dependsOn:["testOpenSpreadsheetById", "testGetSheets"]
}
function testSetSheetValues () {
    io:println("-----------------Test case for setSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                         ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = sp -> setSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5", values);
    string a1Notation = sheetName + "!A1:C5";
    match spreadsheetRes {
        googlespreadsheet4:Range r => test:assertEquals(r.a1Notation, a1Notation, msg = "Failed to update the values!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config{
    dependsOn:["testSetSheetValues", "testGetSheets"]
}
function testGetSheetValues () {
    io:println("-----------------Test case for getSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                         ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = sp -> getSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5");
    match spreadsheetRes {
        string[][] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config{
dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetColumnData () {
    io:println("-----------------Test case for getColumnData method------------------");
    string[] values = ["Name", "Keetz", "Niro", "Nisha", "Kana"];
    var spreadsheetRes = sp -> getColumnData(spreadsheet.spreadsheetId, sheetName, "A");
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetRowData () {
    io:println("-----------------Test case for getRowData method------------------");
    string[] values = ["Name", "Score", "Performance"];
    var spreadsheetRes = sp -> getRowData(spreadsheet.spreadsheetId, sheetName, 1);
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testSetCellData () {
    io:println("-----------------Test case for setCellData method------------------");
    string value = "90";
    var spreadsheetRes = sp -> setCellData(spreadsheet.spreadsheetId, sheetName, "B", 5, "90");
    string a1Notation = sheetName + "!B5";
    match spreadsheetRes {
        googlespreadsheet4:Range r => test:assertEquals(r.a1Notation, a1Notation, msg = "Failed to update the value!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config{
    dependsOn:["testSetCellData", "testGetSheets"]
}
function testGetCellData () {
    io:println("-----------------Test case for getCellData method------------------");
    string value = "90";
    var spreadsheetRes = sp -> getCellData(spreadsheet.spreadsheetId, sheetName, "B", 5);
    match spreadsheetRes {
        string val => test:assertEquals(val, value, msg = "Failed to get the value!");
        googlespreadsheet4:SpreadsheetError e => test:assertFail(msg = e.errorMessage);
    }
}

function setConfParams (string|null confParam) returns string {
    match confParam {
        string param => {
            return param;
        }
        null => {
            io:println("Empty value!");
            return "";
        }
    }
}
