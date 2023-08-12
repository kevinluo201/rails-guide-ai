**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Ruby on Railsのアップグレード
=======================

このガイドでは、アプリケーションを新しいバージョンのRuby on Railsにアップグレードする際に必要な手順を提供します。これらの手順は個別のリリースガイドでも利用できます。

--------------------------------------------------------------------------------

一般的なアドバイス
--------------

既存のアプリケーションをアップグレードする前に、アップグレードする理由があることを確認してください。新機能の必要性、古いコードのサポートが難しくなっていること、利用可能な時間とスキルなど、いくつかの要素をバランスさせる必要があります。

### テストカバレッジ

アップグレード後もアプリケーションが正常に動作することを確認するためには、プロセスを開始する前に十分なテストカバレッジを持っていることが最善です。アプリケーションの大部分を自動化されたテストでカバーしていない場合、変更されたすべてのパーツを手動でテストする必要があります。Railsのアップグレードの場合、アプリケーションのすべての機能を意味します。アップグレードを開始する前に、テストカバレッジが十分であることを確認してください。

### Rubyのバージョン

Railsは通常、リリースされた最新のRubyバージョンに近いバージョンでリリースされます。

* Rails 7はRuby 2.7.0以上が必要です。
* Rails 6はRuby 2.5.0以上が必要です。
* Rails 5はRuby 2.2.2以上が必要です。

RubyとRailsを別々にアップグレードすることをお勧めします。まず、できるだけ最新のRubyにアップグレードし、その後にRailsをアップグレードしてください。

### アップグレードのプロセス

Railsのバージョンを変更する際には、適切に利用できるようにするために、一度に1つのマイナーバージョンずつゆっくりと移行することが最善です。Railsのバージョン番号はMajor.Minor.Patchの形式です。MajorとMinorのバージョンはパブリックAPIに変更を加えることができるため、アプリケーションでエラーが発生する可能性があります。Patchバージョンにはバグ修正のみが含まれ、パブリックAPIは変更されません。

プロセスは以下のように進めるべきです：

1. テストを作成し、パスすることを確認します。
2. 現在のバージョンの直後の最新のパッチバージョンに移動します。
3. テストと非推奨の機能を修正します。
4. 次のマイナーバージョンの最新のパッチバージョンに移動します。

このプロセスを目標のRailsバージョンに到達するまで繰り返します。

#### バージョン間の移動

バージョン間を移動するには：

