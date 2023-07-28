**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
Rails应用模板
===========================

应用模板是简单的Ruby文件，包含DSL，用于向新创建的Rails项目或现有的Rails项目添加gems、初始化器等。

阅读本指南后，您将了解以下内容：

* 如何使用模板生成/定制Rails应用程序。
* 如何使用Rails模板API编写自己的可重用应用程序模板。

--------------------------------------------------------------------------------

用法
-----

要应用模板，您需要使用`-m`选项为Rails生成器提供要应用的模板的位置。这可以是文件的路径或URL。

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

您可以使用`app:template` rails命令将模板应用于现有的Rails应用程序。模板的位置需要通过LOCATION环境变量传递。同样，这可以是文件的路径或URL。

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

模板API
------------

Rails模板API易于理解。以下是典型Rails模板的示例：

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

以下部分概述了API提供的主要方法：

### gem(*args)

向生成的应用程序的`Gemfile`添加所提供的gem的`gem`条目。

例如，如果您的应用程序依赖于`bj`和`nokogiri`这两个gems：

```ruby
gem "bj"
gem "nokogiri"
```

请注意，此方法只会将gem添加到`Gemfile`中，而不会安装gem。

### gem_group(*names, &block)

将gem条目包装在一个组中。

例如，如果您只想在`development`和`test`组中加载`rspec-rails`：

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

将给定的源添加到生成的应用程序的`Gemfile`中。

例如，如果您需要从`"http://gems.github.com"`源引用一个gem：

```ruby
add_source "http://gems.github.com"
```

如果给定了block，则block中的gem条目将被包装到源组中。

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

向`config/application.rb`中的`Application`类添加一行。

如果指定了`options[:env]`，则该行将附加到`config/environments`中的相应文件中。

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

可以使用block代替`data`参数。

### vendor/lib/file/initializer(filename, data = nil, &block)

将初始化器添加到生成的应用程序的`config/initializers`目录中。

假设您喜欢使用`Object#not_nil?`和`Object#not_blank?`：

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

类似地，`lib()`在`lib/`目录中创建一个文件，`vendor()`在`vendor/`目录中创建一个文件。

甚至还有`file()`，它接受一个相对于`Rails.root`的路径，并创建所需的所有目录/文件：

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

这将创建`app/components`目录并将`foo.rb`放在其中。

### rakefile(filename, data = nil, &block)

在`lib/tasks`下创建一个新的rake文件，并提供所需的任务：

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

上面的代码将创建`lib/tasks/bootstrap.rake`，其中包含一个`boot:strap` rake任务。

### generate(what, *args)

使用给定的参数运行所提供的rails生成器。

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

执行任意命令。就像反引号一样。假设您想要删除`README.rdoc`文件：

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

在Rails应用程序中运行所提供的命令。假设您想要迁移数据库：

```ruby
rails_command "db:migrate"
```

您还可以在不同的Rails环境中运行命令：

```ruby
rails_command "db:migrate", env: 'production'
```

您还可以以超级用户身份运行命令：

```ruby
rails_command "log:clear", sudo: true
```

您还可以运行在失败时应中止应用程序生成的命令：

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

向`config/routes.rb`文件添加路由条目。在上面的步骤中，我们生成了一个person脚手架，并删除了`README.rdoc`。现在，要将`PeopleController#index`设置为应用程序的默认页面：

```ruby
route "root to: 'person#index'"
```

### inside(dir)

允许您从给定的目录运行命令。例如，如果您有一个edge rails的副本，希望从新应用程序中创建符号链接，可以这样做：
```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()`方法可以让您有机会从用户那里获取一些反馈，并在模板中使用它。假设您希望用户为您正在添加的新库命名：

```ruby
lib_name = ask("您想如何命名这个新库？")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) or no?(question)

这些方法允许您在模板中提问，并根据用户的答案决定流程。假设您想提示用户运行数据库迁移：

```ruby
rails_command("db:migrate") if yes?("是否运行数据库迁移？")
# no?(question)则相反。
```

### git(:command)

Rails模板允许您运行任何git命令：

```ruby
git :init
git add: "."
git commit: "-a -m 'Initial commit'"
```

### after_bundle(&block)

注册一个回调，在gems被捆绑和binstubs生成后执行。用于将生成的文件添加到版本控制：

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
```

即使传递了`--skip-bundle`，回调也会被执行。

高级用法
--------------

应用程序模板在`Rails::Generators::AppGenerator`实例的上下文中进行评估。它使用Thor提供的[`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method)操作。

这意味着您可以扩展和更改实例以满足您的需求。

例如，通过重写`source_paths`方法以包含模板的位置。现在，`copy_file`等方法将接受相对于模板位置的路径。

```ruby
def source_paths
  [__dir__]
end
```
