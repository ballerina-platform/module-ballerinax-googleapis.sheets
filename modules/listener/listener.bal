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
import ballerinax/googleapis_drive as drive;

# Listener for Google sheets connector 
@display {label: "Google Sheets Listener"}
public class GoogleSheetEventListener {
    private http:Listener httpListener;
    private drive:Client driveClient;
    private OnEventService eventService;

    private string specificGsheetId;
    private boolean isValidGsheet = false;

    private drive:WatchResponse watchResponse;
    private string channelUuid;
    private string watchResourceId;
    private string currentToken;

    private json[] currentFileStatus = [];

    # Listener initialization
    public function init(SheetListenerConfiguration config) returns error? {
        self.httpListener = check new (config.port);
        self.driveClient = check new (config.driveClientConfiguration);
        self.eventService = config.eventService;
        if (config.specificGsheetId is string) {
            self.isValidGsheet = check checkMimeType(self.driveClient, config.specificGsheetId.toString());
        }
        if (self.isValidGsheet == true) {
            self.specificGsheetId = config.specificGsheetId.toString();
            self.watchResponse = check startWatchChannel(config.callbackURL, self.driveClient, self.specificGsheetId);
            check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificGsheetId);
        } else {
            self.specificGsheetId = EMPTY_STRING;
            self.watchResponse = check startWatchChannel(config.callbackURL, self.driveClient);
            check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
        }
        self.channelUuid = self.watchResponse?.id.toString();
        self.watchResourceId = self.watchResponse?.resourceId.toString();
        self.currentToken = self.watchResponse?.startPageToken.toString();
        log:print("Watch channel started in Google, id : " + self.channelUuid);
    }

    public isolated function attach(http:Service s, string[]|string? name = ()) returns error? {
        return self.httpListener.attach(s, name);
    }

    public isolated function detach(http:Service s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public function gracefulStop() returns error? {
        check stopWatchChannel(self.driveClient, self.channelUuid, self.watchResourceId);
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    # Finding event type triggered and retrieve changes list.
    # 
    # + caller - The http caller object for responding to requests 
    # + request - The HTTP request.
    # + return - Returns error, if unsuccessful.
    public function findEventType(http:Caller caller, http:Request request) returns error? {
        log:print("<< RECEIVING A CALLBACK <<");
        string channelID = check request.getHeader("X-Goog-Channel-ID");
        string messageNumber = check request.getHeader("X-Goog-Message-Number");
        string resourceStates = check request.getHeader("X-Goog-Resource-State");
        string channelExpiration = check request.getHeader("X-Goog-Channel-Expiration");
        if (channelID != self.channelUuid) {
            return error("Diffrent channel IDs found, Resend the watch request");
        } else {
            drive:ChangesListResponse[] response = check getAllChangeList(self.currentToken, self.driveClient);
            foreach drive:ChangesListResponse item in response {
                self.currentToken = item?.newStartPageToken.toString();
                if (self.isValidGsheet) {
                    log:print("File watch response processing");
                    check mapFileUpdateEvents(self.specificGsheetId, item, self.driveClient, self.eventService, 
                        self.currentFileStatus);
                    check getCurrentStatusOfFile(self.driveClient, self.currentFileStatus, self.specificGsheetId);
                } else {
                    log:print("Whole drive watch response processing");
                    check mapEvents(item, self.driveClient, self.eventService, self.currentFileStatus);
                    check getCurrentStatusOfDrive(self.driveClient, self.currentFileStatus);
                }
            }
            check caller->respond(http:STATUS_OK); 
        }
        log:print("<< CALLBACK RECEIVED >>");
    }

    # Finding the change event type triggered according to the incoming request.
    # 
    # + caller - http:Caller for acknowleding to the request received
    # + request - http:Request that contains event related data
    # + return - If success, returns EventInfo record, else error
    public isolated function getOnChangeEventType(http:Caller caller, http:Request request) returns EventInfo|error {
        EventInfo info = {};
        json payload = check request.getJsonPayload();
        check caller->respond(http:STATUS_OK); 
        json changeType = check payload.changeType;
        if (EDIT.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = EDIT;
        } else if (INSERT_ROW.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = INSERT_ROW;
        } else if (REMOVE_ROW.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = REMOVE_ROW;
        } else if (INSERT_COLUMN.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = INSERT_COLUMN;
        } else if (REMOVE_COLUMN.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = REMOVE_COLUMN;
        } else if (INSERT_GRID.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = INSERT_GRID;
        } else if (REMOVE_GRID.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = REMOVE_GRID;
        } else if (OTHER.equalsIgnoreCaseAscii(changeType.toString())) {
            info.eventType = OTHER;
        }
        return info;
    }

    # Obtain the information related to the edit event type triggered according to the incoming request.
    # 
    # + caller - http:Caller for acknowleding to the request received
    # + request - http:Request that contains event related data
    # + return - If success, returns EventInfo record, else error
    public isolated function getOnEditEventType(http:Caller caller, http:Request request) returns EventInfo|error {
        EventInfo info = {};
        json payload = check request.getJsonPayload();
        check caller->respond(http:STATUS_OK); 
        json eventType = check payload.eventType;
        if (APPEND_ROW.equalsIgnoreCaseAscii(eventType.toString())) {
            info.eventType = APPEND_ROW;
        } else if (UPDATE_ROW.equalsIgnoreCaseAscii(eventType.toString())) {
            info.eventType = UPDATE_ROW;
        }
        EditEventInfo editEventInfo = check payload.cloneWithType(EditEventInfo);
        info.editEventInfo = editEventInfo;
        return info;
    }
}
