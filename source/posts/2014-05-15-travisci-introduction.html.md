---
title: Travis CI導入メモ
date: 2014-05-15
---

Travis CIを導入した際の手順をメモがてら書きます。

###設定ファイルを書く

Railsプロジェクト（DBはpostgreSQL）で使用したのでその前提で。

プロジェクトのリポジトリに`.travis.yml`を追加して以下のように書きました。

    language: ruby
    rvm:
      - 2.1.0
    bundler_args: --without development --deployment
    cache: bundler
    before_script:
      - cp config/database.travis.yml config/database.yml
      - bundle exec rake db:create
      - bundle exec rake db:migrate
    script:
      - bundle exec rspec spec



languageを`Ruby`に指定。

 `rvm`のところは複数バージョン書いておくとバージョンごとに個別にテストしてくれるぽい。

`bundler_args`と`cache`はできるだけテスト速くしたいので設定。[ドキュメント](http://docs.travis-ci.com/user/caching/#Arbitrary-directories)を参考に（丸パクリ）しました。

`before_script`はテスト実行前の処理。
まずpostgreSQL用の設定。（SQLiteとかなら多分必要ない）`config/database.travis.yml`をつくってtravis用のDB設定を書きます。

こんな感じ。

    test:
      adapter: postgresql
      database: md_note_test
      username: postgres

`rake db:create`, `rake db:migrate`しとけばDBの準備もOK。

あとは`script`のとこでテストの実行コードを書いておけばその通りテストしてくれます。

###Travis CI側での設定
[Travis CI](https://travis-ci.org/)に行ってGithub認証したらほぼ完了。[profile](https://travis-ci.org/profile)に自分のリポジトリ一覧が表示されるので、Travisを使用したいリポジトリにONのチェックを入れるだけ。

あとは上で用意した`.travis.yml`と`config/database.travis.yml`を該当するリポジトリにpushしておけば、その後`git push`するたびにテスト実行してくれるようになります。

`https://travis-ci.org/Githubのユーザー名/リポジトリ名`にいけば経過みれます。（トップ画面でも見れるかも）

###build passing的な画像をREADMEに貼る

`https://travis-ci.org/Githubのユーザー名/リポジトリ名`のちょうど右上に画像が表示されてます。

![travisci_introduction1](images/2014/05/15/travisci_introduction1.png)

それをクリックしてMarkdownを選択。横のパスを`README.md`にコピペしたら表示されます。

![travisci_introduction2](images/2014/05/15/travisci_introduction2.png)

###メモ
`git commit --amend`して`git push -f origin master`ってしたときにTravis側を確認したら`git checkout`の段階で`fatal: reference is not a tree:`みたいなエラーが出たことがありました。

もう一回push（forceではない）したら直ったので原因の深堀りできてないのですが、[ここ](https://github.com/travis-ci/travis-ci/issues/617)に似た状況が書かれていたので今後のためにメモしとく。

###まとめ
個人でオープンに開発するときはTravisが便利！！プライベートリポジトリだと辛そう。（[Travis CI価格表](https://travis-ci.com/plans?v=t)）
仕事では[Circle CI](https://circleci.com/)使ってるんですが、プライベートならこっちのほうが断然いいとおもいます。安いです。([Circle CI価格表](https://circleci.com/pricing)）

状況に応じて使い分けたい。

###参考
- [Caching Dependencies and Directories](http://docs.travis-ci.com/user/caching/)
- [travis-ci/issues/617](https://github.com/travis-ci/travis-ci/issues/617)
