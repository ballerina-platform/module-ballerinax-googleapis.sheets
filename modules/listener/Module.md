# Ballerina Google Sheets Listener Module

Listen to Google sheets events using Ballerina.

# Module Overview

The Google Spreadsheet Listener Ballerina Module provides the capability to listen the push notifications for changes to the spreadsheet resource through the [Drive API](https://developers.google.com/drive/api/v3/push). The underline google sheets API does not directly support this feature. Whenever a watched spreadsheet resource changes, the Drive API notifies the application and the Google sheet listener gets triggered. The Google sheet listener can listen to management related changes of a spreadsheet (using the `/onManage` service endpoint) such as creation of a new spreadsheet and deletion of a spreadsheet with the following trigger methods: `onNewSheetCreatedEvent`, `onSheetDeletedEvent`. The Google Spreadsheet Listener Ballerina Module provides the capability to listen to simple events using the triggers via [App Scripts](https://developers.google.com/apps-script/guides/triggers). App Scripts run a function automatically whenever a certain event, like user changes a value in a spreadsheet. When a trigger fires, Apps Script passes the function an event object as an argument, typically called `e`. The event object contains information about the context that caused the trigger to fire. Using App Script [Installable triggers](https://developers.google.com/apps-script/guides/triggers/installable) we can call services that require authorization and pass these event information. The Google sheet listener can listen to these events triggered for different type of changes such as editing a spreadsheet, inserting a blank row, removing a row, inserting a blank column, removing a column, inserting a new grid, removing a new grid from a spreadsheet with the service endpoint `/onChange` that capture change event types `EDIT`, `INSERT_ROW`, `REMOVE_ROW`, `INSERT_COLUMN`, `REMOVE_COLUMN`, `INSERT_GRID`, `REMOVE_GRID`, `OTHER` etc. and execute the user logic when an event with one of the above change event type is received. By using the `/onEdit` service endpoint that capture edit event types `APPEND_ROW`, `UPDATE_ROW`, the google sheets listener gets triggered when a spreadsheet is edited and can get more information about the edit event such as the `spreadsheet ID, spreadsheet name, worksheet ID, worksheet name, range updated, starting row position, end row position, starting column position, end column position, new values, last row with content, last column with content`etc.

# Compatibility

| Ballerina Language Versions  | GSheet API Version |
|:----------------------------:|:------------------:|
|  Swan Lake Alpha 2           |   v4               |


# Supported Trigger Operations

## On Manage Trigger Endpoint
The `/onManage` service endpoint can listen to management related changes of a spreadsheet such as creation of a new spreadsheet and deletion of a spreadsheet with the following trigger methods: 

* `onNewSheetCreatedEvent`
* `onSheetDeletedEvent`

## On Change Trigger Endpoint
The `/onChange` service endpoint can listen to events triggered for different type of changes to a spreadsheet such as editing a spreadsheet, inserting a blank row, removing a row, inserting a blank column, removing a column, inserting a new grid (worksheet), removing a new grid (worksheet) from a spreadsheet that capture change event types 

* `EDIT`, 
* `INSERT_ROW`
* `REMOVE_ROW` 
* `INSERT_COLUMN` 
* `REMOVE_COLUMN` 
* `INSERT_GRID`
* `REMOVE_GRID` 
* `OTHER` 


## On Edit Trigger Endpoint
The `/onEdit` service endpoint, can listen to events triggered  when a spreadsheet is edited such as when a row is appended to a spreadsheet or when a row is updated in a spreadsheet that capture change event types.

* `APPEND_ROW`
* `UPDATE_ROW`

We can get more information about the edit event such as the 
* `spreadsheet ID` 
* `spreadsheet name` 
* `worksheet ID` 
* `worksheet name` 
* `range updated` 
* `starting row position` 
* `end row position` 
* `starting column position` 
* `end column position` 
* `new values` 
* `last row with content` 
* `last column with content`
* etc.

# Prerequisites:

* Java 11 Installed
Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/)
Ballerina Swan Lake Alpha 2 is required.

* Instantiate the Google Drive connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for Bearer Token Authentication and OAuth 2.0. Google Drive uses OAuth 2.0 to authenticate and authorize requests. It uses the Direct Token Grant Type. The Google Drive connector can be minimally instantiated in the HTTP client config using the OAuth 2.0 access token.
    * Access Token 
    ```ballerina
    drive:Configuration config = {
        clientConfig: {
            token: <access token>
        }
    };
    ```

    The Google Drive connector can also be instantiated in the HTTP client config without the access token using the client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token
    * Refresh URL
    ```ballerina
    drive:Configuration config = {
        clientConfig: {
            clientId: <clientId>,
            clientSecret: <clientSecret>,
            refreshToken: <refreshToken>,
            refreshUrl: <drive:REFRESH_URL>
        }
    };
    ```

## Obtaining Tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Google Spreadsheet scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the access token and refresh token.

## Enable Google App Script Trigger
We need to enable the app script trigger if we want to listen to internal changes of a spreadsheet. Follow the following steps to enable the trigger.

