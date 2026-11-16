# ~/.zshenv — read by *every* zsh (interactive, login, scripts). Keep it tiny.
# PATH lives in ~/.zprofile: macOS runs /etc/zprofile (path_helper) after this
# file, which would reorder anything set here.

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R -F -i"

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
