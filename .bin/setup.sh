#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTDIR="$(dirname "$SCRIPT_DIR")"

# 色付きメッセージ
info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[OK]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# OS検出
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}

# Linuxディストリビューション検出
detect_linux_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# コマンドが存在するかチェック
has() {
  command -v "$1" &>/dev/null
}

# =============================================================================
# macOS: Homebrew
# =============================================================================
install_homebrew() {
  if has brew; then
    success "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # PATHに追加（Apple Silicon対応）
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
}

install_macos_packages() {
  info "Installing packages via Homebrew..."

  local packages=(
    # Shell & Terminal
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    wezterm

    # Git tools
    git
    git-lfs
    git-delta
    lazygit

    # CLI tools
    fzf
    zoxide
    direnv
    mise
    carapace

    # Editor
    helix
    neovim

  )

  local casks=(
    karabiner-elements
  )

  for pkg in "${packages[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      success "$pkg already installed"
    else
      info "Installing $pkg..."
      brew install "$pkg" || warn "Failed to install $pkg"
    fi
  done

  for cask in "${casks[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      success "$cask already installed"
    else
      info "Installing $cask..."
      brew install --cask "$cask" || warn "Failed to install $cask"
    fi
  done

  # Tap packages
  if ! brew list cesarferreira/tap/rip &>/dev/null; then
    info "Installing rip (process killer)..."
    brew tap cesarferreira/tap
    brew install rip
  else
    success "rip already installed"
  fi

  success "macOS packages installation completed"
}

# =============================================================================
# Linux: apt/dnf/pacman
# =============================================================================
install_linux_packages() {
  local distro
  distro=$(detect_linux_distro)

  info "Detected Linux distribution: $distro"

  case "$distro" in
    ubuntu|debian)
      install_linux_apt
      ;;
    fedora)
      install_linux_dnf
      ;;
    arch|manjaro)
      install_linux_pacman
      ;;
    *)
      warn "Unsupported distribution: $distro"
      warn "Please install packages manually"
      return 1
      ;;
  esac
}

install_linux_apt() {
  info "Installing packages via apt..."
  sudo apt update

  local packages=(
    zsh
    git
    git-lfs
    fzf
    direnv
    curl
    unzip
  )

  for pkg in "${packages[@]}"; do
    if dpkg -l "$pkg" &>/dev/null; then
      success "$pkg already installed"
    else
      info "Installing $pkg..."
      sudo apt install -y "$pkg" || warn "Failed to install $pkg"
    fi
  done

  # apt以外で入れる必要があるツール
  install_linux_extra_tools
}

install_linux_dnf() {
  info "Installing packages via dnf..."

  local packages=(
    zsh
    git
    git-lfs
    fzf
    direnv
    curl
    unzip
  )

  for pkg in "${packages[@]}"; do
    if rpm -q "$pkg" &>/dev/null; then
      success "$pkg already installed"
    else
      info "Installing $pkg..."
      sudo dnf install -y "$pkg" || warn "Failed to install $pkg"
    fi
  done

  install_linux_extra_tools
}

install_linux_pacman() {
  info "Installing packages via pacman..."

  local packages=(
    zsh
    git
    git-lfs
    fzf
    zoxide
    direnv
    starship
    helix
    lazygit
    git-delta
    neovim
    curl
    unzip
  )

  for pkg in "${packages[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      success "$pkg already installed"
    else
      info "Installing $pkg..."
      sudo pacman -S --noconfirm "$pkg" || warn "Failed to install $pkg"
    fi
  done

  install_linux_extra_tools
}

