# dotfiles

macOS setup: zsh + starship + Ghostty, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install on a new Mac

```bash
git clone git@github.com:SimonMoritz/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

The script installs the Xcode CLI tools and Homebrew, runs `brew bundle`, backs up any
existing files to `~/.dotfiles-backup/<timestamp>/`, and symlinks everything into `~`.
Re-running it is safe.

## Layout

Each top-level folder is a stow package mirroring `$HOME`:

| Package    | Files                                             |
| ---------- | ------------------------------------------------- |
| `zsh`      | `.zshenv`, `.zprofile`, `.zshrc`                  |
| `ghostty`  | `.config/ghostty/config.ghostty`                  |
| `starship` | `.config/starship.toml`                           |
| `git`      | `.gitconfig`, `.config/git/ignore`                |
| `tmux`     | `.config/tmux/tmux.conf`                          |

Machine-specific, untracked: `~/.zshrc.local`, `~/.gitconfig.local`.

## Highlights

- **No plugin manager** – plugins come from Homebrew: autosuggestions, syntax highlighting,
  history-substring-search (type a prefix, press ↑), extra completions.
- **Completion** – case-insensitive, arrow-key menu, compdump cached in `~/.cache/zsh`.
- **fzf** – `ctrl-r` history, `ctrl-t` files (bat preview), `⌥c` cd into dir (eza tree preview).
- **zoxide** – `z dotf` jumps to `~/dotfiles`; `zi` to pick interactively.
- **fnm** instead of nvm – much faster startup, auto-switches on `.nvmrc`.
- **Ghostty** – JetBrainsMono Nerd Font, Catppuccin that follows macOS light/dark,
  tabs in the titlebar, `⌘\`` drop-down quick terminal, left ⌥ as Alt.

## Commit signing

Commits and tags are signed with the SSH key `~/.ssh/id_ed25519.pub` (`gpg.format = ssh`).
On a new Mac, copy that key pair over (or make a new one with `ssh-keygen -t ed25519`
and add it on GitHub as a **Signing Key**). `git/.config/git/allowed_signers` lets
`git log --show-signature` verify your own commits locally; add any new public key there.

To use another key (or turn signing off) on one machine, put it in `~/.gitconfig.local`.

## After installing

- Ghostty → System Settings → Privacy & Security → Accessibility, so the global `⌘\`` works.
- Copy over `~/.zsh_history` if you want your old history.
