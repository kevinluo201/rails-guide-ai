**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Action Mailerの基本
====================

このガイドでは、アプリケーションからメールを送信するために必要なすべての情報と、Action Mailerの内部について説明します。また、メーラーのテスト方法についてもカバーしています。

このガイドを読み終えると、以下のことがわかるようになります。

* Railsアプリケーション内でメールを送信する方法。
* Action Mailerクラスとメーラービューを生成および編集する方法。
* 環境に合わせてAction Mailerを設定する方法。
* Action Mailerクラスをテストする方法。

--------------------------------------------------------------------------------

Action Mailerとは何ですか？
----------------------

Action Mailerを使用すると、メーラークラスとビューを使用してアプリケーションからメールを送信することができます。

### メーラーはコントローラに似ています

メーラーは[`ActionMailer::Base`][]を継承し、`app/mailers`に存在します。メーラーはコントローラと非常に似た動作をします。以下に類似点のいくつかを挙げます。メーラーは:

* アクションと、`app/views`に表示される関連するビューを持っています。
* ビューでアクセス可能なインスタンス変数を持っています。
* レイアウトとパーシャルを利用することができます。
* paramsハッシュにアクセスすることができます。


メールの送信
--------------

このセクションでは、メーラーとそのビューを作成するためのステップバイステップのガイドを提供します。

### メーラーの生成手順

#### メーラーの作成

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

上記のように、Railsの他のジェネレータと同様に、メーラーを生成することができます。

ジェネレータを使用したくない場合は、`app/mailers`内に独自のファイルを作成することもできますが、`ActionMailer::Base`を継承していることを確認してください。

```ruby
class MyMailer < ActionMailer::Base
end
```

#### メーラーの編集

メーラーには「アクション」と呼ばれるメソッドがあり、ビューを使用してコンテンツを構造化します。コントローラがクライアントに返すためにHTMLなどのコンテンツを生成するのに対し、メーラーはメール経由で配信されるメッセージを作成します。

`app/mailers/user_mailer.rb`には空のメーラーが含まれています。

```ruby
class UserMailer < ApplicationMailer
end
```

ユーザーの登録されたメールアドレスにメールを送信する`welcome_email`というメソッドを追加しましょう。

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
```

前述のメソッドで表示されている項目の簡単な説明を以下に示します。利用可能なオプションの完全なリストについては、後述の「Action Mailerユーザー設定可能な属性の完全なリスト」を参照してください。

* [`default`][]メソッドは、このメーラーから送信されるすべてのメールのデフォルト値を設定します。この場合、このクラスのすべてのメッセージの`:from`ヘッダー値を設定するために使用しています。これは、個々のメールごとに上書きすることができます。
* [`mail`][]メソッドは、実際のメールメッセージを作成します。このメソッドを使用して、`:to`や`:subject`などのヘッダーの値を指定します。


#### メーラービューの作成

`app/views/user_mailer/`に`welcome_email.html.erb`というファイルを作成します。これはHTML形式のメールのテンプレートになります。

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Welcome to example.com, <%= @user.name %></h1>
    <p>
      You have successfully signed up to example.com,
      your username is: <%= @user.login %>.<br>
    </p>
    <p>
      To login to the site, just follow this link: <%= @url %>.
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```

