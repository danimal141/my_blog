---
title: Homebrewで特定バージョンのformulaに切り替える方法
date: 2014-05-14
---

Homebrewで古いバージョンの`imagemagick`を入れる必要に迫られたのでメモです。

### 現状確認
まず`brew update`をしてhomebrewをアップデートして、現状確認。

    $ brew update

    $ brew versions imagemagick

    imagemagick: stable 6.8.9-1 (bottled), HEAD
    http://www.imagemagick.org
    /usr/local/Cellar/imagemagick/6.8.9-1 (1432 files, 22M) *
    Poured from bottle
    From: https://github.com/Homebrew/homebrew/commits/master/Library/Formula/imagemagick.rb
    .
    .
    .

`6.8.9-1`が入ってます。

### 古いバージョンインストール
古いバージョンを確認。

    $ brew versions imagemagick
    6.8.9-1  git checkout 1e30cbf Library/Formula/imagemagick.rb
    6.8.8-9  git checkout b84f779 Library/Formula/imagemagick.rb
    6.8.7-7  git checkout e68e443 Library/Formula/imagemagick.rb
    6.8.7-0  git checkout 14a1fa8 Library/Formula/imagemagick.rb
    6.8.6-3  git checkout 870d5e9 Library/Formula/imagemagick.rb
    6.8.0-10 git checkout 321b293 Library/Formula/imagemagick.rb
    6.7.7-6  git checkout 7d951fb Library/Formula/imagemagick.rb
    6.7.5-7  git checkout f965101 Library/Formula/imagemagick.rb
    6.7.1-1  git checkout 5cce04d Library/Formula/imagemagick.rb
    6.6.9-4  git checkout 4e7c332 Library/Formula/imagemagick.rb
    6.6.7-10 git checkout 0476235 Library/Formula/imagemagick.rb
    6.6.7-8  git checkout db99927 Library/Formula/imagemagick.rb
    6.6.7-1  git checkout 7cd042f Library/Formula/imagemagick.rb
    6.6.4-5  git checkout 53886de Library/Formula/imagemagick.rb
    6.6.4-2  git checkout 2658d63 Library/Formula/imagemagick.rb
    .
    .
    .

この中から`6.8.7-7`をインストールします。

ここで普通に`brew install imagemagick`しても最新のやつぶっこまれます。
上記で各パージョンに対応した`git checkout`コマンドが表示されてるので、そいつを実行してそのバージョンの`imagemagick.rb`をcheckoutします。そうすれば`brew install imagemagick`でそのバージョンのをインストールできます。

    $ cd `brew --prefix` # 自分の場合は/usr/local
    $ git checkout 14a1fa8 /usr/local/Library/Formula/imagemagick.rb

    $ brew info imagemagick

    imagemagick: stable 6.8.7-7 (bottled), HEAD
    http://www.imagemagick.org
    /usr/local/Cellar/imagemagick/6.8.9-1 (1432 files, 22M) *
    Poured from bottle
    From: https://github.com/Homebrew/homebrew/commits/master/Library/Formula/imagemagick.rb
    .
    .
    .

stableが`6.8.7-7`にかわりました。

    # unlinkしてからじゃないと怒られるので注意
    $ brew install imagemagick

    Error: imagemagick-6.8.9-1 already installed
    To install this version, first `brew unlink imagemagick'

    $ brew unlink imagemagick
    $ brew install imagemagick

    $ brew info imagemagick

    imagemagick: stable 6.8.7-7 (bottled), HEAD
    http://www.imagemagick.org
    /usr/local/Cellar/imagemagick/6.8.7-7_1 (1431 files, 20M) *
    Poured from bottle
    /usr/local/Cellar/imagemagick/6.8.9-1 (1432 files, 22M)
    Poured from bottle
    From: https://github.com/Homebrew/homebrew/commits/master/Library/Formula/imagemagick.rb
    .
    .
    .

ちゃんと古いの入りました。

もし新しいほうを使うぞって場合は

    $ brew switch imagemagick 6.8.9-1

って感じでformulaとそのバージョンを指定して`brew switch`すればいいので問題ないです。

### アフターケア
このままにしておくと`/usr/local/`のほうで

    $ git status

    modified:   Library/Formula/imagemagick.rb

みたいになってます。

これ放置するとしばらく経ってから`brew update`でもするかーってなったとき先に「お前の変更コミットしてからにしろよ」みたいにはじかれます。
ここは本家とつながってます。

    $ git remote -v

    origin  https://github.com/Homebrew/homebrew (fetch)
    origin  https://github.com/Homebrew/homebrew (push)

あまりコミットとかする感じじゃないですね。

`/usr/local/Cellar/imagemagick/`にほしいバージョンが入りさえすれば問題ないので、元に戻しときます。

    $ git reset .
    $ git checkout .

ちなみにもう最新のもの以外は必要なくなったぜーって場合は

    $ brew switch imagemagick 6.8.9-1
    $ brew cleanup imagemagick

で最新のもの以外全部消滅します。事前に最新のバージョンにswitchしておく必要があるので注意。

### まとめ

自分はたまたま`imagemagick`でやりましたが、ほかのものでも同じ感じでできると思います。
もしもっと良い方法とかあれば、ぜひご教授くださいませ。

### 参考
[ gcatlin / gist:1847248](https://gist.github.com/gcatlin/1847248)
