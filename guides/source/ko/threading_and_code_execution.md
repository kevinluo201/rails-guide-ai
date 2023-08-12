**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
스레딩과 코드 실행(Rails)
=========================

이 가이드를 읽으면 다음을 알게 됩니다:

* Rails가 자동으로 동시에 실행하는 코드
* 수동 동시성을 Rails 내부와 통합하는 방법
* 모든 애플리케이션 코드를 래핑하는 방법
* 애플리케이션 리로딩에 영향을 주는 방법

--------------------------------------------------------------------------------

자동 동시성
------------

Rails는 여러 작업을 동시에 수행할 수 있도록 자동으로 허용합니다.

기본 Puma와 같은 스레드 기반 웹 서버를 사용할 때, 여러 HTTP 요청이 동시에 처리되며 각 요청은 고유한 컨트롤러 인스턴스가 제공됩니다.

내장된 Async를 포함한 스레드 기반 Active Job 어댑터는 마찬가지로 여러 작업을 동시에 실행합니다. Action Cable 채널도 이 방식으로 관리됩니다.

이러한 메커니즘은 모두 여러 스레드를 사용하며, 각각은 고유한 객체 인스턴스(컨트롤러, 작업, 채널)의 작업을 관리하면서 전역 프로세스 공간(클래스와 그들의 설정, 전역 변수 등)을 공유합니다. 코드가 이러한 공유된 요소를 수정하지 않는 한, 대부분의 경우 다른 스레드가 존재하는 것을 무시할 수 있습니다.

이 가이드의 나머지 부분에서는 Rails가 "대부분 무시 가능하게" 만드는 메커니즘과 특별한 요구 사항을 가진 확장 및 애플리케이션에서 이를 사용하는 방법에 대해 설명합니다.

Executor
--------

Rails Executor는 응용 프로그램 코드와 프레임워크 코드를 분리합니다. 프레임워크가 응용 프로그램에서 작성한 코드를 호출할 때마다 Executor에 의해 래핑됩니다.

Executor는 `to_run`과 `to_complete` 두 개의 콜백으로 구성됩니다. Run 콜백은 응용 프로그램 코드 이전에 호출되며, Complete 콜백은 호출 이후에 호출됩니다.

### 기본 콜백

기본 Rails 애플리케이션에서 Executor 콜백은 다음과 같이 사용됩니다:

* 자동로딩 및 리로딩에 대한 안전한 위치에 있는 스레드를 추적합니다.
* Active Record 쿼리 캐시를 활성화하거나 비활성화합니다.
* 획득한 Active Record 연결을 풀에 반환합니다.
* 내부 캐시 수명을 제한합니다.

Rails 5.0 이전에는 이러한 작업 중 일부는 별도의 Rack 미들웨어 클래스(예: `ActiveRecord::ConnectionAdapters::ConnectionManagement`) 또는 `ActiveRecord::Base.connection_pool.with_connection`과 같은 메서드로 처리되었습니다. Executor는 이러한 작업을 단일 추상 인터페이스로 대체합니다.

### 애플리케이션 코드 래핑

응용 프로그램 코드를 호출하는 라이브러리나 구성 요소를 작성하는 경우 Executor 호출로 래핑해야 합니다:

```ruby
Rails.application.executor.wrap do
  # 여기서 응용 프로그램 코드 호출
end
```

