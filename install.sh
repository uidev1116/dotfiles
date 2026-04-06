#!/bin/bash
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

# zpreztoのruncoms（zshrc以外）をリンク
for rcfile in "$DOTFILES/zprezto/runcoms"/z(^shrc); do
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

echo ""
echo "=== 手動セットアップが必要なファイル ==="
echo ""
echo "以下を参考に各PCで手動作成してください："
echo ""
echo "  個人PCの場合："
echo "    cp $DOTFILES/local/gitconfig.local.personal ~/.gitconfig.local"
echo "    cp $DOTFILES/local/zshrc.local.personal ~/.zshrc.local"
echo ""
echo "  会社PCの場合："
echo "    cp $DOTFILES/local/gitconfig.local.work ~/.gitconfig.local"
echo "    cp $DOTFILES/local/zshrc.local.work ~/.zshrc.local"
echo ""
echo "=== 完了 ==="
