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

import ballerina/http;

# Google Spreadsheet Client object.
# + spreadsheetConnector - TwitterConnector Connector object
public type Client client object {
    public SpreadsheetConnector spreadsheetConnector;

    public function __init(SpreadsheetConfiguration spreadsheetConfig) {
        self.init(spreadsheetConfig);
        self.spreadsheetConnector = new(BASE_URL, spreadsheetConfig.clientConfig);
    }

    # Initialize Spreadsheet endpoint.
    #
    # + spreadsheetConfig - Spreadsheet configuraion
    public function init(SpreadsheetConfiguration spreadsheetConfig);

    # Create a new spreadsheet.
    #
    # + spreadsheetName - Name of the spreadsheet
    # + return - If success, returns json with of task list, else returns `error` object
    public remote function createSpreadsheet(string spreadsheetName) returns Spreadsheet|error {
        return self.spreadsheetConnector->createSpreadsheet(spreadsheetName);
    }

    # Get a spreadsheet by ID.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + return - Spreadsheet object on success and error on failure
    public remote function openSpreadsheetById(string spreadsheetId) returns Spreadsheet|error {
        return self.spreadsheetConnector->openSpreadsheetById(spreadsheetId);
    }

    # Add a new worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - The name of the sheet. It is an optional parameter. If the title is empty, then sheet will be created with the default name.
    # + return - Sheet object on success and error on failure
    public remote function addNewSheet(string spreadsheetId, string sheetName) returns Sheet|error {
        return self.spreadsheetConnector->addNewSheet(spreadsheetId, sheetName);
    }

    # Delete specified worksheet.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetId - The ID of the sheet to delete
    # + return - Sheet object on success and error on failure
    public remote function deleteSheet(string spreadsheetId, int sheetId) returns boolean|error {
        return self.spreadsheetConnector->deleteSheet(spreadsheetId, sheetId);
    }

    # Get spreadsheet values.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + return - Sheet values as a two dimensional array on success and error on failure
    public remote function getSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                                string bottomRightCell = "") returns (string[][])|error {
        return self.spreadsheetConnector->getSheetValues(spreadsheetId, sheetName, topLeftCell = topLeftCell,
                                    bottomRightCell = bottomRightCell);
    }

    # Get column data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to retrieve the data
    # + return - Column data as an array on success and error on failure
    public remote function getColumnData(string spreadsheetId, string sheetName, string column)
                                                  returns (string[])|error {
        return self.spreadsheetConnector->getColumnData(spreadsheetId, sheetName, column);
    }

    # Get row data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + row - Row name to retrieve the data
    # + return - Row data as an array on success and error on failure
    public remote function getRowData(string spreadsheetId, string sheetName, int row)
                                                   returns (string[])|error {
        return self.spreadsheetConnector->getRowData(spreadsheetId, sheetName, row);
    }

    # Get cell data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to retrieve the data
    # + row - Row name to retrieve the data
    # + return - Cell data on success and error on failure
    public remote function getCellData(string spreadsheetId, string sheetName, string column, int row)
                                                    returns (string)|error {
        return self.spreadsheetConnector->getCellData(spreadsheetId, sheetName, column, row);
    }

    # Set cell data.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + column - Column name to set the data
    # + row - Row name to set the data
    # + value - The value to be updated
    # + return - True on success and error on failure
    public remote function setCellData(string spreadsheetId, string sheetName, string column, int row, string value)
                                                     returns (boolean)|error{
        return self.spreadsheetConnector->setCellData(spreadsheetId, sheetName, column, row, value);
    }

    # Set spreadsheet values.
    #
    # + spreadsheetId - Id of the spreadsheet
    # + sheetName - Name of the sheet
    # + topLeftCell - Top left cell
    # + bottomRightCell - Bottom right cell
    # + values - Values to be updated
    # + return - True on success and error on failure
    public remote function setSheetValues(string spreadsheetId, string sheetName, string topLeftCell = "",
                                    string bottomRightCell = "", string[][] values) returns (boolean)|error{
        return self.spreadsheetConnector->setSheetValues(spreadsheetId, sheetName, topLeftCell = topLeftCell,
                                                        bottomRightCell = bottomRightCell, values);
    }
};

function Client.init(SpreadsheetConfiguration spreadsheetConfig) {
    http:AuthConfig? authConfig = spreadsheetConfig.clientConfig.auth;
    if (authConfig is http:AuthConfig) {
        authConfig.refreshUrl = REFRESH_URL;
        authConfig.scheme = http:OAUTH2;
    }
}

# Object for Spreadsheet configuration.
#
# + clientConfig - The http client endpoint
public type SpreadsheetConfiguration record {
    http:ClientEndpointConfig clientConfig;
};
