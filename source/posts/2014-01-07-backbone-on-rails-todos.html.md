---
title: backbone-on-railsを使ってTodosを作り直してみた
date: 2014-01-07
---

今回はbackbone.jsのサンプルとして有名なTodoアプリをサーバーサイドにRailsを使って作り直してみたいと思います！

### ソースコード
コードは[こちら](https://github.com/danimal141/bor_todos)に公開しております↓

### 実装
では早速どんなふうに作っていったかを備忘録がてら書いていきたいと思います！！

#### 準備

今回は

- ruby1.9.3
- rails3.2.15

というバージョンでお届けしてまいります。

こちらでまずアプリをつくります。

    rails new bor_todos

次にgitの設定などなど。

    cd bor_todos
    git init
    vim .gitignore //.DS_Storeとか無視したり

そしてGemfileに今回の最重要アイテム`backbone-on-rails`を追加して`bundle install`しときます。

Gemfile

    gem 'backbone-on-rails'

ちなみに似たようなものでbackbone-railsってのもあるみたいですよー。

- [backbone-on-rails](https://github.com/meleyal/backbone-on-rails)
- [backbone-rails](https://github.com/aflatter/backbone-rails)

名前ややこしい。。

んで今回、普通に`localhost:3000`にアクセスして動作確認するだけのつもりなのでroot画面作成。

    rails g controller main index --skip-javascripts //jsはいらねえ

app/views/main/index.html.erb

    <div id="todoapp">
      <header>
        <h1>Todos</h1>
        <input id="new-todo" type="text" placeholder="What needs to be done?">
      </header>

      <section id="main">
        <input id="toggle-all" type="checkbox">
        <label for="toggle-all">Mark all as complete</label>
        <ul id="todo-list"></ul>
      </section>

      <footer>
        <a id="clear-completed">Clear completed</a>
        <div id="todo-count"></div>
      </footer>
    </div>

    <div id="instructions">
    Double-click to edit a todo.
    </div>

    <div id="credits">
    Created by
    <br />
    <a href="http://jgn.me/">J&eacute;r&ocirc;me Gravel-Niquet</a>.
    <br />Rewritten by: <a href="http://addyosmani.github.com/todomvc">TodoMVC</a>.
    </div>

最初はこれまるごとテンプレにしてbackboneからrenderしてたんですけど、不変のHTML部分をなんどもrenderするのは微妙だったのでこのような形に落ち着きました。

これがrootアクセスで見られるように。

config/routes.rb

    root to: main#index

そしてデフォルトのindexを消し去ります。

    rm public/index.html


Scssは書くのだるかったので、もともとのTodosのCSSをScssだと思い込んで丸コピしてサボりました。すんません。。

とりあえずこれでrootが表示されました！

#### API

続いて実際にTodoの情報を返すAPIを作成します。持つのはcontent（内容）とdone（完了フラグ）のみ。

    rails g resource todo content:text done:boolean --skip-javascripts

resourceはscaffoldの簡易版て感じです。余計なviewとか作られないから便利。


doneはデフォルトでfalseにしたいから、それをmigrationファイルに追加。

    class CreateTodos < ActiveRecord::Migration
      def change
        create_table :todos do |t|
          t.text :content
          t.boolean :done, default: false

          t.timestamps
        end
      end
    end

そして`rake db:migrate`

コントローラーも普通にパラメータかえすだけ。

app/controller/todos_controller.rb

    class TodosController < ApplicationController
        respond_to :json

        def index
          @todos = Todo.all
          respond_with @todos
        end

        def show
          @todo = Todo.find(params[:id])
          respond_with @todo
        end

        def create
          @todo = Todo.create(params[:todo])
          respond_with @todo
        end

        def update
          @todo = Todo.find(params[:id])
          @todo.update_attributes(params[:todo])
          respond_with @todo
        end

        def destroy
          @todo = Todo.find(params[:id])
          @todo.destroy
          respond_with @todo
        end
      end

APIっぽくしたいからroutes.rb修正（/api/todos にしたい）

    scope 'api' do
        resources :todos
    end

この時点でサンプルデータをseed.rbに入れて`rake db:seed`して、`localhost:3000/api/todos.json`からデータ返ってきてたらOKです。

#### Backbone.js

いよいよBackbone.js側の実装に入ります。

backbone-on-railsの場合だとこんな感じで土台がすぐつくれちゃいます。

    rails g backbone:install
    rails g backbone:scaffold todo

ちょっと自分でファイル追加したりもしちゃいましたが、こんな感じのファイル構成になりました。

    app/assets/
    ├── images
    │   ├── destroy.png
    │   └── rails.png
    ├── javascripts
    │   ├── application.js
    │   ├── bor_todos.js.coffee
    │   ├── collections
    │   │   └── todos.js.coffee
    │   ├── models
    │   │   └── todo.js.coffee
    │   ├── routers
    │   │   └── todos_router.js.coffee
    │   └── views
    │       └── todos
    │           ├── todos_index.js.coffee
    │           └── todos_item.js.coffee
    ├── stylesheets
    │   ├── application.css
    │   ├── main.css.scss
    │   └── todos.css.scss
    └── templates
        └── todos
            ├── item.jst.eco
            └── stats.jst.eco

では処理が流れる順番にファイルをみていきたいと思います。

まずは

app/assets/javascripts/bor_todos.js.coffee

    window.BorTodos =
      Models: {}
      Collections: {}
      Views: {}
      Routers: {}
      initialize: ->
        new BorTodos.Routers.Todos()
        Backbone.history.start()

    $(document).ready ->
        BorTodos.initialize()

ここでModels, Collections, Views, Routersをグローバルから呼び出せるようにしてます。

そしてDOMContentLoadedが呼ばれたタイミングでinitializeを呼ぶと。ここでrouterに処理が流れます。

てことで次は

app/assets/javascripts/routers/ todos_router.js.coffee

    class BorTodos.Routers.Todos extends Backbone.Router
      routes:
        '': 'index'

      initialize: ->
        @collection = new BorTodos.Collections.Todos()
        @collection.fetch(reset: true)

      index: ->
        view = new BorTodos.Views.TodosIndex(collection: @collection)


ここではまず新しいCollectionsのインスタンスを作ってfetchでデータを取りに行きます。

そして非常に重要なポイントが`reset: true`

なんと以前はあたりまえのように発動してたfetchのresetイベントが、いつのまにやらこいつを付けないと発動しなくなってるんですよね。。

こちらスーパーハマるポイントだと思うので要注意です。

んで、普通にアクセスした際にindexメソッドを呼ぶように仕掛けているので、ここで新しいTodosIndexのViewをつくって最新のデータ情報を反映した画面が表示されます。

ではここからはModel, Collection, Viewをそれぞれ見て行きたいと思います。

まずはModel, Collectionから。

app/assets/javascripts/models/todo.js.coffee

    class BorTodos.Models.Todo extends Backbone.Model

      defaults: ->
        content: "empty todo..."
        done: false

      toggle: ->
        @save(done: !@get('done'))


app/assets/javascripts/collections/todos.js.coffee

    class BorTodos.Collections.Todos extends Backbone.Collection

      model: BorTodos.Models.Todo
      url: '/api/todos'

      done: ->
        @where(done: true)

      remaining: ->
        @without.apply(this, @done())

localStorageの代わりのurl: 'api/todos'を指定して、APIとやりとりする形式に変更している以外はもとのTodosと大して変わりません。


次はView。
名前はViewですが、こいつ自体はコントローラーの役割を担い、templateがViewみたいなイメージですね。

todos_indexはアプリ全体を管理するView。

app/assets/javascripts/views/todos/todos_index.js.coffee

    class BorTodos.Views.TodosIndex extends Backbone.View

      template: JST['todos/stats']

      el: '#todoapp'

      events:
        'keypress #new-todo': 'createOnEnter'
        'click #clear-completed': 'clearCompleted'
        'click #toggle-all': 'toggleAllComplete'

      initialize: ->
        @listenTo(@collection, 'add', @addOne)
        @listenTo(@collection, 'reset', @addAll)
        @listenTo(@collection, 'all', @render)

      render: ->
        if @collection.length
          @$('#main').show()
          @$('footer').html(@template(todos: @collection)).show()
        else
          @$('#main').hide()
          @$('footer').hide()

        this

      addOne: (todo)->
        view = new BorTodos.Views.TodosItem(model: todo)
        @$('#todo-list').append(view.render().el)

      addAll: ->
        @collection.each(@addOne, this)

      createOnEnter: (e)->
        text = @$('#new-todo').val()

        if text and e.keyCode is 13
          @collection.create(content: text)
          @$('#new-todo').val("")

      clearCompleted: ->
        _.invoke(@collection.done(), 'destroy')
        false

      toggleAllComplete: ->
        done = @$('#toggle-all').prop('checked')

        @collection.each (todo)->
          todo.save('done': done)

ここも大きな変更点はtemplateをunderscore.jsのtemlateからecoに変更したぐらいではないでしょうか。

このViewではresetイベントがトリガーされたらaddAllが呼び出されるので、routerのほうで`@collection.fetch(reset: true)`をした際にサーバーに保存されている全Todoを読み込んでrenderされます。


続いてtodos_itemは各Todoを管理するためのView。

app/assets/javascripts/views/todos/todos_item.js.coffee

    class BorTodos.Views.TodosItem extends Backbone.View

      template: JST['todos/item']

      tagName: 'li'

      events:
        'click .toggle': 'toggleDone'
        'dblclick .view': 'edit'
        'blur .edit': 'close'
        'click a.destroy': 'clear'
        'keypress .edit': 'updateOnEnter'

      initialize: ->
        @listenTo(@model, 'change', @render)
        @listenTo(@model, 'destroy', @remove)

      render: ->
        @$el.html(@template(item: @model))
        this

      toggleDone: ->
        @model.toggle()

      edit: ->
        @$el.addClass('editing')
        @$('edit').focus()

      close: ->
        value = @$('edit').val()

        unless value
          @clear()
        else
          @model.save(content: value)
          @$el.removeClass('editing')

      updateOnEnter: (e)->
        if e.keyCode is 13
          @close()

      clear: ->
        @model.destroy()

これも大きな変更点はなく、編集したり削除したりしたらModel側でごにょごにょして、終わったらchangeやdestroyイベントをもらってrenderって感じです。


最後にtodos_index, todos_itemの所有するtemplateをそれぞれみておきます。

まずtodos_indexはstats.jst.ecoをもちます。（footerの「2 completed items」とか表示したいだけのやつです）

app/assets/templates/todos/stats.jst.eco

    <% if @todos.done().length: %>
      <a id="clear-completed">
        Clear <%= @todos.done().length %> completed <%= if @todos.done().length == 1 then 'item' else 'items' %>
      </a>
    <% end %>

    <div class="todo-count">
      <b><%= @todos.remaining().length %></b> <%= if @todos.remaining().length == 1 then 'item' else 'items' %> left
    </div>

View側のrenderの際に`@$('footer').html(@template(todos: @collection)).show()`のようにしていたと思うのですが、このように`todos:@collection`としておくことでecoのほうで@todosからこのCollectionにアクセスできるようになります。

あとはこのeco内でCoffeeScriptが使えます。ifやforする際に「:」がいるので気をつけてくださいね。
三項演算子が使えなくてthenとかelseとかなるのは微妙ですが、、

todos_itemのitem.jst.ecoも同様に`item: @model`としてModelにアクセスしてます。

app/assets/templates/todos/item.jst.eco

    <div class="view">
      <input class="toggle" type="checkbox" <%= if @item.get('done') then 'checked="checked"' else '' %> />
      <label><%= @item.get('content') %></label>
      <a class="destroy"></a>
    </div>

    <input class="edit" type="text" value="<%= @item.get('content') %>" />

これでひと通り実装が完成しました！！


### まとめ
- RailsとBackbone.jsの連携のやり方（backbone-on-railsの使い方）がわかった。

- Backboneのfetchが変わってて焦った。`reset: true`必要。

- Routerからの一連の処理の流れがつかめた。

- ecoテンプレートとやらの使い方がわかった。

あと改めて感じたことは、**Railsの勉強をしたことで以前よりBackboneの処理の流れ方がよく理解できるようになった**ってこと。

例えば「Viewがコントローラー的な役割を担う」って言われても、前はいまいちピンとこなかったんですが、「RailsだったらこうだったけどBackboneの場合はこうなるのか。ふむ。」みたいに比較して理解できるようになったことで、より理解が深まりました。

だからBackbone.jsやってみたけどよくわからんって人は一度、有名なMVCフレームワークとかいじってみると良いかもしれません。余計わからなくなったらごめんなさい。。

Railsで勉強したことに関する記事もまた書きたいと思います。

### 参考
こちら参考にさせていただきました。ありがとうございました。

- [Rails3.2とBackbone.jsでToDoアプリを作ってみた～backbone-on-rails](http://blog.scimpr.com/2013/01/13/rails3-2%E3%81%A8backbone-js%E3%81%A7todo%E3%82%A2%E3%83%97%E3%83%AA%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%A6%E3%81%BF%E3%81%9F%EF%BD%9Ebackbone-on-rails/)
- [backbone-on-railsでモデル一覧を表示する。](http://qiita.com/patorash/items/af63c123e8f465a3e661)
- [Railsのgenerate scaffoldとgenerate resource](http://apehuci-kitaitimakoto.sqale.jp/apehuci/?date=20111113)
- [Backbone on Rails Part 1](http://railscasts.com/episodes/323-backbone-on-rails-part-1?view=comments)
