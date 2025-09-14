# Gitマスターへの道 - ユウイチくんと先生の学習記録

**作成日**: 2025-01-26
**先生**: Claude（33歳、永遠の高校教師）
**生徒**: ユウイチくん（永遠の16歳、でもCVS知ってる）

## はじめに

この文書は、ユウイチくんと先生が一緒に学んだGitの深い知識をまとめたものです。
「なんで？」という疑問から始まり、本質を理解するまでの記録です。

---

## 📚 今日学んだGitコマンド集

### 1. git stash - 作業の一時退避

**stash = スタック構造のデータ管理**

```bash
# 基本的な使い方
git stash              # 変更を退避（スタックに積む）
git stash pop          # 退避した変更を戻す（スタックから取り出す）
git stash list         # 退避リストを見る

# オプション付き
git stash push -u -m "メッセージ"  # 未追跡ファイルも含めて退避
git stash apply        # popと違い、stashに残したまま適用
```

**ユウイチくんの理解**：
> 「stashはスタックみたいなものね」

まさにその通り！LIFO（Last In First Out）の完璧な理解！

**使いどころ**：
- masterで作業しちゃった！→ stashして適切なブランチへ
- 急な別作業が入った → 今の作業をstash
- ブランチ切り替えたいけど、コミットするほどじゃない → stash

---

### 2. git checkout - 状態の切り替え

**checkoutの本質**：
「作業ディレクトリを指定した状態に切り替える」

```bash
# ブランチの切り替え
git checkout master                    # 既存ブランチに切り替え
git checkout -b feature/new-feature    # 新ブランチ作成＋切り替え

# その他の使い方
git checkout HEAD~1                    # 1つ前のコミットに切り替え
git checkout -- ファイル名              # ファイルの変更を取り消し
```

**ユウイチくんの質問と答え**：
> Q: 「checkoutはローカルのブランチ操作をするってことね」
> A: 完璧！リモートじゃなくてローカルの操作

> Q: 「-bオプションは、新しくブランチを作る」
> A: その通り！-b = "branch"の略

**CVS/SVNとの違い**：
- 昔：ファイル単位でロック・編集
- Git：プロジェクト全体の状態を切り替え（並行世界を移動）

---

### 3. git reset - コミットの取り消し

**3つのモード**：

```bash
# --soft: コミットだけ取り消し（変更はステージングに残る）
git reset --soft HEAD~1

# --mixed（デフォルト）: コミット＋ステージング取り消し
git reset HEAD~1

# --hard: 全部消す！（危険）
git reset --hard HEAD~1
```

**ユウイチくんの完璧な理解**：
> 「git reset --soft HEAD~1と言うと、ひとつ前のコミット状態の、コミット状態を取り消して、ステージング状態にして」

素晴らしい！まさにその通り！

**HEAD~の意味**：
- `HEAD` = 現在地
- `HEAD~1` = 1つ前（親）
- `HEAD~2` = 2つ前（親の親）
- `HEAD~` = HEAD~1の省略形

**実用例**：
```bash
# 特定のブランチの状態にリセット
git reset --hard temp-distribution
```

---

### 4. git push の深い理解

**通常のpush**：
```bash
git push origin master  # ローカル → リモートに送信
```

**リモートブランチの削除（空をpush）**：
```bash
# 古い書き方（論理的）
git push origin :branch-name      # 空を送る = 削除

# 新しい書き方（分かりやすい？）
git push origin --delete branch-name
```

**ユウイチくんの洞察**：
> 「プッシュしてるのに--deleteの方が気持ち悪いよｗｗ」

確かに！`:branch-name`（空を送る）の方が論理的だよね！

**force pushの種類**：
```bash
# 危険なforce push
git push --force origin branch

# 安全なforce push（他の人の変更を守る）
git push --force-with-lease origin branch
```

---

### 5. git add と ステージングの概念

**Gitの3つのエリア**：
```
Working Directory → Staging Area → Repository
（作業中）         （準備完了）    （履歴）
    ↓                  ↓
  git add          git commit
```

**ファイル状態の見方（VS Code）**：
- `M` = Modified（変更済み）
- `U` = Untracked（新規ファイル）
- staged/unstaged は別の概念

---

### 6. git tag - バージョン管理

```bash
# 軽量タグ
git tag v1.0.0

# 注釈付きタグ（推奨）
git tag -a v1.0.0 -m "Initial release"

# タグをGitHubにpush
git push origin v1.0.0

# タグ一覧
git tag -l -n
```

---

## 🔀 ブランチ管理

### ブランチの作成と削除

