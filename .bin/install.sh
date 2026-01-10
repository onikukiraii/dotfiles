#!/usr/bin/env bash
set -ue

DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUPDIR="$HOME/.dotbackup"

# 色付きメッセージ
info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[OK]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

helpmsg() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
  echo "  -d, --debug   Enable debug mode"
  echo "  -n, --dry-run Show what would be done without making changes"
}

backup_and_link() {
  local src="$1"
  local dest="$2"

  # 既にリンクが正しく張られていればスキップ
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    success "$dest already linked"
    return
  fi

  # バックアップディレクトリ作成
  if [[ ! -d "$BACKUPDIR" ]]; then
    info "Creating backup directory: $BACKUPDIR"
    $RUN mkdir -p "$BACKUPDIR"
  fi

  # 既存のシンボリックリンクを削除
  if [[ -L "$dest" ]]; then
    info "Removing old symlink: $dest"
    $RUN rm -f "$dest"
  fi

  # 既存のファイル/ディレクトリをバックアップ
  if [[ -e "$dest" ]]; then
    info "Backing up: $dest -> $BACKUPDIR/"
    $RUN mv "$dest" "$BACKUPDIR/"
  fi

  # シンボリックリンク作成
  info "Linking: $src -> $dest"
  $RUN ln -snf "$src" "$dest"
  success "Linked $dest"
}

link_dotfiles() {
  info "Starting dotfiles installation..."
  info "Source: $DOTDIR"

  # ~/.config ディレクトリがなければ作成
  if [[ ! -d "$HOME/.config" ]]; then
    info "Creating ~/.config directory"
    $RUN mkdir -p "$HOME/.config"
  fi

  # ホームディレクトリ直下のドットファイル (.zshrc など)
  for f in "$DOTDIR"/.[!.]*; do
    name="$(basename "$f")"
    # .git, .config, .bin は除外
    [[ "$name" == ".git" ]] && continue
    [[ "$name" == ".config" ]] && continue
    [[ "$name" == ".bin" ]] && continue

    backup_and_link "$f" "$HOME/$name"
  done

  # .config 以下は個別にリンク
  if [[ -d "$DOTDIR/.config" ]]; then
    for f in "$DOTDIR/.config"/*; do
      name="$(basename "$f")"
      backup_and_link "$f" "$HOME/.config/$name"
    done
  fi
}

# オプション解析
RUN=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --debug|-d)
      set -x
      ;;
    --help|-h)
      helpmsg
      exit 0
      ;;
    --dry-run|-n)
      RUN="echo [DRY-RUN]"
      warn "Dry-run mode enabled"
      ;;
    *)
      warn "Unknown option: $1"
      helpmsg
      exit 1
      ;;
  esac
  shift
done

link_dotfiles

echo ""
success "Install completed!"
echo ""
info "Backup location: $BACKUPDIR"