また、このメールのテキスト部分も作成しましょう。すべてのクライアントがHTMLメールを好むわけではないため、両方を送信するのがベストプラクティスです。これを行うには、`app/views/user_mailer/`に`welcome_email.text.erb`というファイルを作成します。

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```
`mail`メソッドを呼び出すと、Action Mailerは2つのテンプレート（テキストとHTML）を検出し、自動的に`multipart/alternative`のメールを生成します。

#### メーラーの呼び出し

メーラーは、ビューをレンダリングする別の方法です。ビューをレンダリングしてHTTPプロトコルを介して送信する代わりに、メールプロトコルを介して送信します。そのため、コントローラーがユーザーの作成に成功した場合にメーラーに電子メールを送信するように指示することは理にかなっています。

これを設定するのは簡単です。

まず、`User`のスキャフォールドを作成しましょう：

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

これで遊ぶためのユーザーモデルができたので、`app/controllers/users_controller.rb`ファイルを編集して、ユーザーが正常に作成された場合に`UserMailer`に新しく作成されたユーザーにメールを配信するように指示します。具体的には、createアクションを編集し、ユーザーが正常に保存された後に`UserMailer.with(user: @user).welcome_email`を呼び出します。

コントローラーアクションが完了するのを待たずに送信が完了するように、[`deliver_later`][]を使用してメールを送信するようにエンキューします。これはActive Jobによってバックアップされています。

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # ユーザーが保存された後にUserMailerにウェルカムメールを送信するように指示する
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

注意：Active Jobのデフォルトの動作は、`：async`アダプターを介してジョブを実行することです。そのため、`deliver_later`を使用してメールを非同期に送信できます。Active Jobのデフォルトのアダプターは、インプロセスのスレッドプールでジョブを実行します。これは、外部のインフラストラクチャを必要としないため、開発/テスト環境に適していますが、再起動時に保留中のジョブが削除されるため、本番環境には適していません。永続的なバックエンドが必要な場合は、永続的なバックエンドを持つActive Jobアダプター（Sidekiq、Resqueなど）を使用する必要があります。

すぐにメールを送信したい場合（たとえばcronジョブから）、[`deliver_now`][]を呼び出すだけです：

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

[`with`][]に渡されるキーと値のペアは、メーラーアクションの`params`になります。つまり、`with(user: @user, account: @user.account)`は、メーラーアクションで`params[:user]`と`params[:account]`を使用できるようにします。コントローラーと同様に、メーラーもparamsを持っています。

`welcome_email`メソッドは[`ActionMailer::MessageDelivery`][]オブジェクトを返し、それ自体を送信するために`deliver_now`または`deliver_later`と指示できます。`ActionMailer::MessageDelivery`オブジェクトは[`Mail::Message`][]のラッパーです。`Mail::Message`オブジェクトを検査、変更、またはその他の操作を行う場合は、`ActionMailer::MessageDelivery`オブジェクトの[`message`][]メソッドでアクセスできます。


### ヘッダー値の自動エンコード

Action Mailerは、ヘッダーや本文内のマルチバイト文字の自動エンコードを処理します。

より複雑な例として、代替文字セットの定義や自己エンコードテキストの最初については、[Mail](https://github.com/mikel/mail)ライブラリを参照してください。

### Action Mailerメソッドの完全なリスト

ほとんどのメールメッセージを送信するために必要なのは、次の3つのメソッドだけです：

* [`headers`][] - メールの任意のヘッダーを指定します。ヘッダーフィールド名と値のペアのハッシュを渡すか、`headers[:field_name] = 'value'`と呼び出すことができます。
* [`attachments`][] - メールに添付ファイルを追加することができます。例えば、`attachments['file-name.jpg'] = File.read('file-name.jpg')`です。
* [`mail`][] - 実際のメール自体を作成します。`mail`メソッドにヘッダーをハッシュとしてパラメーターとして渡すことができます。`mail`は、定義したメールテンプレートに応じて、プレーンテキストまたはマルチパートのメールを作成します。
#### 添付ファイルの追加

Action Mailerを使用すると、添付ファイルの追加が非常に簡単になります。

* ファイル名と内容をAction Mailerと[Mail gem](https://github.com/mikel/mail)に渡すと、`mime_type`を自動的に推測し、`encoding`を設定し、添付ファイルを作成します。

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  `mail`メソッドがトリガーされると、添付ファイルを含むマルチパートのメールが送信され、トップレベルが`multipart/mixed`であり、最初のパートがプレーンテキストとHTMLメールメッセージを含む`multipart/alternative`になります。

注意：Mailは添付ファイルを自動的にBase64エンコードします。異なるエンコード方法を使用する場合は、コンテンツをエンコードし、エンコードされたコンテンツとエンコーディングを`Hash`で`attachments`メソッドに渡します。

* ファイル名とヘッダーとコンテンツを指定し、Action MailerとMailは渡した設定を使用します。

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

注意：エンコーディングを指定すると、Mailはコンテンツが既にエンコードされているとみなし、Base64エンコードを試みません。

#### インライン添付ファイルの作成

Action Mailer 3.0では、3.0以前のバージョンでは多くのハッキングが必要だったインライン添付ファイルが、より簡単で当然のようになりました。

* まず、Mailに添付ファイルをインライン添付ファイルに変換するように指示するには、Mailer内のattachmentsメソッドに対して`#inline`を呼び出すだけです。

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* 次に、ビューで`attachments`をハッシュとして参照し、表示したい添付ファイルを指定し、`url`を呼び出してその結果を`image_tag`メソッドに渡すだけです。

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* これは`image_tag`への標準的な呼び出しであるため、他の画像と同様に、添付ファイルのURLの後にオプションのハッシュを渡すことができます。

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### 複数の受信者にメールを送信する

