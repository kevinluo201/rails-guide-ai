**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
在Rails中的線程和代碼執行
=======================

閱讀本指南後，您將了解：

* Rails將自動並行執行的代碼
* 如何將手動並發與Rails內部集成
* 如何包裝所有應用程式代碼
* 如何影響應用程式重新加載

--------------------------------------------------------------------------------

自動並發
--------

Rails自動允許同時執行各種操作。

當使用線程化的Web服務器（例如默認的Puma）時，多個HTTP請求將同時提供，每個請求都有自己的控制器實例。

線程化的Active Job適配器（包括內置的Async）也會同時執行多個作業。Action Cable通道也是這樣管理的。

這些機制都涉及多個線程，每個線程管理某個對象的工作（控制器、作業、通道），同時共享全局進程空間（例如類和它們的配置以及全局變量）。只要您的代碼不修改這些共享的東西，它就可以忽略其他線程的存在。

本指南的其餘部分將描述Rails用於使其“基本可忽略”的機制，以及擴展和具有特殊需求的應用程式如何使用它們。

執行器
------

Rails執行器將應用程式代碼與框架代碼分離：每次框架調用您在應用程式中編寫的代碼時，它都會被執行器包裝。

執行器由兩個回調組成：`to_run`和`to_complete`。運行回調在應用程式代碼之前調用，完成回調在之後調用。

### 默認回調

在默認的Rails應用程式中，執行器回調用於：

* 跟踪哪些線程處於安全的自動加載和重新加載位置
* 啟用和禁用Active Record查詢緩存
* 將已獲取的Active Record連接返回到連接池
* 限制內部緩存的生命周期

在Rails 5.0之前，其中一些是由獨立的Rack中間件類（例如`ActiveRecord::ConnectionAdapters::ConnectionManagement`）處理的，或者直接使用方法（例如`ActiveRecord::Base.connection_pool.with_connection`）包裝代碼。執行器將這些替換為更抽象的單一接口。

### 包裝應用程式代碼

如果您正在編寫將調用應用程式代碼的庫或組件，您應該使用執行器將其包裝：

```ruby
Rails.application.executor.wrap do
  # 在這裡調用應用程式代碼
end
```