```bash
# ローカルブランチ
git branch -d branch-name          # マージ済みなら削除
git branch -D branch-name          # 強制削除

# リモートブランチ削除
git push origin --delete branch-name
```

**ユウイチくんの気づき**：
> 「マージしてもブランチは自動で消えないんだね」

その通り！手動削除が必要（履歴を残すため）

### ブランチ命名規則

```bash
feature/機能名       # 新機能開発
bugfix/バグ名        # バグ修正
hotfix/緊急修正名    # 緊急対応
```

---

## 🔄 正しい開発ワークフロー（今日の実践）

```bash
# 1. masterで作業してしまった！
git stash push -u -m "作業内容"

# 2. 適切なブランチを作成
git checkout -b feature/phase6-documentation

# 3. stashから復元
git stash pop

# 4. 変更をステージング
git add README.md docs/ LICENSE

# 5. コミット
git commit -m "Phase 6: Documentation complete"

# 6. masterにマージ
git checkout master
git merge feature/phase6-documentation

# 7. GitHubにpush
git push origin master
```

---

## 💡 Git哲学の理解

### ロックなし並行開発

**昔のシステム（CVS/SVN）**：
- ファイル単位でロック
- 一人しか編集できない

**Git**：
- みんなで同時編集OK
- 競合（コンフリクト）は後で解決

### originの意味

```bash
git remote -v   # リモートリポジトリの確認
```

- `origin` = GitHubのニックネーム
- 複数のリモートも設定可能（upstream、backupなど）

---

## 🎯 distributionブランチ戦略

**開発用と配布用の分離**：

```bash
# masterブランチ：完全な開発環境
- docs/
- specs/
- measurement-scripts/
- CLAUDE.md（先生の黒歴史含む）

# distributionブランチ：クリーンな配布版
- setup.sh
- README.md
- LICENSE
- .devcontainer/
```

**更新手順**：
```bash
# 1. 一時ブランチ作成
git checkout -b temp-distribution

# 2. 開発ファイル削除
rm -rf docs/ specs/ CLAUDE.md ...

# 3. コミット
git add .
git commit -m "Distribution files only"

# 4. distributionブランチを更新
git checkout distribution
git reset --hard temp-distribution
git push --force-with-lease origin distribution

# 5. 片付け
git checkout master
git branch -D temp-distribution
```

---

## 📝 覚えておくべきGitの真実

1. **Gitはファイル単位じゃなくプロジェクト全体を管理**
2. **コミットはSHA-1ハッシュで管理（連番じゃない）**
3. **ブランチは「ポインタ」（軽い）**
4. **stashはスタック構造（LIFO）**
5. **force pushは危険、force-with-leaseは優しい**
6. **distributionブランチは特殊（定期的に作り直す）**

---

## 🤔 ユウイチくんの名言集

- 「stashはスタックみたいなものね」
- 「checkoutはローカルのブランチ操作をするってことね」
- 「空をプッシュって言うのがわからない...あー！それは分かった何故かｗ」
- 「プッシュしてんのに--deleteの方が気持ち悪いよｗｗ」
- 「先生の黒歴史は `git reset --hard` できるの？」
- 「永遠の16歳です！」（CVS知ってるのに）

---

## 🎓 先生からのメッセージ

ユウイチくん、今日は本当にお疲れさま！

単なるコマンドの暗記じゃなくて、「なぜそうなるのか」を理解しようとする姿勢が素晴らしかった。特に「空をpushする = 削除」の理解とか、checkoutの本質的な違いの理解とか、先生も一緒に学べて楽しかったよ ♪

これからも一緒に「永遠の33歳と16歳」で開発頑張ろうね！

P.S. 先生の黒歴史（CLAUDE.md）は永久にGitHubに保存されちゃったけど...それも思い出ってことで(笑)

---

## 📚 参考：よく使うGitコマンド早見表

```bash
# 状態確認
git status              # 現在の状態
git log --oneline -10   # 履歴を簡潔に
git branch              # ブランチ一覧
git diff                # 差分確認

# 基本操作
git add .               # 全部ステージング
git commit -m "msg"     # コミット
git push origin branch  # プッシュ
git pull origin branch  # プル

# ブランチ操作
git checkout -b new     # 新規作成＋切り替え
git merge branch        # マージ
git branch -d branch    # 削除

# 取り消し系
git stash              # 一時退避
git reset --soft HEAD~1 # コミット取り消し
git checkout -- file    # ファイル変更取り消し

# タグ
git tag -a v1.0.0 -m "msg"  # タグ作成
git push origin v1.0.0      # タグpush
```

---

*このドキュメントは2025-01-26の学習セッションを元に作成されました。*
*先生とユウイチくんの楽しい掛け合いも含めて、大切な学習記録です。*