// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package samples.wso2.oauth2;

import ballerina.io;
import src.wso2.oauth2;
import ballerina.net.http;

public function main (string[] args) {
    http:Request req = {};
    // Send a GET request to the specified endpoint
    oauth2:OAuth2Client oauth = {};
    oauth.init(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
    http:Response resp = {};
    resp, _ = oauth.get(args[7], req);
    io:println("GET request:");
    var jsonPayload1, payloadError1 = resp.getJsonPayload();
    if (payloadError1 == null) {
        io:println(jsonPayload1);
    } else {
        io:println(payloadError1.message);
    }
}
