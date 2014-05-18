---
title: Rails4.1プロジェクトにteaspoon入れたらエラー出たので調査した
date: 2014-05-18
---

Rails4.1のプロジェクトで`JavaScript`のテストをするために[`teaspoon`](https://github.com/modeset/teaspoon)を入れたらうまく動かなかったので調査。

Rails4.0で入れたときは問題なかったのに…ツラい。

###準備
まずは`Gemfile`に記述して

    group :development, :test do
      #ここにrspec関連とか書いてる。

      # js spec
      gem 'teaspoon'
      gem 'guard-teaspoon'
    end

`bundle install`する。

    $ bundle install

`CoffeeScript`使いたいので、`--coffee`をつけてインストール。

    $ rails g teaspoon:install --coffee

これであとは好きなように設定を書いて、`teaspoon`(人によっては`bundle exec teaspoon`）か`rake teaspoon`と打てば、テストを実行できる（はずだったんですよ！！）。詳しくはREADMEみてください。

余談ですが`Gemfile`で`group :development, :test do`ではなく、`group :test do`の中に書いていた場合、`undefined method 'setup' for Teaspoon:Module (NoMethodError)`とか出ると思うので注意。この[issue#96](https://github.com/modeset/teaspoon/issues/96)のやつです。今回テーマとしてるエラーとは別物。

###エラー発生
`config/initializers/teaspoon.rb`や`spec/teaspoon_env.rb`なども特に変更せず、`teaspoon`と打ってみたところこんな感じになりました。

    $ teaspoon

    Error: Sprockets::Rails::Helper::AssetFilteredError: Asset filtered out and will not be served: add `Rails.application.config.assets.precompile += %w( teaspoon.css )` to `config/initializers/assets.rb` and restart your server

Why？なぜprecompileの設定をせねばいかんのですか。

とりあえず従順に`config/initializers/assets.rb`をつくってリトライ。

    $ teaspoon

    Error: Sprockets::Rails::Helper::AssetFilteredError: Asset filtered out and will not be served: add `Rails.application.config.assets.precompile += %w( teaspoon-jasmine.js )` to `config/initializers/assets.rb` and restart your server

ふむ。リトライ。

    $ teaspoon

    Error: Sprockets::Rails::Helper::AssetFilteredError: Asset filtered out and will not be served: add `Rails.application.config.assets.precompile += %w( support/bind-poly.js )` to `config/initializers/assets.rb` and restart your server

ふむ。

結局、合計10ファイル程度をprecompileの対象に追加したらやっとテストが動きました。なんだこれは…Rails4.0でいれたときはこんなことなかったぞ。

##とりあえずの対応

同じようなエラーハマった人いないかググったらどんぴしゃな[issue#197](https://github.com/modeset/teaspoon/issues/197)を発見しました。これです、これ！！

Contributerの方も「Can you explain why you have dev/test set to precompile -- or why you want to include teaspoon in production?」って言ってます。ですよね、僕もそう思います。

ざっと読んでいきます。

`config.assets.raise_runtime_errors = false`で直ったぜって記述を発見しました。たしかに前は`config/environments/development.rb`にこんな設定なかった。

[詳細へのリンク](http://guides.rubyonrails.org/asset_pipeline.html#runtime-error-checking)を貼ってくれてるので、そいつも確認。

「When you have raise\_runtime\_errors set to true, dependencies will be checked at runtime so you can ensure that all dependencies are met.」

ふむ。こんな設定がでけたのですね。しかもデフォルトで`true`。

解除します。`config/environments/development.rb`に以下の設定を書いて、

    config.assets.raise_runtime_errors = false

テスト実行

    $ teaspoon

    Starting the Teaspoon server...
    Teaspoon running default suite at http://127.0.0.1:59165/teaspoon/default
    .............

    Finished in 0.03800 seconds
    0 examples, 0 failures

動きました。とりあえずこれでテストは実行できそうです（ほんとにこれでいいのか…）。

ちなみに`.travis.yml`にも`bundle exec teaspoon`を追加して実行してみたのですが問題なく動きました。

###まとめ
さきほどのissue#197も2014年5月18日現在、open状態なのでまだ解決してない問題かと思われます。やはりRailsはアップデートが頻繁なのでこういうのがツラいですね。引き続きissueやpull-reqなど動向をチェックしていこうと思います。[それっぽいpull-req](https://github.com/modeset/teaspoon/pull/206)は既に出てるくさいんですけどね。レビューはよ。

ひとまず現時点でテストできなくて困ってる人がもしいたら、この方法で一応実行はできるよーっていう共有でした。

###参考
- [modeset/teaspoon Teaspoon missing setup method in Teaspoon:Module? #96](https://github.com/modeset/teaspoon/issues/96)

- [modeset/teaspoon Error: Sprockets::Rails::Helper::AssetFilteredError #197](https://github.com/modeset/teaspoon/issues/197)

- [Rails Guides The Asset Pipeline 3.1 Runtime Error Checking](http://guides.rubyonrails.org/asset_pipeline.html#runtime-error-checking)
