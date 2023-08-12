**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f6b613040c7aed4c76b6648b6fd963cf
Action Viewの概要
====================

このガイドを読むことで、以下のことがわかります：

* Action ViewとRailsの使い方
* テンプレート、パーシャル、レイアウトの最適な使い方
* ローカライズされたビューの使い方

--------------------------------------------------------------------------------

Action Viewとは何ですか？
--------------------

Railsでは、Webリクエストは[Action Controller](action_controller_overview.html)とAction Viewによって処理されます。通常、Action Controllerはデータベースとの通信や必要な場合のCRUDアクションに関わります。その後、Action Viewがレスポンスをコンパイルする責任を持ちます。

Action Viewのテンプレートは、HTMLと組み合わせた埋め込みRubyを使用して書かれます。テンプレートを冗長なコードで混雑させないために、いくつかのヘルパークラスがフォーム、日付、文字列などの共通の動作を提供します。また、アプリケーションが進化するにつれて新しいヘルパーを簡単に追加することもできます。

注意：Action Viewの一部の機能はActive Recordに関連していますが、それはAction ViewがActive Recordに依存していることを意味するものではありません。Action Viewは独立したパッケージであり、どのような種類のRubyライブラリとも使用することができます。

RailsでAction Viewを使用する方法
----------------------------

各コントローラには、`app/views`ディレクトリに関連付けられたディレクトリがあり、そのコントローラに関連するビューを構成するテンプレートファイルが格納されています。これらのファイルは、各コントローラアクションから結果として表示されるビューを表示するために使用されます。

scaffoldジェネレータを使用して新しいリソースを作成する場合、Railsがデフォルトで行う動作を見てみましょう：

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Railsでは、ビューには命名規則があります。通常、ビューは関連するコントローラアクションと同じ名前を共有します。上記の例では、`articles_controller.rb`のindexコントローラアクションは、`app/views/articles`ディレクトリの`index.html.erb`ビューファイルを使用します。クライアントに返される完全なHTMLは、このERBファイル、それを囲むレイアウトテンプレート、およびビューが参照するすべてのパーシャルの組み合わせで構成されます。このガイドでは、これらの3つのコンポーネントについての詳細なドキュメントを見つけることができます。

前述のように、最終的なHTML出力は3つのRails要素（テンプレート、パーシャル、レイアウト）の組み合わせです。
以下にそれぞれの概要を示します。

テンプレート
---------

Action Viewのテンプレートは、いくつかの方法で書くことができます。テンプレートファイルの拡張子が`.erb`の場合、ERB（埋め込みRuby）とHTMLの組み合わせが使用されます。テンプレートファイルの拡張子が`.builder`の場合、`Builder::XmlMarkup`ライブラリが使用されます。

Railsは複数のテンプレートシステムをサポートし、ファイルの拡張子を使用してそれらを区別します。たとえば、ERBテンプレートシステムを使用したHTMLファイルの拡張子は`.html.erb`になります。

### ERB

ERBテンプレート内では、`<% %>`と`<%= %>`のタグを使用してRubyコードを含めることができます。`<% %>`タグは、条件やループ、ブロックなど、何も返さないRubyコードを実行するために使用され、`<%= %>`タグは出力が必要な場合に使用されます。

次の名前のループを考えてみましょう：

```html+erb
<h1>全ての人の名前</h1>
<% @people.each do |person| %>
  名前： <%= person.name %><br>
<% end %>
```

このループは通常の埋め込みタグ（`<% %>`）を使用して設定され、名前は出力埋め込みタグ（`<%= %>`）を使用して挿入されます。なお、これは単なる使用の提案ではありません：`print`や`puts`などの通常の出力関数は、ERBテンプレートではビューにレンダリングされません。したがって、次のようになります：

```html+erb
<%# 間違い %>
こんにちは、Mr. <% puts "Frodo" %>
```

先頭と末尾の空白を抑制するには、`<%-` `-%>`を`<%`と`%>`と交換可能に使用することができます。

### Builder

Builderテンプレートは、ERBに対するよりプログラム的な代替手段です。特にXMLコンテンツの生成に便利です。`.builder`の拡張子を持つテンプレートには、`xml`という名前のXmlMarkupオブジェクトが自動的に利用可能になります。

以下にいくつかの基本的な例を示します：

```ruby
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

これにより、次のような出力が生成されます：

```html
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

