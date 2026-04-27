# Prerequisites for Running Tests

Before running the tests, ensure you have a Google account with access to Google Sheets and the necessary OAuth2 credentials. You can set up these credentials either in a `Config.toml` file within the tests directory or as environment variables.

## Using a Config.toml File

Create a `Config.toml` file in the tests directory and include your authentication credentials:

```toml
mockClientId = "<your-client-id>"
mockClientSecret = "<your-client-secret>"
mockRefreshToken = "<your-refresh-token>"
mockRefreshUrl = "https://oauth2.googleapis.com/token"
```

## Using Environment Variables

To run tests against the live Google Sheets API, set the following environment variables and enable live server testing:

```bash
export REFRESH_TOKEN="<your-refresh-token>"
export CLIENT_ID="<your-client-id>"
export CLIENT_SECRET="<your-client-secret>"
export IS_TEST_ON_LIVE_SERVER="true"
```

## Running the Tests

```bash
bal test
```

Setting `IS_TEST_ON_LIVE_SERVER=true` runs the full suite against the real Google Sheets API. Without it, the tests run against the local mock service.
