---
title: Githubのユーザー名を変更してみた
date: 2014-05-05
---

この前Githubのユーザー名を変更したので、メモがてら書いておきます。

自分は以下の懸念事項があって今までなかなか行動に移せていなかったのですが、今回無事に変更できたので似たような心配をしている人の参考になれば幸いです。

- 今まで作成したGithubのリポジトリやGistはどうなるのか
- homesick+Githubで管理してるdotfilesはどうなるのか

###とりあえずユーザー名を変更してみる
ユーザー名の変更自体は簡単です。
[Github](https://github.com/)の自分のプロフィールページにアクセスして、以下のどちらかをクリックすればプロフィール編集画面にいけます。

![github_username1](images/2014/05/05/github_username1.png)

んで、そこからAccount Settings → change usernameでユーザー名を変更するだけ。
変更自体は簡単です。

![github_username2](images/2014/05/05/github_username2.png)

ここで怖いポップアップが出てくるのですが、逃げてはいけません。

![github_username3](images/2014/05/05/github_username3.png)

別にリポジトリもGistも消されたりはしません。
ただ「お前のリポジトリのリダイレクトはしゃーなし設定してやるけど、お前の旧プロフィールページとか他のページはどうなっても知らねえよ？」って言われてるだけです。逃げちゃだめだ。

`https://github.com/old_username/repository_name`

にアクセスしたら

`https://github.com/new_username/repository_name`

にリダイレクトかまされますが、

`https://github.com/old_username`

にアクセスしてもNot Foundになります。注意。

I understandしてしばらく待つとユーザー名の変更が完了します。

###git config user.nameの設定
自分のPC側でgitのユーザー名を設定している場合はこちらも変更しておきます。

    $ git config --global user.name 'new_username'

これでOK。

    $ git config --global -l

で確認できます。

[Github Help](https://help.github.com/articles/setting-your-username-in-git)もあるので参考にしてみてください。

###過去にgit cloneしたローカルのリポジトリ達のケア
これは数が多い場合はだるいですが、やること自体は簡単です。

    $ cd ローカルリポジトリ
    $ git remote -v

    # 変更前
    origin  git@github.com:old_name/repository_name.git (fetch)
    origin  git@github.com:old_name/repository_name.git (push)

    $ git remote set-url origin git@github.com:new_name/repository_name.git
    $ git remote -v

    # 変更後
    origin  git@github.com:new_name/repository_name.git (fetch)
    origin  git@github.com:new_name/repository_name.git (push)

これで`git fetch`とか`git push`が問題なくできればOKです。

###homesickの再設定
自分は`.vimrc`やら`.zshrc`やらの設定ファイルを[`homesick`](https://github.com/technicalpickles/homesick)を使って管理しているのですが、こいつも設定し直さないといけません。`homesick`の使い方は[こちらの記事](http://qiita.com/s_tomoyuki/items/650ff995e6906bdecc17)とかを参考にしてみてください。

ここからが本題の再設定（といっても先ほどと同じことするだけですが）。`~/.homesick/repos/dotfiles`に`homesick clone`したリポジトリがあります。`homesick clone`とはいえ所詮`git clone`なので先ほどと同じようにremoteのurlを設定します。

    $ cd ~/.homesick/repos/dotfiles

    # 先ほどと同様にリポジトリのパスを変更
    $ git remote set-url origin git@github.com:new_name/dotfiles

    $ cd ~
    $ homesick pull
    $ homesick symlink dotfiles

    # 設定できてるか確認
    $ homesick list
    dotfiles git@github.com:new_name/dotfiles

これで再設定が完了します。

他にも一旦ローカルのdotfilesリポジトリを消して、

    $ homesick clone new_name/dotfiles

するのもありかと思いますが、一旦設定が消えてツラかったり、初期に設定されるremoteのurlが`ssh`のものではなく`https`のものだったりするので普通に`git remote set-url`するほうがいいと思います。

###まとめ
こんな感じでサクッと変更できるので、ダサいユーザー名つけて激しく後悔してる人はぜひかっこいいユーザー名に変更してみてください。

###参考

- [Setting your username in git | Github Help](https://help.github.com/articles/setting-your-username-in-git)
- [homesick を使って dotfiles を管理する！](http://qiita.com/s_tomoyuki/items/650ff995e6906bdecc17)
