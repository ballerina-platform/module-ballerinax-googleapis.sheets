// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
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

import ballerina/log;
import ballerina/os;
import ballerinax/googleapis.sheets;

configurable string & readonly refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string & readonly clientId = os:getEnv("CLIENT_ID");
configurable string & readonly clientSecret = os:getEnv("CLIENT_SECRET");
configurable string & readonly refreshUrl = sheets:REFRESH_URL;

sheets:Client spreadsheetClient = check new ({
    auth: {clientId, clientSecret, refreshUrl, refreshToken}
});

// Monthly expense records: [date, category, description, amount (USD)]
final string[][] expenses = [
    ["2024-01-05", "Travel", "Taxi to office", "12.50"],
    ["2024-01-06", "Meals", "Team lunch", "85.00"],
    ["2024-01-07", "Travel", "Flight booking", "320.00"],
    ["2024-01-08", "Office", "Stationery supplies", "45.20"],
    ["2024-01-09", "Meals", "Client dinner", "150.00"],
    ["2024-01-10", "Office", "Printer cartridges", "78.00"],
    ["2024-01-12", "Travel", "Cab to airport", "35.00"],
    ["2024-01-15", "Meals", "Working lunch", "42.00"]
];

public function main() returns error? {
    // Create a new spreadsheet for expense tracking
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->createSpreadsheet("Monthly Expenses - January 2026");
    string spreadsheetId = spreadsheet.spreadsheetId;
    string expenseSheet = spreadsheet.sheets[0].properties.title;

    // Write column headers
    _ = check spreadsheetClient->setRange(spreadsheetId, expenseSheet, {
        a1Notation: "A1:D1",
        values: [["Date", "Category", "Description", "Amount (USD)"]]
    });

    // Append each expense row
    foreach string[] expense in expenses {
        _ = check spreadsheetClient->appendValue(spreadsheetId, expense, <sheets:A1Range>{sheetName: expenseSheet});
    }
    log:printInfo(string `Appended ${expenses.length()} expense records.`);

    // Aggregate totals by category
    map<float> categoryTotals = {};
    foreach string[] expense in expenses {
        string category = expense[1];
        float amount = check float:fromString(expense[3]);
        categoryTotals[category] = (categoryTotals[category] ?: 0.0) + amount;
    }

    // Write category summary to a new sheet
    sheets:Sheet summarySheet = check spreadsheetClient->addSheet(spreadsheetId, "Summary");
    string summarySheetName = summarySheet.properties.title;

    _ = check spreadsheetClient->setRange(spreadsheetId, summarySheetName, {
        a1Notation: "A1:B1",
        values: [["Category", "Total (USD)"]]
    });

    int summaryRow = 2;
    float grandTotal = 0.0;
    foreach [string, float] [category, total] in categoryTotals.entries() {
        _ = check spreadsheetClient->setCell(spreadsheetId, summarySheetName, string `A${summaryRow}`, category);
        _ = check spreadsheetClient->setCell(spreadsheetId, summarySheetName, string `B${summaryRow}`, total.toString());
        grandTotal += total;
        summaryRow += 1;
    }

    // Grand total row
    _ = check spreadsheetClient->setCell(spreadsheetId, summarySheetName, string `A${summaryRow}`, "TOTAL");
    _ = check spreadsheetClient->setCell(spreadsheetId, summarySheetName, string `B${summaryRow}`, grandTotal.toString());

    log:printInfo(string `Summary written. Grand total: USD ${grandTotal}`);
    log:printInfo(string `Spreadsheet: ${spreadsheet.spreadsheetUrl}`);
}
