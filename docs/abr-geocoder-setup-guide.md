# abr-geocoder 環境導入と実行手順

## この手順書の目的

この手順書は、`abr-geocoder` を初めて触る人でも、

- 環境を準備する
- `abr-geocoder` をインストールする
- サンプル住所で動作確認する
- このフォルダにある検証用スクリプトを実行する

ところまで進められるようにまとめたものです。

対象読者は、住所正規化やジオコーディングの前提知識がない社内メンバーです。

## abr-geocoder とは

`abr-geocoder` は、デジタル庁のアドレス・ベース・レジストリを使って、日本の住所を正規化したり、緯度経度を付けたりするためのツールです。

今回の用途では、特に次を確認するために使います。

- 住居表示の住所をどこまで正規化できるか
- 地番の住所をどこまで扱えるか
- 建物名や階数が混ざった文字列をどこまで切り分けられるか
- 緯度経度を返せるか

## 先に知っておきたいこと

今回の検証で確認できた注意点です。

- `Node.js 24` では、そのままだと起動に失敗することがありました
- 安定して進めるには `Node.js 20` または `Node.js 22` を使うのがおすすめです
- インストール時に `better-sqlite3` をビルドするため、`Python 3.x` が必要です
- 自治体を1つだけ指定しても、実際の保存容量は数百MBになることがあります

## このフォルダにあるもの

`/path/to/abr-geocoder` は、このリポジトリを手元に置いた実際のパスに置き換えてください。

- 計画書: [PLAN.md](../PLAN.md)
- 実行結果: [EXECUTION_RESULT.md](../EXECUTION_RESULT.md)
- 評価メモ: [docs/abr-geocoder-evaluation.md](abr-geocoder-evaluation.md)
- 評価結果: [docs/abr-geocoder-assessment.md](abr-geocoder-assessment.md)
- 検証用サンプル: [samples](../samples)
- 実行スクリプト: [scripts/evaluate_abr_geocoder.sh](../scripts/evaluate_abr_geocoder.sh)
- 要約スクリプト: [scripts/summarize_results.py](../scripts/summarize_results.py)
- 片付けスクリプト: [scripts/cleanup_abr_data.sh](../scripts/cleanup_abr_data.sh)

## 前提条件

最低限、次が入っていることを確認してください。

- `Node.js 20` または `Node.js 22`
- `npm`
- `Python 3.x`
- インターネット接続

### バージョン確認

ターミナルで次を実行します。

```bash
node -v
npm -v
python3 --version
```

### Node.js の推奨バージョン

今回の検証では、`Node.js v24.14.1` で `uWebSockets.js` の互換性問題に当たりました。

そのため、社内で新しく試す人には次のどちらかをおすすめします。

- `Node.js 20`
- `Node.js 22`

## 1. 作業フォルダに移動する

```bash
cd /path/to/abr-geocoder
```

## 2. abr-geocoder 用の一時作業ディレクトリを作る

このリポジトリの中に直接 `node_modules` を置かず、一時ディレクトリにインストールします。

```bash
mkdir -p /tmp/abrg-test2
cd /tmp/abrg-test2
npm init -y
```

## 3. abr-geocoder をインストールする

`Python 3.x` の場所が通っていないと、`better-sqlite3` のビルドで失敗することがあります。

その場合は `PYTHON=...` を明示します。

例:

```bash
PYTHON=/path/to/python3 npm install @digital-go-jp/abr-geocoder
```

もし `python3` が普通に使える環境なら、次でもよいです。

```bash
npm install @digital-go-jp/abr-geocoder
```

## 4. CLI が起動するか確認する

```bash
./node_modules/.bin/abrg --help
```

### Node.js 24 を使っていて起動に失敗した場合

今回の検証では、`Node.js 24` だと `serve` コマンドの読み込み時に失敗しました。

その場合は、まず `Node.js 20` か `22` に切り替えてから再実行してください。

それでも社内検証を急いで進める必要がある場合は、今回の検証で使った一時対応があります。ただし恒久対応ではありません。

- 一時インストール先の `cli.js` から `serve` コマンド登録を外す
- これにより `download` と `geocode` だけ使う

恒久的には、`Node.js 20` か `22` にそろえるほうが安全です。

## 5. 自治体を限定してデータをダウンロードする

### 千代田区を試す場合

```bash
./node_modules/.bin/abrg download -c 131016 -d /path/to/abr-geocoder/results/chiyoda/data --silent
```

### 海老名市を試す場合

```bash
./node_modules/.bin/abrg download -c 142158 -d /path/to/abr-geocoder/results/ebina/data --silent
```

### 保存先の見方

ダウンロード後は、指定した `data` 配下に次が作られます。

- `database`: SQLite
- `download`: 展開済みCSV
- `cache`: 内部キャッシュ

