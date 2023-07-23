**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
貢獻於Ruby on Rails
==================

本指南介紹了如何成為Ruby on Rails持續開發的一部分。

閱讀本指南後，您將了解：

* 如何使用GitHub報告問題。
* 如何克隆主分支並運行測試套件。
* 如何幫助解決現有問題。
* 如何貢獻於Ruby on Rails文檔。
* 如何貢獻於Ruby on Rails代碼。

Ruby on Rails不是"別人的框架"。多年來，成千上萬的人對Ruby on Rails做出了貢獻，從一個字符到大規模的架構變更或重要的文檔 - 所有這些都是為了使Ruby on Rails對每個人都更好。即使您還不準備寫代碼或文檔，您也可以通過報告問題或測試修補程序等各種方式做出貢獻。

如[Rails的README](https://github.com/rails/rails/blob/main/README.md)中所提到的，所有參與Rails及其子項目的代碼庫、問題跟踪器、聊天室、討論板和郵件列表的人都應遵守Rails的[行為準則](https://rubyonrails.org/conduct)。

--------------------------------------------------------------------------------

報告問題
--------

Ruby on Rails使用[GitHub問題跟踪](https://github.com/rails/rails/issues)來跟踪問題（主要是錯誤和新代碼的貢獻）。如果您在Ruby on Rails中發現了一個錯誤，這是開始的地方。您需要創建一個（免費）GitHub帳戶來提交問題、對問題發表評論或創建拉取請求。

注意：最新版本的Ruby on Rails中的錯誤可能會得到最多的關注。此外，Rails核心團隊始終對那些能花時間測試"edge Rails"（當前正在開發中的Rails版本的代碼）的人的反饋感興趣。在本指南的後面，您將了解如何獲取edge Rails進行測試。有關支持的版本信息，請參閱我們的[維護政策](maintenance_policy.html)。請勿在GitHub問題跟踪器上報告安全問題。

### 創建錯誤報告

如果您在Ruby on Rails中發現的問題不是安全風險，請在GitHub的[Issues](https://github.com/rails/rails/issues)中搜索，以查看是否已經有人報告了該問題。如果您找不到任何開放的GitHub問題解決該問題，那麼您的下一步將是[創建新問題](https://github.com/rails/rails/issues/new)（有關報告安全問題的信息，請參見下一節）。

我們為您提供了一個問題模板，以便在創建問題時包含所有需要的信息，以確定框架中是否存在錯誤。每個問題都需要包含標題和清晰的問題描述。請確保包含盡可能多的相關信息，包括展示預期行為的代碼示例或失敗的測試，以及您的系統配置。您的目標應該是使自己和其他人能夠輕鬆地重現該錯誤並找到解決方法。

一旦您打開一個問題，除非它是一個"緊急問題，關乎生死存亡"的錯誤，否則它可能不會立即看到活動。這並不意味著我們不關心您的錯誤，只是有很多問題和拉取請求需要處理。有相同問題的其他人可以找到您的問題，確認該錯誤，並可能與您合作修復它。如果您知道如何修復該錯誤，請打開一個拉取請求。

### 創建可執行的測試案例

有一種方法可以重現您的問題，這將有助於人們確認、調查並最終修復您的問題。您可以通過提供可執行的測試案例來實現這一點。為了使這個過程更加容易，我們為您準備了幾個問題報告模板，供您作為起點使用：

* Active Record（模型、數據庫）問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* 測試Active Record（遷移）問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Action Pack（控制器、路由）問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Active Job問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Active Storage問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Action Mailbox問題的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* 其他問題的通用模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

這些模板包含了設置對已發布版本的Rails（`*_gem.rb`）或edge Rails（`*_main.rb`）進行測試的樣板代碼。
將適當的模板內容複製到 `.rb` 檔案中，並進行必要的更改以展示問題。您可以在終端機中執行 `ruby the_file.rb` 來執行它。如果一切順利，您應該會看到測試案例失敗的結果。

然後，您可以將可執行的測試案例分享為 [gist](https://gist.github.com) 或將內容貼到問題描述中。

### 對於安全問題的特殊處理

警告：請不要通過公開的 GitHub 問題報告來報告安全漏洞。[Rails 安全政策頁面](https://rubyonrails.org/security)詳細說明了處理安全問題的程序。

### 關於功能請求呢？

請不要將「功能請求」項目放入 GitHub Issues 中。如果您想要在 Ruby on Rails 中新增一個新功能，您需要自己編寫程式碼，或者說服其他人與您合作編寫程式碼。在本指南的後面部分，您將找到有關提議修補 Ruby on Rails 的詳細說明。如果您在 GitHub Issues 中輸入了一個沒有程式碼的願望清單項目，您可以預期它在審查時會被標記為「無效」。

有時，「錯誤」和「功能」之間的界線很難劃清。一般來說，功能是指添加新行為的任何事物，而錯誤是指導致不正確行為的任何事物。有時，核心團隊必須做出判斷。也就是說，這個區別通常決定了您的更改將與哪個修補程式一起發布；我們喜歡功能提交！只是它們不會被回溯到維護分支。

如果您想在開始進行修補的工作之前對一個功能的想法獲得反饋，請在 [rails-core 討論區](https://discuss.rubyonrails.org/c/rubyonrails-core)上開始一個討論。您可能得不到回應，這意味著每個人都不關心。您可能會找到其他也有興趣建立該功能的人。您可能會得到「這不會被接受」的回應。但這是討論新想法的正確場所。GitHub Issues 不是一個特別適合進行有時需要長時間且涉及的討論的場所。

幫助解決現有問題
------------------

除了報告問題外，您還可以通過提供反饋來幫助核心團隊解決現有問題。如果您是 Ruby on Rails 核心開發的新手，提供反饋將幫助您熟悉代碼庫和流程。

如果您在 GitHub Issues 中檢查 [問題列表](https://github.com/rails/rails/issues)，您會發現許多已經需要關注的問題。您對這些問題能做些什麼呢？實際上有很多：

### 驗證錯誤報告

首先，驗證錯誤報告是有幫助的。您能在自己的電腦上重現報告的問題嗎？如果可以，您可以在問題中添加一個評論，說明您也遇到了同樣的問題。

如果問題非常模糊，您能幫助將其縮小到更具體的問題嗎？也許您可以提供額外的信息來重現錯誤，或者您可以消除不必要的步驟，這些步驟不需要來展示問題。

如果您找到一個沒有測試的錯誤報告，提供一個失敗的測試非常有用。這也是探索源代碼的一個很好的方式：查看現有的測試文件將教您如何編寫更多的測試。新的測試最好以修補程式的形式貢獻，如後面的 [貢獻到 Rails 代碼](#contributing-to-the-rails-code) 部分所述。

您所能做的任何使錯誤報告更簡潔或更容易重現的事情都有助於嘗試編寫修復這些錯誤的程式碼的人 - 無論您最終是否自己編寫程式碼。

### 測試修補程式

您還可以通過檢查通過 GitHub 提交給 Ruby on Rails 的拉取請求來幫助。為了應用某人的更改，首先創建一個專用分支：

```bash
$ git checkout -b testing_branch
```

然後，您可以使用他們的遠端分支來更新您的代碼庫。例如，假設 GitHub 用戶 JohnSmith 已經分叉並推送到位於 https://github.com/JohnSmith/rails 的主題分支 "orange"。

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

將他們的分支應用後，測試一下！以下是一些需要考慮的事情：
* 這個改變真的有效嗎？
* 你對測試滿意嗎？你能理解他們在測試什麼嗎？有任何遺漏的測試嗎？
* 它有適當的文件涵蓋嗎？應該更新其他地方的文件嗎？
* 你喜歡這個實現嗎？你能想到更好或更快的方式來實現他們的改變的一部分嗎？

一旦你確定拉取請求包含了一個好的改變，請在 GitHub 的問題上留下評論，指出你的發現。你的評論應該表明你喜歡這個改變，以及你喜歡它的哪些方面。例如：

> 我喜歡你在 generate_finder_sql 中重組代碼的方式，看起來更好。測試看起來也不錯。

如果你的評論只是寫 "+1"，那麼其他審查者可能不會太認真對待。展示出你花時間審查拉取請求的事實。

貢獻 Rails 文件
----------------

Ruby on Rails 有兩個主要的文件集：指南（guides），用於幫助你學習 Ruby on Rails，以及 API 參考，用作參考。

你可以通過使它們更連貫、一致或可讀，添加遺漏的信息，更正事實錯誤，修正拼寫錯誤，或使它們與最新的 Rails 版本保持一致，來幫助改進 Rails 指南或 API 參考。

要這樣做，修改 Rails 指南源文件（位於 GitHub 上的 [這裡](https://github.com/rails/rails/tree/main/guides/source)）或源代碼中的 RDoc 註釋。然後打開一個拉取請求，將你的更改應用到主分支。

在處理文件時，請考慮 [API 文件指南](api_documentation_guidelines.html) 和 [Ruby on Rails 指南指南](ruby_on_rails_guides_guidelines.html)。

翻譯 Rails 指南
----------------

我們很高興有人自願翻譯 Rails 指南。只需按照以下步驟進行：

* Fork https://github.com/rails/rails。
* 為你的語言添加一個源文件夾，例如：*guides/source/it-IT* 用於義大利語。
* 將 *guides/source* 的內容複製到你的語言目錄中並進行翻譯。
* 不要翻譯 HTML 文件，因為它們是自動生成的。

請注意，翻譯不會提交到 Rails 存儲庫；你的工作存在於你的 fork 中，如上所述。這是因為在實踐中，通過補丁進行文檔維護只在英語中可持續。

要生成 HTML 格式的指南，你需要安裝指南的依賴項，`cd` 到 *guides* 目錄，然後運行（例如，對於 it-IT）：

```bash
# 只安裝指南所需的 gem。要撤消操作，運行：bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

這將在 *output* 目錄中生成指南。

注意：Redcarpet Gem 在 JRuby 上無法正常工作。

我們知道的翻譯努力（各種版本）：

* **義大利語**：[https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **西班牙語**：[https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **波蘭語**：[https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **法語**：[https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **捷克語**：[https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **土耳其語**：[https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **韓語**：[https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **簡體中文**：[https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **繁體中文**：[https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **俄語**：[https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **日語**：[https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **巴西葡萄牙語**：[https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

貢獻到 Rails 代碼
----------------

### 設置開發環境

要從提交錯誤報告轉向幫助解決現有問題或貢獻自己的代碼到 Ruby on Rails，你必須能夠運行其測試套件。在本指南的這一部分，你將學習如何在你的計算機上設置測試。

#### 使用 GitHub Codespaces

如果你是一個啟用了 Codespaces 的組織的成員，你可以將 Rails fork 到該組織中並在 GitHub 上使用 Codespaces。Codespace 將初始化所有所需的依賴項，並允許你運行所有測試。

#### 使用 VS Code 遠程容器

如果你已經安裝了 [Visual Studio Code](https://code.visualstudio.com) 和 [Docker](https://www.docker.com)，你可以使用 [VS Code 遠程容器插件](https://code.visualstudio.com/docs/remote/containers-tutorial)。該插件將讀取存儲庫中的 [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) 配置並在本地構建 Docker 容器。

#### 使用 Dev Container CLI

另外，使用安裝了 [Docker](https://www.docker.com) 和 [npm](https://github.com/npm/cli) 的情況下，你可以運行 [Dev Container CLI](https://github.com/devcontainers/cli) 來使用命令行中的 [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) 配置。

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### 使用 rails-dev-box

也可以使用 [rails-dev-box](https://github.com/rails/rails-dev-box) 來準備開發環境。但是，rails-dev-box 使用 Vagrant 和 Virtual Box，在搭載 Apple Silicon 的 Mac 上無法運行。
#### 本地開發

如果無法使用 GitHub Codespaces，請參考[這份指南](development_dependencies_install.html)來設置本地開發環境。這被認為是比較困難的方式，因為安裝相依套件可能會因作業系統而有所不同。

### 複製 Rails 倉庫

為了能夠貢獻程式碼，您需要複製 Rails 倉庫：

```bash
$ git clone https://github.com/rails/rails.git
```

並建立一個專用的分支：

```bash
$ cd rails
$ git checkout -b my_new_branch
```

您可以使用任何名稱，因為這個分支只會存在於您的本地電腦和 GitHub 上的個人倉庫中，不會成為 Rails Git 倉庫的一部分。

### 安裝 Bundle

安裝所需的 gem 套件。

```bash
$ bundle install
```

### 在本地分支上運行應用程式

如果您需要一個虛擬的 Rails 應用程式來測試更改，`rails new` 的 `--dev` 參數會生成一個使用您的本地分支的應用程式：

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

在 `~/my-test-app` 中生成的應用程式將運行在您的本地分支上，並且在伺服器重新啟動時會看到任何修改。

對於 JavaScript 套件，您可以使用 [`yarn link`](https://yarnpkg.com/cli/link) 在生成的應用程式中引用您的本地分支：

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### 編寫程式碼

現在是時候開始編寫程式碼了！在為 Rails 做更改時，請記住以下幾點：

* 遵循 Rails 的風格和慣例。
* 使用 Rails 的習語和輔助工具。
* 包含在沒有您的程式碼時會失敗的測試，並在有您的程式碼時通過測試。
* 更新（周圍的）文件、其他地方的範例和指南：任何受到您貢獻影響的內容。
* 如果更改添加、刪除或更改了功能，請確保包含 CHANGELOG 項目。如果您的更改是修復錯誤，則不需要 CHANGELOG 項目。

提示：通常不會接受對穩定性、功能性或可測試性沒有實質貢獻的純粹外觀變更（詳細了解[我們做出這個決定的原因](https://github.com/rails/rails/pull/13771#issuecomment-32746700)）。

#### 遵循編碼慣例

Rails 遵循一套簡單的編碼風格慣例：

* 使用兩個空格，不使用 tab（用於縮排）。
* 不要在行尾留下空白。空行不應該有任何空格。
* 在 private/protected 之後進行縮排並留下空行。
* 使用 Ruby >= 1.9 的語法來表示哈希。優先使用 `{ a: :b }` 而不是 `{ :a => :b }`。
* 優先使用 `&&`/`||` 而不是 `and`/`or`。
* 優先使用 `class << self` 而不是 `self.method` 來定義類方法。
* 使用 `my_method(my_arg)` 而不是 `my_method( my_arg )` 或 `my_method my_arg`。
* 使用 `a = b` 而不是 `a=b`。
* 使用 `assert_not` 方法而不是 `refute`。
* 單行塊使用 `method { do_stuff }` 而不是 `method{do_stuff}`。
* 遵循已使用的源代碼中的慣例。

上述為指南 - 請根據您的判斷使用它們。

此外，我們定義了 [RuboCop](https://www.rubocop.org/) 規則來規範一些編碼慣例。您可以在提交拉取請求之前在本地運行 RuboCop 檢查您修改的文件：

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

對於 `rails-ujs` 的 CoffeeScript 和 JavaScript 文件，您可以在 `actionview` 文件夾中運行 `npm run lint`。

#### 拼寫檢查

我們使用 [misspell](https://github.com/client9/misspell) 來檢查拼寫，它主要是使用 [Golang](https://golang.org/) 編寫的，並通過 [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml) 執行。使用 `misspell` 快速修正常見的拼寫錯誤。`misspell` 與大多數其他拼寫檢查器不同，它不使用自定義詞典。您可以在所有文件上運行 `misspell` 來檢查拼寫：

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

`misspell` 的一些重要幫助選項或標誌如下：

- `-i` 字串：忽略以下修正，以逗號分隔
- `-w`：使用修正覆寫文件（默認只顯示）

我們還使用 GitHub Actions 執行 [codespell](https://github.com/codespell-project/codespell) 來檢查拼寫，並且 [codespell](https://pypi.org/project/codespell/) 會運行在一個[小型自定義詞典](https://github.com/rails/rails/blob/main/codespell.txt)上。`codespell` 是使用 [Python](https://www.python.org/) 編寫的，您可以使用以下命令運行它：

```bash
$ codespell --ignore-words=codespell.txt
```

### 基準測試您的程式碼

對於可能對性能產生影響的更改，請對您的程式碼進行基準測試並測量其影響。請分享您使用的基準測試腳本以及結果。您應該考慮將此信息包含在您的提交訊息中，以便未來的貢獻者可以輕鬆驗證您的結果並確定它們是否仍然相關（例如，Ruby VM 中的未來優化可能會使某些優化變得不必要）。
當優化特定場景時，很容易導致其他常見情況的性能下降。
因此，您應該將您的更改與一個代表性場景列表進行測試，最好是從現實世界的生產應用程序中提取出來。

您可以使用 [基準測試模板](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb) 作為起點。它包含了使用 [benchmark-ips](https://github.com/evanphx/benchmark-ips) gem 設置基準測試的樣板代碼。該模板適用於測試相對獨立的更改，可以內聯到腳本中。

### 執行測試

在推送更改之前，Rails 不習慣運行完整的測試套件。特別是 railties 測試套件需要很長時間，如果源代碼像在 [rails-dev-box](https://github.com/rails/rails-dev-box) 推薦的工作流程中一樣掛載在 `/vagrant` 中，則需要更長的時間。

作為一種妥協，測試您的代碼明顯影響的部分，如果更改不在 railties 中，則運行受影響組件的完整測試套件。如果所有測試都通過，那就足以提出您的貢獻。我們有 [Buildkite](https://buildkite.com/rails/rails) 作為捕捉其他意外故障的安全網。

#### 整個 Rails：

運行所有測試，執行：

```bash
$ cd rails
$ bundle exec rake test
```

#### 特定組件

您可以僅運行特定組件的測試（例如，Action Pack）。例如，運行 Action Mailer 測試：

```bash
$ cd actionmailer
$ bin/test
```

#### 特定目錄

您可以僅運行特定組件的特定目錄的測試（例如，Active Storage 中的模型）。例如，運行 `/activestorage/test/models` 中的測試：

```bash
$ cd activestorage
$ bin/test models
```

#### 特定文件

您可以運行特定文件的測試：

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### 執行單個測試

您可以使用 `-n` 選項按名稱運行單個測試：

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### 特定行

找出名稱並不總是容易的，但如果您知道測試開始的行號，則可以使用此選項：

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### 使用特定種子運行測試

測試執行是隨機的，具有隨機化種子。如果您遇到隨機測試失敗，可以通過明確設置隨機化種子來更準確地重現失敗的測試場景。

運行組件的所有測試：

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

運行單個測試文件：

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### 串行運行測試

Action Pack 和 Action View 單元測試默認並行運行。如果您遇到隨機測試失敗，可以設置隨機化種子並讓這些單元測試以串行方式運行，設置 `PARALLEL_WORKERS=1`

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### 測試 Active Record

首先，創建所需的數據庫。您可以在 `activerecord/test/config.example.yml` 中找到所需的表名、用戶名和密碼列表。

對於 MySQL 和 PostgreSQL，只需運行：

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

或：

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

對於 SQLite3，則不需要這樣做。

這是您僅運行 SQLite3 的 Active Record 測試套件的方法：

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

現在，您可以像運行 `sqlite3` 一樣運行測試。任務分別是：

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

最後，

```bash
$ bundle exec rake test
```

將依次運行這三個測試。

您還可以單獨運行任何單個測試：

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

要對所有適配器運行單個測試，使用：

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

您還可以運行 `test_jdbcmysql`、`test_jdbcsqlite3` 或 `test_jdbcpostgresql`。有關運行更有針對性的數據庫測試的信息，請參閱文件 `activerecord/RUNNING_UNIT_TESTS.rdoc`。

#### 使用調試器進行測試

要使用外部調試器（pry、byebug 等），請安裝調試器並像平常一樣使用它。如果遇到調試器問題，請通過設置 `PARALLEL_WORKERS=1` 以串行方式運行測試，或者使用 `-n test_long_test_name` 運行單個測試。

### 警告

測試套件啟用了警告。理想情況下，Ruby on Rails 應該不會發出警告，但可能會有一些警告，以及一些來自第三方庫的警告。如果有任何警告（或修復警告！），請忽略它們，並提交不發出新警告的補丁。
如果引入警告，Rails CI將會引發錯誤。要在本地實現相同的行為，請在運行測試套件時設置`RAILS_STRICT_WARNINGS=1`。

### 更新文檔

Ruby on Rails的[指南](https://guides.rubyonrails.org/)提供了Rails功能的高級概述，而[API文檔](https://api.rubyonrails.org/)則深入介紹了具體細節。

如果您的PR添加了新功能或更改了現有功能的行為，請檢查相關文檔，並根據需要進行更新或添加。

例如，如果您修改了Active Storage的圖像分析器以添加新的元數據字段，則應更新Active Storage指南的[分析文件](active_storage_overview.html#analyzing-files)部分以反映這一變化。

### 更新CHANGELOG

CHANGELOG是每個版本的重要組成部分，它記錄了每個Rails版本的更改列表。

如果您正在添加或刪除功能，或者添加了棄用通知，則應將條目添加到您修改的框架的CHANGELOG的**頂部**。重構、較小的錯誤修復和文檔更改通常不應該出現在CHANGELOG中。

CHANGELOG條目應該總結所做的更改，並以作者的名字結束。如果需要更多空間，您可以使用多行，並且可以附加使用4個空格縮進的代碼示例。如果更改與特定問題有關，則應該附加問題號。以下是CHANGELOG條目的示例：

```
*   簡要描述更改的摘要。您可以使用多行，並在大約80個字符處換行。如果需要，代碼示例也可以。

        class Foo
          def bar
            puts 'baz'
          end
        end

    您可以在代碼示例之後繼續，並且可以附加問題號。

    修復 #1234。

    *您的名字*
```

如果沒有代碼示例或多個段落，您的名字可以直接添加在最後一個詞之後。否則，最好另起一段。

### 破壞性更改

任何可能破壞現有應用程序的更改都被視為破壞性更改。為了方便升級Rails應用程序，破壞性更改需要進行棄用周期。

#### 刪除行為

如果您的破壞性更改刪除了現有行為，您需要首先添加一個棄用警告，同時保留現有行為。

例如，假設您想刪除`ActiveRecord::Base`上的一個公共方法。如果主分支指向未發布的7.0版本，Rails 7.0將需要顯示一個棄用警告。這確保升級到任何Rails 7.0版本的人都會看到棄用警告。在Rails 7.1中，該方法可以被刪除。

您可以添加以下棄用警告：

```ruby
def deprecated_method
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.deprecated_method` is deprecated and will be removed in Rails 7.1.
  MSG
  # 現有行為
end
```

#### 更改行為

如果您的破壞性更改更改了現有行為，您需要添加一個框架默認值。框架默認值通過允許應用程序逐個切換到新的默認值來簡化Rails升級。

要實現新的框架默認值，首先在目標框架上添加一個設置器，創建一個配置。將默認值設置為現有行為，以確保在升級期間不會出現任何問題。

```ruby
module ActiveJob
  mattr_accessor :existing_behavior, default: true
end
```

新的配置允許您有條件地實現新的行為：

```ruby
def changed_method
  if ActiveJob.existing_behavior
    # 現有行為
  else
    # 新行為
  end
end
```

要設置新的框架默認值，在`Rails::Application::Configuration#load_defaults`中設置新值：

```ruby
def load_defaults(target_version)
  case target_version.to_s
  when "7.1"
    ...
    if respond_to?(:active_job)
      active_job.existing_behavior = false
    end
    ...
  end
end
```

為了方便升級，需要將新的默認值添加到`new_framework_defaults`模板中。添加一個被註釋掉的部分，設置新的值：

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.existing_behavior = false
```

最後一步是將新的配置添加到`configuration.md`中的配置指南中：

```markdown
#### `config.active_job.existing_behavior`

| 開始版本 | 默認值 |
| ------- | ------ |
| (原始)  | `true` |
| 7.1     | `false`|
```

### 忽略編輯器/IDE創建的文件

某些編輯器和IDE會在`rails`文件夾內創建隱藏文件或文件夾。您應該將它們添加到您自己的[全局gitignore文件](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)，而不是手動從每個提交中排除它們或將它們添加到Rails的`.gitignore`中。

### 更新Gemfile.lock

某些更改需要依賴升級。在這些情況下，請確保運行`bundle update`以獲取正確版本的依賴項，並將`Gemfile.lock`文件提交到您的更改中。
### 提交您的更改

當您對電腦上的程式碼感到滿意時，您需要將更改提交到Git：

```bash
$ git commit -a
```

這將啟動您的編輯器以撰寫提交訊息。完成後，保存並關閉以繼續。

一個格式良好且描述性的提交訊息對於他人理解為何進行更改非常有幫助，因此請花些時間撰寫它。

一個好的提交訊息看起來像這樣：

```
簡短摘要（理想情況下不超過50個字符）

更詳細的描述，如果需要的話。每行應該在72個字符處換行。
嘗試盡可能詳細地描述。即使您認為提交內容很明顯，對其他人來說可能並不明顯。
添加任何已存在於相關問題中的描述；不需要訪問網頁來檢查歷史記錄。

描述部分可以有多個段落。

代碼示例可以通過縮進4個空格來嵌入：

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

您還可以添加項目符號：

- 通過以破折號（-）或星號（*）開始一行來製作項目符號

- 在72個字符處換行，並使用2個空格縮進任何額外的行以提高可讀性
```

提示：在適當的時候，請將您的提交合併為一個單一的提交。這樣可以簡化未來的cherry pick操作，並保持git日誌的整潔。

### 更新您的分支

在您工作期間，很可能發生了對主分支的其他更改。要獲取主分支上的新更改：

```bash
$ git checkout main
$ git pull --rebase
```

現在在最新更改的基礎上重新應用您的補丁：

```bash
$ git checkout my_new_branch
$ git rebase main
```

沒有衝突？測試通過？您仍然認為更改是合理的？然後將重新基於的更改推送到GitHub：

```bash
$ git push --force-with-lease
```

我們禁止在rails/rails存儲庫基礎上進行強制推送，但您可以將其強制推送到您的分叉。在進行重新基於時，這是一個要求，因為歷史記錄已更改。

### 分叉

前往Rails的[GitHub存儲庫](https://github.com/rails/rails)並在右上角按下“Fork”。

將新的遠端添加到您本地機器上的本地存儲庫：

```bash
$ git remote add fork https://github.com/<your username>/rails.git
```

您可能已經從rails/rails克隆了本地存儲庫，或者您可能已經從您的分叉存儲庫克隆了本地存儲庫。以下git命令假設您已經建立了一個指向rails/rails的“rails”遠端。

```bash
$ git remote add rails https://github.com/rails/rails.git
```

從官方存儲庫下載新的提交和分支：

```bash
$ git fetch rails
```

合併新內容：

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

更新您的分叉：

```bash
$ git push fork main
$ git push fork my_new_branch
```

### 發起拉取請求

前往您剛剛推送的Rails存儲庫（例如 https://github.com/your-user-name/rails ）並在頂部欄（代碼上方）點擊“拉取請求”。在下一頁中，點擊右上角的“新拉取請求”。

拉取請求應該針對基本存儲庫`rails/rails`和分支`main`。頭存儲庫將是您的工作（`your-user-name/rails`），分支將是您給分支的任何名稱。準備好後，點擊“創建拉取請求”。

確保您引入的變更集已包含在內。使用提供的拉取請求模板填寫有關您的潛在補丁的一些細節。完成後，點擊“創建拉取請求”。

### 獲得一些反饋

大多數拉取請求在合併之前都會經歷幾個迭代。不同的貢獻者有時會有不同的意見，通常需要修訂補丁才能進行合併。

Rails的一些貢獻者已經開啟了GitHub的電子郵件通知，但其他人則沒有。此外，（幾乎）每個在Rails上工作的人都是志願者，因此您可能需要等待幾天才能獲得有關拉取請求的第一個反饋。不要絕望！有時候很快，有時候很慢。這就是開源生活。

如果已經超過一個星期，您還沒有收到任何消息，您可以嘗試推動事情的進展。您可以使用[rubyonrails-core討論區](https://discuss.rubyonrails.org/c/rubyonrails-core)進行這個操作。您也可以在拉取請求中再次留下評論。
當你在等待對於你的拉取請求的回饋時，打開其他幾個拉取請求並給別人一些回饋！他們會像你對於你的修補程式的回饋一樣感激。

請注意，只有核心團隊和貢獻者團隊有權合併程式碼變更。如果有人給予回饋並「核准」你的變更，他們可能沒有權限或最終決定權來合併你的變更。

### 根據需要進行迭代

你得到的回饋可能會建議進行一些變更。不要氣餒：參與活躍的開源專案的整個目的就是利用社區的知識。如果有人鼓勵你微調你的程式碼，那麼值得進行微調並重新提交。如果回饋是你的程式碼不會被合併，你可能仍然考慮將其發布為一個寶石（gem）。

#### 合併提交

我們可能要求你「合併你的提交」，這將把你的所有提交合併為一個提交。我們更喜歡只有一個提交的拉取請求。這樣可以更容易地將變更回溯到穩定分支，合併提交使撤銷錯誤提交更容易，並且 Git 歷史可能更容易跟踪。Rails 是一個大型專案，一堆無關的提交會增加很多噪音。

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< 對於除了第一個提交之外的所有提交，選擇 'squash'。 >
< 編輯提交訊息以使其有意義，並描述所有的變更。 >

$ git push fork my_new_branch --force-with-lease
```

你應該能夠在 GitHub 上刷新拉取請求，並看到它已經更新。

#### 更新拉取請求

有時候你會被要求對你已經提交的程式碼進行一些變更。這可能包括修改現有的提交。在這種情況下，Git 不允許你推送變更，因為推送的分支和本地分支不匹配。你可以強制推送到 GitHub 上的分支，而不是打開一個新的拉取請求，方法如前面「合併提交」一節所述：

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

這將使用你的新程式碼更新分支和 GitHub 上的拉取請求。通過使用 `--force-with-lease` 強制推送，git 將比使用典型的 `-f` 更安全地更新遠端，後者可能會刪除你尚未擁有的遠端工作。

### 舊版本的 Ruby on Rails

如果你想要為比下一個版本更舊的 Ruby on Rails 添加修補，你需要設置並切換到你自己的本地追蹤分支。以下是一個示例，切換到 7-0-stable 分支：

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

注意：在處理舊版本之前，請檢查[維護政策](maintenance_policy.html)。不會接受已經到達生命週期終點的版本的變更。

#### 回溯

合併到 main 的變更是為了下一個主要版本的 Rails。有時候，將你的變更傳播回穩定分支以包含在維護版本中可能是有益的。通常，安全修補和錯誤修補是回溯的好候選，而新功能和改變預期行為的修補則不會被接受。如果有疑問，最好在回溯變更之前諮詢 Rails 團隊成員，以避免浪費努力。

首先，確保你的 main 分支是最新的。

```bash
$ git checkout main
$ git pull --rebase
```

切換到你要回溯的分支，例如 `7-0-stable`，並確保它是最新的：

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

如果你要回溯一個已合併的拉取請求，找到合併的提交並 cherry-pick 它：

```bash
$ git cherry-pick -m1 MERGE_SHA
```

解決在 cherry-pick 中發生的任何衝突，推送你的變更，然後打開一個指向你要回溯的穩定分支的 PR。如果你有一組更複雜的變更，[cherry-pick](https://git-scm.com/docs/git-cherry-pick) 的文檔可以幫助你。

Rails 貢獻者
------------------

所有的貢獻都會在[Rails 貢獻者](https://contributors.rubyonrails.org)中得到認可。