1. Open the Google sheet that you want to listen to internal changes.
2. Navigate to `Tools > Script Editor`.
3. Name your project. (Example: Name the project `GSheet_Ballerina_Trigger`)
4. Remove all the code that is currently in the Code.gs file, and replace it with this:
    ```
    function atChange(e){
        var formData = {
            'changeType': e.changeType
        };
        var payload = JSON.stringify(formData);

        if (e.changeType == "REMOVE_ROW") {
            saveDeleteStatus(1);
        }

        var options = {
            'method' : 'post',
            'contentType': 'application/json',
            'payload' : payload
        };

        UrlFetchApp.fetch('<BASE_URL>/onChange/', options);
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
                'eventType' : eventType
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

5. Replace the <BASE_URL> section with the base URL where your listener service is running. (Note: You can use [ngrok](https://ngrok.com/docs) to expose your web server to the internet. Example: 'https://7745640c2478.ngrok.io/onChange/')
6. Navigate to the `Triggers` section in the left menu of the editor.
7. Click `Add Trigger` button.
8. Then make sure you 'Choose which function to run' is `atChange` then 'Select event source' is `From spreadsheet` then 'Select event type' is  `On change` then click Save!.
9. This will prompt you to authorize your script to connect to an external service. Click “Review Permissions” and then “Allow” to continue.
10. Repeat the same process, add a new trigger this time choose this 'Choose which function to run' is `atEdit` then 'Select event source' is `From spreadsheet` then 'Select event type' is  `On edit` then click Save!.
11. Your triggers will now work as you expect, if you go edit any cell and as soon as you leave that cell this trigger will run and it will hit your endpoint with the data!



## Add project configurations file
Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the token obtained in the previous step to the `Config.toml` file.

```
[<org>.<name>]
refreshToken = "enter your refresh token for GDrive here"
clientId = "enter your client id for GDrive here"
clientSecret = "enter your client secret for GDrive here"
callbackURL = "enter your call back URL to the GSheer listener here"
trustStorePath = "enter a truststore path if required"
trustStorePassword = "enter a truststore password if required"

```

# Quickstart(s):

## Working with GSheets listener

### Step 1: Import the Google drive and Google sheets listener Ballerina libraries
First, import the ballerinax/googleapis_drive & ballerinax/googleapis_sheets.'listener module into the Ballerina project.
```ballerina
    import ballerinax/googleapis_drive as drive;
    import ballerinax/googleapis_sheets.'listener as sheetsListener;
