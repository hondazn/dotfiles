#!/usr/bin/env bash

# 色の定義
COLOR_B="\033[38;5;33m"   # b: #3399ff
COLOR_A="\033[38;5;35m"   # a: #53C670
COLOR_G="\033[38;5;29m"   # g: #39ac56
COLOR_H="\033[38;5;23m"   # h: #33994d
COLOR_I="\033[38;5;23;48;5;29m"  # i: fg=#33994d, bg=#39ac56
COLOR_J="\033[38;5;35;48;5;23m"  # j: fg=#53C670, bg=#33994d
COLOR_K="\033[38;2;38;156;112m"   # k: #269C70
RESET="\033[0m"           # リセット

# アスキーアートの定義
ART=(
    "  ███       ███  "
    "  ████      ████ "
    "  ████     █████ "
    " █ ████    █████ "
    " ██ ████   █████ "
    " ███ ████  █████ "
    " ████ ████ ████ "
    " █████  ████████ "
    " █████   ███████ "
    " █████    ██████ "
    " █████     █████ "
    " ████      ████ "
    "  ███       ███  "
    "                    "
    "  N  E  O  V  I  M  "
)

# 色分けルールの定義
# 各行の各文字に対して色を指定する
COLOR_RULES=(
    "  KKKKA       GGGG  "  # 1行目
    "  KKKKAA      GGGGG "  # 2行目
    " B KKKAAA     GGGGG "  # 3行目
    " BB KKAAAA    GGGGG "  # 4行目
    " BBB KAAAAA   GGGGG "  # 5行目
    " BBBB AAAAAA  GGGGG "  # 6行目
    " BBBBB AAAAAA IGGGG "  # 7行目
    " BBBBB  AAAAAAHIGGG "  # 8行目
    " BBBBB   AAAAAJHIGG "  # 9行目
    " BBBBB    AAAAAJHIG "  # 10行目
    " BBBBB     AAAAAJHI "  # 11行目
    " BBBBB      AAAAAJH "  # 12行目
    "  BBBB       AAAAA  "  # 13行目
    "                    "  # 14行目
    "  A  A  A  B  B  B  "  # 15行目
)

# 色を適用する関数
colorize() {
    local line="$1"
    local rules="$2"
    local colored_line=""
    for (( i=0; i<${#line}; i++ )); do
        char="${line:$i:1}"
        rule="${rules:$i:1}"
        case "$rule" in
            "B") colored_line+="${COLOR_B}${char}${RESET}" ;;
            "A") colored_line+="${COLOR_A}${char}${RESET}" ;;
            "G") colored_line+="${COLOR_G}${char}${RESET}" ;;
            "H") colored_line+="${COLOR_H}${char}${RESET}" ;;
            "I") colored_line+="${COLOR_I}${char}${RESET}" ;;
            "J") colored_line+="${COLOR_J}${char}${RESET}" ;;
            "K") colored_line+="${COLOR_K}${char}${RESET}" ;;
            *) colored_line+="${char}" ;;  # 色指定がない場合はそのまま
        esac
    done
    echo -e "$colored_line"
}

# アスキーアートを出力
output=""
for (( i=0; i<${#ART[@]}; i++ )); do
    output+="$(colorize "${ART[$i]}" "${COLOR_RULES[$i]}")"
	if [ $i -ne $((${#ART[@]}-1)) ]; then
		output+="\n"
	fi
done
echo -e "$output"
