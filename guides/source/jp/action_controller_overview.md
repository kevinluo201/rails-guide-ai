**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 3529115f04b9d5fe01401105d9c154e2
Action Controllerの概要
==========================

このガイドでは、コントローラがどのように機能し、アプリケーションのリクエストサイクルにどのように組み込まれるかを学びます。

このガイドを読み終えると、以下のことがわかるようになります。

* コントローラを通じたリクエストのフローを追う方法。
* コントローラに渡されるパラメータを制限する方法。
* セッションやクッキーにデータを保存する方法とその理由。
* フィルタを使用してリクエスト処理中にコードを実行する方法。
* Action Controllerの組み込みのHTTP認証を使用する方法。
* データを直接ユーザのブラウザにストリームする方法。
* 機密情報のパラメータをフィルタリングして、アプリケーションのログに表示されないようにする方法。
* リクエスト処理中に発生する可能性のある例外に対処する方法。
* ロードバランサやアップタイムモニターのための組み込みのヘルスチェックエンドポイントを使用する方法。

--------------------------------------------------------------------------------

コントローラの役割は何ですか？
--------------------------

Action Controllerは、[MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)のCです。ルータがリクエストに使用するコントローラを決定した後、コントローラはリクエストを理解し、適切な出力を生成する責任を持ちます。幸いなことに、Action Controllerはほとんどの基本的な作業を代わりに行い、スマートな規約を使用してこれをできるだけ簡単にします。

ほとんどの一般的な[RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer)アプリケーションでは、コントローラはリクエストを受け取り（これは開発者としては見えません）、モデルからデータを取得または保存し、ビューを使用してHTMLの出力を作成します。コントローラが少し異なる方法で作業する必要がある場合でも、問題ありません。これはコントローラの最も一般的な動作方法です。

したがって、コントローラはモデルとビューの間の仲介役と考えることができます。コントローラはモデルデータをビューで利用できるようにし、ユーザデータをモデルに保存または更新します。

注意：ルーティングプロセスの詳細については、[Rails Routing from the Outside In](routing.html)を参照してください。

コントローラの命名規則
----------------------------

Railsのコントローラの命名規則は、コントローラ名の最後の単語を複数形にすることを好みますが、厳密に必要ではありません（例：`ApplicationController`）。例えば、`ClientsController`は`ClientController`よりも好ましいですし、`SiteAdminsController`は`SiteAdminController`や`SitesAdminsController`よりも好ましいです。

この規則に従うことで、デフォルトのルートジェネレータ（`resources`など）を使用する際に、各`:path`や`:controller`を修飾する必要がなくなり、名前付きルートヘルパーの使用方法をアプリケーション全体で一貫させることができます。詳細については、[Layouts and Rendering Guide](layouts_and_rendering.html)を参照してください。

注意：コントローラの命名規則は、モデルの命名規則とは異なります。モデルは単数形で命名することが期待されています。


メソッドとアクション
-------------------

コントローラは、`ApplicationController`を継承し、他のクラスと同様にメソッドを持つRubyクラスです。アプリケーションがリクエストを受け取ると、ルーティングはどのコントローラとアクションを実行するかを決定し、Railsはそのコントローラのインスタンスを作成し、アクションと同じ名前のメソッドを実行します。

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

例えば、ユーザが新しいクライアントを追加するためにアプリケーションの`/clients/new`にアクセスした場合、Railsは`ClientsController`のインスタンスを作成し、その`new`メソッドを呼び出します。上記の例の空のメソッドは問題ありません。なぜなら、Railsはデフォルトで`new.html.erb`ビューをレンダリングするからです。`new`メソッドでは、新しい`Client`を作成することで、`@client`インスタンス変数をビューで利用できるようにすることができます。

```ruby
def new
  @client = Client.new
end
```

詳細については、[Layouts and Rendering Guide](layouts_and_rendering.html)を参照してください。

`ApplicationController`は[`ActionController::Base`][]を継承しており、多くの便利なメソッドが定義されています。このガイドではいくつかをカバーしますが、気になる方は[APIドキュメント](https://api.rubyonrails.org/classes/ActionController.html)やソース自体で全てを確認することができます。

アクションとして呼び出せるのは公開メソッドのみです。補助メソッドやフィルタなど、アクションでないメソッドの可視性を下げる（`private`や`protected`を使用する）ことはベストプラクティスです。

警告：一部のメソッド名はAction Controllerによって予約されています。これらをアクションや補助メソッドとして意図せず再定義すると、`SystemStackError`が発生する可能性があります。コントローラをRESTfulな[Resource Routing][]アクションに制限する場合は、これについて心配する必要はありません。

注意：予約されたメソッドをアクション名として使用する必要がある場合、予約されたメソッド名を非予約のアクションメソッドにマップするためにカスタムルートを使用するという回避策があります。
[リソースルーティング]: routing.html#resource-routing-the-rails-default

パラメータ
----------

おそらく、コントローラのアクションでユーザーから送信されたデータや他のパラメータにアクセスしたいと思うでしょう。Webアプリケーションでは、2種類のパラメータが可能です。最初はURLの一部として送信されるパラメータで、クエリ文字列パラメータと呼ばれます。クエリ文字列はURLの"?"以降の部分です。2番目のタイプのパラメータは通常POSTデータと呼ばれます。この情報は通常、ユーザーが入力したHTMLフォームから取得されます。POSTデータはHTTP POSTリクエストの一部としてのみ送信できるため、POSTデータと呼ばれます。Railsはクエリ文字列パラメータとPOSTパラメータの区別を行わず、両方がコントローラの[`params`][]ハッシュで利用できます。

```ruby
class ClientsController < ApplicationController
  # このアクションはHTTP GETリクエストによって実行されるため、クエリ文字列パラメータが使用されますが、これはパラメータへのアクセス方法には影響しません。このアクションのURLは、アクティブ化されたクライアントをリストするために次のようになります: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # このアクションはPOSTパラメータを使用します。これらはおそらくユーザーが送信したHTMLフォームから来るものです。このRESTfulリクエストのURLは"/clients"になり、データはリクエストボディの一部として送信されます。
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # この行はデフォルトのレンダリング動作を上書きします。デフォルトでは、"create"ビューがレンダリングされます。
      render "new"
    end
  end
end
```


### ハッシュと配列のパラメータ

`params`ハッシュは1次元のキーと値に限定されません。ネストされた配列やハッシュを含めることができます。値の配列を送信するには、キー名の末尾に空の角括弧 "[]" を追加します:

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

注: この例の実際のURLは、"["と"]"の文字はURLでは許可されていないため、"/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3"とエンコードされます。ほとんどの場合、ブラウザが自動的にエンコードしてくれるため、心配する必要はありませんが、サーバーに手動でそのようなリクエストを送信する必要がある場合は、これを念頭に置いてください。

`params[:ids]`の値は、`["1", "2", "3"]`になります。パラメータの値は常に文字列です。Railsは型を推測したりキャストしたりしません。

注: `params`内の`[nil]`や`[nil, nil, ...]`などの値は、セキュリティ上の理由からデフォルトでは`[]`に置き換えられます。詳細については、[セキュリティガイド](security.html#unsafe-query-generation)を参照してください。

ハッシュを送信するには、角括弧の内部にキー名を含めます:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

このフォームが送信されると、`params[:client]`の値は`{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`になります。`params[:client][:address]`にはネストされたハッシュが含まれていることに注意してください。

`params`オブジェクトはハッシュのように振る舞いますが、キーとしてシンボルと文字列を相互に使用することができます。

### JSONパラメータ

アプリケーションがAPIを公開している場合、JSON形式のパラメータを受け入れることが多いでしょう。リクエストの「Content-Type」ヘッダが「application/json」に設定されている場合、Railsは自動的にパラメータを`params`ハッシュにロードします。通常通りにアクセスすることができます。

例えば、次のJSONコンテンツを送信している場合:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

コントローラは`params[:company]`として`{ "name" => "acme", "address" => "123 Carrot Street" }`を受け取ります。

また、初期化子で`config.wrap_parameters`をオンにしたり、コントローラで[`wrap_parameters`][]を呼び出したりしている場合、JSONパラメータでルート要素を省略することができます。この場合、パラメータはクローンされ、コントローラの名前に基づいてキーが選択されてラップされます。したがって、上記のJSONリクエストは次のように書くことができます:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

そして、データを`CompaniesController`に送信している場合、それは次のように`:company`キーでラップされます:
```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

[APIドキュメント](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)を参照して、キーの名前やラップする特定のパラメータをカスタマイズすることができます。

注意：XMLパラメータの解析のサポートは、`actionpack-xml_parser`というジェムに抽出されました。


### ルーティングパラメータ

`params`ハッシュには常に`:controller`と`:action`のキーが含まれますが、これらの値にアクセスするためには[`controller_name`][]メソッドと[`action_name`][]メソッドを使用する必要があります。`:id`などのルーティングで定義された他のパラメータも利用可能です。例えば、アクティブなクライアントまたは非アクティブなクライアントを表示するリストを考えてみましょう。"pretty"なURLで`:status`パラメータをキャプチャするルートを追加することができます。

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

この場合、ユーザーがURL `/clients/active` を開いた場合、`params[:status]`は "active" に設定されます。このルートが使用されると、`params[:foo]`もクエリ文字列で渡されたかのように "bar" に設定されます。コントローラーはまた、`params[:action]`を "index" として、`params[:controller]`を "clients" として受け取ります。


### `default_url_options`

コントローラー内で`default_url_options`というメソッドを定義することで、URL生成のためのグローバルなデフォルトパラメータを設定することができます。このメソッドは、シンボルでキーが指定されたハッシュを返す必要があります。

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

これらのオプションは、URLを生成する際の出発点として使用されるため、`url_for`の呼び出しに渡されたオプションによって上書きされる可能性があります。

上記の例のように、`ApplicationController`で`default_url_options`を定義すると、これらのデフォルトはすべてのURL生成に使用されます。このメソッドは特定のコントローラーで定義することもできますが、その場合は生成されたURLにのみ影響を与えます。

リクエスト内では、このメソッドは実際にはすべての生成されたURLに対して呼び出されるわけではありません。パフォーマンスのために、返されたハッシュはキャッシュされ、リクエストごとに最大1回の呼び出しがあります。


### ストロングパラメータ

ストロングパラメータを使用すると、Active ModelのマスアサインメントでAction Controllerのパラメータを許可する前に、許可する必要があります。これにより、マスアップデートのために許可する属性を意識的に選択する必要があります。これは、ユーザーが誤って機密性の高いモデル属性を更新することを防ぐためのより良いセキュリティの実践です。

さらに、パラメータを必須としてマークすることができ、定義済みのraise/rescueフローを通じて流れることになります。必須のパラメータがすべて渡されていない場合、400 Bad Requestが返されます。

```ruby
class PeopleController < ActionController::Base
  # これは明示的な許可のステップなしにマスアサインメントを使用しているため、ActiveModel::ForbiddenAttributesError例外が発生します。
  def create
    Person.create(params[:person])
  end

  # これは、パラメータにpersonキーがある限り、問題なくパスします。それ以外の場合は、ActionController::ParameterMissing例外が発生し、ActionController::Baseによってキャッチされて400 Bad Requestエラーに変換されます。
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # 許可されたパラメータをカプセル化するためにプライベートメソッドを使用するのは良いパターンです。これにより、createとupdateの間で同じ許可リストを再利用できます。また、このメソッドを特定のユーザーの許可属性のチェックに特化させることもできます。
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### 許可されたスカラー値

[`permit`][]を以下のように呼び出すと:

```ruby
params.permit(:id)
```

指定されたキー(`:id`)が`params`に現れ、許可されたスカラー値が関連付けられている場合、そのキーは含まれるように許可されます。それ以外の場合、キーはフィルタリングされますので、配列、ハッシュ、または他のオブジェクトは注入されません。

許可されたスカラータイプは、`String`、`Symbol`、`NilClass`、`Numeric`、`TrueClass`、`FalseClass`、`Date`、`Time`、`DateTime`、`StringIO`、`IO`、`ActionDispatch::Http::UploadedFile`、および`Rack::Test::UploadedFile`です。

`params`の値が許可されたスカラー値の配列であることを宣言するには、キーを空の配列にマップします。

```ruby
params.permit(id: [])
```

ハッシュパラメータまたはその内部構造の有効なキーを宣言することができない場合や便利ではない場合があります。その場合は、空のハッシュにマップします。

```ruby
params.permit(preferences: {})
```

ただし、これにより任意の入力が可能になるため、注意が必要です。この場合、`permit`は返された構造内の値が許可されたスカラーであることを保証し、それ以外のものはフィルタリングされます。
[`permit!`][]メソッドを使用すると、パラメータのハッシュ全体を許可することができます。

```ruby
params.require(:log_entry).permit!
```

これにより、`:log_entry`パラメータのハッシュとそのサブハッシュが許可され、許可されたスカラーのチェックは行われません。つまり、どんな値でも受け入れられます。`permit!`を使用する際には非常に注意が必要です。なぜなら、現在のおよび将来のモデル属性のすべてが一括代入されるようになるからです。

#### ネストされたパラメータ

次のように、ネストされたパラメータにも`permit`を使用することができます。

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

この宣言では、`name`、`emails`、`friends`属性が許可されます。`emails`は許可されたスカラー値の配列であることが期待され、`friends`は特定の属性を持つリソースの配列であることが期待されます。`friends`は`name`属性（許可されたスカラー値が許可される）と、`hobbies`属性（許可されたスカラー値の配列）を持ち、`family`属性は`name`を持つことが制限されています（ここでも許可されたスカラー値が許可されます）。

#### その他の例

`new`アクションでも許可された属性を使用することができます。ただし、通常、`new`を呼び出すときにはルートキーを[`require`][]で使用できないため、問題が発生します。

```ruby
# `fetch`を使用するとデフォルト値を指定し、
# そこからStrong Parameters APIを使用できます。
params.fetch(:blog, {}).permit(:title, :author)
```

モデルクラスメソッド`accepts_nested_attributes_for`を使用すると、関連するレコードを更新および削除することができます。これは`id`と`_destroy`パラメータに基づいています。

```ruby
# :idと:_destroyを許可する
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

整数キーを持つハッシュは異なる方法で処理され、直接の子として属性を宣言することができます。これは、`accepts_nested_attributes_for`を`has_many`関連と組み合わせて使用した場合に得られるパラメータです。

```ruby
# 次のデータを許可するために:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

製品名を表すパラメータと、その製品に関連付けられた任意のデータのハッシュを許可したい場合を想像してみてください。製品名属性とデータハッシュ全体を許可する必要があります。

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```


#### Strong Parametersの範囲外

Strong Parameters APIは、最も一般的な使用例を考慮して設計されています。すべてのパラメータフィルタリングの問題を解決するための銀の弾丸としては意図されていません。ただし、APIを独自のコードと簡単に組み合わせて、状況に適応させることができます。

セッション
-------

アプリケーションには、各ユーザーごとにセッションがあり、リクエスト間で永続化される少量のデータを格納することができます。セッションはコントローラとビューでのみ利用可能であり、いくつかの異なるストレージメカニズムのいずれかを使用できます。

* [`ActionDispatch::Session::CookieStore`][] - すべてをクライアントに保存します。
* [`ActionDispatch::Session::CacheStore`][] - データをRailsキャッシュに保存します。
* [`ActionDispatch::Session::MemCacheStore`][] - データをメモリキャッシュクラスタに保存します（これはレガシーな実装です。`CacheStore`を使用することを検討してください）。
* [`ActionDispatch::Session::ActiveRecordStore`][activerecord-session_store] - Active Recordを使用してデータをデータベースに保存します（[`activerecord-session_store`][activerecord-session_store] gemが必要です）。
* カスタムストアまたはサードパーティのgemが提供するストア

すべてのセッションストアは、セッションごとに一意のIDを保存するためにクッキーを使用します（セッションIDをURLに渡すことはセキュリティ上の理由から許可されません）。

ほとんどのストアでは、このIDを使用してサーバー上のセッションデータを検索します（たとえば、データベーステーブル内）。ただし、CookieStoreというデフォルトで推奨されるセッションストアには例外があります。CookieStoreは、すべてのセッションデータをクッキー自体に保存します（IDは必要に応じて使用できます）。これにより、非常に軽量になり、新しいアプリケーションでセッションを使用するためのセットアップが不要になります。クッキーデータは暗号化されており、改ざん防止のために暗号署名されています。また、アクセス権を持つ人物が内容を読むことはできないようにもなっています（編集された場合、Railsは受け入れません）。

CookieStoreは約4 kBのデータを保存できますが、他のストアよりもはるかに少ないです。どのセッションストアを使用しても、大量のデータをセッションに保存することはお勧めしません。特に、モデルインスタンスなどの複雑なオブジェクトをセッションに保存することは避けるべきです。なぜなら、サーバーがリクエスト間でそれらを再構築できない場合にエラーが発生する可能性があるからです。
もしユーザーセッションが重要なデータを保存しない場合や長期間必要ない場合（例えばメッセージングのためにフラッシュを使用する場合）は、`ActionDispatch::Session::CacheStore`を使用することを検討できます。これにより、セッションはアプリケーションで設定したキャッシュの実装を使用して保存されます。これにより、追加のセットアップや管理は必要ありませんが、既存のキャッシュインフラストラクチャを使用してセッションを保存できます。もちろん、セッションは一時的であり、いつでも消える可能性があるというデメリットがあります。

セッションストレージについては、[セキュリティガイド](security.html)を参照してください。

異なるセッションストレージメカニズムが必要な場合は、イニシャライザで変更することができます。

```ruby
Rails.application.config.session_store :cache_store
```

詳細については、[設定ガイドの`config.session_store`](configuring.html#config-session-store)を参照してください。

Railsはセッションデータに署名する際にセッションキー（クッキーの名前）を設定します。これもイニシャライザで変更することができます。

```ruby
# このファイルを変更した場合は、サーバーを再起動してください。
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

`domain`キーを渡すことで、クッキーのドメイン名を指定することもできます。

```ruby
# このファイルを変更した場合は、サーバーを再起動してください。
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Railsは（CookieStoreの場合）`config/credentials.yml.enc`でセッションデータの署名に使用するシークレットキーを設定します。`bin/rails credentials:edit`を使用して変更することができます。

```yaml
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# RailsのすべてのMessageVerifierで使用されるベースシークレット。
secret_key_base: 492f...
```

注意：`CookieStore`を使用している場合、`secret_key_base`を変更するとすべての既存のセッションが無効になります。



### セッションへのアクセス

コントローラーでは、`session`インスタンスメソッドを介してセッションにアクセスできます。

注意：セッションは遅延ロードされます。アクションのコードでセッションにアクセスしない場合、セッションはロードされません。したがって、セッションを無効にする必要はありません。アクセスしないだけで十分です。

セッションの値はハッシュのようなキー/値のペアとして保存されます。

```ruby
class ApplicationController < ActionController::Base
  private
    # :current_user_idというキーでセッションに保存されたIDを持つユーザーを検索します。
    # これはRailsアプリケーションでユーザーログインを処理する一般的な方法です。
    # ログイン時にセッション値を設定し、ログアウト時に削除します。
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

セッションに何かを保存するには、ハッシュのようにキーに割り当てます。

```ruby
class LoginsController < ApplicationController
  # ログインを作成します（ユーザーをログインさせます）
  def create
    if user = User.authenticate(params[:username], params[:password])
      # ユーザーIDをセッションに保存して、後続のリクエストで使用できるようにします
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

セッションから何かを削除するには、キー/値のペアを削除します。

```ruby
class LoginsController < ApplicationController
  # ログインを削除します（ユーザーをログアウトさせます）
  def destroy
    # セッションからユーザーIDを削除します
    session.delete(:current_user_id)
    # メモ化された現在のユーザーをクリアします
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

セッション全体をリセットするには、[`reset_session`][]を使用します。


### フラッシュ

フラッシュはセッションの特別な部分であり、各リクエストでクリアされます。これは、次のリクエストでのみ使用できるため、エラーメッセージなどを渡すのに便利です。

フラッシュは[`flash`][]メソッドを介してアクセスされます。セッションと同様に、フラッシュもハッシュとして表されます。

ログアウトのアクションを例にしてみましょう。コントローラーは次のリクエストでユーザーに表示されるメッセージを送信できます。

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "ログアウトに成功しました。"
    redirect_to root_url, status: :see_other
  end
end
```

リダイレクトの一部としてフラッシュメッセージを割り当てることも可能です。`:notice`、`:alert`、または汎用の`:flash`を割り当てることができます。

```ruby
redirect_to root_url, notice: "ログアウトに成功しました。"
redirect_to root_url, alert: "ここから抜け出せません！"
redirect_to root_url, flash: { referral_code: 1234 }
```

`destroy`アクションはアプリケーションの`root_url`にリダイレクトし、メッセージが表示されます。前のアクションがフラッシュに入れたエラーアラートや通知を表示するかどうかは、次のアクション次第です。フラッシュからのエラーアラートや通知をアプリケーションのレイアウトで表示するのが一般的です。
```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

この方法では、アクションが通知またはアラートメッセージを設定した場合、レイアウトは自動的に表示されます。

セッションが保存できるものなら何でも渡すことができます。通知やアラートに限定されません。

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Welcome to our site!</p>
<% end %>
```

フラッシュの値を別のリクエストに引き継ぐ場合は、[`flash.keep`][]を使用します。

```ruby
class MainController < ApplicationController
  # このアクションはroot_urlに対応するものですが、ここにリダイレクトされるすべてのリクエストをUsersController#indexにリダイレクトしたい場合があります。
  # アクションがフラッシュを設定してここにリダイレクトすると、別のリダイレクトが発生すると値は通常失われますが、'keep'を使用して別のリクエストで永続化することができます。
  def index
    # すべてのフラッシュの値を永続化します。
    flash.keep

    # 特定の種類の値のみを保持するためにキーを使用することもできます。
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### `flash.now`

デフォルトでは、フラッシュに値を追加すると、次のリクエストでそれらの値にアクセスできるようになりますが、同じリクエストでそれらの値にアクセスしたい場合もあります。たとえば、`create`アクションがリソースの保存に失敗し、`new`テンプレートを直接レンダリングする場合、新しいリクエストは発生しませんが、フラッシュを使用してメッセージを表示したい場合があります。これを行うには、通常の`flash`と同じように[`flash.now`][]を使用できます。

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Could not save client"
      render action: "new"
    end
  end
end
```


Cookies
-------

アプリケーションは、クライアントに小さなデータを保存することができます。これはクッキーと呼ばれ、リクエストやセッションを超えて永続化されます。Railsは[`cookies`][]メソッドを介してクッキーへの簡単なアクセスを提供します。これは`session`と同様にハッシュのように動作します。

```ruby
class CommentsController < ApplicationController
  def new
    # クッキーにコメント者の名前が保存されている場合は、自動的にコメント者の名前を入力します。
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # コメント者の名前を記憶します。
        cookies[:commenter_name] = @comment.author
      else
        # コメント者の名前のクッキーを削除します。
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

セッションの値に対してキーを`nil`に設定することで値を削除できますが、クッキーの値を削除する場合は`cookies.delete(:key)`を使用する必要があります。

Railsは、署名付きクッキージャーと暗号化されたクッキージャーも提供しており、機密データを保存するために使用できます。署名付きクッキージャーは、クッキー値に暗号署名を追加してその完全性を保護します。暗号化されたクッキージャーは、署名に加えて値を暗号化するため、エンドユーザーによって読み取ることができません。詳細については、[APIドキュメント](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)を参照してください。

これらの特別なクッキージャーは、シリアライザを使用して割り当てられた値を文字列にシリアライズし、読み取り時にRubyオブジェクトに逆シリアル化します。[`config.action_dispatch.cookies_serializer`][]を使用して使用するシリアライザを指定できます。

新しいアプリケーションのデフォルトシリアライザは`:json`です。JSONはRubyオブジェクトのラウンドトリップに対して制限があることに注意してください。たとえば、`Date`、`Time`、および`Symbol`オブジェクト（`Hash`キーを含む）は、`String`にシリアライズおよび逆シリアル化されます。

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

これらやより複雑なオブジェクトを保存する必要がある場合は、後続のリクエストでそれらの値を読み取るときに値を手動で変換する必要がある場合があります。

クッキーセッションストアを使用する場合、上記は`session`と`flash`ハッシュにも適用されます。


レンダリング
---------

ActionControllerを使用すると、HTML、XML、またはJSONデータのレンダリングが容易になります。スキャフォールディングを使用してコントローラを生成した場合、次のようになります。

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

上記のコードでは、`render xml: @users`ではなく`render xml: @users.to_xml`を使用していることに注意してください。オブジェクトが文字列でない場合、Railsは自動的に`to_xml`を呼び出します。
レンダリングについては、[レイアウトとレンダリングガイド](layouts_and_rendering.html)で詳細を学ぶことができます。

フィルター
-------

フィルターは、コントローラーアクションの「前」「後」「周囲」で実行されるメソッドです。

フィルターは継承されるため、`ApplicationController`でフィルターを設定すると、アプリケーション内のすべてのコントローラーで実行されます。

「前」フィルターは、[`before_action`]を介して登録されます。リクエストサイクルを停止することがあります。一般的な「前」フィルターは、アクションの実行にユーザーのログインが必要なものです。フィルターメソッドは次のように定義できます。

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "このセクションにアクセスするにはログインする必要があります"
        redirect_to new_login_url # リクエストサイクルを停止
      end
    end
end
```

このメソッドは、ユーザーがログインしていない場合にフラッシュにエラーメッセージを保存し、ログインフォームにリダイレクトします。もし「前」フィルターがレンダリングまたはリダイレクトを行った場合、アクションは実行されません。そのフィルターの後に実行される予定の追加のフィルターもキャンセルされます。

この例では、フィルターが`ApplicationController`に追加され、したがってアプリケーション内のすべてのコントローラーがそれを継承します。これにより、アプリケーション内のすべてのものが使用するためにユーザーのログインが必要になります。明らかな理由から（最初にログインできないため！）、すべてのコントローラーやアクションがこれを必要とするわけではありません。[`skip_before_action`]を使用して、特定のアクションの前でこのフィルターが実行されないようにすることができます。

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

これにより、`LoginsController`の`new`と`create`アクションは、ユーザーがログインしている必要がないままで動作します。`only`オプションは、これらのアクションのみでこのフィルターをスキップするために使用され、逆の方法で機能する`except`オプションもあります。これらのオプションは、フィルターを追加する際にも使用できるため、最初から選択したアクションのみで実行されるフィルターを追加することができます。

注意：同じフィルターを異なるオプションで複数回呼び出すことはできません。最後のフィルター定義が前の定義を上書きします。


### 「後」フィルターと「周囲」フィルター

「前」フィルターに加えて、アクションが実行された後にフィルターを実行したり、アクションの前後の両方でフィルターを実行したりすることもできます。

「後」フィルターは、[`after_action`]を介して登録されます。これらは「前」フィルターと似ていますが、アクションが既に実行されているため、クライアントに送信されるレスポンスデータにアクセスできます。明らかに、「後」フィルターはアクションの実行を停止することはできません。なお、「後」フィルターは、リクエストサイクルで例外が発生した場合を除いて、成功したアクションの後にのみ実行されます。

「周囲」フィルターは、[`around_action`]を介して登録されます。関連するアクションを実行するために、yieldを使用します。これはRackミドルウェアの動作と似ています。

たとえば、変更に承認ワークフローがあるウェブサイトでは、管理者はトランザクション内で変更を適用することで簡単にプレビューすることができます。

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

「周囲」フィルターはレンダリングもラップします。特に上記の例では、ビュー自体がデータベースから読み取る場合（スコープを介してなど）、トランザクション内で読み取りが行われ、プレビュー用のデータが表示されます。

yieldせずにレスポンスを自分で構築することも選択できます。その場合、アクションは実行されません。


### フィルターの他の使用方法

フィルターを使用する最も一般的な方法は、プライベートメソッドを作成し、`before_action`、`after_action`、または`around_action`を使用してそれらを追加することですが、同じことを行うための他の2つの方法もあります。

最初の方法は、`*_action`メソッドと直接ブロックを使用する方法です。ブロックはコントローラーを引数として受け取ります。上記の`require_login`フィルターは、ブロックを使用して次のように書き直すことができます。

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "このセクションにアクセスするにはログインする必要があります"
      redirect_to new_login_url
    end
  end
end
```

この場合、フィルターは`send`を使用しています。なぜなら、`logged_in?`メソッドはプライベートであり、フィルターはコントローラーのスコープで実行されないからです。これは、この特定のフィルターを実装するための推奨される方法ではありませんが、より単純な場合には役立つ場合があります。
特に`around_action`について、ブロックは`action`でも呼び出されます。

```ruby
around_action { |_controller, action| time(&action) }
```

2番目の方法は、フィルタリングを処理するためにクラス（実際には、適切なメソッドに応答する任意のオブジェクト）を使用することです。これは、より複雑で、他の2つの方法では読みやすく再利用可能な方法で実装できない場合に便利です。例えば、ログインフィルタを再度クラスを使用して書き直すことができます。

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

再度、このフィルタには理想的な例ではありません。なぜなら、コントローラのスコープではなく、引数としてコントローラが渡されるからです。フィルタクラスは、フィルタと同じ名前のメソッドを実装する必要があります。したがって、`before_action`フィルタの場合、クラスは`before`メソッドを実装する必要があります。`around`メソッドはアクションを実行するために`yield`する必要があります。

リクエスト偽装防止
--------------------------

クロスサイトリクエストフォージェリ（CSRF）は、サイトがユーザーを騙して、ユーザーの知識や許可なしに他のサイトにリクエストを送信し、データを追加、変更、削除する攻撃の一種です。

これを回避するための最初のステップは、すべての「破壊的な」アクション（作成、更新、削除）にはGETリクエスト以外でのアクセスしかできないようにすることです。RESTfulな規約に従っている場合、すでにこれを行っています。ただし、悪意のあるサイトは簡単に非GETリクエストをあなたのサイトに送信することができます。そのため、リクエスト偽装防止が必要です。その名前が示すように、偽装されたリクエストから保護します。

これは、サーバーだけが知っている予測不可能なトークンを各リクエストに追加することで行われます。これにより、適切なトークンのないリクエストが来た場合、アクセスが拒否されます。

次のようなフォームを生成する場合：

```erb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

トークンが隠しフィールドとして追加されるのがわかります：

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Railsは、[フォームヘルパー](form_helpers.html)を使用して生成されたすべてのフォームにこのトークンを追加しますので、ほとんどの場合は心配する必要はありません。フォームを手動で作成するか、他の理由でトークンを追加する必要がある場合は、`form_authenticity_token`メソッドを使用して取得できます。

`form_authenticity_token`は有効な認証トークンを生成します。これは、Railsが自動的に追加しない場所（カスタムAjax呼び出しなど）で便利です。

[セキュリティガイド](security.html)には、これについての詳細な説明と、Webアプリケーションを開発する際に意識すべき他のセキュリティ関連の問題があります。

リクエストとレスポンスオブジェクト
--------------------------------

すべてのコントローラには、現在実行中のリクエストサイクルに関連付けられたリクエストおよびレスポンスオブジェクトを指す2つのアクセサメソッドがあります。[`request`][]メソッドには[`ActionDispatch::Request`][]のインスタンスが含まれ、[`response`][]メソッドはクライアントに送信されるレスポンスオブジェクトを返します。


### `request`オブジェクト

リクエストオブジェクトには、クライアントからのリクエストに関する多くの有用な情報が含まれています。利用可能なメソッドの完全なリストについては、[Rails APIドキュメント](https://api.rubyonrails.org/classes/ActionDispatch/Request.html)と[Rackドキュメント](https://www.rubydoc.info/github/rack/rack/Rack/Request)を参照してください。このオブジェクトでアクセスできるプロパティの一部は次のとおりです。

| `request`のプロパティ                     | 目的                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `host`                                    | このリクエストに使用されたホスト名。                                              |
| `domain(n=2)`                             | ホスト名の右側（TLD）から始まる最初の`n`セグメントのホスト名。            |
| `format`                                  | クライアントが要求したコンテンツタイプ。                                        |
| `method`                                  | リクエストに使用されたHTTPメソッド。                                            |
| `get?`, `post?`, `patch?`, `put?`, `delete?`, `head?` | HTTPメソッドがGET/POST/PATCH/PUT/DELETE/HEADの場合はtrueを返します。   |
| `headers`                                 | リクエストに関連するヘッダーを含むハッシュを返します。               |
| `port`                                    | リクエストに使用されるポート番号（整数）。                                  |
| `protocol`                                | 使用されるプロトコルと「://」を含む文字列を返します。 例：「http://」 |
| `query_string`                            | URLのクエリ文字列部分、「?」以降のすべて。                    |
| `remote_ip`                               | クライアントのIPアドレス。                                                    |
| `url`                                     | リクエストに使用される完全なURL。                                             |
#### `path_parameters`、`query_parameters`、および `request_parameters`

Railsは、クエリ文字列やPOSTボディの一部として送信されたすべてのパラメータを、`params`ハッシュに収集します。リクエストオブジェクトには、これらのパラメータにアクセスするための3つのアクセサがあります。[`query_parameters`][]ハッシュには、クエリ文字列の一部として送信されたパラメータが含まれています。[`request_parameters`][]ハッシュには、POSTボディの一部として送信されたパラメータが含まれています。[`path_parameters`][]ハッシュには、この特定のコントローラとアクションに至るパスの一部としてルーティングによって認識されたパラメータが含まれています。


### `response`オブジェクト

通常、レスポンスオブジェクトは直接使用されることはありませんが、アクションの実行とデータのレンダリング中に構築され、ユーザーに送信されるデータにアクセスするために直接レスポンスにアクセスすることがあります。これらのアクセサメソッドの一部には、値を変更することができるセッターもあります。使用可能なメソッドの完全なリストについては、[Rails APIドキュメント](https://api.rubyonrails.org/classes/ActionDispatch/Response.html)と[Rackドキュメント](https://www.rubydoc.info/github/rack/rack/Rack/Response)を参照してください。

| `response`のプロパティ | 目的                                                                                                 |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `body`                 | クライアントに送信されるデータの文字列です。通常はHTMLです。                                         |
| `status`               | レスポンスのHTTPステータスコード。例えば、成功したリクエストの場合は200、ファイルが見つからない場合は404です。 |
| `location`             | クライアントがリダイレクトされるURL（ある場合）。                                                   |
| `content_type`         | レスポンスのコンテンツタイプ。                                                                       |
| `charset`              | レスポンスに使用される文字セット。デフォルトは "utf-8" です。                                       |
| `headers`              | レスポンスに使用されるヘッダー。                                                                     |

#### カスタムヘッダーの設定

レスポンスにカスタムヘッダーを設定する場合は、`response.headers`を使用します。`headers`属性は、ヘッダー名を値にマッピングするハッシュであり、Railsはいくつかのヘッダーを自動的に設定します。ヘッダーを追加または変更する場合は、次のように`response.headers`に代入するだけです。

```ruby
response.headers["Content-Type"] = "application/pdf"
```

注意：上記の場合、`content_type`セッターを直接使用する方が意味があります。

HTTP認証
--------------------

Railsには、3つの組み込みのHTTP認証メカニズムがあります。

* ベーシック認証
* ダイジェスト認証
* トークン認証

### ベーシック認証

ベーシック認証は、ほとんどのブラウザや他のHTTPクライアントでサポートされている認証スキームです。例として、ユーザー名とパスワードをブラウザのHTTPベーシックダイアログウィンドウに入力することでのみ利用可能な管理セクションを考えてみましょう。組み込みの認証を使用するには、[`http_basic_authenticate_with`][]メソッドを使用するだけです。

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

これを設定すると、`AdminsController`から継承する名前空間のコントローラを作成できます。このフィルタは、これらのコントローラのすべてのアクションで実行され、HTTPベーシック認証で保護されます。


### ダイジェスト認証

ダイジェスト認証は、基本認証よりも優れた認証方法です。なぜなら、クライアントがネットワーク上で暗号化されていないパスワードを送信する必要がないからです（ただし、HTTPベーシック認証はHTTPS上では安全です）。Railsでダイジェスト認証を使用するには、[`authenticate_or_request_with_http_digest`][]メソッドを使用するだけです。

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

上記の例のように、`authenticate_or_request_with_http_digest`ブロックは1つの引数（ユーザー名）を取ります。ブロックはパスワードを返します。`authenticate_or_request_with_http_digest`から`false`または`nil`を返すと、認証に失敗します。


### トークン認証

トークン認証は、HTTP `Authorization`ヘッダーでBearerトークンを使用するためのスキームです。利用可能なトークン形式は多数あり、それらの詳細についてはこのドキュメントの範囲外です。

例えば、事前に発行された認証トークンを使用して認証とアクセスを行いたい場合を考えてみましょう。Railsでトークン認証を実装するには、[`authenticate_or_request_with_http_token`][]メソッドを使用するだけです。

```ruby
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

上記の例のように、`authenticate_or_request_with_http_token`ブロックは2つの引数（トークンとHTTP `Authorization`ヘッダーから解析されたオプションを含む`Hash`）を取ります。ブロックは認証が成功した場合に`true`を返す必要があります。`authenticate_or_request_with_http_token`から`false`または`nil`を返すと、認証に失敗します。
ストリーミングとファイルのダウンロード
----------------------------

HTMLページをレンダリングする代わりに、ファイルをユーザーに送信したい場合があります。Railsのすべてのコントローラーには、[`send_data`][]と[`send_file`][]メソッドがあり、どちらもデータをクライアントにストリーミングします。`send_file`は、ディスク上のファイルの名前を指定し、そのファイルの内容をストリーミングする便利なメソッドです。

クライアントにデータをストリーミングするには、`send_data`を使用します：

```ruby
require "prawn"
class ClientsController < ApplicationController
  # クライアントの情報を含むPDFドキュメントを生成し、返します。ユーザーはPDFをファイルとしてダウンロードします。
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "住所：#{client.address}"
        text "メール：#{client.email}"
      end.render
    end
end
```

上記の例の`download_pdf`アクションは、実際にPDFドキュメントを生成して文字列として返すプライベートメソッドを呼び出します。この文字列は、ファイルとしてダウンロードされるためにクライアントにストリーミングされ、ユーザーにファイル名が提案されます。ファイルをユーザーにストリーミングする場合、ファイルをダウンロードさせたくない場合があります。例えば、HTMLページに埋め込むことができる画像です。ファイルがダウンロードされないようにブラウザに伝えるには、`:disposition`オプションを「inline」に設定します。このオプションの逆でデフォルトの値は「attachment」です。


### ファイルの送信

ディスク上に既に存在するファイルを送信する場合は、`send_file`メソッドを使用します。

```ruby
class ClientsController < ApplicationController
  # 既に生成されディスク上に保存されたファイルをストリーミングします。
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

これにより、ファイルを4KBずつ読み取り、ストリーミングします。一度にファイル全体をメモリに読み込むことを避けるためです。ストリーミングをオフにするには、`:stream`オプションをオフにするか、ブロックサイズを`:buffer_size`オプションで調整できます。

`:type`が指定されていない場合、`:filename`で指定されたファイル拡張子から推測されます。拡張子に対してコンテンツタイプが登録されていない場合は、`application/octet-stream`が使用されます。

警告：クライアントからのデータ（params、cookiesなど）を使用してディスク上のファイルを検索する場合は注意してください。これはセキュリティリスクであり、意図しないファイルにアクセスできる可能性があります。

TIP：可能であれば、静的ファイルをRailsを介してストリーミングするのではなく、Webサーバーのパブリックフォルダに保持することをお勧めします。ユーザーにApacheや他のWebサーバーを使用してファイルを直接ダウンロードさせることで、リクエストがRailsのスタック全体を通過するのを不必要に防ぐことができます。

### RESTfulなダウンロード

`send_data`は問題ありませんが、RESTfulなアプリケーションを作成している場合、ファイルのダウンロードのために別々のアクションを作成する必要はありません。RESTの用語では、上記の例のPDFファイルはクライアントリソースの別の表現と見なすことができます。Railsには「RESTful」なダウンロードを行うためのスマートな方法が用意されています。以下は、ダウンロードがストリーミングなしで`show`アクションの一部としてPDFダウンロードに書き換える方法です：

```ruby
class ClientsController < ApplicationController
  # ユーザーはこのリソースをHTMLまたはPDFとして受け取ることを要求できます。
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

この例が動作するためには、RailsにPDFのMIMEタイプを追加する必要があります。これは、`config/initializers/mime_types.rb`ファイルに次の行を追加することで行うことができます：

```ruby
Mime::Type.register "application/pdf", :pdf
```

注意：設定ファイルは各リクエストでリロードされませんので、変更が反映されるようにサーバーを再起動する必要があります。

これで、ユーザーはURLに「.pdf」を追加するだけで、クライアントのPDFバージョンをリクエストできます：

```
GET /clients/1.pdf
```

### 任意のデータのライブストリーミング

Railsでは、ファイルだけでなく、他の任意のデータもストリーミングすることができます。実際には、レスポンスオブジェクトで任意のデータをストリーミングすることができます。[`ActionController::Live`][]モジュールを使用すると、ブラウザとの持続的な接続を作成できます。このモジュールを使用すると、特定のタイミングでブラウザに任意のデータを送信することができます。
#### ライブストリーミングの組み込み

コントローラクラス内に`ActionController::Live`を含めると、コントローラ内のすべてのアクションでデータのストリーミングが可能になります。以下のようにモジュールをミックスインすることができます。

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

上記のコードは、ブラウザとの持続的な接続を維持し、1秒ごとに"hello world\n"というメッセージを100回送信します。

上記の例にはいくつかの注意点があります。レスポンスストリームを閉じることを忘れないようにする必要があります。ストリームを閉じずに放置すると、ソケットが永久に開いたままになります。また、レスポンスストリームに書き込む前にコンテンツタイプを`text/event-stream`に設定する必要があります。これは、レスポンスがコミットされた後（`response.committed?`が真の値を返すとき）にヘッダを書き込むことができないためです。レスポンスストリームを`write`または`commit`すると、コミットが行われます。

#### 使用例

カラオケマシンを作成しているとしましょう。ユーザーが特定の曲の歌詞を取得したい場合、各`Song`には特定の行数があり、各行は歌い終わるのに`num_beats`の時間がかかります。

もしも歌詞をカラオケ形式で返す（前の行が終わった後に次の行を送信する）場合、`ActionController::Live`を以下のように使用できます。

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

上記のコードは、前の行が終わった後に次の行を送信します。

#### ストリーミングの考慮事項

任意のデータをストリーミングすることは非常に強力なツールです。前の例に示されているように、レスポンスストリームでいつ何を送信するかを選択することができます。ただし、以下の点にも注意する必要があります。

* 各レスポンスストリームは新しいスレッドを作成し、元のスレッドからスレッドローカル変数をコピーします。スレッドローカル変数が多すぎるとパフォーマンスに悪影響を与える可能性があります。同様に、大量のスレッドもパフォーマンスを低下させる可能性があります。
* レスポンスストリームを閉じるのを忘れると、対応するソケットが永久に開いたままになります。レスポンスストリームを使用する場合は、必ず`close`を呼び出してください。
* WEBrickサーバーはすべてのレスポンスをバッファリングするため、`ActionController::Live`を含めることはできません。自動的にレスポンスをバッファリングしないWebサーバーを使用する必要があります。

ログのフィルタリング
-------------

Railsは、`log`フォルダ内の各環境ごとにログファイルを保持しています。これらはアプリケーションの実際の動作をデバッグする際に非常に便利ですが、ライブアプリケーションではすべての情報をログファイルに保存したくない場合があります。

### パラメータのフィルタリング

アプリケーションの設定で[`config.filter_parameters`][]にフィルタリングしたい機密情報のリクエストパラメータを追加することで、ログファイルから機密情報をフィルタリングすることができます。これらのパラメータはログ内で[FILTERED]とマークされます。

```ruby
config.filter_parameters << :password
```

注意：指定されたパラメータは部分一致の正規表現でフィルタリングされます。Railsは、`password`、`password_confirmation`、`my_token`などの一般的なアプリケーションパラメータを処理するために、適切なイニシャライザ（`initializers/filter_parameter_logging.rb`）にデフォルトのフィルタリスト（`:passw`、`:secret`、`:token`など）を追加します。


### リダイレクトのフィルタリング

アプリケーションがリダイレクトしている機密の場所をログファイルからフィルタリングすることが望ましい場合があります。`config.filter_redirect`構成オプションを使用することで、それが可能です。

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

これは、文字列、正規表現、またはその両方の配列に設定することができます。

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

一致するURLは'[FILTERED]'とマークされます。

Rescue
------

おそらく、アプリケーションにはバグが含まれているか、それ以外の例外が発生し、それを処理する必要があります。たとえば、ユーザーがデータベースに存在しないリソースへのリンクをたどる場合、Active Recordは`ActiveRecord::RecordNotFound`例外をスローします。

Railsのデフォルトの例外処理では、すべての例外に対して「500 Server Error」というメッセージが表示されます。リクエストがローカルで行われた場合、トレースバックと追加情報が表示されるため、何が間違っているのかを特定して対処することができます。リクエストがリモートである場合、Railsはユーザーに対して単純な「500 Server Error」というメッセージ、またはルーティングエラーがあった場合は「404 Not Found」というメッセージ、またはレコードが見つからなかった場合は「500 Server Error」というメッセージを表示します。これらのエラーがどのようにキャッチされ、ユーザーに表示されるかをカスタマイズしたい場合、Railsアプリケーションではいくつかのレベルの例外処理が利用可能です。
### デフォルトの500と404のテンプレート

デフォルトでは、本番環境ではアプリケーションは404エラーメッセージまたは500エラーメッセージをレンダリングします。開発環境では、すべての未処理の例外が単に発生します。これらのメッセージは、publicフォルダ内の静的なHTMLファイルである`404.html`および`500.html`に含まれています。これらのファイルをカスタマイズして、追加の情報やスタイルを追加することができますが、これらは静的なHTMLです。つまり、ERB、SCSS、CoffeeScript、またはレイアウトを使用することはできません。

### `rescue_from`

エラーをキャッチする際にもう少し複雑な処理を行いたい場合は、[`rescue_from`][]を使用できます。これは、特定のタイプ（または複数のタイプ）の例外をコントローラ全体およびそのサブクラスで処理します。

`rescue_from`ディレクティブによってキャッチされる例外が発生すると、例外オブジェクトがハンドラに渡されます。ハンドラは、メソッドまたは`:with`オプションに渡される`Proc`オブジェクトです。明示的な`Proc`オブジェクトの代わりに、ブロックを直接使用することもできます。

以下は、`rescue_from`を使用してすべての`ActiveRecord::RecordNotFound`エラーをキャッチし、それらに対して何かしらの処理を行う方法です。

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

もちろん、この例は複雑さを増し、デフォルトの例外処理を改善するわけではありませんが、これらの例外をキャッチできるようになると、自由に処理を行うことができます。たとえば、アプリケーションの特定のセクションにアクセス権限がない場合にスローされるカスタム例外クラスを作成することができます。

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "このセクションにアクセスする権限がありません。"
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # ユーザーがクライアントにアクセスするための適切な権限を持っているかを確認します。
  before_action :check_authorization

  # アクションはすべての認証について心配する必要がないことに注意してください。
  def edit
    @client = Client.find(params[:id])
  end

  private
    # ユーザーが認可されていない場合は、例外をスローします。
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

警告：`Exception`または`StandardError`と`rescue_from`を使用すると、Railsが例外を適切に処理できなくなり、重大な副作用が発生する可能性があります。そのため、強い理由がない限り、これを行うことはお勧めしません。

注意：本番環境で実行する場合、すべての`ActiveRecord::RecordNotFound`エラーは404エラーページをレンダリングします。カスタムの動作が必要でない限り、これを処理する必要はありません。

注意：特定の例外は、コントローラが初期化される前に発生し、アクションが実行されるため、`ApplicationController`クラスからのみ救済できます。

HTTPSプロトコルの強制
--------------------

コントローラへの通信がHTTPSでのみ可能であることを確認したい場合は、[`config.force_ssl`][]を使用して[`ActionDispatch::SSL`][]ミドルウェアを有効にすることで実現できます。

組み込みのヘルスチェックエンドポイント
------------------------------

Railsには、`/up`パスでアクセス可能な組み込みのヘルスチェックエンドポイントも用意されています。このエンドポイントは、アプリケーションが例外なしで起動した場合には200のステータスコードを返し、それ以外の場合には500のステータスコードを返します。

本番環境では、多くのアプリケーションはステータスを上流に報告する必要があります。これは、障害が発生した場合にエンジニアに通知するアップタイムモニター、ポッドのヘルスを判断するために使用されるロードバランサーまたはKubernetesコントローラなどです。このヘルスチェックは、多くの状況で動作するワンサイズフィットオールの設計です。

新しく生成されたRailsアプリケーションでは、ヘルスチェックは`/up`にありますが、"config/routes.rb"でパスを任意のものに設定することができます。

```ruby
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

ヘルスチェックは、`/healthz`パスを介してアクセスできるようになります。

注意：このエンドポイントは、データベースやRedisクラスタなど、アプリケーションのすべての依存関係の状態を反映していません。アプリケーション固有のニーズがある場合は、"rails/health#show"を独自のコントローラアクションに置き換えてください。

チェックする内容については慎重に考えてください。サードパーティのサービスが悪化したためにアプリケーションが再起動される状況になる可能性があります。理想的には、アプリケーションを障害が発生しても正常に処理できるように設計する必要があります。
[`ActionController::Base`]: https://api.rubyonrails.org/classes/ActionController/Base.html
[`params`]: https://api.rubyonrails.org/classes/ActionController/StrongParameters.html#method-i-params
[`wrap_parameters`]: https://api.rubyonrails.org/classes/ActionController/ParamsWrapper/Options/ClassMethods.html#method-i-wrap_parameters
[`controller_name`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-controller_name
[`action_name`]: https://api.rubyonrails.org/classes/AbstractController/Base.html#method-i-action_name
[`permit`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit
[`permit!`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-permit-21
[`require`]: https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-require
[`ActionDispatch::Session::CookieStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html
[`ActionDispatch::Session::CacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/CacheStore.html
[`ActionDispatch::Session::MemCacheStore`]: https://api.rubyonrails.org/classes/ActionDispatch/Session/MemCacheStore.html
[activerecord-session_store]: https://github.com/rails/activerecord-session_store
[`reset_session`]: https://api.rubyonrails.org/classes/ActionController/Metal.html#method-i-reset_session
[`flash`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/RequestMethods.html#method-i-flash
[`flash.keep`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-keep
[`flash.now`]: https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html#method-i-now
[`config.action_dispatch.cookies_serializer`]: configuring.html#config-action-dispatch-cookies-serializer
[`cookies`]: https://api.rubyonrails.org/classes/ActionController/Cookies.html#method-i-cookies
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`skip_before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-skip_before_action
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`ActionDispatch::Request`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[`request`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-request
[`response`]: https://api.rubyonrails.org/classes/ActionController/Base.html#method-i-response
[`path_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Http/Parameters.html#method-i-path_parameters
[`query_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters
[`request_parameters`]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters
[`http_basic_authenticate_with`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Basic/ControllerMethods/ClassMethods.html#method-i-http_basic_authenticate_with
[`authenticate_or_request_with_http_digest`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Digest/ControllerMethods.html#method-i-authenticate_or_request_with_http_digest
[`authenticate_or_request_with_http_token`]: https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html#method-i-authenticate_or_request_with_http_token
[`send_data`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_data
[`send_file`]: https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file
[`ActionController::Live`]: https://api.rubyonrails.org/classes/ActionController/Live.html
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`config.force_ssl`]: configuring.html#config-force-ssl
[`ActionDispatch::SSL`]: https://api.rubyonrails.org/classes/ActionDispatch/SSL.html
