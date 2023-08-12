**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
自動読み込みと定数の再読み込み
===================================

このガイドでは、`zeitwerk`モードでの自動読み込みと再読み込みの仕組みについて説明します。

このガイドを読み終えると、以下のことがわかります。

* 関連するRailsの設定
* プロジェクトの構造
* 自動読み込み、再読み込み、イーガーローディング
* 単一テーブル継承
* その他

--------------------------------------------------------------------------------

はじめに
------------

INFO. このガイドでは、Railsアプリケーションにおける自動読み込み、再読み込み、イーガーローディングについて説明します。

通常のRubyプログラムでは、使用するクラスやモジュールを定義するファイルを明示的に読み込む必要があります。たとえば、次のコントローラーは`ApplicationController`と`Post`を参照しており、通常はこれらのために`require`を使用します。

```ruby
# これは行わないでください。
require "application_controller"
require "post"
# これは行わないでください。

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

しかし、Railsアプリケーションでは、アプリケーションのクラスやモジュールは`require`を使用せずにどこでも利用できます。

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Railsは、必要に応じてこれらを自動的にロードします。これは、Railsが自動読み込み、再読み込み、イーガーローディングを提供するために設定された[Zeitwerk](https://github.com/fxn/zeitwerk)ローダーのおかげです。

一方、これらのローダーは他の何も管理しません。特に、Rubyの標準ライブラリ、gemの依存関係、Railsのコンポーネント自体、そして（デフォルトでは）アプリケーションの`lib`ディレクトリさえも管理しません。そのコードは通常どおりにロードする必要があります。


プロジェクトの構造
-----------------

Railsアプリケーションでは、ファイル名は定義する定数と一致し、ディレクトリは名前空間として機能します。

たとえば、ファイル`app/helpers/users_helper.rb`は`UsersHelper`を定義し、ファイル`app/controllers/admin/payments_controller.rb`は`Admin::PaymentsController`を定義する必要があります。

デフォルトでは、Railsはファイル名を`String#camelize`で変換するようにZeitwerkを設定しています。たとえば、`app/controllers/users_controller.rb`が定数`UsersController`を定義することを期待しています。なぜなら、`"users_controller".camelize`が返す値がそれだからです。

以下の「インフレクションのカスタマイズ」のセクションでは、このデフォルトを上書きする方法について説明します。

