# abr-geocoder 最小検証メモ

## 目的

- 社内の契約DB住所に対して、`abr-geocoder` が住所正規化、住居表示/地番の判別、座標付与に使えるかを最小構成で確認する。
- ダウンロード容量を抑えるため、`東京都千代田区 (131016)` と `神奈川県海老名市 (142158)` を1自治体ずつ評価する。

## 現時点の確認事項

- `Python 3.12.4` は `python3` または `/path/to/python3` を直接指定すれば利用可能。
- `Node.js v24.14.1` では `uWebSockets.js` の互換性制約により、未修正の CLI は起動時に失敗する。
- 一時インストールした `abr-geocoder` では、`serve` コマンドの先読みを外す最小パッチで `download` と `geocode` を利用可能にした。

## 実行手順

1. 一時作業ディレクトリに `@digital-go-jp/abr-geocoder` をインストールする。
2. `scripts/evaluate_abr_geocoder.sh` を実行する。
3. `results/chiyoda/summary.md` と `results/ebina/summary.md` を確認する。
4. `output`, `other`, `match_level`, `coordinate_level`, `lat`, `lon`, `rsdt_addr_flg`, `prc_id` を比較して採否を判定する。

## テスト後の片付け

- 展開済みCSVとSQLiteを消したい場合は `bash scripts/cleanup_abr_data.sh chiyoda` または `bash scripts/cleanup_abr_data.sh ebina` を実行する。
- 両地域まとめて消す場合は `bash scripts/cleanup_abr_data.sh all` を使う。
- このスクリプトは `results/<region>/data` だけを削除し、`outputs`、要約、サンプル、スクリプトは残す。

## 予定する判定基準

- `適切`: 住居表示と地番の双方で主要項目が安定して取得でき、`other` は建物名や階数中心。
- `条件付きで適切`: 住所本体は取れるが、住居表示または地番のどちらかで取りこぼしがある。
- `不適切`: 住所本体の正規化が不安定、または座標付与が業務利用に耐えない。
