# dotfiles

## セットアップ手順

```bash
git clone --recursive git@github.com:uidev1116/dotfiles.git ~/dotfiles
cd ~/dotfiles
zsh install.sh work       # 会社PC
# または
zsh install.sh personal   # 個人PC
```

> - `--recursive` オプションで zprezto submodule も同時に取得されます。
> - 第1引数（`work` / `personal`）を渡すと、`~/.gitconfig.local` と `~/.zshrc.local` も
>   シンボリックリンクで自動作成されます。引数を省略するとローカル設定はスキップされます。

## install.sh 実行後の手動作業

### npmrc の認証トークン

`install.sh` 実行後、`~/.npmrc` に以下を手動で追記してください：

```
//registry.npmjs.org/:_authToken=<YOUR_TOKEN>
```

## 管理対象ファイル

| ファイル | 説明 |
|---|---|
| `gitconfig` | Git共通設定（`~/.gitconfig.local` を include） |
| `gitignore.global` | グローバルgitignore |
| `claude/CLAUDE.md` | Claude Code グローバル指示 |
| `claude/settings.json` | Claude Code 設定（hooks・statusLine・plugins等。プロジェクト固有の権限は含めない） |
| `claude/statusline-command.sh` | ステータスライン表示スクリプト |
| `claude/skills` | `../agents/skills` へのシンボリックリンク |
| `cursor/skills` | `../agents/skills` へのシンボリックリンク |
| `agents/skills/` | AI エージェント共通スキル（実体） |
| `npmrc` | npm設定（認証トークンを除く） |
| `pnpm/rc` | pnpm設定 |
| `zshrc.common` | zsh共通設定（zprezto・Kiro CLI・bun・safe-chain・local読み込み） |
| `zprezto/` | zshフレームワーク（git submodule） |
| `local/*.personal` | 個人PC用ローカル設定 |
| `local/*.work` | 会社PC用ローカル設定（Homebrew prefix を自動判定し Intel/Apple Silicon 両対応） |

## スキル管理（`agents/skills/`）

スキルの実体は `agents/skills/` で管理し、各ツールからはシンボリックリンクで参照します。

```
~/.agents/skills/    → ~/dotfiles/agents/skills/  （実体）
~/.cursor/skills     → ~/.agents/skills            （Cursor用）
~/.claude/skills     → ~/.agents/skills            （Claude Code用）
```

dotfiles リポジトリ内の `cursor/skills` と `claude/skills` もシンボリックリンクとして git 管理されています。

## ローカル設定の考え方

| 種類 | 実体 | 仕組み |
|---|---|---|
| 共通設定 | `zshrc.common`・`gitconfig` 等 | シンボリックリンク（リポジトリと同期） |
| PC固有設定 | `local/*.personal` / `local/*.work` | `install.sh <profile>` でシンボリックリンク |

`gitconfig` は `[include] path = ~/.gitconfig.local` でローカルのメールアドレス等を読み込み、
`zshrc.common` は末尾で `~/.zshrc.local` を `source` します。

## Gitで管理しないもの

| ファイル | 内容 |
|---|---|
| `~/.ssh/` | 秘密鍵（絶対にGit管理しない） |
| `~/.npmrc` の `_authToken` 行 | npm認証トークン（`install.sh`後に手動追記） |
