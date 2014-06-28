---
title: Railsにdraper導入してイジってたらstack level too deepしてしまった
date: 2014-06-29
---

`draper`の導入に関しては[公式のREADME](https://github.com/drapergem/draper)や[こちらの記事](http://morizyun.github.io/blog/draper-ruby-gem-code-clear/)を見てもらうとして、今回やらかした内容をメモしておく。

### やったこと
例えばブログのアプリケーション作ってるとして、記事の作成日時をちょっといい感じに調整してView側で表示したいとする。

`draper`によって`Decorator`が使えるようになるので

    rails g decorator article

する。

`articles_controller`に`show`アクションを定義。`Article`モデルもある前提。

    def show
      @article = Article.find(params[:id]).decorate
    end

`article_decorator`に`created_at`メソッドを定義。

    class ArticleDecorator < Draper::Decorator
      delegate_all

      def created_at
        self.created_at.strftime('%Y.%m.%d')
      end
    end

これをView側`articles/show.html.slim`とかで呼び出す。

    p = @article.created_at

はい、これで詰み。

めでたく`stack level too deep`というエラーが発生する。

### 対応
これ、`self.created_at`ってやったのが問題でした。

もともと`@article`は`created_at`持ってるし、今回`decorator`でも`created_at`定義しちゃってるし、どっちの`created_at`かわからず輪廻してしまうのが原因っぽかった。

最初`created_at`っていう名前が良くないのかなー？名前変えればうまくいくしなーって思ってたんだけど、全くそういうわけではなかった。

危うく間違った理解で済ませるとこでした。。


    class ArticleDecorator < Draper::Decorator
      delegate_all

      def created_at
        object.created_at.strftime('%Y.%m.%d')
      end
    end

ってすれば`object`が元のモデルを指すのでうまくいく。`object`の代わりに`model`でも良い。

### まとめ
ちゃんと使い方確認してからメソッド書きましょう。反省。。

でも`stack level too deep`ってちょっとカッコいいやん。

### 参考
- [Draperで驚くほどRailsコードがわかりやすくなったよ！](http://morizyun.github.io/blog/draper-ruby-gem-code-clear/)
- [drapergem/draper](https://github.com/drapergem/draper)
