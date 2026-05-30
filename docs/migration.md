# 既存環境への導入手順（バックアップ込み）

既存の Mac に dotfiles を導入する手順。`install.sh` は既存ファイルをシンボリックリンクで
置き換える（一部は削除を伴う）ため、**会社PC等では事前バックアップとロールバック手段を必ず用意する**。

このガイドは会社PC（`work` profile）を主例にする。個人PCの場合は `work` を `personal` に読み替える。

---

## 0. 前提：install.sh が触るもの

| ターゲット | 典型的な現状 | install 後 | 注意 |
|---|---|---|---|
| `~/.zprezto` | 実ディレクトリ（git repo） | `dotfiles/zprezto` へのリンク | install 時に `rm -rf` される（要バックアップ） |
| `~/.zshrc` | 実ファイル or runcoms へのリンク | `dotfiles/zshrc.common` へのリンク | PC固有設定が消える |
| `~/.z{login,logout,preztorc,profile,shenv}` | runcoms へのリンク | `dotfiles` 配下へ張り替え | |
| `~/.gitconfig` | 実ファイル | `dotfiles/gitconfig` へのリンク | name/email が変わる |
| `~/.gitignore.global` | 無い場合が多い | 新規リンク | |
| `~/.claude/settings.json` | 実ファイル | `dotfiles/claude/settings.json` へのリンク | **固有 permission が消える** |
| `~/.claude/CLAUDE.md` / `statusline-command.sh` | 実ファイル | リンク | |
| `~/.npmrc` / `pnpm/rc` / `*/skills` | 既にリンク済みのことが多い | 同じ | 影響なし |

> **注意（`~/.zprezto`）**: install.sh は `~/.zprezto` を `link_dir` で張る。実ディレクトリの場合は
> **`rm -rf` で中身ごと削除**してからリンクするため、独自に加えた変更があれば失われる。
> ステップ1のバックアップに加え、ステップ2で `mv` 退避しておくと確実（退避はバックアップを兼ねる）。

導入前に自分のPCの現状を確認するには:

```bash
for p in ~/.zprezto ~/.zshrc ~/.gitconfig ~/.gitignore.global \
         ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.claude/statusline-command.sh \
         ~/.zshrc.local ~/.gitconfig.local; do
  if [ -L "$p" ]; then echo "[リンク] $p -> $(readlink "$p")"
  elif [ -d "$p" ]; then echo "[実ディレクトリ] $p"
  elif [ -f "$p" ]; then echo "[実ファイル] $p"
  else echo "[なし] $p"; fi
done
```

---

## 1. バックアップを取る

タイムスタンプ付きディレクトリに、install で置き換わる**実体**をコピーする。

```bash
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP/.claude"

# シェル設定（-L で、リンクでも実体を辿ってコピー）
cp -L ~/.zshrc                          "$BACKUP/.zshrc"                          2>/dev/null
for f in .zlogin .zlogout .zpreztorc .zprofile .zshenv; do
  cp -L ~/$f "$BACKUP/$f" 2>/dev/null
done

# git
cp -L ~/.gitconfig                      "$BACKUP/.gitconfig"                      2>/dev/null
cp -L ~/.gitignore.global               "$BACKUP/.gitignore.global"               2>/dev/null

# Claude Code（固有 permission を含む settings.json は必ず保存）
cp -L ~/.claude/settings.json           "$BACKUP/.claude/settings.json"           2>/dev/null
cp -L ~/.claude/CLAUDE.md               "$BACKUP/.claude/CLAUDE.md"               2>/dev/null
cp -L ~/.claude/statusline-command.sh   "$BACKUP/.claude/statusline-command.sh"   2>/dev/null

echo "バックアップ先: $BACKUP"
ls -la "$BACKUP"
```

> `~/.zprezto` 本体はサイズが大きいので、次のステップで `mv` して退避する（それがバックアップを兼ねる）。
> バックアップ先のパス `$BACKUP` は**メモしておく**（ロールバックで使う）。

---

## 2. `~/.zprezto` を退避する

