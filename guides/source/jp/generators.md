**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
Railsジェネレータとテンプレートの作成とカスタマイズ
=====================================================

Railsジェネレータは、ワークフローを改善するための重要なツールです。このガイドでは、ジェネレータの作成と既存のジェネレータのカスタマイズ方法を学びます。

このガイドを読み終えると、以下のことがわかります。

* アプリケーションで利用可能なジェネレータを確認する方法。
* テンプレートを使用してジェネレータを作成する方法。
* Railsがジェネレータを呼び出す前にどのようにジェネレータを検索するか。
* ジェネレータのテンプレートをオーバーライドしてスキャフォールドをカスタマイズする方法。
* ジェネレータをオーバーライドしてスキャフォールドをカスタマイズする方法。
* 大量のジェネレータを上書きするのを避けるためのフォールバックの使用方法。
* アプリケーションテンプレートの作成方法。

--------------------------------------------------------------------------------

最初の接触
-------------

`rails`コマンドを使用してアプリケーションを作成すると、実際にはRailsジェネレータを使用しています。その後、`bin/rails generate`を呼び出すことで、利用可能なすべてのジェネレータのリストを取得できます。

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

注意：Railsアプリケーションを作成するには、`gem install rails`を使用してインストールされたRailsのバージョンを使用する`rails`グローバルコマンドを使用します。アプリケーションのディレクトリ内では、アプリケーションにバンドルされたRailsのバージョンを使用する`bin/rails`コマンドを使用します。

Railsに付属しているすべてのジェネレータのリストが表示されます。特定のジェネレータの詳細な説明を表示するには、`--help`オプションを指定してジェネレータを呼び出します。例：

```bash
$ bin/rails generate scaffold --help
```

最初のジェネレータの作成
-----------------------------

