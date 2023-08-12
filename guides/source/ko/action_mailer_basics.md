**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Action Mailer 기본 사항
====================

이 가이드는 애플리케이션에서 이메일을 보내는 데 필요한 모든 정보와 Action Mailer의 내부 동작 방식을 제공합니다. 또한 메일러를 테스트하는 방법도 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* Rails 애플리케이션에서 이메일을 보내는 방법.
* Action Mailer 클래스와 메일러 뷰를 생성하고 편집하는 방법.
* 환경에 맞게 Action Mailer를 구성하는 방법.
* Action Mailer 클래스를 테스트하는 방법.

--------------------------------------------------------------------------------

Action Mailer란?
----------------------

Action Mailer를 사용하면 메일러 클래스와 뷰를 사용하여 애플리케이션에서 이메일을 보낼 수 있습니다.

### 메일러는 컨트롤러와 유사합니다

메일러는 [`ActionMailer::Base`][]를 상속하고 `app/mailers`에 위치합니다. 메일러도 컨트롤러와 매우 유사하게 동작합니다. 유사한 점은 다음과 같습니다. 메일러는:

* 액션과 관련된 뷰를 `app/views`에 표시합니다.
* 뷰에서 접근 가능한 인스턴스 변수를 가지고 있습니다.
* 레이아웃과 파셜을 사용할 수 있습니다.
* params 해시에 접근할 수 있습니다.


이메일 보내기
--------------

이 섹션에서는 메일러와 그 뷰를 생성하는 단계별 가이드를 제공합니다.

### 메일러 생성하기

#### 메일러 생성하기

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

보시다시피, Rails에서 다른 생성기를 사용하는 것과 마찬가지로 메일러를 생성할 수 있습니다.

생성기를 사용하지 않으려면 `app/mailers` 안에 직접 파일을 만들면 됩니다. 다만, `ActionMailer::Base`를 상속하는지 확인하세요.

```ruby
class MyMailer < ActionMailer::Base
end
```

#### 메일러 편집하기

메일러에는 "액션"이라고 불리는 메소드가 있으며, 뷰를 사용하여 내용을 구성합니다. 컨트롤러가 클라이언트로 보내기 위해 HTML과 같은 콘텐츠를 생성하는 것과 달리, 메일러는 이메일로 전달될 메시지를 생성합니다.

`app/mailers/user_mailer.rb`에는 빈 메일러가 있습니다:

```ruby
class UserMailer < ApplicationMailer
end
```

사용자의 등록된 이메일 주소로 이메일을 보내는 `welcome_email`이라는 메소드를 추가해 보겠습니다:

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

위 메소드에서 제시된 항목에 대해 간단히 설명하겠습니다. 사용 가능한 모든 옵션의 전체 목록은 Complete List of Action Mailer user-settable attributes 섹션을 참조하세요.

* [`default`][] 메소드는 이 메일러에서 보내는 모든 이메일에 대한 기본값을 설정합니다. 이 경우, 이 클래스의 모든 메시지에 대한 `:from` 헤더 값을 설정하는 데 사용됩니다. 이는 개별 이메일마다 재정의할 수 있습니다.
* [`mail`][] 메소드는 실제 이메일 메시지를 생성합니다. 이메일마다 `:to`와 `:subject`와 같은 헤더의 값을 지정하는 데 사용합니다.


#### 메일러 뷰 생성하기

`app/views/user_mailer/`에 `welcome_email.html.erb`라는 파일을 생성합니다. 이 파일은 HTML로 포맷된 이메일 템플릿입니다:

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

