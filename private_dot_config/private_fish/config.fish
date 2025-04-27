if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi "$argv" --cwd-file="$tmp"
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

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
#

zoxide init fish | source

direnv hook fish | source
