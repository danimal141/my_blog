---
title: Middleman+S3なブログを作ってサクッと移行してみた
date: 2014-05-04
---

今まではてなブログを使ってたけど、今回ノリで`middleman`でブログを作ったのでサクっと移行してみました。
理由としてはこんな感じ。

- 記事一覧と記事があるだけのシンプルなブログにしたかった
- とりあえず一度、`middleman`使ってみたかった
- S3でホスティングして、今流行りのAWSを使ってる感がほしかった

これだけだとちょっと情報量がツラいので、軽くどんな感じでやったかも書いておきます。

ちなみにソースも[Github上](https://github.com/danimal141/my_blog)に置いてます。


### プロジェクト作成
[ここ](http://middlemanapp.com/jp/basics/blogging/)見ながら進めれば問題ないかと思われます。

こんな感じでプロジェクトを作成して開発を進めていきます。

    $ middleman init my_blog --template=blog


あと自分はRubyのバージョン管理に`rbenv`を使ってるんですけど、毎回`bundle exec`つけてコマンド叩くのはウザいので、`rbenv-binstubs`を入れて初回の`bundle install`時に

    $ bundle install --binstubs=bin

みたいにしました。

`rbenv-binstubs`は

    $ brew install rbenv-binstubs

で入手できます。[こちらの記事](http://qiita.com/naoty_k/items/9000280b3c3a0e74a618)を真似しただけです、はい。

### タスク管理
一人で開発するとはいえ、それなりに対応することも多かったのでタスク管理に[`trello`](https://trello.com/)を使用しました。

Todoを列挙して、対応中のものはDoing、対応済みのものはDoneといった具合にシンプルなタスク管理ができるので一人とか小規模で開発するときにわりとオススメです。

### template、CSSについて
templateは`slim`一択。設定はググれば情報出てくると思います。
自分は[こちらの記事](http://re-dzine.net/2014/01/middleman-slim/)を参考にさせて頂きました。

CSSはできるだけ記述少なくしたかったので`sass`使ってます。
あと最近よく聞く[SMACSS](http://smacss.com/), [BEM](http://bem.info/)を意識するようにしてみました。
ファイル構成はこんなかんじで、SMACSSぽく役割分担。`application.css.sass`で全部importするので基本partial。

    ./source/stylesheets
    ├── _base.css.sass
    ├── _helper.css.sass
    ├── _layout.css.sass
    ├── _variables.css.sass
    ├── application.css.sass
    └── modules
        ├── _article-content.css.sass
        ├── _article.css.sass
        ├── _disqus.css.sass
        ├── _gl-footer.css.sass
        ├── _gl-header.css.sass
        ├── _pagination.css.sass
        └── _social-btns.css.sass


クラスの命名規則はなるべくBEMに準拠するようにしてます。`.article`のElementは`.article__item`みたいな。
正直、今回わざわざBEM導入するような規模じゃないんですけどBEM依存症の自分は気づいたらこの命名規則になってました。もっとBEM極めたい。

ちなみにデザイン考えるのはキツかったので、自分がエディタのカラースキームに使ってる`solarized`の色をそのまま[ここ](http://thomasf.github.io/solarized-css/)から拝借して使いました。デザイン自分でするのはツラいって人にオススメ。

### コメント欄の設置
迷わず[`disqus`](http://disqus.com/)を使いました。ユーザー登録を済ませたら、あとは[`middleman-disqus`](https://github.com/simonrice/middleman-disqus)というgemがあったのでこいつを追加

    gem 'middleman-disqus'

`config.rb`に先ほど登録したユーザー名を入れて

    activate :disqus do |d|
        d.shortname = 'ユーザー名'
    end

あとはコメント欄を設置したい場所に

    = disqus

としてやれば問題なく設置できました。

これに関しては[こちらの記事](http://nmbr8.com/blog/2014/02/23/middleman_foundation_s3-7/)が激アツでした。ありがとうございます！！

### ソーシャルボタンの設置
とりあえずFacebook、Twitter、はてブのボタンを設置しました。

FB用に基本的なOGPタグも設定して、[debugger](https://developers.facebook.com/tools/debug/)でアラートが出ないかだけ軽くチェック（なんかバグってたら教えてください。。）
あと最近はTwitterもFBのOGPと似た`twitter:cards`なるものを設定できるらしいので、[こちらの記事](http://smmlab.aainc.co.jp/?p=18753)を参考に設定してみました。

#### 問題点
FBのlikeボタンなんですが、ブラウザの`history back`でページを行ったり来たりしてるとボタンが崩れ、`fb:like failed to resize in 45s`というエラーメッセージとともにボタンが45秒後に消え失せるバグが発生しました。(これchromeだけかも)

回避策として以下のように`facebook.js.coffee`を作成して、

    window.onload = ->
        loadFacebookSDK()

    loadFacebookSDK = ->
        url = '//connect.facebook.net/en_US/all.js#xfbml=1'
        window.fbAsyncInit = initializeFacebookSDK
        $.getScript url, ->
          FB?.XFBML.parse()

    initializeFacebookSDK = ->
        FB.init
        appId     : '俺のapp_id'
        channelUrl: 'http://danimal141.net'
        status    : true
        cookie    : true
        xfbml     : true

`window.onload`のタイミングで読むようにしたらとりあえず直りました(`DocumentContentLoaded`のタイミングだとボタン崩れました）。でもその分ロードが遅くなるのであまり良い方法ではないと思います。

これ他にも悩んでる人結構いるっぽかったのですが、[この記事](http://stackoverflow.com/questions/20449947/facebook-like-box-disappearing-after-45-seconds)みたいにCSSで`!important`つかって無理やりサイズ固定しろみたいな方法しか見つかりませんでした。Facebook側の修正を気長に待つ感じですかねぇ。。

余談ですが、たかがFacebookのscriptロードするためだけに`jquery`をまるごと読み込むのは悔しいです。
そこで[`jquery-builder`](http://projects.jga.me/jquery-builder/)をつかって`ajax`に必要な部分のみをダウンロードし、そいつを`application.js`からrequireするようにしました。サイズ大分違ってくると思うのでオススメ。

### Google Analyticsの導入
まず[`本家`](http://www.google.com/analytics/)にログインして自分のサイトを登録。
で、[`middleman-google-analytics`](https://github.com/danielbayerlein/middleman-google-analytics)というgemがあるのでそいつを入れてREADMEの通りに`config.rb`に設定を記述。

    configure :development do
      activate :google_analytics do |ga|
        ga.tracking_id = false
      end
    end

    configure :build do
      activate :google_analytics do |ga|
        ga.tracking_id = 'UA-XXXXXXX-X'
      end
    end

あとは`layout`の任意の場所で

    = google_analytics_tag

としてやればGAのJS読み込んでくれます。

あとこれは実際にサイトを運営し始めてからになると思いますが、自分のアクセスが毎回カウントされるのはツラいので自分のアクセスを除外する設定をGA側で設定します。
[こちらの記事](http://11dax.com/google-analytics-2-460.html)を参考にさくっと設定しました。

### sitemap.xmlの作成
GAの設定につづいて[ウェブマスターツール](https://www.google.com/webmasters/tools/home?hl=ja)の設定をしました。`sitemap.xml`を登録しなければいけないので作成します。

[`middleman-sitemap`](https://github.com/pixelpark/middleman-sitemap)と[こちらの記事](http://qiita.com/youcune/items/71e18e7bd5219b4a07f8)を参考にこんな感じで作成しました。


    xml.instruct!
    xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
      sitemap.resources.each do |resource|
        xml.url do
          xml.loc "#{data.site.url}#{resource.url}"
        end if resource.destination_path =~ /\.html$/
      end
    end

これをウェブマスターツール側でサイトマップとして登録すればOK。

ついでに`robots.txt`も以下のように作成しておきました。

    User-agent: *
    Sitemap: http://danimal141.net/sitemap.xml


### デプロイ
今回、自分は[AWS](https://aws.amazon.com/jp/)のS3でホスティング、[お名前.com](http://www.onamae.com/)でドメインをとってそれをRoute53で管理する感じで運営しています。
この設定に関しては[こちらの記事](http://nmbr8.com/blog/2014/03/26/middleman_foundation_s3-9/)がもはやすべてを物語っていたので、これを参考にすれば十分かと。

ただお名前⇔Route53間の設定は上記の記事で書かれていなかったので、[こちらの記事](http://tech.tanaka733.net/entry/2013/09/15/%E3%81%8A%E5%90%8D%E5%89%8D.com_%E3%81%A7%E5%8F%96%E3%81%A3%E3%81%9F%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E3%82%92_Amazon_Route53%E3%81%A7%E7%AE%A1%E7%90%86%E3%81%97%E3%80%81%E3%82%B5%E3%83%96%E3%83%89)を参考にしました。

### まとめ
以上ざっくりですが、`middleman`を使ったブログ開発について書いてみました。
細かいとこ大分端折ってますが、`middleman`はわりと使っている方も多く、調べれば情報はそれなりに出てくるのでそこまで苦労しないかと思われます（Facebookのバグとか対応しきれてないけど。。）

今後はこちらでブログを更新していこうと思いますので、何卒よろしくお願いします<(_ _)>

### 参考

- [Middleman ブログ機能](http://middlemanapp.com/jp/basics/blogging/)
- [bundle execを使わずに済む方法（rbenv編）](http://qiita.com/naoty_k/items/9000280b3c3a0e74a618)
- [Middlemanで作ったブログのテンプレートエンジンをERBからSlimに](http://re-dzine.net/2014/01/middleman-slim/)
- [Middleman + Foundation + Amazon S3 でのBlogサイト構築(7)Blog記事の検索機能とコメント機能の追加](http://nmbr8.com/blog/2014/02/23/middleman_foundation_s3-7/)
- [【エンゲージメント率150%UPも！？】注目機能Twitter Cards！内容詳細と導入方法まとめ](http://smmlab.aainc.co.jp/?p=18753)
- [Facebook Like box disappearing after 45 seconds](http://stackoverflow.com/questions/20449947/facebook-like-box-disappearing-after-45-seconds)
- [Googleアナリティクスで自分のアクセスを除外する方法](http://11dax.com/google-analytics-2-460.html)
- [Middlemanでsitemap.xmlを生成する](http://qiita.com/youcune/items/71e18e7bd5219b4a07f8)
- [Middleman + Foundation + Amazon S3 でのBlogサイト構築(9)Amazon S3へのデプロイ](http://nmbr8.com/blog/2014/03/26/middleman_foundation_s3-9/)
- [お名前.com で取ったドメインを Amazon Route53で管理し、サブドメインをはてなブログに割り当てるまで](http://tech.tanaka733.net/entry/2013/09/15/%E3%81%8A%E5%90%8D%E5%89%8D.com_%E3%81%A7%E5%8F%96%E3%81%A3%E3%81%9F%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E3%82%92_Amazon_Route53%E3%81%A7%E7%AE%A1%E7%90%86%E3%81%97%E3%80%81%E3%82%B5%E3%83%96%E3%83%89)
