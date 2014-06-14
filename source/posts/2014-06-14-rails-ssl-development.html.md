---
title: PowとtunnelsでRailsのローカル開発環境にSSL導入
date: 2014-06-14
---

仕事でRailsアプリのローカル開発環境にSSL導入したのでメモ。

### Powの導入
`Pow`はRackアプリケーション用のサーバー。仮想的なドメイン名を割り当ててアクセスできるようにしてくれるぽい。

Githubの[README](https://github.com/basecamp/pow)をみて導入。

    $ curl get.pow.cx | sh

    $ cd ~/.pow
    $ ln -s /path/to/myapp

myappのところがRailsアプリがあるパス。そこのシンボリックリンクを貼っとくだけでOK。

これだけで`localhost:3000`だけでなく、`http://myapp.dev`でもアクセスできるようになる。便利。

### tunnelsの導入
次に`https://myapp.dev`でもアクセスできるようにする。`tunnels`というgemを入れればできるらしいので導入。

こちらも[README](https://github.com/jugyo/tunnels)をみて導入。

    `gem install tunnels`

3000ポートを443ポートへ。

    $ sudo tunnels 443 3000

これで`https://myapp.dev`にアクセスでけました。

### まとめ
FacebookとかTwitterとか、ソーシャルシェアの機能を試すとき、httpsじゃないってエラー吐かれたり、余裕っしょって思ってたら本番環境でうまく動かなかったり。
たまにそういうのがあったので今回このような環境を用意しました。

手軽にできるので、もし開発段階からSSL環境下で検証したい人はぜひに。

### 参考

- [basecamp/pow](https://github.com/basecamp/pow)
- [jugyo/tunnels](https://github.com/jugyo/tunnels)