1つのメールで1人以上の受信者にメールを送信することができます（例：新しいサインアップの通知としてすべての管理者に通知する）。「:to」キーにメールアドレスのリストを設定することで、メールのリストを指定できます。メールのリストは、メールアドレスの配列またはカンマで区切られたアドレスを含む単一の文字列にすることができます。

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```

同じ形式を使用して、カーボンコピー（Cc：）とブラインドカーボンコピー（Bcc：）の受信者を設定することもできます。それぞれ「:cc」と「:bcc」キーを使用します。

#### 名前付きでメールを送信する

メールを受け取る人のメールアドレスだけでなく、その人の名前も表示したい場合があります。その場合は、[`email_address_with_name`][]を使用できます。

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'Welcome to My Awesome Site'
  )
end
```

同じテクニックを使用して、送信者の名前を指定することもできます。

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Example Company Notifications')
end
```

名前が空の文字列の場合、アドレスのみが返されます。


### メーラービュー

メーラービューは`app/views/name_of_mailer_class`ディレクトリにあります。メーラービューは、メーラーメソッドと同じ名前であるため、クラスには特定のメーラービューがわかります。上記の例では、`welcome_email`メソッドのメーラービューは、HTMLバージョンの場合は`app/views/user_mailer/welcome_email.html.erb`に、プレーンテキストバージョンの場合は`welcome_email.text.erb`になります。

アクションのデフォルトメーラービューを変更するには、次のようにします。

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```
この場合、`app/views/notifications`内の`another`という名前のテンプレートを探します。`template_path`にはパスの配列を指定することもでき、順番に検索されます。

柔軟性を高めるために、ブロックを渡して特定のテンプレートをレンダリングしたり、テンプレートファイルを使用せずにインラインまたはテキストをレンダリングすることもできます。

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Render text' }
    end
  end
end
```

これにより、HTMLパートにはテンプレート`another_template.html.erb`がレンダリングされ、テキストパートにはレンダリングされたテキストが使用されます。`render`コマンドはAction Controller内で使用されるものと同じなので、`:text`、`:inline`などのオプションも使用できます。

デフォルトの`app/views/mailer_name/`ディレクトリ以外にあるテンプレートをレンダリングする場合は、[`prepend_view_path`][]を適用することもできます。

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # "custom/path/to/mailer/view/welcome_email"テンプレートを読み込もうとします
  def welcome_email
    # ...
  end
end
```

[`append_view_path`][]メソッドを使用することもできます。

#### メーラービューのキャッシュ

[`cache`][]メソッドを使用して、アプリケーションビューと同様にメーラービューでフラグメントキャッシュを実行できます。

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

この機能を使用するには、アプリケーションを次のように設定する必要があります。

```ruby
config.action_mailer.perform_caching = true
```

フラグメントキャッシュは、マルチパートメールでもサポートされています。キャッシュについての詳細は、[Railsキャッシュガイド](caching_with_rails.html)を参照してください。

### Action Mailerのレイアウト

コントローラービューと同様に、メーラーレイアウトを使用することもできます。レイアウト名はメーラーと同じである必要があります。例えば、`user_mailer.html.erb`と`user_mailer.text.erb`は、メーラーによって自動的にレイアウトとして認識されます。