ブロックを持つ任意のメソッドは、ブロック内のネストされたマークアップを持つXMLマークアップタグとして扱われます。たとえば、次のようなものです：
```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

は次のような出力を生成します：

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

以下は実際にBasecampで使用された完全なRSSの例です：

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

### Jbuilder

[Jbuilder](https://github.com/rails/jbuilder)は、Railsチームによってメンテナンスされ、デフォルトのRails `Gemfile`に含まれているgemです。Builderと似ていますが、XMLの代わりにJSONを生成するために使用されます。

持っていない場合は、`Gemfile`に次の行を追加できます：

```ruby
gem 'jbuilder'
```

`.jbuilder`拡張子を持つテンプレートには、`json`という名前のJbuilderオブジェクトが自動的に利用可能になります。

以下は基本的な例です：

```ruby
json.name("Alex")
json.email("alex@example.com")
```

これにより、次のような出力が生成されます：

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

詳細な例や情報については、[Jbuilderのドキュメント](https://github.com/rails/jbuilder#jbuilder)を参照してください。

### テンプレートキャッシュ

デフォルトでは、Railsは各テンプレートをレンダリングするためのメソッドにコンパイルします。開発環境では、テンプレートを変更すると、Railsはファイルの変更時刻を確認して再コンパイルします。

パーシャル
--------

パーシャルテンプレート（通常は「パーシャル」と呼ばれる）は、レンダリングプロセスをより管理しやすいチャンクに分割するための別のデバイスです。パーシャルを使用すると、テンプレートからコードの一部を別のファイルに抽出し、テンプレート全体で再利用することができます。

### パーシャルのレンダリング

ビューの一部としてパーシャルをレンダリングするには、ビュー内で`render`メソッドを使用します：

```erb
<%= render "menu" %>
```

これにより、レンダリングされているビューのそのポイントで`_menu.html.erb`というファイルがレンダリングされます。先頭にアンダースコアが付いていることに注意してください：パーシャルは通常のビューと区別するために先頭にアンダースコアが付けられていますが、参照する際にはアンダースコアなしで指定されます。これは、別のフォルダからパーシャルを取り込む場合でも同様です：

```erb
<%= render "shared/menu" %>
```

このコードは、`app/views/shared/_menu.html.erb`からパーシャルを取り込みます。

### パーシャルを使用してビューを簡素化する

パーシャルを使用する方法の1つは、それらをサブルーチンのように扱うことです。つまり、ビューから詳細を切り出して、何が起こっているかをより簡単に把握できるようにする方法です。たとえば、次のようなビューがあるかもしれません：

```html+erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

ここでは、`_ad_banner.html.erb`と`_footer.html.erb`のパーシャルには、アプリケーションの多くのページで共有されるコンテンツが含まれている場合があります。特定のページに集中しているときにこれらのセクションの詳細を見る必要はありません。

### `partial`と`locals`オプションなしの`render`

上記の例では、`render`メソッドは2つのオプション、`partial`と`locals`を取ります。ただし、これらのオプションのみを渡す場合は、これらのオプションを使用せずに済ませることもできます。たとえば、次のように書くこともできます：

```erb
<%= render "product", product: @product %>
```

### `as`オプションと`object`オプション

デフォルトでは、`ActionView::Partials::PartialRenderer`は、テンプレートと同じ名前のローカル変数にオブジェクトを持っています。したがって、次のような場合：

```erb
<%= render partial: "product" %>
```

`_product`パーシャル内では、ローカル変数`product`に`@product`が格納されます。

`object`オプションは、テンプレートのオブジェクトが別の場所にある場合に使用されます（たとえば、別のインスタンス変数やローカル変数にある場合など）。

たとえば、次のような場合：

```erb
<%= render partial: "product", locals: { product: @item } %>
```

次のようにします：

```erb
<%= render partial: "product", object: @item %>
```

`as`オプションを使用すると、指定したローカル変数の名前を変更できます。たとえば、`product`ではなく`item`にしたい場合は、次のようにします：

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

これは、次のコードと同じです：
```erb
<%= render partial: "product", locals: { item: @item } %>
```

### コレクションのレンダリング

通常、テンプレートはコレクションを反復処理し、各要素のためにサブテンプレートをレンダリングする必要があります。このパターンは、配列を受け取り、配列の各要素に対して部分テンプレートをレンダリングする単一のメソッドとして実装されています。

したがって、すべての商品をレンダリングするためのこの例：

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

を単一の行で書き直すことができます：

```erb
<%= render partial: "product", collection: @products %>
```

コレクションとして部分テンプレートが呼び出される場合、部分テンプレートの個々のインスタンスは、レンダリングされているコレクションのメンバーにアクセスできます。この場合、部分テンプレートは `_product` であり、その中で `product` を参照することで、レンダリングされているコレクションのメンバーを取得できます。

コレクションのレンダリングには省略記法も使用できます。`@products` が `Product` インスタンスのコレクションであると仮定すると、次のように書くだけで同じ結果が得られます：

```erb
<%= render @products %>
```

Railsは、コレクション内のモデル名で使用する部分テンプレートの名前を決定します。実際、この省略記法を使用して異なるモデルのインスタンスからなるコレクションをレンダリングすることもでき、Railsはコレクションの各メンバーに適切な部分テンプレートを選択します。

### スペーサーテンプレート

メインの部分テンプレートのインスタンス間にレンダリングするためのセカンドパーシャルを指定するには、`:spacer_template` オプションを使用します：

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Railsは、各 `_product` パーシャルの間にデータを渡さずに `_product_ruler` パーシャルをレンダリングします。

### 厳密なローカル変数

デフォルトでは、テンプレートはキーワード引数として任意の `locals` を受け入れます。テンプレートが受け入れる `locals` を定義するには、`locals` マジックコメントを追加します：

