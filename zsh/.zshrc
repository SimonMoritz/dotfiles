# ~/.zshrc — interactive shell (macOS + Homebrew + Ghostty)
# Machine-specific stuff goes in ~/.zshrc.local (not tracked).

# Fallback for non-login shells that didn't inherit the brew env
: ${HOMEBREW_PREFIX:=/opt/homebrew}

# ---------------------------------------------------------------------------
# Options
# ---------------------------------------------------------------------------
setopt AUTO_CD              # `foo/` == `cd foo/`
setopt AUTO_PUSHD           # cd pushes onto the dir stack (`cd -<TAB>`)
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt INTERACTIVE_COMMENTS # allow `# comments` at the prompt
setopt NO_BEEP

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY       # save timestamps
setopt SHARE_HISTORY          # share across sessions (implies incremental append)
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE      # ` secret-command` is not saved
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # `!!` expands first instead of running blindly

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
fpath=(
  "$HOMEBREW_PREFIX/share/zsh-completions"
  "$HOMEBREW_PREFIX/share/zsh/site-functions"
  $fpath
)

autoload -Uz compinit
() {
  setopt local_options extended_glob
  local dump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
  mkdir -p "${dump:h}"
  # Full (slow) security check at most once a day, cached otherwise
  if [[ ! -s $dump || -n $dump(#qN.mh+24) ]]; then
    compinit -d "$dump"
  else
    compinit -C -d "$dump"
  fi
}

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{magenta}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
bindkey -M menuselect '^[[Z' reverse-menu-complete   # shift-tab

# ---------------------------------------------------------------------------
# Key bindings (emacs mode)
# Ghostty on macOS already maps ⌘← / ⌘→ to line start/end and ⌥← / ⌥→ to words.
# ---------------------------------------------------------------------------
bindkey -e
bindkey '^[[1;5C' forward-word        # ctrl →
bindkey '^[[1;5D' backward-word       # ctrl ←
bindkey '^[[1;3C' forward-word        # option →
bindkey '^[[1;3D' backward-word       # option ←
bindkey '^[[H'    beginning-of-line   # home
bindkey '^[[F'    end-of-line         # end
bindkey '^[[3~'   delete-char         # fn-delete

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line      # open current command in $EDITOR

# ---------------------------------------------------------------------------
# Plugins (installed via Homebrew)
# ---------------------------------------------------------------------------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
ZSH_AUTOSUGGEST_MANUAL_REBIND=1   # faster prompts; we don't rebind widgets later

_plug() { [[ -r $1 ]] && source "$1" }
_plug "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
_plug "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# must come after syntax-highlighting
_plug "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
unfunction _plug

# ↑ / ↓ search history for what's already typed
if (( $+functions[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
fi

# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------
export GPG_TTY=$TTY

# fzf: ctrl-r history, ctrl-t files, option-c cd
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border=rounded --info=inline'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}'"
  source <(fzf --zsh)
fi

# zoxide: `z proj` jumps to the best match, `zi` picks with fzf
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# fnm: fast nvm replacement, auto-switches on .nvmrc / .node-version
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lah --group-directories-first --icons=auto --git'
  alias la='eza -a --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never'   # plain output when piped
(( $+commands[nvim] )) && alias vim='nvim' vi='nvim'

alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias reload='exec zsh'
alias path='print -l $path'
alias dots='cd ~/dotfiles'

# git (most used command by far)
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git lg'
alias gp='git push'
alias gpl='git pull'

# macOS
alias copyfile='pbcopy <'        # copyfile foo.txt
alias o='open .'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

mkcd() { mkdir -p -- "$1" && cd -- "$1" }

# ---------------------------------------------------------------------------
# Prompt (last, so nothing above overrides it)
# ---------------------------------------------------------------------------
(( $+commands[starship] )) && eval "$(starship init zsh)"

[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
