# ABR Geocoder 実行内容と結果

## Summary

- `abr-geocoder` の最小検証を `東京都千代田区 (131016)` と `神奈川県海老名市 (142158)` で実施した。
- 実施範囲は、自治体限定DBの作成、`--target all / residential / parcel` の比較、公式サンプルと自前サンプルでの挙動確認。
- 最終判定は `条件付きで適切`。
- 全体傾向として、住居表示は強く、地番は入力パターンによって精度差が大きかった。

## 実行環境

- 作業ディレクトリ: このリポジトリのルート
- 一時インストール先: `/tmp/abrg-test2`
- Node.js: `v24.14.1`
- npm: `11.11.0`
- Python: `python3` (`/path/to/python3` を明示しても可)

## 実行時の対応事項

- `better-sqlite3` のビルド時は `Python 3.12.4` の実体パス指定で解決した。
- `Node.js v24.14.1` では `uWebSockets.js` の互換性問題で CLI 起動が失敗した。
- 今回は REST API サーバを使わず CLI 評価だけが目的だったため、一時インストール先で `serve` コマンド先読みを外す最小パッチを適用して `download` と `geocode` を使える状態にした。
- この回避は `/tmp/abrg-test2` 配下だけの一時対応で、リポジトリ本体には入れていない。

## 実施手順

1. `/tmp/abrg-test2` に `@digital-go-jp/abr-geocoder` をインストール
2. `abrg download -c 131016` で千代田区データを作成
3. 千代田区サンプルを `--target all / residential / parcel` で実行
4. 同様に `abrg download -c 142158` で海老名市データを作成
5. 海老名市サンプルを `--target all / residential / parcel` で実行
6. `scripts/summarize_results.py` で summary を生成

## 入力データ

### 千代田区

- 公式サンプル: [samples/chiyoda/official.txt](samples/chiyoda/official.txt)
- 自前サンプル: [samples/chiyoda/custom.txt](samples/chiyoda/custom.txt)
- 住所種別:
  - 住居表示寄り: `紀尾井町1-3`, `永田町1-10-1`, `外神田1-17-6`
  - 地番寄り: `神田神保町1丁目1番地`, `神田淡路町1丁目1番地`, `一番町1番地`
  - 付帯情報あり: `東京ガーデンテラス紀尾井町 19階`, `6階`

### 海老名市

- 自前サンプル: [samples/ebina/custom.txt](samples/ebina/custom.txt)
- 住所種別:
  - 地番寄り: `勝瀬175-1`, `柏ケ谷884`, `柏ケ谷1090`
  - 住居表示寄り: `国分南3-12-3`, `河原口3-13-1`, `柏ケ谷2-6-1`
  - 付帯情報あり: `2階`

## 容量の実測

### 千代田区 (`131016`)

- 事前見積もりの対象ZIP合計: 約 `40.55 MiB`
- 実測ディスク使用量: 約 `397M`
- 内訳:
  - `download`: 約 `394M`
  - `database`: 約 `3.0M`
  - `cache`: 約 `112K`
- 主な保存先:
  - DB: [results/chiyoda/data/database](results/chiyoda/data/database)
  - 展開済みCSV: [results/chiyoda/data/download](results/chiyoda/data/download)

### 海老名市 (`142158`)

- 事前見積もりの対象ZIP合計: 約 `36.09 MiB`
- 実測ディスク使用量: 約 `377M`
- 内訳:
  - `download`: 約 `364M`
  - `database`: 約 `14M`
  - `cache`: 約 `72K`
- 主な保存先:
  - DB: [results/ebina/data/database](results/ebina/data/database)
  - 展開済みCSV: [results/ebina/data/download](results/ebina/data/download)

## 出力ファイル

- 千代田区 summary: [results/chiyoda/summary.md](results/chiyoda/summary.md)
- 海老名市 summary: [results/ebina/summary.md](results/ebina/summary.md)
- 評価メモ: [docs/abr-geocoder-evaluation.md](docs/abr-geocoder-evaluation.md)
- 評価結果: [docs/abr-geocoder-assessment.md](docs/abr-geocoder-assessment.md)

## 結果詳細

### 千代田区

#### `--target all`

- 住居表示住所は概ね良好だった。
  - `紀尾井町1-3` は `residential_detail`
  - `永田町1-10-1` は `residential_block`
  - `外神田1-17-6` は `residential_detail`
- 地番寄り入力は番地まで届かないものがあった。
  - `神田神保町1丁目1番地` は `machiaza_detail`
  - `神田淡路町1丁目1番地` も `machiaza_detail`
  - `一番町1番地` は `machiaza` かつ `東京都千代田区一番町町1` と不自然
- 付帯情報付き入力は不安定だった。
  - `千代田区紀尾井町1-3 東京ガーデンテラス紀尾井町 19階` は `東京都千代田区千代田区紀尾井町1-3 ...` と区名が重複した
  - `other` には `区紀尾井町1-3 東京ガーデンテラス紀尾井町 19階` が残った

