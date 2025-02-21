if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

enable_transience

function copyfile
    xclip -sel c <$argv
end

function copypath
    pwd | xclip -sel c
end

function copyfilepath
    set -f file $(pwd)/$(basename $argv[1])
    if test -e "$file"
        echo $file | xclip -sel c
    else
        echo "file $argv[1] not found."
    end
end

function aws_checks
    if test -z AWS_PROFILE
        echo "AWS_PROFILE is not set."
        return 1
    end

    if test "$AWS_PROFILE" != bp-dev -a "$AWS_PROFILE" != bp-qa
        echo "AWS_PROFILE is neither bp-dev or bp-qa."
        return 1
    end

    if test (count $argv) -ne 1
        echo "Expected 1 arguments, got $(count $argv)"
        return 1
    end

    set -g env $argv[1]

    if test "$env" != dev -a "$env" != qa
        echo "Not allowed to get password for $env environment."
        return 1
    end

    if test "$env" = dev
        set -g PROFILE "bp-dev"
    else if test "$env" = qa
        set -g PROFILE "bp-qa"
    end
end

function getpass
    aws_checks "$argv"

    if test $status -ne 0
        return 1
    end

    set -f secret_name $(aws secretsmanager list-secrets --profile $PROFILE --output json | jq --arg env "$env" '.SecretList[].Name | select(contains($env)) | select(contains("portal"))')
    set -f secret_string $(aws secretsmanager get-secret-value --secret-id $(string sub -s 2 -e -1 $secret_name) --profile $PROFILE | jq -r '.SecretString' | jq '.')
    echo $secret_string | jq '.'
    echo $secret_string | jq '.password' | string sub -s 2 -e -1 | xclip -sel c
end

function ec2ip
    aws_checks "$argv"

    if test $status -ne 0
        return 1
    end

    set -f ip $(aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(.Tags[].Value | contains("rds-berrybox-portal-ec2")) | .NetworkInterfaces[].Association.PublicIp' | string sub -s 2 -e -1)
    echo $ip
    echo $ip | xclip -sel c
end

# pnpm
set -gx PNPM_HOME "/home/basant/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