```bash
# install で rm -rf される前にリネームして退避（バックアップを兼ねる）
[ -e ~/.zprezto ] && [ ! -L ~/.zprezto ] && mv ~/.zprezto ~/.zprezto.preinstall
```

これで `~/.zprezto` が無くなり、`~/.zshrc`（zprezto 内を指していたリンク）も一旦切れるが、
install.sh が `dotfiles/zshrc.common` へ張り直すので問題ない。

---

## 3. dotfiles を取得して install

```bash
# まだクローンしていない場合
git clone --recursive git@github.com:uidev1116/dotfiles.git ~/dotfiles

cd ~/dotfiles
zsh install.sh work     # 会社PC（個人PCなら personal）
```

`work` を渡すと `~/.gitconfig.local`（メール）と `~/.zshrc.local`（PC固有設定）も
シンボリックリンクで自動作成される。

---

## 4. install 後の手動作業

### npmrc の認証トークン

`~/.npmrc` に認証トークンを追記する（dotfiles では管理しない）:

```bash
echo "//registry.npmjs.org/:_authToken=<YOUR_TOKEN>" >> ~/.npmrc
```

### 必要なら旧 settings.json から汎用ルールを移す

install 後の `~/.claude/settings.json` は dotfiles 版（汎用設定のみ）になる。
旧設定にあった**どのプロジェクトでも安全な permission** を使いたい場合は、
`$BACKUP/.claude/settings.json` から該当ルールだけを手動でコピーする。
**プロジェクト固有の permission は、各リポジトリの `.claude/settings.local.json` に入れる**こと。

---

## 5. 動作確認

```bash
# 新しいシェルを起動して設定が読まれるか
exec zsh

# リンクが正しく張られたか
ls -l ~/.zshrc ~/.zshrc.local ~/.gitconfig ~/.gitconfig.local ~/.zprezto

# git のメールが work 用になっているか
git config user.email      # → ui@appleple.com

# prezto が読み込まれているか（プロンプトが変わる／エラーが出ない）
```

問題なければ完了。

---

## 6. ロールバック（元に戻す）

`$BACKUP` が分からなくなった場合は `ls -d ~/dotfiles-backup-*` で探す。

```bash
BACKUP="$HOME/dotfiles-backup-XXXXXXXX-XXXXXX"   # ← 実際のパスに置き換える

# dotfiles が張ったリンクを外す
rm -f ~/.zshrc ~/.gitconfig ~/.gitignore.global ~/.zshrc.local ~/.gitconfig.local
rm -f ~/.zlogin ~/.zlogout ~/.zpreztorc ~/.zprofile ~/.zshenv
rm -f ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.claude/statusline-command.sh
rm -f ~/.zprezto    # リンクになっているので消してよい

# バックアップから復元
cp -R "$BACKUP/.zshrc"        ~/.zshrc        2>/dev/null
for f in .zlogin .zlogout .zpreztorc .zprofile .zshenv .gitconfig .gitignore.global; do
  cp -R "$BACKUP/$f" ~/$f 2>/dev/null
done
cp -R "$BACKUP/.claude/." ~/.claude/ 2>/dev/null

# 退避した zprezto を戻す
[ -d ~/.zprezto.preinstall ] && mv ~/.zprezto.preinstall ~/.zprezto

exec zsh
```

---

## 7. 後片付け（動作に問題がなければ）

```bash
rm -rf "$BACKUP" ~/.zprezto.preinstall
```

---

## 引き継がれないもの（会社PC向けの注意）

- **`~/.claude/settings.json` の固有 permission**（社内ドメインの dig、社内パスの Read 等）
  → dotfiles 版に置き換わるため消える。バックアップに残る。固有分はプロジェクトの
    `.claude/settings.local.json` へ寄せる運用。
- **旧 `~/.zshrc` 内の PC固有 PATH**（nodenv・gcloud・antigravity 等）
  → `local/zshrc.local.work` に Homebrew prefix 自動判定（Intel/Apple Silicon 両対応）で
    統合済み。`zsh install.sh work` で適用される。
- **Slack Webhook 等の秘密情報**
  → 秘密情報の仕組みは撤去済み。必要になったら別途 `~/.zshrc.local`（git管理外の実ファイル）等で管理する。
