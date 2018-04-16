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
Sheet sheetResponse = {};
string spreadsheetName = "testBalFile";
string sheetName;

@test:Config
function testCreateSpreadsheet () {
    io:println("-----------------Test case for createSpreadsheet method------------------");
    var spreadsheetRes = spreadsheetClient -> createSpreadsheet(spreadsheetName);
    spreadsheet = check spreadsheetRes;
    test:assertNotEquals(spreadsheet.spreadsheetId, null, msg = "Failed to create spreadsheet");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetName () {
    io:println("-----------------Test case for getSpreadsheetName method------------------");
    string name = check spreadsheet.getSpreadsheetName();
    test:assertEquals(name, spreadsheetName, msg = "getSpreadsheetName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSpreadsheetId () {
    io:println("-----------------Test case for getSpreadsheetId method------------------");
    string spreadsheetId = check spreadsheet.getSpreadsheetId();
    test:assertEquals(spreadsheetId, spreadsheet.spreadsheetId,
                      msg = "getSpreadsheetId() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testGetSheets () {
    io:println("-----------------Test case for getSheets method------------------");
    Sheet[] sheets = check spreadsheet.getSheets();
    sheetName = sheets[0].properties.title;
    test:assertEquals(lengthof sheets, 1, msg = "getSheets() method failed");
}

@test:Config{
    dependsOn:["testGetSheets"]
}
function testGetSheetByName () {
    io:println("-----------------Test case for getSheetByName method------------------");
    sheetResponse = check spreadsheet.getSheetByName(sheetName);
    test:assertEquals(sheetResponse.properties.title, sheetName, msg = "getSheetByName() method failed");
}

@test:Config{
    dependsOn:["testCreateSpreadsheet"]
}
function testOpenSpreadsheetById () {
    io:println("-----------------Test case for openSpreadsheetById method------------------");
    spreadsheet = check spreadsheetClient -> openSpreadsheetById(spreadsheet.spreadsheetId);
    test:assertNotEquals(spreadsheet.spreadsheetId, null, msg = "Failed to open the spreadsheet");

}

@test:Config{
    dependsOn:["testOpenSpreadsheetById", "testGetSheets"]
}
function testSetSheetValues () {
    io:println("-----------------Test case for setSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                         ["Nisha", "98"], ["Kana", "86"]];
    boolean isUpdated = check spreadsheetClient -> setSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5", values);
    string a1Notation = sheetName + "!A1:C5";
    test:assertTrue(isUpdated, msg = "Failed to update the values!");
}

@test:Config{
    dependsOn:["testSetSheetValues", "testGetSheets"]
}
function testGetSheetValues () {
    io:println("-----------------Test case for getSheetValues method------------------");
    string[][] values = [["Name", "Score", "Performance"], ["Keetz", "12"], ["Niro", "78"],
                         ["Nisha", "98"], ["Kana", "86"]];
    string[][] spreadsheetRes = check spreadsheetClient -> getSheetValues(spreadsheet.spreadsheetId, sheetName, "A1", "C5");
    test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetColumnData () {
    io:println("-----------------Test case for getColumnData method------------------");
    string[] values = ["Name", "Keetz", "Niro", "Nisha", "Kana"];
    string[] spreadsheetRes = check spreadsheetClient -> getColumnData(spreadsheet.spreadsheetId, sheetName, "A");
    test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testGetRowData () {
    io:println("-----------------Test case for getRowData method------------------");
    string[] values = ["Name", "Score", "Performance"];
    string[] spreadsheetRes = check spreadsheetClient -> getRowData(spreadsheet.spreadsheetId, sheetName, 1);
    test:assertEquals(spreadsheetRes, values, msg = "Failed to get the values!");
}

@test:Config{
    dependsOn:["testGetSheetValues", "testGetSheets"]
}
function testSetCellData () {
    io:println("-----------------Test case for setCellData method------------------");
    string value = "90";
    boolean isUpdated = check spreadsheetClient -> setCellData(spreadsheet.spreadsheetId, sheetName, "B", 5, "90");
    string a1Notation = sheetName + "!B5";
    test:assertTrue(isUpdated, msg = "Failed to update the value!");
}

@test:Config{
    dependsOn:["testSetCellData", "testGetSheets"]
}
function testGetCellData () {
    io:println("-----------------Test case for getCellData method------------------");
    string value = "90";
    string spreadsheetRes = check spreadsheetClient -> getCellData(spreadsheet.spreadsheetId, sheetName, "B", 5);
    test:assertEquals(spreadsheetRes, value, msg = "Failed to get the value!");
}
