#!/bin/bash
setToken() {
    ~/aws-mfa-script-master/mfa.sh $1 $2 $3
    source ~/aws-mfa-script-master/.token_file
    echo "Your creds have been set in your env."
}
alias mfa=setToken
