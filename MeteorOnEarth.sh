さくせいちゅうです！

#!/bin/bash
export lang=ja_jp.utf-8

tgtFile=${1}   #引数で指定されたファイルを対象とする
chrset=$(file -i ${tgtFile})

if [ ! -e ${1} ]; then
  echo "💩 そんなファイルいないです"
  exit 1
fi

if [ "${chrset##*charset=}" = "unknown-8bit" ]; then
  iconv -f SHIFT_JIS -t UTF-8 ${tgtFile} > tmp1_ltlbgtmp
  cat tmp1_ltlbgtmp >${tgtFile}
fi

destFile=${tgtFile/".txt"/"_rubied.txt"} #出力ファイルの指定する
touch ${destFile}                        #出力先ファイルを生成

