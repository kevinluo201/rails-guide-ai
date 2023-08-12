**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 02f663dc709da76ced45deb2ba800a78
Railsにおけるレイアウトとレンダリング
==============================

このガイドでは、Action ControllerとAction Viewの基本的なレイアウト機能について説明します。

このガイドを読み終えると、以下のことがわかるようになります：

* Railsに組み込まれたさまざまなレンダリングメソッドの使用方法。
* 複数のコンテンツセクションを持つレイアウトの作成方法。
* ビューをDRYにするためのパーシャルの使用方法。
* ネストされたレイアウト（サブテンプレート）の使用方法。

--------------------------------------------------------------------------------

概要：各要素の関係
-------------------------------------

このガイドでは、モデル-ビュー-コントローラ（MVC）の三角形におけるコントローラとビューの相互作用に焦点を当てています。ご存知の通り、コントローラはRailsにおけるリクエストの処理全体を組織する責任を持っていますが、通常は重いコードをモデルに委譲します。しかし、ユーザーにレスポンスを返す時には、コントローラはビューに処理を引き継ぎます。この引き継ぎがこのガイドの主題です。

大まかに言えば、これはどのようなレスポンスを送信するかを決定し、それを作成するための適切なメソッドを呼び出すことを含みます。レスポンスが完全なビューである場合、Railsはビューをレイアウトでラップし、パーシャルビューを取り込むための追加の作業も行います。これらのパスは、このガイドの後半で説明します。

レスポンスの作成
------------------

コントローラの観点からは、HTTPレスポンスを作成する方法は3つあります：

* [`render`][controller.render]を呼び出して、ブラウザに送信するための完全なレスポンスを作成する
* [`redirect_to`][]を呼び出して、ブラウザにHTTPリダイレクトステータスコードを送信する
* [`head`][]を呼び出して、ブラウザに送信するためのHTTPヘッダのみからなるレスポンスを作成する


### デフォルトでのレンダリング：アクションにおける慣例の優先

Railsは「慣例よりも設定」を推進していることを聞いたことがあるかもしれません。デフォルトのレンダリングは、これの優れた例です。Railsでは、デフォルトでは、有効なルートに対応する名前のビューを自動的にレンダリングするようにコントローラが設定されています。たとえば、`BooksController`クラスに次のコードがある場合：

```ruby
class BooksController < ApplicationController
end
```

そして、ルートファイルに次のコードがある場合：

```ruby
resources :books
```

そして、`app/views/books/index.html.erb`というビューファイルがある場合：

```html+erb
<h1>Books are coming soon!</h1>
```

`/books`に移動すると、Railsは自動的に`app/views/books/index.html.erb`をレンダリングし、「Books are coming soon!」が画面に表示されます。

ただし、まだまだ準備中の画面は最小限の有用性しかありませんので、すぐに`Book`モデルを作成し、`BooksController`にインデックスアクションを追加します：

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

「慣例よりも設定」の原則に従って、インデックスアクションの最後に明示的なレンダリングがないことに注意してください。ルールは、コントローラのアクションの最後に何も明示的にレンダリングしない場合、Railsはコントローラのビューパスにある`action_name.html.erb`テンプレートを自動的に探し、それをレンダリングします。したがって、この場合、Railsは`app/views/books/index.html.erb`ファイルをレンダリングします。

ビューにすべての書籍のプロパティを表示したい場合、次のようなERBテンプレートを使用できます：

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