提示：如果您從長時間運行的進程中重複調用應用程式代碼，您可能希望改用[重新加載器](#reloader)進行包裝。

每個線程在運行應用程式代碼之前都應該被包裝，因此如果您的應用程式手動將工作委派給其他線程，例如通過`Thread.new`或使用線程池的Concurrent Ruby功能，您應該立即包裝該塊：

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # 在這裡放置您的代碼
  end
end
```

注意：Concurrent Ruby使用`ThreadPoolExecutor`，有時會使用`executor`選項進行配置。儘管名稱相同，但它們無關。

執行器是安全可重入的；如果它已在當前線程上處於活動狀態，`wrap`操作將不起作用。

如果在塊中包裝應用程式代碼不切實際（例如，Rack API使此變得困難），您還可以使用`run!` / `complete!`對：

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # 在這裡放置您的代碼
ensure
  execution_context.complete! if execution_context
end
```

### 並發

執行器將當前線程放入[加載互鎖](#load-interlock)的“運行”模式。如果另一個線程當前正在自動加載常量或卸載/重新加載應用程式，此操作將暫時阻塞。

重新加載器
--------

與執行器一樣，重新加載器也會包裝應用程式代碼。如果執行器尚未在當前線程上處於活動狀態，重新加載器將為您調用它，因此您只需要調用一個。這也保證重新加載器所做的所有事情，包括所有回調調用，都在執行器內部進行包裝。

```ruby
Rails.application.reloader.wrap do
  # 在這裡調用應用程式代碼
end
```

重新加載器僅適用於長時間運行的框架級進程重複調用應用程式代碼的情況，例如Web服務器或作業隊列。Rails自動包裝Web請求和Active Job工作者，因此您很少需要自己調用重新加載器。始終考慮執行器是否更適合您的用例。

### 回調

在進入包裝塊之前，重新加載器將檢查運行的應用程式是否需要重新加載 - 例如，因為模型的源文件已被修改。如果確定需要重新加載，它將等待直到安全，然後再繼續。當應用程式配置為始終重新加載而不管是否檢測到任何更改時，重新加載將在塊的結尾執行。
Reloader還提供了`to_run`和`to_complete`回調函數；它們在與Executor的回調函數相同的時間點被調用，但只有在當前執行引發應用程序重新加載時才會調用。當不需要重新加載時，Reloader將調用包裹的代碼塊而不調用其他回調函數。

### 類別卸載

重新加載過程中最重要的部分是類別卸載，其中所有自動加載的類別都被移除，準備重新加載。這將在運行或完成回調函數之前立即發生，具體取決於`reload_classes_only_on_change`設置。

通常，在類別卸載之前或之後需要執行其他重新加載操作，因此Reloader還提供了`before_class_unload`和`after_class_unload`回調函數。

### 並發性

只有長時間運行的“頂級”進程應該調用Reloader，因為如果它確定需要重新加載，它將阻塞直到所有其他線程完成任何Executor調用。

如果這發生在“子”線程中，並且在Executor內部有等待的父線程，這將導致不可避免的死鎖：重新加載必須在執行子線程之前發生，但在父線程正在執行時無法安全地執行。子線程應該使用Executor。

框架行為
------------------

Rails框架組件也使用這些工具來管理它們自己的並發需求。

`ActionDispatch::Executor`和`ActionDispatch::Reloader`是Rack中間件，它們分別使用提供的Executor或Reloader包裹請求。它們自動包含在默認應用程序堆棧中。如果發生任何代碼更改，Reloader將確保任何到達的HTTP請求都使用最新加載的應用程序副本來處理。

Active Job也使用Reloader包裹其作業執行，每次作業從隊列中出來時都會加載最新的代碼來執行。

Action Cable則使用Executor：因為Cable連接與類的特定實例相關聯，所以不可能為每個到達的WebSocket消息重新加載。但只有消息處理程序被包裹；長時間運行的Cable連接不會阻止由新的傳入請求或作業觸發的重新加載。相反，Action Cable使用Reloader的`before_class_unload`回調函數來斷開所有連接。當客戶端自動重新連接時，它將與代碼的新版本進行通信。

以上是框架的入口點，因此它們負責確保其各自的線程受到保護，並決定是否需要重新加載。其他組件只需要在它們生成其他線程時使用Executor。

### 配置

只有在`config.enable_reloading`為`true`且`config.reload_classes_only_on_change`也為`true`時，Reloader才會檢查文件更改。這些是`development`環境中的默認值。

當`config.enable_reloading`為`false`（默認情況下為`production`）時，Reloader只是Executor的一個通過。

Executor始終有重要的工作要做，例如數據庫連接管理。當`config.enable_reloading`為`false`且`config.eager_load`為`true`（`production`的默認值）時，不會發生重新加載，因此它不需要Load Interlock。使用`development`環境的默認設置，Executor將使用Load Interlock來確保只有在安全時才加載常量。

Load Interlock
--------------

Load Interlock允許在多線程運行時啟用自動加載和重新加載。

當一個線程通過評估適當文件中的類定義來執行自動加載時，重要的是不讓其他線程遇到部分定義的常量的引用。

同樣，只有在沒有應用程序代碼正在執行時才能安全地執行卸載/重新加載：重新加載之後，例如，`User`常量可能指向不同的類。如果沒有這個規則，錯誤的時機重新加載將意味著`User.new.class == User`，甚至`User == User`可能是錯誤的。

Load Interlock解決了這兩個限制。它跟踪哪些線程當前正在運行應用程序代碼、加載類或卸載自動加載的常量。

一次只能有一個線程進行加載或卸載，要進行任何操作，它必須等待沒有其他線程正在運行應用程序代碼。如果一個線程正在等待執行加載，它不會阻止其他線程加載（實際上，它們將合作，每個線程依次執行其排隊的加載，然後一起恢復運行）。

### `permit_concurrent_loads`

Executor在其塊的持續時間內自動獲取`running`鎖，並且autoload知道何時升級到`load`鎖，然後再切換回`running`。
在Executor區塊內（包括所有應用程式程式碼）執行的其他阻塞操作，可能會不必要地保留`running`鎖定。如果另一個執行緒遇到必須自動載入的常數，這可能會導致死結。

例如，假設`User`尚未載入，下面的程式碼將造成死結：

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 內部執行緒在此等待；當另一個執行緒正在運行時，它無法載入User
    end
  end

  th.join # 外部執行緒在此等待，持有'running'鎖定
end
```

為了防止這種死結，外部執行緒可以使用`permit_concurrent_loads`。通過調用此方法，該執行緒保證不會在提供的區塊內解引用任何可能自動載入的常數。達到這個承諾的最安全方法是將其放在阻塞呼叫的附近：

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # 內部執行緒可以獲取'load'鎖定，載入User，並繼續執行
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # 外部執行緒在此等待，但沒有鎖定
  end
end
```

另一個使用Concurrent Ruby的例子：

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # 在這裡執行工作
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

如果您的應用程式發生死結，並且認為可能涉及載入互鎖，您可以暫時將ActionDispatch::DebugLocks中介軟體添加到`config/application.rb`中：

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

然後重新啟動應用程式並重新觸發死結條件，`/rails/locks`將顯示目前已知的所有執行緒的摘要，包括它們持有或等待的鎖定層級以及它們目前的回溯。

通常，死結是由互鎖與其他外部鎖定或阻塞I/O呼叫發生衝突引起的。找到問題後，您可以使用`permit_concurrent_loads`將其包裹起來。
