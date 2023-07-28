**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
Rails中的线程和代码执行
====================

阅读本指南后，您将了解以下内容：

* Rails将自动并发执行的代码
* 如何将手动并发与Rails内部集成
* 如何包装所有应用程序代码
* 如何影响应用程序重新加载

--------------------------------------------------------------------------------

自动并发
---------------------

Rails自动允许同时执行各种操作。

当使用线程化的Web服务器（例如默认的Puma）时，多个HTTP请求将同时提供服务，每个请求都有自己的控制器实例。

线程化的Active Job适配器，包括内置的Async，也会同时执行多个作业。Action Cable通道也是以这种方式管理的。

所有这些机制都涉及多个线程，每个线程管理某个对象的工作（控制器、作业、通道），同时共享全局进程空间（例如类及其配置和全局变量）。只要您的代码不修改任何这些共享的东西，它就可以基本上忽略其他线程的存在。

本指南的其余部分描述了Rails用于使其“基本上可忽略”的机制，以及具有特殊需求的扩展和应用程序如何使用它们。

执行器
--------

Rails执行器将应用程序代码与框架代码分离：每当框架调用您在应用程序中编写的代码时，它都会被执行器包装。

执行器由两个回调组成：`to_run`和`to_complete`。运行回调在应用程序代码之前调用，完成回调在之后调用。

### 默认回调

在默认的Rails应用程序中，执行器回调用于：

* 跟踪哪些线程处于安全的自动加载和重新加载位置
* 启用和禁用Active Record查询缓存
* 将已获取的Active Record连接返回到池中
* 限制内部缓存的生命周期

在Rails 5.0之前，其中一些是由单独的Rack中间件类（例如`ActiveRecord::ConnectionAdapters::ConnectionManagement`）处理的，或者直接使用诸如`ActiveRecord::Base.connection_pool.with_connection`之类的方法包装代码。执行器用一个更抽象的接口替换了这些。

### 包装应用程序代码

如果您正在编写一个将调用应用程序代码的库或组件，您应该使用执行器来包装它：

```ruby
Rails.application.executor.wrap do
  # 在这里调用应用程序代码
end
```

