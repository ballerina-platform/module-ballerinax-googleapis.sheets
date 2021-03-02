## Compatibility

| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|    Swan Lake Alpha 2        |   V4                           |

### Prerequisites

1. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/)
2. Obtain the following parameters
    * Client Id
    * Client Secret
    * Redirect URI
    * Refresh Token

    **IMPORTANT** This client id, client secret and refresh token can be used to make API requests on your own
    account's behalf. Do not share your client id, client  secret with anyone.

Visit [here](https://developers.google.com/identity/protocols/OAuth2WebServer) for more information on obtaining OAuth2 credentials.

## Running Samples
You can use the `tests.bal` file to test all the connector actions by following the below steps:
1. Create configration file in module-ballerinax-googleapis.sheets.
2. Obtain the client Id, client secret and refresh token as mentioned above and add those values in the configration file.
#### Config.toml
```ballerina

[ballerinax.googleapis_sheets]
refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
trustStorePath = "enter a truststore path if required"
trustStorePassword = "enter a truststore password if required"

Assign the values for the clientId, clientSecret and refreshToken inside constructed endpoint in 
test.bal

```ballerina

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

Client spreadsheetClient = checkpanic new (spreadsheetConfig);
```

3. Navigate to the folder `module-ballerinax-googleapis.sheets`.
4. Run the following commands to execute the tests.
    ```
    bal test 
    ```
