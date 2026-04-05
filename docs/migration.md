# 既存環境からの移行手順

初回セットアップ時に既存ファイルと競合するため、事前に退避が必要。

## 1. 競合ファイルの退避

```bash
# ~/.zprezto（git repoとして存在 → dotfiles/zpreztoへのリンクに置き換える）
mv ~/.zprezto ~/.zprezto.bak

# ~/.zshrc（現在 ~/.zprezto/runcoms/zshrc へのリンク → dotfiles/zshrc.commonに変わる）
rm ~/.zshrc

# ~/.gitconfig（実体ファイル → dotfiles/gitconfigへのリンクに置き換える）
mv ~/.gitconfig ~/.gitconfig.bak

# ~/.claude 配下（実体ファイル → dotfiles/claude/ へのリンクに置き換える）
rm ~/.claude/CLAUDE.md ~/.claude/settings.json ~/.claude/statusline-command.sh
```

## 2. install.sh を実行

```bash
bash ~/dotfiles/install.sh
```

## 3. PC固有ファイルを作成

**個人PCの場合:**

```bash
cp ~/dotfiles/local/gitconfig.local.personal ~/.gitconfig.local
cp ~/dotfiles/local/zshrc.local.personal ~/.zshrc.local
```

**会社PCの場合:**

```bash
cp ~/dotfiles/local/gitconfig.local.work ~/.gitconfig.local
cp ~/dotfiles/local/zshrc.local.work ~/.zshrc.local
```

## 4. GitHub にリポジトリを作成して push

```bash
cd ~/dotfiles
git remote add origin git@github.com:uidev1116/dotfiles.git
git push -u origin main
```

## 5. バックアップの削除（確認後）

```bash
rm -rf ~/.zprezto.bak ~/.gitconfig.bak
```