異なるファイルを使用する場合は、メーラー内で[`layout`][]を呼び出します。

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # awesome.(html|text).erbをレイアウトとして使用する
end
```

コントローラービューと同様に、`yield`を使用してレイアウト内でビューをレンダリングします。

異なるフォーマットに対して異なるレイアウトを指定するために、フォーマットブロック内のレンダーコールに`layout: 'layout_name'`オプションを渡すこともできます。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

これにより、HTMLパートは`my_layout.html.erb`ファイルを使用してレンダリングされ、テキストパートは通常の`user_mailer.text.erb`ファイルが存在する場合に使用されます。

### メールのプレビュー

Action Mailerプレビューを使用すると、特別なURLを訪れることでメールの表示方法を確認することができます。上記の例では、`UserMailer`のプレビュークラスは`UserMailerPreview`という名前であり、`test/mailers/previews/user_mailer_preview.rb`に配置する必要があります。`welcome_email`のプレビューを表示するには、同じ名前のメソッドを実装し、`UserMailer.welcome_email`を呼び出します。

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

その後、プレビューは<http://localhost:3000/rails/mailers/user_mailer/welcome_email>で利用できます。

`app/views/user_mailer/welcome_email.html.erb`またはメーラー自体を変更すると、自動的にリロードされてレンダリングされるため、新しいスタイルを即座に視覚的に確認できます。プレビューのリストは<http://localhost:3000/rails/mailers>でも利用できます。

デフォルトでは、これらのプレビュークラスは`test/mailers/previews`に存在します。`preview_paths`オプションを使用してこれを設定することができます。たとえば、`lib/mailer_previews`を追加したい場合は、`config/application.rb`で設定できます。

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### Action MailerビューでURLを生成する

コントローラーとは異なり、メーラーインスタンスには受信リクエストに関するコンテキストがありませんので、`:host`パラメータを自分で指定する必要があります。

通常、`:host`はアプリケーション全体で一貫しているため、`config/application.rb`でグローバルに設定できます。

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```
この動作のため、メール内では`*_path`ヘルパーを使用することはできません。代わりに関連する`*_url`ヘルパーを使用する必要があります。例えば、次のように使用します。

```html+erb
<%= link_to 'welcome', welcome_url %>
```

完全なURLを使用することで、リンクがメール内で機能するようになります。

#### `url_for`を使用したURLの生成

[`url_for`][]は、テンプレート内ではデフォルトで完全なURLを生成します。

グローバルに`host`オプションを設定していない場合は、`url_for`に渡す必要があります。

