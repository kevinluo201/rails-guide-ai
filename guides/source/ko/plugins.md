**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
Rails 플러그인 생성 기본 사항
====================================

Rails 플러그인은 핵심 프레임워크의 확장 또는 수정입니다. 플러그인은 다음을 제공합니다:

* 안정적인 코드 베이스를 손상시키지 않고 개발자들이 최신 아이디어를 공유할 수 있는 방법.
* 코드 단위를 고정하거나 업데이트할 수 있는 분할된 아키텍처.
* 핵심 개발자들이 모든 새로운 기능을 포함할 필요 없이 새로운 기능을 제공할 수 있는 출구.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* 처음부터 플러그인을 생성하는 방법.
* 플러그인에 대한 테스트를 작성하고 실행하는 방법.

이 가이드에서는 다음을 수행하는 테스트 주도 개발 플러그인을 구축하는 방법을 설명합니다:

* Hash와 String과 같은 핵심 Ruby 클래스를 확장합니다.
* `acts_as` 플러그인의 전통을 따라 `ApplicationRecord`에 메소드를 추가합니다.
* 플러그인에 생성기를 배치하는 위치에 대한 정보를 제공합니다.

이 가이드의 목적을 위해 잠시 새로운 새를 열심히 관찰하는 새 관찰가라고 가정해 보겠습니다.
당신이 가장 좋아하는 새는 Yaffle이며, 다른 개발자들이 Yaffle의 장점을 공유할 수 있는 플러그인을 생성하고 싶습니다.

--------------------------------------------------------------------------------

설정
-----

현재, Rails 플러그인은 젬으로 구축되며, _젬화된 플러그인_입니다. RubyGems와 Bundler를 사용하여 다른 Rails 애플리케이션 간에 공유할 수 있습니다.

### 젬화된 플러그인 생성

Rails는 더미 Rails 애플리케이션을 사용하여 통합 테스트를 실행할 수 있는 능력을 갖춘 어떤 종류의 Rails 확장을 개발하기 위한 뼈대를 생성하는 `rails plugin new` 명령을 제공합니다. 다음 명령으로 플러그인을 생성하세요:

```bash
$ rails plugin new yaffle
```

도움말을 보려면 다음 명령을 실행하세요:

```bash
$ rails plugin new --help
```

새로 생성된 플러그인을 테스트하기
-----------------------------------

플러그인이 포함된 디렉토리로 이동하여 `yaffle.gemspec` 파일을 열고 `TODO` 값이 있는 줄을 수정하세요:

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Summary of Yaffle."
spec.description = "Description of Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

그런 다음 `bundle install` 명령을 실행하세요.

이제 `bin/test` 명령을 사용하여 테스트를 실행할 수 있으며, 다음과 같은 결과가 표시됩니다:

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

이는 모든 것이 올바르게 생성되었고, 기능을 추가할 준비가 되었다는 것을 알려줍니다.

핵심 클래스 확장
----------------------

이 섹션에서는 Rails 애플리케이션 어디에서나 사용할 수 있는 String에 메소드를 추가하는 방법을 설명합니다.

이 예제에서는 `to_squawk`라는 이름의 메소드를 String에 추가합니다. 먼저, 몇 가지 어설션을 포함하는 새로운 테스트 파일을 생성하세요:

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

`bin/test` 명령을 실행하여 테스트를 실행하세요. 이 테스트는 `to_squawk` 메소드를 구현하지 않았기 때문에 실패해야 합니다:

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

좋습니다 - 이제 개발을 시작할 준비가 되었습니다.

`lib/yaffle.rb`에 `require "yaffle/core_ext"`를 추가하세요:

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

마지막으로, `core_ext.rb` 파일을 생성하고 `to_squawk` 메소드를 추가하세요:

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

메소드가 예상대로 작동하는지 테스트하려면 플러그인 디렉토리에서 `bin/test`를 사용하여 유닛 테스트를 실행하세요.

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

이를 실제로 확인하려면 `test/dummy` 디렉토리로 이동하여 `bin/rails console`을 시작하고 squawking을 시작하세요:

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

Active Record에 "acts_as" 메소드 추가
----------------------------------------

플러그인에서 일반적인 패턴은 모델에 `acts_as_something`라는 메소드를 추가하는 것입니다. 이 경우 `acts_as_yaffle`라는 메소드를 작성하여 Active Record 모델에 `squawk` 메소드를 추가하려고 합니다.

먼저, 다음과 같이 파일을 설정하세요:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### 클래스 메소드 추가

이 플러그인은 모델에 `last_squawk`라는 이름의 메소드를 추가했다고 가정합니다. 그러나 플러그인 사용자는 이미 모델에 `last_squawk`라는 이름의 메소드를 정의했을 수도 있으며 이를 다른 용도로 사용할 수도 있습니다. 이 플러그인은 `yaffle_text_field`라는 클래스 메소드를 추가함으로써 이름을 변경할 수 있도록 허용합니다.

먼저, 원하는 동작을 보여주는 실패하는 테스트를 작성하세요:

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

`bin/test`를 실행하면 다음과 같은 결과가 나타납니다:

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

