**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37d2486eee8522a64c5f97f86900b8a6
アクションビューヘルパー
====================

このガイドを読み終えると、以下のことがわかります：

* 日付、文字列、数値のフォーマット方法
* 画像、ビデオ、スタイルシートなどへのリンク方法
* コンテンツのサニタイズ方法
* コンテンツのローカライズ方法

--------------------------------------------------------------------------------

アクションビューが提供するヘルパーの概要
-------------------------------------------

WIP: ここにはすべてのヘルパーがリストされていません。完全なリストについては[APIドキュメント](https://api.rubyonrails.org/classes/ActionView/Helpers.html)を参照してください。

以下は、アクションビューで利用可能なヘルパーの概要です。詳細については[APIドキュメント](https://api.rubyonrails.org/classes/ActionView/Helpers.html)を確認することをおすすめしますが、これは良い出発点となるでしょう。

### AssetTagHelper

このモジュールは、ビューを画像、JavaScriptファイル、スタイルシート、フィードなどのアセットにリンクするためのHTMLを生成するためのメソッドを提供します。

デフォルトでは、Railsはこれらのアセットを現在のホストのpublicフォルダからリンクしますが、[`config.asset_host`][]をアプリケーションの設定（通常は`config/environments/production.rb`）で設定することで、専用のアセットサーバーからのリンクを指定することもできます。たとえば、アセットホストが`assets.example.com`の場合：

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```


#### auto_discovery_link_tag

ブラウザやフィードリーダーがRSS、Atom、またはJSONフィードを自動検出するために使用できるリンクタグを返します。

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

`app/assets/images`ディレクトリ内の画像アセットへのパスを計算します。ドキュメントルートからの完全なパスはそのまま渡されます。`image_tag`内部で使用され、画像パスを構築します。

```ruby
image_path("edit.png") # => /assets/edit.png
```

`config.assets.digest`がtrueに設定されている場合、ファイル名にフィンガープリントが追加されます。

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

`app/assets/images`ディレクトリ内の画像アセットへのURLを計算します。これは内部的に`image_path`を呼び出し、現在のホストまたはアセットホストと結合します。

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

ソースに対するHTMLイメージタグを返します。ソースはフルパスまたは`app/assets/images`ディレクトリに存在するファイルです。

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

指定されたソースごとにHTMLスクリプトタグを返します。現在のページに含めるために、`app/assets/javascripts`ディレクトリに存在するJavaScriptファイルのファイル名（`.js`拡張子はオプション）を渡すか、ドキュメントルートに対する相対パスを渡すことができます。

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

`app/assets/javascripts`ディレクトリ内のJavaScriptアセットへのパスを計算します。ソースのファイル名に拡張子がない場合、`.js`が追加されます。ドキュメントルートからの完全なパスはそのまま渡されます。`javascript_include_tag`内部で使用され、スクリプトパスを構築します。

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

`app/assets/javascripts`ディレクトリ内のJavaScriptアセットへのURLを計算します。これは内部的に`javascript_path`を呼び出し、現在のホストまたはアセットホストと結合します。

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

引数として指定されたソースに対するスタイルシートリンクタグを返します。拡張子を指定しない場合、`.css`が自動的に追加されます。

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```

#### stylesheet_path

`app/assets/stylesheets`ディレクトリ内のスタイルシートアセットへのパスを計算します。ソースのファイル名に拡張子がない場合、`.css`が追加されます。ドキュメントルートからの完全なパスはそのまま渡されます。`stylesheet_link_tag`内部で使用され、スタイルシートパスを構築します。

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

`app/assets/stylesheets`ディレクトリ内のスタイルシートアセットへのURLを計算します。これは内部的に`stylesheet_path`を呼び出し、現在のホストまたはアセットホストと結合します。

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

このヘルパーを使用すると、Atomフィードの構築が簡単になります。以下は完全な使用例です：

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

テンプレート内のブロックの実行時間を測定し、その結果をログに記録することができます。このブロックを高コストな操作やボトルネックの可能性がある箇所にラップして、操作の時間を測定します。
```html+erb
<% ベンチマーク "データファイルの処理" do %>
  <%= expensive_files_operation %>
<% end %>
```

これにより、ログに「データファイルの処理（0.34523）」のようなものが追加され、コードの最適化時にタイミングを比較するために使用できます。

### CacheHelper

#### cache

アクションやページ全体ではなく、ビューの一部をキャッシュするためのメソッドです。メニューやニューストピックのリスト、静的なHTMLフラグメントなどの一部をキャッシュするのに便利なテクニックです。このメソッドは、キャッシュするコンテンツを含むブロックを受け取ります。詳細については、`AbstractController::Caching::Fragments`を参照してください。

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

`capture`メソッドを使用すると、テンプレートの一部を変数に抽出することができます。その後、この変数をテンプレートやレイアウトのどこでも使用できます。

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

抽出された変数は他の場所でも使用できます。

```html+erb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

`content_for`を呼び出すと、マークアップのブロックを識別子に保存します。その後、`yield`に識別子を引数として渡すことで、他のテンプレートやレイアウトで保存されたコンテンツに対して後続の呼び出しを行うことができます。

たとえば、標準のアプリケーションレイアウトと、他のサイトが必要としない特別なページがあるとします。`content_for`を使用して、この特別なページにJavaScriptを含めることができますが、他のサイトを肥大化させることはありません。

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

2つのTimeまたはDateオブジェクトまたは整数（秒単位）間の時間のおおよその距離を報告します。`include_seconds`をtrueに設定すると、詳細な近似値を取得できます。

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => less than a minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => less than 20 seconds
```

#### time_ago_in_words

`distance_of_time_in_words`と同様ですが、`to_time`が`Time.now`に固定されています。

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutes
```

### DebugHelper

オブジェクトをYAMLでダンプした`pre`タグを返します。これにより、オブジェクトを視覚的に検査するための非常に読みやすい方法が作成されます。

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

フォームヘルパーは、モデルを使用する場合に、標準のHTML要素だけを使用するよりも、モデルとの作業を簡単にするための一連のメソッドを提供します。このヘルパーは、フォームのHTMLを生成し、各種の入力（テキスト、パスワード、セレクトなど）に対してメソッドを提供します。フォームが送信されると（つまり、ユーザーが送信ボタンをクリックするか、JavaScript経由でform.submitが呼び出されると）、フォームの入力はparamsオブジェクトにまとめられ、コントローラに渡されます。

フォームヘルパーについては、[Action View Form Helpers
Guide](form_helpers.html)を参照してください。

### JavaScriptHelper

ビューでJavaScriptを使用するための機能を提供します。

#### escape_javascript

JavaScriptセグメントのキャリッジリターンとシングルクォート、ダブルクォートをエスケープします。

#### javascript_tag

提供されたコードをラップするJavaScriptタグを返します。

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

数値をフォーマットされた文字列に変換するためのメソッドを提供します。電話番号、通貨、パーセンテージ、精度、位置表記、ファイルサイズに対してメソッドが提供されています。

#### number_to_currency

数値を通貨の文字列（例：$13.65）にフォーマットします。

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human

数値をユーザーが読みやすい形式に整形（フォーマットと近似値）します。非常に大きな数値に便利です。

```ruby
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```

#### number_to_human_size

サイズのバイトをより理解しやすい表現にフォーマットします。ユーザーにファイルサイズを報告するのに便利です。

```ruby
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```

#### number_to_percentage

数値をパーセンテージの文字列にフォーマットします。
```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

電話番号をフォーマットします（デフォルトは米国）。

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

デリミタを使用して、数値をグループ化された桁区切りでフォーマットします。

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

指定された `precision` レベルで数値をフォーマットします。デフォルトは3です。

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

SanitizeHelperモジュールは、テキストから望ましくないHTML要素を取り除くための一連のメソッドを提供します。

#### sanitize

このsanitizeヘルパーは、すべてのタグをHTMLエンコードし、特に許可されていない属性をすべて削除します。

```ruby
sanitize @article.body
```

`attributes`オプションまたは`tags`オプションのいずれかが渡された場合、指定された属性とタグのみが許可され、それ以外は許可されません。

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

デフォルトを複数回使用するためにデフォルトを変更するには、例えばデフォルトにtableタグを追加する場合：

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

CSSコードのブロックをサニタイズします。

#### strip_links(html)

テキストからすべてのリンクタグを削除し、リンクテキストのみを残します。

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

コメントを含むHTMLタグをすべて削除します。この機能はrails-html-sanitizer gemによって提供されます。

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

注：出力にはまだエスケープされていない '<', '>', '&' 文字が含まれる可能性があり、ブラウザを混乱させることがあります。

### UrlHelper

ルーティングサブシステムに依存するリンクを作成し、URLを取得するためのメソッドを提供します。

#### url_for

提供された `options` のセットに対するURLを返します。

##### 例

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

内部的には `url_for` から派生したURLへのリンクを作成します。主にRESTfulリソースリンクを作成するために使用されます。この例では、モデルを `link_to` に渡すことで実現されます。

**例**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

リンク先が名前パラメータに収まらない場合、ブロックを使用することもできます。 ERBの例：

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

次のように出力されます：

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

詳細については、[APIドキュメントを参照してください](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

渡されたURLに送信するフォームを生成します。フォームには `name` の値を持つ送信ボタンがあります。

##### 例

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

おおよそ次のような出力になります：

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

詳細については、[APIドキュメントを参照してください](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

クロスサイトリクエストフォージリプロテクションパラメータとトークンの名前を持つメタタグ "csrf-param" と "csrf-token" を返します。

```html
<%= csrf_meta_tags %>
```

注意：通常のフォームでは、隠しフィールドが生成されるため、これらのタグは使用されません。詳細については、[Railsセキュリティガイド](security.html#cross-site-request-forgery-csrf)を参照してください。
[`config.asset_host`]: configuring.html#config-asset-host
