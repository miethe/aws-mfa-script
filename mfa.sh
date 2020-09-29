#!/bin/bash
#
# Sample for getting temp session token from AWS STS
#
# aws --profile youriamuser sts get-session-token --duration 3600 \
# --serial-number arn:aws:iam::012345678901:mfa/user --token-code 012345
#

AWS_CLI=`which aws`

if [ $? !=  0 ]; then
  echo "AWS CLI is not installed; exiting"
  exit 1
else
  echo "Using AWS CLI found at $AWS_CLI"
fi

# 1-3 args ok
if [[ $# != 1 && $# != 2 && $# != 3 ]]; then
  echo "Usage: $0 <MFA_TOKEN_CODE> <AWS_CLI_PROFILE> <EXPIRATION>"
  echo "Where:"
  echo "   <MFA_TOKEN_CODE> = Code from virtual MFA device"
  echo "   <AWS_CLI_PROFILE> = aws-cli profile usually in $HOME/.aws/config"
  echo "   <EXPIRATION> = Seconds until token expires"
  exit 2
fi

echo "Reading config..."
if [ ! -r ~/aws-mfa-script-master/mfa.cfg ]; then
  echo "No config found.  Please create your mfa.cfg.  See README.txt for more info."
  exit 2
fi

echo "Unsetting expired temporary credentials..."

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

EXPIRATION=${3:-129600}
EXPIRATION_DATE=$(date -v+${EXPIRATION}S)

# This is currently not correctly validating.
# Validate expiration range per AWS-CLI requirements
#if [[ $EXPIRATION > 129600 ]] || [[ $EXPIRATION < 900 ]]; then
#  echo "Expiration must fall between 15 minutes and 36 hours (900s-129600s)"
#  exit 2
#fi

AWS_CLI_PROFILE=${2:-default}
MFA_TOKEN_CODE=$1
ARN_OF_MFA=$(grep "^$AWS_CLI_PROFILE" ~/aws-mfa-script-master/mfa.cfg | cut -d '=' -f2- | tr -d '"')

echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
echo "MFA ARN: $ARN_OF_MFA"
echo "MFA Token Code: $MFA_TOKEN_CODE"
echo "Token expires on: $EXPIRATION_DATE"

echo "Your Temporary Creds:"
aws --profile $AWS_CLI_PROFILE sts get-session-token --duration $EXPIRATION \
  --serial-number $ARN_OF_MFA --token-code $MFA_TOKEN_CODE --output text \
  | awk '{printf("export AWS_ACCESS_KEY_ID=\"%s\"\nexport AWS_SECRET_ACCESS_KEY=\"%s\"\nexport AWS_SESSION_TOKEN=\"%s\"\nexport AWS_SECURITY_TOKEN=\"%s\"\n",$2,$4,$5,$5)}' | tee ~/aws-mfa-script-master/.token_file
