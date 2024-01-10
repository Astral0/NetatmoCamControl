# NetatmoCamControl
NetatmoCamControl is a simple Bash script to control Netatmo security cameras. This script allows users to enable or disable monitoring of Netatmo cameras and logs actions to a file. It's suitable for standalone use or integration with home automation systems like Home Assistant.

## Configuration

Before using NetatmoCamControl, you need to set up a Netatmo developer account and obtain necessary API credentials. Follow these steps:

1. **Create a Netatmo Developer Account:**
   - Visit [Netatmo Developer](https://dev.netatmo.com) and sign up for an account.

2. **Create an App:**
   - Go to "My Apps", then click the orange "Create" button.
   - Fill in the form with the following details:
     - App Name: Choose a name for your app.
     - Description: Provide a brief description.
     - Data Protection Officer Name and Email: Enter your name and email address.
   - Agree to the terms and conditions and click "Save".

3. **Generate Token:**
   - In the "Token Generator" section of your app, check at least `read_camera`, `write_camera`, and `access_camera`.
   - Click "Generate Token" and accept the authorization request on the following page.

4. **Configure the Script:**
   - Copy the "Client ID", "Client Secret", and "Refresh Token" provided into the Bash script.
   - Replace `"Your_Camera"` at the end of the script with the name of your Netatmo camera.

## Usage

Run the script to control your Netatmo camera.
./netatmo_camera.sh 

The script logs its actions, making it easy to track changes and debug issues.

## Integration with Home Assistant

NetatmoCamControl can be integrated into Home Assistant, allowing for automated control and monitoring of your Netatmo cameras as part of your smart home setup.

## License

NetatmoCamControl is released under the GPL license.

## Disclaimer

This script is not officially associated with Netatmo and has been developed as an independent project for community use.
