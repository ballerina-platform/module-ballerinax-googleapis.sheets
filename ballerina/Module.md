## Overview

The Ballerina Google Sheets connector makes it convenient to implement some of the most common use cases of Google Sheets. This connector streamlines spreadsheet management by enabling users to programmatically handle spreadsheets, manipulate worksheets, execute CRUD operations on data, and conduct precise operations at the column, row, and cell levels.

The Google Sheets connector supports [Google Sheets API v4](https://developers.google.com/sheets/api).

## Setup guide

To use the Google Sheets connector, you must have access to the Google Sheets API through a Google Cloud Platform (GCP)(https://console.cloud.google.com/) account and a project under it. If you do not have a GCP account, you can sign up for one [here](https://cloud.google.com/).

### Step 1: Create a Google Cloud Platform project

1. Open the [Google Cloud Platform Console](https://console.cloud.google.com/).

2. Click on "Select a project" in the drop-down menu and then "NEW PROJECT" to create a new one. (If you already have a project, select it from existing projects and continue from step 2.)

3. Enter a project name and click on "CREATE".

    ![GCP Console Project View]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/consent-screen.png))

### Step 2: Enabling Google Sheets API

1. Select the created project.

2. Navigate to “APIs & Services” > “Library.”

3. Search and select “Google Sheets API.”

4. Click “ENABLE.”

    ![Enable Google Sheets API]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/enable-sheets-api.png))

### Step 3: Creating an OAuth consent app

1. Click on “OAuth Consent Screen” in the sidebar.

2. Select “External” and click “CREATE.”

3. Fill in the app information and add the necessary scopes for Google Sheets API.

4. Click “SAVE AND CONTINUE” and then “SAVE AND CONTINUE” again.

5. Click “BACK TO DASHBOARD".

    ![OAuth Consent Screen]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/oauth-consent.png))

### Step 4: Generating client ID & client secret

1. In the left sidebar, click on “Credentials.”

2. Click on “+ CREATE CREDENTIALS” and choose “OAuth Client ID.”

    ![Create Credentials]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/create-credentials.png))

3. Specify “Web Application” as the application type.

4. Enter a name, authorized redirect URL, and click “CREATE.”
    | Field                    | Value           |
    | -----------              | -----------     |
    | Application type         | Web Application |
    | Name                     | Sheets Client   |
    | Authorized Redirect URIs | https://developers.google.com/oauthplayground |

    ![Create Client]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/create-client.png))

### Step 5: Obtain the access and refresh tokens

Follow these steps to generate the access and refresh tokens. It is recommended to use the [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to acquire the tokens.

1. Configure the [OAuth playground](https://developers.google.com/oauthplayground) with the OAuth client ID and client secret.

    ![OAuth Playground]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/oauth-playground-config.png))

2. Authorize the Google Sheets APIs.

    ![Authorize APIs]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/auhtorize-apis.png))

3. Exchange the authorization code for tokens.

    ![Exchange Tokens]((https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/main/docs/setup/resources/exchange-tokens.png))

## Quickstart

To use the `Google Sheets` connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import connector

Import the `ballerinax/googleapis.sheets` module.

```ballerina
import ballerinax/googleapis.sheets as sheets;
```

### Step 2: Create a new connector instance

Create a `sheets:ConnectionConfig` with the obtained OAuth2.0 tokens and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

sheets:Client spreadsheetClient = check new ({
    auth: {
        clientId,
        clientSecret,
        refreshToken,
        refreshUrl
    }
});
```

### Step 3: Invoke connector operation

Now, utilize the available connector operations.

### Create a spreadsheet with a given name

```ballerina
public function main() returns error? {

    // create a spreadsheet
    sheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");

    // Add a new worksheet with given name to the Spreadsheet
    string spreadsheetId = response.spreadsheetId;
    sheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Google Sheets` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/main/examples), covering use cases like creating, reading, and appending rows.

1. []()
2. []()
