**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0651830a9dc9cbd4e8a1fddab047c719
레일즈 생성기 및 템플릿 생성 및 사용자 정의하기
=====================================================

레일즈 생성기는 워크플로우를 개선하는 데 필수적인 도구입니다. 이 가이드를 통해 생성기를 만들고 기존 생성기를 사용자 정의하는 방법을 배울 수 있습니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 응용 프로그램에서 사용 가능한 생성기를 확인하는 방법.
* 템플릿을 사용하여 생성기를 만드는 방법.
* 레일즈가 생성기를 호출하기 전에 생성기를 검색하는 방법.
* 생성기 템플릿을 재정의하여 스캐폴드를 사용자 정의하는 방법.
* 생성기를 재정의하여 스캐폴드를 사용자 정의하는 방법.
* 대량의 생성기를 덮어쓰지 않도록 대체 방법을 사용하는 방법.
* 응용 프로그램 템플릿을 만드는 방법.

--------------------------------------------------------------------------------

첫 번째 접촉
-------------

`rails` 명령을 사용하여 응용 프로그램을 생성할 때 실제로는 레일즈 생성기를 사용합니다. 그 후에 `bin/rails generate`를 호출하여 사용 가능한 모든 생성기의 목록을 얻을 수 있습니다:

```bash
$ rails new myapp
$ cd myapp
$ bin/rails generate
```

참고: 레일즈 응용 프로그램을 생성하기 위해 `rails` 글로벌 명령을 사용하며, 이는 `gem install rails`를 통해 설치된 레일즈 버전을 사용합니다. 응용 프로그램 디렉토리 내부에 있는 경우 `bin/rails` 명령을 사용하며, 이는 응용 프로그램과 번들된 레일즈 버전을 사용합니다.

레일즈와 함께 제공되는 모든 생성기의 목록을 얻게 됩니다. 특정 생성기의 자세한 설명을 보려면 `--help` 옵션을 사용하여 생성기를 호출하면 됩니다. 예를 들어:

```bash
$ bin/rails generate scaffold --help
```

첫 번째 생성기 만들기
-------------------

