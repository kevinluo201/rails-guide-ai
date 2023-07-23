**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Rails應用程式模板
=================

應用程式模板是包含DSL的簡單Ruby檔案，用於將gem、初始化程式等添加到新建的Rails專案或現有的Rails專案中。

閱讀本指南後，您將了解：

* 如何使用模板生成/自定義Rails應用程式。
* 如何使用Rails模板API編寫自己的可重複使用的應用程式模板。

--------------------------------------------------------------------------------

使用方法
-----

要應用模板，您需要使用`-m`選項向Rails生成器提供要應用的模板的位置。這可以是文件的路徑或URL。

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

您可以使用`app:template` rails命令將模板應用於現有的Rails應用程式。模板的位置需要通過LOCATION環境變量傳遞。同樣，這可以是文件的路徑或URL。

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

模板API
------------

Rails模板API易於理解。以下是一個典型Rails模板的示例：

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

以下各節概述了API提供的主要方法：

### gem(*args)

將提供的gem添加到生成的應用程式的Gemfile中。

例如，如果您的應用程式依賴於gem `bj`和`nokogiri`：

```ruby
gem "bj"
gem "nokogiri"
```

請注意，此方法僅將gem添加到Gemfile中，並不安裝gem。

### gem_group(*names, &block)

在組內包裝gem條目。

例如，如果您只想在`development`和`test`組中加載`rspec-rails`：

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

將給定的源添加到生成的應用程式的Gemfile中。

例如，如果您需要從`"http://gems.github.com"`源引用gem：

```ruby
add_source "http://gems.github.com"
```

如果給定了block，則將block中的gem條目包裝到源組中。

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

在`config/application.rb`中的`Application`類中添加一行。

如果指定了`options[:env]`，則將該行附加到`config/environments`中的相應文件中。

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

可以使用block代替`data`參數。

### vendor/lib/file/initializer(filename, data = nil, &block)

將初始化程式添加到生成的應用程式的`config/initializers`目錄中。

假設您喜歡使用`Object#not_nil?`和`Object#not_blank?`：

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

同樣，`lib()`在`lib/`目錄中創建一個文件，`vendor()`在`vendor/`目錄中創建一個文件。

甚至還有`file()`，它接受從`Rails.root`的相對路徑並創建所需的所有目錄/文件：

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

這將創建`app/components`目錄並將`foo.rb`放在其中。

### rakefile(filename, data = nil, &block)

使用提供的任務在`lib/tasks`下創建新的rake文件：

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

以上代碼將創建具有`boot:strap` rake任務的`lib/tasks/bootstrap.rake`文件。

### generate(what, *args)

使用給定的參數運行提供的rails生成器。

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

執行任意命令。就像反引號一樣。假設您想刪除`README.rdoc`文件：

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

在Rails應用程式中運行提供的命令。假設您想遷移數據庫：

```ruby
rails_command "db:migrate"
```

您還可以使用不同的Rails環境運行命令：

```ruby
rails_command "db:migrate", env: 'production'
```

您還可以以超級用戶身份運行命令：

```ruby
rails_command "log:clear", sudo: true
```

您還可以運行應用程式生成失敗時應中止的命令：

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

將路由條目添加到`config/routes.rb`文件中。在上面的步驟中，我們生成了一個人的脊柱並刪除了`README.rdoc`。現在，要將`PeopleController#index`設為應用程式的默認頁面：

```ruby
route "root to: 'person#index'"
```

### inside(dir)

允許您從給定的目錄運行命令。例如，如果您有一個您希望從新應用程式中建立符號鏈接的edge rails副本，您可以這樣做：
```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()` 讓你有機會從使用者那裡獲得一些回饋並在模板中使用它。假設你想讓使用者為你正在新增的新奇函式庫命名：

```ruby
lib_name = ask("你想要把這個新奇函式庫叫做什麼？")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) 或 no?(question)

這些方法讓你可以在模板中提問並根據使用者的回答來決定流程。假設你想要提示使用者執行資料庫遷移：

```ruby
rails_command("db:migrate") if yes?("執行資料庫遷移？")
# no?(question) 則相反。
```

### git(:command)

Rails 模板讓你執行任何 git 命令：

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### after_bundle(&block)

註冊一個回調函式，在 gems 安裝完畢並生成 binstubs 後執行。這對於將生成的檔案添加到版本控制非常有用：

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
```

即使傳遞了 `--skip-bundle`，回調函式仍會被執行。

進階用法
--------------

應用程式模板在 `Rails::Generators::AppGenerator` 實例的上下文中進行評估。它使用 Thor 提供的 [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) 動作。

這意味著你可以擴展和更改實例以符合你的需求。

例如，你可以覆寫 `source_paths` 方法以包含你的模板位置。現在像 `copy_file` 這樣的方法將接受相對於你的模板位置的路徑。

```ruby
def source_paths
  [__dir__]
end
```
