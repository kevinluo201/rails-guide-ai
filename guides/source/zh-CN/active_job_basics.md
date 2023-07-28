**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Active Job基础知识
=================

本指南为您提供了一切开始创建、排队和执行后台作业所需的内容。

阅读本指南后，您将了解：

* 如何创建作业。
* 如何排队作业。
* 如何在后台运行作业。
* 如何从应用程序异步发送电子邮件。

--------------------------------------------------------------------------------

什么是Active Job？
-------------------

Active Job是一个声明作业并使其在各种排队后端上运行的框架。这些作业可以是定期计划的清理、计费收费或邮件发送等任何可以分解为小单位并并行运行的任务。

Active Job的目的
-----------------------------

主要目的是确保所有Rails应用都具备作业基础设施。然后，我们可以在此基础上构建框架功能和其他宝石，而不必担心不同作业运行器（如Delayed Job和Resque）之间的API差异。选择排队后端更多地成为一个操作问题。您将能够在不重写作业的情况下在它们之间切换。

注意：Rails默认使用一个在进程中运行的线程池来实现异步排队。作业将异步运行，但在重启时，队列中的任何作业都将被丢弃。

创建作业
--------------

本节将提供一个逐步指南，以创建作业并将其排队。

### 创建作业

Active Job提供了一个Rails生成器来创建作业。以下命令将在`app/jobs`目录下创建一个作业（并在`test/jobs`目录下创建一个附带的测试用例）：

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

您还可以创建一个将在特定队列上运行的作业：

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

如果您不想使用生成器，可以在`app/jobs`目录中创建自己的文件，只需确保它继承自`ApplicationJob`即可。

以下是作业的示例代码：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Do something later
  end
end
```

请注意，您可以根据需要定义`perform`方法的参数个数。

如果您已经有一个抽象类，并且其名称与`ApplicationJob`不同，您可以使用`--parent`选项指定您想要使用不同抽象类：

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
```

### 将作业排队

使用[`perform_later`][]和可选的[`set`][]将作业排队。例如：

```ruby
# 将作业排队，以便在排队系统空闲时立即执行。
GuestsCleanupJob.perform_later guest
```

```ruby
# 将作业排队，以便在明天中午执行。
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# 将作业排队，以便在一周后执行。
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now`和`perform_later`将在底层调用`perform`，因此您可以传递与后者中定义的参数一样多的参数。
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

就是这样！

作业执行
-------------

要在生产环境中排队和执行作业，您需要设置一个排队后端，也就是说，您需要决定Rails应该使用哪个第三方排队库。Rails本身只提供了一个在进程中的排队系统，它只将作业保存在RAM中。如果进程崩溃或机器重启，则使用默认的异步后端会丢失所有未完成的作业。这对于较小的应用程序或非关键作业可能没问题，但大多数生产应用程序都需要选择一个持久性后端。

### 后端

Active Job内置了多个排队后端的适配器（Sidekiq、Resque、Delayed Job等）。要获取最新的适配器列表，请参阅[`ActiveJob::QueueAdapters`][]的API文档。

### 设置后端

您可以使用[`config.active_job.queue_adapter`]轻松设置排队后端：

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # 确保在Gemfile中有适配器的gem，并遵循适配器的特定安装和部署说明。
    config.active_job.queue_adapter = :sidekiq
  end
end
```

您还可以根据每个作业配置后端：

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# 现在，您的作业将使用`resque`作为其后端队列适配器，覆盖了在`config.active_job.queue_adapter`中配置的设置。
```
### 启动后端

由于作业与Rails应用程序并行运行，大多数队列库要求您启动特定于库的队列服务（除了启动Rails应用程序）以使作业处理工作。请参考库文档以获取有关启动队列后端的说明。

这里是一个非详尽的文档列表：

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

队列
------

大多数适配器支持多个队列。使用Active Job，您可以使用[`queue_as`][]将作业安排在特定队列上运行：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

您可以使用[`config.active_job.queue_name_prefix`][]在`application.rb`中为所有作业的队列名称添加前缀：

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

# 现在您的作业将在生产环境的production_low_priority队列上运行，
# 在演示环境的staging_low_priority队列上运行
```

您还可以根据每个作业进行前缀配置。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# 现在您的作业的队列名称将不带前缀，覆盖了在`config.active_job.queue_name_prefix`中配置的内容。
```

默认的队列名称前缀分隔符是'\_'。您可以通过在`application.rb`中设置[`config.active_job.queue_name_delimiter`][]来更改它：

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

