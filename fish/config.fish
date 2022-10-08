if status is-interactive
    # Commands to run in interactive sessions can go here
end

set SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
export SSH_AUTH_SOCK

alias vim="nvim"
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
