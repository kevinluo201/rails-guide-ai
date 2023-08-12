**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: d3947b8dd1115e8f8e4279581ff626f6
레일즈 애플리케이션 템플릿
===========================

애플리케이션 템플릿은 새로 생성된 레일즈 프로젝트나 기존 레일즈 프로젝트에 젬, 이니셜라이저 등을 추가하는 DSL을 포함한 간단한 루비 파일입니다.

이 가이드를 읽으면 다음을 알게 됩니다:

* 템플릿을 사용하여 레일즈 애플리케이션을 생성/사용자 정의하는 방법.
* 레일즈 템플릿 API를 사용하여 재사용 가능한 애플리케이션 템플릿을 작성하는 방법.

--------------------------------------------------------------------------------

사용법
-----

템플릿을 적용하려면 `-m` 옵션을 사용하여 적용할 템플릿의 위치를 레일즈 생성기에 제공해야 합니다. 이는 파일 경로나 URL일 수 있습니다.

```bash
$ rails new blog -m ~/template.rb
$ rails new blog -m http://example.com/template.rb
```

`app:template` 레일즈 명령을 사용하여 기존 레일즈 애플리케이션에 템플릿을 적용할 수 있습니다. 템플릿의 위치는 LOCATION 환경 변수를 통해 전달되어야 합니다. 이는 파일 경로나 URL일 수 있습니다.

```bash
$ bin/rails app:template LOCATION=~/template.rb
$ bin/rails app:template LOCATION=http://example.com/template.rb
```

템플릿 API
------------

레일즈 템플릿 API는 이해하기 쉽습니다. 다음은 전형적인 레일즈 템플릿의 예입니다:

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

다음 섹션에서는 API에서 제공하는 주요 메서드를 설명합니다:

### gem(*args)

생성된 애플리케이션의 `Gemfile`에 지정된 젬에 대한 `gem` 항목을 추가합니다.

예를 들어, 애플리케이션이 `bj`와 `nokogiri` 젬에 의존하는 경우:

```ruby
gem "bj"
gem "nokogiri"
```

이 메서드는 젬을 `Gemfile`에 추가하는 것만을 의미하며, 젬을 설치하지는 않습니다.

### gem_group(*names, &block)

그룹 내에서 젬 항목을 랩합니다.

예를 들어, `rspec-rails`를 `development` 그룹과 `test` 그룹에서만 로드하려는 경우:

```ruby
gem_group :development, :test do
  gem "rspec-rails"
end
```

### add_source(source, options={}, &block)

지정된 소스를 생성된 애플리케이션의 `Gemfile`에 추가합니다.

예를 들어, `"http://gems.github.com"`에서 젬을 소스로 사용해야 하는 경우:

```ruby
add_source "http://gems.github.com"
```

블록이 주어지면 블록 내의 젬 항목이 소스 그룹으로 랩됩니다.

```ruby
add_source "http://gems.github.com/" do
  gem "rspec-rails"
end
```

### environment/application(data=nil, options={}, &block)

`config/application.rb`의 `Application` 클래스 내에 라인을 추가합니다.

`options[:env]`가 지정된 경우, 해당 파일에 라인이 추가됩니다.

```ruby
environment 'config.action_mailer.default_url_options = {host: "http://yourwebsite.example.com"}', env: 'production'
```

`data` 인수 대신 블록을 사용할 수 있습니다.

### vendor/lib/file/initializer(filename, data = nil, &block)

생성된 애플리케이션의 `config/initializers` 디렉토리에 이니셜라이저를 추가합니다.

`Object#not_nil?`과 `Object#not_blank?`를 사용하는 것을 좋아한다고 가정해 봅시다:

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

마찬가지로, `lib()`는 `lib/` 디렉토리에 파일을 생성하고, `vendor()`는 `vendor/` 디렉토리에 파일을 생성합니다.

`file()`은 `Rails.root`로부터의 상대 경로를 받아 필요한 모든 디렉토리/파일을 생성합니다:

```ruby
file 'app/components/foo.rb', <<-CODE
  class Foo
  end
CODE
```

위 코드는 `app/components` 디렉토리를 생성하고 그 안에 `foo.rb`를 넣습니다.

### rakefile(filename, data = nil, &block)

