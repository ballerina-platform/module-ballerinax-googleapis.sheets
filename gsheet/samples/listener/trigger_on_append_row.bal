// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/log;
import ballerinax/googleapis.sheets.'listener as sheetsListener;

configurable int port = ?;
configurable string spreadsheetId = ?;

sheetsListener:SheetListenerConfiguration congifuration = {
    port: port,
    spreadsheetId: spreadsheetId
};

listener sheetsListener:Listener gSheetListener = new (congifuration);

service / on gSheetListener {
    remote function onAppendRow(sheetsListener:GSheetEvent event) returns error? {
        log:printInfo("Received onAppendRow-message ", eventMsg = event);
        // Write your logic here.....
    }
}
