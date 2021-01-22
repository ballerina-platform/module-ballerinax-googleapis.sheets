## Compatibility

| Ballerina Language Version  | Google Spreadsheet API Version |
| ----------------------------| -------------------------------|
|    Swan Lake Preview9       |   V4                           |

### Prerequisites

1. Create a project and create an app for this project by visiting [Google Spreadsheet](https://console.developers.google.com/)
2. Obtain the following parameters
    * Client Id
    * Client Secret
    * Redirect URI
    * Access Token
    * Refresh Token

    **IMPORTANT** This access token and refresh token can be used to make API requests on your own
    account's behalf. Do not share your access token, client  secret with anyone.

Visit [here](https://developers.google.com/identity/protocols/OAuth2WebServer) for more information on obtaining OAuth2 credentials.

## Running Samples
You can use the `tests.bal` file to test all the connector actions by following the below steps:
1. Create `Conf.toml` file in module-googlespreadsheet.
2. Obtain the client Id, client secret, and refresh token as mentioned above and add those values in the `Conf.toml` file.
    ```toml
    [googleapis_sheets]
    clientId="your_client_id"
    clientSecret="your_client_secret"
    refreshToken="your_refresh_token"
    ```
3. Navigate to the folder `module-googlespreadsheet`.
4. Run the following commands to execute the tests.
    ```
    bal test
    ```