#### `--target residential`

- `all` とほぼ同傾向で、住居表示寄りの入力に強かった。
- `紀尾井町1-3` と `外神田1-17-6` は番地レベルまで取れた。
- `永田町1-10-1` と `永田町一丁目7番1号` は `residential_block` 止まりで、末尾の `-1` が `other` に残った。

#### `--target parcel`

- 千代田区では parcel 指定の優位性は限定的だった。
- `大手町1-6-1 6階` は `parcel` になり `prc_id=000060000100000` を取得した。
- `外神田1-17-6` も `parcel` になったが、末尾 `-6` が `other` に残った。
- 一方で `紀尾井町1-3` や `永田町1-10-1` は `machiaza` / `machiaza_detail` に留まり、地番解像度の改善は乏しかった。

#### 千代田区の所見

- 住居表示中心なら十分有望。
- 地番混在データをそのまま高精度にさばくには弱い。
- オフィス系の建物名付き住所では前処理または `other` の後処理が必要。

### 海老名市

#### `--target all`

- 千代田区より `all` が自然に住居表示/地番を切り替えた。
- `勝瀬175-1` は `parcel` になり `prc_id=001750000100000` を取得した。
- `国分南3-12-3` は `residential_detail`、`河原口3-13-1 2階` は `residential_block` になった。
- `柏ケ谷884` と `柏ケ谷1090` は `machiaza` 止まりで、番地は `other` に残った。
- `柏ケ谷2-6-1` は `machiaza_detail` 止まりで、`6-1` が `other` に残った。

#### `--target residential`

- 住居表示寄り入力では有効。
  - `国分南3-12-3` は `residential_detail`
  - `河原口3-13-1 2階` は `residential_block`
- 地番寄り入力では `machiaza` に落ちやすかった。
  - `勝瀬175-1` は `machiaza`
  - `柏ケ谷884` と `柏ケ谷1090` も `machiaza`

#### `--target parcel`

- 地番寄り入力では明確に有効だった。
  - `勝瀬175-1` は `parcel`
  - `河原口3-13-1 2階` も `parcel` として拾えた
- ただしすべての地番入力が parcel になるわけではなかった。
  - `柏ケ谷884` と `柏ケ谷1090` は `machiaza`
  - `柏ケ谷2-6-1` は `machiaza_detail`

#### 海老名市の所見

- 住居表示と地番の混在への相性は千代田区より良い。
- `all` のままでも一定の自動切り替えが効く。
- それでも地番の番地レベル解像度は入力パターン依存で、すべてが `parcel` に着地するわけではない。

## `other` フィールドの観察

- 建物名・階数だけが残るケースと、番地の一部が残るケースが混在した。
- 良い例:
  - `大手町1-6-1 6階` の `parcel` では `other=6階`
  - `河原口3-13-1 2階` の `all` では `other=-1 2階`
- 注意が必要な例:
  - `勝瀬175-1` の `residential` では `other=175-1`
  - `柏ケ谷884` では `other=884`
  - `紀尾井町` の建物名付きでは住所本体の一部まで `other` に残った

## `match_level` / `coordinate_level` の観察

- `residential_detail` が取れたケースは、住居表示住所としてかなり扱いやすい。
- `residential_block` は街区止まりなので、棟・号レベルの精度を求める用途では補完が必要。
- `parcel` は `prc_id` を取れるが、`coordinate_level` は `city` のままのケースもあった。
- `machiaza` / `machiaza_detail` に落ちたものは、業務上の確認対象として扱うのが妥当。

## 判定

- 判定: `条件付きで適切`
- 向いている:
  - 住居表示中心の正規化
  - 住居表示住所への座標付与
  - 建物名や階数を `other` 側へ退避しながら住所本体を切り出す用途
- 注意が必要:
  - 地番住所を安定して番地レベルまで正規化したいケース
  - 住居表示と地番が混在し、どちらも同等精度を期待するケース
  - 保存容量を強く抑えたい環境

## 推奨運用

- 基本は `--target all` を使い、住居表示/地番の自動切り替えに任せる。
- `match_level` が `machiaza` / `machiaza_detail` の行は再確認対象に回す。
- `coordinate_level` が `city` の行は精度不足の可能性がある前提で扱う。
- `other` は捨てずに保持し、建物名・階数・部屋番号の退避先として使う。
- 地番比率の高いデータでは、`parcel` 再試行やルールベース前処理の併用を検討する。

## Cleanup

- テストデータだけ消す場合:
  - `bash scripts/cleanup_abr_data.sh chiyoda`
  - `bash scripts/cleanup_abr_data.sh ebina`
  - `bash scripts/cleanup_abr_data.sh all`
- この cleanup は `results/<region>/data` だけを削除し、`outputs` と要約は残す。
