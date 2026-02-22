# dotfiles

個人の開発環境設定ファイル。macOS / Linux / WSL に対応。

## セットアップ

### 新しいマシン（初回）

パッケージのインストールからシンボリックリンクの作成まで全部やる。

```bash
git clone https://github.com/onikukiraii/dotfiles.git ~/dotfiles
~/dotfiles/.bin/setup.sh
```

### dotfiles の再リンクだけ

設定ファイルを追加・変更した後、リンクだけ貼り直したいとき。

```bash
~/dotfiles/.bin/install.sh
```

事前に何が起きるか確認したい場合:

```bash
~/dotfiles/.bin/install.sh --dry-run
```

## 構成

```
~/dotfiles/
├── .bin/
│   ├── setup.sh          # フルセットアップ（パッケージ + リンク + シェル設定）
│   └── install.sh        # シンボリックリンクの作成のみ
├── .config/
│   ├── git/              # git ignore
│   ├── helix/            # Helix エディタ
│   ├── karabiner/        # Karabiner-Elements（macOS キーリマップ）
│   ├── lazygit/          # LazyGit
│   ├── nvim/             # Neovim（Lua, lazy.nvim）
│   ├── wezterm/          # WezTerm ターミナル
│   └── starship.toml     # Starship プロンプト
├── .claude/
│   ├── CLAUDE.md         # Claude Code グローバル指示
│   ├── settings.macos.json
│   ├── settings.linux.json
│   └── skills/           # カスタムスキル
├── .gitconfig            # Git 設定（delta, LFS）
└── .zshrc                # Zsh 設定
```

## install.sh の動作

- `~/dotfiles/` 直下のドットファイル（`.zshrc`, `.gitconfig` 等）を `~/` にシンボリックリンク
- `~/dotfiles/.config/*` を `~/.config/` に個別リンク
- 既存ファイルは `~/.dotbackup/` に退避

## setup.sh の動作

1. **パッケージインストール** — OS を検出して適切なパッケージマネージャを使用
   - macOS: Homebrew
   - Linux: apt / dnf / pacman
2. **dotfiles リンク** — `install.sh` を内部で実行
3. **Claude Code** — Node.js + Claude Code のインストール、設定リンク
4. **シェル設定** — zsh をデフォルトシェルに変更
5. **WSL** — Windows 側への設定リンク（WSL 環境のみ）

### インストールされるツール

#### シェル・ターミナル

| ツール | 説明 |
|---|---|
| [zsh](https://www.zsh.org/) | メインシェル。bash 互換で補完・拡張が強力 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | コマンド履歴からの入力補完をリアルタイム表示 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | コマンド入力時のシンタックスハイライト |
| [starship](https://starship.rs/) | Rust 製のカスタマイズ可能なプロンプト。Git ブランチ・言語バージョン等を表示 |
| [WezTerm](https://wezfurlong.org/wezterm/) | GPU アクセラレーション対応ターミナル。Lua で設定、壁紙・タブ・ペイン分割に対応 |

#### Git

| ツール | 説明 |
|---|---|
| [git](https://git-scm.com/) | バージョン管理 |
| [git-lfs](https://git-lfs.com/) | 大容量ファイルの Git 管理 |
| [delta](https://github.com/dandavison/delta) | Git diff をシンタックスハイライト付きで表示。side-by-side 表示対応 |
| [lazygit](https://github.com/jesseduffield/lazygit) | ターミナル上の Git GUI クライアント |

#### CLI ツール

| ツール | 説明 |
|---|---|
| [fzf](https://github.com/junegunn/fzf) | ファジーファインダー。ファイル検索・コマンド履歴検索等に使用 |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | スマート cd。過去に移動したディレクトリを学習して素早くジャンプ |
| [direnv](https://direnv.net/) | ディレクトリごとの環境変数を `.envrc` で自動管理 |
| [mise](https://mise.jdx.dev/) | 言語ランタイムのバージョン管理（Node.js, Python 等） |
| [carapace](https://carapace.sh/) | 複数シェル対応のコマンド補完エンジン |

#### エディタ

| ツール | 説明 |
|---|---|
| [Neovim](https://neovim.io/) | メインエディタ。Lua ベースの設定、lazy.nvim でプラグイン管理 |
| [Helix](https://helix-editor.com/) | Rust 製モーダルエディタ。LSP 内蔵、設定少なめで使える |

#### macOS 専用

| ツール | 説明 |
|---|---|
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | キーボードのリマッピング |

#### AI

| ツール | 説明 |
|---|---|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Anthropic の CLI エージェント。カスタムスキル・設定も dotfiles で管理 |

## zshrc の主なエイリアス

| エイリアス | コマンド |
|---|---|
| `gs` | `git switch` |
| `gsb` | `git switch -c` |
| `gst` | `git status` |
| `gc` | `git commit` |
| `gp` / `gl` | `git push` / `git pull` |
| `glog` | `git log --oneline --graph` |
| `lg` | `lazygit` |
| `v` / `nv` | `nvim` |
| `gwt <branch>` | git worktree 作成 + 移動 |
| `gwtl` | git worktree list |
| `gwtr` | 現在の worktree を削除 |
