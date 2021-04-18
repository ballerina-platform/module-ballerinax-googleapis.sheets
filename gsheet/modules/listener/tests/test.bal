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
    isolated remote function onAppendRow(GSheetEvent event) returns error? {
        log:printInfo("Received onAppendRow-message ", eventMsg = event);
    }

    isolated remote function onUpdateRow(GSheetEvent event) returns error? {
        log:printInfo("Received onUpdateRow-message ", eventMsg = event);
    }
}

http:Client httpClient = checkpanic new("http://localhost:9090/onEdit");

@test:Config {}
function testOnAppendRowTrigger() returns @tainted error? {
    http:Request request = new;
    json payload =  {"spreadsheetId":"1cBz31FboLUNyoyO_MK6vwGr6CJ9QDABbTAzIPsfyuqA","spreadsheetName":"TestListener",
        "worksheetId":0,"worksheetName":"Sheet1","rangeUpdated":"A6:C6","startingRowPosition":6,
        "startingColumnPosition":1,"endRowPosition":6,"endColumnPosition":3,"newValues":[["a","b","c"]],
        "lastRowWithContent":6,"lastColumnWithContent":3,"previousLastRow":5,"eventType":"appendRow",
        "eventData":{"authMode":"FULL","range":{"columnEnd":3,"columnStart":1,"rowEnd":6,"rowStart":6},"source":{},
        "triggerUid":"6785380","user":{"email":"rolandh@wso2.com","nickname":"rolandh"}}};
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
    json payload =  {"spreadsheetId":"1cBz31FboLUNyoyO_MK6vwGr6CJ9QDABbTAzIPsfyuqA","spreadsheetName":"TestListener",
        "worksheetId":0,"worksheetName":"Sheet1","rangeUpdated":"B4","startingRowPosition":4,"startingColumnPosition":2,
        "endRowPosition":4,"endColumnPosition":2,"newValues":[["a"]],"lastRowWithContent":6,"lastColumnWithContent":3,
        "previousLastRow":6,"eventType":"updateRow","eventData":{"authMode":"FULL","oldValue":"kl",
        "range":{"columnEnd":2,"columnStart":2,"rowEnd":4,"rowStart":4},"source":{},"triggerUid":"6785380",
        "user":{"email":"rolandh@wso2.com","nickname":"rolandh"},"value":"a"}};
    request.setPayload(payload);

    var response = httpClient->post("/", request);
    if (response is http:Response) {
        test:assertEquals(response.statusCode, 200);
    } else {
        test:assertFail("GSheet listener onUpdateRow test failed");
    }
}