```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### 名前付きルートを使用したURLの生成

メールクライアントにはWebコンテキストがないため、パスには完全なWebアドレスを形成するためのベースURLがありません。そのため、常に名前付きルートヘルパーの`*_url`バリアントを使用する必要があります。

グローバルに`host`オプションを設定していない場合は、URLヘルパーに渡す必要があります。

```erb
<%= user_url(@user, host: 'example.com') %>
```

注意：非`GET`リンクには[rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts)または[jQuery UJS](https://github.com/rails/jquery-ujs)が必要であり、メーラーテンプレートでは機能しません。通常の`GET`リクエストになります。

### Action Mailerビューに画像を追加する

コントローラとは異なり、メーラーインスタンスには受信リクエストに関するコンテキストがありませんので、`asset_host`パラメータを自分で指定する必要があります。

通常、`asset_host`はアプリケーション全体で一貫しているため、`config/application.rb`でグローバルに設定できます。

```ruby
config.asset_host = 'http://example.com'
```

これで、メール内に画像を表示することができます。

```html+erb
<%= image_tag 'image.jpg' %>
```

### マルチパートメールの送信

Action Mailerは、同じアクションに対して異なるテンプレートがある場合、自動的にマルチパートメールを送信します。したがって、`UserMailer`の例では、`app/views/user_mailer`に`welcome_email.text.erb`と`welcome_email.html.erb`がある場合、Action Mailerは自動的にHTMLとテキストのバージョンを異なるパーツとして設定したマルチパートメールを送信します。

パーツの挿入順序は、`ActionMailer::Base.default`メソッド内の`:parts_order`によって決まります。

### 動的な配信オプションを使用したメールの送信

メールの配信時にデフォルトの配信オプション（例：SMTPの資格情報）を上書きしたい場合は、メーラーアクションで`delivery_method_options`を使用してこれを行うことができます。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### テンプレートのレンダリングなしでメールを送信する

テンプレートのレンダリングステップをスキップして、メール本文を文字列で指定したい場合があります。これは、`body`オプションを使用して実現できます。この場合、`content_type`オプションを追加することを忘れないでください。そうしないと、Railsはデフォルトで`text/plain`になります。

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Action Mailerコールバック
-----------------------

Action Mailerでは、メッセージを設定するための[`before_action`][]、[`after_action`][]、[`around_action`][]、および配信を制御するための[`before_deliver`][]、[`after_deliver`][]、[`around_deliver`][]を指定できます。

* コールバックは、コントローラと同様に、ブロックまたはメーラークラス内のメソッドへのシンボルとして指定できます。

* `before_action`を使用してインスタンス変数を設定したり、メールオブジェクトにデフォルト値を設定したり、デフォルトのヘッダーや添付ファイルを挿入したりすることができます。

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* `before_action`を使用して、メーラーアクションで設定されたインスタンス変数を使用して、`before_action`と同様のセットアップを行うことができます。

* `after_action`コールバックを使用すると、`mail.delivery_method.settings`を更新することで配信方法の設定をオーバーライドすることもできます。

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # ここでは、メールインスタンス、@business、@userのインスタンス変数にアクセスできます
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* `after_delivery`を使用して、メッセージの配信を記録することができます。

* メーラーコールバックは、本文が非nilの値に設定されている場合、さらなる処理を中止します。`before_deliver`は`throw :abort`で中止することができます。


Action Mailerヘルパーの使用
---------------------------

Action Mailerは`AbstractController`を継承しているため、Action Controllerと同じヘルパーのほとんどにアクセスすることができます。

また、[`ActionMailer::MailHelper`][]にはAction Mailer固有のヘルパーメソッドもあります。例えば、[`mailer`][MailHelper#mailer]を使用してビューからメーラーインスタンスにアクセスしたり、[`message`][MailHelper#message]を使用してメッセージにアクセスしたりすることができます。

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Action Mailerの設定
---------------------------

以下の設定オプションは、環境ファイル（environment.rb、production.rbなど）のいずれかに設定するのが最適です。

| 設定 | 説明 |
|---------------|-------------|
|`logger`|利用可能な場合、メーリング実行に関する情報を生成します。ログを記録しない場合は`nil`に設定できます。Rubyの`Logger`と`Log4r`の両方に対応しています。|
|`smtp_settings`|`:smtp`配信方法の詳細な設定を可能にします。<ul><li>`:address` - リモートメールサーバーを使用することができます。デフォルトの`"localhost"`設定から変更してください。</li><li>`:port` - メールサーバーがポート25で動作しない場合、変更できます。</li><li>`:domain` - HELOドメインを指定する必要がある場合は、ここで指定できます。</li><li>`:user_name` - メールサーバーが認証を必要とする場合、この設定でユーザー名を設定します。</li><li>`:password` - メールサーバーが認証を必要とする場合、この設定でパスワードを設定します。</li><li>`:authentication` - メールサーバーが認証を必要とする場合、ここで認証タイプを指定する必要があります。これはシンボルであり、`:plain`（パスワードをクリアテキストで送信）、`:login`（パスワードをBase64エンコードで送信）、`:cram_md5`（Challenge/Responseメカニズムと重要な情報をハッシュ化するための暗号化メッセージダイジェスト5アルゴリズムを組み合わせたもの）のいずれかです。</li><li>`:enable_starttls` - SMTPサーバーへの接続時にSTARTTLSを使用し、サポートされていない場合は失敗します。デフォルトは`false`です。</li><li>`:enable_starttls_auto` - SMTPサーバーでSTARTTLSが有効になっているかどうかを検出し、使用を開始します。デフォルトは`true`です。</li><li>`:openssl_verify_mode` - TLSを使用する場合、OpenSSLが証明書をどのようにチェックするかを設定できます。これは、自己署名証明書と/またはワイルドカード証明書を検証する必要がある場合に非常に便利です。OpenSSLの検証定数（'none'または'peer'）の名前または定数（`OpenSSL::SSL::VERIFY_NONE`または`OpenSSL::SSL::VERIFY_PEER`）を使用できます。</li><li>`:ssl/:tls` - SMTP接続がSMTP/TLS（SMTPS：直接TLS接続上のSMTP）を使用するようにします。</li><li>`:open_timeout` - 接続を開こうとする間の待機時間（秒単位）。</li><li>`:read_timeout` - 読み取り（2）呼び出しのタイムアウトまでの待機時間（秒単位）。</li></ul>|
|`sendmail_settings`|`:sendmail`配信方法のオプションを上書きすることができます。<ul><li>`:location` - sendmail実行可能ファイルの場所。デフォルトは`"/usr/sbin/sendmail"`です。</li><li>`:arguments` - sendmailに渡されるコマンドライン引数。デフォルトは`["-i"]`です。</li></ul>|
|`raise_delivery_errors`|メールの配信に失敗した場合にエラーを発生させるかどうかを指定します。これは、外部のメールサーバーが即時配信に設定されている場合にのみ機能します。デフォルトは`true`です。|
|`delivery_method`|配信方法を定義します。可能な値は次のとおりです：<ul><li>`:smtp`（デフォルト） - [`config.action_mailer.smtp_settings`][]を使用して設定できます。</li><li>`:sendmail` - [`config.action_mailer.sendmail_settings`][]を使用して設定できます。</li><li>`:file` - メールをファイルに保存します。`config.action_mailer.file_settings`を使用して設定できます。</li><li>`:test` - メールを`ActionMailer::Base.deliveries`配列に保存します。</li></ul>詳細については、[APIドキュメント](https://api.rubyonrails.org/classes/ActionMailer/Base.html)を参照してください。|
|`perform_deliveries`|`deliver`メソッドがMailメッセージで呼び出されたときに、実際に配信が行われるかどうかを決定します。デフォルトでは、配信が行われますが、これをオフにすると機能テストに役立ちます。この値が`false`の場合、`delivery_method`が`:test`であっても`deliveries`配列は更新されません。|
|`deliveries`|`Action Mailer`を介して送信されたすべてのメールを`delivery_method`が`:test`の場合に保持する配列です。ユニットテストと機能テストに最も役立ちます。|
|`delivery_job`|`deliver_later`で使用されるジョブクラスです。デフォルトは`ActionMailer::MailDeliveryJob`です。|
|`deliver_later_queue_name`|デフォルトの`delivery_job`で使用されるキューの名前です。デフォルトはデフォルトのActive Jobキューです。|
|`default_options`|`mail`メソッドのオプション（`:from`、`:reply_to`など）のデフォルト値を設定できます。|
完全な設定の詳細については、Configuring Rails Applicationsガイドの[Configuring Action Mailer](configuring.html#configuring-action-mailer)を参照してください。

### Action Mailerの設定例

以下を適切な`config/environments/$RAILS_ENV.rb`ファイルに追加する例です。

```ruby
config.action_mailer.delivery_method = :sendmail
# デフォルト:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Gmail用のAction Mailerの設定

