# ABR Geocoder 最小検証プラン

## Summary
- 目的は、`abr-geocoder` が社内の契約DB住所を「正規化 + 住居表示/地番の判別 + 座標付与」に使えるかを、容量を抑えた最小構成で判断すること。
- 最小検証地域は `東京都千代田区 (131016)` と `神奈川県海老名市 (142158)` を採用する。
- 容量優先のため、2地域を同時に持たず、`1自治体ずつDBを作成して検証 → 次地域へ切替` の順で進める。
- 検証用入力は `公式サンプル + 自前サンプル` を併用する。

## Key Changes / Execution Plan
- ローカル実行時はコード改修なしで CLI を一時利用する。対象インターフェースは `abrg download -c`, `abrg --target`, `abrg serve start` ではなく、まずは CLI 単体評価を優先する。
- 東京側は `千代田区` を使う。
  - 理由: オフィス系住所に寄りやすい。
  - 公式に住居表示の実施地区・未実施地区の併存が確認できる。
- 神奈川側は `海老名市` を使う。
  - 理由: 公式に住居表示実施地域と未実施地域の併存が確認できる。
  - 6桁団体コード `142158` が確認できる。
- 1地域ごとに次の順で評価する。
  1. 自治体限定DBを作成
  2. 公式サンプルで基本動作確認
  3. 自前サンプルで実務寄り確認
  4. `--target all / residential / parcel` の差分確認
  5. `output`, `other`, `match_level`, `coordinate_level`, `lat`, `lon`, `rsdt_addr_flg`, `prc_id` を評価
- 自前サンプルは各地域で最低6件そろえる。
  - 住居表示 3件
  - 地番表示 3件
- 付帯情報が時々混ざる前提なので、各地域で1-2件は `建物名・階数・部屋番号あり` を含める。
- 判定基準は次で固定する。
  - `適切`: 住居表示/地番の双方で主要項目が安定して取れ、`other` に残るのが建物名や部屋番号中心
  - `条件付きで適切`: 住所本体は取れるが、地番または住居表示のどちらかで取りこぼしがある
  - `不適切`: 住所本体の正規化が不安定、または座標付与が業務利用に耐えない

## Test Plan
- 千代田区:
  - 住居表示実施地区 2件
  - 住居表示未実施地区 2件
  - 自前サンプル 6件以上
- 海老名市:
  - 住居表示実施地区 2件
  - 住居表示未実施地区 2件
  - 自前サンプル 6件以上
- 各入力で確認する観点:
  - 正規化後住所が期待どおりか
  - `match_level` が `residential_*` / `parcel` に妥当着地するか
  - `other` に業務上無視できる文字だけが残るか
  - 座標が返るか、返る場合の `coordinate_level` が十分か
  - `--target all` と `--target residential/parcel` で解釈差が説明可能か
- ダウンロード容量の目安:
  - chiyoda 42517596 40.55 MiB  展開後: 397MB
  - ebina 37845067 36.09 MiB

## Assumptions / Defaults
- まずは全国対応可否ではなく、`東京 + 神奈川の代表2自治体` で採否判断する。
- 容量抑制を最優先し、都道府県単位ダウンロードは行わない。
- まずは CLI 評価のみで十分とし、REST API サーバ検証は後回しにする。
- ローカル実行に進む場合は、一時インストール + 自治体限定ダウンロードのみを許容範囲とする。
- 自前サンプルは匿名化済み住所を前提とする。

## Sources
- 公式概要・仕様: https://lp.geocoder.address-br.digital.go.jp/
- 公式対応ケース: https://lp.geocoder.address-br.digital.go.jp/case.html
- 公式 README / CLI 仕様: https://github.com/digital-go-jp/abr-geocoder
- 千代田区 住居表示実施/未実施地区: https://www.city.chiyoda.lg.jp/koho/machizukuri/tochi/jukyohyoji/jisshi.html
- 海老名市 住居表示説明: https://www.city.ebina.kanagawa.jp/guide/todokede/jukyo/1002837.html
- 海老名市 団体コード `142158`: https://www.j-lis.go.jp/spd/code-address/kantou/cms_13514181.html