```erb
<%# locals: (message:) -%>
<%= message %>
```

デフォルト値も指定できます：

```erb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

または、`locals` を完全に無効にすることもできます：

```erb
<%# locals: () %>
```

レイアウト
-------

レイアウトは、Railsコントローラのアクションの結果を囲む共通のビューテンプレートをレンダリングするために使用できます。通常、Railsアプリケーションには、ページがレンダリングされるレイアウトがいくつかあります。たとえば、サイトにはログイン済みユーザー用のレイアウトと、マーケティングやセールスのサイド用の別のレイアウトがあるかもしれません。ログイン済みユーザーレイアウトには、多くのコントローラアクションで表示される必要があるトップレベルのナビゲーションが含まれる場合があります。SaaSアプリのセールスレイアウトには、「価格設定」や「お問い合わせ」ページなどのトップレベルのナビゲーションが含まれる場合があります。各レイアウトには異なる外観と感触があることが期待されます。詳細については、[Railsのレイアウトとレンダリング](layouts_and_rendering.html)ガイドを参照してください。

### 部分レイアウト

部分テンプレートには、それに適用される独自のレイアウトを適用することもできます。これらのレイアウトは、コントローラアクションに適用されるレイアウトとは異なりますが、同様の方法で機能します。

たとえば、表示目的のために `div` で囲まれたページ上に記事を表示しているとします。まず、新しい `Article` を作成します：

```ruby
Article.create(body: '部分レイアウトは素晴らしいです！')
```

`show` テンプレートでは、`box` レイアウトで `_article` 部分テンプレートをレンダリングします：

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

`box` レイアウトは、単純に `_article` 部分テンプレートを `div` で囲みます：

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

部分レイアウトには、`render` 呼び出しに渡されたローカル変数 `article` にアクセスできることに注意してください。ただし、アプリケーション全体のレイアウトとは異なり、部分レイアウトにはまだアンダースコアの接頭辞が付いています。

また、`yield` を呼び出す代わりに、部分レイアウト内でコードブロックをレンダリングすることもできます。たとえば、`_article` 部分テンプレートがない場合は、次のようにすることもできます：

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

上記の例と同じ `_box` 部分テンプレートを使用する場合、同じ出力が生成されます。

ビューパス
----------

レスポンスをレンダリングする際、コントローラは異なるビューがどこにあるかを解決する必要があります。デフォルトでは、`app/views` ディレクトリ内のみを検索します。
`prepend_view_path`メソッドと`append_view_path`メソッドを使用して、他の場所を追加し、パスの解決時にそれらに優先順位を付けることができます。

### Prepend View Path

これは、サブドメインのために異なるディレクトリ内にビューを配置したい場合などに便利です。

次のように使用することができます。

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

その後、Action Viewはビューを解決する際にまずこのディレクトリを参照します。

### Append View Path

同様に、パスを追加することもできます。

```ruby
append_view_path "app/views/direct"
```

これにより、`app/views/direct`が検索パスの末尾に追加されます。

ヘルパー
-------

Railsは、Action Viewで使用するための多くのヘルパーメソッドを提供しています。これには、次のようなメソッドが含まれます。

* 日付、文字列、数値のフォーマット
* 画像、ビデオ、スタイルシートなどへのHTMLリンクの作成
* コンテンツのサニタイズ
* フォームの作成
* コンテンツのローカライズ

ヘルパーについては、[Action View Helpers Guide](action_view_helpers.html)と[Action View Form Helpers Guide](form_helpers.html)で詳しく学ぶことができます。

ローカライズされたビュー
-----------------------

Action Viewには、現在のロケールに応じて異なるテンプレートをレンダリングする機能があります。

たとえば、showアクションを持つ`ArticlesController`があるとします。デフォルトでは、このアクションを呼び出すと`app/views/articles/show.html.erb`がレンダリングされます。しかし、`I18n.locale = :de`と設定すると、代わりに`app/views/articles/show.de.html.erb`がレンダリングされます。ローカライズされたテンプレートが存在しない場合は、非装飾版が使用されます。つまり、すべてのケースにローカライズされたビューを提供する必要はありませんが、利用可能な場合は優先されて使用されます。

同じテクニックを使用して、パブリックディレクトリ内のレスキューファイルをローカライズすることもできます。たとえば、`I18n.locale = :de`と設定し、`public/500.de.html`と`public/404.de.html`を作成すると、ローカライズされたレスキューページを使用できます。

RailsはI18n.localeを設定するために使用するシンボルを制限しないため、このシステムを使用して好きな要素に応じて異なるコンテンツを表示することができます。たとえば、いくつかの「エキスパート」ユーザーが「通常」のユーザーとは異なるページを表示する必要がある場合を考えてみましょう。次のように`app/controllers/application_controller.rb`に追加することができます。

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

その後、`app/views/articles/show.expert.html.erb`のような特別なビューを作成することで、エキスパートユーザーにのみ表示されるようにすることができます。

Railsの国際化（I18n）APIについては、[こちら](i18n.html)を参照してください。
