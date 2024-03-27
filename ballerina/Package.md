## Package overview

The [Google Sheets](https://developers.google.com/sheets/api), developed by Google LLC, allows users to programmatically interact with Google Sheets, facilitating tasks such as data manipulation, analysis, and automation.

The `ballerinax/googleapis.gsheets` package offers APIs to connect and interact with [Sheets API](https://developers.google.com/sheets/api/guides) endpoints, specifically based on [Google Sheets API v4](https://developers.google.com/sheets/api).

## Setup guide

To use the Google Sheets connector, you must have access to the Google Sheets API through a [Google Cloud Platform (GCP)](https://console.cloud.google.com/) account and a project under it. If you do not have a GCP account, you can sign up for one [here](https://cloud.google.com/).

### Step 1: Create a Google Cloud Platform project

1. Open the [Google Cloud Platform Console](https://console.cloud.google.com/).

2. Click on **Select a project** in the drop-down menu and either select an existing project or create a new one.

   ![Enable Google Sheets API](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/gcp-console-project-view.png)

### Step 2: Enabling Google Sheets API

1. Select the created project.

2. Navigate to **APIs & Services** > **Library**.

3. Search and select `Google Sheets API`. Then click **ENABLE**.

    ![Enable Sheets Api](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/enable-sheets-api.png)

### Step 3: Creating an OAuth consent app

1. Click on the **OAuth Consent Screen** in the sidebar.

2. Select `External` and click **CREATE**.

3. Fill in the app information and add the necessary scopes for Google Sheets API.

    ![OAuth Consent Screen](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/oauth-consent.png)

### Step 4: Generating client ID & client secret

1. In the left sidebar, click on **Credentials**.

2. Click on **+ CREATE CREDENTIALS** and choose **OAuth Client ID**.

    ![Create Credentials](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/create-credentials.png)

3. You will be directed to the OAuth consent screen, in which you need to fill in the necessary information below.

    | Field                    | Value           |
    | -----------              | -----------     |
    | Application type         | Web Application |
    | Name                     | Sheets Client   |
    | Authorized Redirect URIs | <https://developers.google.com/oauthplayground> |

    ![Create Client](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/create-client.png)

### Step 5: Obtain the access and refresh tokens

Follow these steps to generate the access and refresh tokens.

**Note**: It is recommended to use the [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to acquire the tokens.

1. Configure the [OAuth playground](https://developers.google.com/oauthplayground) with the OAuth client ID and client secret.

    ![OAuth Playground](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/oauth-playground-config.png)

2. Authorize the Google Sheets APIs.

    ![Authorize APIs](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/auhtorize-apis.png)

3. Exchange the authorization code for tokens.

    ![Exchange Tokens](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.sheets/master/docs/setup/resources/exchange-tokens.png)

## Quickstart

To use the Google Sheets connector in your Ballerina project, modify the `.bal` file as follows:

### Step 1: Import connector

Import the `ballerinax/googleapis.gsheets` module.

```ballerina
import ballerinax/googleapis.gsheets;
```

### Step 2: Create a new connector instance

Create a `gsheets:ConnectionConfig` with the obtained OAuth2.0 tokens and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;

gsheets:Client spreadsheetClient = check new ({
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
    gsheets:Spreadsheet response = check spreadsheetClient->createSpreadsheet("NewSpreadsheet");

    // Add a new worksheet with given name to the Spreadsheet
    string spreadsheetId = response.spreadsheetId;
    gsheets:Sheet sheet = check spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Google Sheets` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/examples), covering use cases like creating, reading, and appending rows.

1. [Cell operations](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/examples/cell-operations) - Operations associated with a cell, such as clearing, setting, and deleting cell values.

2. [Grid filtering](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/examples/grid-filtering) - Demonstrate filtering sheet values using a grid range.

3. [Sheet modifying](https://github.com/ballerina-platform/module-ballerinax-googleapis.sheets/tree/master/examples/sheet-modifying) - Basic operations associated with sheets such as creating, reading, and appending rows.

## Report issues

To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina library parent repository](https://github.com/ballerina-platform/ballerina-library).

## Useful links

- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
