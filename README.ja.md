# herdr-url-picker

[English](README.md) | 日本語

[Herdr](https://herdr.dev) 用のプラグインです。フォーカス中のペインの表示内容から URL（`http://` / `https://`）を抽出して一覧表示し、選択した URL をブラウザで開きます。tmux の urlview 系プラグイン相当の機能を Herdr で実現します。

## 機能

- フォーカス中のペインの直近 200 行（折り返し解除済み）から URL を抽出
- 重複を除去しつつ出現順を維持して一覧表示
- `fzf` があればインクリメンタル検索付きの選択 UI、なければ番号入力のフォールバック
- 選択した URL を macOS では `open`、Linux では `xdg-open` で開く
- ポップアップ（session-modal popup）として起動するため、レイアウトを崩さない

## 動作要件

- Herdr 0.7.5 以上（macOS / Linux）
- `jq`（必須。プラグインコンテキスト JSON の解析に使用）
- `fzf`（任意。あれば選択 UI が快適になる）

## インストール

```bash
herdr plugin install chouxcreams/herdr-url-picker
```

ローカルで開発・試用する場合はリポジトリをチェックアウトしてリンクします:

```bash
git clone https://github.com/chouxcreams/herdr-url-picker.git
herdr plugin link /path/to/herdr-url-picker
```

登録状態の確認:

```bash
herdr plugin list
herdr plugin action list --plugin chouxcreams.url-picker
```

## キーバインド設定

Herdr の設定ファイルに以下を追加すると、キー一発でピッカーを開けます:

```toml
[[keys.command]]
key = "prefix+u"
type = "plugin_action"
command = "chouxcreams.url-picker.pick"
description = "pick URL from focused pane"
```

## 使い方

キーバインド（または `herdr plugin action invoke chouxcreams.url-picker.pick`）でポップアップが開き、フォーカス中のペインから抽出された URL の一覧が表示されます。選択すると既定のブラウザで開きます。URL が見つからない場合はメッセージを表示して終了します。

## スクリプト単体での実行（デバッグ用）

`picker.sh` は第 1 引数でペイン ID を直接指定できます:

```bash
# ペイン ID の確認
herdr pane list --workspace "$HERDR_WORKSPACE_ID"

# 抽出結果の一覧を確認し、番号を標準入力で渡して非対話で選択
echo 1 | URL_PICKER_PRINT_ONLY=1 bash picker.sh <pane_id>
```

環境変数:

| 変数 | 効果 |
| --- | --- |
| `URL_PICKER_NO_FZF=1` | fzf があっても番号入力フォールバックを使う |
| `URL_PICKER_PRINT_ONLY=1` | 選択した URL をブラウザで開かず標準出力に表示する |
| `URL_PICKER_LINES` | 読み取る行数（デフォルト: 200） |

## アンインストール

```bash
herdr plugin uninstall chouxcreams.url-picker   # install した場合
herdr plugin unlink chouxcreams.url-picker      # link した場合
```