생성기는 [Thor](https://github.com/rails/thor) 위에 구축되어 있으며, 구문 분석을 위한 강력한 옵션과 파일 조작을 위한 훌륭한 API를 제공합니다.

`config/initializers` 내부에 `initializer.rb`라는 초기화 파일을 생성하는 생성기를 만들어 보겠습니다. 첫 번째 단계는 다음 내용으로 `lib/generators/initializer_generator.rb`에 파일을 생성하는 것입니다:

```ruby
class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 초기화 내용을 여기에 추가하세요
    RUBY
  end
end
```

새로운 생성기는 [`Rails::Generators::Base`][]를 상속받고 하나의 메소드 정의를 가지고 있습니다. 생성기가 호출될 때, 생성기 내의 각 공개 메소드는 정의된 순서대로 순차적으로 실행됩니다. 우리의 메소드는 [`create_file`][]을 호출하며, 주어진 대상과 내용으로 파일을 생성합니다.

새로운 생성기를 호출하기 위해 다음을 실행합니다:

```bash
$ bin/rails generate initializer
```

계속하기 전에 새로운 생성기의 설명을 확인해 보겠습니다:

```bash
$ bin/rails generate initializer --help
```

레일즈는 `ActiveRecord::Generators::ModelGenerator`와 같이 네임스페이스가 있는 생성기의 경우 일반적으로 좋은 설명을 유도할 수 있지만, 이 경우에는 그렇지 않습니다. 이 문제를 해결하는 두 가지 방법이 있습니다. 첫 번째 방법은 생성기 내에서 [`desc`][]를 호출하여 설명을 추가하는 것입니다:

```ruby
class InitializerGenerator < Rails::Generators::Base
  desc "이 생성기는 config/initializers에 초기화 파일을 생성합니다."
  def create_initializer_file
    create_file "config/initializers/initializer.rb", <<~RUBY
      # 초기화 내용을 여기에 추가하세요
    RUBY
  end
end
```

이제 새로운 생성기에 `--help`를 호출하여 새 설명을 볼 수 있습니다.

두 번째 방법은 생성기와 동일한 디렉토리에 `USAGE`라는 파일을 생성하는 것입니다. 다음 단계에서 이를 수행하겠습니다.


생성기로 생성기 생성하기
-----------------------

생성기 자체도 생성기를 가지고 있습니다. `InitializerGenerator`를 제거하고 `bin/rails generate generator`를 사용하여 새로운 생성기를 생성해 보겠습니다:

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

방금 생성된 생성기는 다음과 같습니다:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
end
```

먼저, 생성기가 `Rails::Generators::Base` 대신 [`Rails::Generators::NamedBase`][]를 상속받는 것을 알아봅시다. 이는 생성기가 적어도 하나의 인수를 기대하며, 이는 초기화 파일의 이름이 될 것이며 `name`을 통해 코드에서 사용할 수 있습니다.

새로운 생성기의 설명을 확인하여 이를 확인할 수 있습니다:

```bash
$ bin/rails generate initializer --help
Usage:
  bin/rails generate initializer NAME [options]
```

또한, 생성기에는 [`source_root`][]라는 클래스 메소드가 있습니다. 이 메소드는 템플릿의 위치를 가리키며, 필요한 경우 기본적으로 방금 생성된 `lib/generators/initializer/templates` 디렉토리를 가리킵니다.

생성기 템플릿이 작동하는 방법을 이해하기 위해 다음 내용으로 `lib/generators/initializer/templates/initializer.rb` 파일을 생성해 보겠습니다:

```ruby
# 초기화 내용을 여기에 추가하세요
```

그리고 생성기를 호출할 때 이 템플릿을 복사하도록 생성기를 변경해 보겠습니다:
```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end
end
```

이제 우리의 제너레이터를 실행해 봅시다:

```bash
$ bin/rails generate initializer core_extensions
      create  config/initializers/core_extensions.rb

$ cat config/initializers/core_extensions.rb
# Add initialization content here
```

[`copy_file`][]이 우리의 템플릿 내용으로 `config/initializers/core_extensions.rb`를 생성한 것을 볼 수 있습니다. (목적지 경로에 사용된 `file_name` 메소드는 `Rails::Generators::NamedBase`에서 상속되었습니다.)


제너레이터 커맨드 라인 옵션
------------------------------

[`class_option`][]을 사용하여 제너레이터가 커맨드 라인 옵션을 지원할 수 있습니다. 예를 들어:

```ruby
class InitializerGenerator < Rails::Generators::NamedBase
  class_option :scope, type: :string, default: "app"
end
```

이제 우리의 제너레이터는 `--scope` 옵션과 함께 호출될 수 있습니다:

```bash
$ bin/rails generate initializer theme --scope dashboard
```

옵션 값은 [`options`][]를 통해 제너레이터 메소드에서 접근할 수 있습니다:

```ruby
def copy_initializer_file
  @scope = options["scope"]
end
```


제너레이터 해결
--------------------

제너레이터 이름을 해결할 때, Rails는 여러 파일 이름을 사용하여 제너레이터를 찾습니다. 예를 들어, `bin/rails generate initializer core_extensions`를 실행할 때, Rails는 다음 파일들을 순서대로 로드하려고 시도합니다:

* `rails/generators/initializer/initializer_generator.rb`
* `generators/initializer/initializer_generator.rb`
* `rails/generators/initializer_generator.rb`
* `generators/initializer_generator.rb`

이 중 어느 것도 찾을 수 없으면 오류가 발생합니다.

우리는 제너레이터를 애플리케이션의 `lib/` 디렉토리에 넣었는데, 이 디렉토리는 `$LOAD_PATH`에 포함되어 있기 때문에 Rails가 파일을 찾아서 로드할 수 있습니다.

Rails 제너레이터 템플릿 재정의
------------------------------------

Rails는 제너레이터 템플릿 파일을 찾을 때 여러 곳을 찾습니다. 그 중 하나는 애플리케이션의 `lib/templates/` 디렉토리입니다. 이 동작은 Rails의 내장 제너레이터에서 사용하는 템플릿을 재정의할 수 있도록 해줍니다. 예를 들어, [scaffold controller template][]이나 [scaffold view templates][]을 재정의할 수 있습니다.

이를 확인하기 위해, 다음 내용을 포함하는 `lib/templates/erb/scaffold/index.html.erb.tt` 파일을 생성해 봅시다:

```erb
<%% @<%= plural_table_name %>.count %> <%= human_name.pluralize %>
```

템플릿은 _다른_ ERB 템플릿을 렌더링하는 ERB 템플릿입니다. 따라서 _결과적으로_ 템플릿에 나타나야 하는 `<%`는 _제너레이터_ 템플릿에서 `<%%`로 이스케이프해야 합니다.

이제 Rails의 내장 scaffold 제너레이터를 실행해 봅시다:

```bash
$ bin/rails generate scaffold Post title:string
      ...
      create      app/views/posts/index.html.erb
      ...
```

`app/views/posts/index.html.erb`의 내용은 다음과 같습니다:

```erb
<% @posts.count %> Posts
```

[scaffold controller template]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/scaffold_controller/templates/controller.rb.tt
[scaffold view templates]: https://github.com/rails/rails/tree/main/railties/lib/rails/generators/erb/scaffold/templates

Rails 제너레이터 재정의
---------------------------

Rails의 내장 제너레이터는 [`config.generators`][]를 통해 구성할 수 있으며, 일부 제너레이터를 완전히 재정의할 수도 있습니다.

먼저, scaffold 제너레이터가 작동하는 방식을 자세히 살펴보겠습니다.

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

출력에서 볼 수 있듯이, scaffold 제너레이터는 `scaffold_controller` 제너레이터와 같은 다른 제너레이터를 호출합니다. 그리고 그 중 일부 제너레이터도 다른 제너레이터를 호출합니다. 특히, `scaffold_controller` 제너레이터는 `helper` 제너레이터를 포함하여 여러 제너레이터를 호출합니다.

내장 `helper` 제너레이터를 새 제너레이터로 재정의해 보겠습니다. 제너레이터의 이름을 `my_helper`로 지정하겠습니다:

```bash
$ bin/rails generate generator rails/my_helper
      create  lib/generators/rails/my_helper
      create  lib/generators/rails/my_helper/my_helper_generator.rb
      create  lib/generators/rails/my_helper/USAGE
      create  lib/generators/rails/my_helper/templates
      invoke  test_unit
      create    test/lib/generators/rails/my_helper_generator_test.rb
```

그리고 `lib/generators/rails/my_helper/my_helper_generator.rb`에 다음과 같이 제너레이터를 정의하겠습니다:

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

마지막으로, Rails가 내장 `helper` 제너레이터 대신 `my_helper` 제너레이터를 사용하도록 알려주어야 합니다. 이를 위해 `config.generators`를 사용합니다. `config/application.rb`에 다음을 추가해 보겠습니다:

```ruby
config.generators do |g|
  g.helper :my_helper
end
```

이제 scaffold 제너레이터를 다시 실행하면 `my_helper` 제너레이터가 동작하는 것을 확인할 수 있습니다:

```bash
$ bin/rails generate scaffold Article body:text
      ...
      invoke  scaffold_controller
      ...
      invoke    my_helper
      create      app/helpers/articles_helper.rb
      ...
```

참고: 내장 `helper` 제너레이터의 출력에는 "invoke test_unit"이 포함되어 있지만, `my_helper`의 출력에는 포함되어 있지 않습니다. `helper` 제너레이터는 기본적으로 테스트를 생성하지 않지만, [`hook_for`][]를 사용하여 테스트를 생성할 수 있는 후크를 제공합니다. 우리는 `MyHelperGenerator` 클래스에 `hook_for :test_framework, as: :helper`를 포함시켜 동일한 작업을 수행할 수 있습니다. 자세한 내용은 `hook_for` 문서를 참조하십시오.


### 제너레이터 폴백

특정 제너레이터를 재정의하는 또 다른 방법은 _폴백_을 사용하는 것입니다. 폴백은 제너레이터 네임스페이스가 다른 제너레이터 네임스페이스로 위임할 수 있도록 해줍니다.
예를 들어, `test_unit:model` 생성기를 우리 자신의 `my_test_unit:model` 생성기로 오버라이드하고 싶지만 `test_unit:controller`와 같은 다른 `test_unit:*` 생성기를 모두 대체하고 싶지 않은 경우를 가정해 봅시다.

먼저, `lib/generators/my_test_unit/model/model_generator.rb`에 `my_test_unit:model` 생성기를 생성합니다.

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

다음으로, `config.generators`를 사용하여 `test_framework` 생성기를 `my_test_unit`로 구성하고, `my_test_unit:*` 생성기가 없는 경우 `test_unit:*`로 해결되도록 대체를 구성합니다.

```ruby
config.generators do |g|
  g.test_framework :my_test_unit, fixture: false
  g.fallbacks[:my_test_unit] = :test_unit
end
```

이제 스캐폴드 생성기를 실행하면 `my_test_unit`가 `test_unit`을 대체하지만 모델 테스트만 영향을 받은 것을 볼 수 있습니다.

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

응용 프로그램 템플릿
---------------------

응용 프로그램 템플릿은 특별한 종류의 생성기입니다. 이들은 [생성기 도우미 메서드](#generator-helper-methods)를 모두 사용할 수 있지만, Ruby 클래스 대신 Ruby 스크립트로 작성됩니다. 다음은 예입니다.

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

먼저, 템플릿은 사용자에게 Devise를 설치할지 여부를 묻습니다. 사용자가 "yes" (또는 "y")로 응답하면, 템플릿은 `Gemfile`에 Devise를 추가하고 Devise 사용자 모델의 이름을 사용자에게 묻습니다 (기본값은 `User`입니다). 나중에 `bundle install`이 실행된 후, 템플릿은 Devise 생성기와 `rails db:migrate`를 실행합니다. 마지막으로, 템플릿은 전체 앱 디렉토리를 `git add`하고 `git commit`합니다.

새로운 Rails 애플리케이션을 생성할 때 템플릿을 실행하려면 `rails new` 명령에 `-m` 옵션을 전달하면 됩니다.

```bash
$ rails new my_cool_app -m path/to/template.rb
```

또는 기존 애플리케이션 내에서 `bin/rails app:template`을 사용하여 템플릿을 실행할 수 있습니다.

```bash
$ bin/rails app:template LOCATION=path/to/template.rb
```

템플릿은 로컬에 저장할 필요가 없습니다. 대신 경로 대신 URL을 지정할 수 있습니다.

```bash
$ rails new my_cool_app -m http://example.com/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

생성기 도우미 메서드
------------------------

Thor는 [`Thor::Actions`]를 통해 많은 생성기 도우미 메서드를 제공합니다. 예를 들어:

* [`copy_file`][]
* [`create_file`][]
* [`gsub_file`][]
* [`insert_into_file`][]
* [`inside`][]

이 외에도 Rails는 [`Rails::Generators::Actions`]를 통해 많은 도우미 메서드를 제공합니다. 예를 들어:

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