例:

- [results/chiyoda/data](../results/chiyoda/data)
- [results/ebina/data](../results/ebina/data)

### 容量の目安

今回の実測です。

- 千代田区: 約 `397M`
- 海老名市: 約 `377M`

ZIP のダウンロードサイズより、展開後のディスク使用量がかなり増えます。

## 6. 1件だけ手で試す

### 千代田区の例

```bash
echo "東京都千代田区紀尾井町1-3" > /tmp/chiyoda_test.txt
./node_modules/.bin/abrg /tmp/chiyoda_test.txt -d /path/to/abr-geocoder/results/chiyoda/data --target all --format json --silent
```

### 海老名市の例

```bash
echo "神奈川県海老名市勝瀬175-1" > /tmp/ebina_test.txt
./node_modules/.bin/abrg /tmp/ebina_test.txt -d /path/to/abr-geocoder/results/ebina/data --target all --format json --silent
```

## 7. このフォルダの検証スクリプトを使う

このリポジトリには、今回の検証用スクリプトが入っています。

### 千代田区だけ実行

```bash
cd /path/to/abr-geocoder
PKG_DIR=/tmp/abrg-test2 bash scripts/evaluate_abr_geocoder.sh chiyoda
```

### 海老名市だけ実行

```bash
cd /path/to/abr-geocoder
PKG_DIR=/tmp/abrg-test2 bash scripts/evaluate_abr_geocoder.sh ebina
```

### 両方実行

```bash
cd /path/to/abr-geocoder
PKG_DIR=/tmp/abrg-test2 bash scripts/evaluate_abr_geocoder.sh all
```

## 8. 結果を確認する

主に見るファイルは次です。

- 千代田区 summary: [results/chiyoda/summary.md](../results/chiyoda/summary.md)
- 海老名市 summary: [results/ebina/summary.md](../results/ebina/summary.md)
- 実行結果のまとめ: [EXECUTION_RESULT.md](../EXECUTION_RESULT.md)

### どこを見るべきか

次の項目が重要です。

- `output`: 正規化後の住所
- `other`: 建物名、階数、残った番地など
- `match_level`: どの粒度まで一致したか
- `coordinate_level`: 座標の粒度
- `lat`, `lon`: 緯度経度
- `rsdt_addr_flg`: 住居表示か地番かの参考情報
- `prc_id`: 地番系で拾えたかどうかの目印

## 9. 片付ける

検証後に容量を空けたい場合は、`data` だけ消せます。

### 千代田区だけ消す

```bash
cd /path/to/abr-geocoder
bash scripts/cleanup_abr_data.sh chiyoda
```

### 海老名市だけ消す

```bash
cd /path/to/abr-geocoder
bash scripts/cleanup_abr_data.sh ebina
```

### 両方消す

```bash
cd /path/to/abr-geocoder
bash scripts/cleanup_abr_data.sh all
```

この cleanup は `results/<region>/data` だけを削除し、`summary` や `outputs` は残します。

## よくあるつまずき

### 1. `better-sqlite3` のインストールで失敗する

原因になりやすいもの:

- Python が見つからない
- C/C++ ビルド環境が足りない

対応:

- `python3 --version` を確認する
- `PYTHON=/path/to/python3 npm install ...` で Python の実体パスを明示する

### 2. `abrg --help` で落ちる

原因になりやすいもの:

- `Node.js 24` と `uWebSockets.js` の互換性問題

対応:

- `Node.js 20` または `22` を使う

### 3. 容量が思ったより大きい

原因:

- ZIP を落とすだけでなく、展開済みCSVが `download` 配下に残るため

対応:

- 自治体を絞って試す
- 使い終わったら `bash scripts/cleanup_abr_data.sh <region>` で `data` を削除する

### 4. 地番がうまく拾えない

原因:

- 入力パターンによって `machiaza` や `machiaza_detail` に落ちることがある

対応:

- まず `--target all` で試す
- 必要なら `--target parcel` でも再試行する
- `match_level` と `other` を見て後段で再確認する

## 社内向けのおすすめ運用

- まずは `--target all` を標準にする
- `match_level` が `machiaza` / `machiaza_detail` のものだけ確認対象に回す
- `other` は捨てずに建物名・階数・部屋番号の保管先にする
- 地番比率の高いデータは、前処理や `parcel` 再試行を組み合わせる

## 関連資料

- 計画書: [PLAN.md](../PLAN.md)
- 実行結果: [EXECUTION_RESULT.md](../EXECUTION_RESULT.md)
- 評価メモ: [docs/abr-geocoder-evaluation.md](abr-geocoder-evaluation.md)
- 評価結果: [docs/abr-geocoder-assessment.md](abr-geocoder-assessment.md)