이메일의 텍스트 부분도 만들어 보겠습니다. 모든 클라이언트가 HTML 이메일을 선호하지 않으므로 둘 다 보내는 것이 좋은 방법입니다. 이를 위해 `app/views/user_mailer/`에 `welcome_email.text.erb`라는 파일을 생성하세요:

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```
`mail` 메서드를 호출하면 Action Mailer는 두 개의 템플릿(텍스트와 HTML)을 감지하고 자동으로 `multipart/alternative` 이메일을 생성합니다.

#### Mailer 호출하기

메일러는 실제로 뷰를 렌더링하는 또 다른 방법입니다. 뷰를 렌더링하고 HTTP 프로토콜을 통해 전송하는 대신, 이메일 프로토콜을 통해 전송합니다. 따라서 컨트롤러에서 사용자가 성공적으로 생성되었을 때 메일러에게 이메일을 보내도록 지시하는 것이 합리적입니다.

이를 설정하는 것은 간단합니다.

먼저 `User` 스캐폴드를 생성해 보겠습니다:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

이제 사용할 수 있는 사용자 모델이 있으므로 `app/controllers/users_controller.rb` 파일을 편집하여 `UserMailer`에게 새로 생성된 사용자에게 이메일을 전달하도록 지시하겠습니다. create 액션을 편집하고 사용자가 성공적으로 저장된 후에 `UserMailer.with(user: @user).welcome_email`을 호출하는 코드를 삽입하겠습니다.

컨트롤러 액션이 완료될 때까지 대기하지 않고 이메일을 보내기 위해 [`deliver_later`][]를 사용하여 이메일을 대기열에 넣겠습니다. 이는 Active Job을 기반으로 합니다.

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # 사용자 저장 후 UserMailer에게 환영 이메일을 보내도록 지시합니다.
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

참고: Active Job의 기본 동작은 `:async` 어댑터를 통해 작업을 실행하는 것입니다. 따라서 `deliver_later`를 사용하여 이메일을 비동기적으로 보낼 수 있습니다. Active Job의 기본 어댑터는 프로세스 내 스레드 풀을 사용하여 작업을 실행합니다. 이는 외부 인프라를 필요로하지 않으므로 개발/테스트 환경에 적합하지만, 재시작시 대기 중인 작업을 삭제하므로 프로덕션에는 적합하지 않습니다. 영속적인 백엔드가 필요한 경우 Active Job 어댑터(Sidekiq, Resque 등)를 사용해야 합니다.

즉시 이메일을 보내려면(예: cron 작업에서) [`deliver_now`][]를 호출하면 됩니다:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

[`with`][]에 전달된 모든 키-값 쌍은 메일러 액션의 `params`가 됩니다. 따라서 `with(user: @user, account: @user.account)`는 메일러 액션에서 `params[:user]`와 `params[:account]`를 사용할 수 있게 합니다. 마치 컨트롤러의 params와 같습니다.

`welcome_email` 메서드는 [`ActionMailer::MessageDelivery`][] 객체를 반환하며, 이 객체를 `deliver_now` 또는 `deliver_later`로 자체를 보낼 수 있습니다. `ActionMailer::MessageDelivery` 객체는 [`Mail::Message`][]을 래핑한 것입니다. `Mail::Message` 객체를 검사, 변경 또는 기타 작업을 수행하려면 `ActionMailer::MessageDelivery` 객체의 [`message`][] 메서드를 사용할 수 있습니다.


### 헤더 값 자동 인코딩

Action Mailer는 헤더와 본문 내의 다중바이트 문자의 자동 인코딩을 처리합니다.

자세한 예제(대체 문자 집합 정의 또는 자체 인코딩 텍스트 등)는 [Mail](https://github.com/mikel/mail) 라이브러리를 참조하십시오.

### Action Mailer 메서드의 완전한 목록

거의 모든 이메일 메시지를 보내기 위해 필요한 세 가지 메서드가 있습니다:

* [`headers`][] - 이메일에 원하는 모든 헤더를 지정합니다. 헤더 필드 이름과 값 쌍의 해시를 전달하거나 `headers[:field_name] = 'value'`와 같이 호출할 수 있습니다.
* [`attachments`][] - 이메일에 첨부 파일을 추가할 수 있습니다. 예를 들어, `attachments['file-name.jpg'] = File.read('file-name.jpg')`와 같이 사용할 수 있습니다.
* [`mail`][] - 실제 이메일 자체를 생성합니다. `mail` 메서드에 해시로 헤더를 전달할 수 있습니다. `mail`은 정의된 이메일 템플릿에 따라 일반 텍스트 또는 멀티파트 이메일을 생성합니다.
#### 첨부 파일 추가하기

Action Mailer를 사용하면 첨부 파일을 쉽게 추가할 수 있습니다.

* 파일 이름과 내용을 Action Mailer와 [Mail gem](https://github.com/mikel/mail)에 전달하면 `mime_type`을 자동으로 추측하고 `encoding`을 설정하며 첨부 파일을 생성합니다.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  `mail` 메소드가 트리거되면 첨부 파일이 포함된 멀티파트 이메일이 전송되며, 최상위 수준은 `multipart/mixed`이고 첫 번째 부분은 일반 텍스트와 HTML 이메일 메시지를 포함하는 `multipart/alternative`입니다.

참고: Mail은 첨부 파일을 자동으로 Base64로 인코딩합니다. 다른 인코딩을 원하는 경우 내용을 인코딩하고 인코딩된 내용과 인코딩을 `Hash`로 `attachments` 메소드에 전달하십시오.

* 파일 이름을 전달하고 헤더와 내용을 지정하고 Action Mailer와 Mail은 전달한 설정을 사용합니다.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

참고: 인코딩을 지정하면 Mail은 내용이 이미 인코딩되어 있고 Base64로 인코딩하지 않으리라 가정합니다.

#### 인라인 첨부 파일 만들기

Action Mailer 3.0에서는 이전 3.0 버전에서 많은 해킹이 필요했던 인라인 첨부 파일을 더 간단하고 간단하게 만들 수 있습니다.

* 먼저, 첨부 파일을 인라인 첨부 파일로 변환하도록 Mail에 지시하려면 Mailer 내에서 첨부 파일 메소드에 `#inline`을 호출하기만 하면 됩니다.

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* 그런 다음 뷰에서는 `attachments`를 해시로 참조하고 표시할 첨부 파일을 지정하여 `url`을 호출한 다음 결과를 `image_tag` 메소드에 전달하기만 하면 됩니다.

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* 이는 `image_tag`에 대한 표준 호출이므로 다른 이미지와 마찬가지로 첨부 파일 URL 뒤에 옵션 해시를 전달할 수 있습니다.

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### 여러 수신자에게 이메일 보내기