詳細については、[Zeitwerkのドキュメント](https://github.com/fxn/zeitwerk#file-structure)を参照してください。


config.autoload_paths
---------------------

自動読み込みおよび（オプションで）再読み込みされるアプリケーションディレクトリのリストを「自動読み込みパス」と呼びます。たとえば、`app/models`などです。これらのディレクトリはルート名前空間である`Object`を表します。

INFO. Zeitwerkのドキュメントでは、自動読み込みパスを「ルートディレクトリ」と呼んでいますが、このガイドでは「自動読み込みパス」と呼びます。

自動読み込みパス内では、ファイル名は[ここ](https://github.com/fxn/zeitwerk#file-structure)で説明されているように、定義する定数と一致する必要があります。

デフォルトでは、アプリケーションの自動読み込みパスは、アプリケーションが起動するときに存在する`app`のすべてのサブディレクトリ（`assets`、`javascript`、`views`を除く）と、依存する可能性のあるエンジンの自動読み込みパスで構成されています。

たとえば、`UsersHelper`が`app/helpers/users_helper.rb`に実装されている場合、モジュールは自動的に読み込まれますので、`require`の呼び出しは必要ありません（また、書いてはいけません）。

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Railsは、`app`の下にカスタムディレクトリを自動的に追加します。たとえば、アプリケーションに`app/presenters`がある場合、プレゼンターを自動的に読み込むために何も設定する必要はありません。そのまま使えます。

デフォルトの自動読み込みパスの配列は、`config/application.rb`または`config/environments/*.rb`で`config.autoload_paths`に追加することで拡張できます。たとえば：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

また、エンジンはエンジンクラスの本体と独自の`config/environments/*.rb`で追加できます。

WARNING. `ActiveSupport::Dependencies.autoload_paths`を変更しないでください。自動読み込みパスを変更する公開インターフェースは`config.autoload_paths`です。

WARNING: アプリケーションの起動中に自動読み込みパス内のコードを自動読み込むことはできません。特に、`config/initializers/*.rb`で直接行うことはできません。有効な方法については、以下の「アプリケーションの起動時の自動読み込み」を参照してください。

自動読み込みパスは、`Rails.autoloaders.main`ローダーによって管理されます。


config.autoload_lib(ignore:)
----------------------------

デフォルトでは、`lib`ディレクトリはアプリケーションやエンジンの自動読み込みパスに含まれません。

`config.autoload_lib`設定メソッドは、`lib`ディレクトリを`config.autoload_paths`および`config.eager_load_paths`に追加します。これは`config/application.rb`または`config/environments/*.rb`から呼び出す必要があり、エンジンでは使用できません。

通常、`lib`には自動読み込みローダーで管理すべきではないサブディレクトリが含まれています。そのため、必要な場合は、`ignore`キーワード引数に`lib`に対する相対パスを指定してください。たとえば：

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

なぜ？`assets`と`tasks`は通常のコードと`lib`ディレクトリを共有していますが、その内容は自動読み込みやイーガーロードの対象ではありません。`Assets`と`Tasks`はそこではRubyの名前空間ではありません。ジェネレーターも同様です。
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib`は7.1より前では利用できませんが、アプリケーションがZeitwerkを使用している限り、それをエミュレートすることはできます。

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.main.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

config.autoload_once_paths
--------------------------

リロードせずにクラスやモジュールを自動読み込みしたい場合、`autoload_once_paths`設定にコードを保存できます。

デフォルトでは、このコレクションは空ですが、`config.autoload_once_paths`に追加することで拡張することができます。これは`config/application.rb`または`config/environments/*.rb`で行うことができます。例えば：

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

また、エンジンはエンジンクラスの本体と`config/environments/*.rb`に追加することができます。

INFO. `app/serializers`が`config.autoload_once_paths`に追加されると、Railsはこれをautoloadパスとは見なさなくなりますが、`app`のカスタムディレクトリであるにもかかわらず、この設定はそのルールを上書きします。

これは、Railsフレームワーク自体のようなリロードを生き残る場所にキャッシュされたクラスやモジュールに対して重要です。

例えば、Active JobのシリアライザはActive Job内に保存されています。

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

そして、Active Job自体はリロードされません。リロードがある場合、アプリケーションとエンジンのコードのみがautoloadパスにある場合にのみリロードされます。

`MoneySerializer`をリロード可能にすると混乱するため、編集したバージョンをリロードしてもActive Jobに保存されているクラスオブジェクトには影響しません。実際、`MoneySerializer`がリロード可能であれば、Rails 7以降ではそのような初期化子が`NameError`を発生させます。

もう1つのユースケースは、エンジンがフレームワーククラスをデコレートする場合です。

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

ここでは、初期化子が実行される時点で`MyDecoration`に保存されているモジュールオブジェクトが`ActionController::Base`の祖先になり、`MyDecoration`をリロードすることは意味がありません。それはその祖先チェーンに影響を与えません。

autoload onceパスのクラスとモジュールは`config/initializers`で自動読み込みされます。したがって、この設定では次のように動作します。

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO: 技術的には、`once`オートローダーで管理されるクラスとモジュールを`bootstrap_hook`の後に実行される任意の初期化子で自動読み込みすることができます。

autoload onceパスは`Rails.autoloaders.once`で管理されます。

config.autoload_lib_once(ignore:)
---------------------------------

`config.autoload_lib_once`メソッドは`config.autoload_lib`と似ていますが、`lib`を`config.autoload_once_paths`に追加します。これは`config/application.rb`または`config/environments/*.rb`から呼び出す必要があり、エンジンでは利用できません。

`config.autoload_lib_once`は7.1より前では利用できませんが、アプリケーションがZeitwerkを使用している限り、それをエミュレートすることはできます。

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    lib = root.join("lib")

    config.autoload_once_paths << lib
    config.eager_load_paths << lib

    Rails.autoloaders.once.ignore(
      lib.join("assets"),
      lib.join("tasks"),
      lib.join("generators")
    )

    ...
  end
end
```

$LOAD_PATH{#load_path}
----------

デフォルトでは、autoloadパスは`$LOAD_PATH`に追加されます。ただし、Zeitwerkは内部的に絶対ファイル名を使用しており、アプリケーションはautoload可能なファイルのために`require`呼び出しを発行すべきではないため、これらのディレクトリは実際にはそこに必要ありません。このフラグを使用してオプトアウトすることができます。

```ruby
config.add_autoload_paths_to_load_path = false
```

これにより、正当な`require`呼び出しの数が少なくなるため、少し速くなる場合があります。また、アプリケーションが[Bootsnap](https://github.com/Shopify/bootsnap)を使用している場合、ライブラリが不要なインデックスを構築することを防ぐため、メモリ使用量が低下します。

このフラグは`lib`ディレクトリには影響しません。`lib`ディレクトリは常に`$LOAD_PATH`に追加されます。

リロード
---------

Railsは、autoloadパスのアプリケーションファイルが変更された場合に自動的にクラスとモジュールをリロードします。

具体的には、ウェブサーバーが実行中であり、アプリケーションファイルが変更された場合、Railsは次のリクエストが処理される直前に、`main`オートローダーによって管理されるすべてのautoloadされた定数をアンロードします。これにより、そのリクエスト中に使用されるアプリケーションのクラスやモジュールが再度autoloadされ、ファイルシステムの現在の実装を取得します。

リロードは有効または無効にすることができます。この動作を制御する設定は[`config.enable_reloading`][]です。これは、`development`モードではデフォルトで`true`、`production`モードではデフォルトで`false`です。互換性のために、Railsは`config.cache_classes`もサポートしており、これは`!config.enable_reloading`と同等です。

Railsはデフォルトでイベント駆動型のファイルモニターを使用してファイルの変更を検出します。代わりにautoloadパスを歩いてファイルの変更を検出するように設定することもできます。これは[`config.file_watcher`][]設定で制御されます。

Railsコンソールでは、`config.enable_reloading`の値に関係なく、ファイルウォッチャーはアクティブになりません。これは、通常、コンソールセッションの中でコードがリロードされると混乱するためです。個々のリクエストと同様に、一貫性のある、変更されないアプリケーションのクラスとモジュールによってコンソールセッションが提供されることが一般的です。
ただし、コンソールで`reload!`を実行することで強制的にリロードすることができます。

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Reloading...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

ご覧の通り、リロード後に`User`定数に格納されているクラスオブジェクトが異なります。


### リロードと古いオブジェクト

Rubyには、クラスやモジュールをメモリ上で本当にリロードし、それが既に使用されているすべての場所に反映される方法はありません。技術的には、「アンロード」することは、`Object.send(:remove_const, "User")`を使用して`User`定数を削除することを意味します。

例えば、次のRailsコンソールセッションをご覧ください。

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe`は元の`User`クラスのインスタンスです。リロードがある場合、`User`定数は異なるリロードされたクラスに評価されます。`alice`は新しくロードされた`User`のインスタンスですが、`joe`はそうではありません - 彼のクラスは古くなっています。`joe`を再定義したり、IRBのサブセッションを開始したり、`reload!`を呼び出す代わりに、新しいコンソールを起動することができます。

また、リロードされない場所でリロード可能なクラスをサブクラス化する場合にも、この注意点に遭遇することがあります。

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

`User`がリロードされる場合、`VipUser`はリロードされないため、`VipUser`のスーパークラスは元の古いクラスオブジェクトです。

要点：**リロード可能なクラスやモジュールをキャッシュしないでください**。

## アプリケーションの起動時の自動読み込み

起動時、アプリケーションは`autoload_once_paths`から自動的に読み込むことができます。これは`once`オートローダーによって管理されます。詳細については、上記の[`config.autoload_once_paths`](#config-autoload-once-paths)セクションをご覧ください。

ただし、`config/initializers`やアプリケーションやエンジンの初期化子でのコードなど、`main`オートローダーによって管理されるオートロードパスからは自動的に読み込むことはできません。

なぜなら、初期化子はアプリケーションの起動時にのみ実行されるためです。リロード時には再度実行されません。初期化子がリロード可能なクラスやモジュールを使用している場合、それらの編集は初期コードに反映されず、古くなってしまいます。したがって、初期化中にリロード可能な定数を参照することは許可されていません。

代わりに、どうすればよいかを見てみましょう。

### ユースケース1：起動時にリロード可能なコードを読み込む

#### 起動時とリロード時の両方で自動読み込み

`ApiGateway`がリロード可能なクラスであり、アプリケーションの起動時にエンドポイントを設定する必要があると想像してみましょう。

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

初期化子はリロード可能な定数を参照することはできませんので、`to_prepare`ブロックでそれをラップする必要があります。このブロックは起動時とリロード時の後に実行されます。

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

注意：歴史的な理由から、このコールバックは2回実行される場合があります。実行するコードは冪等である必要があります。

#### 起動時のみ自動読み込み

リロード可能なクラスやモジュールは、`after_initialize`ブロックでも自動的に読み込むことができます。これらは起動時に実行されますが、リロード時には再度実行されません。特殊なケースでは、これが必要な場合もあります。

プリフライトチェックはこのようなユースケースです。

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### ユースケース2：起動時にキャッシュされたコードを読み込む

一部の設定では、クラスやモジュールオブジェクトを受け入れ、それをリロードされない場所に格納します。これらがリロード可能であってはならないことが重要です。なぜなら、編集がそれらのキャッシュされた古いオブジェクトに反映されないからです。

ミドルウェアがその例です。

```ruby
config.middleware.use MyApp::Middleware::Foo
```

リロード時にはミドルウェアスタックは影響を受けないため、`MyApp::Middleware::Foo`がリロード可能であることは混乱を招くでしょう。その実装の変更は効果を持ちません。

もう1つの例はActive Jobのシリアライザです。

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

初期化時に`MoneySerializer`が評価され、それがカスタムシリアライザに追加され、リロード時にはそこにとどまります。

さらに、railtieやエンジンは、モジュールを含めることでフレームワーククラスを装飾することがあります。例えば、[`turbo-rails`](https://github.com/hotwired/turbo-rails)はこのように`ActiveRecord::Base`を装飾します。

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

これにより、`Turbo::Broadcastable`が`ActiveRecord::Base`の祖先チェーンにモジュールオブジェクトが追加されます。リロードされた場合、`Turbo::Broadcastable`の変更は効果を持ちません。祖先チェーンは元のものを保持したままです。

推論：これらのクラスやモジュールは**リロード可能ではありません**。

起動時にこれらのクラスやモジュールを参照する最も簡単な方法は、オートロードパスに属していないディレクトリでそれらを定義することです。例えば、`lib`は典型的な選択肢です。デフォルトではオートロードパスには属していませんが、`$LOAD_PATH`には属しています。通常の`require`を使用してそれを読み込んでください。
上記のように、別のオプションは、autoloadでディレクトリを定義するディレクトリに配置することです。詳細については、[config.autoload_once_pathsのセクション](#config-autoload-once-paths)をご確認ください。

### ユースケース3：エンジンのアプリケーションクラスを設定する

エンジンがユーザーをモデル化するリロード可能なアプリケーションクラスで動作し、その設定ポイントがあると仮定しましょう。

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

リロード可能なアプリケーションコードとの互換性を確保するために、エンジンはアプリケーションがそのクラスの「名前」を設定する必要があります。

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

その後、実行時に`config.user_model.constantize`を使用して現在のクラスオブジェクトを取得できます。

イーガーローディング
-------------

本番のような環境では、アプリケーションが起動するときにすべてのアプリケーションコードをロードする方が一般的には良いです。イーガーローディングは、リクエストをすぐに処理できるようにすべてのコードをメモリに読み込むため、また[CoW](https://en.wikipedia.org/wiki/Copy-on-write)にも対応しています。

イーガーローディングは、フラグ[`config.eager_load`]によって制御されます。このフラグは、`production`以外のすべての環境でデフォルトで無効になっています。Rakeタスクが実行されると、[`config.rake_eager_load`]によって`config.eager_load`が上書きされます。デフォルトでは、本番環境ではRakeタスクはアプリケーションをイーガーロードしません。

ファイルのイーガーロードの順序は未定義です。

イーガーローディング中、Railsは`Zeitwerk::Loader.eager_load_all`を呼び出します。これにより、Zeitwerkで管理されるすべてのgemの依存関係もイーガーロードされます。



シングルテーブル継承
------------------------

シングルテーブル継承は、遅延ロードとはうまく動作しません：Active Recordは正しく動作するためにSTIの階層を認識する必要がありますが、遅延ロードではクラスは必要に応じて正確にロードされます！

この根本的な不一致に対処するために、STIをプリロードする必要があります。さまざまなトレードオフを伴ういくつかのオプションがあります。それらを見てみましょう。

### オプション1：イーガーローディングを有効にする

STIをプリロードする最も簡単な方法は、次のようにイーガーローディングを有効にすることです：

```ruby
config.eager_load = true
```

`config/environments/development.rb`および`config/environments/test.rb`に設定します。

これはシンプルですが、アプリケーション全体を起動時およびリロード時にイーガーロードするため、コストがかかる場合があります。ただし、小規模なアプリケーションでは、このトレードオフは有益な場合があります。

### オプション2：折りたたまれたディレクトリをプリロードする

階層を定義するファイルを専用のディレクトリに格納する方法です。これは概念的にも意味があります。このディレクトリは名前空間を表すためではなく、STIをグループ化するためのものです。

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

この例では、`app/models/shapes/circle.rb`は`Shapes::Circle`ではなく`Circle`を定義することを望んでいます。これは、事前にコードベースをリファクタリングする必要がないため、シンプルにするための個人的な選択肢かもしれません。Zeitwerkの[折りたたみ](https://github.com/fxn/zeitwerk#collapsing-directories)機能を使用すると、これを実現できます：

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # 名前空間ではありません。

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

このオプションでは、これらの数少ないファイルを起動時にイーガーロードし、STIが使用されていなくてもリロードします。ただし、アプリケーションに多くのSTIがない限り、これには計測可能な影響はありません。

INFO: `Zeitwerk::Loader#eager_load_dir`メソッドは、Zeitwerk 2.6.2で追加されました。古いバージョンでは、`app/models/shapes`ディレクトリをリストアップし、その内容に`require_dependency`を呼び出すこともできます。

WARNING: STIからモデルが追加、変更、削除される場合、リロードは期待どおりに動作します。ただし、新しい別のSTI階層がアプリケーションに追加される場合は、イニシャライザを編集してサーバーを再起動する必要があります。

### オプション3：通常のディレクトリをプリロードする

前のオプションと同様ですが、ディレクトリは名前空間を表すことを意図しています。つまり、`app/models/shapes/circle.rb`は`Shapes::Circle`を定義することが期待されています。

これについては、折りたたみは設定されていないため、イニシャライザは同じです：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

同じトレードオフです。

### オプション4：データベースからタイプをプリロードする

このオプションでは、ファイルを任意の方法で整理する必要はありませんが、データベースにアクセスします：

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

WARNING: テーブルにすべてのタイプがない場合でも、STIは正しく動作しますが、`subclasses`や`descendants`などのメソッドは欠落しているタイプを返しません。

WARNING: STIからモデルが追加、変更、削除される場合、リロードは期待どおりに動作します。ただし、新しい別のSTI階層がアプリケーションに追加される場合は、イニシャライザを編集してサーバーを再起動する必要があります。
カスタマイズインフレクション
-----------------------

デフォルトでは、Railsは`String#camelize`を使用して、特定のファイルやディレクトリ名がどの定数を定義するかを判断します。例えば、`posts_controller.rb`は`"posts_controller".camelize`が返す`PostsController`を定義する必要があります。

特定のファイルやディレクトリ名が望むようにインフレクトされない場合があります。例えば、`html_parser.rb`はデフォルトでは`HtmlParser`を定義することが期待されます。しかし、クラス名を`HTMLParser`にしたい場合はどうでしょうか？これをカスタマイズする方法はいくつかあります。

最も簡単な方法は、略語を定義することです：

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

これにより、Active Supportのインフレクションがグローバルに影響を与えます。これは一部のアプリケーションでは問題ありませんが、デフォルトのインフレクターから独立して個々のベース名をキャメライズする方法をカスタマイズすることもできます。これはオーバーライドのコレクションをデフォルトのインフレクターに渡すことで行います：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

ただし、このテクニックは、デフォルトのインフレクターがフォールバックとして使用する`String#camelize`に依存しているため、それに依存しないようにする場合は、Active Supportのインフレクションに依存せずにインフレクションを完全に制御することができます。これを行うには、インフレクターを`Zeitwerk::Inflector`のインスタンスに設定します：

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

これらのインスタンスに影響を与えるグローバルな設定はありません。これらは決定論的です。

さらなる柔軟性のために、カスタムインフレクターを定義することもできます。詳細については、[Zeitwerkのドキュメント](https://github.com/fxn/zeitwerk#custom-inflector)を参照してください。

### インフレクションカスタマイズはどこに配置すべきですか？

アプリケーションが`once`オートローダーを使用していない場合、上記のスニペットは`config/initializers`に配置できます。例えば、Active Supportの場合は`config/initializers/inflections.rb`、その他の場合は`config/initializers/zeitwerk.rb`です。

`once`オートローダーを使用しているアプリケーションでは、この設定を`config/application.rb`のアプリケーションクラスの本体から移動またはロードする必要があります。なぜなら、`once`オートローダーはブートプロセスの早い段階でインフレクターを使用するためです。

カスタム名前空間
-----------------

前述のように、オートロードパスはトップレベルの名前空間である`Object`を表します。

例えば、`app/services`を考えてみましょう。このディレクトリはデフォルトでは生成されませんが、存在する場合、Railsは自動的にオートロードパスに追加します。

デフォルトでは、ファイル`app/services/users/signup.rb`は`Users::Signup`を定義することが期待されますが、そのサブツリー全体を`Services`名前空間の下に配置したい場合はどうでしょうか？デフォルトの設定では、サブディレクトリ`app/services/services`を作成することでこれを実現できます。

ただし、好みによっては、`app/services/users/signup.rb`が単に`Services::Users::Signup`を定義することが望ましい場合もあります。

このような場合に対応するために、Zeitwerkは[カスタムルート名前空間](https://github.com/fxn/zeitwerk#custom-root-namespaces)をサポートしており、`main`オートローダーをカスタマイズすることでこれを実現できます：

```ruby
# config/initializers/autoloading.rb

# 名前空間は存在している必要があります。
#
# この例では、モジュールをその場で定義していますが、他の場所で作成され、通常の`require`でここに定義をロードすることもできます。
# いずれにせよ、`push_dir`はクラスまたはモジュールオブジェクトを期待します。
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails 7.1未満では、この機能はサポートされていませんが、同じファイルにこの追加のコードを追加して動作させることができます：

```ruby
# Rails 7.1未満のアプリケーションの追加コード。
app_services_dir = "#{Rails.root}/app/services" # 文字列である必要があります
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

カスタム名前空間は`once`オートローダーでもサポートされています。ただし、`once`オートローダーはブートプロセスの早い段階で設定されるため、アプリケーションイニシャライザーでは設定できません。代わりに、例えば`config/application.rb`に配置してください。

オートロードとエンジン
-----------------------

エンジンは親アプリケーションのコンテキストで実行され、そのコードは親アプリケーションによってオートロード、リロード、イーガーロードされます。アプリケーションが`zeitwerk`モードで実行されている場合、エンジンのコードは`zeitwerk`モードでロードされます。アプリケーションが`classic`モードで実行されている場合、エンジンのコードは`classic`モードでロードされます。

Railsが起動すると、エンジンディレクトリがオートロードパスに追加され、オートローダーの観点からは違いがありません。オートローダーの主な入力はオートロードパスであり、それがアプリケーションのソースツリーに属しているか、エンジンのソースツリーに属しているかは関係ありません。

例えば、このアプリケーションは[Devise](https://github.com/heartcombo/devise)を使用しています：

```
% bin/rails runner 'pp ActiveSupport::Dependencies.autoload_paths'
[".../app/controllers",
 ".../app/controllers/concerns",
 ".../app/helpers",
 ".../app/models",
 ".../app/models/concerns",
 ".../gems/devise-4.8.0/app/controllers",
 ".../gems/devise-4.8.0/app/helpers",
 ".../gems/devise-4.8.0/app/mailers"]
 ```

エンジンが親アプリケーションのオートロードモードを制御する場合、エンジンは通常どおりに記述できます。
ただし、エンジンがRails 6またはRails 6.1をサポートし、親アプリケーションを制御していない場合、`classic`モードまたは`zeitwerk`モードのいずれかで実行できるように準備する必要があります。考慮すべき事項は次のとおりです。

1. `classic`モードでは、ある時点で特定の定数がロードされることを保証するために`require_dependency`呼び出しを行う必要があります。`zeitwerk`モードでは必要ありませんが、`zeitwerk`モードでも動作するので問題ありません。

2. `classic`モードでは、定数名をアンダースコアで区切ります（"User" -> "user.rb"）、`zeitwerk`モードではファイル名をキャメルケースにします（"user.rb" -> "User"）。ほとんどの場合は一致しますが、"HTMLParser"のような連続する大文字の場合は一致しません。互換性を確保するためには、そのような名前を避けることです。この場合、"HtmlParser"を選択してください。

3. `classic`モードでは、ファイル`app/model/concerns/foo.rb`は`Foo`と`Concerns::Foo`の両方を定義することができます。`zeitwerk`モードでは、`Foo`を定義する必要があります。互換性を確保するためには、`Foo`を定義してください。

テスト
-------

### 手動テスト

タスク`zeitwerk:check`は、プロジェクトツリーが期待される命名規則に従っているかどうかをチェックし、手動でチェックするのに便利です。たとえば、`classic`モードから`zeitwerk`モードに移行する場合や、何か修正する場合などです。

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

アプリケーションの設定によっては、追加の出力がある場合がありますが、最後の「All is good!」が目的の出力です。

### 自動テスト

テストスイートでプロジェクトが正しくイーガーロードされることを確認するのは良い習慣です。

これにより、Zeitwerkの命名規則の遵守やその他のエラー条件を確認できます。[_Testing Rails Applications_](testing.html)ガイドの[イーガーローディングのテストに関するセクション](testing.html#testing-eager-loading)を確認してください。

トラブルシューティング
---------------------

ローダーの動作を追跡する最良の方法は、そのアクティビティを検査することです。

最も簡単な方法は、`config/application.rb`のフレームワークのデフォルトをロードした後に

```ruby
Rails.autoloaders.log!
```

を追加することです。これにより、トレースが標準出力に出力されます。

ファイルにログを出力する場合は、次のように設定してください。

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

`config/application.rb`が実行される時点では、Railsのロガーはまだ利用できません。Railsのロガーを使用する場合は、代わりに初期化子でこの設定を行ってください。

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

アプリケーションを管理するZeitwerkのインスタンスは、次の場所で利用できます。

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

述語

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

はRails 7アプリケーションでも利用可能であり、`true`を返します。
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
