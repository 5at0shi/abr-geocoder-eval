# abr-geocoder 評価結果

## 結論

- 判定: `条件付きで適切`
- 向いている用途:
  - 住居表示中心の住所正規化
  - 住居表示住所への座標付与
  - 住所本体と建物名・階数の分離補助
- 注意が必要な用途:
  - 地番住所を安定して番地レベルまで正規化したいケース
  - 住居表示と地番が混在し、どちらも同等精度を期待する契約DB
  - 市区町村限定ダウンロードでも保存容量を強く抑えたい環境

## 容量の実測

### 千代田区 (`131016`)

- 事前見積もりの対象ZIP合計: 約 `40.55 MiB`
- 実測ディスク使用量: 約 `397M`
- 内訳:
  - `download`: 約 `394M`
  - `database`: 約 `3.0M`
  - `cache`: 約 `112K`

### 海老名市 (`142158`)

- 事前見積もりの対象ZIP合計: 約 `36.09 MiB`
- 実測ディスク使用量: 約 `377M`
- 内訳:
  - `download`: 約 `364M`
  - `database`: 約 `14M`
  - `cache`: 約 `72K`

## 評価結果

### 千代田区

- 住居表示は良好。
  - `紀尾井町1-3` は `residential_detail`
  - `外神田1-17-6` は `residential_detail`
  - `永田町1-10-1` は `residential_block`
- 地番系は弱い。
  - `神田神保町1丁目1番地` は `machiaza_detail` 止まり
  - `神田淡路町1丁目1番地` も `machiaza_detail` 止まり
  - `一番町1番地` は `東京都千代田区一番町町1` となり不自然
- 付帯情報付きは不安定。
  - `千代田区紀尾井町1-3 東京ガーデンテラス紀尾井町 19階` は `千代田区` が重複した

### 海老名市

- 住居表示と地番の混在に対して、千代田区より素直だった。
  - `勝瀬175-1` は `parcel` で `prc_id` を取得
  - `国分南3-12-3` は `residential_detail`
  - `河原口3-13-1 2階` は `residential_block`
- 一方で、地番のすべてが番地レベルまで取れるわけではない。
  - `柏ケ谷884` と `柏ケ谷1090` は `machiaza` 止まり
  - `柏ケ谷2-6-1` は `machiaza_detail` 止まり
- 付帯情報は `other` に残せるが、番地解像度は入力パターン依存。

## 業務適用の判断

- そのまま本番適用してよいケース:
  - 住居表示中心
  - 地番は補助的
  - `match_level` と `coordinate_level` を見て後続処理を分けられる
- 前処理または後処理が必要なケース:
  - 地番の比率が高い
  - `番地`、`号`、ハイフン記法が混在する
  - 建物名や部屋番号を含む入力が多い
- 推奨運用:
  - `--target all` を基本とする
  - `match_level` が `machiaza` / `machiaza_detail` に落ちたものを要確認キューに回す
  - `other` を保持して建物名・階数だけを別項目に退避する

## 生成物

- 千代田区 summary: [results/chiyoda/summary.md](../results/chiyoda/summary.md)
- 海老名市 summary: [results/ebina/summary.md](../results/ebina/summary.md)
- 片付けスクリプト: [scripts/cleanup_abr_data.sh](../scripts/cleanup_abr_data.sh)
