**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Action Textの概要
====================

このガイドでは、リッチテキストコンテンツの処理を始めるために必要なすべての情報を提供します。

このガイドを読み終えると、以下のことがわかります。

* Action Textの設定方法
* リッチテキストコンテンツの処理方法
* リッチテキストコンテンツと添付ファイルのスタイリング方法

--------------------------------------------------------------------------------

Action Textとは？
--------------------

Action Textは、リッチテキストコンテンツと編集をRailsにもたらします。それには、フォーマットからリンク、引用、リスト、埋め込み画像やギャラリーまで、すべてを処理する[Trixエディタ](https://trix-editor.org)が含まれています。Trixエディタによって生成されるリッチテキストコンテンツは、既存のActive Recordモデルと関連付けられた独自のRichTextモデルに保存されます。埋め込み画像（またはその他の添付ファイル）は、Active Storageを使用して自動的に保存され、含まれるRichTextモデルと関連付けられます。

## Trixと他のリッチテキストエディタの比較

ほとんどのWYSIWYGエディタは、HTMLの`contenteditable`と`execCommand`のAPIをラップしたもので、これはMicrosoftがInternet Explorer 5.5でウェブページのライブ編集をサポートするために設計したものであり、後に他のブラウザによって[逆にエンジニアリングされ](https://blog.whatwg.org/the-road-to-html-5-contenteditable#history)、コピーされました。

これらのAPIは完全に指定されたり文書化されたりしなかったため、WYSIWYG HTMLエディタは非常に広範なスコープを持っており、各ブラウザの実装には独自のバグやクセがあります。そのため、JavaScript開発者はこれらの不一致を解決する必要があります。

Trixは、contenteditableをI/Oデバイスとして扱うことで、これらの不一致を回避しています。入力がエディタに届くと、Trixはその入力を内部ドキュメントモデル上の編集操作に変換し、そのドキュメントをエディタに再レンダリングします。これにより、Trixは各キーストロークの後に何が起こるかを完全に制御し、execCommandを使用する必要がなくなります。

## インストール

`bin/rails action_text:install`を実行して、Yarnパッケージを追加し、必要なマイグレーションをコピーします。また、埋め込み画像やその他の添付ファイルにActive Storageを設定する必要があります。[Active Storageの概要](active_storage_overview.html)ガイドを参照してください。

注意：Action Textは、`action_text_rich_texts`テーブルとの多態関連を使用しているため、リッチテキスト属性を持つすべてのモデルで共有できます。Action Textコンテンツを使用するモデルが識別子としてUUID値を使用している場合、Action Text属性を使用するすべてのモデルも一意の識別子としてUUID値を使用する必要があります。Action Textの生成されたマイグレーションも、`:record` `references`行に対して`type: :uuid`を指定するように更新する必要があります。

インストールが完了したら、Railsアプリには以下の変更が加えられます。

1. JavaScriptのエントリーポイントで`trix`と`@rails/actiontext`の両方を要求する必要があります。

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. `trix`のスタイルシートは、`application.css`ファイルに含まれるAction Textのスタイルと一緒に含まれます。

## リッチテキストコンテンツの作成

既存のモデルにリッチテキストフィールドを追加します。

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

または、次のコマンドを使用して新しいモデルを作成しながらリッチテキストフィールドを追加します。

```bash
$ bin/rails generate model Message content:rich_text
```

注意：`messages`テーブルに`content`フィールドを追加する必要はありません。

その後、モデルのフォームでこのフィールドを参照するために[`rich_text_area`]を使用します。

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

最後に、ページ上でサニタイズされたリッチテキストを表示します。

```erb
<%= @message.content %>
```

注意：`content`フィールド内に添付されたリソースがある場合、マシンに*libvips/libvips42*パッケージがインストールされていない限り、正しく表示されない場合があります。インストール方法については、[インストールドキュメント](https://www.libvips.org/install.html)を参照してください。

リッチテキストコンテンツを受け入れるために必要なのは、参照される属性を許可するだけです。

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## リッチテキストコンテンツのレンダリング

デフォルトでは、Action Textはリッチテキストコンテンツを`.trix-content`クラスの要素内にレンダリングします。

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

このクラスを持つ要素とAction Textエディタは、[`trix`のスタイルシート](https://unpkg.com/trix/dist/trix.css)によってスタイルが適用されます。代わりに独自のスタイルを提供する場合は、インストーラによって作成された`app/assets/stylesheets/actiontext.css`スタイルシートから`require trix`の行を削除してください。

リッチテキストコンテンツの周りにレンダリングされるHTMLをカスタマイズするには、インストーラによって作成された`app/views/layouts/action_text/contents/_content.html.erb`レイアウトを編集します。

埋め込み画像やその他の添付ファイル（blobとも呼ばれます）のためにレンダリングされるHTMLをカスタマイズするには、インストーラによって作成された`app/views/active_storage/blobs/_blob.html.erb`テンプレートを編集します。
### 添付ファイルのレンダリング

Active Storageを介してアップロードされた添付ファイルに加えて、Action Textは[署名付きGlobalID](https://github.com/rails/globalid#signed-global-ids)で解決できるものを埋め込むことができます。

Action Textは埋め込まれた`<action-text-attachment>`要素を、その`sgid`属性をインスタンスに解決することでレンダリングします。解決されたインスタンスは、[`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)に渡されます。その結果のHTMLは、`<action-text-attachment>`要素の子孫として埋め込まれます。

例えば、`User`モデルを考えてみましょう：

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

次に、`User`インスタンスの署名付きGlobalIDを参照する`<action-text-attachment>`要素を埋め込むリッチテキストのコンテンツを考えてみましょう：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Textは"BAh7CEkiCG…"という文字列を使用して`User`インスタンスを解決します。次に、アプリケーションの`users/user`パーシャルを考えてみましょう：

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Action Textによってレンダリングされた結果のHTMLは、次のようになります：

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

異なるパーシャルをレンダリングするには、`User#to_attachable_partial_path`を定義します：

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

そして、そのパーシャルを宣言します。`User`インスタンスは`user`パーシャルローカル変数として利用できます：

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

`User`インスタンスを解決できない場合（例えば、レコードが削除された場合）、デフォルトのフォールバックパーシャルがレンダリングされます。

Railsは、添付ファイルが見つからない場合のためのグローバルなパーシャルを提供しています。このパーシャルは、アプリケーションの`views/action_text/attachables/missing_attachable`にインストールされ、異なるHTMLをレンダリングしたい場合に変更することができます。

異なる見つからない添付ファイルのパーシャルをレンダリングするには、クラスレベルの`to_missing_attachable_partial_path`メソッドを定義します：

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

そして、そのパーシャルを宣言します。

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>削除されたユーザー</span>
```

Action Textの`<action-text-attachment>`要素のレンダリングと統合するためには、クラスは次のようにする必要があります：

* `ActionText::Attachable`モジュールを含める
* [`GlobalID::Identification` concern][global-id]を介して利用可能な`#to_sgid(**options)`を実装する
* （オプション）`#to_attachable_partial_path`を宣言する
* （オプション）欠落したレコードを処理するためのクラスレベルの`#to_missing_attachable_partial_path`メソッドを宣言する

デフォルトでは、すべての`ActiveRecord::Base`の子孫は[`GlobalID::Identification` concern][global-id]をミックスインしており、したがって`ActionText::Attachable`と互換性があります。


## N+1クエリを回避する

リッチテキストのフィールドが`content`という名前の場合、依存する`ActionText::RichText`モデルを事前にロードしたい場合は、次のような名前付きスコープを使用できます：

```ruby
Message.all.with_rich_text_content # 添付ファイルなしで本文を事前にロードします。
Message.all.with_rich_text_content_and_embeds # 本文と添付ファイルの両方を事前にロードします。
```

## API / バックエンド開発

1. バックエンドAPI（例：JSONを使用）は、`ActiveStorage::Blob`を作成し、その`attachable_sgid`を返す別のエンドポイントが必要です：

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. その`attachable_sgid`を取得し、フロントエンドに対して`<action-text-attachment>`タグを使用してリッチテキストのコンテンツに挿入するように依頼します：

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

これはBasecampに基づいていますので、まだお探しの情報が見つからない場合は、この[Basecampドキュメント](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md)をご確認ください。
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