하나의 이메일에 하나 이상의 수신자에게 이메일을 보낼 수 있습니다(예: 새 가입자에게 모든 관리자에게 알림) `:to` 키에 이메일 목록을 설정함으로써. 이메일 목록은 이메일 주소의 배열이나 쉼표로 구분된 주소가 있는 단일 문자열일 수 있습니다.

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

같은 형식을 사용하여 참조(Cc:) 및 숨은 참조(Bcc:) 수신자를 설정할 수도 있습니다. 각각 `:cc` 및 `:bcc` 키를 사용하면 됩니다.

#### 이름과 함께 이메일 보내기

이메일을 받는 사람에게 이메일 주소만 표시하는 대신 사람의 이름을 표시하려면 [`email_address_with_name`][]을 사용할 수 있습니다.

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'Welcome to My Awesome Site'
  )
end
```

동일한 기술을 사용하여 발신자 이름을 지정할 수도 있습니다.

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Example Company Notifications')
end
```

이름이 빈 문자열인 경우 주소만 반환됩니다.


### Mailer 뷰

Mailer 뷰는 `app/views/name_of_mailer_class` 디렉토리에 위치합니다. 특정 메일러 뷰는 메일러 메소드와 동일한 이름이기 때문에 클래스에 알려져 있습니다. 위의 예에서 `welcome_email` 메소드에 대한 메일러 뷰는 HTML 버전의 경우 `app/views/user_mailer/welcome_email.html.erb`에 있으며 일반 텍스트 버전의 경우 `welcome_email.text.erb`입니다.

동작을 변경하려면 기본 메일러 뷰를 변경하려면 다음과 같이 수행하십시오.

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
이 경우에는 `app/views/notifications` 폴더에서 `another`라는 이름의 템플릿을 찾습니다. 또한 `template_path`에 경로 배열을 지정할 수도 있으며, 순서대로 검색됩니다.

더 많은 유연성이 필요한 경우 블록을 전달하고 특정 템플릿을 렌더링하거나 템플릿 파일을 사용하지 않고 인라인 또는 텍스트를 렌더링할 수도 있습니다.

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

이렇게 하면 HTML 부분에는 'another_template.html.erb' 템플릿이 렌더링되고 텍스트 부분에는 렌더링된 텍스트가 사용됩니다. 렌더 명령은 Action Controller 내부에서 사용되는 것과 동일하므로 `:text`, `:inline` 등과 같은 모든 옵션을 사용할 수 있습니다.

기본 `app/views/mailer_name/` 디렉토리 외부에 있는 템플릿을 렌더링하려면 [`prepend_view_path`][]를 적용할 수 있습니다.

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # "custom/path/to/mailer/view/welcome_email" 템플릿을 로드하려고 시도합니다.
  def welcome_email
    # ...
  end
