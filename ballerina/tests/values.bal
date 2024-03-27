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

SpreadsheetPropertiesType spreadsheetProperties = {
    title: "Ballerina Connector New",
    locale: "en_GB",
    autoRecalc: "ON_CHANGE",
    timeZone: "Etc/GMT"
};

SheetType sheet1 = {
    properties: {
        sheetId: 1094486074,
        title: "Sheet1",
        index: 1,
        sheetType: "GRID",
        gridProperties: {
            rowCount: 1000,
            columnCount: 26
        }
    }
};

anydata[][] values1 = [
    [
        "Update",
        "Score",
        "Performance",
        "Average"
    ],
    [
        "Column",
        "12",
        "AVERAGE(B2:C2)",
        "AVERAGE(B2:C2)"
    ],
    [
        "Values",
        "78",
        "AVERAGE(B3:C3)",
        "AVERAGE(B3:C3)"
    ]
];

anydata[][] value2 = [
    [
        "Update",
        "Row",
        "Values"
    ],
    [
        "Column",
        "12",
        "AVERAGE(B2:C2)",
        "AVERAGE(B2:C2)"
    ],
    [
        "Values",
        "78",
        "AVERAGE(B3:C3)",
        "AVERAGE(B3:C3)"
    ]
];

anydata[][] value3 = [
    [
        "ModifiedValue",
        "Score",
        "Performance",
        "Average"
    ],
    [
        "Keetz",
        "12"
    ],
    [
        "Niro",
        "78"
    ],
    [
        "Nisha",
        "98"
    ],
    [
        "Kana",
        "84"
    ]
];

anydata[][] value4 = [
    [
        "Name",
        "Score",
        "Performance",
        "Average"
    ],
    [
        "Keetz",
        "12"
    ],
    [
        "Niro",
        "78"
    ],
    [
        "Nisha",
        "98"
    ],
    [
        "Kana",
        "84"
    ]
];

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

OkSearchDeveloperMetadataResponse okSearchDeveloperMetadataResponse = {
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

OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse = {
    body: {
        spreadsheetId: "17ZMwIN6LTxeFeNQHBT7vvJNoiYWrDm0Qe_lvjL0BXss",
        valueRanges: [
            {
                valueRange: {
                    range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A2:D2",
                    majorDimension: "ROWS",
                    values: [
                        [
                            "Appending",
                            "Some",
                            "Values Updated With gridrange"
                        ]
                    ]
                },
                dataFilters: [
                    {
                        a1Range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A3:C3"
                    }
                ]
            }
        ]
    }
};

OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse2 = {
    body: {
        spreadsheetId: "17ZMwIN6LTxeFeNQHBT7vvJNoiYWrDm0Qe_lvjL0BXss",
        valueRanges: []
    }
};

OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse3 = {
    body: {
        spreadsheetId: "17ZMwIN6LTxeFeNQHBT7vvJNoiYWrDm0Qe_lvjL0BXss",
        valueRanges: [
            {
                valueRange: {
                    range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A1:AB1",
                    majorDimension: "ROWS",
                    values: [
                        [
                            "Appending",
                            "Some",
                            "Values Updated With Metadata"
                        ]
                    ]
                },
                dataFilters: [
                    {
                        a1Range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A1:AB1"
                    }
                ]
            }
        ]
    }
};

OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse4 = {
    body: {
        spreadsheetId: "17ZMwIN6LTxeFeNQHBT7vvJNoiYWrDm0Qe_lvjL0BXss",
        valueRanges: [
            {
                valueRange: {
                    range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A3:C3",
                    majorDimension: "ROWS",
                    values: [
                        [
                            "Appending",
                            "FALSE",
                            "0.1"
                        ]
                    ]
                },
                dataFilters: [
                    {
                        a1Range: "Dance_dfb2f7a305164effad47bb9aa54c9570!A3:C3"
                    }
                ]
            }
        ]
    }
};

OkBatchUpdateValuesByDataFilterResponse okBatchUpdateValuesByDataFilterResponse2 = {
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
OkBatchGetValuesByDataFilterResponse okBatchGetValuesByDataFilterResponse5 = {
    body: {
        spreadsheetId: "dummy_spreadsheet_id",
        valueRanges: [var1]
    }
};

ValueRangeType valueRange1 = {
    range: "I1:D5",
    majorDimension: "ROWS",
    values: values1
};

ValueRangeType valueRange2 = {
    range: "10:10",
    majorDimension: "ROWS",
    values: value2
};

ValueRangeType valueRange3 = {
    range: "H1",
    majorDimension: "ROWS",
    values: value3
};
