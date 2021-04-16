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
import ballerina/log;

service class HttpService {
    private boolean isOnAppendRowAvailable = false;
    private boolean isOnUpdateRowAvailable = false;

    private SimpleHttpService httpService;
    private string spreadsheetId;

    public isolated function init(SimpleHttpService httpService, string spreadsheetId) {
        self.httpService = httpService;
        self.spreadsheetId = spreadsheetId;

        string[] methodNames = getServiceMethodNames(httpService);

        foreach var methodName in methodNames {
            match methodName {
                ON_APPEND_ROW => {
                    self.isOnAppendRowAvailable = true;
                }
                ON_UPDATE_ROW => {
                    self.isOnUpdateRowAvailable = true;
                }
                _ => {
                    log:printError("Unrecognized method [" + methodName + "] found in the implementation");
                }
            }
        }
    }

    isolated resource function post onEdit(http:Caller caller, http:Request request) returns error? {
        EventInfo info = {};
        json payload = check request.getJsonPayload();
        check caller->respond(http:STATUS_OK); 
        json spreadsheetId = check payload.spreadsheetId;
        if (self.spreadsheetId == spreadsheetId.toString()) {
            EditEventInfo editEventInfo = check payload.cloneWithType(EditEventInfo);
            info.editEventInfo = editEventInfo; 
            json eventType = check payload.eventType;
            match eventType.toString() {
                APPEND_ROW => {
                    if (self.isOnAppendRowAvailable) {
                        info.eventType = APPEND_ROW;
                        check callOnAppendRowMethod(self.httpService, info);
                    }
                }
                UPDATE_ROW => {
                    if (self.isOnUpdateRowAvailable) {
                        info.eventType = UPDATE_ROW;
                        check callOnUpdateRowMethod(self.httpService, info);
                    }
                }
                _ => {
                        log:printError("Unrecognized event type [" + eventType.toString() 
                            + "] found in the response payload");
                }
            }
            return;
        }
        return error("Diffrent spreadsheet IDs found");
    }
}