end
```

[`append_view_path`][] 메서드를 사용할 수도 있습니다.


#### 메일러 뷰 캐싱

[`cache`][] 메서드를 사용하여 응용 프로그램 뷰와 마찬가지로 메일러 뷰에서 프래그먼트 캐싱을 수행할 수 있습니다.

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

이 기능을 사용하려면 응용 프로그램을 다음과 같이 구성해야 합니다.

```ruby
config.action_mailer.perform_caching = true
```

프래그먼트 캐싱은 멀티파트 이메일에서도 지원됩니다.
[Rails 캐싱 가이드](caching_with_rails.html)에서 캐싱에 대해 자세히 알아보세요.


### 액션 메일러 레이아웃

컨트롤러 뷰와 마찬가지로 메일러 레이아웃을 사용할 수도 있습니다. 레이아웃 이름은 메일러와 동일해야 하며, 예를 들어 `user_mailer.html.erb`와 `user_mailer.text.erb`와 같은 이름을 가져야 메일러에서 자동으로 레이아웃으로 인식됩니다.

다른 파일을 사용하려면 메일러에서 [`layout`][]을 호출하면 됩니다.

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # awesome.(html|text).erb를 레이아웃으로 사용합니다.
end
```

컨트롤러 뷰와 마찬가지로 `yield`를 사용하여 레이아웃 내에서 뷰를 렌더링합니다.

또한 format 블록 내부의 render 호출에 `layout: 'layout_name'` 옵션을 전달하여 다른 형식에 대해 다른 레이아웃을 지정할 수도 있습니다.

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

이 경우 HTML 부분은 `my_layout.html.erb` 파일을 사용하여 렌더링되고, 텍스트 부분은 일반적인 `user_mailer.text.erb` 파일이 있다면 해당 파일을 사용합니다.


### 이메일 미리보기

액션 메일러 미리보기는 이메일이 어떻게 보이는지를 확인하기 위해 미리보기 URL을 방문하여 렌더링하는 방법을 제공합니다. 위의 예제에서 `UserMailer`의 미리보기 클래스는 `UserMailerPreview`로 지정되어야 하며, `test/mailers/previews/user_mailer_preview.rb`에 위치해야 합니다. `welcome_email`의 미리보기를 보려면 동일한 이름을 가진 메서드를 구현하고 `UserMailer.welcome_email`을 호출하면 됩니다.

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

그런 다음 미리보기는 <http://localhost:3000/rails/mailers/user_mailer/welcome_email>에서 사용할 수 있습니다.

`app/views/user_mailer/welcome_email.html.erb` 또는 메일러 자체에서 변경 사항이 발생하면 자동으로 다시로드되고 렌더링되므로 새로운 스타일을 즉시 시각적으로 확인할 수 있습니다. 미리보기 목록은 <http://localhost:3000/rails/mailers>에서도 확인할 수 있습니다.

기본적으로 이러한 미리보기 클래스는 `test/mailers/previews`에 있습니다. `preview_paths` 옵션을 사용하여 이를 구성할 수 있습니다. 예를 들어 `lib/mailer_previews`를 추가하려면 `config/application.rb`에서 구성할 수 있습니다.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### 액션 메일러 뷰에서 URL 생성

컨트롤러와 달리 메일러 인스턴스에는 들어오는 요청에 대한 컨텍스트가 없으므로 `:host` 매개변수를 직접 제공해야 합니다.

