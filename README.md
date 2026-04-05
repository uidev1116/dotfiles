# dotfiles

## セットアップ手順

```bash
git clone --recursive git@github.com:uidev1116/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

> `--recursive` オプションで zprezto submodule も同時に取得されます。

## install.sh 実行後の手動作業

### 個人PCの場合

```bash
cp ~/dotfiles/local/gitconfig.local.personal ~/.gitconfig.local
cp ~/dotfiles/local/zshrc.local.personal ~/.zshrc.local
```

### 会社PCの場合

```bash
cp ~/dotfiles/local/gitconfig.local.work ~/.gitconfig.local
cp ~/dotfiles/local/zshrc.local.work ~/.zshrc.local
```

## 管理対象ファイル

| ファイル | 説明 |
|---|---|
| `.gitignore` | このリポジトリ用gitignore |
| `gitconfig` | Git共通設定 |
| `gitignore.global` | グローバルgitignore |
| `claude/CLAUDE.md` | Claude Code グローバル指示 |
| `claude/settings.json` | Claude Code 設定（hooks・statusLine等） |
| `claude/statusline-command.sh` | ステータスライン表示スクリプト |
| `zshrc.common` | zsh共通設定（zprezto・Kiro CLI） |
| `zprezto/` | zshフレームワーク（git submodule） |
| `local/*.personal` | 個人PC用設定サンプル |
| `local/*.work` | 会社PC用設定サンプル |

## シンボリックリンクではなくコピーして使うもの

`local/` 配下にサンプルを管理。各PCで `~/.gitconfig.local` / `~/.zshrc.local` としてコピーして使う。

## Gitで管理しないもの

| ファイル | 内容 |
|---|---|
| `~/.ssh/` | 秘密鍵（絶対にGit管理しない） |
