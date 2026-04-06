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
| `gitconfig` | Git共通設定 |
| `gitignore.global` | グローバルgitignore |
| `claude/CLAUDE.md` | Claude Code グローバル指示 |
| `claude/settings.json` | Claude Code 設定（hooks・statusLine等） |
| `claude/statusline-command.sh` | ステータスライン表示スクリプト |
| `claude/skills` | `../agents/skills` へのシンボリックリンク |
| `cursor/skills` | `../agents/skills` へのシンボリックリンク |
| `agents/skills/` | AI エージェント共通スキル（実体） |
| `npmrc` | npm設定（認証トークンを除く） |
| `pnpm/rc` | pnpm設定 |
| `zshrc.common` | zsh共通設定（zprezto・Kiro CLI） |
| `zprezto/` | zshフレームワーク（git submodule） |
| `local/*.personal` | 個人PC用設定サンプル |
| `local/*.work` | 会社PC用設定サンプル |

## スキル管理（`agents/skills/`）

スキルの実体は `agents/skills/` で管理し、各ツールからはシンボリックリンクで参照します。

```
~/.agents/skills/    → ~/dotfiles/agents/skills/  （実体）
~/.cursor/skills     → ~/.agents/skills            （Cursor用）
~/.claude/skills     → ~/.agents/skills            （Claude Code用）
```

dotfiles リポジトリ内の `cursor/skills` と `claude/skills` もシンボリックリンクとして git 管理されています。

## シンボリックリンクではなくコピーして使うもの

`local/` 配下にサンプルを管理。各PCで `~/.gitconfig.local` / `~/.zshrc.local` としてコピーして使う。

## Gitで管理しないもの

| ファイル | 内容 |
|---|---|
| `~/.ssh/` | 秘密鍵（絶対にGit管理しない） |
| `~/.npmrc` の `_authToken` 行 | npm認証トークン（`install.sh`後に手動追記） |

### npmrc の認証トークンについて

`install.sh` 実行後、`~/.npmrc` に以下を手動で追記してください：

```
//registry.npmjs.org/:_authToken=<YOUR_TOKEN>
```
