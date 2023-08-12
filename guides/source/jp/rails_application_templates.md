**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Railsアプリケーションテンプレート
===========================

アプリケーションテンプレートは、新しく作成されたRailsプロジェクトまたは既存のRailsプロジェクトにgem、初期化子などを追加するためのDSLを含むシンプルなRubyファイルです。

このガイドを読み終えると、次のことがわかります。

* テンプレートを使用してRailsアプリケーションを生成/カスタマイズする方法。
* RailsテンプレートAPIを使用して独自の再利用可能なアプリケーションテンプレートを作成する方法。

--------------------------------------------------------------------------------

使用法
-----

テンプレートを適用するには、Railsジェネレータに適用するテンプレートの場所を`-m`オプションで指定する必要があります。これはファイルのパスまたはURLのいずれかであることができます。

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

`app:template` Railsコマンドを使用して既存のRailsアプリケーションにテンプレートを適用することもできます。テンプレートの場所は、LOCATION環境変数を介して渡す必要があります。これもファイルのパスまたはURLのいずれかであることができます。

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

テンプレートAPI
------------

RailsテンプレートAPIは理解しやすいです。以下は典型的なRailsテンプレートの例です。

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rails_command("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

以下のセクションでは、APIが提供する主要なメソッドについて説明します。

### gem(*args)

生成されたアプリケーションの`Gemfile`に指定されたgemの`gem`エントリを追加します。

たとえば、アプリケーションが`bj`と`nokogiri`のgemに依存している場合：

```ruby
gem "bj"
gem "nokogiri"
```

このメソッドは`Gemfile`にgemを追加するだけで、gemをインストールしません。

### gem_group(*names, &block)

グループ内のgemエントリをラップします。

たとえば、`rspec-rails`を`development`と`test`グループのみでロードしたい場合：

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

指定されたソースを生成されたアプリケーションの`Gemfile`に追加します。

たとえば、gemを`"http://gems.github.com"`からソースする必要がある場合：

```ruby
add_source "http://gems.github.com"
```

ブロックが指定されている場合、ブロック内のgemエントリはソースグループにラップされます。

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

`config/application.rb`の`Application`クラス内に行を追加します。

`options[:env]`が指定されている場合、行は`config/environments`の対応するファイルに追加されます。

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

ブロックは`data`引数の代わりに使用できます。

### vendor/lib/file/initializer(filename, data = nil, &block)

生成されたアプリケーションの`config/initializers`ディレクトリに初期化子を追加します。

`Object#not_nil?`と`Object#not_blank?`を使用するのが好きな場合：

```ruby
initializer 'bloatlol.rb', <<-CODE
  class Object
    def not_nil?
      !nil?
    end

    def not_blank?
      !blank?
    end
  end
CODE
```

同様に、`lib()`は`lib/`ディレクトリにファイルを作成し、`vendor()`は`vendor/`ディレクトリにファイルを作成します。

`file()`もあります。これは`Rails.root`からの相対パスを受け入れ、必要なすべてのディレクトリ/ファイルを作成します。

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

これにより、`app/components`ディレクトリが作成され、その中に`foo.rb`が配置されます。

### rakefile(filename, data = nil, &block)

指定されたタスクで`lib/tasks`の下に新しいrakeファイルを作成します。

```ruby
rakefile("bootstrap.rake") do
  <<-TASK
    namespace :boot do
      task :strap do
        puts "i like boots!"
      end
    end
  TASK
end
```

上記のコードは、`boot:strap`のrakeタスクを持つ`lib/tasks/bootstrap.rake`を作成します。

### generate(what, *args)

指定されたrailsジェネレータを指定された引数で実行します。

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

任意のコマンドを実行します。バッククォートと同様です。たとえば、`README.rdoc`ファイルを削除したい場合：

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

Railsアプリケーションで指定されたコマンドを実行します。たとえば、データベースをマイグレーションしたい場合：

```ruby
rails_command "db:migrate"
```

別のRails環境でコマンドを実行することもできます。

```ruby
rails_command "db:migrate", env: 'production'
```

スーパーユーザとしてコマンドを実行することもできます。

```ruby
rails_command "log:clear", sudo: true
```

コマンドが失敗した場合にアプリケーションの生成を中止するコマンドも実行できます。

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

`config/routes.rb`ファイルにルーティングエントリを追加します。上記の手順では、personスキャフォールドを生成し、`README.rdoc`を削除しました。次に、`PeopleController#index`をアプリケーションのデフォルトページにするために：

```ruby
route "root to: 'person#index'"
```

### inside(dir)

指定されたディレクトリからコマンドを実行できるようにします。たとえば、新しいアプリケーションからシンボリックリンクを作成したい場合、edge railsのコピーがある場合は、次のようにします：
```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()`はユーザーからフィードバックを受け取り、テンプレートで使用するための機会を提供します。例えば、新しい素晴らしいライブラリの名前をユーザーに指定してもらいたい場合は次のようにします。

```ruby
lib_name = ask("新しい素晴らしいライブラリの名前を入力してください")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question)またはno?(question)

これらのメソッドを使用すると、テンプレートから質問をすることができ、ユーザーの回答に基づいてフローを決定することができます。例えば、ユーザーにマイグレーションを実行するかどうか尋ねたい場合は次のようにします。

```ruby
rails_command("db:migrate") if yes?("データベースのマイグレーションを実行しますか？")
# no?(question)は逆の動作をします。
```

### git(:command)

Railsテンプレートでは任意のgitコマンドを実行することができます。

```ruby
git :init
git add: "."
git commit: "-a -m '初回コミット'"
```

### after_bundle(&block)

gemsがバンドルされ、binstubが生成された後に実行されるコールバックを登録します。生成されたファイルをバージョン管理に追加するのに便利です。

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m '初回コミット'"
end
```

このコールバックは、`--skip-bundle`が渡された場合でも実行されます。

高度な使用法
--------------

アプリケーションテンプレートは`Rails::Generators::AppGenerator`インスタンスのコンテキストで評価されます。これはThorが提供する[`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method)アクションを使用しています。

これは、インスタンスを拡張および変更して、自分のニーズに合わせることができることを意味します。

例えば、`source_paths`メソッドを上書きしてテンプレートの場所を含めるようにすることができます。これにより、`copy_file`などのメソッドはテンプレートの場所に対する相対パスを受け入れるようになります。

```ruby
def source_paths
  [__dir__]
end
```
