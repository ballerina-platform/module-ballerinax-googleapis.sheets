## Overview

The [Ballerina](https://ballerina.io/) listener for Google Sheets provides the capability to listen to simple events using the [App Scripts triggers](https://developers.google.com/apps-script/guides/triggers). App Scripts runs a function automatically whenever a certain event occurs, for example, when a user changes a value in a spreadsheet. When an event is triggered, Apps Script passes the event object ( typically `e`) as an argument to the function. The event object contains information about the context that caused the event to trigger. Using App Script [Installable triggers](https://developers.google.com/apps-script/guides/triggers/installable) we can invoke services that require authorization and pass the event information. The Google Sheets Ballerina listener can listen to these events triggered and execute the user logic based on the event type received.

The `/onEdit` service endpoint, can listen to events triggered  when a spreadsheet is edited such as when a row is appended to a spreadsheet or when a row is updated in a spreadsheet with the following trigger methods: 
* `onAppendRow`
* `onUpdateRow`

This module supports [Google App Scripts](https://developers.google.com/apps-script/guides/triggers).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

- Create [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp)
- Enable Google App Script trigger to listen to internal changes of a spreadsheet.

    1. Open the google sheet.
    2. Navigate to `Tools > Script Editor`.
    3. Name your project. (Example: Name the project `GSheet_Ballerina_Trigger`)
    4. Remove all the code that is currently in the Code.gs file, and replace it with this:
        ```
        function atChange(e){
            if (e.changeType == "REMOVE_ROW") {
                saveDeleteStatus(1);
            }
        }

        function atEdit(e){
            var source = e.source;
            var range = e.range;

            var a = range.getRow();
            var b = range.getSheet().getLastRow();
            var previousLastRow = Number(getValue());
            var deleteStatus = Number(getDeleteStatus());
            var eventType = "edit";

            if ((a == b && b != previousLastRow) || (a == b && b == previousLastRow && deleteStatus == 1)) {
                eventType = "appendRow";
            }
            else if ((a != b) || (a == b && b == previousLastRow && deleteStatus == 0)) {
                eventType = "updateRow";
            }
            
            var formData = {
                    'spreadsheetId' : source.getId(),
                    'spreadsheetName' : source.getName(),
                    'worksheetId' : range.getSheet().getSheetId(),
                    'worksheetName' : range.getSheet().getName(),
                    'rangeUpdated' : range.getA1Notation(),
                    'startingRowPosition' : range.getRow(),
                    'startingColumnPosition' : range.getColumn(),
                    'endRowPosition' : range.getLastRow(),
                    'endColumnPosition' : range.getLastColumn(),
                    'newValues' : range.getValues(),
                    'lastRowWithContent' : range.getSheet().getLastRow(),
                    'lastColumnWithContent' : range.getSheet().getLastColumn(),
                    'previousLastRow' : previousLastRow,
                    'eventType' : eventType,
                    'eventData' : e
            };
            var payload = JSON.stringify(formData);

            var options = {
                'method' : 'post',
                'contentType': 'application/json',
                'payload' : payload
            };

            UrlFetchApp.fetch('<BASE_URL>/onEdit/', options);

            saveValue(range.getSheet().getLastRow());
            saveDeleteStatus(0);
        }

        var properties = PropertiesService.getScriptProperties();

        function saveValue(lastRow) {
            properties.setProperty('PREVIOUS_LAST_ROW', lastRow);
        }

        function getValue() {
            return properties.getProperty('PREVIOUS_LAST_ROW');
        }

        function saveDeleteStatus(deleteStatus) {
            properties.setProperty('DELETE_STATUS', deleteStatus);
        }

        function getDeleteStatus() {
            return properties.getProperty('DELETE_STATUS');
        }
        ```
        We’re using the UrlFetchApp class to communicate with other applications on the internet.

    5. Replace the <BASE_URL> section with the base URL where your listener service is running. (Note: You can use [ngrok](https://ngrok.com/docs) to expose your web server to the internet. Example: 'https://7745640c2478.ngrok.io/onEdit/')
    6. Navigate to the `Triggers` section in the left menu of the editor.
    7. Click `Add Trigger` button.
    8. Select the following values for the following fields.

        | Field                        | Value             |
        |------------------------------|-------------------|
        | Choose which function to run | `atChange`        |
        | Select event source          | `From spreadsheet`|
        | Select event type            | `On change`       |

    9. This will prompt you to authorize your script to connect to an external service. Click `Review Permissions` and then `Allow` to continue.
    10. Repeat the same process, add a new trigger with the following values for the following fields. Then click Save!.

        | Field                        | Value             |
        |------------------------------|-------------------|
        | Choose which function to run | `atEdit`          |
        | Select event source          | `From spreadsheet`|
        | Select event type            | `On edit`         |
    11. You have now configured your triggers. You can test these triggers by editing the Google sheet.

## Quickstart

To use the Google Sheets listener in your Ballerina application, update the .bal file as follows:

### Step 1: Import listener
Import the ballerinax/googleapis.sheets.'listener module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.sheets.'listener as sheetsListener;
```

### Step 2: Create a new listener instance
Create a `sheetsListener:ConnectionConfig` with the spreadsheet ID obtained, and initialize the listener with it. 
```ballerina
    sheetsListener:SheetListenerConfiguration congifuration = {
        port: <LISTENER_PORT>,
        spreadsheetId: <IDENTIFIER_OF_THE_SPREADSHEET>
    };

    listener sheetsListener:Listener gSheetListener = new (congifuration);
```
**!!! NOTE:** Spreadsheet ID is available in the spreadsheet URL "https://docs.google.com/spreadsheets/d/" + <SPREADSHEET_ID> + "/edit#gid=" + <WORKSHEET_ID>

### Step 3: Invoke listener triggers
1. Now you can use the triggers available within the listener. 

    Following is an example on how to listen to append events and update events of a spreadsheet using the listener. 
    Add the trigger implementation logic under each section based on the event type you want to listen to using the Google sheets Listener.

    Listen to append events and update events

    ```ballerina
    service / on gSheetListener {
        remote function onAppendRow(sheetsListener:GSheetEvent event) returns error? {
            log:printInfo("Received onAppendRow-message ", eventMsg = event);
            // Write your logic here.....
        }

        remote function onUpdateRow(sheetsListener:GSheetEvent event) returns error? {
            log:printInfo("Received onUpdateRow-message ", eventMsg = event);
            // Write your logic here.....
        }
    }
    ```

    **!!! NOTE:** The Google Sheets Listener supports the service endpoint `/onEdit`. The `/onEdit` service endpoint, can listen to events triggered when a spreadsheet is edited such as when a new row is appended or when a row is updated with the following trigger methods: `onAppendRow`, `onUpdateRow`. We can get more information about the edit event such as the `spreadsheet ID, spreadsheet name, worksheet ID, worksheet name, range updated, starting row position, end row position, starting column position, end column position, new values, last row with content, last column with content` etc.

2. Use `bal run` command to compile and run the Ballerina program. 

**!!! NOTE:** At user function implementation if there was an error we throw it up & the http client will return status 500 error. 
If no any error occured & the user logic is executed successfully we respond with status 200 OK. 
If the user logic in listener remote operations include heavy processing, the user may face http timeout issues. 
To solve this issue, user must use asynchronous processing when it includes heavy processing.

```ballerina
import ballerinax/googleapis.sheets.'listener as sheetsListener;

configurable int port = ?;
configurable string spreadsheetId = ?;

sheetsListener:SheetListenerConfiguration congifuration = {
    port: port,
    spreadsheetId: spreadsheetId
};

listener sheetsListener:Listener gSheetListener = new (congifuration);

service / on gsheetListener {
    isolated remote function onAppendRow(GSheetEvent event) {
       _ = @strand { thread: "any" } start userLogic(event);
    }
}

function userLogic(sheetsListener:GSheetEvent event) returns error? {
    // Write your logic here
}
```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/gsheet/samples/listener)**