# 现在您的作业将在生产环境的production.low_priority队列上运行，
# 在演示环境的staging.low_priority队列上运行
```

如果您希望更多地控制作业将在哪个队列上运行，可以在`set`中传递一个`:queue`选项：

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

要从作业级别控制队列，可以将块传递给`queue_as`。该块将在作业上下文中执行（因此可以访问`self.arguments`），并且必须返回队列名称：

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
    # 处理视频
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

注意：确保您的队列后端“监听”您的队列名称。对于某些后端，您需要指定要监听的队列。


回调
---------

Active Job提供了在作业生命周期中触发逻辑的钩子。与Rails中的其他回调一样，您可以将回调实现为普通方法，并使用宏样式的类方法将它们注册为回调：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # 后续操作
  end

  private
    def around_cleanup
      # 在执行之前进行某些操作
      yield
      # 在执行之后进行某些操作
    end
end
```

宏样式的类方法也可以接收一个块。如果您的块内的代码非常简短，适合放在一行内，考虑使用这种样式。例如，您可以为每个入队的作业发送指标：

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### 可用的回调

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Action Mailer
------------

在现代Web应用程序中，最常见的作业之一是在请求-响应周期之外发送电子邮件，以便用户无需等待。Active Job与Action Mailer集成，因此您可以轻松地异步发送电子邮件：

```ruby
# 如果要立即发送电子邮件，请使用#deliver_now
UserMailer.welcome(@user).deliver_now

# 如果要通过Active Job发送电子邮件，请使用#deliver_later
UserMailer.welcome(@user).deliver_later
```

注意：从Rake任务中使用异步队列（例如，使用`.deliver_later`发送电子邮件）通常不起作用，因为Rake可能会在任何/所有`.deliver_later`电子邮件被处理之前结束，导致进程中的线程池被删除。为了避免这个问题，在开发中使用`.deliver_now`或运行一个持久队列。


国际化
--------------------

每个作业使用创建作业时设置的`I18n.locale`。如果您异步发送电子邮件，这将非常有用：

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # 电子邮件将被本地化为世界语。
```


支持的参数类型
----------------------------
ActiveJob 默认支持以下类型的参数：

  - 基本类型（`NilClass`、`String`、`Integer`、`Float`、`BigDecimal`、`TrueClass`、`FalseClass`）
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash`（键应为 `String` 或 `Symbol` 类型）
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job 支持使用 [GlobalID](https://github.com/rails/globalid/blob/master/README.md) 作为参数。这使得您可以将实时的 Active Record 对象传递给作业，而不是类/ID对，然后手动反序列化。以前，作业看起来像这样：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

现在，您可以简单地这样做：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

这适用于任何混入了 `GlobalID::Identification` 的类，默认情况下，它已经混入了 Active Record 类。

### 序列化器

您可以扩展支持的参数类型列表。您只需要定义自己的序列化器：

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # 检查参数是否应由此序列化器进行序列化。
  def serialize?(argument)
    argument.is_a? Money
  end

  # 使用支持的对象类型将对象转换为更简单的表示形式。
  # 推荐的表示形式是具有特定键的哈希。键只能是基本类型。
  # 您应该调用 `super` 将自定义序列化器类型添加到哈希中。
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # 将序列化的值转换为正确的对象。
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

并将此序列化器添加到列表中：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

请注意，初始化期间不支持自动加载可重新加载的代码。因此，建议仅加载一次序列化器，例如通过修改 `config/application.rb` 来实现：

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

异常
----------

在作业执行期间引发的异常可以使用 [`rescue_from`][] 进行处理：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # 处理异常
  end

  def perform
    # 执行操作
  end
end
```

如果作业的异常没有被捕获，则该作业被称为“失败”。

### 重试或丢弃失败的作业

除非另有配置，否则失败的作业将不会重试。

可以使用 [`retry_on`] 或 [`discard_on`] 来重试或丢弃失败的作业。例如：

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # 默认等待 3 秒，尝试 5 次

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # 可能会引发 CustomAppException 或 ActiveJob::DeserializationError
  end
end
```


### 反序列化

GlobalID 允许序列化传递给 `#perform` 的完整 Active Record 对象。

如果作业入队后但在调用 `#perform` 方法之前，传递的记录被删除，Active Job 将引发 [`ActiveJob::DeserializationError`][] 异常。


作业测试
--------------

您可以在 [测试指南](testing.html#testing-jobs) 中找到有关如何测试作业的详细说明。

调试
---------

如果您需要帮助确定作业的来源，可以启用[详细日志记录](debugging_rails_applications.html#verbose-enqueue-logs)。
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
