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

// Initial inventory: [SKU, product name, quantity, reorder threshold]
final string[][] initialInventory = [
    ["SKU-001", "Wireless Mouse", "150", "20"],
    ["SKU-002", "USB-C Cable", "300", "50"],
    ["SKU-003", "HDMI Adapter", "12", "15"],
    ["SKU-004", "Mechanical Keyboard", "45", "10"],
    ["SKU-005", "Webcam HD", "8", "10"],
    ["SKU-006", "Laptop Stand", "60", "15"],
    ["SKU-007", "Monitor Light Bar", "5", "10"]
];

// Incoming stock changes: [SKU, delta (positive = restock, negative = sold)]
final map<int> stockChanges = {
    "SKU-001": -40,
    "SKU-002": 100,
    "SKU-003": -5,
    "SKU-004": 20,
    "SKU-005": -6,
    "SKU-006": -30,
    "SKU-007": 15
};

public function main() returns error? {
    sheets:Spreadsheet spreadsheet = check spreadsheetClient->createSpreadsheet("Inventory Tracker");
    string spreadsheetId = spreadsheet.spreadsheetId;
    string inventorySheet = spreadsheet.sheets[0].properties.title;

    // Write headers and initial inventory
    string[][] inventoryData = [["SKU", "Product", "Quantity", "Reorder Threshold", "Status"]];
    foreach string[] item in initialInventory {
        int qty = check int:fromString(item[2]);
        int threshold = check int:fromString(item[3]);
        string status = qty <= threshold ? "LOW STOCK" : "OK";
        inventoryData.push([item[0], item[1], item[2], item[3], status]);
    }
    _ = check spreadsheetClient->setRange(spreadsheetId, inventorySheet, {
        a1Notation: string `A1:E${inventoryData.length()}`,
        values: inventoryData
    });
    log:printInfo(string `Loaded ${initialInventory.length()} inventory items.`);

    // Apply stock changes and update each row
    int lowStockCount = 0;
    foreach int i in 0 ..< initialInventory.length() {
        string[] item = initialInventory[i];
        string sku = item[0];
        int currentQty = check int:fromString(item[2]);
        int threshold = check int:fromString(item[3]);

        int delta = stockChanges[sku] ?: 0;
        int updatedQty = currentQty + delta;
        string status = updatedQty <= threshold ? "LOW STOCK" : "OK";

        int sheetRow = i + 2; // +1 for header, +1 for 1-based indexing
        _ = check spreadsheetClient->setCell(spreadsheetId, inventorySheet, string `C${sheetRow}`, updatedQty);
        _ = check spreadsheetClient->setCell(spreadsheetId, inventorySheet, string `E${sheetRow}`, status);

        if updatedQty <= threshold {
            log:printWarn(string `LOW STOCK: ${item[1]} (${sku}) — ${updatedQty} units remaining (threshold: ${threshold})`);
            lowStockCount += 1;
        } else {
            log:printInfo(string `Updated: ${item[1]} (${sku}) — ${currentQty} → ${updatedQty} units`);
        }
    }

    log:printInfo(string `Stock update complete. ${lowStockCount} item(s) below reorder threshold.`);
    log:printInfo(string `Spreadsheet: ${spreadsheet.spreadsheetUrl}`);
}
