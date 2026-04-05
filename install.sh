#!/bin/bash
set -eu

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  ln -sf "$1" "$2" && echo "✓ Linked: $2"
}

echo "=== dotfiles install ==="

# gitconfig
link "$DOTFILES/gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES/gitignore_global" "$HOME/.gitignore_global"

# claude
mkdir -p "$HOME/.claude"
link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# zshrc (zprezto経由で読み込む)
link "$DOTFILES/zshrc.common" "$HOME/.zprezto/runcoms/zshrc"

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
