**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
API 문서 가이드라인
==================

이 가이드는 Ruby on Rails API 문서 작성 가이드라인을 문서화합니다.

이 가이드를 읽으면 다음을 알게 됩니다:

* 문서 작성을 위한 효과적인 글쓰기 방법.
* 다양한 종류의 Ruby 코드를 문서화하는 스타일 가이드라인.

--------------------------------------------------------------------------------

RDoc
----

[Rails API 문서](https://api.rubyonrails.org)는 [RDoc](https://ruby.github.io/rdoc/)로 생성됩니다. 생성하려면 rails 루트 디렉토리에 있는지 확인하고 `bundle install`을 실행한 다음 다음을 실행하세요:

```bash
$ bundle exec rake rdoc
```

결과로 생성된 HTML 파일은 ./doc/rdoc 디렉토리에서 찾을 수 있습니다.

참고: 구문에 도움이 필요한 경우 RDoc [마크업 참조][RDoc Markup]를 참조하세요.

링크
-----

Rails API 문서는 GitHub에서 보기 위한 것이 아니므로 링크는 현재 API와 관련된 RDoc [`link`][RDoc Links] 마크업을 사용해야 합니다.

이는 GitHub Markdown과 [api.rubyonrails.org](https://api.rubyonrails.org) 및 [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org)에 게시된 생성된 RDoc 간의 차이 때문입니다.

예를 들어, RDoc에서 생성된 `ActiveRecord::Base` 클래스에 대한 링크를 생성하기 위해 `[link:classes/ActiveRecord/Base.html]`를 사용합니다.

이는 `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`와 같은 절대 URL보다 우선합니다. 절대 URL은 독자를 현재 문서 버전 밖으로 이동시킬 수 있습니다 (예: edgeapi.rubyonrails.org).

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

문구
----

간결하고 명확한 문장을 작성하세요. 간결함은 장점입니다: 핵심으로 바로 들어가세요.

현재 시제로 작성하세요. "Returns a hash that..." 대신에 "Returned a hash that..." 또는 "Will return a hash that..."와 같은 과거 시제나 미래 시제를 사용하지 마세요.

주석은 대문자로 시작하세요. 일반적인 구두점 규칙을 따르세요:

```ruby
# Declares an attribute reader backed by an internally-named
# instance variable.
def attr_internal_reader(*attrs)
  # ...
end
```

현재 방식을 명시적으로나 암묵적으로 독자에게 전달하세요. edge에서 권장하는 관용구를 사용하세요. 필요한 경우 선호하는 접근 방식을 강조하기 위해 섹션을 재정렬하세요. 문서는 모범 사례와 공식적인, 현대적인 Rails 사용법을 보여주어야 합니다.

문서는 간결하면서도 포괄적이어야 합니다. 예외 상황을 탐색하고 문서화하세요. 모듈이 익명인 경우에는 어떻게 되는지, 컬렉션이 비어 있는 경우에는 어떻게 되는지, 인수가 nil인 경우에는 어떻게 되는지 등을 문서화하세요.

Rails 구성 요소의 정식 이름은 "Active Support"와 같이 단어 사이에 공백이 있습니다. `ActiveRecord`는 Ruby 모듈이며, Active Record는 ORM입니다. 모든 Rails 문서에서는 Rails 구성 요소를 일관되게 정식 이름으로 참조해야 합니다.

"Rails 애플리케이션"을 언급할 때 "엔진"이나 "플러그인"과 구분하여 항상 "application"을 사용하세요. Rails 앱은 "서비스"가 아닙니다. 특정한 서비스 지향 아키텍처에 대해 특별히 논의하는 경우를 제외하고는요.

이름을 올바르게 철자로 사용하세요: Arel, minitest, RSpec, HTML, MySQL, JavaScript, ERB, Hotwire. 의심이 들 경우 공식 문서와 같은 신뢰할 수 있는 출처를 참조하세요.

"SQL"에 대해서는 "an"을 사용하세요. 예를 들어 "an SQL statement"와 같이 사용하세요. 또한 "an SQLite database"와 같이 사용하세요.

"you"와 "your"를 피하는 문구를 선호하세요. 예를 들어, 다음과 같은 스타일 대신에:

```markdown
If you need to use `return` statements in your callbacks, it is recommended that you explicitly define them as methods.
```

다음과 같은 스타일을 사용하세요:

```markdown
If `return` is needed, it is recommended to explicitly define a method.
```

그러나 가상의 사람에 대한 대용사로서 대인칭 대명사(they/their/them)를 사용해야 합니다. 예를 들어:

* he or she... 대신 they를 사용하세요.
* him or her... 대신 them을 사용하세요.
* his or her... 대신 their를 사용하세요.
* his or hers... 대신 theirs를 사용하세요.
* himself or herself... 대신 themselves를 사용하세요.

영어
----

미국 영어를 사용하세요 (*color*, *center*, *modularize* 등). [여기에서 미국 영어와 영국 영어 철자 차이 목록을 확인하세요](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences).

옥스퍼드 쉼표
------------

옥스퍼드 쉼표를 사용하세요 ([옥스퍼드 쉼표에 대한 자세한 내용은 여기를 참조하세요](https://en.wikipedia.org/wiki/Serial_comma))
("red, white, and blue" 대신 "red, white and blue"를 사용하세요).

예제 코드
----------

기본 사항과 흥미로운 포인트 또는 주의 사항을 보여주는 의미 있는 예제를 선택하세요.

코드 청크를 들여쓰기하는 데 두 개의 공백을 사용하세요. 즉, 마크업 목적으로 왼쪽 여백에 대해 두 개의 공백을 사용하세요. 예제 자체는 [Rails 코딩 규칙](contributing_to_ruby_on_rails.html#follow-the-coding-conventions)을 사용해야 합니다.

짧은 문서는 스니펫을 소개하기 위해 명시적인 "Examples" 레이블이 필요하지 않습니다. 문단 뒤에 바로 따라옵니다:

```ruby
# Converts a collection of elements into a formatted string by
# calling +to_s+ on all elements and joining them.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

반면에 구조화된 문서의 큰 청크는 별도의 "Examples" 섹션을 가질 수 있습니다:

```ruby
# ==== Examples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
표현식의 결과는 그 뒤에 "# => "가 붙어서 세로로 정렬됩니다:

```ruby
# 정수가 짝수인지 홀수인지 확인하는 데 사용됩니다.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

만약 한 줄이 너무 길다면, 주석은 다음 줄에 배치될 수 있습니다:

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

그 목적으로 `puts`나 `p`와 같은 출력 메소드를 사용하지 마십시오.

반면, 일반적인 주석은 화살표를 사용하지 않습니다:

```ruby
#   polymorphic_url(record)  # comment_url(record)와 동일합니다.
```

### SQL

SQL 문서화할 때, 결과 앞에 `=>`를 붙이지 않아야 합니다.

예를 들어,

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

IRB(Ruby의 대화형 REPL)의 동작을 문서화할 때, 명령어 앞에 항상 `irb>`를 붙이고 출력은 `=>`로 시작해야 합니다.

예를 들어,

```
# primary key (id)가 10인 고객을 찾습니다.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / Command-line

명령 줄 예제의 경우, 명령어 앞에 항상 `$`를 붙이고 출력은 아무런 접두사가 필요하지 않습니다.

```
# 다음 명령어를 실행합니다:
#   $ bin/rails new zomg
#   ...
```

Booleans
--------

조건문과 플래그에서 정확한 값보다는 부울 성질을 문서화하는 것이 좋습니다.

Ruby에서 정의된대로 "true" 또는 "false"를 사용할 때는 일반 폰트를 사용하십시오. `true`와 `false`와 같은 싱글톤은 고정폭 폰트를 사용해야 합니다. "truthy"와 "falsy"와 같은 용어는 피하십시오. Ruby는 언어에서 true와 false가 무엇인지 정의하고 있으므로 이러한 용어는 기술적인 의미를 가지고 있으며 대체어가 필요하지 않습니다.

일반적인 원칙으로, 필요한 경우가 아니면 싱글톤을 문서화하지 마십시오. 이렇게 하면 `!!`나 삼항 연산자와 같은 인위적인 구조를 방지할 수 있으며, 리팩터링이 가능하며, 코드는 구현에서 호출되는 메소드가 반환하는 정확한 값을 의존하지 않아도 됩니다.

예를 들어:

```markdown
`config.action_mailer.perform_deliveries`는 메일을 실제로 전달할지 여부를 지정하며 기본값은 true입니다.
```

사용자는 플래그의 실제 기본값을 알 필요가 없으므로 부울 성질만 문서화합니다.

조건부 예제:

```ruby
# 컬렉션이 비어있는지 여부를 반환합니다.
#
# 컬렉션이 로드된 경우
# <tt>collection.size.zero?</tt>와 동일합니다. 컬렉션이 로드되지 않은 경우
# <tt>!collection.exists?</tt>와 동일합니다. 컬렉션이 아직 로드되지 않았고
# 레코드를 가져올 예정인 경우 <tt>collection.length.zero?</tt>를 확인하는 것이 좋습니다.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

API는 특정 값을 고정하지 않도록 주의하며, 메소드는 조건부 성질을 가지고 있으면 충분합니다.

파일 이름
----------

일반적으로 애플리케이션 루트를 기준으로 파일 이름을 사용하십시오:

```
config/routes.rb            # YES
routes.rb                   # NO
RAILS_ROOT/config/routes.rb # NO
```

글꼴
-----

### 고정폭 폰트

고정폭 폰트를 사용하는 경우:

* 상수, 특히 클래스와 모듈 이름.
* 메소드 이름.
* `nil`, `false`, `true`, `self`와 같은 리터럴.
* 심볼.
* 메소드 매개변수.
* 파일 이름.

```ruby
class Array
  # 모든 요소에 +to_param+을 호출하고 결과를 슬래시로 연결합니다.
  # 이는 Action Pack의 +url_for+에서 사용됩니다.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

경고: 고정폭 폰트에 `+...+`를 사용하는 것은 일반적인 클래스, 모듈, 메소드 이름, 심볼, 경로(슬래시 포함) 등과 같은 간단한 내용에만 작동합니다. 그 외의 내용은 `<tt>...</tt>` 형식을 사용하십시오.

다음 명령어로 RDoc 출력을 빠르게 테스트할 수 있습니다:

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

예를 들어, 공백이나 따옴표가 포함된 코드는 `<tt>...</tt>` 형식을 사용해야 합니다.

### 일반 폰트

"true"와 "false"가 Ruby 키워드가 아닌 영어 단어로 사용될 때는 일반 폰트를 사용하십시오:

```ruby
# 지정된 컨텍스트에서 모든 유효성 검사를 실행합니다.
# 오류가 발견되지 않으면 true를 반환하고, 그렇지 않으면 false를 반환합니다.
#
# 인수가 false인 경우(기본값은 +nil+), 컨텍스트는
# <tt>new_record?</tt>가 true인 경우 <tt>:create</tt>로 설정되고,
# 그렇지 않은 경우 <tt>:update</tt>로 설정됩니다.
#
# <tt>:on</tt> 옵션이 없는 유효성 검사는
# 컨텍스트에 관계없이 실행됩니다. 일부 <tt>:on</tt> 옵션이 있는
# 유효성 검사는 지정된 컨텍스트에서만 실행됩니다.
def valid?(context = nil)
  # ...
end
```
설명 목록
-----------------

옵션, 매개변수 등의 목록에서 항목과 해당 설명 사이에 하이픈을 사용하여 설명을 나타냅니다(보통 옵션은 기호로 표시되기 때문에 콜론보다 읽기 쉽습니다):

```ruby
# * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+.
```

설명은 대문자로 시작하여 마침표로 끝납니다 - 이는 표준 영어입니다.

추가적인 세부 정보와 예제를 제공하려는 경우 옵션 섹션 스타일을 사용할 수도 있습니다.

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign]은 이에 대한 좋은 예입니다.

```ruby
# ==== Options
#
# [+:expires_at+]
#   The datetime at which the message expires. After this datetime,
#   verification of the message will fail.
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24 hours later...
#     encryptor.decrypt_and_verify(message) # => nil
```


동적으로 생성된 메서드
-----------------------------

`(module|class)_eval(STRING)`로 생성된 메서드는 생성된 코드의 인스턴스와 함께 주석이 있습니다. 해당 주석은 템플릿에서 2칸 떨어져 있습니다:

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

결과적으로 줄이 너무 길 경우, 200열 이상인 경우 주석을 호출 위에 놓습니다:

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

메서드 가시성
-----------------

Rails 문서를 작성할 때, 공개 사용자 인터페이스(API)와 내부 API의 차이를 이해하는 것이 중요합니다.

Rails는 대부분의 라이브러리와 마찬가지로 내부 API를 정의하기 위해 루비의 private 키워드를 사용합니다. 그러나 공개 API는 약간 다른 규칙을 따릅니다. 모든 공개 메서드가 사용자에게 제공되는 것으로 가정하는 대신, Rails는 `:nodoc:` 지시어를 사용하여 이러한 종류의 메서드를 내부 API로 표시합니다.

이는 Rails에는 사용자가 사용하지 않아야 하는 `public` 가시성을 가진 메서드가 있음을 의미합니다.

이에 대한 예로 `ActiveRecord::Core::ClassMethods#arel_table`이 있습니다:

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # do some magic..
  end
end
```

"이 메서드는 `ActiveRecord::Core`의 공개 클래스 메서드처럼 보입니다"라고 생각했다면 맞았습니다. 그러나 실제로 Rails 팀은 사용자가 이 메서드를 사용하지 않기를 원합니다. 따라서 `:nodoc:`로 표시하고 공개 문서에서 제거됩니다. 이러한 이유로 이 메서드의 이름, 반환 값 또는 이 클래스 전체가 변경될 수 있습니다. 따라서 플러그인이나 애플리케이션에서 이 API에 의존하면 Rails의 새 버전으로 업그레이드할 때 앱이나 젬이 깨질 수 있습니다.

기여자로서 이 API가 최종 사용자 소비를 위해 만들어졌는지 여부를 고려하는 것이 중요합니다. Rails 팀은 완전한 사용 중단 주기를 거치지 않고는 공개 API를 변경하지 않기로 약속하고 있습니다. 내부 메서드/클래스가 아닌 경우 내부 API로 간주되므로 이미 private인 경우 `:nodoc:`를 사용하는 것이 좋습니다. API가 안정화되면 가시성을 변경할 수 있지만, 공개 API를 변경하는 것은 하위 호환성 때문에 훨씬 어렵습니다.

클래스나 모듈은 `:nodoc:`로 표시되어 모든 메서드가 내부 API임을 나타냅니다.

요약하면, Rails 팀은 `:nodoc:`를 사용하여 공개적으로 표시되는 메서드와 내부 사용을 위한 클래스를 표시합니다. API의 가시성 변경은 신중히 고려되어야 하며, 먼저 pull request를 통해 토론되어야 합니다.

Rails 스택에 관하여
-------------------------

Rails API의 일부를 문서화할 때, Rails 스택에 포함되는 모든 요소를 기억하는 것이 중요합니다.

이는 메서드나 클래스를 문서화하려는 범위나 컨텍스트에 따라 동작이 달라질 수 있다는 것을 의미합니다.

전체 스택을 고려할 때 다른 동작이 있는 여러 곳이 있으며, 이에 대한 예로 `ActionView::Helpers::AssetTagHelper#image_tag`가 있습니다:

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

`#image_tag`의 기본 동작은 항상 `/images/icon.png`를 반환하는 것입니다. 그러나 우리는 전체 Rails 스택(Asset Pipeline을 포함한)을 고려할 때 위와 같은 결과를 볼 수 있습니다.

우리는 기본적으로 _프레임워크_의 동작을 문서화하고자 합니다.

Rails 팀이 특정 API를 처리하는 방식에 대한 질문이 있으면 [이슈 트래커](https://github.com/rails/rails/issues)에 티켓을 열거나 패치를 보내는 것을 망설이지 마십시오.
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