ジェネレータは、[Thor](https://github.com/rails/thor)の上に構築されており、パーシングのための強力なオプションとファイルの操作のための優れたAPIを提供しています。

`config/initializers`内に`initializer.rb`という名前の初期化ファイルを作成するジェネレータを作成しましょう。最初のステップは、`lib/generators/initializer_generator.rb`というファイルを作成し、以下の内容を記述することです。

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 初期化の内容をここに追加
    RUBY
  end
end
```

新しいジェネレータは非常にシンプルです。[`Rails::Generators::Base`][]を継承し、1つのメソッド定義を持っています。ジェネレータが呼び出されると、ジェネレータ内の各パブリックメソッドが定義された順序で順次実行されます。私たちのメソッドは[`create_file`][]を呼び出し、指定されたディレクトリに指定された内容でファイルを作成します。

新しいジェネレータを呼び出すには、次のコマンドを実行します。

```bash
$ bin/rails generate initializer
```

次に、新しいジェネレータの説明を確認しましょう。

```bash
$ bin/rails generate initializer --help
```

Railsは、`ActiveRecord::Generators::ModelGenerator`のようなジェネレータが名前空間である場合には、通常、良い説明を導出できますが、この場合はできません。この問題を解決する方法は2つあります。1つ目の方法は、ジェネレータ内で[`desc`][]を呼び出すことで説明を追加する方法です。

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers"
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 初期化の内容をここに追加
    RUBY
  end
end
```

これで、新しいジェネレータの説明を`--help`で確認できるようになりました。

2つ目の方法は、ジェネレータと同じディレクトリに`USAGE`という名前のファイルを作成することで説明を追加する方法です。次のステップでそれを行います。


ジェネレータを使用してジェネレータを作成する
-----------------------------------

ジェネレータ自体もジェネレータを持っています。`InitializerGenerator`を削除し、`bin/rails generate generator`を使用して新しいジェネレータを生成しましょう。

```bash
$ rm lib/generators/initializer_generator.rb

$ bin/rails generate generator initializer
      create  lib/generators/initializer
      create  lib/generators/initializer/initializer_generator.rb
      create  lib/generators/initializer/USAGE
      create  lib/generators/initializer/templates
      invoke  test_unit
      create    test/lib/generators/initializer_generator_test.rb
```

これが生成されたジェネレータです。

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

まず、ジェネレータが[`Rails::Generators::NamedBase`][]を継承していることに注意してください。これは、ジェネレータが少なくとも1つの引数を期待しており、それが初期化ファイルの名前であり、`name`を介してコードで利用できることを意味します。

新しいジェネレータの説明を確認することで、それを確認できます。

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

また、ジェネレータには[`source_root`][]というクラスメソッドがあります。このメソッドは、テンプレートの場所を指定します（あれば）。デフォルトでは、`lib/generators/initializer/templates`ディレクトリを指すようになっています。

ジェネレータのテンプレートの動作を理解するために、`lib/generators/initializer/templates/initializer.rb`というファイルを作成し、次の内容を記述しましょう。

```ruby
# 初期化の内容をここに追加
```

そして、ジェネレータが呼び出されたときにこのテンプレートをコピーするようにジェネレータを変更しましょう。
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

さあ、ジェネレータを実行しましょう：

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# 初期化の内容をここに追加してください
```

[`copy_file`][]がテンプレートの内容で`config/initializers/core_extensions.rb`を作成したことがわかります（宛先パスで使用される`file_name`メソッドは`Rails::Generators::NamedBase`から継承されます）。

ジェネレータのコマンドラインオプション
------------------------------

[`class_option`][]を使用して、ジェネレータはコマンドラインオプションをサポートできます。例えば：

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

これでジェネレータは`--scope`オプションを使用して呼び出すことができます：

```bash
$ bin/rails generate initializer theme --scope dashboard
```

オプションの値は、ジェネレータのメソッド内で[`options`][]を介してアクセスできます：

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


ジェネレータの解決
--------------------

ジェネレータの名前を解決する際、Railsは複数のファイル名を使用してジェネレータを探します。例えば、`bin/rails generate initializer core_extensions`を実行すると、Railsは以下のファイルを順番に読み込んでいき、最初に見つかったものを使用します：

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

これらのいずれも見つからない場合はエラーが発生します。

ジェネレータをアプリケーションの`lib/`ディレクトリに配置したのは、そのディレクトリが`$LOAD_PATH`に含まれているため、Railsがファイルを見つけて読み込むことができるからです。

Railsジェネレータのテンプレートのオーバーライド
----------------------------------------------

Railsは、ジェネレータのテンプレートファイルを解決する際に複数の場所を探します。そのうちの1つがアプリケーションの`lib/templates/`ディレクトリです。この動作により、Railsの組み込みジェネレータが使用するテンプレートをオーバーライドすることができます。例えば、[scaffold controller template][]や[scaffold view templates][]をオーバーライドすることができます。

これを実演するために、次の内容の`lib/templates/erb/scaffold/index.html.erb.tt`ファイルを作成しましょう：

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

テンプレートは、別のERBテンプレートをレンダリングするERBテンプレートです。したがって、_結果として_のテンプレートに表示される`<%`は、ジェネレータのテンプレートでは`<%%`とエスケープする必要があります。

それでは、Railsの組み込みのscaffoldジェネレータを実行してみましょう：

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

`app/views/posts/index.html.erb`の内容は次のとおりです：

```erb
<% @posts.count %> Posts
```

[scaffold controller template]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold view templates]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Railsジェネレータのオーバーライド
---------------------------

Railsの組み込みジェネレータは、[`config.generators`][]を使用して設定することができます。これには、一部のジェネレータを完全にオーバーライドすることも含まれます。

まず、scaffoldジェネレータの動作を詳しく見てみましょう。

```bash
$ bin/rails generate scaffold User name:string
      invoke  active_record
      create    db/migrate/20230518000000_create_users.rb
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
      invoke  resource_route
       route    resources :users
      invoke  scaffold_controller
      create    app/controllers/users_controller.rb
      invoke    erb
      create      app/views/users
      create      app/views/users/index.html.erb
      create      app/views/users/edit.html.erb
      create      app/views/users/show.html.erb
      create      app/views/users/new.html.erb
      create      app/views/users/_form.html.erb
      create      app/views/users/_user.html.erb
      invoke    resource_route
      invoke    test_unit
      create      test/controllers/users_controller_test.rb
      create      test/system/users_test.rb
      invoke    helper
      create      app/helpers/users_helper.rb
      invoke      test_unit
      invoke    jbuilder
      create      app/views/users/index.json.jbuilder
      create      app/views/users/show.json.jbuilder
```

出力からわかるように、scaffoldジェネレータは他のジェネレータを呼び出しています。例えば、`scaffold_controller`ジェネレータなどです。そして、それらのジェネレータの中にも他のジェネレータを呼び出すものがあります。特に、`scaffold_controller`ジェネレータは、`helper`ジェネレータを含むいくつかの他のジェネレータを呼び出します。

組み込みの`helper`ジェネレータを新しいジェネレータでオーバーライドしてみましょう。ジェネレータの名前を`my_helper`とします：

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

そして、`lib/generators/rails/my_helper/my_helper_generator.rb`に以下のようにジェネレータを定義します：

```ruby
class Rails::MyHelperGenerator < Rails::Generators::NamedBase
  def create_helper_file
    create_file "app/helpers/#{file_name}_helper.rb", <<~RUBY
      module #{class_name}Helper
        # I'm helping!
      end
    RUBY
  end
end
```

最後に、組み込みの`helper`ジェネレータの代わりに`my_helper`ジェネレータを使用するようにRailsに指示する必要があります。そのためには、`config.generators`を使用します。`config/application.rb`に以下を追加しましょう：

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

これで、scaffoldジェネレータを再度実行すると、`my_helper`ジェネレータが動作することがわかります：

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

注意：組み込みの`helper`ジェネレータの出力には「invoke test_unit」という記述が含まれていることに気付くかもしれませんが、`my_helper`の出力には含まれていません。`helper`ジェネレータはデフォルトではテストを生成しませんが、[`hook_for`][]を使用してテストを生成するフックを提供しています。同様に、`MyHelperGenerator`クラスに`hook_for :test_framework, as: :helper`を含めることで、同じことを行うことができます。詳細については、`hook_for`のドキュメントを参照してください。


### ジェネレータのフォールバック

特定のジェネレータをオーバーライドする別の方法として、_フォールバック_を使用する方法があります。フォールバックを使用すると、ジェネレータの名前空間が別のジェネレータの名前空間に委譲することができます。
例えば、`test_unit:model` ジェネレータを `my_test_unit:model` ジェネレータで上書きしたい場合を考えましょう。ただし、`test_unit:controller` のような他の `test_unit:*` ジェネレータはすべて置き換えたくありません。

まず、`lib/generators/my_test_unit/model/model_generator.rb` に `my_test_unit:model` ジェネレータを作成します。

```ruby
module MyTestUnit
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def do_different_stuff
      say "Doing different stuff..."
    end
  end
end
```

次に、`config.generators` を使用して `test_framework` ジェネレータを `my_test_unit` として設定しますが、`my_test_unit:*` ジェネレータが見つからない場合は `test_unit:*` にフォールバックするように設定します。

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

これで、スキャフォールドジェネレータを実行すると、`my_test_unit` が `test_unit` の代わりに使用されますが、モデルテストのみが影響を受けます。

```bash
$ bin/rails generate scaffold Comment body:text
      invoke  active_record
      create    db/migrate/20230518000000_create_comments.rb
      create    app/models/comment.rb
      invoke    my_test_unit
    Doing different stuff...
      invoke  resource_route
       route    resources :comments
      invoke  scaffold_controller
      create    app/controllers/comments_controller.rb
      invoke    erb
      create      app/views/comments
      create      app/views/comments/index.html.erb
      create      app/views/comments/edit.html.erb
      create      app/views/comments/show.html.erb
      create      app/views/comments/new.html.erb
      create      app/views/comments/_form.html.erb
      create      app/views/comments/_comment.html.erb
      invoke    resource_route
      invoke    my_test_unit
      create      test/controllers/comments_controller_test.rb
      create      test/system/comments_test.rb
      invoke    helper
      create      app/helpers/comments_helper.rb
      invoke      my_test_unit
      invoke    jbuilder
      create      app/views/comments/index.json.jbuilder
      create      app/views/comments/show.json.jbuilder
```

アプリケーションテンプレート
---------------------------

アプリケーションテンプレートは特別な種類のジェネレータです。これらはすべての[ジェネレータヘルパーメソッド](#generator-helper-methods)を使用できますが、RubyクラスではなくRubyスクリプトとして書かれます。以下に例を示します。

```ruby
# template.rb

if yes?("Would you like to install Devise?")
  gem "devise"
  devise_model = ask("What would you like the user model to be called?", default: "User")
end

after_bundle do
  if devise_model
    generate "devise:install"
    generate "devise", devise_model
    rails_command "db:migrate"
  end

  git add: ".", commit: %(-m 'Initial commit')
end
```

まず、テンプレートはユーザーに Devise をインストールするかどうか尋ねます。ユーザーが「はい」（または「y」）と回答すると、テンプレートは `Gemfile` に Devise を追加し、Deviseユーザーモデルの名前をユーザーに尋ねます（デフォルトは `User`）。その後、`bundle install` が実行された後、テンプレートはDeviseジェネレータと `rails db:migrate` を実行します。最後に、テンプレートはアプリケーションディレクトリ全体を `git add` および `git commit` します。

新しいRailsアプリケーションを生成する際に、`rails new` コマンドに `-m` オプションを渡すことで、テンプレートを実行できます。

```bash
$ rails new my_cool_app -m path/to/template.rb
```

または、既存のアプリケーション内で `bin/rails app:template` を使用してテンプレートを実行できます。

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

テンプレートはローカルに保存する必要はありません。パスの代わりにURLを指定することもできます。

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

ジェネレータヘルパーメソッド
--------------------------

Thorは、[`Thor::Actions`]を介して多くのジェネレータヘルパーメソッドを提供しています。以下にいくつかの例を示します。

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

さらに、Railsは[`Rails::Generators::Actions`]を介して多くのヘルパーメソッドを提供しています。

* [`environment`][]
* [`gem`][]
* [`generate`][]
* [`git`][]
* [`initializer`][]
* [`lib`][]
* [`rails_command`][]
* [`rake`][]
* [`route`][]
[`Rails::Generators::Base`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html
[`Thor::Actions`]: https://www.rubydoc.info/gems/thor/Thor/Actions
[`create_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#create_file-instance_method
[`desc`]: https://www.rubydoc.info/gems/thor/Thor#desc-class_method
[`Rails::Generators::NamedBase`]: https://api.rubyonrails.org/classes/Rails/Generators/NamedBase.html
[`copy_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#copy_file-instance_method
[`source_root`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-source_root
[`class_option`]: https://www.rubydoc.info/gems/thor/Thor/Base/ClassMethods#class_option-instance_method
[`options`]: https://www.rubydoc.info/gems/thor/Thor/Base#options-instance_method
[`config.generators`]: configuring.html#configuring-generators
[`hook_for`]: https://api.rubyonrails.org/classes/Rails/Generators/Base.html#method-c-hook_for
[`Rails::Generators::Actions`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html
[`environment`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-environment
[`gem`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-gem
[`generate`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-generate
[`git`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-git
[`gsub_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#gsub_file-instance_method
[`initializer`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-initializer
[`insert_into_file`]: https://www.rubydoc.info/gems/thor/Thor/Actions#insert_into_file-instance_method
[`inside`]: https://www.rubydoc.info/gems/thor/Thor/Actions#inside-instance_method
[`lib`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-lib
[`rails_command`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rails_command
[`rake`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-rake
[`route`]: https://api.rubyonrails.org/classes/Rails/Generators/Actions.html#method-i-route
