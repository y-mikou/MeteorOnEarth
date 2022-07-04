# MeteorOnEarth

## これはなに？
- 対象のファイル1つを引数に取る。
- 一般的な傍点(圏点)指定マークアップである`《《基底文字》》`を変換対象部分とする。
- 一般的なルビ指定マークアップである`｜基底文字《ルビ文字》`の*連続*を変換先とする
- `《《基底文字》》`→`｜基底文字の内1文字《・》`×基底文字すべてが指定されるだけに置換する(モノルビにする)

ための置換スクリプトです。

## 何に使うの？
Pixiv小説などのいくつかの文章掲載サイトでは、`｜《》`をルビ表示に変換する機能はあっても、`《《》》`を圏点(傍点)として変換する機能がない。

圏点指定をルビ指定に変換することで、そうしたサイトに圏点(傍点)を表示できるようにする。

## ただの正規表現置換で良いのでは？

> 《《基底文字》》

を

> ｜基底文字《・・・・》

に変換することは正規表現で容易に達成できるが、

これをモノルビ指定つまり

> ｜基《・》｜底《・》｜文《・》｜字《・》

へ変換することは難しい(どんな文字数にも対応するにはロジックに頼る必要がある)。

これに対応するためのもの。

## モノルビに意味が？

サイトで適用されているスタイルによっては、基底文字に対する「・」連続によるルビ文字指定は、基底文字1文字に正しい位置に付かないことがある。

モノルビ指定にすると、それをほぼ回避できる。

## 名前？
ぼくはリグルくんが好きです。