# aptやdnfでは入らないツールを別途インストール
install_linux_extra_tools() {
  # starship
  if ! has starship; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  else
    success "starship already installed"
  fi

  # zoxide
  if ! has zoxide; then
    info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    success "zoxide already installed"
  fi

  # mise
  if ! has mise; then
    info "Installing mise..."
    curl https://mise.run | sh
    # PATHに追加（現在のセッションで使えるように）
    export PATH="$HOME/.local/bin:$PATH"
  else
    success "mise already installed"
  fi

  # helix
  if ! has hx; then
    info "Installing helix..."
    # Helix公式のインストール方法
    if has snap; then
      sudo snap install helix --classic || warn "Failed to install helix via snap"
    else
      warn "Please install helix manually: https://helix-editor.com"
    fi
  else
    success "helix already installed"
  fi

  # lazygit
  if ! has lazygit; then
    info "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit lazygit.tar.gz
  else
    success "lazygit already installed"
  fi

  # delta
  if ! has delta; then
    info "Installing delta..."
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb" 2>/dev/null && \
      sudo dpkg -i delta.deb && rm -f delta.deb || \
      warn "Failed to install delta, please install manually"
  else
    success "delta already installed"
  fi

  # carapace
  if ! has carapace; then
    info "Installing carapace..."
    CARAPACE_VERSION=$(curl -s "https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo carapace.tar.gz "https://github.com/carapace-sh/carapace-bin/releases/latest/download/carapace-bin_linux_amd64.tar.gz"
    tar xf carapace.tar.gz
    sudo install carapace /usr/local/bin
    rm -f carapace carapace.tar.gz
  else
    success "carapace already installed"
  fi

  # neovim
  if ! has nvim; then
    info "Installing neovim..."
    NVIM_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo nvim-linux64.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
    rm -f nvim-linux64.tar.gz
  else
    success "neovim already installed"
  fi

  # zsh plugins (manual for non-Arch)
  install_zsh_plugins

  success "Linux extra tools installation completed"
}

install_zsh_plugins() {
  local zsh_plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
  mkdir -p "$zsh_plugin_dir"

  # zsh-autosuggestions
  if [[ ! -d "$zsh_plugin_dir/zsh-autosuggestions" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_plugin_dir/zsh-autosuggestions"
  else
    success "zsh-autosuggestions already installed"
  fi

  # zsh-syntax-highlighting
  if [[ ! -d "$zsh_plugin_dir/zsh-syntax-highlighting" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_plugin_dir/zsh-syntax-highlighting"
  else
    success "zsh-syntax-highlighting already installed"
  fi
}

# =============================================================================
# Claude Code インストール
# =============================================================================
install_claude_code() {
  # Claude Code が既にインストールされているか確認
  if has claude; then
    success "Claude Code already installed"
    return
  fi

  # mise のパスを確保
  export PATH="$HOME/.local/bin:$PATH"

  # Node.js が必要
  if ! has node; then
    info "Node.js not found, installing via mise..."
    if has mise; then
      mise use --global node@lts
      eval "$(mise activate bash)"
    else
      warn "mise not found, please install Node.js manually"
      return 1
    fi
  fi

  if ! has npm; then
    warn "npm not found, please install Node.js properly"
    return 1
  fi

  info "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
  success "Claude Code installed"
}

# =============================================================================
# Claude Code 設定
# =============================================================================
link_claude_config() {
  local os="$1"
  local claude_dir="$HOME/.claude"
  local dotfiles_claude="$DOTDIR/.claude"

  if [[ ! -d "$dotfiles_claude" ]]; then
    warn "Claude config not found in dotfiles, skipping..."
    return
  fi

  info "Setting up Claude Code configuration..."

  # ~/.claude ディレクトリ作成
  mkdir -p "$claude_dir"
  mkdir -p "$claude_dir/skills"

  # CLAUDE.md をリンク
  if [[ -f "$dotfiles_claude/CLAUDE.md" ]]; then
    ln -snf "$dotfiles_claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
    success "Linked CLAUDE.md"
  fi

  # skills をリンク
  if [[ -d "$dotfiles_claude/skills" ]]; then
    for skill in "$dotfiles_claude/skills"/*; do
      if [[ -d "$skill" ]]; then
        local skill_name
        skill_name=$(basename "$skill")
        ln -snf "$skill" "$claude_dir/skills/$skill_name"
        success "Linked skill: $skill_name"
      fi
    done
  fi

  # settings.json を OS に応じてリンク
  local settings_file
  case "$os" in
    macos) settings_file="$dotfiles_claude/settings.macos.json" ;;
    linux) settings_file="$dotfiles_claude/settings.linux.json" ;;
  esac

  if [[ -f "$settings_file" ]]; then
    ln -snf "$settings_file" "$claude_dir/settings.json"
    success "Linked settings.json (${os})"
  else
    warn "Settings file not found: $settings_file"
  fi
}

# =============================================================================
# Zshをデフォルトシェルに設定
# =============================================================================
setup_zsh_as_default() {
  local current_shell
  current_shell=$(basename "$SHELL")

  if [[ "$current_shell" == "zsh" ]]; then
    success "zsh is already the default shell"
    return
  fi

  if ! has zsh; then
    warn "zsh is not installed, skipping shell change"
    return
  fi

  local zsh_path
  zsh_path=$(which zsh)

  # /etc/shells に zsh が登録されているか確認
  if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
    info "Adding $zsh_path to /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  info "Changing default shell to zsh..."
  if chsh -s "$zsh_path"; then
    success "Default shell changed to zsh"
    info "Please log out and log back in for the change to take effect"
  else
    warn "Failed to change shell. You can manually run: chsh -s $zsh_path"
  fi
}

# =============================================================================
# メイン処理
# =============================================================================
main() {
  local os
  os=$(detect_os)

  info "Detected OS: $os"
  info "Dotfiles directory: $DOTDIR"
  echo ""

  case "$os" in
    macos)
      install_homebrew
      install_macos_packages
      ;;
    linux)
      install_linux_packages
      ;;
    *)
      error "Unsupported OS: $os"
      exit 1
      ;;
  esac

  echo ""
  info "Running dotfiles linker..."
  bash "$SCRIPT_DIR/install.sh"

  echo ""
  info "Installing Claude Code..."
  install_claude_code

  echo ""
  info "Setting up Claude Code config..."
  link_claude_config "$os"

  echo ""
  info "Setting up zsh as default shell..."
  setup_zsh_as_default

  echo ""
  success "Setup completed!"
  echo ""
  info "Please restart your shell or run: source ~/.zshrc"
}

# ヘルプ表示
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  echo "Usage: $0"
  echo ""
  echo "Installs all required tools and links dotfiles."
  echo "Supports: macOS (Homebrew), Linux (apt/dnf/pacman)"
  exit 0
fi

main
