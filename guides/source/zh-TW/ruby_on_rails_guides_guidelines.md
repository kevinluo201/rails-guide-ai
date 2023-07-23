**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Ruby on Rails指南指南
===============================

本指南記錄了編寫Ruby on Rails指南的指導方針。本指南以優雅的循環方式跟隨自己，將自己作為示例。

閱讀本指南後，您將了解：

* Rails文檔中應使用的慣例。
* 如何在本地生成指南。

--------------------------------------------------------------------------------

Markdown
-------

指南使用[GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown)進行編寫。有詳細的[Markdown文檔](https://daringfireball.net/projects/markdown/syntax)，以及一個[速查表](https://daringfireball.net/projects/markdown/basics)。

序言
--------

每個指南應該以頂部的動機性文本開始（即藍色區域中的小介紹）。序言應該告訴讀者指南的內容以及他們將學到什麼。例如，請參見[路由指南](routing.html)。

標題
------

每個指南的標題使用`h1`標題；指南的各個部分使用`h2`標題；子部分使用`h3`標題；等等。請注意，生成的HTML輸出將使用以`<h2>`開頭的標題標籤。

```markdown
指南標題
===========

部分
-------

### 子部分
```

在書寫標題時，除了介詞、連詞、內部冠詞和動詞“to be”的形式外，所有單詞都應該大寫：

```markdown
#### 斷言和測試組件內的作業
#### 中間件堆疊是一個數組
#### 什麼時候對象被保存？
```

使用與常規文本相同的內嵌格式：

```markdown
##### `:content_type`選項
```

鏈接到API
------------------

指向API（`api.rubyonrails.org`）的鏈接將按照指南生成器的方式進行處理：

包含發行標籤的鏈接保持不變。例如

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

不會被修改。

請在發行說明中使用這些鏈接，因為它們應該指向相應的版本，無論生成的目標是什麼。

如果鏈接不包含發行標籤且正在生成邊緣指南，則將域名替換為`edgeapi.rubyonrails.org`。例如，

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

變成

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

如果鏈接不包含發行標籤且正在生成發行指南，則注入Rails版本。例如，如果我們正在為v5.1.0生成指南，則鏈接

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

變成

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

請不要手動鏈接到`edgeapi.rubyonrails.org`。

API文檔指南
----------------------------

指南和API應該在適當的情況下保持一致。特別是，[API文檔指南](api_documentation_guidelines.html)的以下部分也適用於指南：

* [用詞](api_documentation_guidelines.html#wording)
* [英語](api_documentation_guidelines.html#english)
* [示例代碼](api_documentation_guidelines.html#example-code)
* [文件名](api_documentation_guidelines.html#file-names)
* [字體](api_documentation_guidelines.html#fonts)

HTML指南
-----------

在生成指南之前，請確保您的系統上安裝了最新版本的Bundler。要安裝最新版本的Bundler，運行`gem install bundler`。

如果已經安裝了Bundler，可以使用`gem update bundler`進行更新。

### 生成

要生成所有指南，只需進入`guides`目錄，運行`bundle install`，然後執行：

```bash
$ bundle exec rake guides:generate
```

或者

```bash
$ bundle exec rake guides:generate:html
```

生成的HTML文件可以在`./output`目錄中找到。

要僅處理`my_guide.md`而不處理其他文件，請使用`ONLY`環境變量：

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

默認情況下，未修改的指南不會被處理，因此在實踐中很少需要使用`ONLY`。

要強制處理所有指南，請傳遞`ALL=1`。

如果要生成非英語的指南，可以將它們保存在`source`目錄下的單獨目錄中（例如`source/es`），並使用`GUIDES_LANGUAGE`環境變量：

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

如果要查看可以用於配置生成腳本的所有環境變量，只需運行：

```bash
$ rake
```

### 驗證

請使用以下命令驗證生成的HTML：

```bash
$ bundle exec rake guides:validate
```

特別是，標題會根據其內容生成ID，這通常會導致重複。

Kindle指南
-------------

### 生成

要生成Kindle的指南，請使用以下rake任務：

```bash
$ bundle exec rake guides:generate:kindle
```
