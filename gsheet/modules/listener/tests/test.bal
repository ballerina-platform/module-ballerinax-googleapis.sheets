import ballerina/http;
import ballerina/log;
import ballerina/test;
import ballerina/os;

configurable int port = 9090;
configurable string spreadsheetId = os:getEnv("SPREADSHEET_ID");

SheetListenerConfiguration congifuration = {
    port: port,
    spreadsheetId: spreadsheetId
};

listener Listener gsheetListener = new (congifuration);

service / on gsheetListener {
    isolated remote function onAppendRow(EventInfo event) returns error? {
        log:printInfo("Received onAppendRow-message ", eventMsg = event);
    }

    isolated remote function onUpdateRow(EventInfo event) returns error? {
        log:printInfo("Received onUpdateRow-message ", eventMsg = event);
    }
}

http:Client httpClient = checkpanic new("http://localhost:9090/onEdit");

@test:Config {}
function testOnAppendRowTrigger() returns @tainted error? {
    http:Request request = new;
    json payload =  {"eventType":"appendRow","editEventInfo":{"spreadsheetId":"1cBz31FboLUNyoyO_MK6vwGr6CJ9QDABb",
        "spreadsheetName":"TestListener","worksheetId":0,"worksheetName":"Sheet1","rangeUpdated":"A3:C3",
        "startingRowPosition":3,"endRowPosition":3,"startingColumnPosition":1,"endColumnPosition":3,
        "newValues":[["sdf","kl","lk"]],"lastRowWithContent":3,"lastColumnWithContent":3,
        "eventData":{"authMode":"FULL","range":{"columnEnd":3,"columnStart":1,"rowEnd":3,"rowStart":3},"source":{},
        "triggerUid":"6785380","user":{"email":"user@wso2.com","nickname":"user"}},"previousLastRow":2,
        "eventType":"appendRow"}};
    request.setPayload(payload);

    var response = httpClient->post("/", request);
    if (response is http:Response) {
        test:assertEquals(response.statusCode, 200);
    } else {
        test:assertFail("GSheet listener onAppendRow test failed");
    }
}

@test:Config {}
function testOnUpdateRowTrigger() returns @tainted error? {
    http:Request request = new;
    json payload =  {"eventType":"updateRow","editEventInfo":{"spreadsheetId":"1cBz31FboLUNyoyO_MK6vwGr6CJ9QDABbTAzIPs",
        "spreadsheetName":"TestListener","worksheetId":0,"worksheetName":"Sheet1","rangeUpdated":"B1",
        "startingRowPosition":1,"endRowPosition":1,"startingColumnPosition":2,"endColumnPosition":2,
        "newValues":[["k"]],"lastRowWithContent":2,"lastColumnWithContent":3,"eventData":{"authMode":"FULL",
        "oldValue":"ui","range":{"columnEnd":2,"columnStart":2,"rowEnd":1,"rowStart":1},"source":{},
        "triggerUid":"6785380","user":{"email":"user@wso2.com","nickname":"user"},"value":"k"},
        "previousLastRow":2,"eventType":"updateRow"}};
    request.setPayload(payload);

    var response = httpClient->post("/", request);
    if (response is http:Response) {
        test:assertEquals(response.statusCode, 200);
    } else {
        test:assertFail("GSheet listener onUpdateRow test failed");
    }
}
