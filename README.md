# aws-mfa-script
Script to fetch an MFA token for you to use temporary aws access credentials.

Tested on MacOS Catalina, should at least also work on Linux devices. Requires oath-toolkit for auto-gen.

The profile name should be the name of the profile stanza in your
`~/.aws/credentials` file as used by the aws-cli.

The ARN should be the ARN of your MFA device as specified in the AWS console.

The MFA code is the code your MFA device gives you.
If you locally save the code used to generate a virtual MFA device, you can use the built-in TOTP generator. Just set the location and necessary decryption measures in mfa.sh.

Remember, the env variables set by this script will only persist in that individual terminal session, unless the token file is set in profile.
However, the temporary credentials can be found in the set dir within the .token_file, and printed to console. You can always use the following command in a new window:
```bash
source ~/aws-mfa-script-master/.token_file
```

## Installation

 1. Extract the files to your home directory `~/aws-mfa-script-master` (if elsewhere, make sure you change mfa.sh & alias.sh).
 2. Add `source ./alias.sh` to your `~/.bashrc` (If you aren't already calling rc in profile, make sure you add to .bash_profile/.zprofile)
 3. Copy `SAMPLE-mfa.cfg` to `~/aws-mfa-script-master/mfa.cfg`
 4. Add a profile name and MFA ARN for each aws cli profile you wish to use. The key should be the profile name and the value should be the ARN of the MFA to use for that profile.

## Running the script

At a command prompt run the following command. Using 0 as the mfacode will use the auto-TOTP generator.

```bash
mfa <mfacode> <optional-aws-profile> <optional-expiration-seconds>
mfa 123789 default 43200
mfa 0
```

### Alias Note

Scripts run in a subprocess of the calling shell.  This means that
if you attempt to set the env vars in the script, they will only persist
inside that subprocess.  The `alias.sh` script sets an alias function to source the env vars into your main shell whenever you
run the `mfa` command.
