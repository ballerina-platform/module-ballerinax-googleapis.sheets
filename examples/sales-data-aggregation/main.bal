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

// Regional sales data: [product, units, revenue]
final map<string[][]> regionalSales = {
    "North Region": [
        ["Laptop", "45", "67500"],
        ["Phone", "120", "96000"],
        ["Tablet", "30", "18000"],
        ["Monitor", "25", "12500"]
    ],
    "South Region": [
        ["Laptop", "38", "57000"],
        ["Phone", "95", "76000"],
        ["Tablet", "52", "31200"],
        ["Monitor", "18", "9000"]
    ],
    "East Region": [
        ["Laptop", "60", "90000"],
        ["Phone", "200", "160000"],
        ["Tablet", "40", "24000"],
        ["Monitor", "35", "17500"]
    ]
};

public function main() returns error? {
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->createSpreadsheet("Q1 Sales Report 2024");
    string spreadsheetId = spreadsheet.spreadsheetId;

    // Rename the default sheet to the first region
    string[] regions = regionalSales.keys();
    string firstRegion = regions[0];
    _ = check spreadsheetClient->renameSheet(spreadsheetId, spreadsheet.sheets[0].properties.title, firstRegion);

    // Write data for each region
    foreach int i in 0 ..< regions.length() {
        string region = regions[i];
        string sheetName;
        if i == 0 {
            sheetName = region;
        } else {
            sheets:Sheet regionSheet = check spreadsheetClient->addSheet(spreadsheetId, region);
            sheetName = regionSheet.properties.title;
        }

        string[][] rows = [["Product", "Units Sold", "Revenue (USD)"]];
        string[][] regionData = regionalSales.get(region);
        foreach string[] row in regionData {
            rows.push(row);
        }

        _ = check spreadsheetClient->setRange(spreadsheetId, sheetName, {
            a1Notation: string `A1:C${rows.length()}`,
            values: rows
        });
        log:printInfo(string `Wrote ${regionData.length()} records for '${region}'.`);
    }

    // Aggregate totals by product across all regions
    map<int[]> productTotals = {};
    foreach string region in regions {
        string[][] regionData = regionalSales.get(region);
        foreach string[] row in regionData {
            string product = row[0];
            int units = check int:fromString(row[1]);
            int revenue = check int:fromString(row[2]);
            int[] current = productTotals[product] ?: [0, 0];
            productTotals[product] = [current[0] + units, current[1] + revenue];
        }
    }

    // Write aggregated summary to a new sheet
    sheets:Sheet summarySheet = check spreadsheetClient->addSheet(spreadsheetId, "Summary");
    string summarySheetName = summarySheet.properties.title;

    _ = check spreadsheetClient->setRange(spreadsheetId, summarySheetName, {
        a1Notation: "A1:C1",
        values: [["Product", "Total Units", "Total Revenue (USD)"]]
    });

    int summaryRow = 2;
    int grandUnits = 0;
    int grandRevenue = 0;
    foreach [string, int[]] [product, totals] in productTotals.entries() {
        _ = check spreadsheetClient->createOrUpdateRow(spreadsheetId, summarySheetName, summaryRow,
            [product, totals[0], totals[1]]);
        grandUnits += totals[0];
        grandRevenue += totals[1];
        summaryRow += 1;
    }

    // Grand total row
    _ = check spreadsheetClient->createOrUpdateRow(spreadsheetId, summarySheetName, summaryRow,
        ["TOTAL", grandUnits, grandRevenue]);

    log:printInfo(string `Summary: ${grandUnits} total units sold, USD ${grandRevenue} total revenue.`);
    log:printInfo(string `Spreadsheet: ${spreadsheet.spreadsheetUrl}`);
}
