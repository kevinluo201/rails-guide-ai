**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Ruby on Rails指南指南
===============================

本指南记录了编写Ruby on Rails指南的准则。本指南以优雅的循环方式进行，将自身作为示例。

阅读本指南后，您将了解：

* Rails文档中应使用的约定。
* 如何在本地生成指南。

--------------------------------------------------------------------------------

Markdown
-------

指南使用[GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown)编写。有详细的[Markdown文档](https://daringfireball.net/projects/markdown/syntax)，以及[速查表](https://daringfireball.net/projects/markdown/basics)。

序言
--------

每个指南应以顶部的动机性文本开始（即蓝色区域中的简介）。序言应告诉读者指南的内容以及他们将学到什么。例如，参见[路由指南](routing.html)。

标题
------

每个指南的标题使用`h1`标题；指南的章节使用`h2`标题；子章节使用`h3`标题；等等。请注意，生成的HTML输出将使用以`<h2>`开头的标题标签。

```markdown
指南标题
===========

章节
-------

### 子章节
```

在编写标题时，除了介词、连词、内部冠词和动词“to be”的形式外，所有单词都要大写：

```markdown
#### 在组件内部进行断言和测试作业
#### 中间件堆栈是一个数组
#### 对象何时保存？
```

使用与常规文本相同的内联格式：

```markdown
##### `:content_type`选项
```

链接到API
------------------

指向API（`api.rubyonrails.org`）的链接将由指南生成器按以下方式处理：

包含发布标签的链接保持不变。例如

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

不会被修改。

请在发布说明中使用这些链接，因为它们应该指向相应的版本，无论生成的目标是什么。

如果链接不包含发布标签并且正在生成边缘指南，则将域名替换为`edgeapi.rubyonrails.org`。例如，

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

变成

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

如果链接不包含发布标签并且正在生成发布指南，则注入Rails版本。例如，如果我们正在为v5.1.0生成指南，则链接

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

变成

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

请不要手动链接到`edgeapi.rubyonrails.org`。

API文档准则
----------------------------

指南和API应在适当的情况下保持一致。特别是，[API文档准则](api_documentation_guidelines.html)的以下部分也适用于指南：

* [措辞](api_documentation_guidelines.html#wording)
* [英语](api_documentation_guidelines.html#english)
* [示例代码](api_documentation_guidelines.html#example-code)
* [文件名](api_documentation_guidelines.html#file-names)
* [字体](api_documentation_guidelines.html#fonts)

HTML指南
-----------

在生成指南之前，请确保您的系统上安装了最新版本的Bundler。要安装最新版本的Bundler，请运行`gem install bundler`。

如果已经安装了Bundler，可以使用`gem update bundler`进行更新。

### 生成

要生成所有指南，只需进入`guides`目录，运行`bundle install`，然后执行：

```bash
$ bundle exec rake guides:generate
```

或者

```bash
$ bundle exec rake guides:generate:html
```

生成的HTML文件可以在`./output`目录中找到。

要仅处理`my_guide.md`而不处理其他文件，请使用`ONLY`环境变量：

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

默认情况下，未修改的指南不会被处理，因此在实践中很少需要使用`ONLY`。

要强制处理所有指南，请传递`ALL=1`。

如果要生成非英语的指南，请将它们保存在`source`目录下的单独目录中（例如`source/es`），并使用`GUIDES_LANGUAGE`环境变量：

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

如果要查看可以用于配置生成脚本的所有环境变量，请运行：

```bash
$ rake
```

### 验证

请使用以下命令验证生成的HTML：

```bash
$ bundle exec rake guides:validate
```

特别是，标题会根据其内容生成一个ID，这经常导致重复。

Kindle指南
-------------

### 生成

要为Kindle生成指南，请使用以下rake任务：

```bash
$ bundle exec rake guides:generate:kindle
```
