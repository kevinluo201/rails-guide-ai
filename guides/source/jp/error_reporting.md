**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Railsアプリケーションにおけるエラーレポート
========================

このガイドでは、Ruby on Railsアプリケーションで発生する例外を管理する方法について紹介します。

このガイドを読み終えると、以下のことがわかるようになります：

* Railsのエラーレポーターを使用してエラーをキャプチャし、レポートする方法
* エラーレポートサービスのためのカスタムサブスクライバを作成する方法

--------------------------------------------------------------------------------

エラーレポート
------------------------

Railsの[エラーレポーター](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html)は、アプリケーションで発生する例外を収集し、指定したサービスや場所にレポートするための標準的な方法を提供します。

エラーレポーターは、次のようなボイラープレートのエラーハンドリングコードを置き換えることを目指しています：

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

一貫したインターフェースで次のように書くことができます：

```ruby
Rails.error.handle(SomethingIsBroken) do
  do_something
end
```

Railsは、HTTPリクエスト、ジョブ、`rails runner`の実行などのすべての実行をエラーレポーターでラップするため、アプリ内で処理されないエラーは自動的にエラーレポートサービスにサブスクライバを介してレポートされます。

これにより、サードパーティのエラーレポートライブラリは、未処理の例外をキャプチャするためにRackミドルウェアを挿入したり、モンキーパッチを適用する必要がなくなります。ActiveSupportを使用するライブラリは、以前はログで失われていた警告を非侵入的にレポートするためにこれを使用することもできます。

Railsのエラーレポーターの使用は必須ではありません。他のエラーのキャプチャ手段は引き続き機能します。

### レポータにサブスクライブする

エラーレポーターを使用するには、_サブスクライバ_が必要です。サブスクライバは、`report`メソッドを持つ任意のオブジェクトです。アプリケーションでエラーが発生するか、手動でレポートされると、Railsのエラーレポーターはこのメソッドをエラーオブジェクトといくつかのオプションとともに呼び出します。

[Sentryの](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb)や[Honeybadgerの](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/)ような一部のエラーレポートライブラリは、自動的にサブスクライバを登録します。詳細については、プロバイダのドキュメントを参照してください。

カスタムサブスクライバも作成できます。例：

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

サブスクライバクラスを定義した後、[`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe)メソッドを呼び出して登録します：

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

登録するサブスクライバは何個でも構いません。Railsは登録された順序で順番に呼び出します。

注意：Railsのエラーレポーターは、環境に関係なく登録されたサブスクライバを常に呼び出します。ただし、多くのエラーレポートサービスはデフォルトで本番環境でのみエラーをレポートします。必要に応じて環境を設定してテストする必要があります。

### エラーレポータの使用

エラーレポータには3つの使用方法があります：

#### エラーのレポートとエラーのスワロー

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle)は、ブロック内で発生したエラーをレポートします。その後、エラーは**スワロー**され、ブロックの外側のコードは通常通り実行されます。

```ruby
result = Rails.error.handle do
  1 + '1' # TypeErrorを発生させる
end
result # => nil
1 + 1 # これは実行されます
```

ブロック内でエラーが発生しない場合、`Rails.error.handle`はブロックの結果を返します。エラーが発生した場合は`nil`を返します。`fallback`を指定することでこれをオーバーライドすることもできます：

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### エラーのレポートとエラーの再発生

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record)は、すべての登録されたサブスクライバにエラーをレポートし、その後エラーを再発生させます。つまり、コードの残りの部分は実行されません。

```ruby
Rails.error.record do
  1 + '1' # TypeErrorを発生させる
end
1 + 1 # これは実行されません
```

ブロック内でエラーが発生しない場合、`Rails.error.record`はブロックの結果を返します。

#### 手動でエラーをレポートする

[`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report)を呼び出すことで、手動でエラーをレポートすることもできます：

```ruby
begin
  # コード
rescue StandardError => e
  Rails.error.report(e)
end
```

渡すオプションは、エラーサブスクライバに渡されます。

### エラーレポートオプション

すべての3つのレポートAPI（`#handle`、`#record`、`#report`）は、以下のオプションをサポートしており、登録されたすべてのサブスクライバに渡されます：

- `handled`：エラーが処理されたかどうかを示す`Boolean`。デフォルトでは`true`に設定されています。`#record`ではこれが`false`に設定されます。
- `severity`：エラーの重要度を示す`Symbol`。期待される値は、`:error`、`:warning`、`:info`です。`#handle`ではこれが`:warning`に設定され、`#record`では`:error`に設定されます。
- `context`：エラーに関する詳細なコンテキスト（リクエストやユーザーの詳細など）を提供するための`Hash`。
- `source`：エラーのソースに関する`String`。デフォルトのソースは「application」です。内部ライブラリによって報告されるエラーは他のソースを設定する場合があります。たとえば、Redisキャッシュライブラリは「redis_cache_store.active_support」を使用するかもしれません。サブスクライバはソースを使用して、興味のないエラーを無視することができます。
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### エラークラスでのフィルタリング

`Rails.error.handle`と`Rails.error.record`を使用して、特定のクラスのエラーのみを報告するように選択することもできます。例えば:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # TypeErrorが発生する
end
1 + 1 # TypeErrorはIOErrorではないため、実行されません
```

ここでは、`TypeError`はRailsのエラーレポーターにキャプチャされません。`IOError`とその子孫のインスタンスのみが報告されます。他のエラーは通常通りに発生します。

### グローバルなコンテキストの設定

`context`オプションを介してコンテキストを設定するだけでなく、[`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) APIを使用することもできます。例えば:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

この方法で設定されたコンテキストは、`context`オプションとマージされます。

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# 報告されるコンテキストは: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# 報告されるコンテキストは: {:a=>1, :b=>3}
```

### ライブラリ向け

エラーレポートライブラリは、`Railtie`内でサブスクライバーを登録することができます。

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

エラーサブスクライバーを登録した場合、Rackミドルウェアなどの他のエラーメカニズムがある場合、エラーが複数回報告される可能性があります。他のメカニズムを削除するか、レポート機能を調整して、以前に見た例外の報告をスキップするようにする必要があります。
