#!/bin/bash

# 格言リスト
# 各要素は「日本語\n英語\n人物名」の形式で記述します。
# 新しい格言を追加する場合は、このリストに追記してください。
quotes=(
  "明日死ぬかのように生きよ。永遠に生きるかのように学べ。\nLive as if you were to die tomorrow. Learn as if you were to live forever.\n- Mahatma Gandhi"
  "あなたの時間は限られている。だから他人の人生を生きたりして無駄に過ごしてはいけない。\nYour time is limited, so don't waste it living someone else's life.\n- Steve Jobs"
  "知は力なり。\nKnowledge is power.\n- Francis Bacon"
  "人生は自転車のようなものだ。バランスを保つためには、動き続けなければならない。\nLife is like riding a bicycle. To keep your balance, you must keep moving.\n- Albert Einstein"
  "我々は全員ドブの中にいる。でも、そこから星を眺めている奴だっているんだぜ。\nWe are all in the gutter, but some of us are looking at the stars.\n- Oscar Wilde"
  "速さも大事だが、正確さがすべてだ。\nFast is fine, but accuracy is everything.\n- Wyatt Earp"
  "幸福は旅の途中にあるものであり、目的地ではない。\nHappiness is a journey, not a destination.\n- Alfred D. Souza"
  "成功は最終的なものではなく、失敗も致命的なものではない。重要なのは続ける勇気だ。\nSuccess is not final, failure is not fatal: It is the courage to continue that counts.\n- Winston Churchill"
  "あなたができると思うこと、できないと思うこと、どちらも正しい。\nWhether you think you can or you think you can't, you're right.\n- Henry Ford"
  "他人から常軌を逸していると思われるようなことをやっていないとしたら、あなたは間違っている。\nIf you're not doing something that seems crazy to others, you're doing it wrong.\n- Larry Page"
  "行動がすべてを変える。\nAction is the foundational key to all success.\n- Pablo Picasso"
  "唯一の真の英知は、自分が何も知らないということを知ることである。\nThe only true wisdom is in knowing you know nothing.\n- Socrates"
  "信じると捨てることは同じこと。\nTo believe and to let go are one and the same.\n- Shigeru Akagi (Akagi)"
  "お前を信じる俺を信じろ。\nBelieve in the me that believes in you.\n- Kamina (Tengen Toppa Gurren Lagann)"
  "お前がどれだけ軽い銃を使おうが知ったこっちゃ無いが、俺に言わせりゃロマンに欠けるな。\nI don't give a damn how light a gun you use, but to me, it lacks a philosophy.\n- Daisuke Jigen (Lupin the Third)"
  "誠実な人はいつも孤独なものなのよ\nHonest men are always lonely.\n- Maria Di Vita (Nuovo Cinema Paradiso)"
  "今を生きよ。\nCarpe diem.\n- Horace"
  "フォースと共にあらんことを。\nMay the Force be with you.\n- Star Wars"
  "好きなことを仕事にすれば、一生働かなくてすむ。\nChoose a job you love, and you will never have to work a day in your life.\n- Confucius"
  "かけがえのない人間になるためには、常に他人と違っていなければならない。\nIn order to be irreplaceable one must always be different.\n- Coco Chanel"
  "幸運とは、準備と機会が出会うことである。\nLuck is what happens when preparation meets opportunity.\n- Seneca"
  "失敗を成し遂げなければならない。\nYou have to achieve failure.\n- Tom Platz"
)

# 格言の総数を取得
num_quotes=${#quotes[@]}

# 0から (総数-1) までのランダムなインデックスを生成
index=$(($RANDOM % num_quotes))

# ランダムに選ばれた格言を出力
# -e オプションで \n (改行) を解釈させる
echo -e "${quotes[$index]}"
