---
title: サンプルですよー
date: 2014-04-16
tags: wordpress, vagrant
---

僕がはじめてWordPressを触ったのは２年前…

当時はMAMPを使ったローカル開発環境で開発して、FTPで本番にアップ、、なんてやり方で作業をしていました。
MAMPが起動しなくなって気が狂いそうになったり、適当に作られた独自テーマがカオスすぎて発狂したり、正直僕はWordPressに良い思い出がありませんでしたw

で、最近久しぶりにWordPressを使って簡単なWebサイトを作る機会があり、改めて触ってみると今は便利なものがいっぱいありますねー！！驚くほど開発がスムーズにできたので、今回はその時のことを備忘録がてら書いておきたいと思います。


##イントロ的な

今回、使わせていただいたのはこちら

- 仮想環境を用意して、そこにWordPressを導入する（もちろん自動で！）
  - [vagrant-chef-centos-wordpress](https://github.com/miya0001/vagrant-chef-centos-wordpress/)

- スターターテーマUnderscoresを導入し、CSSやJSをGruntで管理しながら開発できるようにする
  - [iemoto](https://github.com/megumiteam/iemoto)


これらを使うことでめちゃめちゃ簡単に、そして爆速でWordPressの開発を進めることができました。ありがとうございます＞＜

それではこれらを導入していく過程を順に書いていきますー。

##導入
まずはVagrant, Virtual Box, Gruntを導入し、次にvagrant-chef-centos-wordpress、iemotoを導入していきます！

ちなみに僕が今回使用したバージョンは↓です。

- Vagrant 1.3.5

- Virtual Box 4.3.6

- Grunt 0.1.11


###Vagrant
[こちら](http://downloads.vagrantup.com/) からインストールしてください。

`gem install vagrant`でもできるらしいのですが、なんか古いバージョンが入ってしまうなど問題があって非推奨ってどこかに書いてました。なので無難にdmgを入れましょー！


###Virtual Box
[こちら](https://www.virtualbox.org/wiki/Downloads) からインストールしてください。


###Grunt
以前書いた記事 [GruntでCSS、JSの圧縮をしてみた](http://dangerous-animal141.hatenablog.com/entry/2013/08/14/145033)を参考にしていただければと思いますm(_ _ )m


###vagrant-chef-centos-wordpress

[こちらのREADME](https://github.com/miya0001/vagrant-chef-centos-wordpress/blob/master/README-ja.md)に詳しく書いてくださっていますが、一応書いていきますー。

まずはvagrant-hostsupdaterをインストール。

    vagrant plugin install vagrant-hostsupdater

このプラグインを使用すれば起動時に /etc/hosts にレコードを追加し、停止時に自動的に削除してくれるみたいです。hostsがカオスになる心配もなく、楽にURLのカスタマイズができますね。

次に任意のフォルダ（今回はtestってことにします）を作って移動。そこでgit cloneします。

    mkdir test（適当に名前つけてください）
    cd test
    git clone https://github.com/miya0001/vagrant-chef-centos-wordpress.git vagrant-wp


これでvagrant-upフォルダが作られました。

vagrant-upに移動してsampleをもとにVagrantfileを作成、編集します。

    cd vagrant-up
    cp Vagrantfile.sample Vagrantfile
    vim Vagrantfile

    必要に応じて編集してください。


    vagrant up

自分はここで`WP_HOSTNAME`を修正したり、`WP_LANG='ja'`にしたりといった調整をしました。

ここでもし編集を忘れたり、後で修正したくなったとしても、`vagrant provision`でプロビジョニングをやり直せば問題ないですよ！
（`vagrant up`は２回目以降、自動でプロビジョニングが走らないので注意。`vagrant provision`をしないとVagrantfileの変更は反映されないです。）

で、`vagrant up`したら自動でchefが走って環境構築ができました！！すげえ！！

ちなみにchefの実行に必要なcookbooksとかもgit cloneした時にすでに入っているので、仮想環境で`knife solo cook`とかわざわざやる必要もないのですね。

とりあえずこれでWordPressの環境が構築されたので、`WP_HOSTNAME`で設定したURLにアクセスしてみます。
WordPressのデフォルトテーマの画面が表示されれば成功です！

うまく表示されなかったら

    vagrant status

でちゃんとrunningになっているか確認してみてください。

ちなみにここで作った仮想環境ではwp-cli (コマンドでWordPressをごにょごにょいじれるやつ）が入っています。
[こちらのコマンド一覧](http://wp-cli.org/commands/)を参考にぜひ使ってみてくださいー。僕は`wp db`でエクスポートとかをちょろっとしただけなので、正直あんまり使ってないですが。。


### iemoto
WordPressが導入できたので、いよいよテーマ開発をしていきます。

WordPressにはデフォルトテーマ(twentyfourteenとかtwentythirteenとか)がすでに入ってますが、これは一からサイトを作る際に利用するには若干不便です。例えばデフォルトのCSSが効いてるせいで、スタイルの変更が効かずハマったり。。

そこで今回はカスタマイズされる前提でつくられたスターターテーマ[Underscores](http://underscores.me/)なるものを使いたいと考えました！そしてどうせならSassとかGrunt使ってサクっと開発したいと思いました！

そこで発見したのがiemotoというgrunt-initテンプレートです。まさに僕の願望にドンピシャでした！！神！

では早速、[こちらのREADME](https://github.com/megumiteam/iemoto/blob/master/README.md)を参考に、導入していきます。

前提としてローカルのwwwフォルダが仮想環境の/var/wwwとリンクしているので、ローカルのwww以下で修正したものは自動で仮想環境に反映されていきます。作業は基本ローカルでやってます。

    //grunt-initを事前に-gでインストールしておく
    sudo npm install -g grunt-init
    mkdir ~/.grunt-init
    git clone https://github.com/megumiteam/iemoto.git ~/.grunt-init/iemoto

    //themesに移動して新しいテーマフォルダを作成
    cd test/vagrant-up/www/wordpress/wp-content/themes/
    mkdir my-theme(適当に名前つけてください）
    cd my-theme
    grunt-init iemoto

    テーマ名などを聞かれるのですべて答えて、問題なければ最後にnを押して完了


grunt-initで質問された内容はstyle.cssに反映され、PHP prefixは実際に関数に適用されます。
prefixは慎重に答えたほうがいいかも。。

これでmy-themeが出来上がり、中にpackage.jsonがあるので、

    npm install

で依存ファイルをインストール。

あとはGruntfile.jsがすでに用意されているので、

    grunt

でタスク実行できます。

CSSは最終的にはstyle.cssを使用することになっているので、スタイル修正は以下のような流れになります。


sassフォルダ内のscssでスタイルを編集
↓
grunt
↓
cssフォルダ内にcss作成される
↓
style.cssとして一つにまとめられる


楽すぎる！！

そして、Underscoresは最低限ほしい動きは実装されつつも、CSSはほとんどReset関係だけだったりしてほんと良い感じに開発スタートできます。便利なのでぜひ使ってみてください！


あとは`git init`してバージョン管理したり、wp-content内にbackup-dbフォルダ作ってそこに対して`wp db export db.sql`してDBのバックアップとったり、状況に応じて柔軟に開発を進めていけると思います。

.gitignoreもあらかじめwordpressフォルダやgrunt-initしたテーマフォルダ内に用意されています。



##まとめ

- Vagrant, chef, wp-cliを使用して楽にWordPressの環境構築ができた。
- Underscores＋Gruntで爆速で独自テーマを開発できる体制が整った。
- とりあえずMAMPはもう要らんw

昔の苦労が嘘のように楽しく開発できました。こんな便利なものを作ってくれた方々に本当感謝します！！！

小さなことからコツコツと。


##参考記事

こちら参考にさせていただきました。ありがとうございました。

- [Vagrant 1.3.0 からは2回目以降の起動時にプロビジョニングが自動で走らないので注意](http://www.msng.info/archives/2013/09/vagrant-1-3-0-no-provision.php)

- [Vagrant で仮想環境を chef で設定する時のアレコレ](http://inokara.hateblo.jp/entry/2013/10/17/060352)

- [仮想環境構築ツール「Vagrant」で開発環境を仮想マシン上に自動作成する](http://knowledge.sakura.ad.jp/tech/1552/)

- [WordPressのプラグインやテーマ、ウェブサイトの開発に超便利なVagrantつくりました。](http://firegoby.jp/archives/5141)

- [スターターテーマ _s を使ってWordPressのテーマをつくる（準備編）](http://gatespace.jp/2012/12/19/underscores00/)

- [Grunt + Underscores でサクサクWordPressテーマ開発](http://firegoby.jp/archives/5115)


