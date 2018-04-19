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

string accessToken = config:getAsString("ACCESS_TOKEN");
string clientId = config:getAsString("CLIENT_ID");
string clientSecret = config:getAsString("CLIENT_SECRET");
string refreshToken = config:getAsString("REFRESH_TOKEN");

endpoint Client spreadsheetClient {
    clientConfig:{
        auth:{
            accessToken:accessToken,
            refreshToken:refreshToken,
            clientId:clientId,
            clientSecret:clientSecret
        }
    }
};

Spreadsheet spreadsheet = new;
string spreadsheetName = "testBalFile";
string sheetName;

@test:Config
function testCreateSpreadsheet () {
    io:println("-----------------Test case for createSpreadsheet method------------------");
    var spreadsheetRes = spreadsheetClient -> createSpreadsheet(spreadsheetName);
    match spreadsheetRes {
        Spreadsheet s => spreadsheet = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
    test:assertNotEquals(spreadsheet.spreadsheetId, null, msg = "Failed to create spreadsheet");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetName () {
    io:println("-----------------Test case for getSpreadsheetName method------------------");
    string name = "";
    var res = spreadsheet.getSpreadsheetName();
    match res {
        string s => name = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
    test:assertEquals(name, spreadsheetName, msg = "getSpreadsheetName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetId () {
    io:println("-----------------Test case for getSpreadsheetId method------------------");
    string spreadsheetId = "";
    var res = spreadsheet.getSpreadsheetId();
    match res {
        string s => spreadsheetId = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
    io:println("**************");
    io:println(spreadsheetId);
    io:println("**************");
    test:assertEquals(spreadsheetId, spreadsheet.spreadsheetId,
        msg = "getSpreadsheetId() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSheets () {
    io:println("-----------------Test case for getSheets method------------------");
    Sheet[] sheets = [];
    var sheetRes = spreadsheet.getSheets();
    match sheetRes {
        Sheet[] s => sheets = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
    sheetName = sheets[0].properties.title;
    test:assertEquals(lengthof sheets, 1, msg = "getSheets() method failed");
}

@test:Config{
    dependsOn:["testGetSheets"]
}
function testGetSheetByName () {
    io:println("-----------------Test case for getSheetByName method------------------");
    Sheet sheet = {};
    var sheetRes = spreadsheet.getSheetByName(sheetName);
    match sheetRes {
        Sheet s => sheet = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
    test:assertEquals(sheet.properties.title, sheetName, msg = "getSheetByName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testOpenSpreadsheetById () {
    io:println("-----------------Test case for openSpreadsheetById method------------------");
    var spreadsheetRes = spreadsheetClient -> openSpreadsheetById(spreadsheet.spreadsheetId);
    match spreadsheetRes {
        Spreadsheet s => spreadsheet = s;
        SpreadsheetError e => test:assertFail(msg = e.message);
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
    var spreadsheetRes = spreadsheetClient -> setSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5", values);
    match spreadsheetRes {
        boolean isUpdated => test:assertTrue(isUpdated, msg = "Failed to update the values!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}

@test:Config{
    dependsOn:["testSetSheetValues", "testGetSheets"]
}
function testGetSheetValues () {
    io:println("-----------------Test case for getSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
    ["Nisha", "98"], ["Kana", "86"]];
    var spreadsheetRes = spreadsheetClient -> getSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5");
    match spreadsheetRes {
        string[][] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetColumnData () {
    io:println("-----------------Test case for getColumnData method------------------");
    string[] values = ["Name", "Keetz", "Niro", "Nisha", "Kana"];
    var spreadsheetRes = spreadsheetClient -> getColumnData(spreadsheet.spreadsheetId, sheetName, "A");
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetRowData () {
    io:println("-----------------Test case for getRowData method------------------");
    string[] values = ["Name", "Score", "Performance"];
    var spreadsheetRes = spreadsheetClient -> getRowData(spreadsheet.spreadsheetId, sheetName, 1);
    match spreadsheetRes {
        string[] vals => test:assertEquals(vals, values, msg = "Failed to get the values!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testSetCellData () {
    io:println("-----------------Test case for setCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient -> setCellData(spreadsheet.spreadsheetId, sheetName, "B", 5, "90");
    match spreadsheetRes {
        boolean isUpdated => test:assertTrue(isUpdated, msg = "Failed to update the value!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}

@test:Config{
    dependsOn:["testSetCellData", "testGetSheets"]
}
function testGetCellData () {
    io:println("-----------------Test case for getCellData method------------------");
    string value = "90";
    var spreadsheetRes = spreadsheetClient -> getCellData(spreadsheet.spreadsheetId, sheetName, "B", 5);
    match spreadsheetRes {
        string val => test:assertEquals(val, value, msg = "Failed to get the value!");
        SpreadsheetError e => test:assertFail(msg = e.message);
    }
}