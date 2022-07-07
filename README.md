# MeteorOnEarth

## これはなに？
圏点指定《《……》》を、ルビ指定｜字《・》の連続に変換するシェルスクリプト。

## 概要
- 対象のファイル1つを引数に取る(変換対象ファイル)
- 任意の1文字を引数に取る(傍点文字)
- 一般的な傍点(圏点)指定マークアップである`《《親文字》》`を変換対象部分とする。
- 一般的なルビ指定マークアップである`｜親文字《傍点文字》`の*連続*を変換先とする
- `《《親文字》》`→`｜親文字《点》`×親文字すべてが指定されるまで反復、に置換する(モノルビにする)  

ための置換スクリプトです。

## 何に使うの？
Pixiv小説などのいくつかの文章掲載サイトでは、  
`｜《》`をルビ表示に変換する機能はあっても、  
`《《》》`を圏点(傍点)として変換する機能がない。  
圏点指定をルビ指定に変換することで、そうしたサイトに圏点(傍点)を表示できるようにする。

## ただの正規表現置換で良いのでは？

> 《《親文字》》  

を、グループルビである  

> ｜親文字《・・・》  

に変換することは正規表現で容易に達成できるが、  
これをモノルビ指定つまり  

> ｜親《・》｜文《・》｜字《・》  

へ変換することは難しい(どんな文字数にも対応するにはロジックに頼る必要がある)。  
これに対応するためのもの。

## モノルビに意味が？

サイトで適用されているスタイルによっては、親文字に対する傍点文字(`・`とか)の連続によるルビ文字指定は、親文字1文字に正しい位置に付かないことがある。  
特に、全角半角混じりの場合。  
モノルビ指定にすると、それをほぼ回避できる。

## なんでbashでやるの
文書の変換は時代によって変化するものではないので、枯れた技術で長く動く方が良いと考えたため。

## 名前？
ぼくはリグルくんが好きです。

---

## 対応しないこと・前提
- 傍点(圏点)の指定は、入れ子指定されない前提
  - 傍点指定の中にある文字は全て親文字とみなす
  - `《《文字《《文字》》文字》》`とかなっててもエラー化しません
- Debian:11
  - ChromeOS:103.0.5060のCrostini
- GunBash:5.1.4
- POSIX中心までは考えてない

## 処理概要
1. 関数宣言
   1. `置換元文字列群作成`関数
      1. 引数:標準入力
      2. 出力:標準出力
      3. 処理:
         1. grep検索
            1. 検索文字列:`《《[^《》]+》》`
            2. オプション:
               1. -E:拡張正規表現
               2. -o:行単位に出力
         2. 重複削除uniq
         3. 出来上がった文字列を標準出力へ
   2. `置換先文字列群作成`関数
      1. 引数:標準入力
      2. 出力:標準出力
      3. 処理:
         1. 引数文字列を1行毎に処理
            1. `《《`と`》》`を除去
            2. 出来上がった文字全体を1文字ごとに処理
               1. `字`を`｜字《傍点文字》`に置換
         2. 出来上がった文字列全体を標準出力へ
   3. `中間シェル前半作成`関数
      1. 引数:標準入力
      2. 出力:標準出力
      3. 処理:
         1. 引数文字列を1行毎に処理
            1. 先頭に`| sed -e s/`を付与
         2. 出来上がった文字列全体を標準出力へ
   4. `中間シェル後半作成`関数
      1. 引数:標準入力_文字列
      2. 出力:標準出力
      3. 処理:
         1. 引数文字列を1行毎に処理
            1. 末尾に`/g' \`を付与
         2. 出来上がった文字列全体を標準出力へ
2. 主処理
   1. チェック
      1. 引数1:入力ファイル
         1. 入力ファイルが存在しない場合エラー
      2. 引数2:傍点文字
         1. 傍点文字の長さが2以上の場合、エラー
   2. 事前処理
      1. 引数1:入力ファイルの文字コードを判定
         1. SJISの場合、UTF8に変換して作業ファイルへ出力
         2. UTF8の場合、そのまま作業ファイルへ出力
      2. 引数2:傍点文字が空あるいは与えられていない場合
         1. 傍点文字は`・`とする
      3. 出力先ファイルを作成する
         1. `入力ファイル名の拡張子の手前` + '_moe.txt'
   3. 変換処理
      1. 作業ファイルを入力する
      2. └パイプライン:`置換元文字列群作成`関数
      3. └をパイプライン:`置換先文字列群作成`関数
      4. └パイプライン:`中間シェル.sh`作成
         1. 置換基文字列と置換先文字列を横方向へ結合する
      5. └パイプライン:`中間シェル`の加工
         1. └パイプライン:ファイル先頭に、`cat 作業ファイル \`を付与
         2. └パイプライン:ファイル末尾に、`> 中間シェル.sh`
         3. 以下のようになる 
            ```
            cat 作業ファイル \
            | sed -e 's/《《親文字》》/｜字《点》｜字《点》｜字《点》/g' \
            | sed -e 's/《《親文字》》/｜字《点》｜字《点》/g' \
            …
            >  中間シェル.sh   
            ```
      6. `中間シェル`を実行 >標準出力`出力ファイル`
   4. 終了処理
      1. 中間ファイルを削除する
      2. 中間シェルを全て削除する
