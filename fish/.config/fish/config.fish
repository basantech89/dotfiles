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
  xclip -sel c < $argv
end

function copypath
  pwd | xclip -sel c
end