TIP: 장기 실행 프로세스에서 반복적으로 응용 프로그램 코드를 호출하는 경우 [Reloader](#reloader)를 사용하여 래핑하는 것이 좋습니다.

각 스레드는 응용 프로그램 코드를 실행하기 전에 래핑되어야 하므로, 응용 프로그램이 `Thread.new`나 스레드 풀을 사용하는 Concurrent Ruby 기능을 통해 작업을 수동으로 위임하는 경우 블록을 즉시 래핑해야 합니다:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # 여기에 코드 작성
  end
end
```

참고: Concurrent Ruby는 때로는 `executor` 옵션으로 구성된 `ThreadPoolExecutor`를 사용합니다. 이름과는 관련이 없습니다.

Executor는 안전하게 재진입할 수 있습니다. 현재 스레드에서 이미 활성화된 경우 `wrap`은 아무 작업도 수행하지 않습니다.

응용 프로그램 코드를 블록으로 래핑하는 것이 현실적이지 않은 경우(예: Rack API가 이를 방해하는 경우) `run!` / `complete!` 쌍을 사용할 수도 있습니다:

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # 여기에 코드 작성
ensure
  execution_context.complete! if execution_context
end
```

### 동시성

Executor는 현재 스레드를 [Load Interlock](#load-interlock)의 `running` 모드로 설정합니다. 이 작업은 다른 스레드가 현재 상수를 자동로드하거나 애플리케이션을 언로드/리로드하는 경우 일시적으로 블록됩니다.

Reloader
--------

Executor와 마찬가지로 Reloader도 응용 프로그램 코드를 래핑합니다. Executor가 현재 스레드에서 이미 활성화되지 않은 경우, Reloader는 대신에 Executor를 호출하므로 하나만 호출하면 됩니다. 이는 Reloader가 수행하는 모든 작업, 콜백 호출을 포함하여 Executor 내부에서 래핑된다는 것을 보장합니다.

```ruby
Rails.application.reloader.wrap do
  # 여기서 응용 프로그램 코드 호출
end
```

Reloader는 웹 서버나 작업 큐와 같은 장기 실행 프레임워크 수준의 프로세스가 반복적으로 응용 프로그램 코드를 호출하는 경우에만 적합합니다. Rails는 웹 요청과 Active Job 워커를 자동으로 래핑하므로 직접 Reloader를 호출할 필요는 거의 없습니다. 사용 사례에 따라 Executor가 더 적합한지 항상 고려해야 합니다.

### 콜백

래퍼 블록에 진입하기 전에 Reloader는 실행 중인 애플리케이션이 다시 로드되어야 하는지 확인합니다. 예를 들어, 모델의 소스 파일이 수정되었기 때문에 다시 로드해야 할 수 있습니다. 다시 로드가 필요한 경우 안전한 상태가 될 때까지 대기한 다음 계속 진행합니다. 응용 프로그램이 변경 사항이 감지되지 않았더라도 항상 다시 로드되도록 구성된 경우, 다시 로드는 블록의 끝에서 수행됩니다.
리로더는 `to_run` 및 `to_complete` 콜백도 제공합니다. 이들은 Executor의 콜백과 동일한 시점에서 호출되지만, 현재 실행이 애플리케이션 재로드를 시작한 경우에만 호출됩니다. 재로드가 필요하지 않은 경우, 리로더는 다른 콜백 없이 래핑된 블록을 호출합니다.

### 클래스 언로드

재로드 프로세스의 가장 중요한 부분은 클래스 언로드입니다. 여기서 모든 autoload된 클래스가 제거되고 다시로드될 준비가 됩니다. 이는 `reload_classes_only_on_change` 설정에 따라 Run 또는 Complete 콜백 직전에 발생합니다.

일반적으로 클래스 언로드 직전이나 직후에 추가적인 재로드 작업을 수행해야 할 때, 리로더는 `before_class_unload` 및 `after_class_unload` 콜백도 제공합니다.

### 동시성

리로더를 호출해야 하는 것은 오래 실행되는 "상위 레벨" 프로세스뿐입니다. 왜냐하면 리로더가 재로드가 필요하다고 판단하면, 다른 모든 스레드가 Executor 호출을 완료할 때까지 블로킹됩니다.

이것이 "자식" 스레드에서 발생하면, Executor 내부에서 대기 중인 부모 스레드와 불가피한 교착 상태를 발생시킵니다. 재로드는 자식 스레드가 실행되기 전에 발생해야 하지만, 부모 스레드가 실행 중일 때 안전하게 수행될 수 없습니다. 자식 스레드는 대신 Executor를 사용해야 합니다.

프레임워크 동작
------------------

Rails 프레임워크 구성 요소는 자체 동시성 요구 사항을 관리하기 위해 이러한 도구를 사용합니다.

`ActionDispatch::Executor` 및 `ActionDispatch::Reloader`는 Rack 미들웨어로, 요청을 제공된 Executor 또는 Reloader로 래핑합니다. 이들은 기본 애플리케이션 스택에 자동으로 포함됩니다. Reloader는 코드 변경이 발생한 경우 도착하는 모든 HTTP 요청이 최신 코드로 로드된 애플리케이션으로 서비스되도록 보장합니다.

Active Job도 Reloader로 작업 실행을 래핑하여 큐에서 각 작업을 가져올 때마다 최신 코드를 로드합니다.

Action Cable은 대신 Executor를 사용합니다. Cable 연결은 특정 클래스 인스턴스에 연결되기 때문에 도착하는 모든 WebSocket 메시지에 대해 재로드할 수는 없습니다. 그러나 메시지 핸들러만 래핑됩니다. 오래 실행되는 Cable 연결은 새로운 들어오는 요청이나 작업에 의해 트리거된 재로드를 방지하지 않습니다. 대신 Action Cable은 Reloader의 `before_class_unload` 콜백을 사용하여 모든 연결을 끊습니다. 클라이언트가 자동으로 다시 연결되면 코드의 새 버전과 통신하게 됩니다.

위에서 언급한 것은 프레임워크의 진입점이므로, 각각의 스레드가 보호되고 재로드가 필요한지 여부를 결정하는 책임이 있습니다. 다른 구성 요소는 추가 스레드를 생성할 때만 Executor를 사용하면 됩니다.

### 설정

리로더는 `config.enable_reloading`이 `true`이고 `config.reload_classes_only_on_change`도 `true`일 때에만 파일 변경을 확인합니다. 이것들은 `development` 환경의 기본값입니다.

`config.enable_reloading`이 `false`인 경우(`production`의 기본값), 리로더는 Executor로만 전달됩니다.

Executor는 데이터베이스 연결 관리와 같은 중요한 작업을 항상 수행합니다. `config.enable_reloading`이 `false`이고 `config.eager_load`가 `true`(`production`의 기본값)인 경우, 재로드가 발생하지 않으므로 Load Interlock이 필요하지 않습니다. `development` 환경의 기본 설정으로 Executor는 Load Interlock을 사용하여 상수가 안전하게 로드될 때만 로드됩니다.

로드 인터락
--------------

로드 인터락은 멀티스레드 런타임 환경에서 autoload 및 재로드를 활성화할 수 있도록 합니다.

한 스레드가 해당 파일에서 클래스 정의를 평가하여 autoload하는 동안, 다른 스레드가 부분적으로 정의된 상수에 대한 참조를 만나지 않도록 하는 것이 중요합니다.

마찬가지로, 응용 프로그램 코드가 실행 중이지 않을 때만 언로드/재로드를 수행하는 것이 안전합니다. 재로드 후에는 예를 들어 `User` 상수가 다른 클래스를 가리킬 수 있습니다. 이 규칙이 없으면, 잘못 타이밍된 재로드는 `User.new.class == User` 또는 `User == User`가 false가 될 수 있습니다.

이러한 제약 사항은 로드 인터락으로 해결됩니다. 로드 인터락은 현재 애플리케이션 코드를 실행 중인 스레드, 클래스 로드, autoload된 상수 언로드를 추적합니다.

한 번에 하나의 스레드만 로드 또는 언로드할 수 있으며, 어느 것이든 수행하려면 다른 스레드가 애플리케이션 코드를 실행하지 않을 때까지 기다려야 합니다. 로드를 수행하기 위해 대기 중인 스레드는 다른 스레드가 로드하는 것을 방해하지 않습니다(실제로 협력하여, 각각이 순서대로 대기 중인 로드를 수행한 후 모두 함께 실행을 계속합니다).

### `permit_concurrent_loads`

Executor는 블록의 기간 동안 `running` 잠금을 자동으로 획득하고, autoload는 `load` 잠금으로 업그레이드하고 다시 `running`으로 전환하는 시점을 알고 있습니다.
그러나 Executor 블록(모든 응용 프로그램 코드를 포함) 내에서 수행되는 다른 블로킹 작업은 불필요하게 'running' 락을 유지할 수 있습니다. 다른 스레드가 자동으로로드해야하는 상수를 만나면 이로 인해 데드락이 발생할 수 있습니다.

예를 들어, 'User'가 아직로드되지 않은 경우 다음은 데드락을 유발합니다.

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 내부 스레드는 여기서 대기하며 실행 중인 다른 스레드가 있을 때 User를 로드 할 수 없습니다.
    end
  end

  th.join # 외부 스레드는 여기서 대기하며 'running' 락을 보유합니다.
end
```

이러한 데드락을 방지하기 위해 외부 스레드는 'permit_concurrent_loads'를 호출할 수 있습니다. 이 메서드를 호출함으로써 스레드는 제공된 블록 내에서 자동으로로드 된 상수를 참조하지 않음을 보장합니다. 이 약속을 가장 가까운 곳에 두는 것이 가장 안전한 방법입니다.

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 내부 스레드는 'load' 락을 획득하고 User를 로드하고 계속 진행할 수 있습니다.
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # 외부 스레드는 여기서 대기하지만 락이 없습니다.
  end
end
```

Concurrent Ruby를 사용한 다른 예:

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # 여기서 작업 수행
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

응용 프로그램이 데드락이 발생하고 Load Interlock이 관련될 수 있다고 생각되는 경우 `config/application.rb`에 ActionDispatch::DebugLocks 미들웨어를 일시적으로 추가할 수 있습니다.

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

그런 다음 응용 프로그램을 다시 시작하고 데드락 조건을 다시 트리거하면 `/rails/locks`에서 현재 인터락을 알고 있는 모든 스레드의 요약, 보유하거나 대기 중인 락 수준 및 현재 백트레이스가 표시됩니다.

일반적으로 데드락은 인터락이 다른 외부 락이나 블로킹 I/O 호출과 충돌하는 것으로 인해 발생합니다. 발견하면 'permit_concurrent_loads'로 래핑 할 수 있습니다.
