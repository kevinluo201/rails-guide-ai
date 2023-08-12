**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Ruby on Rails 업그레이드
=======================

이 가이드는 응용 프로그램을 더 최신 버전의 Ruby on Rails로 업그레이드할 때 따라야 할 단계를 제공합니다. 이 단계는 개별 릴리스 가이드에서도 사용할 수 있습니다.

--------------------------------------------------------------------------------

일반적인 조언
--------------

기존 응용 프로그램을 업그레이드하기 전에 업그레이드할 좋은 이유가 있는지 확인해야 합니다. 새로운 기능이 필요한지, 이전 코드에 대한 지원을 찾기가 점점 어려워지는지, 사용 가능한 시간과 기술 등을 균형있게 고려해야 합니다.

### 테스트 커버리지

업그레이드 후에 응용 프로그램이 여전히 작동하는지 확인하는 가장 좋은 방법은 프로세스를 시작하기 전에 좋은 테스트 커버리지를 가지고 있는 것입니다. 응용 프로그램의 대부분을 자동으로 테스트하는 테스트가 없다면 변경된 모든 부분을 수동으로 테스트해야 합니다. Rails 업그레이드의 경우, 응용 프로그램의 모든 기능을 의미합니다. 업그레이드를 시작하기 전에 테스트 커버리지가 좋은지 확인하세요.

### Ruby 버전

Rails은 일반적으로 릴리스될 때 최신 버전의 Ruby에 가깝게 유지됩니다:

* Rails 7은 Ruby 2.7.0 이상을 필요로 합니다.
* Rails 6은 Ruby 2.5.0 이상을 필요로 합니다.
* Rails 5는 Ruby 2.2.2 이상을 필요로 합니다.

Ruby와 Rails를 별도로 업그레이드하는 것이 좋습니다. 먼저 가능한 최신 Ruby로 업그레이드한 다음 Rails로 업그레이드하세요.

### 업그레이드 프로세스

Rails 버전을 변경할 때는 경고 메시지를 잘 활용하기 위해 천천히 한 번에 하나의 마이너 버전씩 이동하는 것이 가장 좋습니다. Rails 버전 번호는 Major.Minor.Patch 형식입니다. Major와 Minor 버전은 공개 API에 변경을 가할 수 있으므로 응용 프로그램에서 오류가 발생할 수 있습니다. Patch 버전은 버그 수정만 포함하며 공개 API를 변경하지 않습니다.

다음과 같은 절차를 따라야 합니다:

1. 테스트를 작성하고 통과하는지 확인합니다.
2. 현재 버전 이후의 최신 패치 버전으로 이동합니다.
3. 테스트와 사용 중단된 기능을 수정합니다.
4. 다음 마이너 버전의 최신 패치 버전으로 이동합니다.

이러한 과정을 목표로 하는 Rails 버전에 도달할 때까지 반복합니다.

#### 버전 간 이동

버전 간 이동을 위해 다음을 수행하세요:

1. `Gemfile`에서 Rails 버전 번호를 변경하고 `bundle update`를 실행합니다.
2. `package.json`에서 Rails JavaScript 패키지의 버전을 변경하고, Webpacker를 사용하는 경우 `yarn install`을 실행합니다.
3. [업데이트 작업](#the-update-task)을 실행합니다.
4. 테스트를 실행합니다.

모든 릴리스된 Rails 젬의 목록은 [여기](https://rubygems.org/gems/rails/versions)에서 찾을 수 있습니다.

### 업데이트 작업

Rails는 `rails app:update` 명령을 제공합니다. `Gemfile`에서 Rails 버전을 업데이트한 후에 이 명령을 실행하세요.
이 명령은 대화식 세션에서 새 파일의 생성 및 이전 파일의 변경을 도와줍니다.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

의도하지 않은 변경 사항이 있는지 확인하기 위해 차이를 검토하는 것을 잊지 마세요.

### 프레임워크 기본값 구성

새로운 Rails 버전은 이전 버전과 다른 구성 기본값을 가질 수 있습니다. 그러나 위에서 설명한 단계를 따른 후에도 응용 프로그램은 *이전* Rails 버전의 구성 기본값으로 실행됩니다. 이는 `config/application.rb`의 `config.load_defaults` 값이 아직 변경되지 않았기 때문입니다.

새로운 기본값으로 하나씩 업그레이드할 수 있도록 업데이트 작업은 `config/initializers/new_framework_defaults_X.Y.rb`라는 파일을 생성했습니다(파일 이름에는 원하는 Rails 버전이 포함됩니다). 파일에서 주석 처리된 새로운 구성 기본값을 활성화해야 합니다. 이는 여러 배포를 통해 점진적으로 수행할 수 있습니다. 응용 프로그램이 새로운 기본값으로 실행될 준비가 되면 이 파일을 제거하고 `config.load_defaults` 값을 변경하세요.

Rails 7.0에서 Rails 7.1로 업그레이드하기
-------------------------------------

Rails 7.1에서 수행된 변경 사항에 대한 자세한 내용은 [릴리스 노트](7_1_release_notes.html)를 참조하세요.

### 자동로드된 경로는 더 이상 로드 경로에 포함되지 않습니다

Rails 7.1부터 자동로더가 관리하는 모든 경로는 더 이상 `$LOAD_PATH`에 추가되지 않습니다.
이는 수동 `require` 호출로 로드할 수 없으며, 대신 클래스나 모듈을 참조할 수 있습니다.

`bootsnap`을 사용하지 않는 앱의 경우 `$LOAD_PATH`의 크기를 줄이고 `require` 호출 속도를 높이며, 다른 앱의 `bootsnap` 캐시 크기를 줄일 수 있습니다.
### `ActiveStorage::BaseController`는 더 이상 스트리밍 관련 기능을 포함하지 않습니다.

`ActiveStorage::BaseController`를 상속받는 애플리케이션 컨트롤러에서 사용자 정의 파일 서빙 로직을 구현하기 위해 스트리밍을 사용하는 경우, `ActiveStorage::Streaming` 모듈을 명시적으로 포함해야 합니다.

### `MemCacheStore`와 `RedisCacheStore`는 이제 기본적으로 커넥션 풀링을 사용합니다.

`connection_pool` 젬이 `activesupport` 젬의 종속성으로 추가되었으며, `MemCacheStore`와 `RedisCacheStore`는 이제 기본적으로 커넥션 풀링을 사용합니다.

커넥션 풀링을 사용하지 않으려면 캐시 스토어를 구성할 때 `:pool` 옵션을 `false`로 설정하세요:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

자세한 내용은 [Rails에서 캐싱](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) 가이드를 참조하세요.

### `SQLite3Adapter`는 이제 엄격한 문자열 모드로 구성됩니다.

엄격한 문자열 모드를 사용하면 이중 따옴표로 둘러싼 문자열 리터럴이 비활성화됩니다.

SQLite는 이중 따옴표로 둘러싼 문자열 리터럴에 대해 몇 가지 특징을 가지고 있습니다.
먼저 이중 따옴표로 둘러싼 문자열을 식별자 이름으로 간주하려고 시도하지만, 식별자가 존재하지 않는 경우 문자열 리터럴로 간주합니다. 이로 인해 오타가 무시될 수 있습니다.
예를 들어, 존재하지 않는 열에 대한 인덱스를 생성할 수 있습니다.
자세한 내용은 [SQLite 문서](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted)를 참조하세요.

`SQLite3Adapter`를 엄격한 모드로 사용하지 않으려면 이 동작을 비활성화할 수 있습니다:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### `ActionMailer::Preview`에 대한 여러 개의 미리보기 경로 지원

`config.action_mailer.preview_path` 옵션은 `config.action_mailer.preview_paths` 옵션으로 대체되었습니다. 이 구성 옵션에 경로를 추가하면 해당 경로가 메일러 미리보기 검색에 사용됩니다.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true`는 이제 모든 누락된 번역에 대해 예외를 발생시킵니다.

이전에는 뷰나 컨트롤러에서 호출될 때만 예외가 발생했습니다. 이제 `I18n.t`에 인식할 수 없는 키가 제공되면 언제든지 예외가 발생합니다.

```ruby
# with config.i18n.raise_on_missing_translations = true

# in a view or controller:
t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서는 예외가 발생함
I18n.t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서는 예외가 발생함

# anywhere:
I18n.t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서는 예외가 발생함
```

이 동작을 원하지 않는 경우 `config.i18n.raise_on_missing_translations = false`로 설정할 수 있습니다:

```ruby
# with config.i18n.raise_on_missing_translations = false

# in a view or controller:
t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서도 예외가 발생하지 않음
I18n.t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서도 예외가 발생하지 않음

# anywhere:
I18n.t("missing.key") # 7.0에서는 예외가 발생하지 않음, 7.1에서도 예외가 발생하지 않음
```

또는 `I18n.exception_handler`를 사용자 정의할 수 있습니다.
자세한 내용은 [i18n 가이드](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers)를 참조하세요.

Rails 6.1에서 Rails 7.0으로 업그레이드하기
------------------------------------------

Rails 7.0에 대한 변경 사항에 대한 자세한 내용은 [릴리스 노트](7_0_release_notes.html)를 참조하세요.

### `ActionView::Helpers::UrlHelper#button_to`의 동작이 변경되었습니다.

Rails 7.0부터 `button_to`는 지속된 Active Record 객체를 사용하여 버튼 URL을 구축하는 경우 `form` 태그를 `patch` HTTP 동사와 함께 렌더링합니다.
현재 동작을 유지하려면 `method:` 옵션을 명시적으로 전달해야 합니다:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

또는 URL을 구축하기 위해 헬퍼를 사용할 수 있습니다:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

애플리케이션이 Spring을 사용하는 경우, 적어도 버전 3.0.0으로 업그레이드해야 합니다. 그렇지 않으면 다음과 같은 오류가 발생합니다.

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

또한, `config/environments/test.rb`에서 [`config.cache_classes`][]가 `false`로 설정되어 있는지 확인하세요.


### Sprockets는 이제 선택적 종속성입니다.

`rails` 젬은 더 이상 `sprockets-rails`에 종속되지 않습니다. 여전히 Sprockets를 사용해야 하는 경우,
Gemfile에 `sprockets-rails`를 추가해야 합니다.

```ruby
gem "sprockets-rails"
```

### 애플리케이션은 `zeitwerk` 모드에서 실행되어야 합니다.

아직 `classic` 모드에서 실행 중인 애플리케이션은 `zeitwerk` 모드로 전환해야 합니다. 자세한 내용은 [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) 가이드를 확인하세요.

### `config.autoloader=` 설정자가 삭제되었습니다.

Rails 7에서는 자동로딩 모드를 설정할 수 있는 구성 지점이 없으므로 `config.autoloader=` 설정자가 삭제되었습니다. 이 설정을 `:zeitwerk`로 설정한 경우, 그냥 제거하세요.

### `ActiveSupport::Dependencies`의 비공개 API가 삭제되었습니다.

`ActiveSupport::Dependencies`의 비공개 API가 삭제되었습니다. 이에는 `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` 등의 메서드가 포함됩니다.

일부 주요 변경 사항:

* `ActiveSupport::Dependencies.constantize` 또는 `ActiveSupport::Dependencies.safe_constantize`를 사용한 경우, 이제 `String#constantize` 또는 `String#safe_constantize`로 변경하세요.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # 더 이상 사용할 수 없음
  "User".constantize # 👍
  ```

* `ActiveSupport::Dependencies.mechanism`의 사용 방법은 `config.cache_classes`에 따라 액세스하는 것으로 대체되어야 합니다.

* 자동로더의 활동을 추적하려는 경우, `ActiveSupport::Dependencies.verbose=`는 더 이상 사용할 수 없으며, `config/application.rb`에 `Rails.autoloaders.log!`를 추가하세요.
보조 내부 클래스 또는 모듈도 마찬가지로 사라졌습니다. 예를 들어 `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` 등이 있습니다.

### 초기화 중 자동로드

`to_prepare` 블록 외부에서 초기화 중에 자동로드 가능한 상수를 자동로드한 애플리케이션은 해당 상수가 언로드되고 Rails 6.0 이후에 이 경고가 발생합니다.

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

로그에서 이 경고를 계속 받는 경우, 애플리케이션이 부팅될 때 자동로드에 대한 섹션을 [자동로드 가이드](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots)에서 확인해주세요. 그렇지 않으면 Rails 7에서 `NameError`가 발생합니다.

### `config.autoload_once_paths` 구성 가능

[`config.autoload_once_paths`][]는 `config/application.rb`에 정의된 애플리케이션 클래스의 본문이나 `config/environments/*`의 환경 구성에서 설정할 수 있습니다.

마찬가지로 엔진은 엔진 클래스의 본문이나 환경의 구성에서 해당 컬렉션을 구성할 수 있습니다.

그 후 컬렉션은 동결되며 해당 경로에서 자동로드할 수 있습니다. 특히 초기화 중에 거기에서 자동로드할 수 있습니다. 이들은 `Rails.autoloaders.once` 자동로더에 의해 관리되며 다시로드하지 않고 자동로드/이니셜 로드만 수행합니다.

환경 구성이 처리된 후에 이 설정을 구성하고 `FrozenError`를 받는 경우, 코드를 이동해주세요.


### `ActionDispatch::Request#content_type`은 이제 Content-Type 헤더를 그대로 반환합니다.

이전에 `ActionDispatch::Request#content_type`은 문자셋 부분을 포함하지 않은 값을 반환했습니다.
이 동작은 문자셋 부분을 포함한 Content-Type 헤더를 반환하도록 변경되었습니다.

MIME 유형만 필요한 경우 `ActionDispatch::Request#media_type`을 사용해주세요.

변경 전:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

변경 후:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### 키 생성기 다이제스트 클래스 변경에 따른 쿠키 로테이터 필요

키 생성기의 기본 다이제스트 클래스가 SHA1에서 SHA256으로 변경됩니다.
이는 Rails에서 생성된 암호화된 메시지, 쿠키를 포함한 모든 암호화된 메시지에 영향을 미칩니다.

이전 다이제스트 클래스를 사용하여 메시지를 읽을 수 있도록 하려면 로테이터를 등록해야 합니다. 이를 하지 않으면 업그레이드 중에 사용자의 세션이 무효화될 수 있습니다.

다음은 암호화된 쿠키와 서명된 쿠키에 대한 로테이터 예시입니다.

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

### ActiveSupport::Digest의 다이제스트 클래스가 SHA256으로 변경됨

ActiveSupport::Digest의 기본 다이제스트 클래스가 SHA1에서 SHA256으로 변경됩니다.
이는 Etag와 같은 것에 영향을 미치는데, 이는 캐시 키도 변경됩니다.
이러한 키 변경은 캐시 히트율에 영향을 줄 수 있으므로 새 해시로 업그레이드할 때 주의해야 합니다.

### 새로운 ActiveSupport::Cache 직렬화 형식

보다 빠르고 더 압축된 직렬화 형식이 도입되었습니다.

이를 활성화하려면 `config.active_support.cache_format_version = 7.0`을 설정해야 합니다:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

또는 간단히:

```ruby
# config/application.rb

config.load_defaults 7.0
```

그러나 Rails 6.1 애플리케이션은 이 새로운 직렬화 형식을 읽을 수 없으므로 원활한 업그레이드를 위해 먼저 `config.active_support.cache_format_version = 6.1`로 Rails 7.0 업그레이드를 배포한 후에 모든 Rails 프로세스가 업데이트된 후에 `config.active_support.cache_format_version = 7.0`로 설정해야 합니다.

Rails 7.0은 두 형식 모두를 읽을 수 있으므로 업그레이드 중에 캐시가 무효화되지 않습니다.

### Active Storage 비디오 미리보기 이미지 생성

비디오 미리보기 이미지 생성은 이제 FFmpeg의 장면 변경 감지를 사용하여 의미 있는 미리보기 이미지를 생성합니다. 이전에는 비디오의 첫 번째 프레임이 사용되었으며, 이는 비디오가 검은색에서 서서히 나타나는 경우 문제를 일으켰습니다. 이 변경은 FFmpeg v3.4+를 필요로 합니다.

### Active Storage 기본 변형 프로세서가 `:vips`로 변경됨

새로운 앱의 이미지 변형은 ImageMagick 대신 libvips를 사용합니다. 이를 통해 변형 생성에 소요되는 시간과 CPU 및 메모리 사용량이 줄어들어 이미지를 제공하는 데 의존하는 앱의 응답 시간이 개선됩니다.

`:mini_magick` 옵션은 폐기되지 않으므로 계속 사용해도 괜찮습니다.

기존 앱을 libvips로 마이그레이션하려면 다음을 설정하세요:
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

기존의 이미지 변환 코드를 `image_processing` 매크로로 변경하고 ImageMagick의 옵션을 libvips의 옵션으로 대체해야합니다.

#### resize를 resize_to_limit으로 대체

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

이 작업을 수행하지 않으면 vips로 전환할 때 다음 오류가 발생합니다: `no implicit conversion to float from string`.

#### 자르기 시에 배열 사용

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

vips로 마이그레이션할 때 이 작업을 수행하지 않으면 다음 오류가 발생합니다: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### 자르기 값에 clamp 적용:

크롭 작업에 대해 ImageMagick보다 Vips가 더 엄격합니다:

1. `x`와/또는 `y`가 음수 값인 경우 자르기를 수행하지 않습니다. 예: `[-10, -10, 100, 100]`
2. 위치(`x` 또는 `y`)와 자르기 크기(`width`, `height`)를 합한 값이 이미지보다 큰 경우 자르기를 수행하지 않습니다. 예: 125x125 이미지와 `[50, 50, 100, 100]` 자르기

vips로 마이그레이션할 때 이 작업을 수행하지 않으면 다음 오류가 발생합니다: `extract_area: bad extract area`

#### `resize_and_pad`에 사용되는 배경색 조정

Vips는 ImageMagick과 달리 `resize_and_pad`에 대해 기본 배경색으로 검은색을 사용합니다. `background` 옵션을 사용하여 이를 수정하세요:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### EXIF 기반 회전 제거

Vips는 변형을 처리할 때 EXIF 값을 사용하여 이미지를 자동으로 회전합니다. ImageMagick을 사용하여 회전 값을 사용자가 업로드한 사진의 회전에 적용하고 있었다면 이를 중지해야합니다:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### monochrome를 colourspace로 대체

흑백 이미지를 만들기 위해 Vips는 다른 옵션을 사용합니다:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### 이미지 압축을 위해 libvips 옵션으로 전환

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

#### 프로덕션에 배포

Active Storage는 이미지의 URL에 수행해야 할 변환 목록을 인코딩합니다. 앱에서 이러한 URL을 캐싱하고 있다면 새 코드를 프로덕션에 배포한 후 이미지가 깨집니다. 이를 방지하기 위해 영향을 받는 캐시 키를 수동으로 무효화해야합니다.

예를 들어, 다음과 같은 코드가 뷰에 있다면:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

캐시를 무효화하려면 제품을 터치하거나 캐시 키를 변경할 수 있습니다:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Active Record 스키마 덤프에 Rails 버전이 포함되었습니다.

Rails 7.0에서 일부 열 유형의 기본값이 변경되었습니다. 6.1에서 7.0으로 업그레이드하는 애플리케이션이 새로운 7.0 기본값을 사용하여 현재 스키마를 로드하지 않도록 하기 위해 Rails는 이제 스키마 덤프에 프레임워크 버전을 포함합니다.

Rails 7.0에서 처음으로 스키마를 로드하기 전에 `rails app:update`를 실행하여 스키마 버전이 스키마 덤프에 포함되도록 해야합니다.

스키마 파일은 다음과 같이 보일 것입니다:

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
참고: Rails 7.0으로 스키마를 처음 덤프하는 경우, 해당 파일에 많은 변경 사항이 포함되어 있으며 일부 열 정보도 포함됩니다. 새로운 스키마 파일 내용을 검토하고 리포지토리에 커밋하십시오.

Rails 6.0에서 Rails 6.1로 업그레이드하기
-------------------------------------

Rails 6.1에 대한 변경 사항에 대한 자세한 정보는 [릴리스 노트](6_1_release_notes.html)를 참조하십시오.

### `Rails.application.config_for`의 반환 값은 더 이상 문자열 키로 액세스를 지원하지 않습니다.

다음과 같은 구성 파일이 주어진 경우:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

이전에는 문자열 키로 값을 액세스할 수 있는 해시를 반환했습니다. 이것은 6.0에서 사용 중지되었으며 더 이상 작동하지 않습니다.

여전히 문자열 키로 값을 액세스하려면 `config_for`의 반환 값을 `with_indifferent_access`로 호출할 수 있습니다. 예:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### `respond_to#any`를 사용할 때 응답의 Content-Type

응답에서 반환되는 Content-Type 헤더는 Rails 6.0에서 반환되는 것과 다를 수 있습니다. 특히 응용 프로그램이 `respond_to { |format| format.any }`를 사용하는 경우입니다. 이제 Content-Type은 요청의 형식이 아닌 지정된 블록을 기반으로 합니다.

예:

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

이전 동작은 `text/csv` 응답의 Content-Type을 반환했으며, 이는 JSON 응답이 렌더링되고 있기 때문에 부정확합니다. 현재 동작은 올바르게 `application/json` 응답의 Content-Type을 반환합니다.

응용 프로그램이 이전의 잘못된 동작에 의존하는 경우, 작업이 수락하는 형식을 명시하는 것이 좋습니다. 예:

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook`은 이제 두 번째 인수를 받습니다.

Active Support는 콜백이 체인을 중단할 때마다 `halted_callback_hook`을 재정의할 수 있도록 합니다. 이 메서드는 이제 중단되는 콜백의 이름인 두 번째 인수를 받습니다. 이 메서드를 재정의하는 클래스가 있는 경우, 두 개의 인수를 받도록 확인하십시오. 이는 성능상의 이유로 이전에 사용되지 않은 변경 사항입니다.

예:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => 이 메서드는 이제 1개 대신 2개의 인수를 받습니다.
    Rails.logger.info("Book couldn't be #{callback_name}d")
  end
end
```

### 컨트롤러의 `helper` 클래스 메서드는 `String#constantize`를 사용합니다.

개념적으로 Rails 6.1 이전에는 다음과 같았습니다.

```ruby
helper "foo/bar"
```

결과는 다음과 같았습니다.

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

이제는 다음과 같이 수행됩니다.

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

이 변경 사항은 대부분의 응용 프로그램에서 하위 호환성이 유지되므로 아무 작업도 필요하지 않습니다.

그러나 기술적으로 컨트롤러가 `helpers_path`를 `$LOAD_PATH`의 autoload 경로가 아닌 디렉토리를 가리키도록 구성할 수 있습니다. 이 경우 사용자 정의 도움말 모듈이 자동으로 로드되지 않으므로 `helper`를 호출하기 전에 응용 프로그램에서 로드해야 합니다.

### HTTP에서 HTTPS로의 리디렉션은 이제 308 HTTP 상태 코드를 사용합니다.

HTTP에서 HTTPS로의 비-GET/HEAD 요청 리디렉션 시 `ActionDispatch::SSL`에서 사용하는 기본 HTTP 상태 코드가 https://tools.ietf.org/html/rfc7538에서 정의된 `308`로 변경되었습니다.

### Active Storage는 이제 이미지 처리를 필요로 합니다.

Active Storage에서 변형을 처리할 때, `mini_magick`을 직접 사용하는 대신 [image_processing gem](https://github.com/janko/image_processing)을 번들로 포함해야 합니다. Image Processing은 기본적으로 `mini_magick`을 내부적으로 사용하도록 구성되어 있으므로 업그레이드하는 가장 쉬운 방법은 `mini_magick` 젬을 `image_processing` 젬으로 대체하고 `combine_options`의 명시적 사용을 제거하는 것입니다.

가독성을 위해 원시 `resize` 호출을 `image_processing` 매크로로 변경할 수 있습니다. 예를 들어:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

다음과 같이 변경할 수 있습니다:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### 새로운 `ActiveModel::Error` 클래스

오류는 이제 새로운 `ActiveModel::Error` 클래스의 인스턴스로, API에 변경 사항이 있습니다. 오류를 어떻게 조작하는지에 따라 일부 변경 사항은 오류를 발생시킬 수 있으며, 다른 변경 사항은 Rails 7.0을 위해 수정해야 할 경고 메시지를 출력합니다.

이 변경 사항에 대한 자세한 정보 및 API 변경 사항에 대한 자세한 내용은 [이 PR](https://github.com/rails/rails/pull/32313)에서 확인할 수 있습니다.

Rails 5.2에서 Rails 6.0으로 업그레이드하기
-------------------------------------

Rails 6.0에 대한 변경 사항에 대한 자세한 정보는 [릴리스 노트](6_0_release_notes.html)를 참조하십시오.

### Webpacker 사용하기
[Webpacker](https://github.com/rails/webpacker)는 Rails 6의 기본 JavaScript 컴파일러입니다. 그러나 앱을 업그레이드하는 경우 기본적으로 활성화되지 않습니다.
Webpacker를 사용하려면 Gemfile에 포함하고 설치해야 합니다:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### SSL 강제

컨트롤러의 `force_ssl` 메소드는 더 이상 사용되지 않으며 Rails 6.1에서 제거될 예정입니다. HTTPS 연결을 강제로 사용하려면 [`config.force_ssl`][]을 활성화하는 것이 좋습니다.
일부 엔드포인트를 리디렉션에서 제외하려면 [`config.ssl_options`][]을 사용하여 해당 동작을 구성할 수 있습니다.


### 목적 및 만료 메타데이터는 이제 보안을 강화하기 위해 서명된 및 암호화된 쿠키 내에 포함됩니다.

보안을 강화하기 위해 Rails는 암호화된 또는 서명된 쿠키 값 내에 목적 및 만료 메타데이터를 포함시킵니다.

Rails는 쿠키의 서명/암호화된 값을 복사하여 다른 쿠키의 값으로 사용하려는 공격을 방지할 수 있습니다.

이 새로운 포함된 메타데이터는 Rails 6.0보다 오래된 버전과 호환되지 않습니다.

쿠키를 Rails 5.2 및 이전 버전에서 읽어야 하는 경우 또는 6.0 배포를 유효성 검사하고 롤백할 수 있도록 하려면
`Rails.application.config.action_dispatch.use_cookies_with_metadata`를 `false`로 설정하세요.

### 모든 npm 패키지가 `@rails` 범위로 이동되었습니다.

이전에 `actioncable`, `activestorage`, `rails-ujs` 패키지를 npm/yarn을 통해 로드하던 경우, 이러한 종속성의 이름을 업그레이드하기 전에 업데이트해야 합니다. `6.0.0`로:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Action Cable JavaScript API 변경 사항

Action Cable JavaScript 패키지가 CoffeeScript에서 ES2015로 변환되었으며, 이제 소스 코드를 npm 배포에서 게시합니다.

이 릴리스에는 Action Cable JavaScript API의 선택적 부분에 몇 가지 중단 사항이 포함되어 있습니다:

- WebSocket 어댑터 및 로거 어댑터의 구성이 `ActionCable`의 속성에서 `ActionCable.adapters`의 속성으로 이동되었습니다.
  이러한 어댑터를 구성하는 경우 다음 변경 사항을 수행해야 합니다:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- `ActionCable.startDebugging()` 및 `ActionCable.stopDebugging()`
  메소드가 제거되고 속성 `ActionCable.logger.enabled`로 대체되었습니다.
  이러한 메소드를 사용 중이라면 다음 변경 사항을 수행해야 합니다:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type`은 이제 수정 없이 Content-Type 헤더를 반환합니다.

이전에 `ActionDispatch::Response#content_type`의 반환 값은 문자셋 부분을 포함하지 않았습니다.
이 동작은 이전에 생략된 문자셋 부분을 포함하도록 변경되었습니다.

MIME 유형만 원하는 경우 `ActionDispatch::Response#media_type`을 사용하세요.

이전:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

이후:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### 새로운 `config.hosts` 설정

Rails에는 이제 보안을 위한 새로운 `config.hosts` 설정이 있습니다. 이 설정은 개발 환경에서 기본적으로 `localhost`로 설정됩니다. 개발 중에 다른 도메인을 사용하는 경우 다음과 같이 허용해야 합니다:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # 선택적으로 정규식도 허용됩니다
```

다른 환경에서는 `config.hosts`가 기본적으로 비어 있으므로 Rails는 호스트를 검증하지 않습니다. 필요한 경우 프로덕션에서 검증하려면 선택적으로 추가할 수 있습니다.

### 자동로딩

Rails 6의 기본 구성은 다음과 같습니다.

```ruby
# config/application.rb

config.load_defaults 6.0
```

CRuby에서 `zeitwerk` 자동로딩 모드가 활성화됩니다. 이 모드에서는 자동로딩, 다시로딩 및 이저 로딩이 [Zeitwerk](https://github.com/fxn/zeitwerk)에 의해 관리됩니다.

이전 Rails 버전의 기본값을 사용하는 경우 다음과 같이 zeitwerk를 활성화할 수 있습니다:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### 공개 API

일반적으로 애플리케이션은 Zeitwerk의 API를 직접 사용할 필요가 없습니다. Rails는 `config.autoload_paths`, `config.cache_classes` 등의 기존 계약에 따라 설정을 수행합니다.

애플리케이션은 해당 인터페이스를 사용해야 하지만, 실제 Zeitwerk 로더 객체는 다음과 같이 액세스할 수 있습니다.

```ruby
Rails.autoloaders.main
```

예를 들어 Single Table Inheritance (STI) 클래스를 사전로드하거나 사용자 정의 인플렉터를 구성해야 하는 경우 유용할 수 있습니다.

#### 프로젝트 구조

업그레이드하는 애플리케이션이 올바르게 자동로드되는 경우 프로젝트 구조는 이미 대부분 호환될 것입니다.

그러나 `classic` 모드는 누락된 상수 이름(`underscore`)에서 파일 이름을 추론하지만, `zeitwerk` 모드는 파일 이름(`camelize`)에서 상수 이름을 추론합니다. 이러한 도우미는 서로 항상 역이 아닙니다. 특히 약어가 포함된 경우에는 그렇습니다. 예를 들어, `"FOO".underscore`는 `"foo"`이지만, `"foo".camelize`는 `"Foo"`가 아니라 `"FOO"`입니다.
호환성은 `zeitwerk:check` 작업을 사용하여 확인할 수 있습니다:

```bash
$ bin/rails zeitwerk:check
잠시만 기다려주세요, 애플리케이션을 이저 로딩하고 있습니다.
모두 좋습니다!
```

#### require_dependency

`require_dependency`의 모든 사용 사례가 제거되었으므로 프로젝트를 검색하고 삭제해야 합니다.

애플리케이션이 단일 테이블 상속을 사용하는 경우 Autoloading and Reloading Constants (Zeitwerk Mode) 가이드의 [Single Table Inheritance section](autoloading_and_reloading_constants.html#single-table-inheritance)을 참조하십시오.

#### 클래스 및 모듈 정의에서의 정규화된 이름

이제 클래스 및 모듈 정의에서 상수 경로를 안정적으로 사용할 수 있습니다:

```ruby
# 이 클래스의 본문에서의 Autoloading은 이제 Ruby의 의미론과 일치합니다.
class Admin::UsersController < ApplicationController
  # ...
end
```

주의해야 할 점은 실행 순서에 따라 클래식 오토로더가 때로는 다음과 같이 `Foo::Wadus`를 자동으로 로드할 수 있습니다.

```ruby
class Foo::Bar
  Wadus
end
```

이는 `Foo`가 중첩에 없기 때문에 Ruby의 의미론과 일치하지 않으며 `zeitwerk` 모드에서 전혀 작동하지 않습니다. 이러한 코너 케이스를 발견하면 정규화된 이름 `Foo::Wadus`를 사용할 수 있습니다.

```ruby
class Foo::Bar
  Foo::Wadus
end
```

또는 중첩에 `Foo`를 추가할 수 있습니다.

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

다음과 같은 표준 구조에서 자동로드 및 이저 로드할 수 있습니다.

```
app/models
app/models/concerns
```

이 경우 `app/models/concerns`는 루트 디렉토리로 간주됩니다(autoload 경로에 속하기 때문에) 그리고 네임스페이스로서 무시됩니다. 따라서 `app/models/concerns/foo.rb`는 `Concerns::Foo`가 아닌 `Foo`를 정의해야 합니다.

`Concerns::` 네임스페이스는 구현의 부작용으로 클래식 오토로더에서 작동하지만 실제로 의도된 동작은 아닙니다. `Concerns::`를 사용하는 애플리케이션은 `zeitwerk` 모드에서 실행할 수 있도록 해당 클래스와 모듈의 이름을 변경해야 합니다.

#### `app`을 autoload 경로에 추가하기

일부 프로젝트는 `app/api/base.rb`와 같은 구조로 `API::Base`를 정의하고 `classic` 모드에서 이를 수행하기 위해 `app`을 autoload 경로에 추가하려고 합니다. Rails는 자동으로 `app`의 모든 하위 디렉토리를 autoload 경로에 추가하므로 이는 또 다른 상황입니다. 위에서 설명한 `concerns`와 유사한 원리입니다.

이러한 구조를 유지하려면 초기화 파일에서 autoload 경로에서 하위 디렉토리를 삭제해야 합니다.

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Autoloaded Constants and Explicit Namespaces

파일에서 네임스페이스가 정의된 경우, 여기에서 `Hotel`처럼:

```
app/models/hotel.rb         # Hotel을 정의합니다.
app/models/hotel/pricing.rb # Hotel::Pricing을 정의합니다.
```

`Hotel` 상수는 `class` 또는 `module` 키워드를 사용하여 설정되어야 합니다. 예를 들어:

```ruby
class Hotel
end
```

는 올바릅니다.

다음과 같은 대안은 작동하지 않습니다.

```ruby
Hotel = Class.new
```

또는

```ruby
Hotel = Struct.new
```

와 같이 작성된 경우 `Hotel::Pricing`과 같은 하위 객체를 찾을 수 없습니다.

이 제한은 명시적인 네임스페이스에만 적용됩니다. 네임스페이스를 정의하지 않은 클래스와 모듈은 이러한 관용구를 사용하여 정의할 수 있습니다.

#### 한 파일에 한 개의 상수 (동일한 최상위 수준에서)

`classic` 모드에서는 한 최상위 수준에 여러 상수를 정의하고 모두 다시 로드할 수 있었습니다. 예를 들어 다음과 같이 주어진 경우

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

`Bar`는 자동로드되지 않을 수 있지만 `Foo`를 자동로드하면 `Bar`도 자동로드됩니다. 그러나 `zeitwerk` 모드에서는 `Bar`를 자체 파일 `bar.rb`로 이동해야 합니다. 한 파일에 한 개의 상수.

이는 위의 예제와 같은 최상위 수준의 상수에만 적용됩니다. 내부 클래스와 모듈은 괜찮습니다. 예를 들어 다음을 고려해 보십시오.

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

애플리케이션이 `Foo`를 다시 로드하면 `Foo::InnerClass`도 다시 로드됩니다.

#### Spring과 `test` 환경

Spring은 무언가 변경되면 애플리케이션 코드를 다시 로드합니다. `test` 환경에서는 이를 작동하려면 다시 로드를 활성화해야 합니다.

```ruby
# config/environments/test.rb

config.cache_classes = false
```

그렇지 않으면 다음 오류가 발생합니다.

```
reloading is disabled because config.cache_classes is true
```

#### Bootsnap

Bootsnap은 최소한 버전 1.4.2여야 합니다.

또한 Bootsnap은 Ruby 2.5에서 실행 중인 경우 인터프리터의 버그로 인해 iseq 캐시를 비활성화해야 합니다. 이 경우 최소한 Bootsnap 1.4.4에 의존하도록 해야 합니다.

#### `config.add_autoload_paths_to_load_path`

새로운 구성 지점 [`config.add_autoload_paths_to_load_path`][]은 기본적으로 `true`로 설정되어 있어 하위 호환성을 위해 autoload 경로를 `$LOAD_PATH`에 추가하지 않도록 설정할 수 있습니다.

대부분의 애플리케이션에서는 `app/models`와 같은 파일을 절대로 요구해서는 안 되며 Zeitwerk은 내부적으로 절대 파일 이름만 사용합니다.
옵트아웃을 선택함으로써 `$LOAD_PATH` 조회를 최적화할 수 있으며 (확인할 디렉토리가 적어짐), 이러한 디렉토리에 대한 인덱스를 빌드할 필요가 없으므로 Bootsnap 작업 및 메모리 사용량을 절약할 수 있습니다.

#### 스레드 안전성

클래식 모드에서 상수 자동로딩은 스레드 안전하지 않지만, 예를 들어 개발 환경에서 자동로딩이 활성화되어 있는 경우 웹 요청을 스레드 안전하게 만들기 위해 Rails에는 잠금이 있습니다.

`zeitwerk` 모드에서는 상수 자동로딩이 스레드 안전합니다. 예를 들어, `runner` 명령으로 실행되는 멀티스레드 스크립트에서 이제 자동로딩을 사용할 수 있습니다.

#### config.autoload_paths에서 와일드카드 사용

다음과 같은 구성에 주의하세요.

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

`config.autoload_paths`의 각 요소는 최상위 네임스페이스(`Object`)를 나타내야 하며, 이러한 요소는 중첩될 수 없습니다(`concerns` 디렉토리는 예외입니다).

이를 수정하려면 와일드카드를 제거하세요.

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### 이젠 로딩과 자동로딩은 일관성이 있습니다.

`classic` 모드에서 `app/models/foo.rb`가 `Bar`를 정의하는 경우 해당 파일을 자동로딩할 수 없지만, 이젠 로딩은 파일을 재귀적으로 무작위로 로드하기 때문에 작동합니다. 이는 실행 시 자동로딩이 실패할 수 있으므로 먼저 이젠 로딩을 테스트하면 오류가 발생할 수 있습니다.

`zeitwerk` 모드에서는 두 로딩 모드가 일관성이 있으며, 동일한 파일에서 실패하고 오류가 발생합니다.

#### Rails 6에서 클래식 자동로더 사용 방법

클래식 자동로더를 사용하려면 `config.autoloader`를 다음과 같이 설정하여 Rails 6 기본값을 로드할 수 있습니다.

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Rails 6 애플리케이션에서 클래식 자동로더를 사용할 때는 스레드 안전성 문제로 인해 개발 환경에서 웹 서버 및 백그라운드 프로세서의 동시성 수준을 1로 설정하는 것이 좋습니다.

### Active Storage 할당 동작 변경

Rails 5.2의 기본 구성으로는 `has_many_attached`로 선언된 첨부 파일 컬렉션에 할당할 때 새 파일이 추가됩니다.

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

Rails 6.0의 기본 구성으로는 첨부 파일 컬렉션에 할당할 때 기존 파일을 추가하는 대신 기존 파일을 대체합니다. 이는 컬렉션 연관을 할당할 때 Active Record 동작과 일치합니다.

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach`를 사용하여 기존 첨부 파일을 제거하지 않고 새 첨부 파일을 추가할 수 있습니다.

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

기존 애플리케이션은 [`config.active_storage.replace_on_assign_to_many`][]를 `true`로 설정하여 이 새로운 동작을 사용할 수 있습니다. 이전 동작은 Rails 7.0에서 폐지 예정이며, Rails 7.1에서 제거될 예정입니다.


### 사용자 정의 예외 처리 애플리케이션

잘못된 `Accept` 또는 `Content-Type` 요청 헤더는 이제 예외를 발생시킵니다.
기본 [`config.exceptions_app`][]은 해당 오류를 처리하고 보상합니다.
사용자 정의 예외 애플리케이션도 해당 오류를 처리해야 하며, 그렇지 않으면 해당 요청은 Rails가 대체 예외 애플리케이션을 사용하여 `500 Internal Server Error`를 반환합니다.


Rails 5.1에서 Rails 5.2로 업그레이드
-------------------------------------

Rails 5.2에서 수행된 변경 사항에 대한 자세한 정보는 [릴리스 노트](5_2_release_notes.html)를 참조하세요.

### Bootsnap

Rails 5.2에서는 [새로 생성된 앱의 Gemfile](https://github.com/rails/rails/pull/29313)에 bootsnap 젬이 추가되었습니다.
`app:update` 명령은 `boot.rb`에서 이를 설정합니다. 사용하려면 Gemfile에 추가하세요.

```ruby
# 캐싱을 통해 부팅 시간을 줄입니다. config/boot.rb에서 필요합니다.
gem 'bootsnap', require: false
```

그렇지 않으면 `boot.rb`를 bootsnap을 사용하지 않도록 변경하세요.

### 서명 또는 암호화된 쿠키의 만료가 이제 쿠키 값에 포함됩니다.

보안을 강화하기 위해 Rails는 이제 만료 정보를 암호화된 또는 서명된 쿠키 값에도 포함시킵니다.

이 새로 추가된 정보로 인해 이러한 쿠키는 5.2 이전 버전의 Rails와 호환되지 않습니다.

쿠키를 5.1 및 이전 버전에서 읽어야 하는 경우 또는 5.2 배포를 유효성 검사하고 롤백할 수 있도록 하려면
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption`을 `false`로 설정하세요.

Rails 5.0에서 Rails 5.1로 업그레이드
-------------------------------------

Rails 5.1에서 수행된 변경 사항에 대한 자세한 정보는 [릴리스 노트](5_1_release_notes.html)를 참조하세요.

### 최상위 `HashWithIndifferentAccess`는 소프트로 폐지됩니다.

애플리케이션이 최상위 `HashWithIndifferentAccess` 클래스를 사용하는 경우
코드를 점진적으로 변경하여 `ActiveSupport::HashWithIndifferentAccess`를 사용하도록 해야 합니다.
현재는 소프트로 deprecated되었으며, 코드가 깨지지 않고 경고 메시지가 표시되지 않지만, 이 상수는 나중에 제거될 것입니다.

또한, 이러한 객체의 덤프를 포함하는 매우 오래된 YAML 문서가 있다면, 올바른 상수를 참조하도록 다시 로드하고 덤프해야 하며, 이를 로드하는 것이 미래에 깨지지 않도록 해야 합니다.

### `application.secrets`의 모든 키가 심볼로 로드됨

애플리케이션이 중첩된 구성을 `config/secrets.yml`에 저장하는 경우, 모든 키가 심볼로 로드됩니다. 따라서 문자열을 사용하여 액세스해야 합니다.

기존:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

변경:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### `render`에서 `:text`와 `:nothing`의 지원이 제거됨

컨트롤러에서 `render :text`를 사용하는 경우 더 이상 작동하지 않습니다. `text/plain` MIME 유형으로 텍스트를 렌더링하는 새로운 방법은 `render :plain`을 사용하는 것입니다.

마찬가지로, `render :nothing`도 제거되었으며, 헤더만 포함하는 응답을 보내려면 `head` 메서드를 사용해야 합니다. 예를 들어, `head :ok`는 본문이 없는 200 응답을 보냅니다.

### `redirect_to :back`의 지원이 제거됨

Rails 5.0에서 `redirect_to :back`은 deprecated되었으며, Rails 5.1에서 완전히 제거되었습니다.

대신 `redirect_back`을 사용하세요. `redirect_back`은 `HTTP_REFERER`가 없는 경우에 사용할 `fallback_location` 옵션도 사용할 수 있다는 점에 유의해야 합니다.

```ruby
redirect_back(fallback_location: root_path)
```


Rails 4.2에서 Rails 5.0으로 업그레이드하기
-------------------------------------

Rails 5.0에 대한 변경 사항에 대한 자세한 정보는 [릴리스 노트](5_0_release_notes.html)를 참조하십시오.

### Ruby 2.2.2+가 필요합니다

Ruby on Rails 5.0부터 Ruby 2.2.2+만 지원됩니다. 진행하기 전에 Ruby 2.2.2 버전 이상인지 확인하십시오.

### Active Record 모델은 이제 기본적으로 ApplicationRecord에서 상속됩니다

Rails 4.2에서 Active Record 모델은 `ActiveRecord::Base`에서 상속됩니다. Rails 5.0에서는 모든 모델이 `ApplicationRecord`에서 상속됩니다.

`ApplicationRecord`는 앱 모델의 새로운 슈퍼클래스로, 앱 컨트롤러가 `ActionController::Base` 대신 `ApplicationController`를 상속하는 것과 유사합니다. 이를 통해 앱에서 전체 모델 동작을 구성할 수 있는 단일 지점을 제공합니다.

Rails 4.2에서 Rails 5.0으로 업그레이드할 때는 `app/models/`에 `application_record.rb` 파일을 생성하고 다음 내용을 추가해야 합니다:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

그런 다음 모든 모델이 이를 상속하도록 확인하십시오.

### `throw(:abort)`를 통한 콜백 체인 중단

Rails 4.2에서 Active Record 및 Active Model에서 'before' 콜백이 `false`를 반환하면 전체 콜백 체인이 중단됩니다. 즉, 연속적인 'before' 콜백이 실행되지 않으며, 콜백으로 래핑된 작업도 실행되지 않습니다.

Rails 5.0에서 Active Record 또는 Active Model 콜백에서 `false`를 반환하면 콜백 체인이 중단되는 이러한 부작용이 없습니다. 대신 `throw(:abort)`를 호출하여 명시적으로 콜백 체인을 중단해야 합니다.

Rails 4.2에서 Rails 5.0으로 업그레이드할 때는 이러한 유형의 콜백에서 `false`를 반환하면 여전히 콜백 체인이 중단되지만, 이 변경 사항에 대한 경고 메시지를 받게 됩니다.

준비가 되면, `config/application.rb`에 다음 구성을 추가하여 새로운 동작으로 전환하고 경고 메시지를 제거할 수 있습니다:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

이 옵션은 Active Support 콜백에는 영향을 주지 않으며, 반환 값이 있는 경우에도 체인이 중단되지 않았습니다.

자세한 내용은 [#17227](https://github.com/rails/rails/pull/17227)를 참조하십시오.

### ActiveJob은 이제 기본적으로 ApplicationJob에서 상속됩니다

Rails 4.2에서 Active Job은 `ActiveJob::Base`에서 상속됩니다. Rails 5.0에서는 이 동작이 변경되어 `ApplicationJob`에서 상속됩니다.

Rails 4.2에서 Rails 5.0으로 업그레이드할 때는 `app/jobs/`에 `application_job.rb` 파일을 생성하고 다음 내용을 추가해야 합니다:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

그런 다음 모든 작업 클래스가 이를 상속하도록 확인하십시오.

자세한 내용은 [#19034](https://github.com/rails/rails/pull/19034)를 참조하십시오.

### Rails 컨트롤러 테스트

#### 일부 도우미 메서드를 `rails-controller-testing`으로 추출

`assigns`와 `assert_template`은 `rails-controller-testing` 젬으로 추출되었습니다. 컨트롤러 테스트에서 이러한 메서드를 계속 사용하려면 `Gemfile`에 `gem 'rails-controller-testing'`을 추가하십시오.

테스트에 RSpec를 사용하는 경우, 젬의 문서에서 필요한 추가 구성을 확인하십시오.

#### 파일 업로드 시 새로운 동작

테스트에서 `ActionDispatch::Http::UploadedFile`을 사용하여 파일을 업로드하는 경우, 비슷한 `Rack::Test::UploadedFile` 클래스를 사용하도록 변경해야 합니다.
자세한 내용은 [#26404](https://github.com/rails/rails/issues/26404)를 참조하십시오.

### 프로덕션 환경에서 부팅 후에 자동로딩이 비활성화됩니다.

이제 기본적으로 프로덕션 환경에서 부팅 후에 자동로딩이 비활성화됩니다.

응용 프로그램의 eager 로딩은 부팅 프로세스의 일부이므로 상위 수준의 상수는 정상적으로 자동로딩되며 파일을 요구할 필요가 없습니다.

일반 메소드 본문과 같이 런타임에 실행되는 깊은 위치의 상수도 정상적으로 작동합니다. 이는 부팅 중에 eager 로딩되는 파일에 의해 정의됩니다.

대부분의 응용 프로그램에서는 이 변경 사항에 대해 추가 조치가 필요하지 않습니다. 그러나 프로덕션에서 실행 중에 자동로딩이 필요한 매우 드문 경우에는 `Rails.application.config.enable_dependency_loading`을 true로 설정하십시오.

### XML 직렬화

`ActiveModel::Serializers::Xml`이 Rails에서 `activemodel-serializers-xml` 젬으로 분리되었습니다. 응용 프로그램에서 XML 직렬화를 계속 사용하려면 `Gemfile`에 `gem 'activemodel-serializers-xml'`을 추가하십시오.

### 레거시 `mysql` 데이터베이스 어댑터 지원 제거

Rails 5에서는 레거시 `mysql` 데이터베이스 어댑터를 지원하지 않습니다. 대부분의 사용자는 `mysql2`를 대신 사용할 수 있습니다. 유지 관리자를 찾으면 별도의 젬으로 변환될 것입니다.

### 디버거 지원 제거

Ruby 2.2에서는 `debugger`가 지원되지 않습니다. Rails 5에서는 `byebug`를 사용하십시오.

### 작업 및 테스트 실행을 위해 `bin/rails` 사용

Rails 5에서는 작업 및 테스트를 rake 대신 `bin/rails`를 통해 실행할 수 있습니다. 일반적으로 이러한 변경 사항은 rake와 병렬로 이루어집니다. 그러나 일부는 완전히 이식되었습니다.

새로운 테스트 러너를 사용하려면 `bin/rails test`를 입력하십시오.

`rake dev:cache`는 이제 `bin/rails dev:cache`입니다.

명령어 목록을 보려면 응용 프로그램의 루트 디렉토리에서 `bin/rails`를 실행하십시오.

### `ActionController::Parameters`가 더 이상 `HashWithIndifferentAccess`를 상속하지 않습니다.

응용 프로그램에서 `params`를 호출하면 해시 대신 객체가 반환됩니다. 이미 허용된 매개변수를 사용하는 경우 변경 사항을 가질 필요가 없습니다. `permitted?`와 관계없이 해시를 읽을 수 있는 `map` 및 기타 메소드를 사용하는 경우 응용 프로그램을 업그레이드하여 먼저 허용한 다음 해시로 변환해야 합니다.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery`의 기본값은 이제 `prepend: false`입니다.

`protect_from_forgery`의 기본값은 `prepend: false`로 변경되었습니다. 이는 응용 프로그램에서 호출하는 지점에서 콜백 체인에 삽입됩니다. `protect_from_forgery`를 항상 먼저 실행하려면 응용 프로그램을 변경하여 `protect_from_forgery prepend: true`를 사용하십시오.

### 기본 템플릿 핸들러는 이제 RAW입니다.

확장자에 템플릿 핸들러가 없는 파일은 RAW 핸들러를 사용하여 렌더링됩니다. 이전에 Rails는 ERB 템플릿 핸들러를 사용하여 파일을 렌더링했습니다.

RAW 핸들러를 통해 파일을 처리하지 않으려면 적절한 템플릿 핸들러에 의해 구문 분석될 수 있는 확장자를 파일에 추가해야 합니다.

### 템플릿 종속성에 대한 와일드카드 매칭 추가

이제 템플릿 종속성에 와일드카드 매칭을 사용할 수 있습니다. 예를 들어, 다음과 같이 템플릿을 정의하고 있다면:

```erb
<% # Template Dependency: recordings/threads/events/subscribers_changed %>
<% # Template Dependency: recordings/threads/events/completed %>
<% # Template Dependency: recordings/threads/events/uncompleted %>
```

와일드카드를 사용하여 종속성을 한 번 호출할 수 있습니다.

```erb
<% # Template Dependency: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper`가 외부 젬(record_tag_helper)로 이동되었습니다.

`content_tag_for` 및 `div_for`는 `content_tag`만 사용하도록 변경되었습니다. 이전 방법을 계속 사용하려면 `Gemfile`에 `record_tag_helper` 젬을 추가하십시오.

```ruby
gem 'record_tag_helper', '~> 1.0'
```

자세한 내용은 [#18411](https://github.com/rails/rails/pull/18411)을 참조하십시오.

### `protected_attributes` 젬 지원 제거

`protected_attributes` 젬은 더 이상 Rails 5에서 지원되지 않습니다.

### `activerecord-deprecated_finders` 젬 지원 제거

`activerecord-deprecated_finders` 젬은 더 이상 Rails 5에서 지원되지 않습니다.

### `ActiveSupport::TestCase`의 기본 테스트 순서는 이제 무작위입니다.

테스트가 응용 프로그램에서 실행될 때 기본 순서는 이제 `:random`이 아닌 `:sorted`입니다. 다음 구성 옵션을 사용하여 다시 `:sorted`로 설정하십시오.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live`가 `Concern`이 되었습니다.

컨트롤러에 포함된 다른 모듈에서 `ActionController::Live`를 포함하는 경우 모듈을 `ActiveSupport::Concern`로 확장해야 합니다. 또는 `StreamingSupport`가 포함된 후에 `ActionController::Live`를 컨트롤러에 직접 포함하도록 `self.included` 훅을 사용할 수 있습니다.

따라서 응용 프로그램에 자체 스트리밍 모듈이 있는 경우 다음 코드는 프로덕션에서 작동하지 않습니다.
```ruby
# 이것은 Warden/Devise와 함께 스트리밍 컨트롤러에서 인증을 수행하기 위한 해결책입니다.
# https://github.com/plataformatec/devise/issues/2332 참조
# 라우터에서 인증하는 것은 해당 문제에서 제안된 다른 해결책입니다.
class StreamingSupport
  include ActionController::Live # 이것은 Rails 5에서는 프로덕션에서 작동하지 않습니다.
  # extend ActiveSupport::Concern # 이 줄을 주석 처리하지 않는 한 작동하지 않습니다.

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

### 새로운 프레임워크 기본값

#### Active Record `belongs_to` 기본으로 필수 설정

`belongs_to`는 이제 기본적으로 연관이 없으면 유효성 오류를 발생시킵니다.

`optional: true`로 각 연관에 대해 이를 비활성화할 수 있습니다.

이 기본값은 새로운 애플리케이션에서 자동으로 구성됩니다. 기존 애플리케이션에서 이 기능을 추가하려면 초기화 파일에서 활성화해야 합니다:

```ruby
config.active_record.belongs_to_required_by_default = true
```

이 설정은 기본적으로 모든 모델에 대해 전역으로 적용되지만, 모델별로 재정의할 수 있습니다. 이를 통해 모든 모델을 기본적으로 연관이 필요한 상태로 마이그레이션하는 데 도움이 될 것입니다.

```ruby
class Book < ApplicationRecord
  # 모델은 아직 기본적으로 연관이 필요하지 않은 상태입니다.

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # 모델은 기본적으로 연관이 필요한 상태입니다.

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### 폼별 CSRF 토큰

Rails 5는 JavaScript로 생성된 폼과의 코드 주입 공격에 대비하기 위해 폼별 CSRF 토큰을 지원합니다. 이 옵션을 켜면 애플리케이션의 각 폼마다 해당 액션과 메소드에 특정한 CSRF 토큰이 생성됩니다.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### 출처 확인을 통한 Forgery 보호

애플리케이션에서 HTTP `Origin` 헤더를 사이트의 출처와 비교하여 추가적인 CSRF 방어를 할 수 있도록 구성할 수 있습니다. 다음을 설정하여 활성화합니다:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Action Mailer 큐 이름 구성 가능

기본 메일러 큐 이름은 `mailers`입니다. 이 구성 옵션을 사용하면 전역적으로 큐 이름을 변경할 수 있습니다. 다음을 설정합니다:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Action Mailer 뷰에서 Fragment Caching 지원

[`config.action_mailer.perform_caching`][]을 설정하여 Action Mailer 뷰에서 캐싱을 지원할지 여부를 결정할 수 있습니다.

```ruby
config.action_mailer.perform_caching = true
```

#### `db:structure:dump`의 출력 구성

`schema_search_path`나 다른 PostgreSQL 확장을 사용하는 경우, 스키마를 어떻게 덤프할지 제어할 수 있습니다. `:all`로 설정하여 모든 덤프를 생성하거나 `:schema_search_path`로 설정하여 스키마 검색 경로에서 생성합니다.

```ruby
config.active_record.dump_schemas = :all
```

#### 서브도메인에서 HSTS를 사용하도록 SSL 옵션 구성

서브도메인을 사용할 때 HSTS를 활성화하려면 다음을 설정합니다:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### 수신자의 타임존 보존

Ruby 2.4를 사용할 때 `to_time`을 호출할 때 수신자의 타임존을 보존할 수 있습니다.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### JSON/JSONB 직렬화 변경 사항

Rails 5.0에서 JSON/JSONB 속성의 직렬화 및 역직렬화 방식이 변경되었습니다. 이제 `String`으로 열을 설정하면 Active Record는 해당 문자열을 `Hash`로 변환하지 않고 문자열 그대로 반환합니다. 이는 모델과 상호작용하는 코드뿐만 아니라 `db/schema.rb`의 `:default` 열 설정에도 영향을 줍니다. `String`으로 열을 설정하지 않고 자동으로 JSON 문자열로 변환되는 `Hash`를 전달하는 것이 권장됩니다.

Rails 4.1에서 Rails 4.2로 업그레이드하는 경우
--------------------------------------------

### 웹 콘솔

먼저, `Gemfile`의 `:development` 그룹에 `gem 'web-console', '~> 2.0'`을 추가하고 `bundle install`을 실행하여 설치합니다(업그레이드할 때 포함되지 않았을 것입니다). 설치된 후, 원하는 뷰에 콘솔 도우미를 추가하기 위해 참조(`<%= console %>`)를 뷰에 추가할 수 있습니다. 개발 환경에서 보는 오류 페이지에도 콘솔이 제공됩니다.

### Responders

`respond_with`와 클래스 레벨의 `respond_to` 메소드가 `responders` 젬으로 분리되었습니다. 사용하려면 `Gemfile`에 `gem 'responders', '~> 2.0'`을 추가하면 됩니다. `respond_with`와 `respond_to`에 대한 호출(다시 말하지만, 클래스 레벨에서)은 `responders` 젬을 의존성에 포함하지 않으면 더 이상 작동하지 않습니다.
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

인스턴스 레벨 `respond_to`는 영향을 받지 않으며 추가적인 gem이 필요하지 않습니다:

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

자세한 내용은 [#16526](https://github.com/rails/rails/pull/16526)을 참조하십시오.

### 트랜잭션 콜백에서의 오류 처리

현재, Active Record는 `after_rollback` 또는 `after_commit` 콜백에서 발생한 오류를 억제하고 로그에만 출력합니다. 다음 버전에서는 이러한 오류가 더 이상 억제되지 않습니다. 대신, 이러한 오류는 다른 Active Record 콜백과 마찬가지로 정상적으로 전파됩니다.

`after_rollback` 또는 `after_commit` 콜백을 정의할 때, 이러한 변경 사항에 대한 사용 중지 경고를 받게 됩니다. 준비가 되면 다음 구성을 `config/application.rb`에 추가하여 새로운 동작을 선택하고 사용 중지 경고를 제거할 수 있습니다:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

자세한 내용은 [#14488](https://github.com/rails/rails/pull/14488) 및
[#16537](https://github.com/rails/rails/pull/16537)을 참조하십시오.

### 테스트 케이스의 순서

Rails 5.0에서는 기본적으로 테스트 케이스가 무작위로 실행됩니다. 이 변경을 대비하여 Rails 4.2에서는 테스트 순서를 명시적으로 지정하기 위한 새로운 구성 옵션 `active_support.test_order`를 도입했습니다. 이를 통해 현재 동작을 `:sorted`로 고정하거나 미래 동작을 `:random`으로 선택할 수 있습니다.

이 옵션에 대한 값을 지정하지 않으면 사용 중지 경고가 발생합니다. 이를 피하기 위해 테스트 환경에 다음 줄을 추가하십시오:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # 또는 `:random`을 선호하는 경우
end
```

### 직렬화된 속성

사용자 정의 코더(예: `serialize :metadata, JSON`)를 사용할 때, 직렬화된 속성에 `nil`을 할당하면 `nil` 값을 코더를 통과시키지 않고 데이터베이스에 `NULL`로 저장합니다(예: `JSON` 코더를 사용할 때 `"null"`).

### 프로덕션 로그 레벨

Rails 5에서 프로덕션 환경의 기본 로그 레벨은 `:info`에서 `:debug`로 변경됩니다. 현재 기본값을 유지하려면 다음 줄을 `production.rb`에 추가하십시오:

```ruby
# 현재 기본값과 일치하도록 `:info`로 설정하거나 미래 기본값을 선택하려면 `:debug`로 설정하십시오.
config.log_level = :info
```

### Rails 템플릿에서 `after_bundle`

모든 파일을 버전 관리에 추가하는 Rails 템플릿이 있는 경우, 생성된 binstub을 추가하지 못하는 문제가 발생합니다. 이는 Bundler 이전에 실행되기 때문입니다:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

이제 `git` 호출을 `after_bundle` 블록으로 래핑할 수 있습니다. 이는 binstub이 생성된 후에 실행됩니다.

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

### Rails HTML Sanitizer

애플리케이션에서 HTML 조각을 살균하는 새로운 선택지가 있습니다. 기존의 html-scanner 접근 방식은 이제 공식적으로 폐기되었으며 [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer)를 사용하는 것을 권장합니다.

이는 `sanitize`, `sanitize_css`, `strip_tags`, `strip_links` 메서드가 새로운 구현을 사용하도록 변경되었음을 의미합니다.

이 새로운 살균기는 내부적으로 [Loofah](https://github.com/flavorjones/loofah)를 사용합니다. Loofah는 C 및 Java로 작성된 XML 파서를 래핑하는 Nokogiri를 사용하므로 어떤 Ruby 버전을 사용하더라도 살균이 더 빨라질 것입니다.

새로운 버전은 `sanitize`를 업데이트하여 강력한 살균을 위해 `Loofah::Scrubber`를 사용할 수 있도록 합니다.
[여기에서 일부 살균기 예제를 확인하십시오](https://github.com/flavorjones/loofah#loofahscrubber).

또한 `PermitScrubber`와 `TargetScrubber`라는 두 가지 새로운 살균기가 추가되었습니다. 자세한 내용은 [젬의 readme](https://github.com/rails/rails-html-sanitizer)를 참조하십시오.

`PermitScrubber`와 `TargetScrubber`에 대한 문서에서 요소가 언제 및 어떻게 제거되어야 하는지에 대한 완전한 제어를 얻을 수 있는 방법을 설명합니다.

애플리케이션이 이전 살균기 구현을 사용해야 하는 경우 `Gemfile`에 `rails-deprecated_sanitizer`를 포함하십시오:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM Testing

[`TagAssertions` 모듈](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html)(`assert_tag`과 같은 메서드를 포함)은 [`SelectorAssertions` 모듈](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb)의 `assert_select` 메서드를 선호하는 것으로 [폐기되었습니다](https://github.com/rails/rails-dom-testing).

### 가려진 인증 토큰

SSL 공격을 완화하기 위해 `form_authenticity_token`은 이제 각 요청마다 다르게 변하는 방식으로 가려집니다. 따라서 토큰은 가려진 다음 복호화하여 유효성을 검사합니다. 결과적으로, 정적 세션 CSRF 토큰을 사용하여 비-레일즈 폼에서 요청을 확인하는 전략은 이를 고려해야 합니다.
### 액션 메일러

이전에는 메일러 클래스의 메일러 메소드를 호출하면 해당 인스턴스 메소드가 직접 실행되었습니다. 그러나 Active Job과 `#deliver_later`의 도입으로 이는 더 이상 사실이 아닙니다. Rails 4.2에서는 인스턴스 메소드의 호출이 `deliver_now` 또는 `deliver_later`가 호출될 때까지 지연됩니다. 예를 들어:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # 이 시점에서 Notifier#notify는 아직 호출되지 않음
mail = mail.deliver_now           # "Called"를 출력함
```

대부분의 애플리케이션에는 이로 인해 어떤 차이도 없어야 합니다. 그러나 동기적으로 실행되어야 하는 일부 메일러 메소드가 있고 이전에 동기적인 프록시 동작에 의존했다면 이를 메일러 클래스의 클래스 메소드로 직접 정의해야 합니다:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### 외래 키 지원

마이그레이션 DSL은 외래 키 정의를 지원하도록 확장되었습니다. Foreigner 젬을 사용하고 있다면 제거하는 것을 고려해야 합니다. Rails의 외래 키 지원은 Foreigner의 하위 집합입니다. 즉, 모든 Foreigner 정의를 Rails 마이그레이션 DSL과 완전히 대체할 수 있는 것은 아닙니다.

마이그레이션 절차는 다음과 같습니다:

1. `Gemfile`에서 `gem "foreigner"`를 제거합니다.
2. `bundle install`을 실행합니다.
3. `bin/rake db:schema:dump`를 실행합니다.
4. `db/schema.rb`에 필요한 옵션을 포함한 모든 외래 키 정의가 있는지 확인합니다.

Rails 4.0에서 Rails 4.1로 업그레이드하기
-------------------------------------

### 원격 `<script>` 태그로부터의 CSRF 보호

또는 "왜 테스트가 실패하는 거야!!?" 또는 "내 `<script>` 위젯이 망가졌어!!"

Cross-site request forgery (CSRF) 보호는 이제 JavaScript 응답을 포함한 GET 요청에도 적용됩니다. 이는 제3자 사이트가 `<script>` 태그를 사용하여 JavaScript를 원격으로 참조하여 민감한 데이터를 추출하는 것을 방지합니다.

즉, 다음과 같이 사용하는 기능 및 통합 테스트는 이제 CSRF 보호를 트리거합니다.

```ruby
get :index, format: :js
```

다음과 같이 명시적으로 `XmlHttpRequest`를 테스트하려면 다음으로 전환하세요.

```ruby
xhr :get, :index, format: :js
```

참고: 자체 `<script>` 태그도 기본적으로 교차 출처로 처리되어 차단됩니다. `<script>` 태그에서 JavaScript를 로드하려는 경우 해당 작업에서 CSRF 보호를 명시적으로 건너뛰어야 합니다.

### 스프링

애플리케이션 사전로더로 스프링을 사용하려면 다음을 수행해야 합니다:

1. `Gemfile`에 `gem 'spring', group: :development`을 추가합니다.
2. `bundle install`을 사용하여 스프링을 설치합니다.
3. `bundle exec spring binstub`을 사용하여 스프링 binstub을 생성합니다.

참고: 사용자 정의 rake 작업은 기본적으로 `development` 환경에서 실행됩니다. 다른 환경에서 실행하려면 [Spring README](https://github.com/rails/spring#rake)를 참조하세요.

### `config/secrets.yml`

애플리케이션의 비밀을 저장하기 위해 새로운 `secrets.yml` 규칙을 사용하려면 다음을 수행해야 합니다:

1. `config` 폴더에 다음 내용을 포함하는 `secrets.yml` 파일을 생성합니다.

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. `secret_token.rb` 초기화 파일에서 기존 `secret_key_base`를 사용하여 Rails 애플리케이션을 실행하는 사용자에게 `SECRET_KEY_BASE` 환경 변수를 설정합니다. 또는 기존 `secret_token.rb` 초기화 파일에서 `secret_key_base`를 `secrets.yml`의 `production` 섹션에 복사하여 `<%= ENV["SECRET_KEY_BASE"] %>`를 대체합니다.

3. `secret_token.rb` 초기화 파일을 제거합니다.

4. `rake secret`를 사용하여 `development` 및 `test` 섹션에 대한 새로운 키를 생성합니다.

5. 서버를 재시작합니다.

### 테스트 헬퍼 변경 사항

테스트 헬퍼에 `ActiveRecord::Migration.check_pending!` 호출이 포함되어 있다면 이를 제거할 수 있습니다. 이제 `require "rails/test_help"`를 실행할 때 자동으로 확인이 수행됩니다. 그러나 헬퍼에 이 줄을 남겨두어도 아무런 문제가 없습니다.

### 쿠키 직렬화

Rails 4.1 이전에 생성된 애플리케이션은 쿠키 값을 서명 및 암호화하는 데 `Marshal`을 사용했습니다. 애플리케이션에서 새로운 `JSON` 기반 형식을 사용하려면 다음 내용을 포함하는 초기화 파일을 추가할 수 있습니다:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

이렇게 하면 기존의 `Marshal` 직렬화된 쿠키가 새로운 `JSON` 기반 형식으로 자동으로 마이그레이션됩니다.

`:json` 또는 `:hybrid` 직렬화기를 사용할 때는 모든 Ruby 객체가 JSON으로 직렬화될 수 있는 것은 아니라는 점에 유의해야 합니다. 예를 들어, `Date` 및 `Time` 객체는 문자열로 직렬화되고, `Hash`는 키가 문자열로 변환됩니다.

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
쿠키에는 간단한 데이터 (문자열 및 숫자) 만 저장하는 것이 좋습니다.
복잡한 객체를 저장해야하는 경우, 다음 요청에서 값을 읽을 때 변환을 수동으로 처리해야합니다.

쿠키 세션 저장소를 사용하는 경우 `session` 및 `flash` 해시에도 동일한 규칙이 적용됩니다.

### 플래시 구조 변경

플래시 메시지 키는 [문자열로 정규화](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1)됩니다. 여전히 심볼 또는 문자열을 사용하여 액세스 할 수 있습니다. 플래시를 반복하면 항상 문자열 키가 생성됩니다:

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

플래시 메시지 키를 문자열과 비교하는지 확인하십시오.

### JSON 처리 변경 사항

Rails 4.1에서 JSON 처리와 관련된 몇 가지 주요 변경 사항이 있습니다.

#### MultiJSON 제거

MultiJSON은 [지원 종료](https://github.com/rails/rails/pull/10576)되어 Rails에서 제거되었습니다.

현재 애플리케이션이 MultiJSON에 직접 종속되어 있는 경우 몇 가지 옵션이 있습니다:

1. `Gemfile`에 'multi_json'을 추가하십시오. 이는 앞으로 작동하지 않을 수 있습니다.

2. `obj.to_json` 및 `JSON.parse(str)`을 사용하여 MultiJSON에서 이동하십시오.

경고 : 단순히 `MultiJson.dump` 및 `MultiJson.load`를 `JSON.dump` 및 `JSON.load`로 대체하지 마십시오. 이러한 JSON gem API는 임의의 Ruby 객체를 직렬화하고 역직렬화하기 위해 사용되며 일반적으로 [안전하지 않습니다](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### JSON gem 호환성

과거에는 Rails가 JSON gem과 호환성 문제가 있었습니다. Rails 애플리케이션에서 `JSON.generate` 및 `JSON.dump`을 사용하면 예기치 않은 오류가 발생할 수 있습니다.

Rails 4.1은 JSON gem에서 자체 인코더를 격리함으로써 이러한 문제를 해결했습니다. JSON gem API는 정상적으로 작동하지만 Rails 특정 기능에 액세스 할 수 없습니다. 예를 들어:

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

#### 새로운 JSON 인코더

Rails 4.1의 JSON 인코더는 JSON gem의 이점을 활용하기 위해 다시 작성되었습니다. 대부분의 애플리케이션에는 투명한 변경이 될 것입니다. 그러나 다음 기능은 인코더에서 제거되었습니다.

1. 순환 데이터 구조 감지
2. `encode_json` 후크 지원
3. `BigDecimal` 객체를 문자열 대신 숫자로 인코딩하는 옵션

애플리케이션이 이러한 기능 중 하나에 의존하는 경우 [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder) gem을 `Gemfile`에 추가하여 다시 사용할 수 있습니다.

#### Time 객체의 JSON 표현

시간 구성 요소 (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)가 있는 객체의 `#as_json`은 이제 기본적으로 밀리초 정밀도를 반환합니다. 밀리초 정밀도가 없는 이전 동작을 유지해야하는 경우 초기화기에서 다음을 설정하십시오.

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### 인라인 콜백 블록 내에서 `return` 사용

이전에 Rails는 인라인 콜백 블록에서 다음과 같이 `return`을 사용할 수 있었습니다.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # BAD
end
```

이 동작은 의도적으로 지원되지 않았습니다. `ActiveSupport::Callbacks`의 내부 변경으로 인해 Rails 4.1에서는 더 이상 허용되지 않습니다. 인라인 콜백 블록에서 `return` 문을 사용하면 콜백이 실행될 때 `LocalJumpError`가 발생합니다.

`return`을 사용하는 인라인 콜백 블록은 반환 값을 평가하도록 리팩토링 할 수 있습니다.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # GOOD
end
```

또는 `return`을 선호하는 경우 명시적으로 메서드를 정의하는 것이 좋습니다.

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # GOOD

  private
    def before_save_callback
      false
    end
end
```

이 변경 사항은 Active Record 및 Active Model 콜백뿐만 아니라 Action Controller의 필터 (예 : `before_action`)를 포함하여 Rails에서 콜백이 사용되는 대부분의 위치에 적용됩니다.

자세한 내용은 [이 pull request](https://github.com/rails/rails/pull/13271)를 참조하십시오.

### Active Record 픽스처에서 정의된 메서드

Rails 4.1은 각 픽스처의 ERB를 별도의 컨텍스트에서 평가하므로 픽스처에서 정의된 도우미 메서드는 다른 픽스처에서 사용할 수 없습니다.

여러 픽스처에서 사용되는 도우미 메서드는 `test_helper.rb`에서 새로 도입된 `ActiveRecord::FixtureSet.context_class`에 포함된 모듈에 정의되어야합니다.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n에서 사용 가능한 로케일 강제

Rails 4.1은 이제 I18n 옵션 `enforce_available_locales`를 `true`로 기본 설정합니다. 이는 전달되는 모든 로케일이 `available_locales` 목록에 선언되어야 함을 의미합니다.
다음 구성을 애플리케이션에 추가하여 이를 비활성화하고 I18n이 *어떤* 로케일 옵션도 허용하도록 설정할 수 있습니다.

```ruby
config.i18n.enforce_available_locales = false
```

이 옵션은 사용자 입력이 이전에 알려진 경우에만 로케일 정보로 사용될 수 있도록 보안 조치로 추가되었습니다. 따라서 이 옵션을 비활성화하지 않는 것이 권장되며, 강력한 이유가 없는 한 비활성화하지 않는 것이 좋습니다.

### 관계에 대한 뮤테이터 메서드 호출

`Relation`에는 더 이상 `#map!` 및 `#delete_if`와 같은 뮤테이터 메서드가 없습니다. 이러한 메서드를 사용하기 전에 `#to_a`를 호출하여 `Array`로 변환하십시오.

이는 `Relation`에 직접 뮤테이터 메서드를 호출하는 코드에서 이상한 버그와 혼란을 방지하기 위한 것입니다.

```ruby
# 이렇게 하지 말고
Author.where(name: 'Hank Moody').compact!

# 이제는 이렇게 해야 합니다
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### 기본 스코프 변경

기본 스코프는 이제 체인된 조건에 의해 덮어쓰이지 않습니다.

이전 버전에서 모델에서 `default_scope`를 정의하면 동일한 필드의 체인된 조건에 의해 덮어쓰였습니다. 이제 다른 스코프와 마찬가지로 병합됩니다.

이전:

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

이후:

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

이전 동작을 얻으려면 `unscoped`, `unscope`, `rewhere` 또는 `except`를 사용하여 `default_scope` 조건을 명시적으로 제거해야 합니다.

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

### 문자열에서 콘텐츠 렌더링

Rails 4.1에서는 `:plain`, `:html` 및 `:body` 옵션을 `render`에 도입했습니다. 이러한 옵션은 문자열 기반 콘텐츠를 렌더링하는 우선적인 방법이며, 응답이 전송될 콘텐츠 유형을 지정할 수 있습니다.

* `render :plain`은 콘텐츠 유형을 `text/plain`으로 설정합니다.
* `render :html`은 콘텐츠 유형을 `text/html`로 설정합니다.
* `render :body`는 콘텐츠 유형 헤더를 설정하지 *않습니다*.

보안 측면에서 응답 본문에 마크업이 없는 것으로 예상하지 않는 경우, 응답에 대한 대부분의 브라우저가 안전하지 않은 콘텐츠를 이스케이프하기 때문에 `render :plain`을 사용해야 합니다.

향후 버전에서 `render :text`의 사용을 폐지할 예정입니다. 따라서 대신 더 정확한 `:plain`, `:html` 및 `:body` 옵션을 사용하도록 시작하십시오. `render :text`를 사용하면 콘텐츠가 `text/html`로 전송되므로 보안 위험이 발생할 수 있습니다.

### PostgreSQL JSON 및 hstore 데이터 유형

Rails 4.1에서는 `json` 및 `hstore` 열을 문자열 키가 있는 Ruby `Hash`로 매핑합니다. 이전 버전에서는 `HashWithIndifferentAccess`가 사용되었습니다. 이는 심볼 액세스가 더 이상 지원되지 않는다는 것을 의미합니다. 이는 또한 `json` 또는 `hstore` 열을 기반으로 하는 `store_accessors`에도 해당됩니다. 일관되게 문자열 키를 사용하도록 주의하십시오.

### `ActiveSupport::Callbacks`에 대한 명시적 블록 사용

Rails 4.1에서는 `ActiveSupport::Callbacks.set_callback`을 호출할 때 명시적 블록을 전달해야 합니다. 이 변경 사항은 4.1 릴리스를 위해 `ActiveSupport::Callbacks`가 대부분 재작성되었기 때문입니다.

```ruby
# 이전에 Rails 4.0에서
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# 이제 Rails 4.1에서
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Rails 3.2에서 Rails 4.0으로 업그레이드하기
------------------------------------------

현재 애플리케이션이 3.2.x 이전 버전의 Rails에 있는 경우, Rails 4.0으로 업그레이드하기 전에 먼저 Rails 3.2로 업그레이드해야 합니다.

다음 변경 사항은 애플리케이션을 Rails 4.0으로 업그레이드하기 위한 것입니다.

### HTTP PATCH
Rails 4는 `config/routes.rb`에서 RESTful 리소스가 선언될 때 업데이트에 대한 주요 HTTP 동사로 `PATCH`를 사용합니다. `update` 액션은 여전히 사용되며, `PUT` 요청도 여전히 `update` 액션으로 라우팅됩니다. 따라서 표준 RESTful 라우트만 사용하는 경우 변경할 필요가 없습니다:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # 변경할 필요 없음; PATCH가 우선되며, PUT도 작동합니다.
  end
end
```

그러나 `PUT` HTTP 메서드를 사용하는 사용자 정의 경로와 함께 리소스를 업데이트하기 위해 `form_for`를 사용하는 경우 변경해야 합니다:

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
    # 변경 필요; form_for는 존재하지 않는 PATCH 경로를 사용하려고 시도합니다.
  end
end
```

만약 액션이 공개 API에서 사용되지 않고 HTTP 메서드를 변경할 수 있다면, 라우트를 `put` 대신 `patch`를 사용하도록 업데이트할 수 있습니다:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

Rails 4에서 `/users/:id`로의 `PUT` 요청은 오늘과 같이 `update`로 라우팅됩니다. 따라서 실제 `PUT` 요청을 받는 API가 있다면 작동할 것입니다. 라우터는 또한 `PATCH` 요청도 `/users/:id`로 `update` 액션으로 라우팅합니다.

액션이 공개 API에서 사용되고 사용 중인 HTTP 메서드를 변경할 수 없다면, 폼을 `PUT` 메서드를 사용하도록 업데이트할 수 있습니다:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

PATCH에 대한 자세한 내용 및 이 변경이 왜 이루어졌는지에 대해서는 [이 게시물](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/)을 참조하십시오.

#### 미디어 유형에 대한 참고 사항

`PATCH` 동사에 대한 정정 [사양에서 'diff' 미디어 유형을 사용해야 한다고 명시](http://www.rfc-editor.org/errata_search.php?rfc=5789)합니다. 이러한 형식 중 하나는 [JSON Patch](https://tools.ietf.org/html/rfc6902)입니다. Rails는 JSON Patch를 기본적으로 지원하지 않지만, 지원을 추가하는 것은 매우 쉽습니다:

```ruby
# 컨트롤러에서:
def update
  respond_to do |format|
    format.json do
      # 부분 업데이트 수행
      @article.update params[:article]
    end

    format.json_patch do
      # 복잡한 변경 수행
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

JSON Patch는 최근에 RFC로 만들어졌기 때문에 아직 훌륭한 Ruby 라이브러리는 많지 않습니다. Aaron Patterson의 [hana](https://github.com/tenderlove/hana)는 그러한 젬 중 하나이지만, 사양의 마지막 몇 가지 변경을 완전히 지원하지는 않습니다.

### Gemfile

Rails 4.0은 `Gemfile`에서 `assets` 그룹을 제거했습니다. 업그레이드할 때 해당 줄을 `Gemfile`에서 제거해야 합니다. 또한 응용 프로그램 파일을 업데이트해야 합니다(`config/application.rb`):

```ruby
# 테스트, 개발 또는 프로덕션으로 제한한 모든 젬을 포함하여 Gemfile에 나열된 젬을 요구합니다.
Bundler.require(*Rails.groups)
```

### vendor/plugins

Rails 4.0은 더 이상 `vendor/plugins`에서 플러그인을 로드하지 않습니다. 플러그인을 젬으로 추출하고 `Gemfile`에 추가해야 합니다. 젬으로 만들지 않을 경우, 해당 플러그인을 `lib/my_plugin/*`로 이동하고 `config/initializers/my_plugin.rb`에 적절한 초기화 파일을 추가할 수 있습니다.

### Active Record

* Rails 4.0은 Active Record에서 identity map을 제거했습니다. 이는 [연관성과 일관성에 일부 불일치가 있어서](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6)입니다. 애플리케이션에서 수동으로 활성화한 경우 더 이상 효과가 없는 다음 구성을 제거해야 합니다: `config.active_record.identity_map`.

* 컬렉션 연관에서 `delete` 메서드는 이제 레코드 대신 `Integer` 또는 `String` 인수를 받을 수 있습니다. 이전에는 이러한 인수에 대해 `ActiveRecord::AssociationTypeMismatch`를 발생시켰습니다. Rails 4.0부터 `delete`는 삭제하기 전에 주어진 ID와 일치하는 레코드를 자동으로 찾으려고 시도합니다.

* Rails 4.0에서 열 또는 테이블 이름을 변경하면 관련된 인덱스도 변경됩니다. 인덱스를 이름 변경하는 마이그레이션이 있다면 더 이상 필요하지 않습니다.

* Rails 4.0은 `serialized_attributes`와 `attr_readonly`를 이제 클래스 메서드로만 변경했습니다. 더 이상 인스턴스 메서드를 사용해서는 안 되므로 클래스 메서드를 사용하도록 변경해야 합니다. 예를 들어 `self.serialized_attributes`를 `self.class.serialized_attributes`로 변경해야 합니다.

* 기본 코더를 사용하는 경우, 직렬화된 속성에 `nil`을 할당하면 `NULL`로 데이터베이스에 저장되며 YAML(`"--- \n...\n"`)을 통해 `nil` 값을 전달하지 않습니다.
* Rails 4.0에서는 `attr_accessible`와 `attr_protected` 기능을 Strong Parameters로 대체했습니다. 원활한 업그레이드 경로를 위해 [Protected Attributes gem](https://github.com/rails/protected_attributes)을 사용할 수 있습니다.

* Protected Attributes를 사용하지 않는 경우, `whitelist_attributes` 또는 `mass_assignment_sanitizer` 옵션과 관련된 모든 옵션을 제거할 수 있습니다.

* Rails 4.0에서는 스코프가 Proc 또는 람다와 같은 호출 가능한 객체를 사용해야 합니다:

    ```ruby
      scope :active, where(active: true)

      # 변경 후
      scope :active, -> { where active: true }
    ```

* Rails 4.0에서는 `ActiveRecord::Fixtures`를 `ActiveRecord::FixtureSet`으로 대체했습니다.

* Rails 4.0에서는 `ActiveRecord::TestCase`를 `ActiveSupport::TestCase`로 대체했습니다.

* Rails 4.0에서는 구식 해시 기반 검색 API를 폐기했습니다. 이는 이전에 "finder options"를 허용했던 메서드들이 더 이상 허용하지 않음을 의미합니다. 예를 들어, `Book.find(:all, conditions: { name: '1984' })`는 `Book.where(name: '1984')`로 대체되었습니다.

* `find_by_...` 및 `find_by_...!`를 제외한 모든 동적 메서드들이 폐기되었습니다.
  변경 사항을 처리하는 방법은 다음과 같습니다:

      * `find_all_by_...`           -> `where(...)`
      * `find_last_by_...`          -> `where(...).last`
      * `scoped_by_...`             -> `where(...)`
      * `find_or_initialize_by_...` -> `find_or_initialize_by(...)`
      * `find_or_create_by_...`     -> `find_or_create_by(...)`

* `where(...)`는 이전 구현과 동일한 SQL을 실행하지 않을 수 있습니다.

* 구식 검색기를 다시 활성화하려면 [activerecord-deprecated_finders gem](https://github.com/rails/activerecord-deprecated_finders)를 사용할 수 있습니다.

* Rails 4.0에서는 `has_and_belongs_to_many` 관계에 대한 기본 조인 테이블이 두 번째 테이블 이름에서 공통 접두사를 제거하도록 변경되었습니다. 공통 접두사가 있는 모델 간의 기존 `has_and_belongs_to_many` 관계는 `join_table` 옵션으로 지정해야 합니다. 예를 들어:

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* 접두사는 스코프도 고려하므로 `Catalog::Category`와 `Catalog::Product` 또는 `Catalog::Category`와 `CatalogProduct` 간의 관계도 마찬가지로 업데이트해야 합니다.

### Active Resource

Rails 4.0에서는 Active Resource를 독립적인 gem으로 분리했습니다. 이 기능이 필요한 경우 `Gemfile`에 [Active Resource gem](https://github.com/rails/activeresource)을 추가할 수 있습니다.

### Active Model

* Rails 4.0에서는 `ActiveModel::Validations::ConfirmationValidator`와 함께 오류를 첨부하는 방식을 변경했습니다. 이제 확인 유효성 검사가 실패하면 오류가 `:#{attribute}_confirmation`에 첨부되고 이전에는 `attribute`에 첨부되었습니다.

* Rails 4.0에서는 `ActiveModel::Serializers::JSON.include_root_in_json`의 기본값을 `false`로 변경했습니다. 이제 Active Model Serializers와 Active Record 객체는 동일한 기본 동작을 가지게 됩니다. 따라서 `config/initializers/wrap_parameters.rb` 파일에서 다음 옵션을 주석 처리하거나 제거할 수 있습니다:

    ```ruby
    # 기본적으로 JSON에서 루트 요소 비활성화
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* Rails 4.0에서는 `ActiveSupport::KeyGenerator`를 도입하고 이를 기반으로 서명된 쿠키를 생성하고 확인합니다. 기존에 Rails 3.x에서 생성된 서명된 쿠키는 기존의 `secret_token`을 그대로 두고 새로운 `secret_key_base`를 추가하면 자동으로 업그레이드됩니다.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = '기존의 비밀 토큰'
      Myapp::Application.config.secret_key_base = '새로운 비밀 키 베이스'
    ```

    이 때, `secret_key_base`를 설정하는 것은 사용자의 100%가 Rails 4.x로 업그레이드되고 Rails 3.x로 롤백할 필요가 없다고 확신할 때까지 기다려야 합니다. 이는 Rails 4.x에서 `secret_key_base`를 기반으로 서명된 쿠키가 Rails 3.x와 호환되지 않기 때문입니다. 기존의 `secret_token`을 그대로 두고 새로운 `secret_key_base`를 설정하지 않고 업그레이드가 완료될 때까지 폐기 경고를 무시할 수 있습니다.

    Rails 앱의 서명된 세션 쿠키(또는 일반적인 서명된 쿠키)를 외부 애플리케이션이나 JavaScript가 읽을 수 있도록 하는 기능에 의존하는 경우, 이러한 관심사를 분리할 때까지 `secret_key_base`를 설정하지 않아야 합니다.

* Rails 4.0에서는 `secret_key_base`가 설정되었을 경우 쿠키 기반 세션의 내용을 암호화합니다. Rails 3.x는 쿠키 기반 세션의 내용을 서명하지만 암호화하지 않았습니다. 서명된 쿠키는 앱에서 생성된 것임과 변조 방지가 보장되는 "안전한" 쿠키입니다. 그러나 내용은 최종 사용자가 볼 수 있으며, 내용을 암호화하면 이러한 주의사항/관심사를 제거할 수 있습니다. 이는 성능에 큰 영향을 주지 않고 이점을 제공합니다.

    암호화된 세션 쿠키로의 이동에 대한 자세한 내용은 [Pull Request #9978](https://github.com/rails/rails/pull/9978)를 참조하십시오.

* Rails 4.0에서는 `ActionController::Base.asset_path` 옵션을 제거했습니다. 대신 assets pipeline 기능을 사용하십시오.
* Rails 4.0에서는 `ActionController::Base.page_cache_extension` 옵션이 사용되지 않습니다. 대신 `ActionController::Base.default_static_extension`을 사용하세요.

* Rails 4.0에서는 Action과 Page 캐싱이 Action Pack에서 제거되었습니다. 컨트롤러에서 `caches_action`을 사용하려면 `actionpack-action_caching` 젬을 추가해야하고, `caches_page`를 사용하려면 `actionpack-page_caching`을 추가해야합니다.

* Rails 4.0에서는 XML 매개 변수 파서가 제거되었습니다. 이 기능이 필요한 경우 `actionpack-xml_parser` 젬을 추가해야합니다.

* Rails 4.0에서는 심볼 또는 nil을 반환하는 프록스를 사용하여 기본 `layout` 조회 설정이 변경되었습니다. "no layout" 동작을 얻으려면 nil 대신 false를 반환해야합니다.

* Rails 4.0에서는 기본 memcached 클라이언트를 `memcache-client`에서 `dalli`로 변경했습니다. 업그레이드하려면 `Gemfile`에 간단히 `gem 'dalli'`을 추가하면 됩니다.

* Rails 4.0에서는 컨트롤러에서 `dom_id` 및 `dom_class` 메서드를 사용하지 않도록 사용되지 않습니다 (뷰에서는 사용 가능). 이 기능이 필요한 컨트롤러에는 `ActionView::RecordIdentifier` 모듈을 포함해야합니다.

* Rails 4.0에서는 `link_to` 헬퍼의 `:confirm` 옵션이 사용되지 않습니다. 대신 데이터 속성을 사용해야합니다 (예: `data: { confirm: 'Are you sure?' }`). 이 변경 사항은 `link_to_if` 또는 `link_to_unless`와 같은 이 헬퍼를 기반으로 한 도우미에도 적용됩니다.

* Rails 4.0에서는 `assert_generates`, `assert_recognizes`, `assert_routing`이 작동하는 방식이 변경되었습니다. 이제 이러한 어설션 중 하나가 `ActionController::RoutingError` 대신 `Assertion`을 발생시킵니다.

* Rails 4.0에서는 충돌하는 이름을 가진 라우트가 정의되면 `ArgumentError`가 발생합니다. 이는 명시적으로 정의된 이름을 가진 라우트 또는 `resources` 메서드에 의해 트리거 될 수 있습니다. `example_path`라는 이름을 가진 라우트와 충돌하는 두 가지 예제가 있습니다:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    첫 번째 경우에는 여러 라우트에 동일한 이름을 사용하지 않도록 간단히 피할 수 있습니다. 두 번째 경우에는 `resources` 메서드에서 제공되는 `only` 또는 `except` 옵션을 사용하여 생성되는 라우트를 제한할 수 있습니다. 자세한 내용은 [Routing Guide](routing.html#restricting-the-routes-created)를 참조하십시오.

* Rails 4.0에서는 유니코드 문자 라우트를 그리는 방식도 변경되었습니다. 이제 직접 유니코드 문자 라우트를 그릴 수 있습니다. 이미 이러한 라우트를 그리고 있다면 변경해야합니다. 예를 들어:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    다음과 같이 변경됩니다:

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0에서는 `match`를 사용하는 라우트는 요청 메서드를 지정해야합니다. 예를 들어:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # becomes
      match '/' => 'root#index', via: :get

      # or
      get '/' => 'root#index'
    ```

* Rails 4.0에서는 `ActionDispatch::BestStandardsSupport` 미들웨어가 제거되었습니다. `<!DOCTYPE html>`은 이미 표준 모드를 트리거하며 https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx에서 ChromeFrame 헤더가 `config.action_dispatch.default_headers`로 이동되었습니다.

    응용 프로그램 코드에서 미들웨어에 대한 참조도 제거해야합니다. 예를 들어:

    ```ruby
    # Raise exception
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    또한 `config.action_dispatch.best_standards_support`의 환경 설정도 확인하고 있으면 제거해야합니다.

* Rails 4.0에서는 `config.action_dispatch.default_headers`를 설정하여 HTTP 헤더를 구성할 수 있습니다. 기본값은 다음과 같습니다:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    애플리케이션이 `<frame>` 또는 `<iframe>`에서 특정 페이지를 로드하는 것에 의존하는 경우 `X-Frame-Options`를 명시적으로 `ALLOW-FROM ...` 또는 `ALLOWALL`로 설정해야 할 수도 있습니다.

* Rails 4.0에서는 자바스크립트 및 CSS가 아닌 자산을 자동으로 `vendor/assets` 및 `lib/assets`에서 복사하지 않습니다. Rails 애플리케이션 및 엔진 개발자는 이러한 자산을 `app/assets`에 넣거나 [`config.assets.precompile`]을 구성해야합니다.

* Rails 4.0에서는 액션이 요청 형식을 처리하지 않을 때 `ActionController::UnknownFormat`가 발생합니다. 기본적으로 예외는 406 Not Acceptable로 응답합니다. 그러나 이제 이를 재정의할 수 있습니다. Rails 3에서는 항상 406 Not Acceptable이 반환되었습니다. 재정의하지 않습니다.

* Rails 4.0에서는 `ParamsParser`가 요청 매개 변수를 구문 분석하지 못할 때 일반적인 `ActionDispatch::ParamsParser::ParseError` 예외가 발생합니다. 예를 들어 이 예외를 낮은 수준의 `MultiJson::DecodeError` 대신 처리해야합니다.

* Rails 4.0에서는 엔진이 URL 접두사에서 제공되는 앱에 마운트되었을 때 `SCRIPT_NAME`이 올바르게 중첩됩니다. 더 이상 `default_url_options[:script_name]`을 설정하여 덮어 쓴 URL 접두사를 해결하기 위해 설정할 필요가 없습니다.

* Rails 4.0에서는 `ActionController::Integration`이 `ActionDispatch::Integration`을 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::IntegrationTest`가 `ActionDispatch::IntegrationTest`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::PerformanceTest`가 `ActionDispatch::PerformanceTest`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::AbstractRequest`가 `ActionDispatch::Request`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::Request`가 `ActionDispatch::Request`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::AbstractResponse`가 `ActionDispatch::Response`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::Response`가 `ActionDispatch::Response`를 대체하기 위해 사용되지 않습니다.
* Rails 4.0에서는 `ActionController::Routing`이 `ActionDispatch::Routing`을 대체하기 위해 사용되지 않습니다.
### Active Support

Rails 4.0은 `j`를 `ERB::Util#json_escape`의 별칭에서 제거했습니다. 왜냐하면 `j`는 이미 `ActionView::Helpers::JavaScriptHelper#escape_javascript`에 사용되고 있기 때문입니다.

#### Cache

Rails 3.x와 4.0 사이에 캐싱 방법이 변경되었습니다. [캐시 네임스페이스를 변경](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store)하고 콜드 캐시로 롤아웃해야 합니다.

### Helpers 로딩 순서

여러 디렉토리에서 가져온 헬퍼의 로딩 순서가 Rails 4.0에서 변경되었습니다. 이전에는 헬퍼들이 수집되고 알파벳 순으로 정렬되었습니다. Rails 4.0으로 업그레이드한 후에는 헬퍼들은 로딩된 디렉토리의 순서를 유지하고 각 디렉토리 내에서만 알파벳 순으로 정렬됩니다. `helpers_path` 매개변수를 명시적으로 사용하지 않는 한, 이 변경은 엔진에서 헬퍼를 로딩하는 방식에만 영향을 미칩니다. 순서에 의존하는 경우, 업그레이드 후에 올바른 메소드가 사용 가능한지 확인해야 합니다. 엔진이 로딩되는 순서를 변경하려면 `config.railties_order=` 메소드를 사용할 수 있습니다.

### Active Record Observer와 Action Controller Sweeper

`ActiveRecord::Observer`와 `ActionController::Caching::Sweeper`는 `rails-observers` 젬으로 분리되었습니다. 이 기능을 사용하려면 `rails-observers` 젬을 추가해야 합니다.

### sprockets-rails

* `assets:precompile:primary`와 `assets:precompile:all`이 제거되었습니다. 대신 `assets:precompile`을 사용하세요.
* `config.assets.compress` 옵션은 [`config.assets.js_compressor`][]로 변경되어야 합니다. 예를 들어 다음과 같이 변경하세요:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```


### sass-rails

* 두 개의 인수를 사용하는 `asset-url`은 사용되지 않습니다. 예를 들어: `asset-url("rails.png", image)`는 `asset-url("rails.png")`로 변경됩니다.

Rails 3.1에서 Rails 3.2로 업그레이드하기
-------------------------------------

현재 애플리케이션이 3.1.x 이전의 Rails 버전에 있는 경우, 업그레이드를 시도하기 전에 먼저 Rails 3.1로 업그레이드해야 합니다.

다음 변경 사항은 애플리케이션을 최신 3.2.x 버전의 Rails로 업그레이드하기 위한 것입니다.

### Gemfile

`Gemfile`에서 다음 변경 사항을 수행하세요.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

개발 환경에 다음 구성 설정을 추가해야 합니다.

```ruby
# Active Record 모델의 대량 할당 보호에 대한 예외 발생
config.active_record.mass_assignment_sanitizer = :strict

# 이 시간 이상 걸리는 쿼리에 대한 쿼리 계획 로깅 (SQLite, MySQL, PostgreSQL에서 작동)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

`mass_assignment_sanitizer` 구성 설정은 `config/environments/test.rb`에도 추가해야 합니다.

```ruby
# Active Record 모델의 대량 할당 보호에 대한 예외 발생
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

Rails 3.2에서는 `vendor/plugins`를 사용하지 않도록 권장하며, Rails 4.0에서는 완전히 제거될 예정입니다. Rails 3.2 업그레이드의 일부로서 필수적이지는 않지만, 플러그인을 젬으로 추출하고 `Gemfile`에 추가하는 것으로 대체할 수 있습니다. 젬으로 만들지 않을 경우, 해당 플러그인을 `lib/my_plugin/*`로 이동하고 `config/initializers/my_plugin.rb`에 적절한 초기화 코드를 추가할 수 있습니다.

### Active Record

`belongs_to`에서 `:dependent => :restrict` 옵션이 제거되었습니다. 연관된 객체가 있는 경우 객체를 삭제하지 못하도록 하려면 `:dependent => :destroy`를 설정하고 연관된 객체의 삭제 콜백 중 하나에서 연관성의 존재 여부를 확인한 후 `false`를 반환해야 합니다.

Rails 3.0에서 Rails 3.1로 업그레이드하기
-------------------------------------

현재 애플리케이션이 3.0.x 이전의 Rails 버전에 있는 경우, 업그레이드를 시도하기 전에 먼저 Rails 3.0으로 업그레이드해야 합니다.

다음 변경 사항은 애플리케이션을 Rails 3.1.12로 업그레이드하기 위한 것입니다. Rails 3.1.x의 마지막 버전입니다.

### Gemfile

`Gemfile`에서 다음 변경 사항을 수행하세요.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# 새로운 에셋 파이프라인을 위해 필요합니다.
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery는 Rails 3.1의 기본 JavaScript 라이브러리입니다.
gem 'jquery-rails'
```

### config/application.rb

에셋 파이프라인에는 다음 추가 사항이 필요합니다.

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

리소스에 대해 "/assets" 경로를 사용하는 경우, 에셋에 대한 접두사를 충돌을 피하기 위해 변경할 수 있습니다.

```ruby
# 기본값은 '/assets'입니다.
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

RJS 설정 `config.action_view.debug_rjs = true`를 제거하세요.

에셋 파이프라인을 사용하는 경우 다음 설정을 추가하세요.

```ruby
# 에셋을 압축하지 않습니다.
config.assets.compress = false

# 에셋을 로드하는 줄을 확장합니다.
config.assets.debug = true
```

### config/environments/production.rb

다시 말하지만, 아래의 대부분의 변경 사항은 에셋 파이프라인을 위한 것입니다. 이에 대한 자세한 내용은 [에셋 파이프라인](asset_pipeline.html) 가이드를 참조하세요.
```ruby
# JavaScript와 CSS 압축
config.assets.compress = true

# 컴파일된 에셋이 누락된 경우에 에셋 파이프라인으로 fallback하지 않음
config.assets.compile = false

# 에셋 URL에 대한 다이제스트 생성
config.assets.digest = true

# 기본값은 Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# 추가 에셋을 미리 컴파일함 (application.js, application.css, 그리고 모든 JS/CSS 이외의 파일은 이미 추가됨)
# config.assets.precompile += %w( admin.js admin.css )

# 모든 앱 접근을 SSL로 강제하고 Strict-Transport-Security를 사용하며 안전한 쿠키를 사용함
# config.force_ssl = true
```

### config/environments/test.rb

다음 내용을 테스트 환경에 추가하여 성능을 테스트할 수 있습니다:

```ruby
# 성능을 위해 Cache-Control을 사용하여 테스트용 정적 에셋 서버를 구성함
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

파라미터를 중첩된 해시로 래핑하려면 다음 내용이 포함된 파일을 추가하십시오. 이는 새로운 애플리케이션에서 기본적으로 활성화됩니다.

```ruby
# 이 파일을 수정할 때 서버를 다시 시작해야 합니다.
# 이 파일에는 기본적으로 활성화된 ActionController::ParamsWrapper의 설정이 포함되어 있습니다.

# JSON에 대한 파라미터 래핑을 활성화합니다. :format을 빈 배열로 설정하여 이를 비활성화할 수 있습니다.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# 기본적으로 JSON에서 루트 요소를 비활성화합니다.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

세션 키를 새로운 값으로 변경하거나 모든 세션을 제거해야 합니다:

```ruby
# config/initializers/session_store.rb에 추가
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

또는

```bash
$ bin/rake db:sessions:clear
```

### 뷰에서 에셋 도우미 참조에서 :cache와 :concat 옵션 제거

* 에셋 파이프라인에서는 더 이상 :cache와 :concat 옵션이 사용되지 않으므로 뷰에서 이러한 옵션을 삭제하세요.
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
