---
title: Railsのbefore_validationで文字列の先頭、末尾にある全角スペースを取り除く
date: 2014-05-19
---

`Strip#strip`を使うだけでは半角スペースとか改行文字しか取り除けないので、before_validation時に全角スペースを取り除く方法を考える。

ちなみにRubyは2.1.2、Railsは4.1.0を前提に書いてます。

###auto\_strip\_attributesの導入
[`auto_strip_attributes`](https://github.com/holli/auto_strip_attributes)というgemがあったのでとりあえず使ってみる。

Gemfileに書いて、`bundle install`する。

    gem "auto_strip_attributes", "~> 2.0"

こうやって使うっぽい。

    class User < ActiveRecord::Base

      # Normal usage where " aaa   bbb\t " changes to "aaa bbb"
      auto_strip_attributes :nick, :comment

      # Squeezes spaces inside the string: "James   Bond  " => "James Bond"
      auto_strip_attributes :name, :squish => true

      # Won't set to null even if string is blank. "   " => ""
      auto_strip_attributes :email, :nullify => false
    end

これだけでとりあえず半角スペースとかは消せそう。便利！でも全角スペースは消せない。

###strip\_full\_width\_spaceフィルターを追加する
[lib/auto\_strip\_attributes.rb](https://github.com/holli/auto_strip_attributes/blob/master/lib/auto_strip_attributes.rb)をみた感じ、`set_filter`で独自フィルターをつくって`setup`で追加できるっぽかったのでつくってみる。

ちょうど[こちら](http://d.hatena.ne.jp/ria10/20131019/1382169233)で「まさにこれです！」って感じの実装されている方がいたので参考にさせていただきました。

`config/initializers/`に`auto_strip_attributes.rb`をつくって以下のようにする。

    AutoStripAttributes::Config.setup do
      set_filter strip_full_width_space: false do |value|
        unless value.nil? || !value.is_a?(String)
          value.remove(/\A[\s　]+|[\s　]+\Z/)
        end
      end
    end

`set_filter strip_full_width_space: false do`のとこでデフォルト`false`でフィルターを追加する。指定時に`strip_full_width_space: true`にしてやればセットできるようになる。(`auto_strip_attributes.rb`に`next unless options[filter_name]`って書いてあって、`false`の場合は飛ばされてる）

`value.remove`は[`active_support/core_ext/string/filters.rb`](https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/string/filters.rb)に書いてあるやつ。`gsub pattern, ''`をちょっと短く書ける。

正規表現`/\A[\s　]+|[\s　]+\Z/`の`\A`と`\Z`は文字列の先頭と末尾を表す。[こちらの記事](http://blog.tokumaru.org/2014/03/z.html)にあるように`^`と`$`をRubyで使うのは危険だったりするらしい。自分はJavaScriptを主に書いていた人間なのでこういう違いには注意しないと。。

`[\s　]`は半角スペースOR全角スペースどちらかにマッチ。カッコ内のどれか一文字という意味になる。（この場合、半角スペースは要らないか。。）

###モデル側でフィルターを使用する
    class User < ActiveRecord::Base

      auto_strip_attributes :nick, :comment, strip_full_width_space: true

    end

これで例えば`:nick`が`　ほげ　`とかだったらちゃんと`ほげ`にしてくれる。

###まとめ
わざわざgemいれなくてもできそうですが、こんな感じで全角スペースの削除ができました。

`auto_strip_attributes.rb`のコードは短くて読みやすかったのでRubyの勉強にもなりました。

###参考
- [holli/auto\_strip\_attributes](https://github.com/holli/auto_strip_attributes)

- [Railsでバリデーション前に文字列の前後のスペースやタブを取り除くメモ](http://d.hatena.ne.jp/ria10/20131019/1382169233)

- [正規表現によるバリデーションでは ^ と $ ではなく \A と \z を使おう](http://blog.tokumaru.org/2014/03/z.html)
