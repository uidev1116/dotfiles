#!/usr/bin/env zsh
# 注: runcoms のグロブ `z(^shrc)` と `${rcfile:t}` は zsh 専用記法のため zsh で実行する。
set -eu

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  ln -sf "$1" "$2" && echo "✓ Linked: $2"
}

# ディレクトリをシンボリックリンクで置き換える（既存ディレクトリは削除してからリンク）
link_dir() {
  if [ -d "$2" ] && [ ! -L "$2" ]; then
    rm -rf "$2"
  fi
  ln -sf "$1" "$2" && echo "✓ Linked: $2"
}

echo "=== dotfiles install ==="

# submoduleの初期化
git -C "$DOTFILES" submodule update --init --recursive

# zprezto
link "$DOTFILES/zprezto" "$HOME/.zprezto"

# zpreztoのruncoms（zshrc以外）をリンク（zshrc は zshrc.common を使うため除外）
setopt EXTENDED_GLOB
for rcfile in "$DOTFILES/zprezto/runcoms"/z*~*zshrc(.N); do
  link "$rcfile" "$HOME/.${rcfile:t}"
done

# zshrc（共通設定）
link "$DOTFILES/zshrc.common" "$HOME/.zshrc"

# gitconfig
link "$DOTFILES/gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES/gitignore.global" "$HOME/.gitignore.global"

# claude
mkdir -p "$HOME/.claude"
link "$DOTFILES/claude/CLAUDE.md"             "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/claude/settings.json"         "$HOME/.claude/settings.json"
link "$DOTFILES/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# npmrc
link "$DOTFILES/npmrc" "$HOME/.npmrc"

# pnpm
mkdir -p "$HOME/Library/Preferences/pnpm"
link "$DOTFILES/pnpm/rc" "$HOME/Library/Preferences/pnpm/rc"

# agents/skills（スキルの実体）
mkdir -p "$HOME/.agents"
link_dir "$DOTFILES/agents/skills" "$HOME/.agents/skills"

# ~/.cursor/skills → ~/.agents/skills
mkdir -p "$HOME/.cursor"
link_dir "$HOME/.agents/skills" "$HOME/.cursor/skills"

# ~/.claude/skills → ~/.agents/skills
link_dir "$HOME/.agents/skills" "$HOME/.claude/skills"

# 個人/会社PCのローカル設定（第1引数で profile を指定: personal | work）
# 指定するとシンボリックリンクで ~/.gitconfig.local / ~/.zshrc.local を張る。
PROFILE="${1:-}"
case "$PROFILE" in
  personal | work)
    link "$DOTFILES/local/gitconfig.local.$PROFILE" "$HOME/.gitconfig.local"
    link "$DOTFILES/local/zshrc.local.$PROFILE"     "$HOME/.zshrc.local"
    ;;
  "")
    echo ""
    echo "（profile 未指定: ローカル設定はスキップしました）"
    echo "  自動リンクするには: zsh install.sh personal  または  zsh install.sh work"
    ;;
  *)
    echo "未知の profile: '$PROFILE'（personal または work を指定してください）" >&2
    exit 1
    ;;
esac

echo ""
echo "=== 完了 ==="
