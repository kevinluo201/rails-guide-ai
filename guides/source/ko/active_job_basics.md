**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Active Job 기본 사항
=================

이 가이드는 백그라운드 작업을 생성, 큐에 넣고 실행하는 데 필요한 모든 정보를 제공합니다.

이 가이드를 읽으면 다음을 알게 됩니다:

* 작업을 생성하는 방법.
* 작업을 큐에 넣는 방법.
* 백그라운드에서 작업을 실행하는 방법.
* 응용 프로그램에서 비동기적으로 이메일을 보내는 방법.

--------------------------------------------------------------------------------

Active Job이란 무엇인가?
-------------------

Active Job은 작업을 선언하고 다양한 큐 백엔드에서 실행할 수 있도록 하는 프레임워크입니다. 이 작업은 정기적으로 예약된 정리, 청구 요금, 메일링 등 모든 것이 될 수 있습니다. 실제로 작업을 작은 단위로 나누고 병렬로 실행할 수 있는 모든 것입니다.


Active Job의 목적
-----------------------------

주요 목표는 모든 Rails 앱에 작업 인프라가 구축되도록 보장하는 것입니다. 그런 다음 프레임워크 기능과 다른 젬들이 Delayed Job 및 Resque와 같은 다양한 작업 실행기 간의 API 차이로 인해 걱정할 필요없이 이를 기반으로 빌드할 수 있습니다. 큐 백엔드를 선택하는 것은 운영상의 문제가 되며 작업을 다시 작성하지 않고도 이들 사이를 전환할 수 있게 됩니다.

참고: Rails는 기본적으로 작업을 비동기적으로 실행하는 내부 스레드 풀을 사용하는 비동기 큐 구현을 제공합니다. 작업은 비동기적으로 실행되지만 큐에 있는 작업은 재시작시 삭제됩니다.


작업 생성하기
--------------

이 섹션에서는 작업을 생성하고 큐에 넣는 단계별 가이드를 제공합니다.

### 작업 생성하기

Active Job은 작업을 생성하기 위한 Rails 생성기를 제공합니다. 다음은 `app/jobs`에 작업을 생성하는 예입니다 (`test/jobs`에 첨부된 테스트 케이스가 있음):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

특정 큐에서 실행될 작업을 생성할 수도 있습니다:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

생성기를 사용하지 않으려면 `app/jobs` 내부에 직접 파일을 생성할 수도 있지만, 이 파일이 `ApplicationJob`에서 상속되는지 확인하십시오.

다음은 작업의 예입니다:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # 나중에 무언가를 수행합니다
  end
end
```

`perform`을 원하는 만큼 많은 인수와 함께 정의할 수 있다는 점에 유의하십시오.

추상 클래스가 이미 있고 그 이름이 `ApplicationJob`과 다른 경우 `--parent` 옵션을 전달하여 다른 추상 클래스를 사용하려는 것을 나타낼 수 있습니다:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # 나중에 무언가를 수행합니다
  end
end
```

### 작업 큐에 넣기

[`perform_later`][] 및 선택적으로 [`set`][]을 사용하여 작업을 큐에 넣습니다. 다음과 같이 사용합니다:

```ruby
# 큐 시스템이 비어있을 때 즉시 실행될 작업을 큐에 넣습니다.
GuestsCleanupJob.perform_later guest
```

```ruby
# 내일 정오에 실행될 작업을 큐에 넣습니다.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# 1주일 후에 실행될 작업을 큐에 넣습니다.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` 및 `perform_later`는 내부적으로 `perform`를 호출하므로
# 후자에서 정의된대로 많은 인수를 전달할 수 있습니다.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

그게 다입니다!


작업 실행하기
-------------

작업을 큐에 넣고 실행하기 위해 프로덕션 환경에서는 큐 백엔드를 설정해야 합니다. 즉, Rails가 사용해야 할 3rd-party 큐 라이브러리를 결정해야 합니다. Rails 자체는 작업을 RAM에만 유지하는 내부 큐 시스템만 제공합니다. 프로세스가 충돌하거나 기계가 재설정되면 모든 미처리된 작업은 기본 비동기 백엔드에서 손실됩니다. 이는 작은 앱이나 중요하지 않은 작업에는 괜찮을 수 있지만 대부분의 프로덕션 앱은 영속적인 백엔드를 선택해야 합니다.

### 백엔드