1. `Gemfile`でRailsのバージョン番号を変更し、`bundle update`を実行します。
2. `package.json`でRailsのJavaScriptパッケージのバージョンを変更し、Webpackerを使用している場合は`yarn install`を実行します。
3. [アップデートタスク](#the-update-task)を実行します。
4. テストを実行します。

リリースされたすべてのRailsのgemのリストは[こちら](https://rubygems.org/gems/rails/versions)で確認できます。

### アップデートタスク

Railsは`rails app:update`コマンドを提供しています。`Gemfile`でRailsのバージョンを更新した後、このコマンドを実行します。
これにより、新しいファイルの作成や古いファイルの変更がインタラクティブなセッションで行われます。

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

予期しない変更があったかどうかを確認するために、差分を確認することを忘れないでください。

### フレームワークのデフォルトを設定する

新しいRailsバージョンでは、以前のバージョンとは異なるデフォルトの設定がある場合があります。ただし、上記の手順に従っていれば、アプリケーションはまだ*前の*Railsバージョンのデフォルトの設定で実行されます。これは、`config/application.rb`の`config.load_defaults`の値がまだ変更されていないためです。

新しいデフォルトを段階的に有効にするために、アップデートタスクは`config/initializers/new_framework_defaults_X.Y.rb`というファイルを作成しました（ファイル名には望ましいRailsバージョンが含まれます）。このファイルで新しいデフォルトの設定をコメント解除することで、段階的に設定を有効にすることができます。アプリケーションが新しいデフォルトで実行できる準備が整ったら、このファイルを削除し、`config.load_defaults`の値を切り替えます。

Rails 7.0からRails 7.1へのアップグレード
-------------------------------------

Rails 7.1への変更点の詳細については、[リリースノート](7_1_release_notes.html)を参照してください。

### 自動読み込みパスはロードパスに含まれなくなりました

Rails 7.1以降、自動読み込みパスは`$LOAD_PATH`に追加されなくなります。
これは、手動で`require`を呼び出してそれらをロードすることはできなくなることを意味します。代わりにクラスやモジュールを参照することができます。

`bootsnap`を使用していないアプリでは、`$LOAD_PATH`のサイズを減らすことで`require`呼び出しを高速化し、他のアプリでは`bootsnap`キャッシュのサイズを減らすことができます。
### `ActiveStorage::BaseController` はストリーミングの関心事を含まなくなりました

`ActiveStorage::BaseController` を継承するアプリケーションコントローラーで、カスタムファイルサービスのロジックを実装するためにストリーミングを使用している場合、`ActiveStorage::Streaming` モジュールを明示的に含める必要があります。

### `MemCacheStore` と `RedisCacheStore` はデフォルトでコネクションプーリングを使用するようになりました

`activesupport` ジェムの依存関係として `connection_pool` ジェムが追加され、`MemCacheStore` と `RedisCacheStore` はデフォルトでコネクションプーリングを使用するようになりました。

コネクションプーリングを使用したくない場合は、キャッシュストアを設定する際に `:pool` オプションを `false` に設定してください。

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

詳細については、[Rails でのキャッシュ](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options)ガイドを参照してください。

### `SQLite3Adapter` は厳密な文字列モードで使用するように設定されました

厳密な文字列モードの使用により、二重引用符で囲まれた文字列リテラルが無効になります。

SQLite には二重引用符で囲まれた文字列リテラルに関するいくつかの特殊な動作があります。
まず、SQLite は二重引用符で囲まれた文字列を識別子として考えようとしますが、存在しない場合は文字列リテラルとして扱います。そのため、タイプミスが静かに見逃される可能性があります。たとえば、存在しない列にインデックスを作成することができます。
詳細については、[SQLite のドキュメント](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)を参照してください。

`SQLite3Adapter` を厳密なモードで使用したくない場合は、この動作を無効にすることができます。

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### `ActionMailer::Preview` の複数のプレビューパスをサポート

オプション `config.action_mailer.preview_path` は非推奨であり、`config.action_mailer.preview_paths` を使用するようになりました。この設定オプションにパスを追加すると、それらのパスがメーラープレビューの検索に使用されます。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` は、未定義の翻訳がある場合に常にエラーを発生させるようになりました。

以前はビューやコントローラーで呼び出された場合にのみエラーが発生していましたが、`I18n.t` に認識されないキーが指定された場合にいつでもエラーが発生するようになりました。

```ruby
# config.i18n.raise_on_missing_translations = true の場合

# ビューやコントローラー内で:
t("missing.key") # 7.0 ではエラーが発生しなかったが、7.1 ではエラーが発生する
I18n.t("missing.key") # 7.0 ではエラーが発生しなかったが、7.1 ではエラーが発生する

# どこでも:
I18n.t("missing.key") # 7.0 ではエラーが発生しなかったが、7.1 ではエラーが発生する
```

この動作を変更したくない場合は、`config.i18n.raise_on_missing_translations = false` に設定してください。

```ruby
# config.i18n.raise_on_missing_translations = false の場合

# ビューやコントローラー内で:
t("missing.key") # 7.0 ではエラーが発生しなかったし、7.1 でもエラーは発生しない
I18n.t("missing.key") # 7.0 ではエラーが発生しなかったし、7.1 でもエラーは発生しない

# どこでも:
I18n.t("missing.key") # 7.0 ではエラーが発生しなかったし、7.1 でもエラーは発生しない
```

または、`I18n.exception_handler` をカスタマイズすることもできます。
詳細については、[i18n ガイド](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers)を参照してください。

Rails 6.1 から Rails 7.0 へのアップグレード
-------------------------------------

Rails 7.0 への変更点の詳細については、[リリースノート](7_0_release_notes.html)を参照してください。

### `ActionView::Helpers::UrlHelper#button_to` の動作が変更されました

Rails 7.0 から、`button_to` は、永続化された Active Record オブジェクトを使用してボタンの URL を構築する場合に、`patch` HTTP メソッドを使用して `form` タグをレンダリングするようになりました。
現在の動作を維持するには、`method:` オプションを明示的に渡すことを検討してください。

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

または、URL を構築するためにヘルパーを使用する方法もあります。

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

アプリケーションが Spring を使用している場合、少なくともバージョン 3.0.0 にアップグレードする必要があります。そうしないと、次のエラーが発生します。

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

また、`config/environments/test.rb` で [`config.cache_classes`][] が `false` に設定されていることを確認してください。


### Sprockets はオプションの依存関係となりました

`rails` ジェムはもはや `sprockets-rails` に依存しません。アプリケーションが引き続き Sprockets を使用する必要がある場合は、Gemfile に `sprockets-rails` を追加してください。

```ruby
gem "sprockets-rails"
```

### アプリケーションは `zeitwerk` モードで実行する必要があります

まだ `classic` モードで実行されているアプリケーションは、`zeitwerk` モードに切り替える必要があります。詳細については、[Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html)ガイドを参照してください。

### `config.autoloader=` のセッターが削除されました

Rails 7 では、オートローディングモードを設定するための構成ポイントはありません。`config.autoloader=` は削除されました。何らかの理由で `:zeitwerk` に設定していた場合は、単に削除してください。

### `ActiveSupport::Dependencies` のプライベート API が削除されました

`ActiveSupport::Dependencies` のプライベート API が削除されました。これには `hook!`、`unhook!`、`depend_on`、`require_or_load`、`mechanism` などのメソッドが含まれます。

いくつかのハイライト:

* `ActiveSupport::Dependencies.constantize` や `ActiveSupport::Dependencies.safe_constantize` を使用していた場合は、それらを `String#constantize` や `String#safe_constantize` に変更してください。

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # これはもうできません
  "User".constantize # 👍
  ```

* `ActiveSupport::Dependencies.mechanism` の使用方法（リーダーやライター）は、`config.cache_classes` にアクセスすることで置き換える必要があります。

* オートローダーのアクティビティをトレースしたい場合は、`ActiveSupport::Dependencies.verbose=` は使用できなくなりました。代わりに、`config/application.rb` で `Rails.autoloaders.log!` を使用してください。
補助的な内部クラスやモジュールも削除されました。例えば、`ActiveSupport::Dependencies::Reference`、`ActiveSupport::Dependencies::Blamable`などです。

### 初期化時の自動読み込み

`to_prepare` ブロックの外で初期化時に自動読み込みされる定数を持つアプリケーションは、Rails 6.0 以降、これらの定数がアンロードされ、次の警告が発生します。

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

ログでこの警告がまだ表示される場合は、アプリケーションの起動時に自動読み込みに関するセクションを [自動読み込みガイド](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots) で確認してください。それ以外の場合、Rails 7 では `NameError` が発生します。

### `config.autoload_once_paths` の設定可能性

[`config.autoload_once_paths`][] は、`config/application.rb` で定義されたアプリケーションクラスの本体または `config/environments/*` の環境設定で設定できます。

同様に、エンジンはエンジンクラスの本体または環境の設定でそのコレクションを設定できます。

その後、コレクションは凍結され、それらのパスから自動読み込みできます。特に、初期化時にそこから自動読み込みできます。これらは `Rails.autoloaders.once` オートローダーによって管理され、リロードせずに自動読み込み/イーガーロードのみを行います。

環境設定が処理された後にこの設定を行い、`FrozenError` が発生している場合は、コードを移動してください。

### `ActionDispatch::Request#content_type` は、Content-Type ヘッダーをそのまま返すようになりました。

以前の `ActionDispatch::Request#content_type` の返り値には、charset 部分が含まれていませんでした。
この動作は、charset 部分を含む Content-Type ヘッダーが返されるように変更されました。

MIME タイプのみが必要な場合は、代わりに `ActionDispatch::Request#media_type` を使用してください。

変更前:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

変更後:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### キー生成器のダイジェストクラスの変更にはクッキーローテーターが必要です

キー生成器のデフォルトのダイジェストクラスが SHA1 から SHA256 に変更されます。
これには、Rails によって生成される暗号化されたメッセージ、つまり暗号化されたクッキーを含む、いくつかの影響があります。

古いダイジェストクラスを使用してメッセージを読み取るためには、ローテーターを登録する必要があります。これを行わないと、アップグレード中にユーザーのセッションが無効になる可能性があります。

以下は、暗号化されたクッキーと署名付きクッキーのためのローテーターの例です。

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### ActiveSupport::Digest のダイジェストクラスが SHA256 に変更されました

ActiveSupport::Digest のデフォルトのダイジェストクラスが SHA1 から SHA256 に変更されます。
これには、Etag などに影響を与えるキャッシュキーの変更が含まれます。
これらのキーを変更すると、キャッシュヒット率に影響を与える可能性があるため、新しいハッシュにアップグレードする際には注意してください。

### 新しい ActiveSupport::Cache シリアライゼーション形式

より高速でコンパクトなシリアライゼーション形式が導入されました。

これを有効にするには、`config.active_support.cache_format_version = 7.0` を設定する必要があります。

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

または単純に:

```ruby
# config/application.rb

config.load_defaults 7.0
```

ただし、Rails 6.1 アプリケーションはこの新しいシリアライゼーション形式を読み取ることができませんので、シームレスなアップグレードを確保するために、まず `config.active_support.cache_format_version = 6.1` で Rails 7.0 アップグレードをデプロイし、すべての Rails プロセスが更新された後に `config.active_support.cache_format_version = 7.0` を設定する必要があります。

Rails 7.0 は両方の形式を読み取ることができるため、アップグレード中にキャッシュが無効になることはありません。

### Active Storage のビデオプレビュー画像生成

ビデオのプレビュー画像生成には、より意味のあるプレビュー画像を生成するために、FFmpeg のシーンチェンジ検出が使用されるようになりました。以前はビデオの最初のフレームが使用されていたため、ビデオが黒からフェードインする場合に問題が発生していました。この変更には、FFmpeg v3.4+ が必要です。

### Active Storage のデフォルトのバリアントプロセッサが `:vips` に変更されました

新しいアプリケーションでは、画像の変換に ImageMagick の代わりに libvips が使用されます。これにより、バリアントの生成にかかる時間、CPU 使用率、メモリ使用量が削減され、画像を提供するために Active Storage に依存するアプリケーションの応答時間が改善されます。

`:mini_magick` オプションは非推奨ではないため、引き続き使用することができます。

既存のアプリケーションを libvips に移行するには、次のように設定します。
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

既存の画像変換コードを`image_processing`マクロに変更し、ImageMagickのオプションをlibvipsのオプションに置き換える必要があります。

#### resizeをresize_to_limitに置き換える

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

これを行わない場合、vipsに切り替えると次のエラーが表示されます: `no implicit conversion to float from string`。

#### クロップする際には配列を使用する

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

これを行わない場合、vipsに移行する際に次のエラーが表示されます: `unable to call crop: you supplied 2 arguments, but operation needs 5`。

#### クロップ値を制限する

クロッピングに関して、VipsはImageMagickよりも厳格です:

1. `x`および/または`y`が負の値の場合、クロップは行われません。例: `[-10, -10, 100, 100]`
2. 位置(`x`または`y`)とクロップの寸法(`width`、`height`)の合計が画像よりも大きい場合、クロップは行われません。例: 125x125の画像とクロップ`[50, 50, 100, 100]`

これを行わない場合、vipsに移行する際に次のエラーが表示されます: `extract_area: bad extract area`。

#### `resize_and_pad`で使用する背景色を調整する

Vipsは、ImageMagickとは異なり、`resize_and_pad`でデフォルトの背景色として黒を使用します。これを修正するには、`background`オプションを使用します:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### EXIFベースの回転を削除する

Vipsは、変換を行う際にEXIF値を使用して画像を自動的に回転します。もし、ImageMagickで回転を適用するためにユーザーがアップロードした写真の回転値を保存していた場合、それをやめる必要があります:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### monochromeをcolourspaceに置き換える

モノクロ画像を作成するために、Vipsは異なるオプションを使用します:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### 画像の圧縮にlibvipsのオプションを使用するよう切り替える

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### 本番環境へのデプロイ

Active Storageは、画像のURLに実行する必要のある変換のリストをエンコードします。アプリケーションがこれらのURLをキャッシュしている場合、新しいコードを本番環境にデプロイすると画像が壊れます。そのため、影響を受けるキャッシュキーを手動で無効化する必要があります。

例えば、ビューで次のようなコードがある場合:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

キャッシュを無効化するには、製品を更新するかキャッシュキーを変更します:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Active RecordスキーマダンプにRailsバージョンが含まれるようになりました

Rails 7.0では、一部のカラムタイプのデフォルト値が変更されました。6.1から7.0にアップグレードするアプリケーションが新しい7.0のデフォルトを使用して現在のスキーマをロードするのを避けるために、Railsはスキーマダンプにフレームワークのバージョンを含めるようになりました。

Rails 7.0で初めてスキーマをロードする前に、スキーマダンプにフレームワークのバージョンが含まれるようにするために`rails app:update`を実行してください。

スキーマファイルは次のようになります:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
注意：Rails 7.0でスキーマをダンプする初回は、カラム情報を含むなど、そのファイルに多くの変更が表示されます。新しいスキーマファイルの内容を確認し、リポジトリにコミットしてください。

Rails 6.0からRails 6.1へのアップグレード
-------------------------------------

Rails 6.1への変更の詳細については、[リリースノート](6_1_release_notes.html)を参照してください。

### `Rails.application.config_for`の戻り値は、もはや文字列キーでのアクセスをサポートしていません。

次のような設定ファイルがある場合：

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

これは以前は文字列キーで値にアクセスできるハッシュを返していましたが、それは6.0で非推奨となり、もはや機能しません。

まだ文字列キーで値にアクセスしたい場合は、`config_for`の戻り値に対して`with_indifferent_access`を呼び出すことができます。例：

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### `respond_to#any`を使用した場合のレスポンスのContent-Type

レスポンスで返されるContent-Typeヘッダは、Rails 6.0とは異なる場合があります。具体的には、アプリケーションが`respond_to { |format| format.any }`を使用している場合です。Content-Typeは、リクエストのフォーマットではなく、指定されたブロックに基づいています。

例：

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

以前の動作では、`text/csv`のContent-Typeが返されていましたが、これはJSONレスポンスがレンダリングされているため正確ではありません。現在の動作では、`application/json`のContent-Typeが正しく返されます。

以前の誤った動作に依存している場合は、アクションが受け入れるフォーマットを明示することをお勧めします。例：

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook`は、2番目の引数を受け取るようになりました

Active Supportでは、コールバックがチェーンを停止する場合に`halted_callback_hook`をオーバーライドすることができます。このメソッドは、停止されているコールバックの名前を2番目の引数として受け取るようになりました。このメソッドをオーバーライドするクラスがある場合は、2つの引数を受け入れるようにしてください。なお、これは事前の非推奨化サイクルなしでの破壊的な変更です（パフォーマンス上の理由から）。

例：

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => このメソッドは1つではなく2つの引数を受け入れるようになりました
    Rails.logger.info("Book couldn't be #{callback_name}d")
  end
end
```

### コントローラの`helper`クラスメソッドは`String#constantize`を使用します

概念的には、Rails 6.1以前では

```ruby
helper "foo/bar"
```

は次のようになりました：

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

これは次のように変更されました：

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

この変更は、ほとんどのアプリケーションにとって後方互換性がありますので、特に何もする必要はありません。

ただし、技術的には、コントローラが`helpers_path`を`$LOAD_PATH`の中にあるディレクトリを指すように構成している場合、デフォルトではサポートされなくなりました。ヘルパーモジュールが自動読み込み可能でない場合、アプリケーションは`helper`を呼び出す前にそれをロードする責任があります。

### HTTPからHTTPSへのリダイレクトは、現在308のHTTPステータスコードを使用します

HTTPからHTTPSへのリダイレクト時に`ActionDispatch::SSL`で使用されるデフォルトのHTTPステータスコードが、https://tools.ietf.org/html/rfc7538で定義されている`308`に変更されました。

### Active Storageは現在、画像処理を必要とします

Active Storageでバリアントを処理する際には、直接`mini_magick`を使用する代わりに、[image_processing gem](https://github.com/janko/image_processing)をバンドルする必要があります。Image Processingはデフォルトで`mini_magick`を内部で使用するように設定されているため、アップグレードする最も簡単な方法は、`mini_magick` gemを`image_processing` gemに置き換え、`combine_options`の明示的な使用を削除することです。

可読性のために、生の`resize`呼び出しを`image_processing`のマクロに変更することもできます。例えば、次のようにします：

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

次のようにすることができます：

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### 新しい`ActiveModel::Error`クラス

エラーは新しい`ActiveModel::Error`クラスのインスタンスとなり、APIに変更が加わりました。これらの変更のいくつかは、エラーを操作する方法によってはエラーをスローする場合がありますが、他の変更はRails 7.0のために修正するための非推奨の警告を表示します。

この変更に関する詳細な情報やAPIの変更についての詳細は、[このPR](https://github.com/rails/rails/pull/32313)を参照してください。

Rails 5.2からRails 6.0へのアップグレード
-------------------------------------

Rails 6.0への変更の詳細については、[リリースノート](6_0_release_notes.html)を参照してください。

### Webpackerの使用
[Webpacker](https://github.com/rails/webpacker)
は、Rails 6のデフォルトのJavaScriptコンパイラです。ただし、アプリをアップグレードする場合はデフォルトで有効になっていません。
Webpackerを使用する場合は、Gemfileに含めてインストールしてください。

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### 強制SSL

コントローラ上の`force_ssl`メソッドは非推奨となり、Rails 6.1で削除されます。
HTTPS接続をアプリケーション全体で強制するために[`config.force_ssl`][]を有効にすることをお勧めします。
リダイレクトから特定のエンドポイントを除外する必要がある場合は、[`config.ssl_options`][]を使用してその動作を設定できます。

### 目的と有効期限のメタデータがセキュリティ向上のために署名付きおよび暗号化されたクッキーに埋め込まれるようになりました

セキュリティを向上させるために、Railsは目的と有効期限のメタデータを暗号化または署名付きクッキーの値に埋め込みます。

これにより、クッキーの署名/暗号化された値をコピーして別のクッキーの値として使用しようとする攻撃を防ぐことができます。

この新しい埋め込みメタデータにより、これらのクッキーはRails 6.0より古いバージョンと互換性がありません。

クッキーをRails 5.2およびそれ以前で読み取る必要がある場合、または6.0のデプロイを検証し、ロールバックできるようにする場合は、
`Rails.application.config.action_dispatch.use_cookies_with_metadata`を`false`に設定してください。

### すべてのnpmパッケージは`@rails`スコープに移動しました

以前は、`actioncable`、`activestorage`、`rails-ujs`パッケージをnpm/yarnを介してロードしていた場合、これらの依存関係の名前をアップグレードする前に更新する必要があります。

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Action Cable JavaScript APIの変更

Action Cable JavaScriptパッケージは、CoffeeScriptからES2015に変換され、ソースコードをnpmディストリビューションで公開するようになりました。

このリリースには、Action Cable JavaScript APIのオプションの一部に破壊的な変更が含まれています。

- WebSocketアダプターとロガーアダプターの設定は、`ActionCable`のプロパティから`ActionCable.adapters`のプロパティに移動しました。
  これらのアダプターを設定している場合は、次の変更を行う必要があります:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- `ActionCable.startDebugging()`と`ActionCable.stopDebugging()`メソッドは削除され、プロパティ`ActionCable.logger.enabled`で置き換えられました。
  これらのメソッドを使用している場合は、次の変更を行う必要があります:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type`は、Content-Typeヘッダーを変更せずに返すようになりました

以前は、`ActionDispatch::Response#content_type`の返り値には文字セット部分が含まれていませんでした。
この動作は、以前は文字セット部分を省略していましたが、変更されて以降は文字セット部分も含まれるようになりました。

MIMEタイプのみを取得したい場合は、`ActionDispatch::Response#media_type`を使用してください。

変更前:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

変更後:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### 新しい`config.hosts`設定

Railsには、セキュリティのための新しい`config.hosts`設定があります。この設定は、開発環境ではデフォルトで`localhost`になっています。
開発中に他のドメインを使用する場合は、次のように許可する必要があります:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # オプションで正規表現も使用できます
```

他の環境では、デフォルトで`config.hosts`は空です。これは、Railsがホストを検証しないことを意味します。必要に応じて追加することもできます。

### 自動読み込み

Rails 6のデフォルトの設定

```ruby
# config/application.rb

config.load_defaults 6.0
```

は、CRubyで`zeitwerk`の自動読み込みモードを有効にします。このモードでは、自動読み込み、リロード、およびイーガーローディングは[Zeitwerk](https://github.com/fxn/zeitwerk)によって管理されます。

以前のRailsバージョンのデフォルトを使用している場合は、次のようにしてzeitwerkを有効にできます:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### パブリックAPI

一般的に、アプリケーションはZeitwerkのAPIを直接使用する必要はありません。Railsは既存の契約に従って設定を行います: `config.autoload_paths`、`config.cache_classes`など。

アプリケーションはそのインターフェースに従うべきですが、実際のZeitwerkローダーオブジェクトには次のようにアクセスできます。

```ruby
Rails.autoloaders.main
```

これは、Single Table Inheritance (STI) クラスをプリロードしたり、カスタムのインフレクタを設定したりする必要がある場合に便利です。

#### プロジェクトの構造

アップグレードされるアプリケーションが正しく自動読み込みされる場合、プロジェクトの構造はすでにほとんど互換性があるはずです。

ただし、`classic`モードでは、欠落している定数名からファイル名を推測します（`underscore`）、一方、`zeitwerk`モードでは、ファイル名から定数名を推測します（`camelize`）。これらのヘルパーは常に互いの逆ではないため、特に略語が関与する場合には注意が必要です。例えば、`"FOO".underscore`は`"foo"`ですが、`"foo".camelize`は`"Foo"`ではなく`"FOO"`です。
互換性は、`zeitwerk:check`タスクでチェックできます。

```bash
$ bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

#### require_dependency

`require_dependency`のすべての既知の使用例は削除されましたので、プロジェクトをgrepしてそれらを削除してください。

アプリケーションがSingle Table Inheritanceを使用している場合は、Autoloading and Reloading Constants（Zeitwerk Mode）ガイドの[Single Table Inheritance section](autoloading_and_reloading_constants.html#single-table-inheritance)を参照してください。

#### クラスとモジュール定義の修飾名

クラスとモジュールの定義で定数パスを堅牢に使用できるようになりました。

```ruby
# Autoloading in this class' body matches Ruby semantics now.
class Admin::UsersController < ApplicationController
  # ...
end
```

注意点として、実行の順序によっては、クラシックなオートローダーは、次のコードで`Foo::Wadus`をオートロードできる場合があります。

```ruby
class Foo::Bar
  Wadus
end
```

これはRubyのセマンティクスに一致しないため、`Foo`がネストにないため、`zeitwerk`モードではまったく機能しません。このような特殊なケースがある場合は、修飾名`Foo::Wadus`を使用するか、

```ruby
class Foo::Bar
  Foo::Wadus
end
```

または`Foo`をネストに追加します。

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

次のような標準の構造から自動ロードおよびイーガーロードできます。

```
app/models
app/models/concerns
```

この場合、`app/models/concerns`はルートディレクトリと見なされます（オートロードパスに属しているため）、および名前空間として無視されます。したがって、`app/models/concerns/foo.rb`は`Concerns::Foo`ではなく`Foo`を定義する必要があります。

`Concerns::`の名前空間は、実装の副作用としてクラシックなオートローダーで機能していましたが、実際には意図された動作ではありませんでした。`Concerns::`を使用するアプリケーションは、これらのクラスとモジュールの名前を変更して`zeitwerk`モードで実行できるようにする必要があります。

#### `app`をオートロードパスに持つ場合

一部のプロジェクトでは、`app/api/base.rb`のようなファイルで`API::Base`を定義し、`classic`モードでそれを実現するために`app`をオートロードパスに追加したい場合があります。Railsは`app`のすべてのサブディレクトリを自動的にオートロードパスに追加するため、ネストされたルートディレクトリが存在する場合、このセットアップはもはや機能しません。上記の`concerns`の場合と同様の原則が適用されます。

この構造を維持したい場合は、イニシャライザでオートロードパスからサブディレクトリを削除する必要があります。

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### オートロードされた定数と明示的な名前空間

名前空間がファイルで定義されている場合、例えばここで`Hotel`が定義されている場合：

```
app/models/hotel.rb         # Defines Hotel.
app/models/hotel/pricing.rb # Defines Hotel::Pricing.
```

`Hotel`定数は`class`または`module`キーワードを使用して設定する必要があります。例：

```ruby
class Hotel
end
```

は正しいです。

以下のような代替手段は機能しません。

```ruby
Hotel = Class.new
```

または

```ruby
Hotel = Struct.new
```

この制限は明示的な名前空間にのみ適用されます。名前空間を定義しないクラスやモジュールは、これらのイディオムを使用して定義できます。

#### 1つのファイルに1つの定数（同じトップレベル）

`classic`モードでは、同じトップレベルに複数の定数を定義し、それらをすべて再読み込みすることができました。例えば、次のような場合：

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

`Bar`はオートロードされないかもしれませんが、`Foo`をオートロードすると`Bar`もオートロードされます。これは`zeitwerk`モードでは適用されませんので、`Bar`を独自のファイル`bar.rb`に移動する必要があります。1つのファイルに1つの定数。

これは、上記の例のように同じトップレベルの定数にのみ適用されます。内部のクラスやモジュールは問題ありません。例えば、次のような場合を考えてみてください。

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

アプリケーションが`Foo`を再読み込みすると、`Foo::InnerClass`も再読み込まれます。

#### Springと`test`環境

Springは、何か変更があった場合にアプリケーションコードを再読み込みします。`test`環境では、再読み込みを有効にする必要があります。

```ruby
# config/environments/test.rb

config.cache_classes = false
```

そうしないと、次のエラーが発生します。

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnapは、少なくともバージョン1.4.2である必要があります。

さらに、Ruby 2.5を実行している場合、Bootsnapはiseqキャッシュを無効にする必要があります。その場合は、少なくともBootsnap 1.4.4に依存するようにしてください。

#### `config.add_autoload_paths_to_load_path`

新しい設定ポイント[`config.add_autoload_paths_to_load_path`][]は、後方互換性のためにデフォルトで`true`ですが、autoloadパスを`$LOAD_PATH`に追加しないようにすることもできます。

これはほとんどのアプリケーションで意味があります。たとえば、`app/models`のファイルをrequireする必要はありませんし、Zeitwerkは内部的に絶対ファイル名のみを使用します。
オプトアウトすることで、`$LOAD_PATH`の検索が最適化され（チェックするディレクトリが少なくなるため）、Bootsnapの作業とメモリ消費が節約されます。なぜなら、これらのディレクトリのインデックスを構築する必要がないからです。

#### スレッドセーフ

クラシックモードでは、定数の自動読み込みはスレッドセーフではありませんが、Railsにはロックがあります。たとえば、開発環境で一般的に有効になっている場合、Webリクエストのスレッドセーフを実現するためです。

`zeitwerk`モードでは、定数の自動読み込みはスレッドセーフです。たとえば、`runner`コマンドで実行されるマルチスレッドのスクリプトで自動読み込みを行うことができます。

#### config.autoload_pathsのグロブ

次のような設定に注意してください。

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

`config.autoload_paths`の各要素は、トップレベルの名前空間（`Object`）を表す必要があり、ネストすることはできません（上記で説明した`concerns`ディレクトリを除く）。

これを修正するには、ワイルドカードを削除するだけです。

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### イーガーローディングと自動読み込みの一貫性

`classic`モードでは、`app/models/foo.rb`が`Bar`を定義している場合、そのファイルを自動読み込むことはできませんが、イーガーローディングは再帰的にファイルを読み込むため、動作します。これは、最初にイーガーローディングでテストを行った場合、後で自動読み込みで実行が失敗する可能性があるため、エラーの原因となる場合があります。

`zeitwerk`モードでは、両方のローディングモードが一貫しており、同じファイルで失敗し、エラーが発生します。

#### Rails 6でクラシックオートローダーを使用する方法

アプリケーションは、`config.autoloader`を次のように設定することで、Rails 6のデフォルトを読み込み、クラシックオートローダーを使用することができます。

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Rails 6アプリケーションでクラシックオートローダーを使用する場合、スレッドセーフの問題のため、開発環境のWebサーバーやバックグラウンドプロセッサの並行性レベルを1に設定することをお勧めします。

### Active Storageの割り当て動作の変更

Rails 5.2のデフォルトの設定では、`has_many_attached`で宣言された添付ファイルのコレクションに割り当てると、新しいファイルが追加されます。

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Rails 6.0のデフォルトの設定では、添付ファイルのコレクションに割り当てると、既存のファイルが置き換えられます。これは、Active Recordのコレクション関連に割り当てる場合の動作と一致します。

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach`を使用して、既存のものを削除せずに新しい添付ファイルを追加することができます。

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

既存のアプリケーションは、[`config.active_storage.replace_on_assign_to_many`][]を`true`に設定することで、この新しい動作を選択できます。古い動作はRails 7.0で非推奨になり、Rails 7.1で削除されます。

### カスタム例外処理アプリケーション

無効な`Accept`または`Content-Type`リクエストヘッダーは、例外を発生させるようになりました。
デフォルトの[`config.exceptions_app`][]は、そのエラーを特に処理し、それに対処します。
カスタム例外アプリケーションもそのエラーを処理する必要があります。そうしないと、そのようなリクエストに対してRailsがフォールバック例外アプリケーションを使用し、`500 Internal Server Error`を返します。

Rails 5.1からRails 5.2へのアップグレード
-------------------------------------

Rails 5.2で行われた変更の詳細については、[リリースノート](5_2_release_notes.html)を参照してください。

### Bootsnap

Rails 5.2では、[新しく生成されたアプリのGemfile](https://github.com/rails/rails/pull/29313)にbootsnap gemが追加されました。
`app:update`コマンドは、`boot.rb`でそれを設定します。使用する場合は、Gemfileに追加してください。

```ruby
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
```

それ以外の場合は、`boot.rb`を変更してbootsnapを使用しないようにしてください。

### 署名付きまたは暗号化されたクッキーの有効期限は、クッキーの値に埋め込まれるようになりました

セキュリティを向上させるため、Railsは現在、暗号化または署名付きのクッキーの有効期限情報をクッキーの値にも埋め込んでいます。

この新しい埋め込み情報により、これらのクッキーはRails 5.2より古いバージョンと互換性がありません。

クッキーを5.1およびそれ以前で読み取る必要がある場合、またはまだ5.2のデプロイを検証している場合で、ロールバックを許可するために、
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption`を`false`に設定してください。

Rails 5.0からRails 5.1へのアップグレード
-------------------------------------

Rails 5.1で行われた変更の詳細については、[リリースノート](5_1_release_notes.html)を参照してください。

### トップレベルの`HashWithIndifferentAccess`は非推奨です

アプリケーションがトップレベルの`HashWithIndifferentAccess`クラスを使用している場合は、
コードを徐々に`ActiveSupport::HashWithIndifferentAccess`を使用するように移行する必要があります。
これはソフトデプリケーションのみであり、現時点ではコードが壊れることはなく、非推奨の警告も表示されませんが、この定数は将来的に削除されます。

また、古いYAMLドキュメントには、このようなオブジェクトのダンプが含まれている場合、正しい定数を参照するように再度ロードおよびダンプする必要があります。これにより、将来的にロードが壊れることがないようになります。

### `application.secrets` はすべてのキーをシンボルとして読み込むようになりました

アプリケーションがネストされた設定を `config/secrets.yml` に格納している場合、すべてのキーがシンボルとして読み込まれるようになりましたので、文字列を使用したアクセス方法を変更する必要があります。

変更前:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

変更後:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### `render` での `:text` と `:nothing` の非推奨サポートが削除されました

コントローラが `render :text` を使用している場合、これはもはや機能しません。`text/plain` の MIME タイプでテキストをレンダリングする新しい方法は、`render :plain` を使用することです。

同様に、`render :nothing` も削除され、ヘッダのみを含むレスポンスを送信するために `head` メソッドを使用する必要があります。例えば、`head :ok` は本文をレンダリングせずに 200 のレスポンスを送信します。

### `redirect_to :back` の非推奨サポートが削除されました

Rails 5.0 では、`redirect_to :back` は非推奨となりました。Rails 5.1 では完全に削除されました。

代わりに、`redirect_back` を使用してください。`redirect_back` は `HTTP_REFERER` が存在しない場合に使用される `fallback_location` オプションも受け取ることに注意してください。

```ruby
redirect_back(fallback_location: root_path)
```


Rails 4.2 から Rails 5.0 へのアップグレード
-------------------------------------

Rails 5.0 への変更の詳細については、[リリースノート](5_0_release_notes.html) を参照してください。

### Ruby 2.2.2+ が必要です

Ruby on Rails 5.0 以降、Ruby 2.2.2+ のみがサポートされています。
進む前に、Ruby 2.2.2 バージョン以上になっていることを確認してください。

### Active Record モデルはデフォルトで ApplicationRecord を継承するようになりました

Rails 4.2 では、Active Record モデルは `ActiveRecord::Base` を継承していました。Rails 5.0 では、すべてのモデルが `ApplicationRecord` を継承するように変更されました。

`ApplicationRecord` は、アプリケーションのモデルのための新しいスーパークラスであり、アプリケーションコントローラが `ActionController::Base` の代わりに `ApplicationController` をサブクラス化するのと同様のものです。これにより、アプリケーション全体のモデルの動作を設定するための単一の場所が提供されます。

Rails 4.2 から Rails 5.0 にアップグレードする際には、`app/models/` に `application_record.rb` ファイルを作成し、次の内容を追加する必要があります:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

その後、すべてのモデルがそれを継承していることを確認してください。

### `throw(:abort)` によるコールバックチェーンの停止

Rails 4.2 では、Active Record および Active Model で 'before' コールバックが `false` を返すと、コールバックチェーン全体が停止されました。つまり、連続する 'before' コールバックは実行されず、コールバックでラップされたアクションも実行されませんでした。

Rails 5.0 では、Active Record または Active Model のコールバックで `false` を返しても、コールバックチェーンが停止する副作用はありません。代わりに、`throw(:abort)` を呼び出すことで明示的にコールバックチェーンを停止する必要があります。

Rails 4.2 から Rails 5.0 にアップグレードする際には、そのようなコールバックで `false` を返すと、コールバックチェーンはまだ停止しますが、この将来の変更に関する非推奨の警告が表示されます。

準備ができたら、新しい動作に移行し、次の設定を `config/application.rb` に追加することで、非推奨の警告を削除できます:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

このオプションは、Active Support コールバックには影響を与えません。なぜなら、値が返されたときにチェーンが停止したことはなかったからです。

詳細については、[#17227](https://github.com/rails/rails/pull/17227) を参照してください。

### ActiveJob はデフォルトで ApplicationJob を継承するようになりました

Rails 4.2 では、Active Job は `ActiveJob::Base` を継承していました。Rails 5.0 では、この動作が変更され、`ApplicationJob` を継承するようになりました。

Rails 4.2 から Rails 5.0 にアップグレードする際には、`app/jobs/` に `application_job.rb` ファイルを作成し、次の内容を追加する必要があります:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

その後、すべてのジョブクラスがそれを継承していることを確認してください。

詳細については、[#19034](https://github.com/rails/rails/pull/19034) を参照してください。

### Rails コントローラのテスト

#### 一部のヘルパーメソッドを `rails-controller-testing` に抽出しました

`assigns` と `assert_template` は、`rails-controller-testing` gem に抽出されました。コントローラのテストでこれらのメソッドを引き続き使用するには、`Gemfile` に `gem 'rails-controller-testing'` を追加してください。

テストに RSpec を使用している場合は、gem のドキュメントに記載されている追加の設定を参照してください。

#### ファイルのアップロード時の新しい動作

テストで `ActionDispatch::Http::UploadedFile` を使用してファイルをアップロードしている場合、同様の `Rack::Test::UploadedFile` クラスを使用するように変更する必要があります。
詳細については[#26404](https://github.com/rails/rails/issues/26404)を参照してください。

### プロダクション環境での起動後にオートロードが無効化されるようになりました

デフォルトで、プロダクション環境での起動後にオートロードが無効化されるようになりました。

アプリケーションのイーガーローディングは起動プロセスの一部であり、トップレベルの定数は問題なくオートロードされます。そのため、ファイルを要求する必要はありません。

通常のメソッド本体のように、実行時にのみ実行されるような深い場所の定数も問題ありません。なぜなら、それらを定義するファイルは起動時にイーガーロードされているからです。

ほとんどのアプリケーションでは、この変更に対して何もする必要はありません。ただし、プロダクションで実行中にオートロードが必要な場合は、`Rails.application.config.enable_dependency_loading`をtrueに設定してください。

### XMLシリアライゼーション

`ActiveModel::Serializers::Xml`はRailsから`activemodel-serializers-xml`というジェムに抽出されました。アプリケーションで引き続きXMLシリアライゼーションを使用するには、`Gemfile`に`gem 'activemodel-serializers-xml'`を追加してください。

### レガシーな`mysql`データベースアダプタのサポートが削除されました

Rails 5では、レガシーな`mysql`データベースアダプタのサポートが削除されました。ほとんどのユーザーは`mysql2`を代わりに使用できるはずです。メンテナンスを引き継いでくれる人が見つかった場合、それは別のジェムに変換されます。

### デバッガのサポートが削除されました

Ruby 2.2では`debugger`はサポートされていないため、Rails 5では使用できません。代わりに`byebug`を使用してください。

### タスクとテストの実行には`bin/rails`を使用してください

Rails 5では、タスクとテストを`rake`の代わりに`bin/rails`を使用して実行できるようになりました。これらの変更は一般的にはrakeと並行して行われますが、一部はまとめて移植されました。

新しいテストランナーを使用するには、単に`bin/rails test`と入力してください。

`rake dev:cache`は`bin/rails dev:cache`になりました。

アプリケーションのルートディレクトリで`bin/rails`を実行すると、利用可能なコマンドのリストが表示されます。

### `ActionController::Parameters`はもはや`HashWithIndifferentAccess`を継承しません

アプリケーションで`params`を呼び出すと、ハッシュではなくオブジェクトが返されるようになりました。パラメータが既に許可されている場合は、変更を加える必要はありません。`permitted?`に関係なくハッシュを読み取る必要がある`map`などのメソッドを使用している場合は、アプリケーションをアップグレードして最初に許可し、その後にハッシュに変換する必要があります。

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery`のデフォルトは`prepend: false`になりました

`protect_from_forgery`のデフォルトは`prepend: false`になりました。つまり、アプリケーションで呼び出すポイントでコールバックチェーンに挿入されます。`protect_from_forgery`を常に最初に実行したい場合は、アプリケーションを変更して`protect_from_forgery prepend: true`を使用する必要があります。

### デフォルトのテンプレートハンドラはRAWになりました

拡張子にテンプレートハンドラが指定されていないファイルは、RAWハンドラを使用してレンダリングされます。以前はRailsがERBテンプレートハンドラを使用してファイルをレンダリングしていました。

ファイルをRAWハンドラで処理したくない場合は、適切なテンプレートハンドラで解析できる拡張子をファイルに追加する必要があります。

### テンプレートの依存関係にワイルドカードマッチングを追加しました

テンプレートの依存関係にワイルドカードマッチングを使用できるようになりました。たとえば、次のようにテンプレートを定義していた場合：

```erb
<% # テンプレートの依存関係: recordings/threads/events/subscribers_changed %>
<% # テンプレートの依存関係: recordings/threads/events/completed %>
<% # テンプレートの依存関係: recordings/threads/events/uncompleted %>
```

ワイルドカードを使用して依存関係を一度だけ呼び出すことができます。

```erb
<% # テンプレートの依存関係: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper`が外部ジェム（record_tag_helper）に移動しました

`content_tag_for`と`div_for`は削除され、代わりに`content_tag`のみを使用するようになりました。古いメソッドを引き続き使用するには、`Gemfile`に`record_tag_helper`ジェムを追加してください：

```ruby
gem 'record_tag_helper', '~> 1.0'
```

詳細については[#18411](https://github.com/rails/rails/pull/18411)を参照してください。

### `protected_attributes`ジェムのサポートが削除されました

Rails 5では、`protected_attributes`ジェムはサポートされなくなりました。

### `activerecord-deprecated_finders`ジェムのサポートが削除されました

Rails 5では、`activerecord-deprecated_finders`ジェムはサポートされなくなりました。

### `ActiveSupport::TestCase`のデフォルトのテスト順序はランダムになりました

テストがアプリケーションで実行されるとき、デフォルトの順序は`：random`ではなく`：sorted`になりました。`：sorted`に戻すには、次の設定オプションを使用してください。

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live`が`Concern`になりました

コントローラに含まれる他のモジュールで`ActionController::Live`を含める場合は、そのモジュールを`ActiveSupport::Concern`で拡張する必要があります。または、`StreamingSupport`が含まれた後に`ActionController::Live`をコントローラに直接含めるために、`self.included`フックを使用することもできます。

これは、アプリケーションが独自のストリーミングモジュールを持っていた場合、次のコードは本番環境で壊れるでしょう：
```ruby
# これは、Warden/Deviseを使用してストリームコントローラーで認証を行うための回避策です。
# https://github.com/plataformatec/devise/issues/2332 を参照してください。
# その問題で提案されたように、ルーターで認証することも別の解決策です。
class StreamingSupport
  include ActionController::Live # これはRails 5では本番環境では機能しません
  # extend ActiveSupport::Concern # この行のコメントを解除しない限りは機能しません。

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### 新しいフレームワークのデフォルト値

#### Active Record `belongs_to` Required by Default オプション

`belongs_to`は、関連が存在しない場合にデフォルトでバリデーションエラーを発生させるようになりました。

これは、`optional: true`を使用して個別の関連ごとに無効にすることができます。

このデフォルトは、新しいアプリケーションに自動的に設定されます。既存のアプリケーションでこの機能を追加する場合は、初期化ファイルで有効にする必要があります。

```ruby
config.active_record.belongs_to_required_by_default = true
```

この設定はデフォルトで全てのモデルに対してグローバルに適用されますが、モデルごとにオーバーライドすることもできます。これにより、全てのモデルをデフォルトで関連が必須となるように移行するのに役立ちます。

```ruby
class Book < ApplicationRecord
  # モデルはまだデフォルトで関連が必須ではありません

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # モデルはデフォルトで関連が必須となる準備ができています

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### フォームごとのCSRFトークン

Rails 5では、JavaScriptによって作成されたフォームに対するコードインジェクション攻撃からの保護として、フォームごとのCSRFトークンがサポートされるようになりました。このオプションをオンにすると、アプリケーションのフォームごとに、そのフォームのアクションとメソッドに固有のCSRFトークンが生成されます。

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### OriginチェックによるForgery Protection

アプリケーションがHTTPの`Origin`ヘッダーをサイトのオリジンと照合するかどうかを設定できるようになりました。以下の設定を`true`に設定してください。

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Action Mailerキュー名の設定

デフォルトのメーラーキュー名は`mailers`です。この設定オプションを使用すると、キュー名をグローバルに変更することができます。以下の設定を行ってください。

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Action Mailerビューでのフラグメントキャッシュのサポート

[`config.action_mailer.perform_caching`][]を設定して、Action Mailerビューでキャッシュをサポートするかどうかを決定します。

```ruby
config.action_mailer.perform_caching = true
```

#### `db:structure:dump`の出力の設定

`schema_search_path`やその他のPostgreSQLの拡張を使用している場合、スキーマのダンプ方法を制御することができます。`config.active_record.dump_schemas`を`:all`に設定すると、すべてのダンプを生成します。`:schema_search_path`に設定すると、スキーマ検索パスから生成します。

```ruby
config.active_record.dump_schemas = :all
```

#### サブドメインでHSTSを有効にするためのSSLオプションの設定

サブドメインを使用している場合にHSTSを有効にするには、以下の設定を行ってください。

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### レシーバのタイムゾーンを保持する設定

Ruby 2.4を使用している場合、`to_time`を呼び出す際にレシーバのタイムゾーンを保持することができます。

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### JSON/JSONBシリアライズの変更

Rails 5.0では、JSON/JSONB属性のシリアライズとデシリアライズの方法が変更されました。これにより、`String`と等しいカラムを設定した場合、Active Recordはその文字列を`Hash`に変換せず、単に文字列を返すようになりました。これはモデルとの対話だけでなく、`db/schema.rb`の`:default`カラム設定にも影響します。`String`と等しいカラムを設定しないようにすることをお勧めします。代わりに、自動的にJSON文字列に変換される`Hash`を渡してください。

Rails 4.1からRails 4.2へのアップグレード
-------------------------------------

### Web Console

まず、`Gemfile`の`:development`グループに`gem 'web-console', '~> 2.0'`を追加し、`bundle install`を実行してください（アップグレード時に含まれていない場合は追加する必要があります）。インストールが完了したら、コンソールヘルパー（つまり、`<%= console %>`）を任意のビューに追加するだけで有効にすることができます。開発環境で表示されるエラーページにもコンソールが提供されます。

### Responders

`respond_with`とクラスレベルの`respond_to`メソッドは、`responders` gemに抽出されました。これらを使用するには、`Gemfile`に`gem 'responders', '~> 2.0'`を追加してください。`respond_with`と`respond_to`への呼び出し（再度、クラスレベルで）は、依存関係に`responders` gemを含めていない場合は動作しません。
```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

インスタンスレベルの`respond_to`は影響を受けず、追加のgemは必要ありません：

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

詳細については、[#16526](https://github.com/rails/rails/pull/16526)を参照してください。

### トランザクションコールバックでのエラーハンドリング

現在、Active Recordは`after_rollback`または`after_commit`コールバック内で発生したエラーを抑制し、ログにのみ表示します。次のバージョンでは、これらのエラーは抑制されなくなります。代わりに、エラーは他のActive Recordコールバックと同様に通常通り伝播します。

`after_rollback`または`after_commit`コールバックを定義すると、この将来の変更に関する非推奨の警告が表示されます。準備ができたら、以下の設定を`config/application.rb`に追加することで新しい動作に移行し、非推奨の警告を削除できます。

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

詳細については、[#14488](https://github.com/rails/rails/pull/14488)および[#16537](https://github.com/rails/rails/pull/16537)を参照してください。

### テストケースの順序付け

Rails 5.0では、デフォルトでテストケースはランダムな順序で実行されます。この変更に備えて、Rails 4.2ではテストの順序を明示的に指定するための新しい設定オプション`active_support.test_order`が導入されました。これにより、オプションを`:sorted`に設定することで現在の動作を固定するか、オプションを`:random`に設定することで将来の動作に移行することができます。

このオプションの値を指定しない場合、非推奨の警告が表示されます。これを回避するために、テスト環境に以下の行を追加してください。

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # もしくは `:random` を選択する場合
end
```

### シリアライズされた属性

カスタムコーダー（例：`serialize :metadata, JSON`）を使用する場合、シリアライズされた属性に`nil`を割り当てると、`nil`の値をコーダーを介さずにデータベースに`NULL`として保存します（例：`JSON`コーダーを使用する場合は`"null"`）。

### 本番ログレベル

Rails 5では、本番環境のデフォルトのログレベルが`：info`から`：debug`に変更されます。現在のデフォルトを維持するために、`production.rb`に以下の行を追加してください。

```ruby
# 現在のデフォルトに合わせるには `:info` を設定し、将来のデフォルトに移行するには `:debug` を設定します。
config.log_level = :info
```

### Railsテンプレートの`after_bundle`

バージョン管理にすべてのファイルを追加するRailsテンプレートがある場合、Bundlerの実行前に実行されるため、生成されたbinstubを追加できません。

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

これを解決するために、`git`の呼び出しを`after_bundle`ブロックで囲むことができます。これにより、binstubが生成された後に実行されます。

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTMLサニタイザー

アプリケーションでHTMLフラグメントをサニタイズするための新しい選択肢があります。伝統的なhtml-scannerアプローチは、公式には非推奨とされ、[`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer)に置き換えられました。

これにより、`sanitize`、`sanitize_css`、`strip_tags`、`strip_links`メソッドが新しい実装でバックアップされるようになりました。

この新しいサニタイザーは、内部で[Loofah](https://github.com/flavorjones/loofah)を使用しています。LoofahはCとJavaで書かれたXMLパーサーをラップしているため、どのバージョンのRubyを実行していてもサニタイズが高速になります。

新しいバージョンでは、`sanitize`に`Loofah::Scrubber`を渡すことができるようになりました。
[ここでいくつかのスクラバーの例を見ることができます](https://github.com/flavorjones/loofah#loofahscrubber)。

さらに、`PermitScrubber`と`TargetScrubber`という2つの新しいスクラバーが追加されました。詳細については、[gemのreadme](https://github.com/rails/rails-html-sanitizer)を参照してください。

`PermitScrubber`と`TargetScrubber`のドキュメントでは、要素をどのように削除するかを完全に制御する方法について説明しています。

古いサニタイザーの実装を使用する必要がある場合は、`Gemfile`に`rails-deprecated_sanitizer`を含めてください。

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOMテスト

[`TagAssertions`モジュール](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html)（`assert_tag`などのメソッドを含む）は、[`SelectorAssertions`モジュール](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb)の`assert_select`メソッドを使用することを推奨するため、非推奨となりました。`SelectorAssertions`モジュールは[rails-dom-testing gem](https://github.com/rails/rails-dom-testing)に抽出されました。

### マスクされた認証トークン

SSL攻撃を緩和するために、`form_authenticity_token`はマスクされるようになり、各リクエストごとに異なる値になります。そのため、トークンはアンマスクして復号化して検証されます。その結果、静的なセッションCSRFトークンに依存していた非Railsフォームからのリクエストの検証戦略は、これを考慮に入れる必要があります。
### Action Mailer

以前は、メーラークラスのメーラーメソッドを呼び出すと、対応するインスタンスメソッドが直接実行されました。しかし、Active Jobと`#deliver_later`の導入により、これはもはや真ではありません。Rails 4.2では、インスタンスメソッドの呼び出しは、`deliver_now`または`deliver_later`が呼び出されるまで遅延されます。例えば：

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # この時点ではまだNotifier#notifyは呼び出されていません
mail = mail.deliver_now           # "Called"と出力されます
```

これは、ほとんどのアプリケーションには目立った違いをもたらしません。ただし、以前は同期的なプロキシ動作に依存していた非メーラーメソッドを同期的に実行する必要がある場合は、それらを直接メーラークラスのクラスメソッドとして定義する必要があります。

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### 外部キーのサポート

マイグレーションDSLは、外部キーの定義をサポートするように拡張されました。Foreigner gemを使用していた場合は、削除を検討することをお勧めします。Railsの外部キーサポートはForeignerの一部です。つまり、すべてのForeignerの定義をRailsのマイグレーションDSLの対応するもので完全に置き換えることはできません。

マイグレーション手順は次のとおりです。

1. `Gemfile`から`gem "foreigner"`を削除します。
2. `bundle install`を実行します。
3. `bin/rake db:schema:dump`を実行します。
4. `db/schema.rb`に必要なオプションを持つすべての外部キー定義が含まれていることを確認します。

Rails 4.0からRails 4.1へのアップグレード
-------------------------------------

### リモートの`<script>`タグからのCSRF保護

または、「なんでテストが失敗するの！？」または「私の`<script>`ウィジェットが壊れている！」ということです。

クロスサイトリクエストフォージェリ（CSRF）保護は、JavaScriptのレスポンスを伴うGETリクエストにも適用されるようになりました。これにより、第三者のサイトが`<script>`タグを使用してJavaScriptをリモートで参照して、機密データを抽出することを防止します。

これは、以下を使用している機能テストや統合テストに影響を与えます。

```ruby
get :index, format: :js
```

これにより、CSRF保護がトリガーされます。代わりに

```ruby
xhr :get, :index, format: :js
```

を使用して、`XmlHttpRequest`を明示的にテストします。

注意：独自の`<script>`タグもクロスオリジンとして扱われ、デフォルトでブロックされます。`<script>`タグからJavaScriptを読み込む意図がある場合は、これらのアクションで明示的にCSRF保護をスキップする必要があります。

### Spring

アプリケーションのプリローダとしてSpringを使用する場合は、次の手順を実行する必要があります。

1. `Gemfile`に`gem 'spring', group: :development`を追加します。
2. `bundle install`を使用してSpringをインストールします。
3. `bundle exec spring binstub`を使用してSpringのbinstubを生成します。

注意：ユーザー定義のrakeタスクはデフォルトで`development`環境で実行されます。他の環境で実行する場合は、[Spring README](https://github.com/rails/spring#rake)を参照してください。

### `config/secrets.yml`

アプリケーションのシークレットを保存するために新しい`secrets.yml`規約を使用する場合は、次の手順を実行する必要があります。

1. `config`フォルダに`secrets.yml`ファイルを作成し、次の内容を追加します。

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. `secret_token.rb`イニシャライザから既存の`secret_key_base`を使用して、Railsアプリケーションを本番で実行しているユーザーの`SECRET_KEY_BASE`環境変数を設定します。または、単純に`secret_key_base`を`secret_token.rb`イニシャライザからコピーして、`secrets.yml`の`production`セクションに`<%= ENV["SECRET_KEY_BASE"] %>`を置き換えます。

3. `secret_token.rb`イニシャライザを削除します。

4. `rake secret`を使用して、`development`および`test`セクションの新しいキーを生成します。

5. サーバーを再起動します。

### テストヘルパーの変更

テストヘルパーに`ActiveRecord::Migration.check_pending!`の呼び出しが含まれている場合、これを削除できます。このチェックは、`require "rails/test_help"`時に自動的に行われますが、この行をヘルパーに残しておいても問題ありません。

### Cookieシリアライザ

Rails 4.1より前に作成されたアプリケーションでは、署名付きおよび暗号化されたクッキージャーに対して`Marshal`を使用してクッキーの値をシリアライズしていました。アプリケーションで新しい`JSON`ベースの形式を使用したい場合は、次の内容のイニシャライザファイルを追加できます。

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

これにより、既存の`Marshal`でシリアライズされたクッキーが新しい`JSON`ベースの形式に透過的に移行されます。

`:json`または`:hybrid`シリアライザを使用する場合、すべてのRubyオブジェクトがJSONとしてシリアライズできるわけではないことに注意してください。例えば、`Date`オブジェクトや`Time`オブジェクトは文字列としてシリアライズされ、`Hash`のキーは文字列に変換されます。

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
クッキーには、シンプルなデータ（文字列や数値）のみを保存することをお勧めします。
複雑なオブジェクトを保存する場合は、後続のリクエストで値を読み取る際に変換を手動で処理する必要があります。

クッキーのセッションストアを使用する場合、これは`session`と`flash`ハッシュにも適用されます。

### Flash構造の変更

Flashメッセージのキーは、[文字列に正規化](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1)されます。それらは引き続きシンボルまたは文字列のいずれかを使用してアクセスできます。Flashをループ処理すると常に文字列キーが返されます。

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

Flashメッセージのキーを文字列と比較していることを確認してください。

### JSON処理の変更

Rails 4.1には、JSON処理に関連するいくつかの重要な変更があります。

#### MultiJSONの削除

MultiJSONは[終了](https://github.com/rails/rails/pull/10576)し、Railsから削除されました。

現在のアプリケーションが直接MultiJSONに依存している場合、いくつかのオプションがあります。

1. `Gemfile`に 'multi_json'を追加します。ただし、将来的には機能しなくなる可能性があります。

2. `obj.to_json`と`JSON.parse(str)`を使用してMultiJSONから移行します。

警告：単純に`MultiJson.dump`と`MultiJson.load`を`JSON.dump`と`JSON.load`に置き換えないでください。これらのJSON gemのAPIは、任意のRubyオブジェクトをシリアライズおよびデシリアライズするためのものであり、一般的には[安全ではありません](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load)。

#### JSON gemの互換性

過去に、RailsはJSON gemとの互換性の問題を抱えていました。Railsアプリケーション内で`JSON.generate`と`JSON.dump`を使用すると、予期しないエラーが発生する場合があります。

Rails 4.1では、これらの問題を修正し、JSON gemから独自のエンコーダを分離しました。JSON gemのAPIは通常通り機能しますが、Rails固有の機能にはアクセスできません。例えば：

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### 新しいJSONエンコーダ

Rails 4.1のJSONエンコーダは、JSON gemの利点を活用するために書き直されました。ほとんどのアプリケーションにとって、これは透過的な変更になるはずです。ただし、書き直しの一環として、エンコーダから次の機能が削除されました。

1. 循環データ構造の検出
2. `encode_json`フックのサポート
3. `BigDecimal`オブジェクトを文字列ではなく数値としてエンコードするオプション

アプリケーションがこれらの機能に依存している場合は、[`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) gemを`Gemfile`に追加することでこれらの機能を取り戻すことができます。

#### TimeオブジェクトのJSON表現

時間成分を持つオブジェクト（`Time`、`DateTime`、`ActiveSupport::TimeWithZone`）の`#as_json`は、デフォルトでミリ秒の精度を返すようになりました。ミリ秒の精度を持たない古い動作を維持する必要がある場合は、初期化子で次のように設定します。

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### インラインコールバックブロック内での`return`の使用

以前、Railsはインラインコールバックブロックでこのように`return`を使用することを許可していました。

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # BAD
end
```

この動作は意図的にサポートされていませんでした。`ActiveSupport::Callbacks`の内部の変更により、これはRails 4.1では許可されなくなりました。インラインコールバックブロックで`return`ステートメントを使用すると、コールバックが実行されると`LocalJumpError`が発生します。

`return`を使用しているインラインコールバックブロックは、返された値を評価するようにリファクタリングすることができます。

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # GOOD
end
```

または、`return`を使用する場合は、明示的にメソッドを定義することをお勧めします。

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # GOOD

  private
    def before_save_callback
      false
    end
end
```

この変更は、コールバックが使用されるRailsのほとんどの場所に適用されます。これには、Active RecordやActive Modelのコールバック、Action Controllerのフィルタ（例：`before_action`）などが含まれます。

詳細については、[このプルリクエスト](https://github.com/rails/rails/pull/13271)を参照してください。

### Active Recordフィクスチャで定義されたメソッド

Rails 4.1では、各フィクスチャのERBを別々のコンテキストで評価するため、フィクスチャで定義されたヘルパーメソッドは他のフィクスチャで使用できません。

複数のフィクスチャで使用されるヘルパーメソッドは、`test_helper.rb`で新たに導入された`ActiveRecord::FixtureSet.context_class`に含まれるモジュールで定義する必要があります。

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### 利用可能なロケールの強制

Rails 4.1では、I18nオプション`enforce_available_locales`のデフォルト値が`true`になりました。これにより、渡されるすべてのロケールは`available_locales`リストに宣言されている必要があります。
アプリケーションでこれを無効にする（およびI18nが*任意の*ロケールオプションを受け入れるようにする）には、次の設定を追加します。

```ruby
config.i18n.enforce_available_locales = false
```

このオプションは、ユーザーの入力が事前に知られていない限り、ロケール情報として使用されないようにするためのセキュリティ対策として追加されました。したがって、このオプションを無効にしないことをお勧めします。

### Relationで呼び出されるミューテータメソッド

`Relation`にはもはや`#map!`や`#delete_if`などのミューテータメソッドはありません。これらのメソッドを使用する前に、`#to_a`を呼び出して`Array`に変換してください。

これにより、`Relation`に直接ミューテータメソッドを呼び出すコードでの奇妙なバグや混乱が防止されるようになります。

```ruby
# これではなく
Author.where(name: 'Hank Moody').compact!

# これを行う必要があります
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### デフォルトスコープの変更

デフォルトスコープは、チェーンされた条件によってもはや上書きされません。

以前のバージョンでは、モデルで`default_scope`を定義すると、同じフィールドのチェーンされた条件によって上書きされました。今では、他のスコープと同様にマージされます。

以前：

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

以降：

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

以前の動作を取得するには、`unscoped`、`unscope`、`rewhere`、または`except`を使用して明示的に`default_scope`の条件を削除する必要があります。

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### 文字列からのコンテンツのレンダリング

Rails 4.1では、`render`に`:plain`、`:html`、および`:body`オプションが導入されました。これらのオプションは、レスポンスを送信するときにどのコンテンツタイプを使用するかを指定できるため、文字列ベースのコンテンツをレンダリングするための推奨方法です。

* `render :plain`はコンテンツタイプを`text/plain`に設定します
* `render :html`はコンテンツタイプを`text/html`に設定します
* `render :body`はコンテンツタイプヘッダーを設定しません。

セキュリティの観点から、レスポンスボディにマークアップがない場合は、`render :plain`を使用する必要があります。ほとんどのブラウザは、レスポンスの安全でないコンテンツをエスケープしてくれます。

将来のバージョンでは、`render :text`の使用は非推奨になります。代わりに、より正確な`:plain`、`:html`、および`:body`オプションを使用してください。`render :text`を使用すると、コンテンツが`text/html`として送信されるため、セキュリティ上のリスクがあります。

### PostgreSQLのJSONとhstoreデータ型

Rails 4.1では、`json`と`hstore`のカラムを文字列キーのRuby `Hash`にマップします。以前のバージョンでは、`HashWithIndifferentAccess`が使用されていました。これは、シンボルアクセスがサポートされなくなったことを意味します。これは、`json`または`hstore`カラムの上に基づく`store_accessors`にも当てはまります。一貫して文字列キーを使用するようにしてください。

### `ActiveSupport::Callbacks`の明示的なブロックの使用

Rails 4.1では、`ActiveSupport::Callbacks.set_callback`を呼び出す際に明示的なブロックが渡されることを期待しています。この変更は、4.1リリースのために`ActiveSupport::Callbacks`が大幅に書き直されたことによるものです。

```ruby
# 以前のRails 4.0では
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# 今のRails 4.1では
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Rails 3.2からRails 4.0へのアップグレード
-------------------------------------

アプリケーションが現在のバージョンが3.2.xよりも古いRailsのバージョンである場合、Rails 4.0にアップグレードする前にまずRails 3.2にアップグレードする必要があります。

以下の変更は、アプリケーションをRails 4.0にアップグレードするためのものです。

### HTTP PATCH
Rails 4では、RESTfulなリソースが`config/routes.rb`で宣言されている場合、更新のための主要なHTTP動詞として`PATCH`が使用されます。`update`アクションは引き続き使用され、`PUT`リクエストも`update`アクションにルーティングされます。したがって、標準のRESTfulなルートのみを使用している場合は、変更は必要ありません。

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # 変更は必要ありません。PATCHが優先され、PUTも動作します。
  end
end
```

ただし、`PUT` HTTPメソッドを使用したカスタムルートと組み合わせてリソースを更新するために`form_for`を使用している場合は、変更が必要です。

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # 変更が必要です。form_forは存在しないPATCHルートを使用しようとします。
  end
end
```

もしアクションが公開APIで使用されており、使用されているHTTPメソッドを変更できない場合は、フォームを`PUT`メソッドを使用するように更新する必要があります。

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

PATCHとなぜこの変更が行われたのかについては、Railsブログの[この記事](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)を参照してください。

#### メディアタイプについての注意事項

`PATCH`動詞の勘定書きには、[`PATCH`と共に「diff」メディアタイプを使用する](http://www.rfc-editor.org/errata_search.php?rfc=5789)という誤植があります。そのような形式の1つが[JSON Patch](https://tools.ietf.org/html/rfc6902)です。RailsはJSON Patchをネイティブにサポートしていませんが、簡単にサポートを追加できます。

```ruby
# コントローラー内:
def update
  respond_to do |format|
    format.json do
      # 部分的な更新を実行
      @article.update params[:article]
    end

    format.json_patch do
      # 複雑な変更を実行
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

JSON Patchは最近RFCになったばかりなので、まだ優れたRubyライブラリはありません。Aaron Pattersonの[hana](https://github.com/tenderlove/hana)はそのようなジェムの1つですが、仕様の最後のいくつかの変更に対して完全なサポートを持っていません。

### Gemfile

Rails 4.0では、`Gemfile`から`assets`グループが削除されました。アップグレードする際には、その行を`Gemfile`から削除する必要があります。また、アプリケーションファイル（`config/application.rb`内）も更新する必要があります。

```ruby
# Gemfileに記載されているgemを読み込むために、
# :test、:development、:productionに制限されたgemも含めてrequireする。
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0では、`vendor/plugins`からのプラグインの読み込みがサポートされなくなりました。プラグインをジェムに抽出して`Gemfile`に追加するか、ジェムにしない場合は、`lib/my_plugin/*`に移動し、`config/initializers/my_plugin.rb`に適切な初期化子を追加する必要があります。

### Active Record

* Rails 4.0では、Active Recordからidentity mapが削除されました。これは[関連付けの不整合によるものです](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6)。アプリケーションで手動で有効にしている場合は、もはや効果のない次の設定を削除する必要があります：`config.active_record.identity_map`。

* コレクション関連付けの`delete`メソッドは、レコードのIDだけでなく、`Integer`または`String`の引数も受け取ることができるようになりました。これまでは、このような引数に対して`ActiveRecord::AssociationTypeMismatch`が発生していました。Rails 4.0以降、`delete`は削除する前に指定されたIDに一致するレコードを自動的に検索しようとします。

* Rails 4.0では、列またはテーブルの名前が変更されると、関連するインデックスも名前が変更されます。インデックスの名前を変更するマイグレーションがある場合は、それらはもはや必要ありません。

* Rails 4.0では、`serialized_attributes`と`attr_readonly`がクラスメソッドのみに変更されました。もはやインスタンスメソッドを使用しないでください。クラスメソッドを使用するように変更する必要があります。例えば、`self.serialized_attributes`を`self.class.serialized_attributes`に変更するなどです。

* デフォルトのコーダーを使用して、シリアライズされた属性に`nil`を割り当てると、`nil`の値をYAML（`"--- \n...\n"`）を介して渡すのではなく、データベースに`NULL`として保存されるようになりました。
* Rails 4.0では、`attr_accessible`と`attr_protected`の機能がStrong Parametersに置き換えられました。スムーズなアップグレードパスのために、[Protected Attributes gem](https://github.com/rails/protected_attributes)を使用することができます。

* Protected Attributesを使用していない場合は、`whitelist_attributes`や`mass_assignment_sanitizer`など、このgemに関連するオプションを削除することができます。

* Rails 4.0では、スコープはProcやlambdaなどの呼び出し可能なオブジェクトを使用する必要があります。

    ```ruby
      scope :active, where(active: true)

      # 以下のようになります
      scope :active, -> { where active: true }
    ```

* Rails 4.0では、`ActiveRecord::Fixtures`は`ActiveRecord::FixtureSet`に非推奨となりました。

* Rails 4.0では、`ActiveRecord::TestCase`は`ActiveSupport::TestCase`に非推奨となりました。

* Rails 4.0では、古いスタイルのハッシュベースの検索APIが非推奨となりました。これは、以前に「検索オプション」を受け入れていたメソッドがもはや受け入れないことを意味します。例えば、`Book.find(:all, conditions: { name: '1984' })`は`Book.where(name: '1984')`に非推奨となりました。

* `find_by_...`と`find_by_...!`以外の動的メソッドはすべて非推奨となりました。変更の対処方法は以下の通りです：

      * `find_all_by_...`           は `where(...)` に変更します。
      * `find_last_by_...`          は `where(...).last` に変更します。
      * `scoped_by_...`             は `where(...)` に変更します。
      * `find_or_initialize_by_...` は `find_or_initialize_by(...)` に変更します。
      * `find_or_create_by_...`     は `find_or_create_by(...)` に変更します。

* `where(...)`は古い検索方法とは異なり、配列ではなくリレーションを返します。配列が必要な場合は、`where(...).to_a`を使用してください。

* これらの同等のメソッドは、以前の実装と同じSQLを実行しない場合があります。

* 古い検索方法を再度有効にするには、[activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)を使用することができます。

* Rails 4.0では、`has_and_belongs_to_many`関係のデフォルトの結合テーブルが、2番目のテーブル名から共通の接頭辞を削除するように変更されました。共通の接頭辞を持つモデル間の既存の`has_and_belongs_to_many`関係は、`join_table`オプションを指定する必要があります。例：

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* 接頭辞はスコープも考慮に入れるため、`Catalog::Category`と`Catalog::Product`または`Catalog::Category`と`CatalogProduct`の間の関係も同様に更新する必要があります。

### Active Resource

Rails 4.0では、Active Resourceが独自のgemに分離されました。この機能が必要な場合は、`Gemfile`に[Active Resource gem](https://github.com/rails/activeresource)を追加することができます。

### Active Model

* Rails 4.0では、`ActiveModel::Validations::ConfirmationValidator`でエラーが発生した場合、エラーは`attribute`ではなく`:#{attribute}_confirmation`に関連付けられるように変更されました。

* Rails 4.0では、`ActiveModel::Serializers::JSON.include_root_in_json`のデフォルト値が`false`に変更されました。これにより、Active Model SerializersとActive Recordオブジェクトが同じデフォルトの動作を持つようになりました。したがって、`config/initializers/wrap_parameters.rb`ファイルの以下のオプションをコメントアウトまたは削除することができます。

    ```ruby
    # Disable root element in JSON by default.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0では、`ActiveSupport::KeyGenerator`が導入され、これを基にして署名付きクッキーを生成および検証します。Rails 3.xで生成された既存の署名付きクッキーは、既存の`secret_token`をそのままにして新しい`secret_key_base`を追加することで透過的にアップグレードされます。

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    ただし、`secret_key_base`を設定するのは、ユーザーベースの100%がRails 4.xに移行し、Rails 3.xにロールバックする必要がないことがほぼ確実な場合に行うべきです。これは、Rails 4.xで`secret_key_base`に基づいて署名されたクッキーがRails 3.xと互換性がないためです。既存の`secret_token`をそのままにして、新しい`secret_key_base`を設定せずに、非推奨の警告を無視することもできます。アップグレードが完了していることがほぼ確実な場合にのみ、警告を無視してください。

    Railsアプリの署名付きセッションクッキー（または署名付きクッキー全般）を外部アプリケーションやJavaScriptが読み取れるようにする必要がある場合は、これらの関心事を切り離すまで`secret_key_base`を設定しないでください。

* Rails 4.0では、`secret_key_base`が設定されている場合、クッキーベースのセッションの内容が暗号化されます。Rails 3.xでは、クッキーベースのセッションの内容は署名されていますが、暗号化されていません。署名付きクッキーは、アプリによって生成されたことが検証され、改ざんされないことが保証されます。ただし、内容はエンドユーザーに表示される可能性があり、内容を暗号化することでこの注意点/懸念事項を排除します。これには大きなパフォーマンスのペナルティはありません。

    暗号化されたセッションクッキーへの移行の詳細については、[Pull Request #9978](https://github.com/rails/rails/pull/9978)をご覧ください。

* Rails 4.0では、`ActionController::Base.asset_path`オプションが削除されました。代わりにアセットパイプライン機能を使用してください。
* Rails 4.0では、`ActionController::Base.page_cache_extension`オプションが非推奨となりました。代わりに`ActionController::Base.default_static_extension`を使用してください。

* Rails 4.0では、Action PackからActionとPageのキャッシュが削除されました。`caches_action`を使用するには`actionpack-action_caching` gemを追加する必要があります。また、`caches_page`を使用するには`actionpack-page_caching` gemを追加する必要があります。

* Rails 4.0では、XMLパラメーターパーサーが削除されました。この機能が必要な場合は、`actionpack-xml_parser` gemを追加する必要があります。

* Rails 4.0では、シンボルまたはnilを返すプロックを使用して設定されるデフォルトの`layout`の検索方法が変更されました。"no layout"の動作を得るためには、nilの代わりにfalseを返すようにしてください。

* Rails 4.0では、デフォルトのmemcachedクライアントが`memcache-client`から`dalli`に変更されました。アップグレードするには、単に`Gemfile`に`gem 'dalli'`を追加してください。

* Rails 4.0では、コントローラーで`dom_id`メソッドと`dom_class`メソッドが非推奨となりました（ビューでは問題ありません）。この機能を使用するコントローラーには、`ActionView::RecordIdentifier`モジュールを含める必要があります。

* Rails 4.0では、`link_to`ヘルパーの`:confirm`オプションが非推奨となりました。代わりにデータ属性（例：`data: { confirm: 'Are you sure?' }`）に依存するようにしてください。この非推奨は、このヘルパーに基づくヘルパー（`link_to_if`や`link_to_unless`など）にも関係します。

* Rails 4.0では、`assert_generates`、`assert_recognizes`、および`assert_routing`の動作が変更されました。これらのアサーションはすべて、`ActionController::RoutingError`ではなく`Assertion`を発生させるようになりました。

* Rails 4.0では、名前が衝突する名前付きルートが定義されている場合には`ArgumentError`が発生します。これは、明示的に定義された名前付きルートまたは`resources`メソッドによって引き起こされる可能性があります。以下は、`example_path`という名前のルートと衝突する2つの例です：

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    最初の場合は、複数のルートに同じ名前を使用しないようにするだけで問題ありません。2番目の場合は、`resources`メソッドで提供される`only`または`except`オプションを使用して作成されるルートを制限するために、[Routing Guide](routing.html#restricting-the-routes-created)で詳細に説明されている方法を使用できます。

* Rails 4.0では、ユニコード文字のルートの描画方法も変更されました。ユニコード文字のルートを直接描画できるようになりました。既にこのようなルートを描画している場合は、例えば次のように変更する必要があります：

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    変更後：

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0では、`match`を使用するルートはリクエストメソッドを指定する必要があります。例：

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # 変更後
      match '/' => 'root#index', via: :get

      # または
      get '/' => 'root#index'
    ```

* Rails 4.0では、`ActionDispatch::BestStandardsSupport`ミドルウェアが削除されました。`<!DOCTYPE html>`は既にhttps://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspxによって標準モードがトリガーされ、ChromeFrameヘッダーは`config.action_dispatch.default_headers`に移動されました。

    アプリケーションコードからミドルウェアへの参照も削除する必要があることにも注意してください。例：

    ```ruby
    # 例外を発生させる
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    環境設定に`config.action_dispatch.best_standards_support`がある場合は、それも削除してください。

* Rails 4.0では、`config.action_dispatch.default_headers`を設定することでHTTPヘッダーを構成することができます。デフォルトは次のとおりです：

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    アプリケーションが`<frame>`または`<iframe>`で特定のページを読み込む必要がある場合は、`X-Frame-Options`を明示的に`ALLOW-FROM ...`または`ALLOWALL`に設定する必要があるかもしれません。

* Rails 4.0では、アセットのプリコンパイルはもはや自動的に`vendor/assets`と`lib/assets`から非JS/CSSアセットをコピーしません。Railsアプリケーションおよびエンジン開発者は、これらのアセットを`app/assets`に配置するか、[`config.assets.precompile`][]を設定する必要があります。

* Rails 4.0では、アクションがリクエストフォーマットを処理しない場合には`ActionController::UnknownFormat`が発生します。デフォルトでは、この例外は406 Not Acceptableで応答するように処理されますが、これをオーバーライドすることもできます。Rails 3では、常に406 Not Acceptableが返されました。オーバーライドはありません。

* Rails 4.0では、リクエストパラメータを解析できなかった場合には、一般的な`ActionDispatch::ParamsParser::ParseError`例外が発生します。例外を処理するために、低レベルの`MultiJson::DecodeError`ではなく、この例外をキャッチする必要があります。

* Rails 4.0では、エンジンがURLプレフィックスから提供されるアプリにマウントされている場合、`SCRIPT_NAME`が適切にネストされます。これにより、上書きされたURLプレフィックスを回避するために`default_url_options[:script_name]`を設定する必要はありません。

* Rails 4.0では、`ActionController::Integration`は非推奨となり、`ActionDispatch::Integration`が推奨されます。
* Rails 4.0では、`ActionController::IntegrationTest`は非推奨となり、`ActionDispatch::IntegrationTest`が推奨されます。
* Rails 4.0では、`ActionController::PerformanceTest`は非推奨となり、`ActionDispatch::PerformanceTest`が推奨されます。
* Rails 4.0では、`ActionController::AbstractRequest`は非推奨となり、`ActionDispatch::Request`が推奨されます。
* Rails 4.0では、`ActionController::Request`は非推奨となり、`ActionDispatch::Request`が推奨されます。
* Rails 4.0では、`ActionController::AbstractResponse`は非推奨となり、`ActionDispatch::Response`が推奨されます。
* Rails 4.0では、`ActionController::Response`は非推奨となり、`ActionDispatch::Response`が推奨されます。
* Rails 4.0では、`ActionController::Routing`は非推奨となり、`ActionDispatch::Routing`が推奨されます。
### Active Support

Rails 4.0では、`j`はすでに`ActionView::Helpers::JavaScriptHelper#escape_javascript`で使用されているため、`ERB::Util#json_escape`の`j`エイリアスが削除されました。

#### キャッシュ

Rails 3.xと4.0ではキャッシュのメソッドが変更されました。[キャッシュの名前空間を変更](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store)し、キャッシュをクリアしてから展開する必要があります。

### ヘルパーの読み込み順

複数のディレクトリからのヘルパーの読み込み順序がRails 4.0で変更されました。以前は、ヘルパーは収集されてからアルファベット順に並べ替えられていました。Rails 4.0にアップグレードすると、ヘルパーは読み込まれたディレクトリの順序を保持し、各ディレクトリ内でのみアルファベット順に並べ替えられます。`helpers_path`パラメータを明示的に使用しない限り、この変更はエンジンからヘルパーを読み込む方法にのみ影響を与えます。順序に依存している場合は、アップグレード後に正しいメソッドが利用可能かどうかを確認する必要があります。エンジンの読み込み順序を変更したい場合は、`config.railties_order=`メソッドを使用できます。

### Active Record ObserverとAction Controller Sweeper

`ActiveRecord::Observer`と`ActionController::Caching::Sweeper`は`rails-observers`ジェムに抽出されました。これらの機能が必要な場合は、`rails-observers`ジェムを追加する必要があります。

### sprockets-rails

* `assets:precompile:primary`と`assets:precompile:all`が削除されました。代わりに`assets:precompile`を使用してください。
* `config.assets.compress`オプションは、[`config.assets.js_compressor`][]に変更する必要があります。例えば、次のようになります。

    ```ruby
    config.assets.js_compressor = :uglifier
    ```


### sass-rails

* 2つの引数を持つ`asset-url`は非推奨です。例えば、`asset-url("rails.png", image)`は`asset-url("rails.png")`になります。

Rails 3.1からRails 3.2へのアップグレード
-------------------------------------

アプリケーションが3.1.xより古いバージョンのRailsである場合、アップグレードを試みる前にRails 3.1にアップグレードする必要があります。

以下の変更は、アプリケーションを最新の3.2.xバージョンのRailsにアップグレードするためのものです。

### Gemfile

`Gemfile`に以下の変更を加えてください。

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

開発環境に以下の新しい設定を追加する必要があります。

```ruby
# Active Recordモデルのマスアサインメント保護に対して例外を発生させる
config.active_record.mass_assignment_sanitizer = :strict

# クエリの実行計画をログに出力する（SQLite、MySQL、PostgreSQLで動作）
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`config/environments/test.rb`にも`mass_assignment_sanitizer`の設定を追加してください。

```ruby
# Active Recordモデルのマスアサインメント保護に対して例外を発生させる
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2では`vendor/plugins`は非推奨となり、Rails 4.0では完全に削除されます。Rails 3.2のアップグレードの一環として必須ではありませんが、プラグインをジェムに抽出して`Gemfile`に追加するか、`lib/my_plugin/*`に移動して`config/initializers/my_plugin.rb`に適切な初期化処理を追加することができます。

### Active Record

`belongs_to`からオプション`:dependent => :restrict`が削除されました。関連するオブジェクトが存在する場合にオブジェクトの削除を防止するには、`:dependent => :destroy`を設定し、関連オブジェクトの削除コールバックのいずれかから関連の存在をチェックした後に`false`を返すことができます。

Rails 3.0からRails 3.1へのアップグレード
-------------------------------------

アプリケーションが3.0.xより古いバージョンのRailsである場合、アップグレードを試みる前にRails 3.0にアップグレードする必要があります。

以下の変更は、アプリケーションをRails 3.1.12にアップグレードするためのものです。

### Gemfile

`Gemfile`に以下の変更を加えてください。

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# 新しいアセットパイプラインに必要
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQueryはRails 3.1のデフォルトのJavaScriptライブラリです
gem 'jquery-rails'
```

### config/application.rb

アセットパイプラインには以下の追加が必要です。

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

アプリケーションがリソースに対して"/assets"ルートを使用している場合、アセット用のプレフィックスを変更して競合を回避するために次のようにすることができます。

```ruby
# デフォルトは '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

RJSの設定`config.action_view.debug_rjs = true`を削除してください。

アセットパイプラインを有効にする場合、以下の設定を追加してください。

```ruby
# アセットを圧縮しない
config.assets.compress = false

# アセットを読み込む行を展開する
config.assets.debug = true
```

### config/environments/production.rb

以下の変更は、再びアセットパイプラインに関するものです。これについては、[アセットパイプライン](asset_pipeline.html)ガイドで詳しく説明しています。
```ruby
# JavaScriptとCSSを圧縮する
config.assets.compress = true

# コンパイル済みのアセットが見つからない場合にアセットパイプラインにフォールバックしない
config.assets.compile = false

# アセットURLにダイジェストを生成する
config.assets.digest = true

# デフォルトはRails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# 追加のアセットを事前コンパイルする（application.js、application.css、およびすべての非JS/CSSは既に追加されています）
# config.assets.precompile += %w( admin.js admin.css )

# アプリ全体でSSLを強制し、Strict-Transport-Securityを使用し、セキュアなクッキーを使用する
# config.force_ssl = true
```

### config/environments/test.rb

これらの追加をテスト環境に設定することで、パフォーマンスをテストできます。

```ruby
# パフォーマンスのためにCache-Controlを使用してテスト用の静的アセットサーバーを設定する
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

パラメータをネストされたハッシュにラップする場合は、次の内容でこのファイルを追加します。これは新しいアプリケーションではデフォルトで有効になっています。

```ruby
# このファイルを変更した場合は、サーバーを再起動してください。
# このファイルには、デフォルトで有効になっているActionController::ParamsWrapperの設定が含まれています。

# JSONのパラメータラッピングを有効にする。:formatを空の配列に設定することで無効にできます。
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# JSONでルート要素を無効にする。
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

セッションキーを新しいものに変更するか、すべてのセッションを削除する必要があります。

```ruby
# in config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

または

```bash
$ bin/rake db:sessions:clear
```

### ビュー内のアセットヘルパー参照の:cacheと:concatオプションを削除する

* アセットパイプラインでは、:cacheと:concatオプションはもはや使用されませんので、ビューからこれらのオプションを削除してください。
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
