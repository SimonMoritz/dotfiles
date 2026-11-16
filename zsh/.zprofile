# ~/.zprofile — login shells. Ghostty (and Terminal.app) on macOS start login
# shells, so this runs once per window/tab, after macOS's path_helper.

# Homebrew (Apple Silicon first, Intel fallback)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

typeset -U path fpath  # keep entries unique
path=(
  "$HOME/.local/bin"                                          # uv tools, personal scripts
  "$HOME/.cargo/bin"                                          # cargo install …
  ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/opt/rustup/bin"}       # rustup is keg-only in Homebrew
  $path
)
export PATH
