**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 975163c53746728404fb3a3658fbd0f6
Action Viewフォームヘルパー
========================

Webアプリケーションのフォームは、ユーザーの入力のための重要なインターフェースです。ただし、フォームのマークアップは、フォームコントロールの名前付けやその多くの属性の処理が必要なため、すぐに書くのが面倒になり、メンテナンスが難しくなることがあります。Railsは、フォームマークアップを生成するためのビューヘルパーを提供することで、この複雑さを取り除きます。ただし、これらのヘルパーメソッドには異なる使用例があるため、開発者はヘルパーメソッドの違いを知っておく必要があります。

このガイドを読むことで、以下のことがわかります。

* アプリケーションの特定のモデルを表さない、検索フォームや同様の一般的なフォームを作成する方法。
* 特定のデータベースレコードの作成や編集のためのモデル中心のフォームを作成する方法。
* 複数のデータ型から選択ボックスを生成する方法。
* Railsが提供する日付と時刻のヘルパー。
* ファイルのアップロードフォームの特徴。
* 外部リソースにフォームを投稿し、`authenticity_token`を設定する方法。
* 複雑なフォームの作成方法。

--------------------------------------------------------------------------------

注意: このガイドは、利用可能なフォームヘルパーとその引数の完全なドキュメントではありません。すべての利用可能なヘルパーの完全なリファレンスについては、[Rails APIドキュメント](https://api.rubyonrails.org/classes/ActionView/Helpers.html)を参照してください。

基本的なフォームの処理
------------------------

メインのフォームヘルパーは[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)です。

```erb
<%= form_with do |form| %>
  フォームの内容
<% end %>
```

このように引数なしで呼び出されると、現在のページにPOSTされるフォームタグが作成されます。たとえば、現在のページがホームページであると仮定すると、生成されるHTMLは次のようになります。

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  フォームの内容
</form>
```

HTMLには、`hidden`タイプの`input`要素が含まれていることに注意してください。この`input`は重要です。なぜなら、`GET`以外のフォームは、これなしでは正常に送信できないからです。
名前が`authenticity_token`の非表示の入力要素は、Railsのセキュリティ機能である**クロスサイトリクエストフォージェリ保護**です。フォームヘルパーは、このセキュリティ機能が有効な場合に、すべての`GET`以外のフォームに対してこれを生成します。詳細については、[Railsアプリケーションのセキュリティ](security.html#cross-site-request-forgery-csrf)ガイドを参照してください。

### 一般的な検索フォーム

Web上で最も基本的なフォームの1つは、検索フォームです。このフォームには以下が含まれます。

* "GET"メソッドを持つフォーム要素
* 入力のためのラベル
* テキスト入力要素
* 送信要素

このフォームを作成するには、`form_with`とそれが生成するフォームビルダーオブジェクトを使用します。次のようになります。

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

これにより、次のHTMLが生成されます。

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

TIP: `form_with`に`url: my_specified_path`を渡すことで、リクエストを行う場所をフォームに指定できます。ただし、以下で説明するように、フォームにActive Recordオブジェクトを渡すこともできます。

TIP: 各フォーム入力には、その名前からID属性が生成されます（上記の例では`"query"`）。これらのIDは、CSSスタイリングやJavaScriptでのフォームコントロールの操作に非常に便利です。

重要: 検索フォームではメソッドとして"GET"を使用してください。これにより、ユーザーは特定の検索をブックマークし、それに戻ることができます。一般的に、Railsはアクションに適切なHTTP動詞を使用することを推奨しています。

### フォーム要素を生成するためのヘルパー

`form_with`によって生成されるフォームビルダーオブジェクトは、テキストフィールド、チェックボックス、ラジオボタンなどのフォーム要素を生成するための多くのヘルパーメソッドを提供します。これらのメソッドへの最初のパラメータは常に入力の名前です。
フォームが送信されると、名前はフォームデータとともに渡され、ユーザーが入力した値がコントローラの`params`に渡されます。たとえば、フォームに`<%= form.text_field :query %>`が含まれている場合、コントローラでこのフィールドの値を`params[:query]`で取得できます。
Railsは、入力の名前付けに特定の規則を使用しています。これにより、配列やハッシュなどのスカラー以外の値を含むパラメータを送信することが可能になり、これらの値は`params`でアクセスできます。詳細については、このガイドの[パラメータの命名規則の理解](#understanding-parameter-naming-conventions)セクションで詳しく説明しています。これらのヘルパーの正確な使用方法については、[APIドキュメント](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)を参照してください。

#### チェックボックス

チェックボックスは、ユーザーが有効または無効にできるオプションのセットを提供するフォームコントロールです。

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "I own a dog" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "I own a cat" %>
```

これにより、以下のような出力が生成されます。

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">I own a dog</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">I own a cat</label>
```

[`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box)の最初のパラメータは、入力の名前です。チェックボックスの値（`params`に表示される値）は、オプションで3番目と4番目のパラメータを使用して指定することもできます。詳細については、APIドキュメントを参照してください。

