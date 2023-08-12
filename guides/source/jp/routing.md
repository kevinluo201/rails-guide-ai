**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fb66c6f4aafffdb8f8d44e8a2076c9b0
外部からのRailsルーティング
=================================

このガイドでは、Railsのルーティングのユーザー向け機能について説明します。

このガイドを読み終えると、以下のことがわかります。

* `config/routes.rb`内のコードの解釈方法
* 好まれるリソースフルスタイルまたは`match`メソッドを使用して独自のルートを構築する方法
* コントローラーアクションに渡されるルートパラメーターの宣言方法
* ルートヘルパーを使用して自動的にパスとURLを作成する方法
* 制約の作成やRackエンドポイントのマウントなどの高度なテクニック

--------------------------------------------------------------------------------

Railsルーターの目的
-------------------

Railsルーターは、URLを認識し、それらをコントローラーアクションまたはRackアプリケーションにディスパッチします。また、ビューで文字列をハードコードする必要がないため、パスとURLを生成することもできます。

### URLとコードの接続

Railsアプリケーションが次のような受信リクエストを受け取った場合：

```
GET /patients/17
```

ルーターにコントローラーアクションと一致するように要求します。最初に一致するルートが次の場合：

```ruby
get '/patients/:id', to: 'patients#show'
```

リクエストは、`patients`コントローラーの`show`アクションに`{ id: '17' }`を`params`としてディスパッチされます。

注意：ここではRailsはコントローラー名にsnake_caseを使用しています。`MonsterTrucksController`のような複数の単語のコントローラーがある場合は、例えば`monster_trucks#show`を使用する必要があります。

### コードからパスとURLを生成する

パスとURLも生成することができます。上記のルートが次のように変更された場合：

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

コントローラーに次のコードが含まれている場合：

```ruby
@patient = Patient.find(params[:id])
```

および対応するビューに次のコードが含まれている場合：

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

ルーターはパス`/patients/17`を生成します。これにより、ビューの脆弱性が低くなり、コードが理解しやすくなります。idはルートヘルパーで指定する必要はありません。

### Railsルーターの設定

アプリケーションまたはエンジンのルートは、`config/routes.rb`というファイルにあり、通常は次のようになります：

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

これは通常のRubyソースファイルなので、ルートを定義するためにすべての機能を使用できますが、ルーターのDSLメソッドと変数名が衝突する可能性があるため、注意が必要です。

注意：ルート定義を囲む`Rails.application.routes.draw do ... end`ブロックは、ルーターDSLのスコープを確立するために必要であり、削除してはいけません。

リソースルーティング：Railsのデフォルト
-----------------------------------

リソースルーティングを使用すると、特定のリソースフルコントローラーに対して一般的なルートをすばやく宣言できます。[`resources`][]への単一の呼び出しで、`index`、`show`、`new`、`edit`、`create`、`update`、`destroy`アクションに必要なすべてのルートを宣言できます。


### ウェブ上のリソース

ブラウザは、特定のHTTPメソッド（`GET`、`POST`、`PATCH`、`PUT`、`DELETE`など）を使用して、URLをリクエストしてRailsからページを要求します。各メソッドは、リソース上で操作を実行するためのリクエストです。リソースルートは、複数の関連するリクエストを単一のコントローラーのアクションにマップします。

Railsアプリケーションが次のような受信リクエストを受け取った場合：

```
DELETE /photos/17
```

ルーターにコントローラーアクションにマップするように要求します。最初に一致するルートが次の場合：

```ruby
resources :photos
```

Railsは、そのリクエストを`photos`コントローラーの`destroy`アクションに`{ id: '17' }`を`params`としてディスパッチします。

### CRUD、動詞、およびアクション

Railsでは、リソースフルなルートは、HTTP動詞とURLをコントローラーアクションにマッピングします。慣例として、各アクションもデータベース内の特定のCRUD操作にマッピングされます。次のようなルーティングファイルのエントリ1つだけで、例えば：

```ruby
resources :photos
```

アプリケーション内には、`Photos`コントローラーにマッピングされる7つの異なるルートが作成されます：

| HTTP動詞 | パス             | コントローラー#アクション | 用途                                         |
| --------- | ---------------- | ----------------- | -------------------------------------------- |
| GET       | /photos          | photos#index      | すべての写真のリストを表示                     |
| GET       | /photos/new      | photos#new        | 新しい写真を作成するためのHTMLフォームを返す   |
| POST      | /photos          | photos#create     | 新しい写真を作成する                           |
| GET       | /photos/:id      | photos#show       | 特定の写真を表示                               |
| GET       | /photos/:id/edit | photos#edit       | 写真を編集するためのHTMLフォームを返す         |
| PATCH/PUT | /photos/:id      | photos#update     | 特定の写真を更新する                           |
| DELETE    | /photos/:id      | photos#destroy    | 特定の写真を削除する                           |
注意：ルーターはHTTPの動詞とURLを使用して受信リクエストとマッチングするため、4つのURLが7つの異なるアクションにマッピングされます。

注意：Railsのルートは指定された順序でマッチングされるため、`resources :photos`の上に`get 'photos/poll'`がある場合、`resources`の行の`show`アクションのルートが`get`の行よりも先にマッチングされます。これを修正するには、`get`の行を`resources`の行の**上**に移動して、最初にマッチングされるようにします。

### パスとURLヘルパー

リソースフルなルートを作成すると、アプリケーションのコントローラにいくつかのヘルパーが公開されます。`resources :photos`の場合：

* `photos_path`は`/photos`を返します
* `new_photo_path`は`/photos/new`を返します
* `edit_photo_path(:id)`は`/photos/:id/edit`を返します（たとえば、`edit_photo_path(10)`は`/photos/10/edit`を返します）
* `photo_path(:id)`は`/photos/:id`を返します（たとえば、`photo_path(10)`は`/photos/10`を返します）

