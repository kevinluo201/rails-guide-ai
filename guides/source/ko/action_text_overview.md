**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Action Text 개요
====================

이 가이드는 풍부한 텍스트 콘텐츠를 처리하기 위해 시작하는 데 필요한 모든 정보를 제공합니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* Action Text를 구성하는 방법.
* 풍부한 텍스트 콘텐츠를 처리하는 방법.
* 풍부한 텍스트 콘텐츠와 첨부 파일을 스타일링하는 방법.

--------------------------------------------------------------------------------

Action Text란 무엇인가?
--------------------

Action Text는 Rails에 풍부한 텍스트 콘텐츠와 편집 기능을 제공합니다. 이는 모든 것을 다루는 [Trix 에디터](https://trix-editor.org)를 포함하고 있습니다. Trix 에디터는 서식, 링크, 인용구, 목록, 내장 이미지 및 갤러리 등을 처리합니다. Trix 에디터에서 생성된 풍부한 텍스트 콘텐츠는 자체 RichText 모델에 저장되며, 응용 프로그램의 기존 Active Record 모델과 연결됩니다. 내장된 이미지(또는 다른 첨부 파일)는 Active Storage를 사용하여 자동으로 저장되며, 포함된 RichText 모델과 연결됩니다.

## 다른 풍부한 텍스트 편집기와 비교한 Trix

대부분의 WYSIWYG 편집기는 HTML의 `contenteditable` 및 `execCommand` API를 래핑한 것입니다. 이 API는 Microsoft가 Internet Explorer 5.5에서 웹 페이지의 실시간 편집을 지원하기 위해 설계한 것이며, 나중에 다른 브라우저에서 역공학적으로 복제되었습니다. 

이 API는 완전히 지정되거나 문서화되지 않았으며, WYSIWYG HTML 편집기는 범위가 매우 크기 때문에 각 브라우저의 구현에는 고유한 버그와 특이점이 있으며, JavaScript 개발자는 이러한 불일치를 해결해야 합니다.

Trix는 contenteditable을 I/O 장치로 취급하여 입력이 편집기로 전달되면 Trix는 해당 입력을 내부 문서 모델의 편집 작업으로 변환한 다음 해당 문서를 다시 편집기로 렌더링합니다. 이를 통해 Trix는 모든 키 입력 후에 발생하는 일에 대해 완전한 제어권을 갖게 되며, execCommand를 사용할 필요가 없어집니다.

## 설치

`bin/rails action_text:install`을 실행하여 Yarn 패키지를 추가하고 필요한 마이그레이션을 복사합니다. 또한, 내장된 이미지와 다른 첨부 파일에 대해 Active Storage를 설정해야 합니다. [Active Storage 개요](active_storage_overview.html) 가이드를 참조하십시오.

참고: Action Text는 `action_text_rich_texts` 테이블과 다형성 관계를 사용하여 풍부한 텍스트 속성을 가진 모든 모델과 공유할 수 있도록 합니다. Action Text 콘텐츠를 사용하는 모델이 식별자로 UUID 값을 사용하는 경우, Action Text 속성을 사용하는 모든 모델도 고유 식별자로 UUID 값을 사용해야 합니다. Action Text에 대한 생성된 마이그레이션도 `:record` `references` 라인에 `type: :uuid`를 지정해야 합니다.

설치가 완료되면 Rails 앱에 다음 변경 사항이 있어야 합니다:

1. JavaScript 진입점에서 `trix`와 `@rails/actiontext`를 모두 요구해야 합니다.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. `trix` 스타일시트는 `application.css` 파일에 Action Text 스타일과 함께 포함됩니다.

## 풍부한 텍스트 콘텐츠 생성

기존 모델에 풍부한 텍스트 필드를 추가합니다:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

또는 다음을 사용하여 새 모델을 생성하는 동안 풍부한 텍스트 필드를 추가합니다:

```bash
$ bin/rails generate model Message content:rich_text
```

참고: `messages` 테이블에 `content` 필드를 추가할 필요가 없습니다.

그런 다음 모델의 폼에서 이 필드를 참조하기 위해 [`rich_text_area`]를 사용합니다:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

마지막으로, 페이지에서 살균된 풍부한 텍스트를 표시합니다:

```erb
<%= @message.content %>
```

참고: `content` 필드 내에 첨부된 리소스가 있는 경우, 로컬 머신에 *libvips/libvips42* 패키지가 설치되어 있지 않으면 제대로 표시되지 않을 수 있습니다. 설치 방법은 [설치 문서](https://www.libvips.org/install.html)를 확인하십시오.

풍부한 텍스트 콘텐츠를 수락하려면 참조된 속성을 허용하기만 하면 됩니다:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## 풍부한 텍스트 콘텐츠 렌더링

기본적으로 Action Text는 풍부한 텍스트 콘텐츠를 `.trix-content` 클래스를 가진 요소 내에 렌더링합니다:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

이 클래스를 가진 요소와 Action Text 편집기는 [`trix` 스타일시트](https://unpkg.com/trix/dist/trix.css)에 의해 스타일이 지정됩니다. 대신 자체 스타일을 제공하려면 설치 프로그램에 의해 생성된 `app/assets/stylesheets/actiontext.css` 스타일시트에서 `= require trix` 줄을 제거하십시오.

풍부한 텍스트 콘텐츠 주위에 렌더링되는 HTML을 사용자 정의하려면 설치 프로그램에 의해 생성된 `app/views/layouts/action_text/contents/_content.html.erb` 레이아웃을 편집하십시오.

내장된 이미지와 다른 첨부 파일(블롭)에 대해 렌더링되는 HTML을 사용자 정의하려면 설치 프로그램에 의해 생성된 `app/views/active_storage/blobs/_blob.html.erb` 템플릿을 편집하십시오.
### 첨부 파일 렌더링

Active Storage를 통해 업로드된 첨부 파일 외에도 Action Text는 [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids)로 해결할 수 있는 모든 것을 삽입할 수 있습니다.

Action Text는 삽입된 `<action-text-attachment>` 요소를 `sgid` 속성을 해결하여 인스턴스로 렌더링합니다. 해결된 인스턴스는 [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render)에 전달됩니다. 그 결과로 생성된 HTML은 `<action-text-attachment>` 요소의 하위 요소로 삽입됩니다.

예를 들어, `User` 모델을 고려해보겠습니다:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

다음으로, `User` 인스턴스의 signed GlobalID를 참조하는 `<action-text-attachment>` 요소를 삽입하는 일부 리치 텍스트 콘텐츠를 고려해보겠습니다:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

Action Text는 "BAh7CEkiCG…" 문자열을 사용하여 `User` 인스턴스를 해결합니다. 그 다음으로, 애플리케이션의 `users/user` 부분을 고려해보겠습니다:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Action Text에 의해 렌더링된 결과 HTML은 다음과 같을 것입니다:

```html
<p>Hello, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

다른 부분을 렌더링하려면 `User#to_attachable_partial_path`를 정의하세요:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

그런 다음 해당 부분을 선언하세요. `User` 인스턴스는 `user` 부분 로컬 변수로 사용할 수 있습니다:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

`User` 인스턴스를 해결할 수 없는 경우 (예: 레코드가 삭제된 경우) Action Text는 기본 대체 부분을 렌더링합니다.

Rails는 누락된 첨부 파일에 대한 전역 부분을 제공합니다. 이 부분은 `views/action_text/attachables/missing_attachable`에 애플리케이션에 설치되며, 다른 HTML을 렌더링하려면 수정할 수 있습니다.

다른 누락된 첨부 파일 부분을 렌더링하려면 클래스 수준의 `to_missing_attachable_partial_path` 메서드를 정의하세요:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

그런 다음 해당 부분을 선언하세요.

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Deleted user</span>
```

Action Text `<action-text-attachment>` 요소 렌더링과 통합하려면 클래스는 다음을 해야 합니다:

* `ActionText::Attachable` 모듈을 포함시킵니다.
* [`GlobalID::Identification` concern][global-id]을 통해 `#to_sgid(**options)`를 구현합니다.
* (선택 사항) `#to_attachable_partial_path`를 선언합니다.
* (선택 사항) 누락된 레코드를 처리하기 위한 클래스 수준의 `#to_missing_attachable_partial_path` 메서드를 선언합니다.

기본적으로 모든 `ActiveRecord::Base` 하위 클래스는 [`GlobalID::Identification` concern][global-id]을 믹스인하므로 `ActionText::Attachable`과 호환됩니다.


## N+1 쿼리 피하기

리치 텍스트 필드의 이름이 `content`인 경우, 종속된 `ActionText::RichText` 모델을 미리로드하려면 다음과 같은 네임드 스코프를 사용할 수 있습니다:

```ruby
Message.all.with_rich_text_content # 첨부 파일 없이 본문만 미리로드합니다.
Message.all.with_rich_text_content_and_embeds # 본문과 첨부 파일을 모두 미리로드합니다.
```

## API / 백엔드 개발

1. 백엔드 API (예: JSON을 사용하는 경우)는 `ActiveStorage::Blob`을 생성하고 해당 `attachable_sgid`를 반환하는 별도의 파일 업로드 엔드포인트가 필요합니다:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. 해당 `attachable_sgid`를 가져와 프론트엔드에게 `<action-text-attachment>` 태그를 사용하여 리치 텍스트 콘텐츠에 삽입하도록 요청합니다:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

이는 Basecamp를 기반으로 하며, 원하는 내용을 찾을 수 없는 경우 [Basecamp 문서](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md)를 확인하세요.
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