Action Mailerは[Mail gem](https://github.com/mikel/mail)を使用し、類似の設定を受け入れます。
Gmail経由で送信するには、以下を`config/environments/$RAILS_ENV.rb`ファイルに追加してください。

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

Mail gemの古いバージョン（2.6.x以前）を使用している場合は、`enable_starttls`の代わりに`enable_starttls_auto`を使用してください。

注意：Googleは、より安全でないと判断したアプリからのサインインをブロックします。
試行を許可するために、Gmailの設定を[ここ](https://www.google.com/settings/security/lesssecureapps)で変更できます。Gmailアカウントで2要素認証が有効になっている場合は、通常のパスワードの代わりに[アプリパスワード](https://myaccount.google.com/apppasswords)を設定する必要があります。

メーラーテスト
--------------

メーラーのテスト方法の詳細な手順については、[テストガイド](testing.html#testing-your-mailers)を参照してください。

メールのインターセプトと監視
-------------------

Action Mailerは、メールの配信ライフサイクルの間に呼び出されるクラスを登録するためのMailオブザーバーとインターセプターのフックを提供します。

### メールのインターセプト

インターセプターを使用すると、メールが配信エージェントに渡される前に変更を加えることができます。インターセプタークラスは、メールが送信される前に呼び出される`::delivering_email(message)`メソッドを実装する必要があります。

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

インターセプターが機能する前に、`interceptors`の設定オプションを使用して登録する必要があります。
これは、`config/initializers/mail_interceptors.rb`のような初期化ファイルで行うことができます。

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

注意：上記の例では、テスト目的のプロダクションライクなサーバーに「staging」というカスタム環境を使用しています。カスタムRails環境についての詳細は、[Creating Rails Environments](configuring.html#creating-rails-environments)を参照してください。

### メールの監視

オブザーバーを使用すると、メールが送信された後にメールメッセージにアクセスできます。オブザーバークラスは、メールが送信された後に呼び出される`:delivered_email(message)`メソッドを実装する必要があります。

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

インターセプターと同様に、`observers`の設定オプションを使用してオブザーバーを登録する必要があります。
これは、`config/initializers/mail_observers.rb`のような初期化ファイルで行うことができます。

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
