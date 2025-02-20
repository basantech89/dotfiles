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

function getpass
    if test -z "AWS_PROFILE"
        echo "AWS_PROFILE is not set."
        return 1
    end

    if test "$AWS_PROFILE" != "bp-dev"
        echo "AWS_PROFILE is not set to bp-dev."
        return 1
    end

    if test (count $argv) -ne 1
        echo "Expected 1 arguments, got $(count $argv)"
        return 1
    end 

    set -f env $argv[1]

    if test "$env" != "dev"
        echo "Not allowed to get password for $env environment."
        return 1
    end

    if test $proceed -ne 1
        return 1
    end

    set -f secret_name $(aws secretsmanager list-secrets --profile $AWS_PROFILE --output json | jq --arg env "$env" '.SecretList[].Name | select(contains($env)) | select(contains("portal"))')
    set -f secret_string $(aws secretsmanager get-secret-value --secret-id $(string sub -s 2 -e -1 $secret_name) --profile $AWS_PROFILE | jq -r '.SecretString' | jq '.')
    echo $secret_string | jq '.'
    echo $secret_string | jq '.password' | string sub -s 2 -e -1 | xclip -sel c
end

# pnpm
set -gx PNPM_HOME "/home/basant/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
