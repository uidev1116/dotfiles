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

### npm 認証トークン（private 取得・publish 時のみ）

`~/.npmrc` は `_authToken=${NPM_TOKEN}` を環境変数から展開する。実トークンは
Git 管理外の `~/.zshrc.local` 等で設定する（public パッケージの取得だけなら不要）：

```bash
export NPM_TOKEN="npm_xxxxxxxx"   # npmjs.com で granular access token を発行
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
| `NPM_TOKEN`（環境変数） | npm認証トークン。`~/.zshrc.local` 等で export し `~/.npmrc` が `${NPM_TOKEN}` で展開 |