지정된 작업으로 `lib/tasks` 아래에 새로운 rake 파일을 생성합니다:

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

위 코드는 `boot:strap` rake 작업이 있는 `lib/tasks/bootstrap.rake`를 생성합니다.

### generate(what, *args)

지정된 레일즈 생성기를 주어진 인수로 실행합니다.

```ruby
generate(:scaffold, "person", "name:string", "address:text", "age:number")
```

### run(command)

임의의 명령을 실행합니다. 백틱과 마찬가지입니다. `README.rdoc` 파일을 제거하려는 경우:

```ruby
run "rm README.rdoc"
```

### rails_command(command, options = {})

레일즈 애플리케이션에서 지정된 명령을 실행합니다. 데이터베이스를 마이그레이션하려는 경우:

```ruby
rails_command "db:migrate"
```

다른 레일즈 환경에서 명령을 실행할 수도 있습니다:

```ruby
rails_command "db:migrate", env: 'production'
```

슈퍼 유저로 명령을 실행할 수도 있습니다:

```ruby
rails_command "log:clear", sudo: true
```

실패할 경우 애플리케이션 생성을 중단해야 하는 명령을 실행할 수도 있습니다:

```ruby
rails_command "db:migrate", abort_on_failure: true
```

### route(routing_code)

`config/routes.rb` 파일에 라우팅 항목을 추가합니다. 위 단계에서 우리는 person 스캐폴드를 생성하고 `README.rdoc`를 제거했습니다. 이제 `PeopleController#index`를 애플리케이션의 기본 페이지로 만들려면:

```ruby
route "root to: 'person#index'"
```

### inside(dir)

지정된 디렉토리에서 명령을 실행할 수 있도록 합니다. 예를 들어, 새로운 앱에서 심볼릭 링크를 만들기 위해 엣지 레일즈의 사본을 사용하려는 경우:
```ruby
inside('vendor') do
  run "ln -s ~/commit-rails/rails rails"
end
```

### ask(question)

`ask()`는 사용자로부터 피드백을 받아 템플릿에서 사용할 수 있는 기회를 제공합니다. 예를 들어 새로운 라이브러리의 이름을 사용자에게 지정하도록 하려면 다음과 같이 할 수 있습니다:

```ruby
lib_name = ask("새로운 라이브러리의 이름을 지정하세요:")
lib_name << ".rb" unless lib_name.index(".rb")

lib lib_name, <<-CODE
  class Shiny
  end
CODE
```

### yes?(question) 또는 no?(question)

이러한 메서드를 사용하여 템플릿에서 질문을 하고 사용자의 답변에 따라 흐름을 결정할 수 있습니다. 예를 들어 사용자에게 마이그레이션을 실행할 것인지 묻고 싶다면 다음과 같이 할 수 있습니다:

```ruby
rails_command("db:migrate") if yes?("데이터베이스 마이그레이션을 실행하시겠습니까?")
# no?(question)는 반대로 작동합니다.
```

### git(:command)

Rails 템플릿에서는 어떤 git 명령이든 실행할 수 있습니다:

```ruby
git :init
git add: "."
git commit: "-a -m '초기 커밋'"
```

### after_bundle(&block)

젬이 번들되고 binstub이 생성된 후에 실행될 콜백을 등록합니다. 생성된 파일을 버전 관리에 추가하는 데 유용합니다:

```ruby
after_bundle do
  git :init
  git add: '.'
  git commit: "-a -m '초기 커밋'"
end
```

콜백은 `--skip-bundle`이 전달되었더라도 실행됩니다.

고급 사용법
--------------

애플리케이션 템플릿은 `Rails::Generators::AppGenerator` 인스턴스의 컨텍스트에서 평가됩니다. 이는 Thor에서 제공하는 [`apply`](https://www.rubydoc.info/gems/thor/Thor/Actions#apply-instance_method) 액션을 사용합니다.

이는 인스턴스를 확장하고 변경하여 필요에 맞게 맞출 수 있다는 것을 의미합니다.

예를 들어 `source_paths` 메서드를 덮어쓰고 템플릿의 위치를 포함하도록 설정할 수 있습니다. 이제 `copy_file`과 같은 메서드는 템플릿의 위치에 상대적인 경로를 허용합니다.

```ruby
def source_paths
  [__dir__]
end
```
