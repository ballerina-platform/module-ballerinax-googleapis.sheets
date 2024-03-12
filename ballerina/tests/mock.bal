// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

service /spreadsheets/v4 on new http:Listener(9092) {

    private SpreadsheetPropertiesType spreadsheetProperties;
    private SpreadsheetType spreadsheet;
    private SheetType[] sheetList;
    private UpdateValuesResponse[] updateValueResponse;
    private int appendCount = 1;

    function init() {
        self.sheetList = [];
        self.updateValueResponse = [];
        self.sheetList.push(sheet1);
        self.spreadsheetProperties = spreadsheetProperties;
        self.spreadsheet = {
            spreadsheetId: "13Z6g1sWETEni0oNatHonBDJannLOC80GtJMzmZmJgvw",
            properties: self.spreadsheetProperties,
            sheets: self.sheetList,
            spreadsheetUrl: "https://docs.google.com/spreadsheets/d/13Z6g1sWETEni0oNatHonBDJannLOC80GtJMzmZmJgvw/edit"
        };
    }

    resource function post spreadsheets("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload Spreadsheet payload) returns OkSpreadsheet {
        OkSpreadsheet okSpreadsheet = {
            body: self.spreadsheet
        };
        return okSpreadsheet;
    }

    resource function get spreadsheets/[string spreadsheetId]/developerMetadata/[int metadataId]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType) returns DeveloperMetadata {
        DeveloperMetadata metadata = {
            location: {
                dimensionRangeType: {
                    sheetId: 123,
                    startIndex: 1,
                    endIndex: 10,
                    dimension: "ROWS"
                }
            },
            metadataId: 1,
            metadataKey: "sample_key",
            metadataValue: "sample_value",
            visibility: "DEVELOPER_METADATA_VISIBILITY_UNSPECIFIED"
        };
        return metadata;
    }

    resource function get spreadsheets/[string spreadsheetId]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeGridData, string[]? ranges) returns SpreadsheetType|error {
        if spreadsheetId == "13Z6g1sWETEni0oNatHonBDJannLOC80GtJMzmZmJgvw" {
            return self.spreadsheet;
        }
        return error("Not Found");
    }

    // resource function get spreadsheets/[string spreadsheetId]/developerMetadata/[int metadataId]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType) returns DeveloperMetadata {
    //     return {
    //         location: {},
    //         metadataId: 0,
    //         metadataKey: "",
    //         metadataValue: "",
    //         visibility: "DEVELOPER_METADATA_VISIBILITY_UNSPECIFIED"
    //     };
    // }

    resource function post spreadsheets/[string spreadsheetId]/developerMetadata\:search("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload SearchDeveloperMetadataRequest payload) returns OkSearchDeveloperMetadataResponse {
        OkSearchDeveloperMetadataResponse response = {
            body: {
                matchedDeveloperMetadata: [
                    {
                        developerMetadata: {
                            metadataId: 1,
                            metadataKey: "sample_key",
                            metadataValue: "sample_value",
                            location: {
                                dimensionRangeType: {
                                    sheetId: 123,
                                    startIndex: 1,
                                    endIndex: 10,
                                    dimension: "ROWS"
                                }
                            },
                            visibility: "DEVELOPER_METADATA_VISIBILITY_UNSPECIFIED"
                        }
                    },
                    {
                        developerMetadata: {
                            metadataId: 2,
                            metadataKey: "another_key",
                            metadataValue: "another_value",
                            location: {
                                dimensionRangeType: {
                                    sheetId: 456,
                                    startIndex: 5,
                                    endIndex: 15,
                                    dimension: "COLUMNS"
                                }
                            },
                            visibility: "DEVELOPER_METADATA_VISIBILITY_UNSPECIFIED"
                        }
                    }
                ]
            }
        };
        return response;
    }

    resource function post spreadsheets/[string spreadsheetId]/sheets/[string sheetidCopyto]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload CopySheetToAnotherSpreadsheetRequest payload) returns OkSheetProperties|error {
        OkSheetProperties okSheetProperties = {
            body: {
                sheetId: 123,
                title: "Sample Sheet",
                index: 0,
                sheetType: "GRID",
                gridProperties: {
                    rowCount: 100,
                    columnCount: 10,
                    frozenRowCount: 2,
                    frozenColumnCount: 1
                }
            }
        };
        return okSheetProperties;
    }

    resource function get spreadsheets/[string spreadsheetId]/values/[string range]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, "SERIAL_NUMBER"|"FORMATTED_STRING"? dateTimeRenderOption, "DIMENSION_UNSPECIFIED"|"ROWS"|"COLUMNS"? majorDimension, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? valueRenderOption) returns ValueRangeType {
        if range.includes("!I:I") {
            ValueRangeType valueRange = {
                range: "I1:D5",
                majorDimension: "ROWS",
                values: values1
            };
            return valueRange;
        }
        if range.includes("!10:10") {
            ValueRangeType valueRange = {
                range: "10:10",
                majorDimension: "ROWS",
                values: value2
            };
            return valueRange;
        }
        if range.includes("!H1") {
            ValueRangeType valueRange = {
                range: "H1",
                majorDimension: "ROWS",
                values: value3
            };
            return valueRange;
        }
        ValueRangeType valueRange = {
            values: value4
        };
        return valueRange;
    }

    resource function put spreadsheets/[string spreadsheetId]/values/[string range]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeValuesInResponse, "SERIAL_NUMBER"|"FORMATTED_STRING"? responseDateTimeRenderOption, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? responseValueRenderOption, "INPUT_VALUE_OPTION_UNSPECIFIED"|"RAW"|"USER_ENTERED"? valueInputOption, @http:Payload ValueRangeType payload) returns UpdateValuesResponse {
        UpdateValuesResponse updateValuesResponse = {
            spreadsheetId: "dummy_spreadsheet_id",
            updatedRange: "dummy_range",
            updatedRows: 10,
            updatedColumns: 2,
            updatedCells: 20,
            updatedData: {
                values: [
                    ["A1", "B1"],
                    ["A2", "B2"]
                ]
            }
        };
        return updateValuesResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values/[string rangeAppend]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeValuesInResponse, "OVERWRITE"|"INSERT_ROWS"? insertDataOption, "SERIAL_NUMBER"|"FORMATTED_STRING"? responseDateTimeRenderOption, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? responseValueRenderOption, "INPUT_VALUE_OPTION_UNSPECIFIED"|"RAW"|"USER_ENTERED"? valueInputOption, @http:Payload ValueRangeType payload) returns OkAppendValuesResponse|error {
        if !rangeAppend.endsWith(":append") {
            return error("bad URL");
        }
        OkAppendValuesResponse okAppendValuesResponse = {
            body: {
                spreadsheetId: "dummy_spreadsheet_id",
                tableRange: "dummy_table_range",
                updates: {
                    spreadsheetId: "1nw70WgEBTmlmQZ5VvmD5olRaT2VphEcMXZYP4YTVqb8",
                    updatedRange: string `Dance_ce64b5baae1544ccbb33476a4989b8fe!A${self.appendCount - 3}:C${self.appendCount - 3}`,
                    updatedRows: <int:Signed32>self.appendCount,
                    updatedColumns: <int:Signed32>self.appendCount,
                    updatedCells: <int:Signed32>self.appendCount
                }
            }
        };
        self.appendCount += 1;
        return okAppendValuesResponse;
    }

    // resource function post spreadsheets/[string spreadsheetId]/values/[string rangeClear]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload ClearValuesRequest? payload) returns OkClearValuesResponse|error {
    //     log:printInfo("rangeClear: " + rangeClear);
    //     if !rangeClear.endsWith(":clear") {
    //         return error("bad URL");
    //     }
    //     OkClearValuesResponse okClearValuesResponse = {
    //         body: {
    //             spreadsheetId: "adsfasdf",
    //             clearedRange: "asfasfdasd"
    //         }
    //     };
    //     return okClearValuesResponse;
    // }

    resource function post spreadsheets/[string spreadsheetId]/values\:batchClear("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchClearValuesRequest payload) returns OkBatchClearValuesResponse {
        OkBatchClearValuesResponse okBatchClearValuesByDataFilterResponse = {
            body: {
                spreadsheetId: "dummy_spreadsheet_id",
                clearedRanges: ["range1", "range2"]
            }
        };
        return okBatchClearValuesByDataFilterResponse;
    }

    resource function posts preadsheets/[string spreadsheetId]/values\:batchClearByDataFilter("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchClearValuesByDataFilterRequest payload) returns OkBatchClearValuesByDataFilterResponse {
        OkBatchClearValuesByDataFilterResponse okBatchClearValuesByDataFilterResponse = {
            body: {
                spreadsheetId: "dummy_spreadsheet_id",
                clearedRanges: ["range1", "range2"]
            }
        };
        return okBatchClearValuesByDataFilterResponse;
    }

    resource function get spreadsheets/[string spreadsheetId]/values\:batchGet("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, "SERIAL_NUMBER"|"FORMATTED_STRING"? dateTimeRenderOption, "DIMENSION_UNSPECIFIED"|"ROWS"|"COLUMNS"? majorDimension, string[]? ranges, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? valueRenderOption) returns BatchGetValuesResponse {
        BatchGetValuesResponse batchGetValuesResponse = {
            spreadsheetId: "dummy_spreadsheet_id",
            valueRangeTypes: [{majorDimension: "ROWS", values: [["A1", "B1", "A2", "B2"]]}, {majorDimension: "COLUMNS", values: [["A1", "B1", "A2", "B2"]]}]
        };
        return batchGetValuesResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values\:batchGetByDataFilter("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchGetValuesByDataFilterRequest payload) returns OkBatchGetValuesByDataFilterResponse {
        MatchedValueRangeType var1 = {
            dataFilters: [
                {
                    a1Range: "A1:B2",
                    gridRange: {
                        sheetId: 123,
                        startRowIndex: 0,
                        endRowIndex: 2,
                        startColumnIndex: 0,
                        endColumnIndex: 2
                    }
                }
            ]
        };
        OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse = {
            body: {
                spreadsheetId: "dummy_spreadsheet_id",
                valueRangeTypes: [var1]
            }
        };
        return okBatchGetValuesByDataFilterResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values\:batOkBatchUpdateValuesResponsechUpdate("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateValuesRequest payload) returns OkBatchUpdateValuesResponse {
        OkBatchUpdateValuesResponse okBatchUpdateValuesResponse = {
            body: {
                responses: [
                    {
                        spreadsheetId: "dummy_spreadsheet_id",
                        updatedRange: "dummy_range",
                        updatedRows: 10,
                        updatedColumns: 2,
                        updatedCells: 20
                    }
                ]
            }
        };
        return okBatchUpdateValuesResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values/\:batchUpdateByDataFilter("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateValuesByDataFilterRequest payload) returns OkBatchUpdateValuesByDataFilterResponse {
        OkBatchUpdateValuesByDataFilterResponse okBatchUpdateValuesByDataFilterResponse = {
            body: {
                spreadsheetId: "1SDK1wn0NI9UwlIYtOCfdNRyRxsMKkfxGNT0dw-xzR5I",
                totalUpdatedRows: 1,
                totalUpdatedColumns: 3,
                totalUpdatedCells: 3,
                totalUpdatedSheets: 1,
                responses: [
                    {
                        updatedRange: "Dance_bc51b4d2a381454098c2019c2320da94!A3:C3",
                        updatedRows: 1,
                        updatedColumns: 3,
                        updatedCells: 3,
                        dataFilter: {
                            a1Range: "Dance_bc51b4d2a381454098c2019c2320da94!A3:C3"
                        }
                    }
                ]
            }
        };
        return okBatchUpdateValuesByDataFilterResponse;
    }

    resource function post spreadsheets/[string spreadsheetidBatchupdate]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateSpreadsheetRequest payload) returns OkBatchUpdateSpreadsheetResponse|error {
        if !spreadsheetidBatchupdate.endsWith(":batchUpdate") {
            return error("bad URL");
        }
        string sheetId = "";
        if payload.requests is Request[] {
            Request request = (<Request[]>payload.requests)[0];
            if request.addSheet is AddSheetRequest {
                AddSheetRequest addSheetRequest = <AddSheetRequest>request.addSheet;
                if addSheetRequest.properties is SheetPropertiesType {
                    SheetPropertiesType sheetProperties = <SheetPropertiesType>addSheetRequest.properties;
                    sheetId = sheetProperties.title is string ? <string>sheetProperties.title : spreadsheetId;
                    self.sheetList.push({
                        properties: {
                            sheetId: 1094486074,
                            title: sheetId,
                            index: 1,
                            sheetType: "GRID",
                            gridProperties: {
                                rowCount: 1000,
                                columnCount: 26
                            }
                        }
                    });
                }
            } else if request.deleteSheet is DeleteSheetRequest {
                _ = self.sheetList.pop();
            } else if request.updateSheetProperties is UpdateSheetPropertiesRequest {
                SheetPropertiesType properties = <SheetPropertiesType>(<UpdateSheetPropertiesRequest>request.updateSheetProperties).properties;
                self.spreadsheet.sheets[0].properties.title = properties.title;
            } else if request.updateSpreadsheetProperties is UpdateSpreadsheetPropertiesTypeRequest {
                self.spreadsheetProperties.title = "Ballerina Connector New Renamed";
            }
        }
        OkBatchUpdateSpreadsheetResponse okBatchUpdateSpreadsheetResponse = {
            body: {
                spreadsheetId: sheetId,
                replies: [
                    {
                        addSheet: {
                            properties: {
                                sheetId: 1094486074,
                                title: sheetId,
                                index: 1,
                                sheetType: "GRID",
                                gridProperties: {
                                    rowCount: 1000,
                                    columnCount: 26
                                }
                            }
                        }
                    }
                ],
                updatedSpreadsheet: self.spreadsheet
            }
        };
        return okBatchUpdateSpreadsheetResponse;
    }

    // resource function post spreadsheets/[string spreadsheetidGetbydatafilter]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload GetSpreadsheetByDataFilterRequest payload) returns OkSpreadsheet|error {
    //     if !spreadsheetidGetbydatafilter.endsWith(":getByDataFilter") {
    //         return error("bad URL");
    //     }
    //     string spreadsheetId = spreadsheetidGetbydatafilter.substring(0, spreadsheetidGetbydatafilter.length() - 15);
    // }
}