이는 테스트하려는 모델(Hickwall 및 Wickwall)이 없기 때문에 필요한 모델이 없다는 것을 알려줍니다. "더미" 레일즈 애플리케이션에서 다음 명령을 실행하여 이러한 모델을 쉽게 생성할 수 있습니다.:

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

이제 더미 앱으로 이동하여 테스트 데이터베이스에 필요한 데이터베이스 테이블을 생성할 수 있습니다. 먼저 다음을 실행하세요:

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

여기에 있는 동안, Hickwall 및 Wickwall 모델을 yaffle처럼 작동해야 한다는 것을 알 수 있도록 변경하세요.

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

또한 `acts_as_yaffle` 메소드를 정의하는 코드를 추가합니다.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

그런 다음 플러그인의 루트 디렉토리로 돌아가 `bin/test`를 사용하여 테스트를 다시 실행하세요.

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

점점 가까워지고 있습니다... 이제 `acts_as_yaffle` 메소드의 코드를 구현하여 테스트를 통과시킵니다.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

`bin/test`를 실행하면 모든 테스트가 통과하는 것을 볼 수 있습니다.

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 인스턴스 메소드 추가

이 플러그인은 `acts_as_yaffle`을 호출하는 모든 Active Record 객체에 `squawk`라는 메소드를 추가합니다. `squawk` 메소드는 단순히 데이터베이스의 필드 중 하나의 값을 설정합니다.

먼저, 원하는 동작을 보여주는 실패하는 테스트를 작성하세요:

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

마지막 두 테스트가 "NoMethodError: undefined method \`squawk'"를 포함한 오류로 실패하는지 확인하기 위해 테스트를 실행한 다음 `acts_as_yaffle.rb`를 다음과 같이 업데이트하세요.

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

마지막으로 `bin/test`를 실행하면 다음과 같은 결과가 나타납니다:

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

참고: 모델에서 필드에 쓰기 위해 `write_attribute`를 사용하는 것은 플러그인이 모델과 상호 작용하는 한 가지 예일 뿐이며 항상 올바른 메소드는 아닙니다. 예를 들어 다음과 같이 사용할 수도 있습니다.
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

생성기
----------

생성기는 플러그인의 `lib/generators` 디렉토리에 생성하여 간단하게 젬에 포함될 수 있습니다. 생성기의 생성에 대한 자세한 정보는 [생성기 가이드](generators.html)에서 찾을 수 있습니다.

젬 공유하기
-------------------

개발 중인 젬 플러그인은 현재 어떤 Git 저장소에서든 쉽게 공유할 수 있습니다. Yaffle 젬을 다른 사람들과 공유하려면, 간단히 코드를 Git 저장소(예: GitHub)에 커밋하고, 해당 애플리케이션의 `Gemfile`에 한 줄을 추가하면 됩니다:

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

`bundle install`을 실행한 후에는 젬 기능이 애플리케이션에서 사용할 수 있게 됩니다.

젬을 공식 릴리스로 공유할 준비가 되었을 때, [RubyGems](https://rubygems.org)에 게시할 수 있습니다.

또는, Bundler의 Rake 작업을 활용할 수도 있습니다. 다음과 같이 전체 목록을 확인할 수 있습니다:

```bash
$ bundle exec rake -T

$ bundle exec rake build
# yaffle-0.1.0.gem을 pkg 디렉토리에 빌드합니다.

$ bundle exec rake install
# yaffle-0.1.0.gem을 시스템 젬으로 빌드하고 설치합니다.

$ bundle exec rake release
# 태그 v0.1.0을 생성하고 yaffle-0.1.0.gem을 빌드하여 Rubygems에 푸시합니다.
```

RubyGems에 젬을 게시하는 방법에 대한 자세한 정보는 다음을 참조하세요: [젬 게시하기](https://guides.rubygems.org/publishing).

RDoc 문서화
------------------

플러그인이 안정화되고 배포할 준비가 되었다면, 다른 사람들에게 도움이 되도록 문서화하는 것이 좋습니다. 다행히도, 플러그인에 대한 문서 작성은 쉽습니다.

첫 번째 단계는 README 파일을 자세한 정보로 업데이트하는 것입니다. 포함해야 할 몇 가지 주요 사항은 다음과 같습니다:

* 이름
* 설치 방법
* 앱에 기능을 추가하는 방법 (일반적인 사용 사례의 여러 예시)
* 사용자에게 도움이 될 수 있는 경고, 주의 사항 또는 팁

README가 완성되면, 개발자가 사용할 모든 메서드에 RDoc 주석을 추가하세요. 또한, 공개 API에 포함되지 않은 코드 부분에는 일반적으로 `# :nodoc:` 주석을 추가하는 것이 관례입니다.

주석이 준비되었다면, 플러그인 디렉토리로 이동한 후 다음을 실행하세요:

```bash
$ bundle exec rake rdoc
```

### 참고 자료

* [Bundler를 사용한 RubyGem 개발](https://github.com/radar/guides/blob/master/gem-development.md)
* [올바르게 .gemspecs 사용하기](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspec 참조](https://guides.rubygems.org/specification-reference/)
