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

# Listener for the Google Sheets connector
@display {label: "Google Sheets Listener"}
public class Listener {
    private http:Listener httpListener;
    private SheetListenerConfiguration config; 
    private HttpService httpService;

    # Initializes the Google Sheets connector listener.
    #
    # + config - Configurations required to initialize the listener
    public isolated function init(SheetListenerConfiguration config) returns @tainted error? {
        self.httpListener = check new (config.port);
        self.config = config;
    }

    public isolated function attach(SimpleHttpService s, string[]|string? name = ()) returns @tainted error? {
        HttpToGSheetAdaptor adaptor = check new (s);   
        self.httpService = new HttpService(adaptor, self.config.spreadsheetId);
        check self.httpListener.attach(self.httpService, name);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public isolated function detach(SimpleHttpService s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function gracefulStop() returns error? {
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }
}
