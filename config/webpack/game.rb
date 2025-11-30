# 1〜100の数字の中から、隠された正解（secret）を当てるゲームです
secret = rand(1..100) # 1〜100の中でランダムに正解が決まる
count = 0             # 何回間違えたか数える

puts "1〜100の数字を当ててみて！"

# loop do は「break」と言うまで無限に繰り返すループです
loop do
  print "数字を入力 > "
  input = gets.to_i # キーボードからの入力を数字として受け取る
  count = count + 1 # 回数を1増やす

  if input == secret
    puts "正解！ #{count}回目で当たりました！"
    break # ループを抜ける（ゲーム終了）

elsif input > secret       # もし、入力した数字(input)が正解(secret)より大きかったら
    puts "もっと小さいよ！"   # ヒントを出す
  elsif input < secret       # もし、入力した数字(input)が正解(secret)より小さかったら
    puts "もっと大きいよ！"   # ヒントを出す
  
  # ↓↓↓ ここにロジックを書いてみよう ↓↓↓
  # ヒント：
  # 入力した数字(input)が、正解(secret)より「大きかったら」...
  # 入力した数字(input)が、正解(secret)より「小さかったら」...
  # それぞれヒントを出してあげてください。
  
  
  
  # ↑↑↑ ここまで ↑↑↑
  end
end