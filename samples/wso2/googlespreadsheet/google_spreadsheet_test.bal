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
import ballerina.test;


//endpoint<googlespreadsheet:GoogleSpreadsheetClientConnector> googlespreadsheetEP {
//         }
string ACCESS_TOKEN;
string REFRESH_TOKEN;
string CLIENT_ID;
string CLIENT_SECRET;

function initBalConnector (){
    //endpoint<googlespreadsheet:GoogleSpreadsheetClientConnector> googlespreadsheetEP {
    //}
    CLIENT_ID="304712049061-e2iq4mm47igvknk2nf5bdn9qce8as8vd.apps.googleusercontent.com";
    CLIENT_SECRET="L0HNGHxeUUYoWHvozrDtTV0h";
    ACCESS_TOKEN="ya29.GltoBXxMzppIDzyo7a-1gktcTUX5rzgrKb2H-lbrkDEHc5Id5EjbXhI5SIzGs1TMKjULyHNy-KC6I86C_fEFcIi6aY_1zL-4lwaQW_-z7qFjGIClp4vnk2KybMp5";
    REFRESH_TOKEN="1/cdxVh5UY59N-p7ExKap0fPpuaNb6h7sFSMDIA3C0V7w";
    //googlespreadsheet:GoogleSpreadsheetClientConnector googlespreadsheetConnector =
    //create googlespreadsheet:GoogleSpreadsheetClientConnector(ACCESS_TOKEN, REFRESH_TOKEN, CLIENT_ID, CLIENT_SECRET);
    //bind googlespreadsheetConnector with googlespreadsheetEP;
    //ACCESS_TOKEN = system:getEnv("ACCESS_TOKEN");
    //string REFRESH_TOKEN = system:getEnv("REFRESH_TOKEN");
    //string CLIENT_ID = system:getEnv("CLIENT_ID");
    //string CLIENT_SECRET = system:getEnv("CLIENT_SECRET");
}

function testCreateSpreadSheet () {
    endpoint<googlespreadsheet:GoogleSpreadsheetClientConnector> googlespreadsheetEP {
    }

    initBalConnector();

    googlespreadsheet:GoogleSpreadsheetClientConnector googlespreadsheetConnector =
    create googlespreadsheet:GoogleSpreadsheetClientConnector(ACCESS_TOKEN, REFRESH_TOKEN, CLIENT_ID, CLIENT_SECRET);
    bind googlespreadsheetConnector with googlespreadsheetEP;

    googlespreadsheet:SpreadsheetError spreadsheetError = {};
    googlespreadsheet:Spreadsheet spreadsheet = {};
    string spreadsheetName = "testBalSheet";
    boolean assertValue = false;

    spreadsheet, spreadsheetError = googlespreadsheetEP.createSpreadsheet(spreadsheetName);
    string returnedSpreadSheetId = spreadsheet.spreadsheetId;
    string returnedSpreadSheetName = spreadsheet.properties.title;
    if (returnedSpreadSheetId != "" &&  returnedSpreadSheetName == spreadsheetName) {
        assertValue = true;
    }
    io:println(spreadsheet);
    test:assertEquals(assertValue, true, "Test Failed.Assertion is failing" + "SpreadsheetID" + ":"
                                         + returnedSpreadSheetId + "Spreadsheet Name" + ":" + returnedSpreadSheetName);
}