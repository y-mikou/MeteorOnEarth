#!/bin/bash
export lang=ja_jp.utf-8

tgtFile=${1}   #引数で指定されたファイルを対象とする
chrEmph=${2}   #引数で指定された文字を傍点文字とする

#chrset=$(file -i ${tgtFile})

#############################################################
# 関数宣言部
#############################################################

# 置換元文字列群作成
# 入力文字の中から《《…文字列…》》を検索し結果を列方向に並べる
function pckTgtStr () {
  #パイプでも標準入力でも
  if [ -p /dev/stdin ]; then
      if [ "`echo $@`" == "" ]; then 
          __str=`cat -`
      else
          __str=$@
      fi
  else
      __str=$@
  fi

  # 処理
    echo "${__str}" \
  | grep -E -o "《《[^》]+》》"  \
  | uniq
}

# 置換先文字列群作成
# 入力文字をモノルビへ変換する
function mkDstStr () {
  #パイプでも標準入力でも
  if [ -p /dev/stdin ]; then
      if [ "`echo $@`" == "" ]; then 
          __str=`cat -`
      else
          __str=$@
      fi
  else
      __str=$@
  fi

  # 処理
    echo "${__str}" \
    | sed -e 's/《《//g' \
    | sed -e 's/》》//g' \
    | while read line || [ -n "${line}" ]; do
          echo "${line}" \
        | sed -e 's/\(.\)/｜\1《'${chrEmph}'》/g'
      done
}

#############################################################
# メイン
#############################################################

# チェック #################################################
if [ ! -e ${tgtFile} ]; then
  echo "💩 そんなファイルいないです"
  exit 1
fi

#入れ子検知チェックをいれる

if [ ${#chrEmph} -eq 0 ]; then
  echo "🍕 第2引数がないので傍点文字は「・」になります"
  chrRby='・'
fi

if [ ! ${#chrEmph} -eq 1 ]; then
  echo "🍕 傍点文字は1文字にしてください"
  exit 1
fi

# 入力ファイルがSJISだったら、UTF8に変換する
if [ "${chrset##*charset=}" = "unknown-8bit" ]; then
  iconv -f SHIFT_JIS -t UTF-8 "${tgtFile}" >tmp1_moe
else
  cat "${tgtFile}" >tmp1_moe
fi
# 後続処理ファイルはtmp1_moe

# 前処理 #################################################

#出力ファイルの指定する
dstFile=${tgtFile/".txt"/"_moe.txt"}
touch ${dstFile}

## 変換処理 #############################################

cat tmp1_moe | pckTgtStr >tgtStr_moe
cat tgtStr_moe | mkDstStr >dstStr_moe

paste -d / tgtStr_moe dstStr_moe \
  | sed -e 's/^/\| sed -e '\''s\//' \
  | sed -e 's/$/\/g'\'' \\/g' \
  | sed -z 's/^/cat tmp1_moe \\\n/g' \
  | sed -z 's/$/>'${dstFile}' \n/g' \
  > tmp_moe.sh

bash tmp_moe.sh

echo "✨ "${destFile}"を出力しました[傍点をルビに]"

# 後処理 #################################################
pth=$(pwd)
rmstrBase='rm -rf '${pth}'/'
eval $rmstrBase'*_moe'
eval $rmstrBase'tmp_moe.sh'
exit 0