Active Job에는 여러 큐 백엔드 (Sidekiq, Resque, Delayed Job 등)에 대한 내장 어댑터가 있습니다. 최신 어댑터 목록을 보려면 [`ActiveJob::QueueAdapters`][]의 API 문서를 참조하십시오.


### 백엔드 설정하기

[`config.active_job.queue_adapter`]를 사용하여 큐 백엔드를 쉽게 설정할 수 있습니다:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # 어댑터의 gem이 Gemfile에 있고
    # 어댑터의 특정 설치 및 배포 지침을 따르십시오.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

작업별로 백엔드를 구성할 수도 있습니다:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# 이제 작업은 `resque`를 백엔드 큐 어댑터로 사용하며,
# `config.active_job.queue_adapter`에 구성된 것을 무시합니다.
```
### 백엔드 시작하기

작업은 Rails 애플리케이션과 병렬로 실행되기 때문에 대부분의 큐잉 라이브러리는 작업 처리를 위해 Rails 앱을 시작하는 동시에 라이브러리별 큐잉 서비스를 시작해야 합니다. 큐 백엔드를 시작하는 방법에 대한 지침은 라이브러리 문서를 참조하십시오.

다음은 비완전한 문서 목록입니다:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

큐
------

대부분의 어댑터는 여러 개의 큐를 지원합니다. Active Job을 사용하여 [`queue_as`][]를 사용하여 작업을 특정 큐에서 실행할 수 있습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

[`config.active_job.queue_name_prefix`][]를 사용하여 모든 작업에 대한 큐 이름에 접두사를 추가할 수 있습니다. 이를 위해 `application.rb`에서 다음과 같이 설정할 수 있습니다.

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# 이제 작업은 프로덕션 환경에서 production_low_priority 큐에서 실행되며,
# 스테이징 환경에서는 staging_low_priority 큐에서 실행됩니다.
```

큐 이름에 대한 접두사를 작업별로 구성할 수도 있습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# 이제 작업의 큐 이름에는 접두사가 없으며, `config.active_job.queue_name_prefix`에서 구성한 것을 무시합니다.
```

기본 큐 이름 접두사 구분자는 '\_'입니다. 이를 `application.rb`에서 [`config.active_job.queue_name_delimiter`][]를 설정하여 변경할 수 있습니다.

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# 이제 작업은 프로덕션 환경에서 production.low_priority 큐에서 실행되며,
# 스테이징 환경에서는 staging.low_priority 큐에서 실행됩니다.
```

작업이 실행될 큐를 더 세밀하게 제어하려면 `set`에 `:queue` 옵션을 전달할 수 있습니다.

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

작업 수준에서 큐를 제어하려면 `queue_as`에 블록을 전달할 수도 있습니다. 이 블록은 작업 컨텍스트에서 실행되므로 (`self.arguments`에 액세스할 수 있으므로) 큐 이름을 반환해야 합니다.

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # 비디오 처리 수행
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

참고: 큐잉 백엔드가 큐 이름을 "듣도록" 설정해야 합니다. 일부 백엔드에서는 듣기 위해 큐를 지정해야 합니다.


콜백
---------

Active Job은 작업의 라이프 사이클 동안 로직을 트리거하기 위한 훅을 제공합니다. Rails의 다른 콜백과 마찬가지로 콜백을 일반 메서드로 구현하고 매크로 스타일의 클래스 메서드를 사용하여 콜백으로 등록할 수 있습니다.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # 나중에 무언가 수행
  end

  private
    def around_cleanup
      # 수행 전에 무언가 수행
      yield
      # 수행 후에 무언가 수행
    end
end
```

매크로 스타일의 클래스 메서드는 블록을 받을 수도 있습니다. 블록 내의 코드가 한 줄에 들어갈 정도로 짧다면 이 스타일을 사용하는 것이 좋습니다. 예를 들어, 모든 작업이 예약될 때마다 메트릭을 보낼 수 있습니다.

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### 사용 가능한 콜백

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


액션 메일러
------------

현대적인 웹 애플리케이션에서 가장 일반적인 작업 중 하나는 요청-응답 주기 외부에서 이메일을 보내는 것입니다. 이를 위해 사용자가 기다릴 필요가 없도록 Active Job은 Action Mailer와 통합되어 이메일을 비동기적으로 쉽게 보낼 수 있습니다.

```ruby
# 지금 이메일을 보내려면 #deliver_now를 사용합니다.
UserMailer.welcome(@user).deliver_now

