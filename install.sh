#!/usr/bin/env bash
# Bootstrap a new Mac: Homebrew → packages → symlink dotfiles with stow.
# Safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh ghostty starship git tmux)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }

[[ "$(uname -s)" == Darwin ]] || { echo "This setup targets macOS."; exit 1; }

# 1. Xcode command line tools (git, compilers)
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installing Xcode Command Line Tools — re-run this script when it finishes"
  xcode-select --install
  exit 0
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Packages
info "Installing Brewfile packages"
brew bundle --file="$DOTFILES/Brewfile"
# Homebrew leaves share/zsh group-writable, which makes compinit complain
# about "insecure directories" on every new shell
chmod -R go-w "$(brew --prefix)/share/zsh"

# 4. Move any existing real files out of the way, then symlink
info "Linking dotfiles"
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r rel; do
    rel="${rel#./}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      echo "  backed up ~/$rel → $BACKUP/$rel"
    fi
  done < <(cd "$DOTFILES/$pkg" && find . -type f)
done
stow --no-folding --restow --dir="$DOTFILES" --target="$HOME" "${PACKAGES[@]}"

# 5. Machine-local files (never overwritten)
[[ -f "$HOME/.zshrc.local" ]] || printf '# Machine-specific zsh config (not in git)\n' > "$HOME/.zshrc.local"
[[ -f "$HOME/.gitconfig.local" ]] || printf '# Machine-specific git config (not in git)\n' > "$HOME/.gitconfig.local"

# 6. Rust toolchain + Node LTS
RUSTUP="$(brew --prefix rustup)/bin/rustup"
if [[ -x "$RUSTUP" ]] && ! "$RUSTUP" toolchain list 2>/dev/null | grep -q stable; then
  info "Installing stable Rust"
  "$RUSTUP" default stable
fi
if command -v fnm >/dev/null 2>&1 && [[ -z "$(fnm list 2>/dev/null | grep -v system)" ]]; then
  info "Installing Node LTS"
  fnm install --lts && fnm default lts-latest
fi

info "Done. Open Ghostty (or run: exec zsh)."
[[ -d "$BACKUP" ]] && echo "Old files saved in $BACKUP"
