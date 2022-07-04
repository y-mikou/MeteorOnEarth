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


##《《基底文字》》を一旦｜基底文字《基底文字》にする。

cat tgtFile >emphasisInput_ltlbgtmp
cat emphasisInput_ltlbgtmp \
| grep -E -o "《《[^》]+》》"  \
| uniq \
>tgt_ltlbgtmp

  ## 中間ファイルreplaceSeed(《《[^》]*》》で抽出したもの)の長さが0の場合、処理しない
  if [ -s tgt_ltlbgtmp ]; then 

    # 圏点の基底文字列のみの中間ファイルを作成する

    # ルビとして振る「﹅」を、rawと同じ文字だけもった中間ファイルを作成する。
    # [^字^](回転)、[l\[左右\]r\](強制合字)、^^(縦中横)、~~(自動縦中横)は
    # 傍点観点では1文字として扱う。
    cat raw_ltlbgtmp \
    | sed -e 's/\*\*//g' \
    | sed -e 's/゛//g' \
    | sed -e 's/\[\^.\^\]/﹅/g' \
    | sed -e 's/\[l\[..\]r\]/﹅/g' \
    | sed -e 's/\^.\{1,3\}\^/﹅/g' \
    | sed -e 's/~.\{2\}~/﹅/g' \
    | sed -e 's/./﹅/g' \
    >emphtmp_ltlbgtmp
  
    # 上記で作った基底文字ファイルとルビ文字ファイルを列単位に結合する
    # その後、各行ごとに置換処理を行い、
    # 中間ファイルtgtの各行を置換元とする置換先文字列を作成する。
    ## →置換先文字列
    ## 　各行ごとに「,」の前が基底文字、「,」の後がルビ文字となっているので、
    ## 　これを利用してルビタグの文字列を作成する。
    paste -d , raw_ltlbgtmp emphtmp_ltlbgtmp \
    | while read line || [ -n "${line}" ]; do 

      echo "${line##*,}" \
      | grep -E -o . \
      | sed -e 's/^/<ruby class=\"ltlbg_emphasis\" data-emphasis=\"/' \
      | sed -e 's/$/\">/' \
      >1_ltlbgtmp

      echo "${line%%,*}" \
      | grep -E -o "(\[\^.\^\]|\^[^\^]+\^|\~[^~]{2}\~|<[^>]>[^<]+<\/>|\{[^｜]\+｜[^\}]\+\}|.゛|.)" \
      >2_ltlbgtmp

      echo "${line##*,}" \
      | grep -E -o "." \
      | sed -e 's/^/<rt>/g' \
      | sed -e 's/$/<\/rt><\/ruby>/g' \
      >3_ltlbgtmp

      paste 1_ltlbgtmp 2_ltlbgtmp 3_ltlbgtmp \
      | sed -e 's/\t//g' \
      | sed -z 's/\n//g' \
      | sed -e 's/\//\\\//g' \
      | sed -e 's/\"/\\\"/g' \
      | sed -e 's/\[/\\\[/g' \
      | sed -e 's/\]/\\\]/g' \
      | sed -e 's/\^/\\\^/g' \
      | sed -e 's/\*/\\\*/g' \
      | sed -e 's/$/\/g'\'' \\/'

      echo ''
      done \
    >rep_ltlbgtmp

    cat tgt_ltlbgtmp \
    | sed -e 's/\//\\\//g' \
    | sed -e 's/\"/\\\"/g' \
    | sed -e 's/\[/\\\[/g' \
    | sed -e 's/\]/\\\]/g' \
    | sed -e 's/\^/\\\^/g' \
    | sed -e 's/\*/\\\*/g' \
    | sed -e 's/^/\| sed -e '\''s\//' \
    | sed -e 's/$/\//g' \
    >replaceSeed_ltlbgtmp
    
    paste replaceSeed_ltlbgtmp rep_ltlbgtmp \
    | sed -e 's/\t//g' \
    | sed -z 's/^/cat emphasisInput_ltlbgtmp \\\n/' \
    >tmp.sh
    bash  tmp.sh >tmp1_ltlbgtmp

    cat tmp1_ltlbgtmp \
    | sed -e 's/<ruby class=\"ltlbg_emphasis\" data-emphasis=\"﹅\">〼<rt>﹅<\/rt><\/ruby>/<span class=\"ltlbg_wSp\"><\/span>/g' \
    | sed -e 's/<ruby class=\"ltlbg_emphasis\" data-emphasis=\"﹅\">〿<rt>﹅<\/rt><\/ruby>/<span class=\"ltlbg_sSp\"><\/span>/g' \
    | sed -e 's/<ruby class=\"ltlbg_emphasis\" data-emphasis=\"﹅\">\([\*\^\~]\?\)<rt>﹅<\/rt><\/ruby>/\1/g' \
    >tmp2_ltlbgtmp
    cat tmp2_ltlbgtmp >emphasisOutput_ltlbgtmp
  else
    cat emphasisInput_ltlbgtmp >emphasisOutput_ltlbgtmp
  fi
  cat emphasisOutput_ltlbgtmp \
  >tmp1_ltlbgtmp