일반적으로 `:host`는 응용 프로그램 전체에서 일관되기 때문에 `config/application.rb`에서 전역적으로 구성할 수 있습니다.

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```
이 동작으로 인해 이메일 내에서 `*_path` 헬퍼를 사용할 수 없습니다. 대신 관련된 `*_url` 헬퍼를 사용해야 합니다. 예를 들어 다음과 같이 사용하는 대신:

```html+erb
<%= link_to 'welcome', welcome_path %>
```

다음을 사용해야 합니다:

```html+erb
<%= link_to 'welcome', welcome_url %>
```

전체 URL을 사용함으로써 이제 이메일에서 링크가 작동합니다.

#### `url_for`를 사용하여 URL 생성하기

[`url_for`][]은 템플릿에서 기본적으로 전체 URL을 생성합니다.

전역적으로 `:host` 옵션을 구성하지 않은 경우 `url_for`에 전달해야 합니다.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### 명명된 라우트를 사용하여 URL 생성하기

이메일 클라이언트에는 웹 컨텍스트가 없으므로 경로에는 완전한 웹 주소를 형성할 기본 URL이 없습니다. 따라서 항상 명명된 라우트 헬퍼의 `*_url` 변형을 사용해야 합니다.

전역적으로 `:host` 옵션을 구성하지 않은 경우 URL 헬퍼에 전달해야 합니다.

```erb
<%= user_url(@user, host: 'example.com') %>
```

참고: 비-`GET` 링크는 [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) 또는 [jQuery UJS](https://github.com/rails/jquery-ujs)가 필요하며 메일러 템플릿에서 작동하지 않습니다. 이는 일반적인 `GET` 요청으로 처리됩니다.

### Action Mailer 뷰에 이미지 추가하기

컨트롤러와 달리 메일러 인스턴스에는 수신 요청에 대한 컨텍스트가 없으므로 `:asset_host` 매개변수를 직접 제공해야 합니다.

일반적으로 `:asset_host`는 애플리케이션 전체에서 일관되기 때문에 `config/application.rb`에서 전역적으로 구성할 수 있습니다:

```ruby
config.asset_host = 'http://example.com'
```

이제 이메일 내에서 이미지를 표시할 수 있습니다.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Multipart 이메일 보내기

동일한 액션에 대해 다른 템플릿이 있는 경우 Action Mailer는 자동으로 멀티파트 이메일을 보냅니다. 따라서 `UserMailer` 예제에서 `app/views/user_mailer`에 `welcome_email.text.erb` 및 `welcome_email.html.erb`가 있는 경우 Action Mailer는 HTML 및 텍스트 버전이 다른 부분으로 설정된 멀티파트 이메일을 자동으로 보냅니다.

삽입되는 부분의 순서는 `ActionMailer::Base.default` 메서드 내의 `:parts_order`에 의해 결정됩니다.

### 동적 전달 옵션으로 이메일 보내기

이메일을 전달하는 동안 기본 전달 옵션(예: SMTP 자격 증명)을 재정의하려면 메일러 액션에서 `delivery_method_options`를 사용하여 이를 수행할 수 있습니다.

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

### 템플릿 렌더링 없이 이메일 보내기

템플릿 렌더링 단계를 건너뛰고 이메일 본문을 문자열로 제공해야 하는 경우 `:body` 옵션을 사용할 수 있습니다. 이러한 경우 `:content_type` 옵션을 추가하는 것을 잊지 마세요. 그렇지 않으면 Rails는 기본적으로 `text/plain`으로 설정됩니다.

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

Action Mailer 콜백
-----------------------

Action Mailer는 메시지를 구성하기 위해 [`before_action`][], [`after_action`][] 및 [`around_action`][]을 지정하고
전달을 제어하기 위해 [`before_deliver`][], [`after_deliver`][] 및 [`around_deliver`][]를 지정할 수 있습니다.

* 콜백은 컨트롤러와 유사하게 메일러 클래스의 블록이나 메서드에 대한 심볼로 지정할 수 있습니다.

* `before_action`을 사용하여 인스턴스 변수를 설정하거나 메일 객체에 기본값을 채우거나 기본 헤더와 첨부 파일을 삽입할 수 있습니다.

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
* `before_action`를 사용하여 `before_action`과 유사한 설정을 할 수 있습니다. 다만, 메일러 액션에서 설정된 인스턴스 변수를 사용합니다.

* `after_action` 콜백을 사용하면 `mail.delivery_method.settings`를 업데이트하여 전송 방법 설정을 재정의할 수도 있습니다.

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
      # 여기에서 메일 인스턴스, @business 및 @user 인스턴스 변수에 액세스할 수 있습니다.
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

* `after_delivery`를 사용하여 메시지 전송 기록을 기록할 수 있습니다.

* 메일러 콜백은 본문이 `nil`이 아닌 값으로 설정되면 추가 처리를 중단합니다. `before_deliver`는 `throw :abort`로 중단할 수 있습니다.


Action Mailer 도우미 사용하기
-----------------------------

Action Mailer는 `AbstractController`를 상속하므로 Action Controller에서 사용하는 대부분의 도우미에 액세스할 수 있습니다.

[`ActionMailer::MailHelper`][]에는 Action Mailer에 특화된 도우미 메서드도 있습니다. 예를 들어, [`mailer`][MailHelper#mailer]를 사용하여 뷰에서 메일러 인스턴스에 액세스하고, [`message`][MailHelper#message]를 사용하여 메시지에 액세스할 수 있습니다:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Action Mailer 구성
-----------------

다음 구성 옵션은 환경 파일(environment.rb, production.rb 등) 중 하나에서 설정하는 것이 가장 좋습니다.

| 구성 옵션 | 설명 |
|---------------|-------------|
|`logger`|사용 가능한 경우 메일링 실행에 대한 정보를 생성합니다. 로깅을 사용하지 않으려면 `nil`로 설정할 수 있습니다. Ruby의 `Logger` 및 `Log4r` 로거와 호환됩니다.|
|`smtp_settings`|`:smtp` 전송 방법에 대한 자세한 구성을 허용합니다:<ul><li>`:address` - 원격 메일 서버를 사용할 수 있도록 합니다. 기본 설정인 `"localhost"`에서 변경하면 됩니다.</li><li>`:port` - 메일 서버가 포트 25에서 실행되지 않는 경우 변경할 수 있습니다.</li><li>`:domain` - HELO 도메인을 지정해야 하는 경우 여기에서 설정할 수 있습니다.</li><li>`:user_name` - 메일 서버가 인증을 요구하는 경우 이 설정에 사용자 이름을 설정합니다.</li><li>`:password` - 메일 서버가 인증을 요구하는 경우 이 설정에 비밀번호를 설정합니다.</li><li>`:authentication` - 메일 서버가 인증을 요구하는 경우 여기에 인증 유형을 지정해야 합니다. 이는 심볼이며 `:plain` (암호를 평문으로 전송), `:login` (암호를 Base64로 인코딩하여 전송) 또는 `:cram_md5` (정보 교환을 위한 도전/응답 메커니즘과 중요 정보를 해시하기 위한 암호화된 메시지 다이제스트 5 알고리즘을 결합) 중 하나입니다.</li><li>`:enable_starttls` - SMTP 서버에 연결할 때 STARTTLS를 사용하고 지원되지 않으면 실패합니다. 기본값은 `false`입니다.</li><li>`:enable_starttls_auto` - SMTP 서버에서 STARTTLS가 활성화되어 있는지 감지하고 사용하기 시작합니다. 기본값은 `true`입니다.</li><li>`:openssl_verify_mode` - TLS를 사용할 때 OpenSSL이 인증서를 확인하는 방법을 설정할 수 있습니다. 자체 서명 및/또는 와일드카드 인증서를 유효성 검사해야 하는 경우 매우 유용합니다. OpenSSL 검증 상수('none' 또는 'peer')의 이름이나 상수(`OpenSSL::SSL::VERIFY_NONE` 또는 `OpenSSL::SSL::VERIFY_PEER`)를 사용할 수 있습니다.</li><li>`:ssl/:tls` - SMTP 연결에 SMTP/TLS(직접 TLS 연결을 통한 SMTPS)를 사용합니다.</li><li>`:open_timeout` - 연결을 열려고 시도하는 동안 대기할 시간(초)입니다.</li><li>`:read_timeout` - 읽기(2) 호출을 타임아웃하는 데 대기할 시간(초)입니다.</li></ul>|
|`sendmail_settings`|`:sendmail` 전송 방법에 대한 옵션을 재정의할 수 있습니다.<ul><li>`:location` - sendmail 실행 파일의 위치입니다. 기본값은 `/usr/sbin/sendmail`입니다.</li><li>`:arguments` - sendmail에 전달할 커맨드 라인 인수입니다. 기본값은 `["-i"]`입니다.</li></ul>|
|`raise_delivery_errors`|이메일 전송에 실패한 경우 오류를 발생시킬지 여부를 결정합니다. 이는 외부 이메일 서버가 즉시 전송으로 구성된 경우에만 작동합니다. 기본값은 `true`입니다.|
|`delivery_method`|전송 방법을 정의합니다. 가능한 값은 다음과 같습니다:<ul><li>`:smtp` (기본값) - [`config.action_mailer.smtp_settings`][]을 사용하여 구성할 수 있습니다.</li><li>`:sendmail` - [`config.action_mailer.sendmail_settings`][]을 사용하여 구성할 수 있습니다.</li><li>`:file` - 이메일을 파일로 저장합니다. `config.action_mailer.file_settings`를 사용하여 구성할 수 있습니다.</li><li>`:test` - 이메일을 `ActionMailer::Base.deliveries` 배열에 저장합니다.</li></ul>자세한 내용은 [API 문서](https://api.rubyonrails.org/classes/ActionMailer/Base.html)를 참조하세요.|
|`perform_deliveries`|`deliver` 메서드가 Mail 메시지에서 호출될 때 실제로 전송이 수행되는지 여부를 결정합니다. 기본적으로 전송이 수행되지만, 기능 테스트를 돕기 위해 이를 비활성화할 수 있습니다. 이 값이 `false`인 경우 `delivery_method`가 `:test`이더라도 `deliveries` 배열이 채워지지 않습니다.|
|`deliveries`|`Action Mailer`를 통해 전송된 모든 이메일을 `:test` `delivery_method`로 저장하는 배열입니다. 단위 및 기능 테스트에 가장 유용합니다.|
|`delivery_job`|`deliver_later`에서 사용되는 작업 클래스입니다. 기본값은 `ActionMailer::MailDeliveryJob`입니다.|
|`deliver_later_queue_name`|기본 `delivery_job`과 함께 사용되는 큐의 이름입니다. 기본값은 기본 Active Job 큐입니다.|
|`default_options`|`mail` 메서드 옵션(`:from`, `:reply_to` 등)의 기본값을 설정할 수 있습니다.|
[Action Mailer 구성](configuring.html#configuring-action-mailer)에 대한 자세한 설명은 Configuring Rails Applications 가이드에서 확인할 수 있습니다.


### Action Mailer 구성 예제

예를 들어, 다음을 적절한 `config/environments/$RAILS_ENV.rb` 파일에 추가할 수 있습니다:

```ruby
config.action_mailer.delivery_method = :sendmail
# 기본값:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Gmail을 위한 Action Mailer 구성