```

### Step 2: Create EventTrigger Class with the trigger implementation logic 
Then you need to create the Event Trigger Class with the implementations for the necessary trigger functions. Each trigger method should be implemented only if you want to listen to events receieved at the `/onManage` trigger endpoint.
```ballerina
# Event Trigger class
public class sheetsListener:EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {
        log:print("New File was created : " + fileId);
        // Write your logic here.....
    }

    public isolated function onSheetDeletedEvent(string fileId) {
        log:print("This File was removed to the trash : " + fileId);
        // Write your logic here.....
    }

    public isolated function onFileUpdateEvent(string fileId) {
        log:print("The File was updated : " + fileId);
        // Write your logic here.....
    }
}
```

### Step 3: Enable Google App Script Trigger
We need to enable the app script trigger if we want to listen to internal changes of a spreadsheet. Follow the [Enable Google App Script Trigger](##enable-google-app-script-trigger) guide in the prerequisite section. This should be enabled only if you want to listen to events receieved through the `/onChange` & `/onEdit` trigger endpoints.

### Step 3: Initialize the Google Drive Client and Google Sheets Listener
In order for you to use the Google Sheets Listener Endpoint, first you need to create a Google Drive Client endpoint and a Google Sheets Listener Endpoint.
```ballerina
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
```


### Step 4: Implement the service endpoint with the service logic for the supported triggers
The Google Sheets Listener supports 3 service endpoints `/onManage`, `/onChange` and `/onEdit` respectively.
* The `/onManage` service endpoint can listen to management related changes of a spreadsheet such as creation of a new spreadsheet and deletion of a spreadsheet with the following trigger methods: `onNewSheetCreatedEvent`, `onSheetDeletedEvent`.
* The `/onChange` service endpoint can listen to events triggered for different type of changes such as editing a spreadsheet, inserting a blank row, removing a row, inserting a blank column, removing a column, inserting a new grid (worksheet), removing a new grid (worksheet) from a spreadsheet that capture change event types `EDIT`, `INSERT_ROW`, `REMOVE_ROW`, `INSERT_COLUMN`, `REMOVE_COLUMN`, `INSERT_GRID`, `REMOVE_GRID`, `OTHER` etc.
* The `/onEdit` service endpoint, can listen to events triggered when a spreadsheet is edited that capture edit event types `APPEND_ROW`, `UPDATE_ROW`. We can get more information about the edit event such as the `spreadsheet ID, spreadsheet name, worksheet ID, worksheet name, range updated, starting row position, end row position, starting column position, end column position, new values, last row with content, last column with content` etc.
```ballerina
service / on gSheetListener {
    resource function post [string eventType] (http:Caller caller, http:Request request) returns error? {
        if (eventType == sheetsListener:ON_EDIT) {  
            sheetsListener:EventInfo eventInfo = check gSheetListener.getOnEditEventType(caller, request);
            if (eventInfo?.eventType == sheetsListener:APPEND_ROW && eventInfo?.editEventInfo != ()) {
                log:print(eventInfo?.editEventInfo.toString());
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:UPDATE_ROW && eventInfo?.editEventInfo != ()) {
                log:print(eventInfo?.editEventInfo.toString());
                // Write your logic here.....
            }
        } else if (eventType == sheetsListener:ON_CHANGE) {
            EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
            if (eventInfo?.eventType == sheetsListener:EDIT) {
                log:print("Received Worksheet Edit Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:INSERT_ROW) {
                log:print("Received Worksheet Insert Row Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:REMOVE_ROW) {
                log:print("Received Worksheet Delete Row Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:INSERT_COLUMN) {
                log:print("Received Worksheet Insert Column Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:REMOVE_COLUMN) {
                log:print("Received Worksheet Delete Column Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:INSERT_GRID) {
                log:print("Received Insert Grid Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:REMOVE_GRID) {
                log:print("Received Delete Grid Event");
                // Write your logic here.....
            } else if (eventInfo?.eventType == sheetsListener:OTHER) {
                log:print("Received Other Event");
                // Write your logic here.....
            } 
        } else if (eventType == ON_MANAGE) {
            check gSheetListener.findEventType(caller, request); 
        }
    }
}
```
Add the trigger implementation logic under each section based on the event type you want to listen to using the Google sheets Listener.


# Samples

## On Manage Trigger Endpoint

### Trigger On New Spreadsheet Created
Triggers when a new spreadsheet is created.

```ballerina
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
```

### Trigger On Spreadsheet Deleted
Triggers when a spreadsheet is deleted.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

    public isolated function onSheetDeletedEvent(string fileId) {
        log:print("This File was removed to the trash : " + fileId);
        // Write your logic here.....
    }

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
```

## On Edit Trigger Endpoint

### Trigger On Edit 
Triggers when a spreadsheet is edited.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onEdit (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnEditEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:APPEND_ROW && eventInfo?.editEventInfo != ()) {
            log:print(eventInfo?.editEventInfo.toString());
            // Write your logic here.....
        } else if (eventInfo?.eventType == sheetsListener:UPDATE_ROW && eventInfo?.editEventInfo != ()) {
            log:print(eventInfo?.editEventInfo.toString());
            // Write your logic here.....
        }
    }
}
```

### Trigger On Append Row
Triggers when a new row is appended to a spreadsheet.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onEdit (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnEditEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:APPEND_ROW && eventInfo?.editEventInfo != ()) {
            log:print(eventInfo?.editEventInfo.toString());
            // Write your logic here.....
        }
    }
}
```

### Trigger On Update Row
Triggers when a row is updated in a spreadsheet.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onEdit (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnEditEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:UPDATE_ROW && eventInfo?.editEventInfo != ()) {
            log:print(eventInfo?.editEventInfo.toString());
            // Write your logic here.....
        }
    }
}
```


## On Change Trigger Endpoint

### Trigger On Insert Blank Row 
Triggers when a blank new row is added.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:INSERT_ROW) {
            log:print("Received Worksheet Insert Row Event");
            // Write your logic here.....
        }
    }
}
```

### Trigger On Delete Row 
Triggers when a row is deleted.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:REMOVE_ROW) {
            log:print("Received Worksheet Delete Row Event");
            // Write your logic here.....
        }
    }
}
```

### Trigger On Insert Blank Column 
Triggers when a blank new column is added.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:INSERT_COLUMN) {
            log:print("Received Worksheet Insert Column Event");
            // Write your logic here.....
        }
    }
}
```

### Trigger On Delete Column 
Triggers when a column is deleted.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:REMOVE_COLUMN) {
            log:print("Received Worksheet Delete Column Event");
            // Write your logic here.....
        }
    }
}
```

### Trigger On Insert Grid 
Triggers when a new grid is added.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:INSERT_GRID) {
            log:print("Received Worksheet Insert Grid Event");
            // Write your logic here.....
        }
    }
}
```

### Trigger On Delete Grid 
Triggers when a grid is deleted.

```ballerina
import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_drive as drive;
import ballerinax/googleapis_sheets.'listener as sheetsListener;

# Event Trigger class
public class EventTrigger {
    public isolated function onNewSheetCreatedEvent(string fileId) {}

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
    resource function post onChange (http:Caller caller, http:Request request) returns error? {
        sheetsListener:EventInfo eventInfo = check gSheetListener.getOnChangeEventType(caller, request);
        if (eventInfo?.eventType == sheetsListener:REMOVE_GRID) {
            log:print("Received Worksheet Delete Grid Event");
            // Write your logic here.....
        }
    }
}
```

More Samples are available at "https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/samples".
