---
title: Rubyのビット演算子、論理演算子について
date: 2014-06-28
---

Rubyの論理演算子、ビット演算子についてメモ。

### 論理演算子
一番よく使うやつ。

Rubyの論理積、論理和って`true`、`false`じゃなくてオペランドのどちらかを返す。短絡評価。（片方を評価して結果がわかったら、もう片方を評価せずに結果を返す）

論理積はどちらも真であることを期待するけど、例えば以下のような感じ。

    nil && 1 #=> nil

`nil`を評価した時点でどちらも真である希望はなくなるので、この時点で心折れて`nil`を返す。

    1 && nil #=> nil

とかであれば`1`を評価して真なので期待に胸をふくらませて次へ。
でも`nil`なので絶望にひたりながら`nil`を返す。

論理和の場合はどちらかが真であればいいので

    nil || 1 #=> 1
    1 || nil #=> 1

となる。

### ビット演算子
個人的には普段、あまり使わないかも。

整数の２進表現をビットの列として演算を行う。

ビット積はどちらも1の場合のみ1、それ以外は0になるので

    1 & 2 #=> 0

となる。(1は2進数で01、2は2進数で11）

ビット和はどちらかが1なら1になるので

    1 | 2 #=> 3

### Arrayでビット演算子を使う場合
これ、最近まで知らなかったやつ。地味に使えそう。

`Array`には `&`、`|`っていうメソッドが定義されてるぽい。`Array.instance_methods`やったらちゃんとこいつら出てくる。

`&`は2つの配列を評価して重複する要素を新しい配列に入れて返す。イメージ通り。

    [1, 2, 3] & [2, 4, 6] #=> [2]

`|`は2つの配列を合わせて、重複を取り除いてから返す。

    [1, 2, 3] | [2, 4, 6] #=> [1, 2, 3, 4, 6]

### まとめ
`Array`のビット演算子、積極的に使っていきたい。

### 参考
- [Rubyのビット演算子でarrayを操作する](http://techracho.bpsinc.jp/hachi8833/2014_05_04/17084)