これらのヘルパーのそれぞれには、現在のホスト、ポート、およびパスプレフィックスが前置された同じパスを返す`_url`ヘルパー（たとえば、`photos_url`）が対応しています。

ヒント：ルートのヘルパー名を見つけるには、以下の[既存のルートのリスト](#listing-existing-routes)を参照してください。

### 同時に複数のリソースを定義する

複数のリソースに対してルートを作成する必要がある場合、`resources`への単一の呼び出しでそれらをすべて定義することで、少しのタイピングを節約できます。

```ruby
resources :photos, :books, :videos
```

これは次のように正確に動作します：

```ruby
resources :photos
resources :books
resources :videos
```

### 単数形のリソース

クライアントが常にIDを参照せずに検索するリソースがある場合があります。たとえば、現在ログインしているユーザーのプロフィールを常に`/profile`で表示したい場合、単数形のリソースを使用して`show`アクションに`/profile`（`/profile/:id`ではなく）をマップできます：

```ruby
get 'profile', to: 'users#show'
```

`to:`に`String`を渡すと、`controller#action`の形式が期待されます。`Symbol`を使用する場合は、`to:`オプションを`action:`で置き換える必要があります。`#`なしの`String`を使用する場合は、`to:`オプションを`controller:`で置き換える必要があります：

```ruby
get 'profile', action: :show, controller: 'users'
```

このリソースフルなルート：

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

は、アプリケーションに6つの異なるルートを作成し、すべてが`Geocoders`コントローラにマッピングされます：

| HTTP動詞 | パス                  | コントローラ#アクション | 用途                                          |
| --------- | --------------------- | --------------------- | --------------------------------------------- |
| GET       | /geocoder/new         | geocoders#new         | ジオコーダを作成するためのHTMLフォームを返す |
| POST      | /geocoder             | geocoders#create      | 新しいジオコーダを作成する                   |
| GET       | /geocoder             | geocoders#show        | 唯一のジオコーダリソースを表示する           |
| GET       | /geocoder/edit        | geocoders#edit        | ジオコーダを編集するためのHTMLフォームを返す |
| PATCH/PUT | /geocoder             | geocoders#update      | 唯一のジオコーダリソースを更新する           |
| DELETE    | /geocoder             | geocoders#destroy     | ジオコーダリソースを削除する                 |

注意：単数形のルート（`/account`）と複数形のルート（`/accounts/45`）の両方に同じコントローラを使用したい場合、単数形のリソースは複数形のコントローラにマップされます。したがって、たとえば、`resource :photo`と`resources :photos`は、同じコントローラ（`PhotosController`）にマップされる単数形と複数形のルートを作成します。

単数形のリソースフルなルートは、次のヘルパーを生成します：

* `new_geocoder_path`は`/geocoder/new`を返します
* `edit_geocoder_path`は`/geocoder/edit`を返します
* `geocoder_path`は`/geocoder`を返します

注意：`resolve`への呼び出しは、[レコードの識別](form_helpers.html#relying-on-record-identification)を介して`Geocoder`のインスタンスをルートに変換するために必要です。

複数形のリソースと同様に、ホスト、ポート、およびパスプレフィックスが含まれる`_url`で終わる同じヘルパーもあります。

### コントローラの名前空間とルーティング

コントローラのグループを名前空間の下に整理したい場合があります。最も一般的には、いくつかの管理コントローラを`Admin::`名前空間の下にグループ化し、これらのコントローラを`app/controllers/admin`ディレクトリに配置します。[`namespace`][]ブロックを使用して、そのようなグループにルーティングできます。

```ruby
namespace :admin do
  resources :articles, :comments
end
```

これにより、`articles`と`comments`コントローラのそれぞれにいくつかのルートが作成されます。`Admin::ArticlesController`の場合、Railsは次のように作成します：

| HTTP動詞 | パス                        | コントローラ#アクション | 名前付きルートヘルパー       |
| --------- | --------------------------- | --------------------- | ---------------------------- |
| GET       | /admin/articles             | admin/articles#index  | admin_articles_path          |
| GET       | /admin/articles/new         | admin/articles#new    | new_admin_article_path       |
| POST      | /admin/articles             | admin/articles#create | admin_articles_path          |
| GET       | /admin/articles/:id         | admin/articles#show   | admin_article_path(:id)      |
| GET       | /admin/articles/:id/edit    | admin/articles#edit   | edit_admin_article_path(:id) |
| PATCH/PUT | /admin/articles/:id         | admin/articles#update | admin_article_path(:id)      |
| DELETE    | /admin/articles/:id         | admin/articles#destroy| admin_article_path(:id)      |
もしも`/articles`（`/admin`の接頭辞なし）を`Admin::ArticlesController`にルーティングしたい場合は、[`scope`][]ブロックでモジュールを指定することができます。

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

単一のルートに対しても同様に行うことができます。

```ruby
resources :articles, module: 'admin'
```

もしも`/admin/articles`を`ArticlesController`（`Admin::`モジュール接頭辞なし）にルーティングしたい場合は、`scope`ブロックでパスを指定することができます。

```ruby
scope '/admin' do
  resources :articles, :comments
end
```

単一のルートに対しても同様に行うことができます。

```ruby
resources :articles, path: '/admin/articles'
```

これらの場合、名前付きルートヘルパーは`scope`を使用しなかった場合と同じままです。最後の場合、以下のパスが`ArticlesController`にマップされます。

| HTTPメソッド | パス                     | コントローラー#アクション | 名前付きルートヘルパー |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

TIP: `namespace`ブロック内で異なるコントローラーネームスペースを使用する必要がある場合は、絶対コントローラーパスを指定することができます。例：`get '/foo', to: '/foo#index'`。

### ネストされたリソース

リソースが論理的に他のリソースの子であることは一般的です。例えば、アプリケーションに次のモデルが含まれるとします。

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

ネストされたルートを使用すると、この関係をルーティングで表現することができます。この場合、次のルート宣言を含めることができます。

```ruby
resources :magazines do
  resources :ads
end
```

この宣言により、マガジンに関するルートだけでなく、広告も`AdsController`にルーティングされます。広告のURLにはマガジンが必要です。

| HTTPメソッド | パス                                 | コントローラー#アクション | 用途                                                                   |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | 特定のマガジンのすべての広告のリストを表示する                          |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | 特定のマガジンに所属する新しい広告を作成するためのHTMLフォームを返す |
| POST      | /magazines/:magazine_id/ads          | ads#create        | 特定のマガジンに所属する新しい広告を作成する                           |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | 特定のマガジンに所属する特定の広告を表示する                             |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | 特定のマガジンに所属する特定の広告を編集するためのHTMLフォームを返す     |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | 特定のマガジンに所属する特定の広告を更新する                              |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | 特定のマガジンに所属する特定の広告を削除する                              |

これにより、`magazine_ads_url`や`edit_magazine_ad_path`などのルーティングヘルパーも作成されます。これらのヘルパーは、最初のパラメーターとして`Magazine`のインスタンスを受け取ります（`magazine_ads_url(@magazine)`）。

#### ネストの制限

必要に応じて、他のネストされたリソース内にリソースをネストすることもできます。例えば：

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

深くネストされたリソースはすぐに扱いにくくなります。この場合、アプリケーションは次のようなパスを認識します。

```
/publishers/1/magazines/2/photos/3
```

対応するルートヘルパーは`publisher_magazine_photo_url`であり、3つのレベルすべてでオブジェクトを指定する必要があります。実際、この状況は混乱を招くため、[Jamis Buck氏の人気記事](http://weblog.jamisbuck.org/2007/2/5/nesting-resources)では、良いRailsデザインのための原則を提案しています。

TIP: リソースは1レベル以上のネストにするべきではありません。

#### シャローなネスト

深いネストを避けるための方法の1つは、親の下にコレクションアクションをスコープ付きで生成し、階層を把握するための最小限の情報でリソースを一意に識別するためのルートのみをネストすることです。つまり、次のように記述します。

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

このアイデアは、記述的なルートと深いネストのバランスを取るものです。このために、`:shallow`オプションを使用して短縮構文を使用することもできます。

```ruby
resources :articles do
  resources :comments, shallow: true
end
```
最初の例と同じルートが生成されます。親リソースで `:shallow` オプションを指定することもできます。その場合、すべてのネストされたリソースが浅くなります。

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

ここでの articles リソースには、次のルートが生成されます。

| HTTP メソッド | パス                                         | コントローラー#アクション | 名前付きルートヘルパー       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_comment_path        |
| GET       | /comments/:id(.:format)                      | comments#show     | comment_path             |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | comment_path             |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | comment_path             |
| GET       | /articles/:article_id/quotes(.:format)       | quotes#index      | article_quotes_path      |
| POST      | /articles/:article_id/quotes(.:format)       | quotes#create     | article_quotes_path      |
| GET       | /articles/:article_id/quotes/new(.:format)   | quotes#new        | new_article_quote_path   |
| GET       | /quotes/:id/edit(.:format)                   | quotes#edit       | edit_quote_path          |
| GET       | /quotes/:id(.:format)                        | quotes#show       | quote_path               |
| PATCH/PUT | /quotes/:id(.:format)                        | quotes#update     | quote_path               |
| DELETE    | /quotes/:id(.:format)                        | quotes#destroy    | quote_path               |
| GET       | /articles/:article_id/drafts(.:format)       | drafts#index      | article_drafts_path      |
| POST      | /articles/:article_id/drafts(.:format)       | drafts#create     | article_drafts_path      |
| GET       | /articles/:article_id/drafts/new(.:format)   | drafts#new        | new_article_draft_path   |
| GET       | /drafts/:id/edit(.:format)                   | drafts#edit       | edit_draft_path          |
| GET       | /drafts/:id(.:format)                        | drafts#show       | draft_path               |
| PATCH/PUT | /drafts/:id(.:format)                        | drafts#update     | draft_path               |
| DELETE    | /drafts/:id(.:format)                        | drafts#destroy    | draft_path               |
| GET       | /articles(.:format)                          | articles#index    | articles_path            |
| POST      | /articles(.:format)                          | articles#create   | articles_path            |
| GET       | /articles/new(.:format)                      | articles#new      | new_article_path         |
| GET       | /articles/:id/edit(.:format)                 | articles#edit     | edit_article_path        |
| GET       | /articles/:id(.:format)                      | articles#show     | article_path             |
| PATCH/PUT | /articles/:id(.:format)                      | articles#update   | article_path             |
| DELETE    | /articles/:id(.:format)                      | articles#destroy  | article_path             |

DSL の [`shallow`][] メソッドは、ネストごとにスコープを作成します。これにより、前の例と同じルートが生成されます。

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

浅いルートをカスタマイズするための `scope` のオプションには、2つのオプションがあります。`shallow_path` オプションは、メンバーパスに指定したパラメーターを接頭辞として追加します。

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ここでの comments リソースには、次のルートが生成されます。

| HTTP メソッド | パス                                         | コントローラー#アクション | 名前付きルートヘルパー       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

`shallow_prefix` オプションは、名前付きルートヘルパーに指定したパラメーターを追加します。

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

ここでの comments リソースには、次のルートが生成されます。

| HTTP メソッド | パス                                         | コントローラー#アクション | 名前付きルートヘルパー          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |


### ルーティングの関心事

ルーティングの関心事を使用すると、他のリソースやルート内で再利用できる共通のルートを宣言できます。関心事を定義するには、[`concern`][] ブロックを使用します。

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

これらの関心事は、コードの重複を避け、ルート間での動作を共有するためにリソースで使用できます。

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

上記は次と同じです。

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```
[`concerns`][]を呼び出すことで、どこでも使用することができます。たとえば、`scope`ブロックや`namespace`ブロック内で使用することができます。

```ruby
namespace :articles do
  concerns :commentable
end
```


### オブジェクトからパスとURLを作成する

ルーティングヘルパーを使用するだけでなく、Railsはパラメータの配列からパスとURLを作成することもできます。たとえば、次のルートがあるとします。

```ruby
resources :magazines do
  resources :ads
end
```

`magazine_ad_path`を使用する場合、数値のIDの代わりに`Magazine`と`Ad`のインスタンスを渡すことができます。

```erb
<%= link_to '広告の詳細', magazine_ad_path(@magazine, @ad) %>
```

また、[`url_for`][ActionView::RoutingUrlFor#url_for]をオブジェクトのセットとともに使用することもできます。Railsは自動的にどのルートを使用するかを判断します。

```erb
<%= link_to '広告の詳細', url_for([@magazine, @ad]) %>
```

この場合、Railsは`@magazine`が`Magazine`であり、`@ad`が`Ad`であることを認識し、`magazine_ad_path`ヘルパーを使用します。`link_to`などのヘルパーでは、`url_for`の代わりにオブジェクトだけを指定することもできます。

```erb
<%= link_to '広告の詳細', [@magazine, @ad] %>
```

単にマガジンにリンクする場合は、次のようにします。

```erb
<%= link_to 'マガジンの詳細', @magazine %>
```

その他のアクションの場合は、配列の最初の要素としてアクション名を挿入するだけです。

```erb
<%= link_to '広告の編集', [:edit, @magazine, @ad] %>
```

これにより、モデルのインスタンスをURLとして扱うことができ、リソースフルなスタイルを使用することの主な利点です。


### 追加のRESTfulアクションの追加

RESTfulルーティングがデフォルトで作成する7つのルートに制限されることはありません。必要に応じて、コレクションまたはコレクションの個々のメンバーに適用される追加のルートを追加することができます。

#### メンバールートの追加

メンバールートを追加するには、リソースブロックに[`member`][]ブロックを追加します。

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

これにより、GETで`/photos/1/preview`が認識され、`PhotosController`の`preview`アクションにルーティングされます。リソースIDの値は`params[:id]`に渡されます。また、`preview_photo_url`と`preview_photo_path`のヘルパーも作成されます。

メンバールートのブロック内では、各ルート名は認識されるHTTP動詞を指定します。ここでは[`get`][], [`patch`][], [`put`][], [`post`][], [`delete`][]を使用できます。複数の`member`ルートがない場合は、ブロックを省略して`route`に`:on`を渡すこともできます。

```ruby
resources :photos do
  get 'preview', on: :member
end
```

`:on`オプションを省略することもできます。これにより、リソースIDの値が`params[:id]`ではなく`params[:photo_id]`で利用できる同じメンバールートが作成されます。ルートヘルパーも`preview_photo_url`と`preview_photo_path`から`photo_preview_url`と`photo_preview_path`に名前が変更されます。


#### コレクションルートの追加

[`collection`][]ブロックを使用してコレクションにルートを追加します。

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

これにより、GETで`/photos/search`などのパスが認識され、`PhotosController`の`search`アクションにルーティングされます。また、`search_photos_url`と`search_photos_path`のルートヘルパーも作成されます。

メンバールートと同様に、ルートに`:on`を渡すことができます。

```ruby
resources :photos do
  get 'search', on: :collection
end
```

注意: 最初の位置引数としてシンボルを使用して追加のリソースルートを定義している場合、シンボルと文字列は同等ではないことに注意してください。シンボルはコントローラのアクションを推測し、文字列はパスを推測します。


#### その他の新しいアクションのためのルートの追加

`on: :new`のショートカットを使用して別の新しいアクションを追加するには、次のようにします。

```ruby
resources :comments do
  get 'preview', on: :new
end
```

これにより、GETで`/comments/new/preview`などのパスが認識され、`CommentsController`の`preview`アクションにルーティングされます。また、`preview_new_comment_url`と`preview_new_comment_path`のルートヘルパーも作成されます。

TIP: リソースフルなルートに多くの追加アクションを追加している場合は、別のリソースの存在を隠している可能性があるため、停止して自分自身に尋ねる時が来たと考えてください。

リソースフルでないルート
----------------------

リソースルーティングに加えて、Railsは任意のURLをアクションにルーティングするための強力なサポートを提供しています。ここでは、リソースフルなルーティングによって自動的に生成されるルートグループはありません。代わりに、アプリケーション内で各ルートを個別に設定します。

通常はリソースフルなルーティングを使用するべきですが、シンプルなルーティングの方が適している場合も多くあります。リソースフルなフレームワークにアプリケーションの最後の一部を無理にはめ込む必要はありません。
特に、シンプルなルーティングにより、既存のURLを新しいRailsアクションにマッピングすることが非常に簡単になります。

### バウンドパラメータ

通常のルートを設定する際に、Railsは受信したHTTPリクエストの一部としてマップするシンボルのシリーズを指定します。例えば、次のルートを考えてみてください。

```ruby
get 'photos(/:id)', to: 'photos#display'
```

このルートによって処理される受信したリクエストが `/photos/1` の場合（ファイル内の他のルートと一致しなかったため）、結果は `PhotosController` の `display` アクションを呼び出し、最終パラメータ `"1"` を `params[:id]` として利用できるようになります。このルートは、オプションのパラメータである `:id` を括弧で囲んでいるため、`/photos` という受信したリクエストも `PhotosController#display` にルーティングします。

### ダイナミックセグメント

通常のルート内には、任意の数のダイナミックセグメントを設定できます。セグメントは、`params` の一部としてアクションで利用できます。次のようなルートを設定した場合、

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

`/photos/1/2` というパスが `PhotosController` の `show` アクションにディスパッチされます。`params[:id]` は `"1"` となり、`params[:user_id]` は `"2"` となります。

TIP: ダイナミックセグメントはデフォルトではドットを受け付けません。これは、ドットがフォーマットされたルートの区切り文字として使用されるためです。ダイナミックセグメント内でドットを使用する必要がある場合は、これを上書きする制約を追加してください。例えば、`id: /[^\/]+/` はスラッシュ以外の任意の文字を許可します。

### スタティックセグメント

セグメントの前にコロンを付けずにルートを作成することで、スタティックセグメントを指定できます。

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

このルートは `/photos/1/with_user/2` のようなパスに応答します。この場合、`params` は `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }` となります。

### クエリ文字列

`params` には、クエリ文字列からのパラメータも含まれます。例えば、次のルートを持つ場合、

```ruby
get 'photos/:id', to: 'photos#show'
```

`/photos/1?user_id=2` というパスが `Photos` コントローラーの `show` アクションにディスパッチされます。`params` は `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }` となります。

### デフォルトの定義

ルートにデフォルトを定義するには、`:defaults` オプションにハッシュを指定します。これは、ダイナミックセグメントとして指定しないパラメータにも適用されます。例えば、

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Railsは `photos/12` を `PhotosController` の `show` アクションにマッチさせ、`params[:format]` を `"jpg"` に設定します。

また、[`defaults`][] ブロックを使用して複数のアイテムのデフォルトを定義することもできます。

```ruby
defaults format: :json do
  resources :photos
end
```

NOTE: クエリパラメータを介してデフォルトを上書きすることはできません。これはセキュリティ上の理由からです。URLパス内のダイナミックセグメントを置換することでのみ、デフォルトを上書きできます。

### ルートの名前付け

`:as` オプションを使用して、任意のルートに名前を指定できます。

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

これにより、アプリケーション内の名前付きルートヘルパーとして `logout_path` と `logout_url` が作成されます。`logout_path` を呼び出すと `/exit` が返されます。

また、これを使用して、カスタムルートがリソースによって定義されたルーティングメソッドを上書きすることもできます。カスタムルートをリソースの定義の前に配置することで、次のようにします。

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

これにより、コントローラー、ヘルパー、ビューで利用できる `user_path` メソッドが定義され、`/bob` のようなルートに移動します。`UsersController` の `show` アクション内では、`params[:username]` にユーザーのユーザー名が含まれます。パラメータ名を `:username` 以外にしたい場合は、ルート定義内の `:username` を変更してください。

### HTTP動詞の制約

一般的には、[`get`][]、[`post`][]、[`put`][]、[`patch`][]、[`delete`][] メソッドを使用して、ルートを特定の動詞に制約するべきです。[`match`][] メソッドを `:via` オプションとともに使用して、複数の動詞に一致させることもできます。

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

`via: :all` を使用して、すべての動詞を特定のルートに一致させることもできます。

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: `GET` と `POST` の両方のリクエストを単一のアクションにルーティングすることにはセキュリティ上の問題があります。一般的には、良い理由がない限り、すべての動詞をアクションにルーティングすることは避けるべきです。

NOTE: Railsの `GET` はCSRFトークンをチェックしません。`GET` リクエストからデータベースに書き込むことは絶対に行わないでください。詳細については、CSRF対策の[セキュリティガイド](security.html#csrf-countermeasures)を参照してください。
### セグメントの制約

動的セグメントのフォーマットを強制するために、`:constraints` オプションを使用することができます。

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

このルートは `/photos/A12345` のようなパスにマッチしますが、`/photos/893` のようなパスにはマッチしません。同じルートをより簡潔に表現することもできます。

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` は正規表現を受け取りますが、正規表現のアンカーは使用できません。例えば、次のルートは機能しません。

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

ただし、すべてのルートは開始と終了でアンカーが設定されているため、アンカーを使用する必要はありません。

例えば、次のルートは、常に数字で始まる `1-hello-world` のような `articles` の `to_param` 値と、数字で始まらない `david` のような `users` の `to_param` 値が同じルート名前空間を共有できるようにします。

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### リクエストベースの制約

リクエストオブジェクトの任意のメソッドを基にルートを制約することもできます。

セグメントの制約と同じように、リクエストベースの制約を指定します。

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

また、[`constraints`][] ブロックを使用して制約を指定することもできます。

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

注意: リクエストの制約は、ハッシュのキーと同じ名前のメソッドを [Request オブジェクト](action_controller_overview.html#the-request-object) 上で呼び出し、その戻り値とハッシュの値を比較することで動作します。したがって、制約の値は対応する Request オブジェクトのメソッドの戻り値の型と一致する必要があります。例えば: `constraints: { subdomain: 'api' }` は、予想どおりに `api` サブドメインにマッチします。ただし、シンボルを使用した `constraints: { subdomain: :api }` はマッチしません。なぜなら、`request.subdomain` は文字列 `'api'` を返すからです。

注意: `format` 制約には例外があります。これは Request オブジェクトのメソッドですが、すべてのパスに暗黙のオプションパラメータとして存在します。セグメントの制約が優先され、`format` 制約はハッシュを介して強制された場合にのみ適用されます。例えば、`get 'foo', constraints: { format: 'json' }` は `GET  /foo` にマッチします。なぜなら、デフォルトではフォーマットはオプションです。ただし、`get 'foo', constraints: lambda { |req| req.format == :json }` のように [lambda を使用](#advanced-constraints) すると、明示的な JSON リクエストのみがルートにマッチします。


### 高度な制約

より高度な制約がある場合は、Rails が使用する `matches?` メソッドに応答するオブジェクトを指定することができます。例えば、制限されたリストのすべてのユーザーを `RestrictedListController` にルーティングしたい場合、次のようにすることができます。

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

また、`lambda` を使用して制約を指定することもできます。

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

`matches?` メソッドと lambda の両方が `request` オブジェクトを引数として受け取ります。

#### ブロック形式での制約の指定

ブロック形式で制約を指定することもできます。これは、複数のルートに同じルールを適用する必要がある場合に便利です。例えば:

```ruby
class RestrictedListConstraint
  # ...上記の例と同じ
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

`lambda` を使用することもできます。

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### ルートのグロビングとワイルドカードセグメント

ルートのグロビングは、特定のパラメータがルートの残りの部分にマッチするように指定する方法です。例えば:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

このルートは `photos/12` や `/photos/long/path/to/12` にマッチし、`params[:other]` には `"12"` や `"long/path/to/12"` が設定されます。星印で始まるセグメントは「ワイルドカードセグメント」と呼ばれます。

ワイルドカードセグメントはルートのどこにでも現れることができます。例えば:

```ruby
get 'books/*section/:title', to: 'books#show'
```

は `books/some/section/last-words-a-memoir` にマッチし、`params[:section]` は `'some/section'`、`params[:title]` は `'last-words-a-memoir'` になります。

技術的には、ルートには複数のワイルドカードセグメントがある場合もあります。マッチャーはセグメントをパラメータに直感的に割り当てます。例えば:

```ruby
get '*a/foo/*b', to: 'test#index'
```

は `zoo/woo/foo/bar/baz` にマッチし、`params[:a]` は `'zoo/woo'`、`params[:b]` は `'bar/baz'` になります。
注意：`'/foo/bar.json'`をリクエストすると、`params[:pages]`はJSON形式のリクエストフォーマットで`'foo/bar'`となります。古い3.0.xの動作を復元するには、次のように`format: false`を指定することができます。

```ruby
get '*pages', to: 'pages#show', format: false
```

注意：フォーマットセグメントを省略できないようにするには、`format: true`を指定することができます。

```ruby
get '*pages', to: 'pages#show', format: true
```

### リダイレクト

ルーターで[`redirect`][]ヘルパーを使用して、任意のパスを別のパスにリダイレクトすることができます。

```ruby
get '/stories', to: redirect('/articles')
```

マッチしたパスの動的セグメントをパスに再利用してリダイレクトすることもできます。

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

`redirect`にはブロックを指定することもできます。このブロックは、シンボル化されたパスパラメータとリクエストオブジェクトを受け取ります。

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

デフォルトのリダイレクトは301「Moved Permanently」リダイレクトです。一部のウェブブラウザやプロキシサーバーは、このタイプのリダイレクトをキャッシュし、古いページにアクセスできなくする場合があります。レスポンスステータスを変更するには、`:status`オプションを使用できます。

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

これらの場合、先頭のホスト（`http://www.example.com`）を指定しない場合、Railsは現在のリクエストからこれらの詳細を取得します。


### Rackアプリケーションへのルーティング

`'articles#index'`のような文字列は、`ArticlesController`の`index`アクションに対応しますが、マッチャーのエンドポイントとして[Rackアプリケーション](rails_on_rack.html)を指定することもできます。

```ruby
match '/application.js', to: MyRackApp, via: :all
```

`MyRackApp`が`call`に応答し、`[status, headers, body]`を返す限り、ルーターはRackアプリケーションとアクションの違いを認識しません。これは、`via: :all`の適切な使用例です。Rackアプリケーションが適切と考えるすべての動詞を処理できるようにするためです。

注意：興味がある場合、`'articles#index'`は実際には`ArticlesController.action(:index)`に展開されます。これは有効なRackアプリケーションを返します。

注意：プロック/ラムダは`call`に応答するオブジェクトであるため、非常にシンプルなルート（たとえば、ヘルスチェック用）をインラインで実装することができます：<br>`get '/health', to: ->(env) { [204, {}, ['']] }`

マッチャーのエンドポイントとしてRackアプリケーションを指定する場合、受信アプリケーションではルートが変更されないことに注意してください。次のルートでは、Rackアプリケーションはルートが`/admin`であることを想定する必要があります。

```ruby
match '/admin', to: AdminApp, via: :all
```

Rackアプリケーションが代わりにルートパスでリクエストを受け取るようにしたい場合は、[`mount`][]を使用します。

```ruby
mount AdminApp, at: '/admin'
```


### `root`の使用

[`root`][]メソッドを使用して、Railsが`'/'`をどのアクションにルーティングするかを指定できます。

```ruby
root to: 'pages#main'
root 'pages#main' # 上記のショートカット
```

`root`ルートはファイルの先頭に配置する必要があります。最も一般的なルートであり、最初にマッチする必要があるためです。

注意：`root`ルートは`GET`リクエストのみをアクションにルーティングします。

ネームスペースやスコープ内でも`root`を使用することができます。例：

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### Unicode文字ルート

Unicode文字ルートを直接指定することができます。例：

```ruby
get 'こんにちは', to: 'welcome#index'
```

### 直接ルート

[`direct`][]を呼び出すことで、直接カスタムURLヘルパーを作成することができます。例：

```ruby
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

ブロックの戻り値は、`url_for`メソッドの有効な引数である必要があります。有効な文字列URL、ハッシュ、配列、Active Modelのインスタンス、またはActive Modelクラスを渡すことができます。

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### `resolve`の使用

[`resolve`][]メソッドを使用すると、モデルのポリモーフィックなマッピングをカスタマイズすることができます。例：

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```

これにより、通常の`/baskets/:id`の代わりに単数形のURL `/basket`が生成されます。


リソースフルルートのカスタマイズ
------------------------------

[`resources`][]によって生成されるデフォルトのルートとヘルパーは通常うまく機能しますが、何らかの方法でカスタマイズする必要がある場合があります。Railsでは、リソースフルヘルパーのほとんどの一般的な部分をカスタマイズすることができます。
### コントローラの指定

`:controller`オプションを使用すると、リソースに使用するコントローラを明示的に指定できます。例えば：

```ruby
resources :photos, controller: 'images'
```

これにより、`/photos`で始まるパスは認識されますが、`Images`コントローラにルーティングされます：

| HTTPメソッド | パス             | コントローラ＃アクション | 名前付きルートヘルパー   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | images#index      | photos_path          |
| GET       | /photos/new      | images#new        | new_photo_path       |
| POST      | /photos          | images#create     | photos_path          |
| GET       | /photos/:id      | images#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | images#destroy    | photo_path(:id)      |

注意：このリソースのパスを生成するために`photos_path`、`new_photo_path`などを使用してください。

ネームスペース付きのコントローラの場合、ディレクトリ表記を使用できます。例えば：

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

これは`Admin::UserPermissions`コントローラにルーティングされます。

注意：ディレクトリ表記のみがサポートされています。Rubyの定数表記（例：`controller: 'Admin::UserPermissions'`）でコントローラを指定すると、ルーティングの問題が発生し、警告が表示されます。

### 制約の指定

`:constraints`オプションを使用して、暗黙の`id`に必要な形式を指定できます。例えば：

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

この宣言は、`:id`パラメータが指定された正規表現と一致するように制約します。したがって、この場合、ルーターは`/photos/1`をこのルートに一致させません。代わりに、`/photos/RR27`が一致します。

ブロック形式を使用して、複数のルートに単一の制約を適用することもできます。

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

注意：もちろん、このコンテキストで非リソースフルなルートで使用できるより高度な制約を使用することもできます。

TIP：デフォルトでは、`：id`パラメータはドットを受け付けません。これは、ドットがフォーマットされたルートのセパレータとして使用されるためです。`：id`内でドットを使用する必要がある場合は、これを上書きする制約を追加します。たとえば、`id: /[^\/]+/`はスラッシュ以外の任意の文字を許可します。

### 名前付きルートヘルパーの上書き

`:as`オプションを使用すると、名前付きルートヘルパーの通常の命名を上書きできます。例えば：

```ruby
resources :photos, as: 'images'
```

これにより、`/photos`で始まるパスは認識され、リクエストは`PhotosController`にルーティングされますが、ヘルパーの名前に`:as`オプションの値が使用されます。

| HTTPメソッド | パス             | コントローラ＃アクション | 名前付きルートヘルパー   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | images_path          |
| GET       | /photos/new      | photos#new        | new_image_path       |
| POST      | /photos          | photos#create     | images_path          |
| GET       | /photos/:id      | photos#show       | image_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | image_path(:id)      |

### `new`および`edit`セグメントの上書き

`:path_names`オプションを使用すると、自動生成されたパスの`new`および`edit`セグメントを上書きできます。

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

これにより、以下のようなパスがルーティングで認識されます：

```
/photos/make
/photos/1/change
```

注意：このオプションによって実際のアクション名は変更されません。表示される2つのパスは、依然として`new`および`edit`アクションにルーティングされます。

TIP：このオプションをすべてのルートに一貫して適用したい場合は、以下のようにスコープを使用できます：

```ruby
scope path_names: { new: 'make' } do
  # 他のルート
end
```

### 名前付きルートヘルパーのプレフィックス

`：as`オプションを使用して、Railsがルートに対して生成する名前付きルートヘルパーのプレフィックスを指定できます。このオプションを使用して、パススコープを使用するルート間の名前の衝突を防ぐことができます。例えば：

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

これにより、`/admin/photos`のルートヘルパーは`photos_path`、`new_photos_path`などから`admin_photos_path`、`new_admin_photo_path`などに変更されます。スコープ付きの`resources :photos`に`as: 'admin_photos'`を追加しない場合、スコープのない`resources :photos`にはルートヘルパーがありません。

ルートヘルパーのグループにプレフィックスを付けるには、`scope`と`：as`を使用します：

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

前述のように、`/admin`スコープのリソースヘルパーは`admin_photos_path`および`admin_accounts_path`に変更され、スコープのないリソースは`photos_path`および`accounts_path`を使用できます。
注意：`namespace`スコープは、`:as`だけでなく、`:module`と`:path`の接頭辞も自動的に追加されます。

#### パラメータスコープ

名前付きパラメータでルートに接頭辞を付けることができます：

```ruby
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

これにより、`/1/articles/9`などのパスが提供され、コントローラ、ヘルパー、ビューでパスの`account_id`部分を`params[:account_id]`として参照することができます。

また、`account_`で接頭辞が付いたパスとURLのヘルパーも生成されます。これには、通常どおりオブジェクトを渡すことができます：

```ruby
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

[制約を使用して](#segment-constraints)、スコープをIDのような文字列にマッチするように制限しています。制約を必要に応じて変更するか、完全に省略することができます。`:as`オプションも厳密に必要ではありませんが、それがないと、`url_for([@account, @article])`や[`form_with`][]などの`url_for`に依存する他のヘルパーを評価するときにRailsがエラーを発生させます。


### 作成されるルートの制限

デフォルトでは、RailsはアプリケーションのすべてのRESTfulルートに対して7つのデフォルトアクション（`index`、`show`、`new`、`create`、`edit`、`update`、`destroy`）のルートを作成します。`:only`オプションと`:except`オプションを使用してこの動作を細かく調整することができます。`:only`オプションは、指定したルートのみを作成するようにRailsに指示します：

```ruby
resources :photos, only: [:index, :show]
```

これにより、`/photos`への`GET`リクエストは成功しますが、`/photos`への`POST`リクエスト（通常は`create`アクションにルーティングされる）は失敗します。

`except`オプションは、Railsが作成しないルートまたはルートのリストを指定します：

```ruby
resources :photos, except: :destroy
```

この場合、Railsは`destroy`のルート（`/photos/:id`への`DELETE`リクエスト）を除くすべての通常のルートを作成します。

TIP: アプリケーションにRESTfulルートが多い場合、必要なルートのみを生成するために`only`と`except`を使用すると、メモリ使用量を削減し、ルーティングプロセスを高速化することができます。

### 翻訳されたパス

`scope`を使用すると、`resources`によって生成されるパス名を変更することができます：

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

これにより、Railsは`CategoriesController`へのルートを作成します。

| HTTPメソッド | パス                       | コントローラ#アクション  | 名前付きルートヘルパー      |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### 単数形のオーバーライド

リソースの単数形をオーバーライドしたい場合は、[`inflections`][]を介してインフレクタに追加のルールを追加する必要があります：

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### ネストされたリソースでの`：as`の使用

`：as`オプションは、ネストされたルートヘルパーで自動生成されるリソースの名前を上書きします。例：

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

これにより、`magazine_periodical_ads_url`や`edit_magazine_periodical_ad_path`などのルーティングヘルパーが作成されます。

### 名前付きルートパラメータのオーバーライド

`:param`オプションは、デフォルトのリソース識別子`:id`（ルートを生成するために使用される[動的セグメント](routing.html#dynamic-segments)の名前）を上書きします。コントローラからそのセグメントにアクセスするには、`params[<:param>]`を使用します。

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

関連するモデルの`ActiveRecord::Base#to_param`をオーバーライドしてURLを構築することもできます：

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

非常に大きなルートファイルを複数の小さなファイルに分割する
-------------------------------------------------------

数千のルートを持つ大規模なアプリケーションで作業する場合、単一の`config/routes.rb`ファイルは扱いにくく、読みにくくなることがあります。

Railsには、[`draw`][]マクロを使用して巨大な単一の`routes.rb`ファイルを複数の小さなファイルに分割する方法があります。

管理エリアのすべてのルートを含む`admin.rb`ルート、API関連のリソース用の別の`api.rb`ファイルなどを持つことができます。

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # `config/routes/admin.rb`にある別のルートファイルを読み込みます
end
```
```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

`Rails.application.routes.draw`ブロック内で`draw(:admin)`を呼び出すと、引数として与えられた名前と同じ名前のルートファイルを読み込もうとします（この例では`admin.rb`）。ファイルは`config/routes`ディレクトリまたはそのサブディレクトリ（つまり、`config/routes/admin.rb`または`config/routes/external/admin.rb`）に配置する必要があります。

`admin.rb`ルーティングファイル内では通常のルーティングDSLを使用できますが、メインの`config/routes.rb`ファイルと同様に`Rails.application.routes.draw`ブロックで囲む必要はありません。


### 本当に必要な場合以外はこの機能を使用しないでください

複数のルーティングファイルを持つことは、見つけやすさや理解しやすさを損ないます。ほとんどのアプリケーションでは、数百のルートを持つ場合でも、開発者が単一のルーティングファイルを持つ方が簡単です。RailsのルーティングDSLは、`namespace`や`scope`を使用してルートを整理する方法を既に提供しています。


ルートの検査とテスト
-------------------

Railsには、ルートを検査およびテストするための機能が用意されています。

### 現在のルートの一覧表示

アプリケーションで利用可能なすべてのルートの完全な一覧を取得するには、サーバーが**development**環境で実行されている状態でブラウザで<http://localhost:3000/rails/info/routes>を開きます。または、ターミナルで`bin/rails routes`コマンドを実行して同じ出力を生成することもできます。

どちらの方法でも、`config/routes.rb`に記載されている順序と同じ順序ですべてのルートがリストされます。各ルートには以下の情報が表示されます。

* ルート名（ある場合）
* 使用されるHTTP動詞（ルートがすべての動詞に応答しない場合）
* マッチするURLパターン
* ルートのルーティングパラメータ

たとえば、RESTfulなルートの`bin/rails routes`出力の一部を以下に示します。

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

また、`--expanded`オプションを使用して展開されたテーブル形式のモードをオンにすることもできます。

```bash
$ bin/rails routes --expanded

--[ ルート 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ ルート 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ ルート 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ ルート 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```

grepオプションを使用してルートを検索することもできます。これにより、URLヘルパーメソッド名、HTTP動詞、またはURLパスと部分一致するルートが出力されます。

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

特定のコントローラにマップされるルートのみを表示したい場合は、-cオプションを使用します。

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

TIP: `bin/rails routes`の出力は、出力行が折り返されないようにターミナルウィンドウの幅を広げると読みやすくなります。

### ルートのテスト

ルートは、アプリケーションの他の部分と同様に、テスト戦略に含めるべきです。Railsには、ルートのテストをより簡単にするための3つの組み込みアサーションが用意されています。

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]


#### `assert_generates`アサーション

[`assert_generates`][]は、特定のオプションが特定のパスを生成することをアサートし、デフォルトのルートまたはカスタムルートと共に使用できます。例えば：

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### `assert_recognizes`アサーション

[`assert_recognizes`][]は、`assert_generates`の逆です。与えられたパスが認識され、アプリケーション内の特定の場所にルーティングされることをアサートします。例えば：

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

`:method`引数を指定してHTTP動詞を指定することもできます。

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### `assert_routing`アサーション

[`assert_routing`][]アサーションは、パスがオプションを生成し、オプションがパスを生成することの両方をチェックします。つまり、`assert_generates`と`assert_recognizes`の機能を組み合わせています。

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope
[`shallow`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-shallow
[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection
[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults
[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match
[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints
[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect
[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount
[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root
[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct
[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve
[`form_with`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections
[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw
[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing
