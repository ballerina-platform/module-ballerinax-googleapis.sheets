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