提示：如果您从长时间运行的进程中重复调用应用程序代码，您可能希望使用[Reloader](#reloader)进行包装。

每个线程在运行应用程序代码之前都应该被包装，因此如果您的应用程序手动将工作委托给其他线程，例如通过`Thread.new`或使用线程池的Concurrent Ruby功能，您应该立即包装该块：

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # 在这里写入您的代码
  end
end
```

注意：Concurrent Ruby使用`ThreadPoolExecutor`，有时会使用`executor`选项进行配置。尽管名称相同，但它们无关。

执行器是安全可重入的；如果它已经在当前线程上活动，`wrap`操作将不起作用。

如果在块中包装应用程序代码不切实际（例如，Rack API使此成为问题），您还可以使用`run!` / `complete!`对：

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # 在这里写入您的代码
ensure
  execution_context.complete! if execution_context
end
```

### 并发

执行器将当前线程置于[加载互锁](#load-interlock)的“运行”模式。如果另一个线程当前正在自动加载常量或卸载/重新加载应用程序，则此操作将暂时阻塞。

重新加载器
--------

与执行器一样，重新加载器也会包装应用程序代码。如果执行器尚未在当前线程上活动，则重新加载器将为您调用它，因此您只需要调用一个。这还确保重新加载器所做的所有操作，包括其所有回调调用，都在执行器内部进行包装。

```ruby
Rails.application.reloader.wrap do
  # 在这里调用应用程序代码
end
```

重新加载器仅适用于长时间运行的框架级进程重复调用应用程序代码的情况，例如Web服务器或作业队列。Rails会自动包装Web请求和Active Job工作者，因此您很少需要自己调用重新加载器。始终考虑执行器是否更适合您的用例。

### 回调

在进入包装块之前，重新加载器将检查是否需要重新加载正在运行的应用程序 - 例如，因为修改了模型的源文件。如果确定需要重新加载，它将等待直到安全，然后在继续之前执行重新加载。当应用程序配置为始终重新加载而不管是否检测到任何更改时，重新加载将在块的末尾执行。
Reloader还提供了`to_run`和`to_complete`回调函数；它们在与Executor相同的时间点被调用，但仅当当前执行已经启动应用程序重新加载时才会被调用。当不需要重新加载时，Reloader将只调用包装的块而没有其他回调函数。

### 类卸载

重新加载过程中最重要的部分是类卸载，其中所有自动加载的类都被移除，准备重新加载。这将在运行或完成回调之前立即发生，具体取决于`reload_classes_only_on_change`设置。

通常，在类卸载之前或之后需要执行其他重新加载操作，因此Reloader还提供了`before_class_unload`和`after_class_unload`回调函数。

### 并发性

只有长时间运行的“顶级”进程应该调用Reloader，因为如果它确定需要重新加载，它将阻塞直到所有其他线程完成任何Executor调用。

如果这发生在“子”线程中，其中一个等待的父线程在Executor内部，将导致无法避免的死锁：重新加载必须在执行子线程之前发生，但不能在父线程正在执行时安全执行。子线程应该使用Executor。

框架行为
------------------

Rails框架组件也使用这些工具来管理自己的并发需求。

`ActionDispatch::Executor`和`ActionDispatch::Reloader`是Rack中间件，它们分别用提供的Executor或Reloader包装请求。它们自动包含在默认的应用程序堆栈中。如果发生了任何代码更改，Reloader将确保任何到达的HTTP请求都使用最新加载的应用程序副本进行服务。

Active Job也使用Reloader包装其作业执行，每当作业从队列中出来时，它会加载最新的代码来执行。

Action Cable使用Executor：因为Cable连接与类的特定实例相关联，所以不可能为每个到达的WebSocket消息重新加载。但只有消息处理程序被包装；长时间运行的Cable连接不会阻止由新的传入请求或作业触发的重新加载。相反，Action Cable使用Reloader的`before_class_unload`回调函数来断开所有连接。当客户端自动重新连接时，它将与代码的新版本进行通信。

以上是框架的入口点，因此它们负责确保其各自的线程受到保护，并决定是否需要重新加载。其他组件只需要在它们生成额外线程时使用Executor。

### 配置

当`config.enable_reloading`为`true`且`config.reload_classes_only_on_change`也为`true`时，Reloader只会检查文件更改。这些是`development`环境的默认设置。

当`config.enable_reloading`为`false`（默认为`production`）时，Reloader只是Executor的一个传递。

Executor始终有重要的工作要做，比如数据库连接管理。当`config.enable_reloading`为`false`且`config.eager_load`为`true`（`production`的默认设置）时，不会进行重新加载，因此不需要Load Interlock。在`development`环境的默认设置中，Executor将使用Load Interlock来确保常量只在安全时加载。

Load Interlock
--------------

Load Interlock允许在多线程运行时环境中启用自动加载和重新加载。

当一个线程通过评估适当文件中的类定义来执行自动加载时，重要的是不让其他线程遇到部分定义的常量的引用。

类似地，只有当没有应用程序代码处于执行中时，才能执行卸载/重新加载：重新加载后，例如，`User`常量可能指向不同的类。如果没有这个规则，一个时机不好的重新加载将意味着`User.new.class == User`，甚至`User == User`可能为false。

Load Interlock解决了这两个约束。它跟踪当前正在运行应用程序代码、加载类或卸载自动加载的常量的线程。

只有一个线程可以同时加载或卸载，并且为了执行任何操作，它必须等待直到没有其他线程正在运行应用程序代码。如果一个线程正在等待执行加载操作，它不会阻止其他线程加载（实际上，它们将相互合作，依次执行它们的加载操作，然后一起恢复运行）。

### `permit_concurrent_loads`

Executor在其块的持续时间内自动获取`running`锁，并且autoload知道何时升级为`load`锁，并在之后切换回`running`。
然而，在Executor块内执行的其他阻塞操作（包括所有应用程序代码）可能会不必要地保留`running`锁。如果另一个线程遇到必须自动加载的常量，这可能会导致死锁。

例如，假设`User`尚未加载，以下代码将导致死锁：

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 内部线程在此处等待；在另一个线程运行时无法加载User
    end
  end

  th.join # 外部线程在此处等待，持有'running'锁
end
```

为了防止这种死锁，外部线程可以调用`permit_concurrent_loads`。通过调用此方法，线程保证不会在提供的块内取消引用任何可能自动加载的常量。实现这个承诺的最安全方法是尽可能靠近阻塞调用：

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 内部线程可以获取'load'锁，加载User，并继续执行
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # 外部线程在此处等待，但没有锁
  end
end
```

另一个示例，使用Concurrent Ruby：

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # 在这里执行工作
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

如果您的应用程序发生死锁，并且认为Load Interlock可能涉及其中，您可以临时将ActionDispatch::DebugLocks中间件添加到`config/application.rb`中：

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

然后重新启动应用程序并重新触发死锁条件，`/rails/locks`将显示当前已知的所有线程的摘要，包括它们持有或等待的锁级别和当前的回溯信息。

通常，死锁是由于Interlock与其他外部锁或阻塞I/O调用发生冲突引起的。一旦找到它，您可以使用`permit_concurrent_loads`将其包装起来。