Action Mailer는 [Mail gem](https://github.com/mikel/mail)을 사용하며 유사한 구성을 허용합니다.
Gmail을 통해 전송하려면 `config/environments/$RAILS_ENV.rb` 파일에 다음을 추가하십시오:

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

Mail gem의 이전 버전(2.6.x 이하)을 사용하는 경우 `enable_starttls` 대신 `enable_starttls_auto`를 사용하십시오.

참고: Google은 앱의 보안 수준이 낮다고 판단하는 경우 [로그인을 차단](https://support.google.com/accounts/answer/6010255)합니다.
로그인을 허용하려면 Gmail 설정을 [여기](https://www.google.com/settings/security/lesssecureapps)에서 변경할 수 있습니다. Gmail 계정에 2단계 인증이 활성화된 경우,
일반 비밀번호 대신 [앱 비밀번호](https://myaccount.google.com/apppasswords)를 설정해야 합니다.

메일러 테스트
--------------

메일러를 테스트하는 방법에 대한 자세한 지침은 [테스트 가이드](testing.html#testing-your-mailers)에서 확인할 수 있습니다.

이메일 가로채기 및 관찰하기
-------------------

Action Mailer는 Mail 옵저버 및 인터셉터 메서드에 훅을 제공합니다. 이를 통해 모든 전송된 이메일의 전송 수명 주기 동안 호출되는 클래스를 등록할 수 있습니다.

### 이메일 가로채기

인터셉터를 사용하면 이메일이 배달 대행자에게 전달되기 전에 수정할 수 있습니다. 인터셉터 클래스는 이메일이 전송되기 전에 호출되는 `::delivering_email(message)` 메서드를 구현해야 합니다.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

인터셉터가 작동하려면 `interceptors` 구성 옵션을 사용하여 등록해야 합니다.
`config/initializers/mail_interceptors.rb`와 같은 초기화 파일에서 이 작업을 수행할 수 있습니다:

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

참고: 위의 예제는 테스트 목적으로 프로덕션과 유사한 서버인 "staging"이라는 사용자 정의 환경을 사용합니다. 사용자 정의 Rails 환경에 대한 자세한 내용은
[Creating Rails Environments](configuring.html#creating-rails-environments)를 참조하십시오.

### 이메일 관찰하기

옵저버는 이메일이 전송된 후에 이메일 메시지에 액세스할 수 있게 해줍니다. 옵저버 클래스는 이메일이 전송된 후에 호출되는 `:delivered_email(message)` 메서드를 구현해야 합니다.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

인터셉터와 마찬가지로 `observers` 구성 옵션을 사용하여 옵저버를 등록해야 합니다.
`config/initializers/mail_observers.rb`와 같은 초기화 파일에서 이 작업을 수행할 수 있습니다:

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
