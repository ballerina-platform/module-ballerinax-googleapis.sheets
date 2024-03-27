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
        return metadata;
    }

    resource function get spreadsheets/[string spreadsheetId]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeGridData, string[]? ranges) returns SpreadsheetType|error {
        if spreadsheetId == "13Z6g1sWETEni0oNatHonBDJannLOC80GtJMzmZmJgvw" {
            return self.spreadsheet;
        }
        return error("Not Found");
    }

    resource function post spreadsheets/[string spreadsheetId]/developerMetadata\:search("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload SearchDeveloperMetadataRequest payload) returns OkSearchDeveloperMetadataResponse {
        return okSearchDeveloperMetadataResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/sheets/[string sheetidCopyto]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload CopySheetToAnotherSpreadsheetRequest payload) returns OkSheetProperties|error {
        return okSheetProperties;
    }

    resource function get spreadsheets/[string spreadsheetId]/values/[string range]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, "SERIAL_NUMBER"|"FORMATTED_STRING"? dateTimeRenderOption, "DIMENSION_UNSPECIFIED"|"ROWS"|"COLUMNS"? majorDimension, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? valueRenderOption) returns ValueRangeType {
        if range.includes("!I:I") {
            return valueRange1;
        } else if range.includes("!10:10") {
            return valueRange2;
        } else if range.includes("!H1") {
            return valueRange3;
        }
        ValueRangeType valueRange = {
            values: value4
        };
        return valueRange;
    }

    resource function put spreadsheets/[string spreadsheetId]/values/[string range]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeValuesInResponse, "SERIAL_NUMBER"|"FORMATTED_STRING"? responseDateTimeRenderOption, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? responseValueRenderOption, "INPUT_VALUE_OPTION_UNSPECIFIED"|"RAW"|"USER_ENTERED"? valueInputOption, @http:Payload ValueRangeType payload) returns UpdateValuesResponse {
        return updateValuesResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values/[string filter]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, boolean? includeValuesInResponse, "OVERWRITE"|"INSERT_ROWS"? insertDataOption, "SERIAL_NUMBER"|"FORMATTED_STRING"? responseDateTimeRenderOption, "FORMATTED_VALUE"|"UNFORMATTED_VALUE"|"FORMULA"? responseValueRenderOption, "INPUT_VALUE_OPTION_UNSPECIFIED"|"RAW"|"USER_ENTERED"? valueInputOption, @http:Payload BatchGetValuesByDataFilterRequest|ValueRangeType payload) returns OkAppendValuesResponse|OkBatchUpdateValuesByDataFilterResponse|OkBatchGetValuesByDataFilterResponse|error {
        if filter.endsWith(BATCH_UPDATE_BY_DATAFILTER_REQUEST) {
            return okBatchUpdateValuesByDataFilterResponse;
        } else if filter.endsWith(BATCH_GET_BY_DATAFILTER_REQUEST) {
            if payload is BatchGetValuesByDataFilterRequest {
                BatchGetValuesByDataFilterRequest payloadType = payload;
                if (<DataFilter[]>payloadType.dataFilters)[0].gridRange is GridRange {
                    return okBatchGetValuesByDataFilterResponse;
                } else if (<DataFilter[]>payloadType.dataFilters)[0].developerMetadataLookup is DeveloperMetadataLookup {
                    DeveloperMetadataLookup lookup = <DeveloperMetadataLookup>(<DataFilter[]>payloadType.dataFilters)[0].developerMetadataLookup;
                    if lookup.metadataValue is "valueNone" {
                        return okBatchGetValuesByDataFilterResponse2;
                    }
                    return okBatchGetValuesByDataFilterResponse3;
                }
                return okBatchGetValuesByDataFilterResponse4;
            }
        } else if filter.endsWith(APPEND) {
            string updateRange = string `Dance_ce64b5baae1544ccbb33476a4989b8fe!A${self.appendCount}:C${self.appendCount}`;
            OkAppendValuesResponse okAppendValuesResponse = {
                body: {
                    spreadsheetId: "dummy_spreadsheet_id",
                    tableRange: "dummy_table_range",
                    updates: {
                        spreadsheetId: "1nw70WgEBTmlmQZ5VvmD5olRaT2VphEcMXZYP4YTVqb8",
                        updatedRange: updateRange,
                        updatedRows: <int:Signed32>self.appendCount,
                        updatedColumns: <int:Signed32>self.appendCount,
                        updatedCells: <int:Signed32>self.appendCount
                    }
                }
            };
            self.appendCount += 1;
            if self.appendCount == 4 {
                self.appendCount = 1;
            }
            return okAppendValuesResponse;
        }
        return error("bad URL");
    }

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

    resource function post spreadsheets/[string spreadsheetId]/values/\:batchGetByDataFilter("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchGetValuesByDataFilterRequest payload) returns OkBatchGetValuesByDataFilterResponse {
        return okBatchGetValuesByDataFilterResponse5;
    }

    resource function post spreadsheets/[string spreadsheetId]/values\:batchOkBatchUpdateValuesResponsechUpdate("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateValuesRequest payload) returns OkBatchUpdateValuesResponse {
        return okBatchUpdateValuesResponse;
    }

    resource function post spreadsheets/[string spreadsheetId]/values\:batchUpdateByDataFilter("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateValuesByDataFilterRequest|BatchGetValuesByDataFilterRequest payload) returns OkBatchUpdateValuesByDataFilterResponse|OkBatchGetValuesByDataFilterResponse|error {
        return okBatchUpdateValuesByDataFilterResponse2;
    }

    resource function post spreadsheets/[string spreadsheetidBatchupdate]("1"|"2"? \$\.xgafv, string? access_token, "json"|"media"|"proto"? alt, string? callback, string? fields, string? 'key, string? oauth_token, boolean? prettyPrint, string? quotaUser, string? upload_protocol, string? uploadType, @http:Payload BatchUpdateSpreadsheetRequest payload) returns OkBatchUpdateSpreadsheetResponse|error {
        if !spreadsheetidBatchupdate.endsWith(":batchUpdate") {
            return error("bad URL");
        }
        string sheetId = "";
        if payload.requests is Request[] {
            Request request = (<Request[]>payload.requests)[0];
            if request.deleteSheet is DeleteSheetRequest {
                _ = self.sheetList.pop();
            } else if request.updateSheetProperties is UpdateSheetPropertiesRequest {
                SheetPropertiesType properties = <SheetPropertiesType>(<UpdateSheetPropertiesRequest>request.updateSheetProperties).properties;
                self.spreadsheet.sheets[0].properties.title = properties.title;
            } else if request.updateSpreadsheetProperties is UpdateSpreadsheetPropertiesTypeRequest {
                self.spreadsheetProperties.title = "Ballerina Connector New Renamed";
            } else if request.addSheet is AddSheetRequest {
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
                            gridProperties: {rowCount: 1000, columnCount: 26}
                        }
                    });
                }
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
}
