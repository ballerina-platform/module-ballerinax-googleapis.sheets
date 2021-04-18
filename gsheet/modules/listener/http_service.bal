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

import ballerina/http;

service class HttpService {
    private EventDispatcher eventDispatcher;
    private string spreadsheetId;

    public isolated function init(SimpleHttpService httpService, string spreadsheetId) {
        self.eventDispatcher = new (httpService);
        self.spreadsheetId = spreadsheetId;
    }

    isolated resource function post onEdit(http:Caller caller, http:Request request) returns error? {
        json payload = check request.getJsonPayload();
        json spreadsheetId = check payload.spreadsheetId;
        json eventType = check payload.eventType;
        check caller->respond(http:STATUS_OK); 
        if (self.isEventFromMatchingGSheet(spreadsheetId)) {
            GSheetEvent event = {};
            EventInfo eventInfo = check payload.cloneWithType(EventInfo);
            event.eventInfo = eventInfo; 
            error? dispatchResult = self.eventDispatcher.dispatch(eventType.toString(), event);
            if (dispatchResult is error) {
                return error("Failed to dispatch event : ", 'error = dispatchResult);
            }
            return;
        }
        return error("Diffrent spreadsheet IDs found : ", configuredSpreadsheetID = self.spreadsheetId, 
            requestSpreadsheetID = spreadsheetId.toString());
    }

    isolated function isEventFromMatchingGSheet(json spreadsheetId) returns boolean {
        return (self.spreadsheetId == spreadsheetId.toString());
    }
}