#### ラジオボタン

ラジオボタンは、チェックボックスに似ていますが、ユーザーが1つだけ選択できるオプションのセットを指定するコントロールです。

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "I am younger than 21" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "I am over 21" %>
```

出力:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">I am younger than 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">I am over 21</label>
```

[`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button)の2番目のパラメータは、入力の値です。これらの2つのラジオボタンは同じ名前（`age`）を共有しているため、ユーザーはそれらのうちの1つしか選択できず、`params[:age]`には`"child"`または`"adult"`が含まれます。

注意: チェックボックスとラジオボタンには常にラベルを使用してください。ラベルは特定のオプションにテキストを関連付け、クリック可能な領域を拡大することで、ユーザーが入力をクリックしやすくします。

### その他の興味深いヘルパー

他の価値のあるフォームコントロールには、テキストエリア、非表示フィールド、パスワードフィールド、数値フィールド、日付と時刻フィールドなどがあります。

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

出力:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

非表示の入力はユーザーに表示されず、テキスト入力と同様にデータを保持します。それらの内部の値はJavaScriptで変更することができます。

重要: 検索、電話、日付、時刻、色、日時、日時-ローカル、月、週、URL、メール、数値、範囲の入力は、HTML5のコントロールです。古いブラウザでも一貫した体験を提供する必要がある場合は、HTML5のポリフィル（CSSおよび/またはJavaScriptによって提供される）が必要です。[多くの解決策が存在します](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills)が、現在人気のあるツールは[Modernizr](https://modernizr.com/)です。これは、検出されたHTML5の機能の存在に基づいて機能を追加する簡単な方法を提供します。
ヒント：パスワード入力フィールド（どの目的でも）を使用している場合は、アプリケーションを設定してこれらのパラメータがログに記録されないようにすることをお勧めします。これについては、[Securing Rails Applications](security.html#logging)ガイドで学ぶことができます。

モデルオブジェクトの取り扱い
--------------------------

### フォームをオブジェクトにバインドする

`form_with`の`:model`引数を使用すると、フォームビルダーオブジェクトをモデルオブジェクトにバインドできます。これにより、フォームはそのモデルオブジェクトにスコープされ、フォームのフィールドはそのモデルオブジェクトの値で自動的に埋められます。

たとえば、次のような`@article`モデルオブジェクトがある場合：

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

次のフォーム：

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

出力結果は次のようになります：

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

ここで注目すべき点がいくつかあります：

* フォームの`action`は、`@article`に適切な値が自動的に埋められます。
* フォームのフィールドは、`@article`から対応する値で自動的に埋められます。
* フォームのフィールド名は`article[...]`でスコープされます。これにより、`params[:article]`はこれらのフィールドの値を含むハッシュになります。パラメータの命名規則の詳細については、このガイドの[Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions)章を参照してください。
* 送信ボタンには適切なテキスト値が自動的に設定されます。

ヒント：通常、入力フィールドはモデルの属性と同じになります。ただし、必ずしもそうである必要はありません！必要な他の情報がある場合は、属性と同様にフォームに含め、`params[:article][:my_nifty_non_attribute_input]`を介してアクセスできます。

#### `fields_for`ヘルパー

[`fields_for`][]ヘルパーは、`<form>`タグをレンダリングせずに同様のバインディングを作成します。これを使用して、同じフォーム内で追加のモデルオブジェクトのフィールドをレンダリングすることができます。たとえば、`Person`モデルに関連する`ContactDetail`モデルがある場合、次のようにして両方のための単一のフォームを作成できます：

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

これにより、次の出力が生成されます：

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

`fields_for`によって生成されるオブジェクトは、`form_with`によって生成されるフォームビルダーと同様のものです。


### レコードの識別に依存する

Articleモデルはアプリケーションのユーザーに直接利用されるため、Railsでの開発のベストプラクティスに従って、**リソース**として宣言する必要があります：

```ruby
resources :articles
```

ヒント：リソースを宣言すると、いくつかの副作用が発生します。リソースの設定と使用方法については、[Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default)ガイドを参照してください。

RESTfulリソースを扱う場合、`form_with`への呼び出しは、**レコードの識別**に依存すると、かなり簡単になります。要するに、モデルのインスタンスを渡すだけで、Railsがモデル名とその他の情報を自動的に解決してくれます。次の例の長いスタイルと短いスタイルは、同じ結果をもたらします：

```ruby
## 新しい記事を作成する
# 長いスタイル：
form_with(model: @article, url: articles_path)
# 短いスタイル：
form_with(model: @article)

## 既存の記事を編集する
# 長いスタイル：
form_with(model: @article, url: article_path(@article), method: "patch")
# 短いスタイル：
form_with(model: @article)
```

短いスタイルの`form_with`呼び出しは、レコードが新しいか既存のかに関係なく、便利に同じです。レコードの識別は、`record.persisted?`を使ってレコードが新しいかどうかを判断します。また、適切なパスを選択し、オブジェクトのクラスに基づいて名前を選択します。
もし[singular resource](routing.html#singular-resources)を持っている場合、`form_with`で動作させるために`resource`と`resolve`を呼び出す必要があります。

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

警告: モデルにSTI（単一テーブル継承）を使用している場合、親クラスのみがリソースとして宣言されている場合、サブクラスのレコード識別には依存できません。明示的に`:url`と`:scope`（モデル名）を指定する必要があります。

#### 名前空間の扱い

名前空間のルートを作成した場合、`form_with`には便利なショートカットがあります。アプリケーションにadmin名前空間がある場合、

```ruby
form_with model: [:admin, @article]
```

は、admin名前空間内の`ArticlesController`にフォームを作成します（更新の場合は`admin_article_path(@article)`に送信します）。名前空間のレベルが複数ある場合、構文は似ています。

```ruby
form_with model: [:admin, :management, @article]
```

Railsのルーティングシステムと関連する規則についての詳細は、[Rails Routing from the Outside In](routing.html)ガイドを参照してください。

### PATCH、PUT、またはDELETEメソッドを使用したフォームはどのように動作しますか？

Railsフレームワークは、アプリケーションのRESTfulな設計を推奨しているため、フォームの送信には「PATCH」、「PUT」、「DELETE」のリクエストを頻繁に行うことになります（「GET」と「POST」以外のメソッドも含まれます）。ただし、ほとんどのブラウザは、フォームの送信に関して「GET」と「POST」以外のメソッドをサポートしていません。

Railsは、`"_method"`という名前の非表示の入力を使用して、他のメソッドをPOSTでエミュレートすることで、この問題を解決します。この入力は、指定されたメソッドを反映するように設定されます。

```ruby
form_with(url: search_path, method: "patch")
```

出力:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

POSTされたデータを解析する際、Railsは特別な`_method`パラメータを考慮に入れ、それに内部で指定されたHTTPメソッド（この例では「PATCH」）として動作します。

フォームをレンダリングする際、送信ボタンは`formmethod:`キーワードを使用して宣言された`method`属性を上書きすることができます。

```erb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

`<form>`要素と同様に、ほとんどのブラウザは、[formmethod][]で宣言されたフォームメソッドを上書きすることをサポートしていません。

Railsは、[formmethod][]、[value][button-value]、および[name][button-name]属性の組み合わせによって、POSTを介して他のメソッドをエミュレートすることで、この問題を解決します。

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


簡単なセレクトボックスの作成
-----------------------------

HTMLのセレクトボックスは、選択肢ごとに1つの`<option>`要素を含む多くのマークアップが必要です。そのため、Railsではこの手間を減らすためのヘルパーメソッドを提供しています。

例えば、ユーザーが選択するための都市のリストがあるとします。[`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select)ヘルパーを次のように使用できます。

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

出力:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

また、ラベルと異なる`<option>`の値を指定することもできます。

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

出力:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

このようにすることで、ユーザーは完全な都市名を表示しますが、`params[:city]`は「BE」、「CHI」、「MD」のいずれかになります。

最後に、`selected:`引数を使用してセレクトボックスのデフォルトの選択肢を指定することができます。

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

出力:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### オプショングループ

場合によっては、関連するオプションをグループ化してユーザーエクスペリエンスを向上させたい場合があります。`select`に`Hash`（または比較可能な`Array`）を渡すことで、それを行うことができます。
```erb
<%= form.select :city,
      {
        "ヨーロッパ" => [ ["ベルリン", "BE"], ["マドリード", "MD"] ],
        "北アメリカ" => [ ["シカゴ", "CHI"] ],
      },
      selected: "CHI" %>
```

出力:

```html
<select name="city" id="city">
  <optgroup label="ヨーロッパ">
    <option value="BE">ベルリン</option>
    <option value="MD">マドリード</option>
  </optgroup>
  <optgroup label="北アメリカ">
    <option value="CHI" selected="selected">シカゴ</option>
  </optgroup>
</select>
```

### セレクトボックスとモデルオブジェクト

他のフォームコントロールと同様に、セレクトボックスはモデル属性にバインドすることができます。例えば、以下のような`@person`モデルオブジェクトがある場合:

```ruby
@person = Person.new(city: "MD")
```

次のフォーム:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["ベルリン", "BE"], ["シカゴ", "CHI"], ["マドリード", "MD"]] %>
<% end %>
```

以下のようなセレクトボックスを出力します:

```html
<select name="person[city]" id="person_city">
  <option value="BE">ベルリン</option>
  <option value="CHI">シカゴ</option>
  <option value="MD" selected="selected">マドリード</option>
</select>
```

適切なオプションが自動的に`selected="selected"`とマークされていることに注意してください。このセレクトボックスはモデルにバインドされているため、`:selected`引数を指定する必要はありませんでした！

### タイムゾーンと国のセレクト

Railsでタイムゾーンのサポートを活用するには、ユーザーにどのタイムゾーンにいるか尋ねる必要があります。これには、事前定義された[`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)オブジェクトのリストからセレクトオプションを生成する必要がありますが、既にこれをラップしている[`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select)ヘルパーを使用することができます:

```erb
<%= form.time_zone_select :time_zone %>
```

Railsには国を選択するための`country_select`ヘルパーがありましたが、これは[country_selectプラグイン](https://github.com/stefanpenner/country_select)に抽出されました。

日付と時間のフォームヘルパーの使用
--------------------------------

HTML5の日付と時間の入力を使用したくない場合、Railsはプレーンなセレクトボックスをレンダリングする代替の日付と時間のフォームヘルパーを提供しています。これらのヘルパーは、各時間要素（年、月、日など）ごとにセレクトボックスをレンダリングします。例えば、以下のような`@person`モデルオブジェクトがある場合:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

次のフォーム:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

以下のようなセレクトボックスを出力します:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">1月</option>
  <option value="2">2月</option>
  <option value="3">3月</option>
  <option value="4">4月</option>
  <option value="5">5月</option>
  <option value="6">6月</option>
  <option value="7">7月</option>
  <option value="8">8月</option>
  <option value="9">9月</option>
  <option value="10">10月</option>
  <option value="11">11月</option>
  <option value="12" selected="selected">12月</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

フォームが送信されると、`params`ハッシュには完全な日付を含む単一の値はありません。代わりに、`"birth_date(1i)"`のような特殊な名前の複数の値が存在します。Active Recordは、これらの特殊な名前の値をモデル属性の宣言されたタイプに基づいて、完全な日付または時間に組み立てる方法を知っています。そのため、このフォームが完全な日付を表す単一のフィールドを使用している場合と同様に、`params[:person]`を`Person.new`や`Person#update`に渡すことができます。

[`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select)ヘルパーに加えて、Railsは[`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select)と[`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select)も提供しています。

### 個々の時間要素のためのセレクトボックス

Railsは、個々の時間要素のためのセレクトボックスをレンダリングするためのヘルパーも提供しています: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute), [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second)です。これらのヘルパーは「ベア」メソッドであり、フォームビルダーのインスタンスでは呼び出されません。例えば:

```erb
<%= select_year 1999, prefix: "party" %>
```

以下のようなセレクトボックスを出力します:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

これらのヘルパーの各々について、デフォルト値として数値の代わりに日付や時間オブジェクトを指定することもでき、適切な時間要素が抽出されて使用されます。

任意のオブジェクトのコレクションからの選択肢
----------------------------------------------

時々、任意のオブジェクトのコレクションから選択肢のセットを生成したいことがあります。例えば、`City`モデルと対応する`belongs_to :city`関連付けがある場合：

```ruby
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```

```ruby
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

その後、次のフォームでデータベースから都市を選択できるようにすることができます：

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

注意：`belongs_to`関連付けのフィールドをレンダリングする場合、関連付け自体の名前ではなく、外部キーの名前（上記の例では`city_id`）を指定する必要があります。

ただし、Railsには、コレクションから選択肢を明示的に反復処理することなく生成するためのヘルパーが用意されています。これらのヘルパーは、コレクション内の各オブジェクトに指定されたメソッドを呼び出して、各選択肢の値とテキストラベルを決定します。

### `collection_select`ヘルパー

セレクトボックスを生成するには、[`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select)を使用できます：

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

出力：

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

注意：`collection_select`では、最初に値のメソッド（上記の例では`:id`）を指定し、次にテキストラベルのメソッド（上記の例では`:name`）を指定します。これは、`select`ヘルパーの選択肢を指定する際の順序とは逆です。

### `collection_radio_buttons`ヘルパー

ラジオボタンのセットを生成するには、[`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons)を使用できます：

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

出力：

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```

### `collection_check_boxes`ヘルパー

チェックボックスのセットを生成するには、[`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes)を使用できます。例えば、`has_and_belongs_to_many`関連付けをサポートするために使用できます：

```erb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

出力：

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```

ファイルのアップロード
---------------

一般的なタスクとして、人物の写真やデータを処理するためのCSVファイルなど、ある種のファイルをアップロードすることがあります。ファイルのアップロードフィールドは、[`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field)ヘルパーを使用してレンダリングできます。

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

ファイルのアップロードに関して最も重要なことは、レンダリングされるフォームの`enctype`属性を「multipart/form-data」に設定する必要があることです。これは、`form_with`内で`file_field`を使用すると自動的に行われます。また、属性を手動で設定することもできます：

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

`form_with`の規則に従って、上記の2つのフォームのフィールド名も異なることに注意してください。つまり、最初のフォームのフィールド名は`person[picture]`（`params[:person][:picture]`でアクセス可能）になり、2番目のフォームのフィールド名は単に`picture`（`params[:picture]`でアクセス可能）になります。

### アップロードされるもの

`params`ハッシュ内のオブジェクトは[`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html)のインスタンスです。次のスニペットは、アップロードされたファイルを元のファイルと同じ名前で`#{Rails.root}/public/uploads`に保存します。

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

ファイルがアップロードされた後、ディスク、Amazon S3などにファイルを保存する場所、モデルとの関連付け、画像ファイルのリサイズ、サムネイルの生成など、さまざまなタスクがあります。これらのタスクをサポートするために、[Active Storage](active_storage_overview.html)が設計されています。
フォームビルダのカスタマイズ
-------------------------

`form_with`と`fields_for`によって生成されるオブジェクトは[`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html)のインスタンスです。フォームビルダは、単一のオブジェクトのフォーム要素を表示する概念をカプセル化しています。通常の方法でフォームのヘルパーを作成することもできますが、`ActionView::Helpers::FormBuilder`のサブクラスを作成し、そこにヘルパーを追加することもできます。例えば、

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

は、次のように置き換えることができます。

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

以下のような`LabellingFormBuilder`クラスを定義することで可能です。

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

これを頻繁に再利用する場合は、`builder: LabellingFormBuilder`オプションを自動的に適用する`labeled_form_with`ヘルパーを定義することができます。

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options[:builder] = LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

また、使用するフォームビルダによって次のような動作が決まります。

```erb
<%= render partial: f %>
```

もし`f`が`ActionView::Helpers::FormBuilder`のインスタンスであれば、これは`form`パーシャルをレンダリングし、パーシャルのオブジェクトをフォームビルダに設定します。フォームビルダが`LabellingFormBuilder`クラスであれば、`labelling_form`パーシャルが代わりにレンダリングされます。

パラメータの命名規則の理解
--------------------------

フォームからの値は、`params`ハッシュのトップレベルにあるか、別のハッシュにネストされることがあります。例えば、Personモデルの標準的な`create`アクションでは、`params[:person]`は通常、作成するPersonのすべての属性のハッシュです。`params`ハッシュには配列、ハッシュの配列などが含まれることもあります。

基本的にHTMLフォームは、構造化されたデータについては何も知りません。生成されるのは名前と値のペアであり、ペアは単なる文字列です。アプリケーションで見る配列やハッシュは、Railsが使用するパラメータの命名規則の結果です。

### 基本的な構造

基本的な構造は配列とハッシュの2つです。ハッシュは`params`で値にアクセスするために使用される構文を反映しています。例えば、フォームに次のような要素が含まれている場合、

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

`params`ハッシュには次のようになります。

```ruby
{ 'person' => { 'name' => 'Henry' } }
```

そして、コントローラで`params[:person][:name]`を使用すると、送信された値を取得することができます。

ハッシュは必要なだけネストすることができます。例えば、

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

とすると、`params`ハッシュは次のようになります。

```ruby
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

通常、Railsは重複するパラメータ名を無視します。パラメータ名が空の角括弧`[]`で終わる場合、それらは配列に蓄積されます。ユーザーが複数の電話番号を入力できるようにしたい場合、次のようにフォームに配置することができます。

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

これにより、`params[:person][:phone_number]`は入力された電話番号を含む配列になります。

### 組み合わせる

これらの2つの概念を組み合わせることができます。ハッシュの要素の1つは、前の例のような配列である場合もあります。また、ハッシュの配列を持つこともできます。例えば、フォームでは次のように繰り返しアドレスを作成できるようにすることができます。

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

これにより、`params[:person][:addresses]`は、`line1`、`line2`、`city`をキーとするハッシュの配列になります。

ただし、制限があります。ハッシュは任意のレベルでネストできますが、「配列のレベル」は1つだけ許可されます。通常、配列はハッシュに置き換えることができます。例えば、モデルオブジェクトの配列の代わりに、id、配列のインデックス、または他のパラメータをキーとするモデルオブジェクトのハッシュを持つことができます。
警告：配列パラメータは`check_box`ヘルパーと互換性がありません。HTML仕様によると、チェックされていないチェックボックスは値を送信しません。しかし、チェックボックスが常に値を送信するのが便利な場合があります。`check_box`ヘルパーは、同じ名前の補助的な隠し入力を作成することでこれを偽装します。チェックボックスがチェックされていない場合、隠し入力のみが送信され、チェックされている場合は両方が送信されますが、チェックボックスによって送信される値が優先されます。

### `fields_for`ヘルパーの`:index`オプション

例えば、個人の各住所に対してフィールドのセットを含むフォームをレンダリングしたいとします。[`fields_for`][]ヘルパーとその`:index`オプションを使用すると、次のように補助できます：

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

IDが23と45の2つの住所を持つ場合、上記のフォームは次のような出力を生成します：

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

これにより、次のような`params`ハッシュが生成されます：

```ruby
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

フォームのすべての入力は、`person_form`フォームビルダーで`fields_for`を呼び出したため、`"person"`ハッシュにマップされます。また、`index: address.id`を指定することで、各都市の入力の`name`属性を`person[address][#{address.id}][city]`としてレンダリングしました。そのため、`params`ハッシュを処理する際に変更する必要があるAddressレコードを特定できます。

`index`オプションには他の重要な数値や文字列を渡すこともできます。さらに、配列パラメータを生成するには`nil`を渡すこともできます。

より複雑なネストを作成するには、入力名の先頭部分を明示的に指定することもできます。例えば：

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

次のような入力を作成します：

```html
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

`text_field`などのヘルパーに直接`index`オプションを渡すこともできますが、個々の入力フィールドではなくフォームビルダーレベルで指定する方が繰り返しを減らせる場合が多いです。

一般的に、最終的な入力名は、`fields_for` / `form_with`に指定された名前、`index`オプションの値、および属性の名前の連結になります。

最後に、`:index`にIDを指定する代わりに（例：`index: address.id`）、指定された名前に`"[]"`を追加するショートカットも使用できます。例えば：

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

元の例とまったく同じ出力が生成されます。

外部リソースへのフォーム
---------------------------

Railsのフォームヘルパーは、外部リソースにデータを投稿するためのフォームを作成するためにも使用できます。ただし、リソースに`authenticity_token`を設定する必要がある場合があります。これは、`form_with`オプションに`authenticity_token: 'your_external_token'`パラメータを渡すことで行うことができます：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  フォームの内容
<% end %>
```

支払いゲートウェイなどの外部リソースにデータを送信する場合、フォームで使用できるフィールドは外部APIによって制限される場合があり、`authenticity_token`を生成することは望ましくない場合があります。トークンを送信しないようにするには、`:authenticity_token`オプションに`false`を渡すだけです：

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  フォームの内容
<% end %>
```
複雑なフォームの作成
----------------------

多くのアプリケーションは、単一のオブジェクトのフォーム編集を超えて成長します。たとえば、`Person`を作成する際には、ユーザーに複数の住所レコード（自宅、職場など）を同じフォームで作成させたい場合があります。その後、その人物を編集する際には、必要に応じて住所を追加、削除、または修正できるようにする必要があります。

### モデルの設定

Active Recordは、[`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for)メソッドを介してモデルレベルのサポートを提供します。

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

これにより、`Person`に`addresses_attributes=`メソッドが作成され、住所を作成、更新、（オプションで）削除できるようになります。

### ネストされたフォーム

次のフォームでは、ユーザーが`Person`と関連する住所を作成できます。

```html+erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

関連オブジェクトがネストされた属性を受け入れる場合、`fields_for`は関連の要素ごとにそのブロックを一度だけレンダリングします。特に、人物に住所がない場合は何もレンダリングされません。一般的なパターンは、コントローラーが少なくとも1つのフィールドセットをユーザーに表示するために、1つ以上の空の子を作成することです。以下の例では、新しい人物のフォームに2つの住所フィールドセットがレンダリングされます。

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

`fields_for`はフォームビルダーを生成します。パラメータの名前は、`accepts_nested_attributes_for`が期待するものになります。たとえば、2つの住所を持つユーザーを作成する場合、送信されるパラメータは次のようになります。

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

`:addresses_attributes`ハッシュのキーの実際の値は重要ではありませんが、それらは整数の文字列である必要があり、各住所ごとに異なる値である必要があります。

関連オブジェクトが既に保存されている場合、`fields_for`は保存されたレコードの`id`を持つ非表示の入力を自動生成します。これを無効にするには、`fields_for`に`include_id: false`を渡します。

### コントローラー

通常通り、モデルに渡す前にコントローラーで[許可されたパラメータを宣言](action_controller_overview.html#strong-parameters)する必要があります。

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### オブジェクトの削除

`accepts_nested_attributes_for`に`allow_destroy: true`を渡すことで、関連オブジェクトの削除を許可できます。

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

オブジェクトの属性ハッシュに`_destroy`キーが含まれ、その値が`true`（たとえば、1、'1'、true、または'true'）に評価される場合、オブジェクトは削除されます。このフォームでは、ユーザーは住所を削除できます。

```erb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

コントローラーの許可されたパラメータも更新して、`_destroy`フィールドを含めるように忘れないでください。

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### 空のレコードの防止

ユーザーが入力していないフィールドセットを無視することは、しばしば便利です。これは、`accepts_nested_attributes_for`に`:reject_if`プロックを渡すことで制御できます。このプロックは、フォームによって送信された属性のハッシュごとに呼び出されます。プロックが`true`を返す場合、Active Recordはそのハッシュの関連オブジェクトを構築しません。以下の例では、`kind`属性が設定されている場合にのみ住所を構築しようとします。
```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

便利のために、代わりにシンボル `:all_blank` を渡すこともできます。これにより、すべての属性が空であるレコード（`_destroy` の値を除く）は拒否されるプロックが作成されます。

### フィールドの動的追加

あらかじめ複数のフィールドセットをレンダリングする代わりに、ユーザーが「新しい住所を追加」ボタンをクリックしたときにのみ追加することもできます。Rails はこれに対して組み込みのサポートを提供していません。新しいフィールドセットを生成する際には、関連する配列のキーが一意であることを確認する必要があります - 現在の JavaScript 日付（エポックからのミリ秒）は一般的な選択肢です。

フォームビルダーのコンテキスト外でタグヘルパーを使用する
--------------------------------------------------------

フォームビルダーのコンテキスト外でフォームフィールドをレンダリングする必要がある場合、Rails は一般的なフォーム要素のためのタグヘルパーを提供しています。たとえば、[`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag)：

```erb
<%= check_box_tag "accept" %>
```

出力：

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

一般的に、これらのヘルパーは、フォームビルダーの対応するものと同じ名前に `_tag` 接尾辞が付いたものです。完全なリストについては、[`FormTagHelper` API ドキュメント](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)を参照してください。

`form_tag` と `form_for` の使用
-------------------------------

Rails 5.1 で `form_with` が導入される前は、その機能は [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) と [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for) に分割されていました。いずれも現在はソフト非推奨となっています。使用方法についてのドキュメントは、[このガイドの古いバージョン](https://guides.rubyonrails.org/v5.2/form_helpers.html)で見つけることができます。
[`fields_for`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-formmethod
[button-name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-name
[button-value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#attr-value