注意：実際のレンダリングは、[`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html)モジュールのネストされたクラスによって行われます。このガイドではそのプロセスには詳しく触れませんが、ビューのファイル拡張子はテンプレートハンドラの選択を制御するため、重要なことを知っておく必要があります。

### `render`の使用

ほとんどの場合、コントローラの[`render`][controller.render]メソッドが、ブラウザで使用するためにアプリケーションのコンテンツをレンダリングするための重要な役割を果たします。`render`の動作をカスタマイズする方法はさまざまあります。Railsテンプレートのデフォルトビューをレンダリングしたり、特定のテンプレートやファイル、インラインコード、何もレンダリングしないようにしたりできます。テキスト、JSON、XMLをレンダリングすることもできます。レンダリングされるレスポンスのコンテンツタイプやHTTPステータスも指定できます。

TIP: ブラウザでの検査を必要とせずに、`render`の呼び出しの正確な結果を確認したい場合は、`render_to_string`を呼び出すことができます。このメソッドは`render`とまったく同じオプションを受け取りますが、レスポンスをブラウザに送信する代わりに、文字列を返します。
#### アクションのビューをレンダリングする

同じコントローラ内の別のテンプレートに対応するビューをレンダリングしたい場合は、`render`を使用してビューの名前を指定することができます。

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

`update`の呼び出しが失敗した場合、このコントローラ内の`update`アクションは、同じコントローラに属する`edit.html.erb`テンプレートをレンダリングします。

もし好みであれば、文字列の代わりにシンボルを使用してレンダリングするアクションを指定することもできます。

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```

#### 別のコントローラのアクションのテンプレートをレンダリングする

アクションコードを含むコントローラとは異なるコントローラのテンプレートをレンダリングしたい場合は、`render`を使用してレンダリングするテンプレートの完全なパス（`app/views`に対する相対パス）を指定することもできます。たとえば、`app/controllers/admin`に存在する`AdminProductsController`でコードを実行している場合、次のようにして`app/views/products`のテンプレートの結果をレンダリングすることができます。

```ruby
render "products/show"
```

スラッシュ文字が文字列に埋め込まれているため、Railsはこのビューが別のコントローラに属していることを認識します。明示的にする場合は、`template`オプションを使用することもできます（Rails 2.2以前では必須でした）。

```ruby
render template: "products/show"
```

#### まとめ

上記の2つのレンダリング方法（同じコントローラ内の別のアクションのテンプレートをレンダリングし、異なるコントローラの別のアクションのテンプレートをレンダリングする）は、実際には同じ操作のバリエーションです。

実際には、`BooksController`クラスの`update`アクション内で、本が正常に更新されない場合に`edit.html.erb`テンプレートを`views/books`ディレクトリにレンダリングするため、次のすべてのレンダリング呼び出しは同じ結果をもたらします。

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

どれを使用するかはスタイルと慣習の問題ですが、書いているコードに合理的な最もシンプルなものを使用することが原則です。

#### `render`と`:inline`の使用

`render`メソッドは、メソッド呼び出しの一部としてERBを提供するために、ビューを完全に使用しないこともできます。これは完全に有効な方法です。

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

警告：このオプションを使用する良い理由はほとんどありません。コントローラにERBを混ぜ込むことは、RailsのMVC指向に反するものであり、他の開発者がプロジェクトのロジックを追うのが難しくなります。代わりに別のerbビューを使用してください。

デフォルトでは、インラインレンダリングはERBを使用します。`:type`オプションを使用して代わりにBuilderを使用するように強制することもできます。

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### テキストのレンダリング

`render`の`:plain`オプションを使用して、ブラウザにマークアップのないプレーンテキストを送信することができます。

```ruby
render plain: "OK"
```

TIP: 純粋なテキストをレンダリングするのは、正しいHTML以外のものを期待しているAjaxやWebサービスのリクエストに応答する場合に最も役立ちます。

注意: `:plain`オプションを使用すると、テキストは現在のレイアウトを使用せずにレンダリングされます。テキストを現在のレイアウトに配置するには、`layout: true`オプションを追加し、レイアウトファイルの拡張子に`.text.erb`を使用する必要があります。

#### HTMLのレンダリング

`render`の`:html`オプションを使用して、HTML文字列をブラウザに送信することができます。

```ruby
render html: helpers.tag.strong('Not Found')
```

TIP: これは、小さなHTMLコードの断片をレンダリングする場合に便利です。ただし、マークアップが複雑な場合は、テンプレートファイルに移動することを検討することもあります。

注意: `html:`オプションを使用する場合、HTMLエンティティは、文字列が`html_safe`対応のAPIと組み合わされていない場合にエスケープされます。

#### JSONのレンダリング

JSONは、多くのAjaxライブラリで使用されるJavaScriptデータ形式です。Railsには、オブジェクトをJSONに変換し、そのJSONをブラウザにレンダリングするための組み込みサポートがあります。

```ruby
render json: @product
```

TIP: レンダリングしたいオブジェクトに対して`to_json`を呼び出す必要はありません。`json`オプションを使用する場合、`render`は自動的に`to_json`を呼び出します。
#### XMLのレンダリング

Railsには、オブジェクトをXMLに変換し、そのXMLを呼び出し元にレンダリングするための組み込みサポートもあります。

```ruby
render xml: @product
```

TIP: レンダリングしたいオブジェクトに`to_xml`を呼び出す必要はありません。`render`を使用する場合、`to_xml`は自動的に呼び出されます。

#### バニラJavaScriptのレンダリング

RailsはバニラJavaScriptをレンダリングすることもできます。

```ruby
render js: "alert('Hello Rails');"
```

これにより、指定された文字列が`text/javascript`のMIMEタイプでブラウザに送信されます。

#### 生のボディのレンダリング

`render`の`body`オプションを使用して、コンテンツタイプを設定せずに生のコンテンツをブラウザに送信することができます。

```ruby
render body: "raw"
```

TIP: このオプションは、レスポンスのコンテンツタイプに関係なく使用する必要があります。ほとんどの場合、`plain`または`html`を使用する方が適切です。

NOTE: オーバーライドされていない場合、このレンダリングオプションから返されるレスポンスは`text/plain`になります。これは、Action Dispatchレスポンスのデフォルトのコンテンツタイプです。

#### 生のファイルのレンダリング

Railsは絶対パスから生のファイルをレンダリングすることができます。これは、エラーページなどの静的ファイルを条件付きでレンダリングするのに便利です。

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

これは生のファイルをレンダリングします（ERBや他のハンドラはサポートされていません）。デフォルトでは、現在のレイアウト内でレンダリングされます。

WARNING: `:file`オプションをユーザーの入力と組み合わせて使用すると、セキュリティ上の問題が発生する可能性があるため、注意してください。攻撃者はこのアクションを使用して、ファイルシステム内のセキュリティに関連するファイルにアクセスすることができます。

TIP: レイアウトが必要ない場合は、通常は`send_file`がより高速で優れたオプションです。

#### オブジェクトのレンダリング

Railsは、`:render_in`に応答するオブジェクトをレンダリングすることができます。

```ruby
render MyRenderable.new
```

これは、提供されたオブジェクトに対して現在のビューコンテキストで`render_in`を呼び出します。

また、`render`の`renderable`オプションを使用してオブジェクトを指定することもできます。

```ruby
render renderable: MyRenderable.new
```

#### `render`のオプション

[`render`][controller.render]メソッドへの呼び出しは、一般的に6つのオプションを受け入れます。

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### `:content_type`オプション

デフォルトでは、Railsはレンダリング操作の結果を`text/html`のMIMEコンテンツタイプで提供します（`:json`オプションを使用する場合は`application/json`、`:xml`オプションの場合は`application/xml`）。これを変更したい場合は、`:content_type`オプションを設定することができます。

```ruby
render template: "feed", content_type: "application/rss"
```

##### `:layout`オプション

`render`のほとんどのオプションでは、レンダリングされたコンテンツは現在のレイアウトの一部として表示されます。レイアウトについては、このガイドの後のセクションで詳しく説明します。

`layout`オプションを使用して、現在のアクションのレイアウトとして特定のファイルを使用するようRailsに指示することができます。

```ruby
render layout: "special_layout"
```

また、Railsにレイアウトを使用せずにレンダリングするよう指示することもできます。

```ruby
render layout: false
```

##### `:location`オプション

`location`オプションを使用して、HTTPの`Location`ヘッダーを設定することができます。

```ruby
render xml: photo, location: photo_url(photo)
```

##### `:status`オプション

Railsは自動的に正しいHTTPステータスコードを持つレスポンスを生成します（ほとんどの場合、これは`200 OK`です）。これを変更するためには、`:status`オプションを使用できます。

```ruby
render status: 500
render status: :forbidden
```

Railsは、下記に示す数値ステータスコードと対応するシンボルの両方を理解します。

| レスポンスクラス   | HTTPステータスコード | シンボル                          |
| ----------------- | ------------------- | --------------------------------- |
| **情報**          | 100                 | :continue                        |
|                   | 101                 | :switching_protocols             |
|                   | 102                 | :processing                      |
| **成功**          | 200                 | :ok                              |
|                   | 201                 | :created                         |
|                   | 202                 | :accepted                        |
|                   | 203                 | :non_authoritative_information   |
|                   | 204                 | :no_content                      |
|                   | 205                 | :reset_content                   |
|                   | 206                 | :partial_content                 |
|                   | 207                 | :multi_status                    |
|                   | 208                 | :already_reported                |
|                   | 226                 | :im_used                         |
| **リダイレクト**  | 300                 | :multiple_choices                |
|                   | 301                 | :moved_permanently               |
|                   | 302                 | :found                           |
|                   | 303                 | :see_other                       |
|                   | 304                 | :not_modified                    |
|                   | 305                 | :use_proxy                       |
|                   | 307                 | :temporary_redirect              |
|                   | 308                 | :permanent_redirect              |
| **クライアントエラー** | 400           | :bad_request                     |
|                   | 401                 | :unauthorized                    |
|                   | 402                 | :payment_required                |
|                   | 403                 | :forbidden                       |
|                   | 404                 | :not_found                       |
|                   | 405                 | :method_not_allowed              |
|                   | 406                 | :not_acceptable                  |
|                   | 407                 | :proxy_authentication_required   |
|                   | 408                 | :request_timeout                 |
|                   | 409                 | :conflict                        |
|                   | 410                 | :gone                            |
|                   | 411                 | :length_required                 |
|                   | 412                 | :precondition_failed             |
|                   | 413                 | :payload_too_large               |
|                   | 414                 | :uri_too_long                    |
|                   | 415                 | :unsupported_media_type          |
|                   | 416                 | :range_not_satisfiable           |
|                   | 417                 | :expectation_failed              |
|                   | 421                 | :misdirected_request             |
|                   | 422                 | :unprocessable_entity            |
|                   | 423                 | :locked                          |
|                   | 424                 | :failed_dependency               |
|                   | 426                 | :upgrade_required                |
|                   | 428                 | :precondition_required           |
|                   | 429                 | :too_many_requests               |
|                   | 431                 | :request_header_fields_too_large |
|                   | 451                 | :unavailable_for_legal_reasons   |
| **サーバーエラー** | 500              | :internal_server_error           |
|                   | 501                 | :not_implemented                 |
|                   | 502                 | :bad_gateway                     |
|                   | 503                 | :service_unavailable             |
|                   | 504                 | :gateway_timeout                 |
|                   | 505                 | :http_version_not_supported      |
|                   | 506                 | :variant_also_negotiates         |
|                   | 507                 | :insufficient_storage            |
|                   | 508                 | :loop_detected                   |
|                   | 510                 | :not_extended                    |
|                   | 511                 | :network_authentication_required |
注意：非コンテンツのステータスコード（100-199、204、205、または304）と一緒にコンテンツをレンダリングしようとすると、レスポンスから削除されます。

##### `:formats`オプション

Railsは、リクエストで指定されたフォーマット（またはデフォルトで`:html`）を使用します。シンボルまたは配列を使用して`:formats`オプションを渡すことで、これを変更できます。

```ruby
render formats: :xml
render formats: [:json, :xml]
```

指定されたフォーマットのテンプレートが存在しない場合、`ActionView::MissingTemplate`エラーが発生します。

##### `:variants`オプション

これにより、Railsは同じフォーマットのテンプレートのバリエーションを探します。
シンボルまたは配列を使用して、`variants`オプションでバリアントのリストを指定できます。

使用例は次のとおりです。

```ruby
# HomeController#indexで呼び出される
render variants: [:mobile, :desktop]
```

このバリアントのセットでは、Railsは次のセットのテンプレートを探し、最初に存在するものを使用します。

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

指定されたフォーマットのテンプレートが存在しない場合、`ActionView::MissingTemplate`エラーが発生します。

レンダリング呼び出しでバリアントを設定する代わりに、コントローラアクションのリクエストオブジェクトに設定することもできます。

```ruby
def index
  request.variant = determine_variant
end

private
  def determine_variant
    variant = nil
    # 使用するバリアントを決定するためのコード
    variant = :mobile if session[:use_mobile]

    variant
  end
```

#### レイアウトの検索

現在のレイアウトを見つけるために、Railsはコントローラと同じベース名のファイルを`app/views/layouts`で検索します。たとえば、`PhotosController`クラスからアクションをレンダリングすると、`app/views/layouts/photos.html.erb`（または`app/views/layouts/photos.builder`）が使用されます。そのようなコントローラ固有のレイアウトが存在しない場合、Railsは`app/views/layouts/application.html.erb`または`app/views/layouts/application.builder`を使用します。`.erb`のレイアウトが存在しない場合、`.builder`のレイアウトが存在する場合はそれを使用します。Railsはまた、個々のコントローラとアクションに特定のレイアウトをより正確に割り当てるためのいくつかの方法も提供しています。

##### コントローラに対するレイアウトの指定

[`layout`][]宣言を使用して、コントローラ内でデフォルトのレイアウトの規則をオーバーライドできます。例：

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

この宣言により、`ProductsController`によってレンダリングされるすべてのビューは、そのレイアウトとして`app/views/layouts/inventory.html.erb`を使用します。

アプリケーション全体に特定のレイアウトを割り当てるには、`ApplicationController`クラスで`layout`宣言を使用します。

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

この宣言により、アプリケーション全体のすべてのビューは、そのレイアウトとして`app/views/layouts/main.html.erb`を使用します。


##### 実行時にレイアウトを選択する

シンボルを使用して、レイアウトの選択をリクエストが処理されるまで延期することができます。

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

これにより、現在のユーザが特別なユーザである場合、製品を表示するときに特別なレイアウトが表示されます。

Procなどのインラインメソッドを使用して、レイアウトを決定することもできます。たとえば、Procオブジェクトを渡す場合、Procに与えられるブロックには`controller`インスタンスが与えられるため、現在のリクエストに基づいてレイアウトを決定できます。

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### 条件付きレイアウト

コントローラレベルで指定されたレイアウトは、`:only`および`:except`オプションをサポートしています。これらのオプションは、コントローラ内のメソッド名またはメソッド名の配列を取ります。

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

この宣言により、`rss`および`index`メソッド以外のすべてに`product`レイアウトが使用されます。

##### レイアウトの継承

レイアウトの宣言は階層的に下方向に伝播し、より具体的なレイアウトの宣言が常に一般的なものを上書きします。例：

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

このアプリケーションでは：

* 一般的には、ビューは`main`レイアウトでレンダリングされます
* `ArticlesController#index`は`main`レイアウトを使用します
* `SpecialArticlesController#index`は`special`レイアウトを使用します
* `OldArticlesController#show`はレイアウトを使用しません
* `OldArticlesController#index`は`old`レイアウトを使用します
##### テンプレートの継承

レイアウトの継承ロジックと同様に、テンプレートやパーシャルが通常のパスで見つからない場合、コントローラは継承チェーン内のテンプレートやパーシャルをレンダリングするために探します。例えば：

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```

```ruby
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

`admin/products#index` アクションの探索順序は次のようになります：

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

これにより、`app/views/application/` は共有パーシャルのための素晴らしい場所となります。これらは次のように ERB 内でレンダリングされます：

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
このリストにはまだアイテムがありません。<em>yet</em>。
```

#### 二重レンダーエラーの回避

ほとんどの Rails 開発者は、いずれは「Can only render or redirect once per action」というエラーメッセージを見ることになるでしょう。これは面倒ですが、比較的簡単に修正できます。通常、これは `render` の動作を理解していないために発生します。

例えば、次のコードはこのエラーを引き起こします：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

`@book.special?` が `true` に評価されると、Rails は `@book` 変数を `special_show` ビューに出力するためのレンダリングプロセスを開始します。しかし、これは `show` アクションの残りのコードの実行を停止しないため、Rails はアクションの末尾に達すると `regular_show` ビューをレンダリングし、エラーをスローします。解決策は簡単です：単一のコードパスで `render` または `redirect` を1回だけ呼び出すことを確認してください。`return` が役立つことがあります。以下はメソッドの修正バージョンです：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

注意点として、ActionController によって暗黙のレンダリングが行われ、`render` が呼び出されたかどうかを検出するため、次のコードはエラーなしで動作します：

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

これにより、`special?` が設定された本は `special_show` テンプレートでレンダリングされ、他の本はデフォルトの `show` テンプレートでレンダリングされます。

### `redirect_to` の使用

HTTP リクエストに対するレスポンスを返す別の方法として、[`redirect_to`][] を使用することもできます。先ほど見たように、`render` は Rails にレスポンスを構築するためにどのビュー（または他のアセット）を使用するかを伝えます。`redirect_to` メソッドはまったく異なることを行います：ブラウザに別の URL に対して新しいリクエストを送信するように指示します。例えば、次の呼び出しでコード内のどこからでもアプリケーション内の写真のインデックスにリダイレクトできます：

```ruby
redirect_to photos_url
```

[`redirect_back`][] を使用して、ユーザーを直前のページに戻すこともできます。この場所は、ブラウザによって設定される保証がない `HTTP_REFERER` ヘッダから取得されますので、この場合に使用する `fallback_location` を指定する必要があります。

```ruby
redirect_back(fallback_location: root_path)
```

注意：`redirect_to` と `redirect_back` はメソッドの実行から直ちに中断して戻るのではなく、単に HTTP レスポンスを設定します。それらの後にある文は実行されます。必要に応じて、明示的な `return` や他の中断メカニズムによって中断することができます。

#### 異なるリダイレクトステータスコードの取得

Rails は `redirect_to` を呼び出すときに HTTP ステータスコード 302（一時的なリダイレクト）を使用します。もし異なるステータスコード、例えば 301（恒久的なリダイレクト）を使用したい場合は、`:status` オプションを使用できます：

```ruby
redirect_to photos_path, status: 301
```

`render` の `:status` オプションと同様に、`redirect_to` の `:status` は数値とシンボルの両方のヘッダ指定を受け入れます。

#### `render` と `redirect_to` の違い

経験の浅い開発者は、`redirect_to` を `goto` コマンドのようなものと考え、Rails コード内での実行を一つの場所から別の場所に移動するものとして考えることがあります。これは正しくありません。コードの実行は停止し、ブラウザからの新しいリクエストを待ちます。ただし、HTTP 302 ステータスコードを送り返すことで、ブラウザに次にどのリクエストを行うべきかを伝えているだけです。

違いを確認するために、次のアクションを考えてみましょう：

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

この形式のコードでは、`@book` 変数が `nil` の場合に問題が発生する可能性があります。`render :action` はターゲットアクション内のコードを実行しないため、おそらく `index` ビューで必要とされる `@books` 変数を設定するものは何もありません。これを修正する方法の一つは、レンダリングではなくリダイレクトすることです：
```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

このコードでは、ブラウザはインデックスページのために新しいリクエストを行い、`index`メソッドのコードが実行され、すべてが正常に動作します。

このコードの唯一の欠点は、ブラウザへの往復が必要であることです。ブラウザは`/books/1`というshowアクションをリクエストし、コントローラは本が存在しないことを検出し、コントローラはブラウザに対して302リダイレクトレスポンスを送信して`/books/`に移動するよう指示します。ブラウザはこれに従い、新しいリクエストをコントローラに送信して`index`アクションを要求します。コントローラはデータベースからすべての本を取得し、インデックステンプレートをレンダリングしてブラウザに送信し、ブラウザはそれを画面に表示します。

小規模なアプリケーションでは、この追加の待ち時間は問題にならないかもしれませんが、レスポンス時間が心配な場合は考慮する必要があります。次に、矛盾した例を使用して、この問題を処理する方法を示します。

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "本が見つかりませんでした"
    render "index"
  end
end
```

これにより、指定されたIDの本が存在しないことが検出され、モデル内のすべての本を含む`@books`インスタンス変数が作成され、直接`index.html.erb`テンプレートがレンダリングされ、ユーザーに何が起こったかを伝えるフラッシュアラートメッセージがブラウザに返されます。

### `head`を使用してヘッダーのみのレスポンスを作成する

[`head`][]メソッドは、ヘッダーのみを含むレスポンスをブラウザに送信するために使用できます。`head`メソッドは、HTTPステータスコードを表す数値またはシンボル（[参照表](#the-status-option)を参照）を受け入れます。オプション引数は、ヘッダー名と値のハッシュとして解釈されます。たとえば、エラーヘッダーのみを返すことができます。

```ruby
head :bad_request
```

これにより、次のヘッダーが生成されます。

```http
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

または、他のHTTPヘッダーを使用して他の情報を伝えることもできます。

```ruby
head :created, location: photo_path(@photo)
```

これにより、次のヘッダーが生成されます。

```http
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

レイアウトの構造化
-------------------

Railsがビューをレスポンスとしてレンダリングする際、現在のレイアウトとビューを組み合わせるために、このガイドで説明した現在のレイアウトを見つけるためのルールを使用します。レイアウト内では、次の3つのツールを使用して、異なる出力のビットを組み合わせて全体のレスポンスを形成することができます。

* アセットタグ
* `yield`と[`content_for`][]
* パーシャル


### アセットタグヘルパー

アセットタグヘルパーは、ビューをフィード、JavaScript、スタイルシート、画像、ビデオ、オーディオにリンクするためのHTMLを生成するためのメソッドを提供します。Railsには6つのアセットタグヘルパーがあります。

* [`auto_discovery_link_tag`][]
* [`javascript_include_tag`][]
* [`stylesheet_link_tag`][]
* [`image_tag`][]
* [`video_tag`][]
* [`audio_tag`][]

これらのタグは、レイアウトや他のビューで使用できますが、`auto_discovery_link_tag`、`javascript_include_tag`、`stylesheet_link_tag`は、レイアウトの`<head>`セクションで最も一般的に使用されます。

警告: アセットタグヘルパーは、指定された場所にアセットが存在するかどうかを検証しません。単にあなたが何をしているかを前提としてリンクを生成します。


#### `auto_discovery_link_tag`を使用してフィードにリンクする

[`auto_discovery_link_tag`][]ヘルパーは、ほとんどのブラウザとフィードリーダーがRSS、Atom、またはJSONフィードの存在を検出するために使用できるHTMLを生成します。リンクのタイプ（`:rss`、`:atom`、または`:json`）、url_forに渡されるオプションのハッシュ、およびタグのオプションのハッシュを取ります。

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSSフィード"}) %>
```

`auto_discovery_link_tag`には、次の3つのタグオプションがあります。

* `:rel`はリンクの`rel`値を指定します。デフォルト値は「alternate」です。
* `:type`は明示的なMIMEタイプを指定します。Railsは適切なMIMEタイプを自動的に生成します。
* `:title`はリンクのタイトルを指定します。デフォルト値は大文字の`:type`値です。たとえば、「ATOM」または「RSS」です。
#### `javascript_include_tag`を使用してJavaScriptファイルにリンクする

[`javascript_include_tag`][]ヘルパーは、指定されたソースごとにHTMLの`script`タグを返します。

Asset Pipelineが有効なRailsを使用している場合、このヘルパーは`public/javascripts`ではなく`/assets/javascripts/`へのリンクを生成します。このリンクはAsset Pipelineによって提供されます。

RailsアプリケーションまたはRailsエンジン内のJavaScriptファイルは、`app/assets`、`lib/assets`、または`vendor/assets`のいずれかの場所に配置されます。これらの場所についての詳細は、Asset Pipelineガイドの[Asset Organizationセクション](asset_pipeline.html#asset-organization)で説明されています。

ドキュメントルートに対するフルパスまたはURLを指定することもできます。たとえば、`app/assets`、`lib/assets`、または`vendor/assets`のいずれかのディレクトリ内にあるJavaScriptファイルにリンクするには、次のようにします。

```erb
<%= javascript_include_tag "main" %>
```

Railsは次のような`script`タグを出力します。

```html
<script src='/assets/main.js'></script>
```

このアセットへのリクエストは、Sprockets gemによって提供されます。

`app/assets/javascripts/main.js`と`app/assets/javascripts/columns.js`のような複数のファイルを同時に含めるには、次のようにします。

```erb
<%= javascript_include_tag "main", "columns" %>
```

`app/assets/javascripts/main.js`と`app/assets/javascripts/photos/columns.js`を含めるには、次のようにします。

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

`http://example.com/main.js`を含めるには、次のようにします。

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### `stylesheet_link_tag`を使用してCSSファイルにリンクする

[`stylesheet_link_tag`][]ヘルパーは、指定されたソースごとにHTMLの`<link>`タグを返します。

Asset Pipelineが有効なRailsを使用している場合、このヘルパーは`/assets/stylesheets/`へのリンクを生成します。このリンクはSprockets gemによって処理されます。スタイルシートファイルは、`app/assets`、`lib/assets`、または`vendor/assets`のいずれかの場所に保存できます。

ドキュメントルートに対するフルパスまたはURLを指定することもできます。たとえば、`app/assets`、`lib/assets`、または`vendor/assets`のいずれかのディレクトリ内にあるスタイルシートファイルにリンクするには、次のようにします。

```erb
<%= stylesheet_link_tag "main" %>
```

`app/assets/stylesheets/main.css`と`app/assets/stylesheets/columns.css`を含めるには、次のようにします。

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

`app/assets/stylesheets/main.css`と`app/assets/stylesheets/photos/columns.css`を含めるには、次のようにします。

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

`http://example.com/main.css`を含めるには、次のようにします。

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

デフォルトでは、`stylesheet_link_tag`は`rel="stylesheet"`を持つリンクを作成します。適切なオプション（`:rel`）を指定することで、このデフォルトを上書きすることができます。

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### `image_tag`を使用して画像にリンクする

[`image_tag`][]ヘルパーは、指定されたファイルに対してHTMLの`<img />`タグを作成します。デフォルトでは、ファイルは`public/images`から読み込まれます。

警告：画像の拡張子を指定する必要があることに注意してください。

```erb
<%= image_tag "header.png" %>
```

必要に応じて画像へのパスを指定することもできます。

```erb
<%= image_tag "icons/delete.gif" %>
```

追加のHTMLオプションのハッシュを指定することもできます。

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

画像がオフになっている場合に使用される代替テキストを指定することもできます。明示的にaltテキストを指定しない場合、ファイル名がデフォルトのaltテキストとして使用されます。たとえば、次の2つの画像タグは同じコードを返します。

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

特殊なサイズタグも指定できます。形式は"{幅}x{高さ}"です。

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

上記の特殊なタグに加えて、`class`、`id`、または`name`などの標準的なHTMLオプションのハッシュを指定することもできます。

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### `video_tag`を使用してビデオにリンクする

[`video_tag`][]ヘルパーは、指定されたファイルに対してHTML5の`<video>`タグを作成します。デフォルトでは、ファイルは`public/videos`から読み込まれます。

```erb
<%= video_tag "movie.ogg" %>
```

次のようになります。

```erb
<video src="/videos/movie.ogg" />
```

`image_tag`のように、パスを指定することもできます。絶対パスまたは`public/videos`ディレクトリに対する相対パスです。さらに、`image_tag`と同様に、`size: "#{width}x#{height}"`オプションを指定することもできます。ビデオタグには、`id`、`class`などのHTMLオプションも指定できます。

ビデオタグは、HTMLオプションハッシュを介して`<video>`のすべてのHTMLオプションもサポートしています。これには、次のものが含まれます。

* `poster: "image_name.png"`：ビデオが再生される前に表示する画像を提供します。
* `autoplay: true`：ページの読み込み時にビデオを再生します。
* `loop: true`：ビデオが終了したらループします。
* `controls: true`：ユーザーがビデオと対話するためのブラウザが提供するコントロールを表示します。
* `autobuffer: true`：ビデオはページの読み込み時にファイルをプリロードします。
`video_tag`に配列のビデオを渡すことで、複数のビデオを指定することもできます。

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

これにより、以下のような出力が生成されます。

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### `audio_tag`を使用してオーディオファイルにリンクする

[`audio_tag`][]ヘルパーは、指定されたファイルにHTML5の`<audio>`タグを作成します。デフォルトでは、ファイルは`public/audios`からロードされます。

```erb
<%= audio_tag "music.mp3" %>
```

必要に応じてオーディオファイルへのパスを指定することもできます。

```erb
<%= audio_tag "music/first_song.mp3" %>
```

また、`:id`、`:class`などの追加オプションのハッシュを指定することもできます。

`video_tag`と同様に、`audio_tag`には特別なオプションがあります。

* `autoplay: true`は、ページの読み込み時にオーディオを再生します。
* `controls: true`は、ユーザーがオーディオと対話するためのブラウザが提供するコントロールを提供します。
* `autobuffer: true`は、ページの読み込み時にユーザーのためにファイルを事前にロードします。

### `yield`の理解

レイアウトの文脈では、`yield`はビューからのコンテンツが挿入されるセクションを識別します。これを使用する最も簡単な方法は、単一の`yield`を持つことで、現在レンダリングされているビューのすべての内容が挿入されます。

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

また、複数のyielding領域を持つレイアウトを作成することもできます。

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

ビューのメインボディは常に無名の`yield`にレンダリングされます。名前付きの`yield`にコンテンツをレンダリングするには、`content_for`メソッドを使用します。

### `content_for`メソッドの使用

[`content_for`][]メソッドを使用すると、レイアウト内の名前付きの`yield`ブロックにコンテンツを挿入できます。たとえば、次のビューは、先ほど見たレイアウトと一緒に動作します。

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

このページを指定されたレイアウトにレンダリングすると、次のHTMLが生成されます。

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

`content_for`メソッドは、レイアウトにサイドバーやフッターなどの独自のコンテンツブロックを挿入する必要がある場合に非常に便利です。また、ページ固有のJavaScriptやCSSファイルをヘッダーに挿入するためのタグを挿入するのにも便利です。

### パーシャルの使用

パーシャルテンプレート（通常は「パーシャル」と呼ばれます）は、レンダリングプロセスをより管理しやすいチャンクに分割するための別のデバイスです。パーシャルを使用すると、特定のレスポンスの特定の部分をレンダリングするためのコードを独自のファイルに移動できます。

#### パーシャルの命名

ビューの一部としてパーシャルをレンダリングするには、ビュー内で[`render`][view.render]メソッドを使用します。

```html+erb
<%= render "menu" %>
```

これにより、レンダリングされているビューのそのポイントで`_menu.html.erb`という名前のファイルがレンダリングされます。先頭にアンダースコアが付いていることに注意してください：パーシャルはアンダースコアなしで参照されますが、通常のビューとは異なることを区別するために先頭にアンダースコアが付けられます。これは、別のフォルダからパーシャルを取り込む場合でも同様です。

```html+erb
<%= render "shared/menu" %>
```

このコードは、`app/views/shared/_menu.html.erb`からパーシャルを取り込みます。


#### パーシャルを使用してビューを簡素化する

パーシャルを使用する方法の1つは、サブルーチンのように扱うことです。つまり、ビューから詳細を移動して、何が起こっているかをより簡単に把握できるようにする方法です。たとえば、次のようなビューがあるかもしれません。

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

ここでは、`_ad_banner.html.erb`と`_footer.html.erb`のパーシャルには、アプリケーションの多くのページで共有されるコンテンツが含まれているかもしれません。特定のページに集中しているときにこれらのセクションの詳細を見る必要はありません。

このガイドの前のセクションで見たように、`yield`はレイアウトをきれいにするための非常に強力なツールです。それは純粋なRubyなので、ほとんどの場所で使用することができます。たとえば、いくつかの類似したリソースに対してフォームレイアウトの定義をDRYにするために使用することができます。

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Name contains: <%= form.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |form| %>
      <p>
        Title contains: <%= form.text_field :title_contains %>
      </p>
    <% end %>
    ```
* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_with model: search do |form| %>
      <h1>検索フォーム:</h1>
      <fieldset>
        <%= yield form %>
      </fieldset>
      <p>
        <%= form.submit "検索" %>
      </p>
    <% end %>
    ```

TIP: アプリケーションのすべてのページで共有されるコンテンツには、レイアウトから直接パーシャルを使用できます。

#### パーシャルレイアウト

パーシャルは、ビューがレイアウトを使用できるように、独自のレイアウトファイルを使用することができます。たとえば、次のようにパーシャルを呼び出すことができます。

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

これにより、`_link_area.html.erb`という名前のパーシャルが探され、`_graybar.html.erb`レイアウトを使用してレンダリングされます。パーシャルのレイアウトも通常のパーシャルと同じように、先頭にアンダースコアが付いている命名規則に従い、パーシャルが属するフォルダに配置されます（マスターの`layouts`フォルダではありません）。

また、`:layout`などの追加オプションを渡す場合は、明示的に`:partial`を指定する必要があることにも注意してください。

#### ローカル変数の渡し方

パーシャルにもローカル変数を渡すことができ、それによりさらに強力で柔軟なものにすることができます。たとえば、このテクニックを使用して、新規作成ページと編集ページの間の重複を減らしながら、少し異なるコンテンツを保持することができます。

* `new.html.erb`

    ```html+erb
    <h1>新しいゾーン</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>ゾーンの編集</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_with model: zone do |form| %>
      <p>
        <b>ゾーン名</b><br>
        <%= form.text_field :name %>
      </p>
      <p>
        <%= form.submit %>
      </p>
    <% end %>
    ```

同じパーシャルが両方のビューにレンダリングされますが、Action Viewのsubmitヘルパーは、新規作成アクションでは「ゾーンの作成」、編集アクションでは「ゾーンの更新」という結果を返します。

特定の場合にのみパーシャルにローカル変数を渡すには、`local_assigns`を使用します。

* `index.html.erb`

    ```erb
    <%= render user.articles %>
    ```

* `show.html.erb`

    ```erb
    <%= render article, full: true %>
    ```

* `_article.html.erb`

    ```erb
    <h2><%= article.title %></h2>

    <% if local_assigns[:full] %>
      <%= simple_format article.body %>
    <% else %>
      <%= truncate article.body %>
    <% end %>
    ```

これにより、すべてのローカル変数を宣言する必要なく、パーシャルを使用することができます。

すべてのパーシャルには、同じ名前のローカル変数があります（先頭のアンダースコアを除く）。このローカル
コレクションが空の場合、`render`はnilを返すため、代替コンテンツを提供するのは非常に簡単です。

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### ローカル変数

パーシャル内でカスタムのローカル変数名を使用するには、パーシャルへの呼び出しで`:as`オプションを指定します。

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

この変更により、パーシャル内で`@products`コレクションのインスタンスに`item`ローカル変数としてアクセスできます。

また、`locals: {}`オプションを使用してレンダリングしている任意のパーシャルに任意のローカル変数を渡すこともできます。

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

この場合、パーシャルは値が "Products Page" の`title`ローカル変数にアクセスできます。

#### カウンタ変数

Railsは、コレクションによって呼び出されるパーシャル内で利用可能なカウンタ変数も提供します。変数は、パーシャルのタイトルに続く`_counter`という名前になります。たとえば、コレクション`@products`をレンダリングするとき、パーシャル`_product.html.erb`は`product_counter`変数にアクセスできます。この変数は、パーシャルが閉じているビュー内でレンダリングされた回数をインデックス化し、最初のレンダリングでは`0`の値から始まります。

```erb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```erb
# _product.html.erb
<%= product_counter %> # 最初の商品は0、2番目の商品は1...
```

`as:`オプションを使用してパーシャル名を変更した場合でも、この方法は機能します。したがって、`as: :item`を行った場合、カウンタ変数は`item_counter`になります。

#### スペーサーテンプレート

メインのパーシャルのインスタンス間にレンダリングするために、`spacer_template`オプションを使用して2番目のパーシャルを指定することもできます。

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Railsは、各`_product`パーシャルのペア間にデータを渡さずに`_product_ruler`パーシャルをレンダリングします。

#### コレクションパーシャルのレイアウト

コレクションをレンダリングする際に、`layout`オプションを使用することもできます。

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

レイアウトは、コレクション内の各アイテムのパーシャルと一緒にレンダリングされます。現在のオブジェクトと`object_counter`変数も、パーシャル内と同じようにレイアウトで利用できます。

### ネストされたレイアウトの使用

アプリケーションには、特定のコントローラをサポートするために通常のアプリケーションレイアウトとは若干異なるレイアウトが必要な場合があります。メインのレイアウトを繰り返し編集する代わりに、ネストされたレイアウト（サブテンプレートとも呼ばれます）を使用することで、これを実現できます。以下に例を示します。

次の`ApplicationController`レイアウトがあるとします。

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Top menu items here</div>
      <div id="menu">Menu items here</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

`NewsController`によって生成されるページでは、トップメニューを非表示にし、右メニューを追加したいとします。

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Right menu items here</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

以上です。Newsビューは新しいレイアウトを使用し、トップメニューを非表示にし、"content" div内に新しい右メニューを追加します。

このテクニックを使用して、異なるサブテンプレートスキームで同様の結果を得る方法はいくつかあります。ネストのレベルに制限はありません。新しいレイアウトをNewsレイアウトに基づいて作成するために、`ActionView::render`メソッドを使用することもできます。`News`レイアウトをサブテンプレート化しないことが確実な場合は、`content_for?(:news_content) ? yield(:news_content) : yield`を単に`yield`に置き換えることができます。
[controller.render]: https://api.rubyonrails.org/classes/ActionController/Rendering.html#method-i-render
[`redirect_to`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to
[`head`]: https://api.rubyonrails.org/classes/ActionController/Head.html#method-i-head
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`redirect_back`]: https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back
[`content_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for
[`auto_discovery_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-auto_discovery_link_tag
[`javascript_include_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-javascript_include_tag
[`stylesheet_link_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-stylesheet_link_tag
[`image_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag
[`video_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-video_tag
[`audio_tag`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-audio_tag
[view.render]: https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render
