**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f53b3a12c263256fbbe154cfc8b2f4d
자동로드 및 상수 다시로드
===================================

이 가이드는 `zeitwerk` 모드에서 자동로드 및 다시로드가 작동하는 방법에 대해 문서화합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* 관련된 Rails 구성
* 프로젝트 구조
* 자동로드, 다시로드 및 이저 로딩
* 단일 테이블 상속
* 그리고 더 많은 내용

--------------------------------------------------------------------------------

소개
------------

INFO. 이 가이드는 Rails 애플리케이션에서의 자동로드, 다시로드 및 이저 로딩에 대해 문서화합니다.

일반적인 루비 프로그램에서는 사용하려는 클래스와 모듈을 정의하는 파일을 명시적으로 로드합니다. 예를 들어, 다음 컨트롤러는 `ApplicationController`와 `Post`를 참조하며, 보통 이들을 위해 `require` 호출을 수행합니다:

```ruby
# 이렇게 하지 마세요.
require "application_controller"
require "post"
# 이렇게 하지 마세요.

class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

하지만 Rails 애플리케이션에서는 `require` 호출 없이 어디에서나 애플리케이션 클래스와 모듈을 사용할 수 있습니다:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end
end
```

Rails는 필요한 경우 자동으로 이들을 _자동로드_합니다. 이는 Rails가 제공하는 [Zeitwerk](https://github.com/fxn/zeitwerk) 로더 덕분에 가능한 것으로, 이 로더는 자동로드, 다시로드 및 이저 로딩을 제공합니다.

반면, 이 로더들은 다른 것들을 관리하지 않습니다. 특히, Ruby 표준 라이브러리, 젬 종속성, Rails 컴포넌트 자체 또는 (기본적으로) 애플리케이션 `lib` 디렉토리를 관리하지 않습니다. 이 코드는 평소와 같이 로드되어야 합니다.


프로젝트 구조
-----------------

Rails 애플리케이션에서 파일 이름은 정의하는 상수와 일치해야 하며, 디렉토리는 네임스페이스 역할을 합니다.

예를 들어, `app/helpers/users_helper.rb` 파일은 `UsersHelper`를 정의해야 하며, `app/controllers/admin/payments_controller.rb` 파일은 `Admin::PaymentsController`를 정의해야 합니다.

기본적으로, Rails는 파일 이름을 `String#camelize`로 변환하기 위해 Zeitwerk을 구성합니다. 예를 들어, `"users_controller".camelize`가 반환하는 대로 `app/controllers/users_controller.rb`가 상수 `UsersController`를 정의한다고 기대합니다.

아래의 _Inflections 사용자 정의_ 섹션에서 이 기본값을 재정의하는 방법에 대해 문서화합니다.

자세한 내용은 [Zeitwerk 문서](https://github.com/fxn/zeitwerk#file-structure)를 참조하십시오.

config.autoload_paths
---------------------

자동로드 및 (선택적으로) 다시로드할 애플리케이션 디렉토리 목록을 _자동로드 경로_라고 합니다. 예를 들어, `app/models`와 같은 디렉토리는 루트 네임스페이스인 `Object`를 나타냅니다.

INFO. Zeitwerk 문서에서는 자동로드 경로를 _루트 디렉토리_라고 부르지만, 이 가이드에서는 "자동로드 경로"라는 용어를 사용합니다.

자동로드 경로 내에서 파일 이름은 [여기](https://github.com/fxn/zeitwerk#file-structure)에 문서화된 대로 정의하는 상수와 일치해야 합니다.

기본적으로, 애플리케이션의 자동로드 경로는 애플리케이션이 부팅될 때 존재하는 `app`의 모든 하위 디렉토리 ---`assets`, `javascript` 및 `views` 제외--- 및 의존하는 엔진의 자동로드 경로로 구성됩니다.

예를 들어, `UsersHelper`가 `app/helpers/users_helper.rb`에 구현되어 있다면, 이 모듈은 자동로드 가능하며, `require` 호출을 필요로 하지 않습니다(그리고 작성해서는 안 됩니다):

```bash
$ bin/rails runner 'p UsersHelper'
UsersHelper
```

Rails는 `app` 아래의 사용자 정의 디렉토리를 자동으로 자동로드 경로에 추가합니다. 예를 들어, 애플리케이션에 `app/presenters`가 있다면, 프레젠터를 자동로드하기 위해 별도의 구성이 필요하지 않습니다. 기본적으로 작동합니다.

기본 자동로드 경로 배열은 `config.autoload_paths`에 추가하여 확장할 수 있습니다. `config/application.rb` 또는 `config/environments/*.rb`에서 다음과 같이 수행할 수 있습니다:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_paths << "#{root}/extras"
  end
end
```

또한, 엔진은 엔진 클래스의 본문과 자체 `config/environments/*.rb`에서 푸시할 수 있습니다.

WARNING. `ActiveSupport::Dependencies.autoload_paths`를 변경하지 마십시오. 자동로드 경로를 변경하는 공개 인터페이스는 `config.autoload_paths`입니다.

WARNING: 애플리케이션이 부팅되는 동안 자동로드 경로의 코드를 자동로드할 수 없습니다. 특히, `config/initializers/*.rb`에서 직접로드하지 마십시오. 유효한 방법은 [_애플리케이션이 부팅될 때 자동로드_](#autoloading-when-the-application-boots) 아래에서 확인할 수 있습니다.

자동로드 경로는 `Rails.autoloaders.main` 자동로더에 의해 관리됩니다.

config.autoload_lib(ignore:)
----------------------------

기본적으로, `lib` 디렉토리는 애플리케이션 또는 엔진의 자동로드 경로에 속하지 않습니다.

구성 메서드 `config.autoload_lib`은 `lib` 디렉토리를 `config.autoload_paths` 및 `config.eager_load_paths`에 추가합니다. 이는 `config/application.rb` 또는 `config/environments/*.rb`에서 호출되어야 하며, 엔진에서는 사용할 수 없습니다.

일반적으로, `lib`에는 자동로더가 관리하지 않아야 할 하위 디렉토리가 있습니다. `ignore` 키워드 인수에 `lib`에 대한 상대적인 이름을 전달하십시오. 예를 들어:

```ruby
config.autoload_lib(ignore: %w(assets tasks))
```

왜? `assets`와 `tasks`는 일반 코드와 `lib` 디렉토리를 공유하지만, 그 내용은 자동로드되거나 이저 로드되어서는 안 됩니다. `Assets`와 `Tasks`는 Ruby 네임스페이스가 아닙니다. 생성기도 마찬가지입니다.
```ruby
config.autoload_lib(ignore: %w(assets tasks generators))
```

`config.autoload_lib`는 7.1 이전에는 사용할 수 없지만, 애플리케이션이 Zeitwerk를 사용하는 한 이를 에뮬레이트할 수 있습니다:

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

리로드하지 않고 클래스와 모듈을 자동으로로드 할 수 있도록 하려면 `autoload_once_paths` 구성이 필요합니다. `autoload_once_paths` 구성은 자동으로로드 할 수 있지만 다시로드되지 않을 코드를 저장합니다.

기본적으로이 컬렉션은 비어 있지만 `config.autoload_once_paths`에 추가하여 확장 할 수 있습니다. 이 작업은 `config/application.rb` 또는 `config/environments/*.rb`에서 수행 할 수 있습니다. 예를 들어:

```ruby
module MyApplication
  class Application < Rails::Application
    config.autoload_once_paths << "#{root}/app/serializers"
  end
end
```

또한 엔진은 엔진 클래스의 본문과 자체 `config/environments/*.rb`에서도 추가 할 수 있습니다.

INFO. `app/serializers`가 `config.autoload_once_paths`에 추가되면 Rails는 이것을 `autoload` 경로로 간주하지 않습니다. 이 설정은이 규칙을 무시합니다.

이는 Rails 프레임 워크 자체와 같은 다시로드를 생존하는 위치에 캐시 된 클래스 및 모듈에 대해 중요합니다.

예를 들어, Active Job 직렬화기는 Active Job 내부에 저장됩니다:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

그리고 Active Job 자체는 다시로드되지 않습니다. 다시로드 할 때는 응용 프로그램 및 엔진 코드 만 자동로드 경로에 있습니다.

`MoneySerializer`를 다시로드 할 수있는 것은 혼란 스러울 것입니다. 편집 된 버전을 다시로드하면 Active Job에 저장된 해당 클래스 객체에는 영향을주지 않습니다. 실제로 `MoneySerializer`가 다시로드 가능하면 Rails 7부터이 초기화 프로그램은 `NameError`를 발생시킵니다.

또 다른 사용 사례는 엔진이 프레임 워크 클래스를 장식 할 때입니다:

```ruby
initializer "decorate ActionController::Base" do
  ActiveSupport.on_load(:action_controller_base) do
    include MyDecoration
  end
end
```

여기에서 초기화 프로그램이 실행 될 때 `MyDecoration`에 의해 저장된 모듈 객체는 `ActionController::Base`의 조상이되며 `MyDecoration`을 다시로드하는 것은 의미가 없습니다. 그것은 그 조상 체인에 영향을주지 않습니다.

`autoload_once_paths`에있는 클래스 및 모듈은 `config/initializers`에서 자동으로로드 될 수 있습니다. 따라서이 구성으로 작동합니다:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

INFO : 기술적으로 `once` 오토로더에서 관리하는 클래스와 모듈을 `:bootstrap_hook` 이후에 실행되는 초기화 프로그램에서 자동으로로드 할 수 있습니다.

autoload once 경로는 `Rails.autoloaders.once`에 의해 관리됩니다.

config.autoload_lib_once(ignore:)
---------------------------------

`config.autoload_lib_once` 메서드는 `config.autoload_lib`와 유사하지만 `lib`를 `config.autoload_once_paths`에 추가합니다. 이 메서드는 `config/application.rb` 또는 `config/environments/*.rb`에서 호출해야하며 엔진에서 사용할 수 없습니다.

`config.autoload_lib_once`을 호출하면 `lib`의 클래스와 모듈을 애플리케이션 초기화 프로그램에서도 자동으로로드 할 수 있지만 다시로드되지 않습니다.

`config.autoload_lib_once`은 7.1 이전에는 사용할 수 없지만, 애플리케이션이 Zeitwerk를 사용하는 한 이를 에뮬레이트할 수 있습니다:

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

autoload 경로는 기본적으로 `$LOAD_PATH`에 추가됩니다. 그러나 Zeitwerk는 내부적으로 절대 파일 이름을 사용하며 응용 프로그램은 autoload 가능한 파일에 대해 `require` 호출을 수행하지 않아야하므로 해당 디렉토리는 실제로 필요하지 않습니다. 이 플래그를 사용하여 선택적으로 제외 할 수 있습니다.

```ruby
config.add_autoload_paths_to_load_path = false
```

이렇게하면 합법적인 `require` 호출이 더 적게 발생하므로 약간의 속도가 향상될 수 있습니다. 또한 애플리케이션이 [Bootsnap](https://github.com/Shopify/bootsnap)을 사용하는 경우 라이브러리가 불필요한 인덱스를 작성하지 않도록하여 메모리 사용량을 줄일 수 있습니다.

이 플래그는 `lib` 디렉토리에는 영향을주지 않으며 항상 `$LOAD_PATH`에 추가됩니다.

리로딩
---------

Rails는 autoload 경로의 애플리케이션 파일이 변경되면 클래스와 모듈을 자동으로 다시로드합니다.

더 정확히 말하면, 웹 서버가 실행 중이고 애플리케이션 파일이 수정되었을 때, Rails는 다음 요청이 처리되기 직전에 `main` 오토로더가 관리하는 모든 autoload된 상수를 언로드합니다. 이렇게하면 해당 요청 중에 사용되는 애플리케이션 클래스 또는 모듈이 다시 자동로드되어 파일 시스템의 현재 구현을 사용하게됩니다.

리로딩은 활성화 또는 비활성화 될 수 있습니다. 이 동작을 제어하는 설정은 [`config.enable_reloading`][]입니다. 이 설정은 `development` 모드에서 기본적으로`true`이며`production` 모드에서 기본적으로`false`입니다. 호환성을 위해 Rails는 `config.cache_classes`도 지원하며`!config.enable_reloading`과 동일합니다.

Rails는 기본적으로 파일 변경을 감지하기 위해 이벤트 기반 파일 모니터를 사용합니다. 대신 autoload 경로를 거치면 파일 변경을 감지하도록 구성 할 수 있습니다. 이는 [`config.file_watcher`][] 설정으로 제어됩니다.

Rails 콘솔에서는 `config.enable_reloading`의 값에 관계없이 파일 감시자가 활성화되지 않습니다. 일반적으로 콘솔 세션에서 코드를 리로드하는 것은 혼란 스러울 것입니다. 개별 요청과 마찬가지로 콘솔 세션은 일관되고 변경되지 않는 일련의 응용 프로그램 클래스와 모듈로 제공되기를 원합니다.
그러나 콘솔에서 `reload!`을 실행하여 강제로 다시로드 할 수 있습니다.

```irb
irb(main):001:0> User.object_id
=> 70136277390120
irb(main):002:0> reload!
Reloading...
=> true
irb(main):003:0> User.object_id
=> 70136284426020
```

보시다시피, `User` 상수에 저장된 클래스 객체는 다시로드 후에 다릅니다.


### 다시로드 및 오래된 객체

루비에는 클래스와 모듈을 실제로 메모리에서 다시로드하고 이미 사용 중인 모든 곳에 반영하는 방법이 없다는 것을 이해하는 것이 매우 중요합니다. 기술적으로 "언로드"는 `Object.send(:remove_const, "User")`를 통해 `User` 상수를 제거하는 것을 의미합니다.

예를 들어, 다음과 같은 레일즈 콘솔 세션을 살펴보십시오.

```irb
irb> joe = User.new
irb> reload!
irb> alice = User.new
irb> joe.class == alice.class
=> false
```

`joe`는 원래 `User` 클래스의 인스턴스입니다. 다시로드가 발생하면 `User` 상수는 다시로드된 클래스로 평가됩니다. `alice`는 새로로드된 `User`의 인스턴스입니다. 그러나 `joe`는 새로로드되지 않았으므로 그의 클래스는 오래되었습니다. `reload!`를 호출하는 대신 `joe`를 다시 정의하거나 IRB 하위 세션을 시작하거나 새로운 콘솔을 시작할 수 있습니다.

다시로드 가능한 클래스를 다시로드되지 않는 위치에서 서브클래싱하는 경우에도이 문제를 발견할 수 있습니다.

```ruby
# lib/vip_user.rb
class VipUser < User
end
```

`User`가 다시로드되는 경우 `VipUser`가 다시로드되지 않으므로 `VipUser`의 슈퍼클래스는 원래의 오래된 클래스 객체입니다.

결론적으로, **다시로드 가능한 클래스나 모듈을 캐시하지 마십시오**.

## 응용 프로그램 부팅 시 자동로드

부팅 중에 애플리케이션은 `once` 자동로더가 관리하는 autoload once 경로에서 자동로드 할 수 있습니다. 위의 [`config.autoload_once_paths`](#config-autoload-once-paths) 섹션을 확인하십시오.

그러나 `main` 자동로더가 관리하는 autoload 경로에서는 `config/initializers`에있는 코드 및 응용 프로그램 또는 엔진 초기화기에서 자동로드 할 수 없습니다.

왜냐하면 초기화기는 응용 프로그램이 부팅될 때 한 번만 실행되기 때문입니다. 다시로드시에는 다시 실행되지 않습니다. 초기화기에서 다시로드 가능한 클래스 또는 모듈을 사용하는 경우 해당 초기 코드에 반영되지 않으므로 오래되게됩니다. 따라서 초기화 중에 다시로드 가능한 상수를 참조하는 것은 허용되지 않습니다.

대신 무엇을 해야하는지 살펴보겠습니다.

### 사용 사례 1 : 부팅 중에 다시로드 가능한 코드 로드

#### 부팅 및 각 다시로드시 자동로드

`ApiGateway`가 다시로드 가능한 클래스이고 응용 프로그램이 부팅될 때 엔드포인트를 구성해야하는 경우를 상상해보십시오.

```ruby
# config/initializers/api_gateway_setup.rb
ApiGateway.endpoint = "https://example.com" # NameError
```

초기화기는 다시로드 가능한 상수를 참조 할 수 없으므로 해당 코드를 `to_prepare` 블록으로 래핑해야합니다. 이 블록은 부팅시와 다시로드 후에 실행됩니다.

```ruby
# config/initializers/api_gateway_setup.rb
Rails.application.config.to_prepare do
  ApiGateway.endpoint = "https://example.com" # CORRECT
end
```

참고 : 역사적인 이유로이 콜백은 두 번 실행 될 수 있습니다. 실행되는 코드는 멱등성을 가져야합니다.

#### 부팅시에만 자동로드

다시로드 가능한 클래스와 모듈은 `after_initialize` 블록에서도 자동로드 될 수 있습니다. 이들은 부팅시에 실행되지만 다시로드시에는 다시 실행되지 않습니다. 일부 예외적인 경우에는 이것이 원하는 동작일 수 있습니다.

사전 점검은 이러한 사용 사례입니다.

```ruby
# config/initializers/check_admin_presence.rb
Rails.application.config.after_initialize do
  unless Role.where(name: "admin").exists?
    abort "The admin role is not present, please seed the database."
  end
end
```

### 사용 사례 2 : 부팅 중에 캐시된 코드 로드

일부 구성은 클래스 또는 모듈 객체를 사용하고 이를 다시로드되지 않는 위치에 저장합니다. 이러한 것들이 다시로드 가능하면 안되며, 편집 사항은 해당 캐시된 오래된 객체에 반영되지 않아야합니다.

미들웨어가 예입니다.

```ruby
config.middleware.use MyApp::Middleware::Foo
```

다시로드 할 때 미들웨어 스택은 영향을받지 않으므로 `MyApp::Middleware::Foo`가 다시로드 가능하다면 혼란스러울 것입니다. 구현의 변경은 효과가 없을 것입니다.

다른 예로 Active Job 직렬화기가 있습니다.

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

초기화 중에 `MoneySerializer`가 평가되고 사용자 정의 직렬화기에 푸시되며, 다시로드시에도 그 객체가 그대로 유지됩니다.

또 다른 예는 레일티 또는 엔진이 모듈을 포함하여 프레임워크 클래스를 장식하는 것입니다. 예를 들어, [`turbo-rails`](https://github.com/hotwired/turbo-rails)는 다음과 같이 `ActiveRecord::Base`를 장식합니다.

```ruby
initializer "turbo.broadcastable" do
  ActiveSupport.on_load(:active_record) do
    include Turbo::Broadcastable
  end
end
```

이렇게하면 `Turbo::Broadcastable`의 변경 사항이 다시로드되면 효과가 없으며, 조상 체인에 원래 모듈이 여전히 있습니다.

결론 : 이러한 클래스 또는 모듈은 **다시로드 할 수 없습니다**.

부팅 중에 해당 클래스 또는 모듈을 참조하는 가장 쉬운 방법은 autoload 경로에 속하지 않는 디렉토리에 정의되어 있도록하는 것입니다. 예를 들어, `lib`는 관용적인 선택입니다. 기본적으로 autoload 경로에 속하지 않지만 `$LOAD_PATH`에 속합니다. 일반적인 `require`를 사용하여로드하십시오.
위에서 언급한 대로, 다른 옵션은 autoload.once_paths에 정의된 디렉토리를 autoload에 포함시키는 것입니다. 자세한 내용은 [config.autoload_once_paths](#config-autoload-once-paths) 섹션을 확인하십시오.

### Use Case 3: 엔진을 위한 응용 프로그램 클래스 구성

엔진이 사용자를 모델링하는 reloadable 응용 프로그램 클래스와 함께 작동하고, 이를 위한 구성 지점이 있는 경우를 가정해 봅시다:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = User # NameError
end
```

리로드 가능한 응용 프로그램 코드와 잘 작동하려면, 엔진은 응용 프로그램에서 그 클래스의 _이름_을 구성하도록 해야 합니다:

```ruby
# config/initializers/my_engine.rb
MyEngine.configure do |config|
  config.user_model = "User" # OK
end
```

그런 다음 실행 시간에 `config.user_model.constantize`를 사용하여 현재 클래스 객체를 얻을 수 있습니다.

이저 로딩
-------------

프로덕션과 유사한 환경에서는 응용 프로그램이 부팅될 때 모든 응용 프로그램 코드를 로드하는 것이 일반적으로 좋습니다. 이저 로딩은 요청을 즉시 처리할 준비가 된 상태로 모든 것을 메모리에 로드하며, 또한 [CoW](https://en.wikipedia.org/wiki/Copy-on-write)에 친화적입니다.

이저 로딩은 [`config.eager_load`][] 플래그로 제어됩니다. 이 플래그는 `production` 환경을 제외한 모든 환경에서 기본적으로 비활성화되어 있습니다. Rake 작업이 실행될 때는 `config.eager_load`가 [`config.rake_eager_load`][]에 의해 재정의되며, 기본적으로 `false`입니다. 따라서 기본적으로 프로덕션 환경에서 Rake 작업은 응용 프로그램을 이저 로드하지 않습니다.

파일이 이저 로딩되는 순서는 정의되어 있지 않습니다.

이저 로딩 중에 Rails는 `Zeitwerk::Loader.eager_load_all`을 호출합니다. 이를 통해 Zeitwerk로 관리되는 모든 젬 종속성이 이저 로딩됩니다.



단일 테이블 상속
------------------------

단일 테이블 상속(STI)은 지연 로딩과 잘 어울리지 않습니다: Active Record는 올바르게 작동하기 위해 STI 계층 구조를 인식해야 하지만, 지연 로딩 시에는 클래스가 필요한 경우에만 정확히 로드됩니다!

이 기본적인 불일치를 해결하기 위해 STI를 사전로드해야 합니다. 이를 위해 다양한 트레이드오프가 있는 몇 가지 옵션이 있습니다. 이제 이들을 살펴보겠습니다.

### 옵션 1: 이저 로딩 활성화

STI를 사전로드하는 가장 쉬운 방법은 다음과 같이 이저 로딩을 활성화하는 것입니다:

```ruby
config.eager_load = true
```

`config/environments/development.rb` 및 `config/environments/test.rb`에 설정합니다.

이 방법은 간단하지만, 부팅 시 전체 응용 프로그램을 이저 로드하고 모든 리로드마다 비용이 발생할 수 있습니다. 그러나 작은 응용 프로그램의 경우 트레이드오프는 가치가 있을 수 있습니다.

### 옵션 2: 축소된 디렉토리 사전로드

계층을 정의하는 파일을 전용 디렉토리에 저장하는 것이 개념적으로도 의미가 있습니다. 이 디렉토리는 네임스페이스를 나타내는 것이 아니라 STI를 그룹화하는 것을 목적으로 합니다:

```
app/models/shapes/shape.rb
app/models/shapes/circle.rb
app/models/shapes/square.rb
app/models/shapes/triangle.rb
```

이 예제에서는 `app/models/shapes/circle.rb`가 `Shapes::Circle`가 아닌 `Circle`을 정의하도록 하고 싶습니다. 이것은 간단하게 유지하고 기존 코드 베이스에서 리팩터링을 피하기 위한 개인적인 선호도일 수 있습니다. Zeitwerk의 [collapsing](https://github.com/fxn/zeitwerk#collapsing-directories) 기능을 사용하여 이를 수행할 수 있습니다:

```ruby
# config/initializers/preload_stis.rb

shapes = "#{Rails.root}/app/models/shapes"
Rails.autoloaders.main.collapse(shapes) # 네임스페이스가 아닙니다.

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(shapes)
  end
end
```

이 옵션에서는 이러한 몇 개의 파일을 부팅 시 이저 로드하고 STI가 사용되지 않더라도 리로드합니다. 그러나 응용 프로그램에 STI가 많지 않은 경우에는 측정 가능한 영향이 없을 것입니다.

INFO: `Zeitwerk::Loader#eager_load_dir` 메서드는 Zeitwerk 2.6.2에서 추가되었습니다. 이전 버전의 경우 `app/models/shapes` 디렉토리를 나열하고 그 내용에 `require_dependency`를 호출할 수 있습니다.

WARNING: STI에서 모델이 추가, 수정 또는 삭제되는 경우 리로드는 예상대로 작동합니다. 그러나 새로운 별도의 STI 계층이 응용 프로그램에 추가되는 경우 초기화 파일을 편집하고 서버를 다시 시작해야 합니다.

### 옵션 3: 일반 디렉토리 사전로드

이전 옵션과 유사하지만, 디렉토리가 네임스페이스로 사용되도록 의도되었습니다. 즉, `app/models/shapes/circle.rb`는 `Shapes::Circle`을 정의하는 것으로 예상됩니다.

이 경우, 초기화 파일은 축소가 구성되지 않은 것 외에는 동일합니다:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models/shapes")
  end
end
```

동일한 트레이드오프가 존재합니다.

### 옵션 4: 데이터베이스에서 유형 사전로드

이 옵션에서는 파일을 어떤 방식으로든 구성할 필요가 없지만, 데이터베이스에 접근해야 합니다:

```ruby
# config/initializers/preload_stis.rb

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    types = Shape.unscoped.select(:type).distinct.pluck(:type)
    types.compact.each(&:constantize)
  end
end
```

WARNING: 테이블에 모든 유형이 없더라도 STI는 올바르게 작동하지만, `subclasses` 또는 `descendants`와 같은 메서드는 누락된 유형을 반환하지 않습니다.

WARNING: STI에서 모델이 추가, 수정 또는 삭제되는 경우 리로드는 예상대로 작동합니다. 그러나 새로운 별도의 STI 계층이 응용 프로그램에 추가되는 경우 초기화 파일을 편집하고 서버를 다시 시작해야 합니다.
인플렉션 커스터마이징
-----------------------

기본적으로 Rails는 `String#camelize`를 사용하여 주어진 파일이나 디렉토리 이름이 어떤 상수를 정의해야 하는지 알아냅니다. 예를 들어, `posts_controller.rb`는 `"posts_controller".camelize`가 반환하는 대로 `PostsController`를 정의해야 합니다.

특정 파일이나 디렉토리 이름이 원하는 대로 변형되지 않을 수도 있습니다. 예를 들어, `html_parser.rb`는 기본적으로 `HtmlParser`를 정의해야 합니다. 그러나 클래스를 `HTMLParser`로 선호하는 경우 어떻게 해야 할까요? 이를 커스터마이징하는 몇 가지 방법이 있습니다.

가장 쉬운 방법은 약어를 정의하는 것입니다:

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "HTML"
  inflect.acronym "SSL"
end
```

이렇게 하면 Active Support가 전역적으로 어떻게 변형하는지에 영향을 미칩니다. 일부 응용 프로그램에서는 이것이 괜찮을 수 있지만, Active Support와 독립적으로 개별 기본 이름을 어떻게 camelize할지 커스터마이징하려면 기본 인플렉터에 대한 오버라이드 컬렉션을 전달하여 사용할 수도 있습니다:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

이 기술은 여전히 `String#camelize`에 의존하지만, 이것이 기본 인플렉터가 대체로 사용하는 것입니다. Active Support 인플렉션에 전혀 의존하지 않고 인플렉션을 완전히 제어하고 싶다면, 인플렉터를 `Zeitwerk::Inflector`의 인스턴스로 구성하여 절대적인 제어를 갖도록 설정할 수 있습니다:

```ruby
Rails.autoloaders.each do |autoloader|
  autoloader.inflector = Zeitwerk::Inflector.new
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error"   => "SSLError"
  )
end
```

이러한 인스턴스에 영향을 미칠 수 있는 전역 설정은 없습니다. 이들은 결정론적입니다.

심지어 완전한 유연성을 위해 사용자 정의 인플렉터를 정의할 수도 있습니다. 자세한 내용은 [Zeitwerk 문서](https://github.com/fxn/zeitwerk#custom-inflector)를 확인하십시오.

### 인플렉션 커스터마이징은 어디에 위치해야 할까요?

응용 프로그램이 `once` 오토로더를 사용하지 않는 경우, 위의 코드 조각은 `config/initializers`에 위치할 수 있습니다. 예를 들어, Active Support 사용 사례의 경우 `config/initializers/inflections.rb`, 다른 경우에는 `config/initializers/zeitwerk.rb`와 같이 사용할 수 있습니다.

`once` 오토로더를 사용하는 응용 프로그램은 이 구성을 `config/application.rb`의 응용 프로그램 클래스 본문에서 이동하거나 로드해야 합니다. 왜냐하면 `once` 오토로더는 부팅 프로세스 초기에 인플렉터를 사용하기 때문입니다.

사용자 정의 네임스페이스
-----------------

위에서 보았듯이, 오토로드 경로는 최상위 네임스페이스인 `Object`를 나타냅니다.

예를 들어, `app/services`를 고려해 봅시다. 이 디렉토리는 기본적으로 생성되지 않지만, 존재하는 경우 Rails는 자동으로 오토로드 경로에 추가합니다.

기본 설정에서 `app/services/users/signup.rb` 파일은 `Users::Signup`를 정의해야 합니다. 그러나 그 전체 하위 트리를 `Services` 네임스페이스 아래에 두고 싶다면 어떻게 해야 할까요? 기본 설정에서는 `app/services/services` 하위 디렉토리를 생성하여 이를 수행할 수 있습니다.

그러나 취향에 따라 그렇게 하는 것이 올바르게 느껴지지 않을 수도 있습니다. `app/services/users/signup.rb`가 단순히 `Services::Users::Signup`을 정의하도록 하려면 어떻게 해야 할까요?

Zeitwerk은 [사용자 정의 루트 네임스페이스](https://github.com/fxn/zeitwerk#custom-root-namespaces)를 지원하여 이러한 사용 사례를 해결할 수 있으며, `main` 오토로더를 사용자 정의할 수 있습니다:

```ruby
# config/initializers/autoloading.rb

# 네임스페이스가 존재해야 합니다.
#
# 이 예제에서는 모듈을 그 자리에서 정의합니다. 다른 곳에서 생성될 수도 있으며, 정의는 일반적인 `require`를 사용하여 여기에서 로드된다.
# 어느 경우에든 `push_dir`은 클래스나 모듈 객체를 기대합니다.
module Services; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/services", namespace: Services)
```

Rails 7.1 미만에서는 이 기능을 지원하지 않지만, 동일한 파일에 추가 코드를 추가하여 작동시킬 수 있습니다:

```ruby
# Rails 7.1 미만에서 실행되는 응용 프로그램에 대한 추가 코드.
app_services_dir = "#{Rails.root}/app/services" # 문자열이어야 함
ActiveSupport::Dependencies.autoload_paths.delete(app_services_dir)
Rails.application.config.watchable_dirs[app_services_dir] = [:rb]
```

`once` 오토로더에 대해서도 사용자 정의 네임스페이스를 지원합니다. 그러나 이것은 부팅 프로세스 초기에 설정되기 때문에 응용 프로그램 초기화기에서 구성할 수 없습니다. 대신, 예를 들어 `config/application.rb`에 넣어야 합니다.

오토로딩과 엔진
-----------------------

엔진은 부모 응용 프로그램의 컨텍스트에서 실행되며, 코드는 부모 응용 프로그램에 의해 오토로드되고 다시 로드되며 이전에 로드되었습니다. 응용 프로그램이 `zeitwerk` 모드에서 실행되면 엔진 코드는 `zeitwerk` 모드로 로드됩니다. 응용 프로그램이 `classic` 모드에서 실행되면 엔진 코드는 `classic` 모드로 로드됩니다.

Rails가 부팅될 때, 엔진 디렉토리는 오토로드 경로에 추가되며, 오토로더의 관점에서는 차이가 없습니다. 오토로더의 주요 입력은 오토로드 경로이며, 이 경로가 응용 프로그램 소스 트리에 속하는지 엔진 소스 트리에 속하는지는 중요하지 않습니다.

예를 들어, 이 응용 프로그램은 [Devise](https://github.com/heartcombo/devise)를 사용합니다:

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

엔진이 부모 응용 프로그램의 오토로딩 모드를 제어하는 경우, 엔진은 일반적인 방식으로 작성할 수 있습니다.
그러나 엔진이 Rails 6 또는 Rails 6.1을 지원하고 부모 애플리케이션을 제어하지 않는 경우 `classic` 또는 `zeitwerk` 모드에서 실행할 준비가 되어야 합니다. 고려해야 할 사항은 다음과 같습니다.

1. `classic` 모드에서는 특정 상수가 어느 시점에 로드되도록 `require_dependency` 호출이 필요합니다. `zeitwerk` 모드에서는 필요하지 않지만, `zeitwerk` 모드에서도 작동하기 때문에 문제가 되지 않습니다.

2. `classic` 모드에서는 상수 이름을 밑줄로 구분합니다 ("User" -> "user.rb"), `zeitwerk` 모드에서는 파일 이름을 카멜 표기법으로 구분합니다 ("user.rb" -> "User"). 대부분의 경우 일치하지만, "HTMLParser"와 같이 연속된 대문자로 이루어진 경우에는 일치하지 않습니다. 호환성을 유지하기 가장 쉬운 방법은 이러한 이름을 피하는 것입니다. 이 경우 "HtmlParser"를 선택하세요.

3. `classic` 모드에서는 `app/model/concerns/foo.rb` 파일에서 `Foo`와 `Concerns::Foo`를 모두 정의할 수 있습니다. `zeitwerk` 모드에서는 `Foo`만 정의해야 합니다. 호환성을 유지하기 위해 `Foo`를 정의하세요.

테스트
-------

### 수동 테스트

작업 `zeitwerk:check`는 프로젝트 트리가 예상한 네이밍 규칙을 따르는지 확인하며, 수동으로 확인하기에 편리합니다. 예를 들어, `classic` 모드에서 `zeitwerk` 모드로 마이그레이션하거나, 문제를 수정하는 경우에 유용합니다:

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

애플리케이션 구성에 따라 추가 출력이 있을 수 있지만, 마지막 "All is good!"가 확인하려는 내용입니다.

### 자동화된 테스트

테스트 스위트에서 프로젝트가 올바르게 eager load되는지 확인하는 것은 좋은 관행입니다.

이는 Zeitwerk 네이밍 규칙 준수 및 기타 가능한 오류 조건을 확인합니다. [_Testing Rails Applications_](testing.html) 가이드의 [_Testing Eager Loading_](testing.html#testing-eager-loading) 섹션을 확인하세요.

문제 해결
---------------

로더의 동작을 추적하는 가장 좋은 방법은 그들의 활동을 검사하는 것입니다.

가장 쉬운 방법은 다음을 포함하는 것입니다.

```ruby
Rails.autoloaders.log!
```

`config/application.rb`에서 프레임워크 기본값을 로드한 후에 추가하세요. 이렇게 하면 표준 출력에 추적이 출력됩니다.

파일에 로깅하는 것을 선호하는 경우 다음과 같이 설정하세요.

```ruby
Rails.autoloaders.logger = Logger.new("#{Rails.root}/log/autoloading.log")
```

`config/application.rb`이 실행될 때는 아직 Rails 로거를 사용할 수 없습니다. Rails 로거를 사용하려면 초기화 파일에서 다음 설정을 구성하세요.

```ruby
# config/initializers/log_autoloaders.rb
Rails.autoloaders.logger = Rails.logger
```

Rails.autoloaders
-----------------

애플리케이션을 관리하는 Zeitwerk 인스턴스는 다음에서 사용할 수 있습니다.

```ruby
Rails.autoloaders.main
Rails.autoloaders.once
```

조건부

```ruby
Rails.autoloaders.zeitwerk_enabled?
```

은 Rails 7 애플리케이션에서도 사용할 수 있으며 `true`를 반환합니다.
[`config.enable_reloading`]: configuring.html#config-enable-reloading
[`config.file_watcher`]: configuring.html#config-file-watcher
[`config.eager_load`]: configuring.html#config-eager-load
[`config.rake_eager_load`]: configuring.html#config-rake-eager-load
