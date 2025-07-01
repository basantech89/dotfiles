#!/usr/bin/env bash

aws_checks() {
    if test -z AWS_PROFILE; then
        echo "AWS_PROFILE is not set."
        return 1
    fi

    if test "$AWS_PROFILE" != bp-dev -a "$AWS_PROFILE" != bp-qa -a "$AWS_PROFILE" != bp-prod; then
        echo "AWS_PROFILE is neither bp-dev, bp-qa or bp-prod."
        return 1
    fi

    if [ "$#" -ne 1 ]; then
        echo "Expected 1 arguments, got $#"
        return 1
    fi
}

aws_env_check() {
    env=$1

    if test "$env" != dev -a "$env" != qa -a "$env" != prod; then
        echo "Not allowed to get password for $env environment."
        return 1
    fi

    if test "$env" = dev; then
        PROFILE=bp-dev
    elif test "$env" = qa; then
        PROFILE=bp-qa
    elif test "$env" = prod; then
        PROFILE=bp-prod
    fi
}

dbpass() {
    local given_env=$(test -n "$1" && echo $1 || echo "dev")
    aws_checks "$given_env"
    aws_env_check "$given_env"
    echo "Getting password for environment: $given_env"

    if test $status -ne 0; then
        return 1
    fi

    local secret_name=$(aws secretsmanager list-secrets --profile $PROFILE --output json | jq --arg env "$env" '.SecretList[].Name | select(contains($env)) | select(contains("portal")) | select(contains("Databas"))' | tr -d '"')
    local secret_string=$(aws secretsmanager get-secret-value --secret-id $secret_name --profile $PROFILE | jq -r '.SecretString' | jq '.')
    echo $secret_string | jq '.'
    echo -n $(echo -n $secret_string | jq '.password' | tr -d '"') | pbcopy -sel c
}

ec2ip() {
    local given_env=$(test -n "$1" && echo $1 || echo "dev")
    echo "Getting IP for environment: $given_env"

    aws_checks "$given_env"
    aws_env_check "$given_env"

    if test $status -ne 0; then
        return 1
    fi

    if test "$env" = qa; then
        local instance=qa-rds-ec2
    elif test "$env" = prod; then
        local instance=berry-prod-ec2-rds
    fi

    local ip=$(aws ec2 describe-instances --profile $PROFILE | jq --arg instance "$instance" '.Reservations[].Instances[] | select(.Tags[].Value | contains($instance)) | .NetworkInterfaces[].Association.PublicIp' | tr -d '"')
    echo $ip
    echo -n $ip | pbcopy -sel c
}

ssm() {
    local given_env=$(test -n "$2" && echo $2 || echo "dev")
    aws_checks "$given_env"
    aws_env_check "$given_env"
    echo "Getting SSM parameter "$1" for environment: $given_env"

    if test $status -ne 0; then
        return 1
    fi

    local name=$(aws ssm describe-parameters --profile $PROFILE --parameter-filters "Key=Name,Option=Contains,Values=$1" --query 'Parameters | [0].Name' | tr -d '"')
    echo "Parameter Name: $name"

    local value=$(aws ssm get-parameter --profile $PROFILE --name "$name" --with-decryption --query 'Parameter.Value' | tr -d '"')
    echo $value
    echo -n $value | pbcopy -sel c
}
