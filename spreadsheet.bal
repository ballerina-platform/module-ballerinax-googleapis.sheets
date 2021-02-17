// // Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 Inc. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied.  See the License for the
// // specific language governing permissions and limitations
// // under the License.

// import ballerina/http;

// # Spreadsheet client object.
// #
// # + spreadsheetId - Id of the spreadsheet
// # + properties - Properties of a spreadsheet
// # + sheets - The sheets that are part of a spreadsheet
// # + spreadsheetUrl - The URL of the spreadsheet
// public client class Spreadsheet {

//     public string spreadsheetId;
//     SpreadsheetProperties properties;
//     public string spreadsheetUrl;
//     Client spreadsheetClient;
//     http:Client httpClient;
//     public Sheet[] sheets;

//     public isolated function init(Client spreadsheetClient, string id, SpreadsheetProperties props, string url, Sheet[]
//             sheets) {
//         self.spreadsheetClient = spreadsheetClient;
//         self.spreadsheetId = id;
//         self.properties = props;
//         self.spreadsheetUrl = url;
//         self.httpClient = spreadsheetClient.httpClient;
//         self.sheets = sheets;
//     }

//     # Get the name of the spreadsheet.
//     # + return - Name of the spreadsheet object on success and error on failure
//     public isolated function getProperties() returns SpreadsheetProperties {
//         return self.properties;
//     }

//     # Get sheets of the spreadsheet.
//     # + return - Sheet array on success and error on failure
//     public isolated function getSheets() returns Sheet[] | error {
//         Sheet[] sheets = [];
//         if (self.sheets.length() == 0) {
//             error err = error("No sheets found");
//             return err;
//         }
//         sheets = self.sheets;
//         return sheets;
//     }

//     # Get sheets of the spreadsheet.
//     # + sheetName - Name of the sheet to retrieve
//     # + return - Sheet object on success and error on failure
//     public isolated function getSheetByName(string sheetName) returns Sheet | error {
//         Sheet[] sheets = self.sheets;
//         foreach var sheet in sheets {
//             if (equalsIgnoreCase(sheet.properties.title, sheetName)) {
//                 return sheet;
//             }
//         }
//         return error("Sheet not found");
//     }


//     # Add a new worksheet.
//     #
//     # + sheetName - The name of the sheet. It is an optional parameter.
//     #               If the title is empty, then sheet will be created with the default name.
//     # + return - Sheet object on success and error on failure
//     remote function addSheet(string sheetName) returns @tainted Sheet | error {
//         map<json> payload = {"requests": [{"addSheet": {"properties": {}}}]};
//         map<json> jsonSheetProperties = {};
//         if (sheetName != EMPTY_STRING) {
//             jsonSheetProperties["title"] = sheetName;
//         }
//         json[] requestsElement = <json[]>payload["requests"];
//         map<json> firstRequestsElement = <map<json>>requestsElement[0];
//         map<json> sheetElement = <map<json>>firstRequestsElement.addSheet;
//         sheetElement["properties"] = jsonSheetProperties;
//         string addSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
//         json | error response = sendRequestWithPayload(self.httpClient, addSheetPath, payload);
//         if (response is error) {
//             return response;
//         } else {
//             json[] replies = <json[]>response.replies;
//             json | error addSheet = replies[0].addSheet;
//             Sheet newSheet = convertToSheet(!(addSheet is error) ? addSheet : {}, self.spreadsheetClient,
//             self.spreadsheetId);
//             return newSheet;
//         }
//     }

//     # Delete specified worksheet.
//     #
//     # + sheetId - The ID of the sheet to delete
//     # + return - Boolean value true on success and error on failure
//     remote function removeSheet(int sheetId) returns @tainted error? {
//         json payload = {"requests": [{"deleteSheet": {"sheetId": sheetId}}]};
//         string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
//         json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
//         if (response is error) {
//             return response;
//         }
//     }

//     # Renames the Spreadsheet with the given name.
//     #
//     # + name - New name for the Spreadsheet
//     # + return - Nil on success, else returns an error
//     remote function rename(string name) returns @tainted error? {
//         json payload = {
//             "requests": [
//                 {
//                     "updateSpreadsheetProperties": {
//                         "properties": {"title": name},
//                         "fields": "title"
//                     }
//                 }
//             ]
//         };
//         string deleteSheetPath = SPREADSHEET_PATH + PATH_SEPARATOR + self.spreadsheetId + BATCH_UPDATE_REQUEST;
//         json | error response = sendRequestWithPayload(self.httpClient, deleteSheetPath, payload);
//         if (response is error) {
//             return response;
//         } else {
//             self.properties.title = name;
//         }
//     }
// }