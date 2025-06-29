function aws_checks
    if test -z AWS_PROFILE
        echo "AWS_PROFILE is not set."
        return 1
    end

    if test "$AWS_PROFILE" != bp-dev -a "$AWS_PROFILE" != bp-qa -a "$AWS_PROFILE" != bp-prod
        echo "AWS_PROFILE is neither bp-dev, bp-qa or bp-prod."
        return 1
    end

    if test (count $argv) -ne 1
        echo "Expected 1 arguments, got $(count $argv)"
        return 1
    end
end

function aws_env_check
    set -g env $argv[1]

    if test "$env" != dev -a "$env" != qa -a "$env" != prod
        echo "Not allowed to get password for $env environment."
        return 1
    end

    if test "$env" = dev
        set -g PROFILE bp-dev
    else if test "$env" = qa
        set -g PROFILE bp-qa
    else if test "$env" = prod
        set -g PROFILE bp-prod
    end
end

function dbpass
    set -f given_env (test -n "$argv[1]" && echo $argv[1] || echo "dev")
    aws_checks "$given_env"
    aws_env_check "$given_env"
    echo "Getting password for environment: $given_env"

    if test $status -ne 0
        return 1
    end

    set -f secret_name $(aws secretsmanager list-secrets --profile $PROFILE --output json | jq --arg env "$env" '.SecretList[].Name | select(contains($env)) | select(contains("portal")) | select(contains("Databas"))')
    set -f secret_string $(aws secretsmanager get-secret-value --secret-id $(string sub -s 2 -e -1 $secret_name) --profile $PROFILE | jq -r '.SecretString' | jq '.')
    echo $secret_string | jq '.'
    echo -n $secret_string | jq '.password' | string sub -s 2 -e -1 | pbcopy -sel c
end

function ec2ip
    set -f given_env (test -n "$argv[1]" && echo $argv[1] || echo "dev")
    echo "Getting IP for environment: $given_env"

    aws_checks "$given_env"
    aws_env_check "$given_env"

    if test $status -ne 0
        return 1
    end

    set -f instance rds-berrybox-portal-ec2
    if test "$env" = qa
        set -f instance qa-rds-ec2
    else if test "$env" = prod
        set -f instance berry-prod-ec2-rds
    end

    set -f ip $(aws ec2 describe-instances --profile $PROFILE | jq --arg instance "$instance" '.Reservations[].Instances[] | select(.Tags[].Value | contains($instance)) | .NetworkInterfaces[].Association.PublicIp' | string sub -s 2 -e -1)
    echo $ip
    echo -n $ip | pbcopy -sel c
end

function ssm
    set -f given_env (test -n "$argv[2]" && echo $argv[2] || echo "dev")
    aws_checks "$given_env"
    aws_env_check "$given_env"
    echo "Getting SSM parameter "$argv[1]" for environment: $given_env"

    if test $status -ne 0
        return 1
    end

    set -f name $(aws ssm describe-parameters --profile $PROFILE --parameter-filters "Key=Name,Option=Contains,Values=$argv[1]" --query 'Parameters | [0].Name' | string sub -s 2 -e -1)
    set -f value $(aws ssm get-parameter --profile $PROFILE --name "$name" --with-decryption --query 'Parameter.Value' | string sub -s 2 -e -1)
    echo $value
    echo -n $value | pbcopy -sel c
end
