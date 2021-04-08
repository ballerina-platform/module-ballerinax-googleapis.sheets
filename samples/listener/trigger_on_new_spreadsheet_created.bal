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
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {
        log:print("New File was created : " + fileId);
        // Write your logic here.....
    }

    public isolated function onSheetDeletedEvent(string fileId) {}

    public isolated function onFileUpdateEvent(string fileId) {}
}

configurable int port = ?;
configurable string callbackURL = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;
configurable string refreshToken = ?;

drive:Configuration clientConfiguration = {
    clientConfig: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: refreshUrl,
        refreshToken: refreshToken
    }
};

sheetsListener:SheetListenerConfiguration congifuration = {
    port: port,
    callbackURL: callbackURL,
    driveClientConfiguration: clientConfiguration,
    eventService: new EventTrigger()
};

listener sheetsListener:GoogleSheetEventListener gSheetListener = new (congifuration);

service / on gSheetListener {
    resource function post onManage (http:Caller caller, http:Request request) returns error? {
        check gSheetListener.findEventType(caller, request); 
    }
}