# Active Job을 통해 이메일을 보내려면 #deliver_later를 사용합니다.
UserMailer.welcome(@user).deliver_later
```

참고: Rake 작업에서 비동기 큐를 사용하는 경우 (예: `.deliver_later`를 사용하여 이메일을 보내는 경우) 일반적으로 작동하지 않을 수 있습니다. Rake가 종료되기 전에 `.deliver_later` 이메일이 처리되기 전에 프로세스 내 스레드 풀이 삭제될 수 있기 때문입니다. 이 문제를 피하기 위해 `.deliver_now`를 사용하거나 개발 중에 지속적인 큐를 실행하십시오.


국제화
--------------------

각 작업은 작업이 생성된 시점에 설정된 `I18n.locale`를 사용합니다. 이는 이메일을 비동기적으로 보내는 경우 유용합니다.

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # 이메일은 에스페란토로 지역화됩니다.
```


인수에 대한 지원되는 유형
----------------------------
ActiveJob은 기본적으로 다음 유형의 인수를 지원합니다:

  - 기본 유형 (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (키는 `String` 또는 `Symbol` 유형이어야 함)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job은 매개변수에 대해 [GlobalID](https://github.com/rails/globalid/blob/master/README.md)를 지원합니다. 이를 통해 클래스/ID 쌍 대신에 실시간 Active Record 객체를 작업에 전달하여 수동으로 역직렬화해야 하는 번거로움을 피할 수 있습니다. 이전에 작업은 다음과 같았습니다:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

이제 다음과 같이 간단하게 작성할 수 있습니다:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

이는 기본적으로 Active Record 클래스에 섞여 있는 `GlobalID::Identification`를 사용하는 모든 클래스와 함께 작동합니다.

### 직렬화기

지원되는 인수 유형 목록을 확장할 수 있습니다. 직렬화기를 직접 정의하기만 하면 됩니다:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # 이 직렬화기가 인수를 직렬화해야 하는지 확인합니다.
  def serialize?(argument)
    argument.is_a? Money
  end

  # 지원되는 객체 유형을 사용하여 객체를 더 간단한 대표값으로 변환합니다.
  # 권장되는 대표값은 특정 키를 가진 해시입니다. 키는 기본 유형만 사용할 수 있습니다.
  # 사용자 정의 직렬화기 유형을 해시에 추가하려면 `super`를 호출해야 합니다.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # 직렬화된 값을 적절한 객체로 변환합니다.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

그리고 다음과 같이 직렬화기를 목록에 추가합니다:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

초기화 중에 코드를 다시로드하는 것은 지원되지 않습니다. 따라서 직렬화기가 한 번만 로드되도록 설정하는 것이 좋습니다. 예를 들어 다음과 같이 `config/application.rb`을 수정하는 것이 좋습니다:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

예외
----------

작업 실행 중 발생한 예외는 [`rescue_from`][]을 사용하여 처리할 수 있습니다:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # 예외 처리
  end

  def perform
    # 나중에 수행할 작업
  end
end
```

작업에서 발생한 예외가 처리되지 않으면 해당 작업은 "실패한" 작업으로 간주됩니다.


### 실패한 작업 재시도 또는 폐기하기

구성에 따라 실패한 작업은 재시도되지 않습니다.

[`retry_on`] 또는 [`discard_on`]을 사용하여 실패한 작업을 재시도하거나 폐기할 수 있습니다. 예를 들어:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # 기본값은 3초 대기, 5번 시도

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # CustomAppException 또는 ActiveJob::DeserializationError가 발생할 수 있음
  end
end
```


### 역직렬화

GlobalID를 사용하면 `#perform`에 전달된 전체 Active Record 객체를 직렬화할 수 있습니다.

작업이 대기열에 추가된 후 `#perform` 메서드가 호출되기 전에 전달된 레코드가 삭제된 경우 Active Job은 [`ActiveJob::DeserializationError`][] 예외를 발생시킵니다.


작업 테스트
--------------

작업을 테스트하는 방법에 대한 자세한 지침은 [테스트 가이드](testing.html#testing-jobs)에서 찾을 수 있습니다.

디버깅
---------

작업이 어디에서 왔는지 파악하는 데 도움이 필요한 경우 [상세한 로깅](debugging_rails_applications.html#verbose-enqueue-logs)을 활성화할 수 있습니다.
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
