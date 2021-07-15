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

isolated service class HttpService {
    private final string spreadsheetId;
    private final boolean isOnAppendRowAvailable;
    private final boolean isOnUpdateRowAvailable;
    private final HttpToGSheetAdaptor adaptor;

    isolated function init(HttpToGSheetAdaptor adaptor, string spreadsheetId) {
        self.adaptor = adaptor;
        self.spreadsheetId = spreadsheetId;

        string[] methodNames = adaptor.getServiceMethodNames();
        self.isOnAppendRowAvailable = isMethodAvailable(ON_APPEND_ROW, methodNames);
        self.isOnUpdateRowAvailable = isMethodAvailable(ON_UPDATE_ROW, methodNames);

        if (methodNames.length() > 0) {
            foreach string methodName in methodNames {
                log:printError("Unrecognized method [" + methodName + "] found in user implementation."); 
            }
        }
    }

    isolated resource function post onEdit(http:Caller caller, http:Request request) returns @tainted error? {
        json payload = check request.getJsonPayload();
        json spreadsheetId = check payload.spreadsheetId;
        json eventType = check payload.eventType;

        GSheetEvent event = {};
        EventInfo eventInfo = check payload.cloneWithType(EventInfo);
        event.eventInfo = eventInfo; 

        if (self.isEventFromMatchingGSheet(spreadsheetId)) {        
            error? dispatchResult = self.dispatch(eventType.toString(), event);
            if (dispatchResult is error) {
                return error("Dispatching or remote function error : ", 'error = dispatchResult);
            }
            http:Response res = new;
            res.statusCode = http:STATUS_OK;
            check caller->respond(res); 
            return;
        }
        return error("Diffrent spreadsheet IDs found : ", configuredSpreadsheetID = self.spreadsheetId, 
            requestSpreadsheetID = spreadsheetId.toString());
    }

    isolated function isEventFromMatchingGSheet(json spreadsheetId) returns boolean {
        return (self.spreadsheetId == spreadsheetId.toString());
    }

    isolated function dispatch(string eventType, GSheetEvent event) returns error? {
        match eventType.toString() {
            APPEND_ROW => {
                if (self.isOnAppendRowAvailable) {
                    event.eventType = APPEND_ROW;
                    check self.adaptor.callOnAppendRowMethod(event);
                } 
            }
            UPDATE_ROW => {
                if (self.isOnUpdateRowAvailable) {
                    event.eventType = UPDATE_ROW;
                    check self.adaptor.callOnUpdateRowMethod(event);
                } 
            }
            _ => {
                log:printError("Unrecognized event type [" + eventType.toString() 
                    + "] found in the response payload");
            }
        }
        return;
    }
}

# Retrieves whether the particular remote method is available.
#
# + methodName - Name of the required method
# + methods - All available methods
# + return - `true` if method available or else `false`
isolated function isMethodAvailable(string methodName, string[] methods) returns boolean {
    boolean isAvailable = methods.indexOf(methodName) is int;
    if (isAvailable) {
        var index = methods.indexOf(methodName);
        if (index is int) {
            _ = methods.remove(index);
        }
    }
    return isAvailable;
}
