**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 发布说明
===============================

Rails 4.0 的亮点：

* 优先使用 Ruby 2.0；要求 1.9.3+
* 强参数
* Turbolinks
* 俄罗斯套娃缓存

这些发布说明仅涵盖了主要更改。要了解各种错误修复和更改，请参阅更改日志或查看 GitHub 上 Rails 主存储库中的[提交列表](https://github.com/rails/rails/commits/4-0-stable)。

--------------------------------------------------------------------------------

升级到 Rails 4.0
----------------------

如果您正在升级现有应用程序，在进行升级之前，最好有良好的测试覆盖率。您还应该首先升级到 Rails 3.2（如果尚未升级），并确保您的应用程序在升级到 Rails 4.0 之前仍然按预期运行。在[升级 Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0)指南中提供了升级时需要注意的事项列表。


创建 Rails 4.0 应用程序
--------------------------------

```bash
# 您应该已经安装了 'rails' RubyGem
$ rails new myapp
$ cd myapp
```

### 存储 Gems

Rails 现在使用应用程序根目录中的 `Gemfile` 来确定您的应用程序启动所需的 Gems。这个 `Gemfile` 由 [Bundler](https://github.com/carlhuda/bundler) gem 处理，然后安装所有依赖项。它甚至可以将所有依赖项本地安装到您的应用程序中，以便它不依赖于系统 Gems。

更多信息：[Bundler 主页](https://bundler.io)

### 使用最新版本

`Bundler` 和 `Gemfile` 使得使用新的专用 `bundle` 命令冻结您的 Rails 应用程序变得非常容易。如果您想直接从 Git 存储库进行捆绑，可以传递 `--edge` 标志：

```bash
$ rails new myapp --edge
```

如果您有一个 Rails 存储库的本地检出，并希望使用它生成一个应用程序，可以传递 `--dev` 标志：

```bash
$ ruby /path/to/rails/railties/bin/rails new myapp --dev
```

主要功能
--------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### 升级

* **Ruby 1.9.3** ([提交记录](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - 优先使用 Ruby 2.0；要求 1.9.3+
* **[新的弃用策略](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - 在 Rails 4.0 中，弃用的功能将成为警告，并将在 Rails 4.1 中被移除。
* **ActionPack 页面和动作缓存** ([提交记录](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - 页面和动作缓存被提取到一个单独的 gem 中。页面和动作缓存需要太多手动干预（在底层模型对象更新时手动过期缓存）。相反，请使用俄罗斯套娃缓存。
* **ActiveRecord 观察者** ([提交记录](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - 观察者被提取到一个单独的 gem 中。观察者仅在页面和动作缓存中需要，并且可能导致混乱的代码。
* **ActiveRecord 会话存储** ([提交记录](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - ActiveRecord 会话存储被提取到一个单独的 gem 中。在 SQL 中存储会话是昂贵的。相反，请使用 cookie 会话、内存缓存会话或自定义会话存储。
* **ActiveModel 大规模赋值保护** ([提交记录](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - Rails 3 大规模赋值保护已弃用。相反，请使用强参数。
* **ActiveResource** ([提交记录](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource 被提取到一个单独的 gem 中。ActiveResource 的使用不广泛。
* **移除 vendor/plugins** ([提交记录](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - 使用 `Gemfile` 来管理已安装的 Gems。

### ActionPack

* **强参数** ([提交记录](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - 仅允许更新模型对象的允许参数 (`params.permit(:title, :text)`).
* **路由关注点** ([提交记录](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - 在路由 DSL 中，提取出常见的子路由 (`comments` from `/posts/1/comments` 和 `/videos/1/comments`).
* **ActionController::Live** ([提交记录](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - 使用 `response.stream` 流式传输 JSON。
* **声明性 ETags** ([提交记录](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - 添加控制器级别的 etag 添加，这将成为动作 etag 计算的一部分。
* **[俄罗斯套娃缓存](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([提交记录](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - 缓存视图的嵌套片段。每个片段都会根据一组依赖项（缓存键）过期。缓存键通常是模板版本号和模型对象。
* **Turbolinks** ([提交记录](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - 仅提供一个初始的 HTML 页面。当用户导航到另一个页面时，使用 pushState 更新 URL，并使用 AJAX 更新标题和内容。
* **将 ActionView 与 ActionController 解耦** ([提交记录](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView 已从 ActionPack 解耦，并将在 Rails 4.1 中移动到一个单独的 gem 中。
* **不依赖于 ActiveModel** ([提交记录](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack 不再依赖于 ActiveModel。
### 通用

* **ActiveModel::Model**（[提交](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)）- `ActiveModel::Model`是一个混入模块，使普通的Ruby对象可以与ActionPack无缝配合使用（例如用于`form_for`）。
* **新的作用域API**（[提交](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)）- 作用域必须始终使用可调用对象。
* **模式缓存转储**（[提交](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)）- 为了提高Rails的启动时间，不再直接从数据库加载模式，而是从转储文件加载模式。
* **支持指定事务隔离级别**（[提交](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)）- 选择可重复读取或改进性能（减少锁定）哪个更重要。
* **Dalli**（[提交](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)）- 使用Dalli内存缓存客户端作为内存缓存存储。
* **通知开始和结束**（[提交](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)）- Active Support工具包会向订阅者报告开始和结束通知。
* **默认线程安全**（[提交](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)）- Rails可以在多线程应用服务器中运行，无需额外配置。

注意：请确保您使用的gem是线程安全的。

* **PATCH动词**（[提交](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)）- 在Rails中，PATCH替代了PUT。PATCH用于对资源进行部分更新。

### 安全性

* **匹配不捕获全部**（[提交](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)）- 在路由DSL中，匹配要求指定HTTP动词。
* **默认转义HTML实体**（[提交](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)）- 在erb中呈现的字符串会被转义，除非使用`raw`包装或调用`html_safe`。
* **新的安全头**（[提交](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)）- Rails会在每个HTTP请求中发送以下头部：`X-Frame-Options`（通过禁止浏览器将页面嵌入到框架中来防止点击劫持），`X-XSS-Protection`（要求浏览器停止脚本注入）和`X-Content-Type-Options`（防止浏览器将jpeg文件打开为exe文件）。

功能提取为gems
---------------------------

在Rails 4.0中，一些功能已经被提取为gems。您只需将提取的gems添加到您的`Gemfile`中，即可恢复功能。

* 基于哈希和动态查找方法（[GitHub](https://github.com/rails/activerecord-deprecated_finders)）
* Active Record模型中的批量赋值保护（[GitHub](https://github.com/rails/protected_attributes)，[Pull Request](https://github.com/rails/rails/pull/7251)）
* ActiveRecord::SessionStore（[GitHub](https://github.com/rails/activerecord-session_store)，[Pull Request](https://github.com/rails/rails/pull/7436)）
* Active Record观察者（[GitHub](https://github.com/rails/rails-observers)，[Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2)）
* Active Resource（[GitHub](https://github.com/rails/activeresource)，[Pull Request](https://github.com/rails/rails/pull/572)，[Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource)）
* Action Caching（[GitHub](https://github.com/rails/actionpack-action_caching)，[Pull Request](https://github.com/rails/rails/pull/7833)）
* Page Caching（[GitHub](https://github.com/rails/actionpack-page_caching)，[Pull Request](https://github.com/rails/rails/pull/7833)）
* Sprockets（[GitHub](https://github.com/rails/sprockets-rails)）
* 性能测试（[GitHub](https://github.com/rails/rails-perftest)，[Pull Request](https://github.com/rails/rails/pull/8876)）

文档
-------------

* 指南以GitHub Flavored Markdown格式重写。

* 指南具有响应式设计。

Railties
--------

请参阅[更改日志](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md)以获取详细更改信息。

### 显著更改

* 新的测试位置`test/models`，`test/helpers`，`test/controllers`和`test/mailers`。相应的rake任务也已添加。([Pull Request](https://github.com/rails/rails/pull/7878))

* 您应用程序的可执行文件现在位于`bin/`目录中。运行`rake rails:update:bin`以获取`bin/bundle`，`bin/rails`和`bin/rake`。

* 默认启用线程安全

* 通过传递`--builder`（或`-b`）给`rails new`来使用自定义构建器的能力已被删除。考虑使用应用程序模板代替。([Pull Request](https://github.com/rails/rails/pull/9401))

### 弃用

* `config.threadsafe!`已弃用，建议使用`config.eager_load`，它提供了更精细的控制，可以对什么进行急加载。

* `Rails::Plugin`已经被移除。不要将插件添加到`vendor/plugins`，而是使用带有路径或git依赖项的gems或bundler。

Action Mailer
-------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md)以获取详细更改信息。

### 显著更改

### 弃用

Active Model
------------

请参阅[更改日志](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md)以获取详细更改信息。
### 显著变化

* 添加了`ActiveModel::ForbiddenAttributesProtection`，一个简单的模块，用于在传递非允许属性时保护属性免受批量赋值。

* 添加了`ActiveModel::Model`，一个混入模块，使Ruby对象能够与Action Pack无缝配合使用。

### 弃用

Active Support
--------------

详细更改请参阅[Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md)。

### 显著变化

* 在`ActiveSupport::Cache::MemCacheStore`中用`dalli`替换了已弃用的`memcache-client` gem。

* 优化了`ActiveSupport::Cache::Entry`，以减少内存和处理开销。

* 现在可以根据区域设置定义不同的词形变化。`singularize`和`pluralize`接受额外的区域设置参数。

* 如果接收对象未实现方法，`Object#try`现在将返回nil而不是引发NoMethodError，但您仍然可以通过使用新的`Object#try!`来获得旧的行为。

* 当给定无效日期时，`String#to_date`现在会引发`ArgumentError: invalid date`，而不是`NoMethodError: undefined method 'div' for nil:NilClass`。它现在与`Date.parse`相同，并且接受比3.x更多的无效日期，例如：

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: invalid date
    "333".to_date # => Fri, 29 Nov 2013
    ```

### 弃用

* 弃用`ActiveSupport::TestCase#pending`方法，请改用minitest的`skip`方法。

* 由于缺乏线程安全性，`ActiveSupport::Benchmarkable#silence`已被弃用。它将在Rails 4.1中被删除，没有替代方法。

* 弃用`ActiveSupport::JSON::Variable`。请为自定义JSON字符串文字定义自己的`#as_json`和`#encode_json`方法。

* 弃用兼容性方法`Module#local_constant_names`，请改用`Module#local_constants`（返回符号）。

* 弃用`ActiveSupport::BufferedLogger`。请使用`ActiveSupport::Logger`或Ruby标准库中的日志记录器。

* 弃用`assert_present`和`assert_blank`，改用`assert object.blank?`和`assert object.present?`。

Action Pack
-----------

详细更改请参阅[Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md)。

### 显著变化

* 更改开发模式下异常页面的样式表。此外，在所有异常页面中还显示引发异常的代码行和片段。

### 弃用


Active Record
-------------

详细更改请参阅[Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md)。

### 显著变化

* 改进了编写`change`迁移的方式，不再需要旧的`up`和`down`方法。

    * `drop_table`和`remove_column`方法现在是可逆的，只要提供了必要的信息。`remove_column`方法以前接受多个列名；现在请使用`remove_columns`（不可逆）。`change_table`方法也是可逆的，只要其块不调用`remove`、`change`或`change_default`。

    * 新的`reversible`方法可以指定在迁移上或下运行的代码。请参阅[Migration指南](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * 新的`revert`方法将还原整个迁移或给定的块。如果向下迁移，则正常运行给定的迁移/块。请参阅[Migration指南](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* 添加了对PostgreSQL数组类型的支持。任何数据类型都可以用于创建数组列，并具有完整的迁移和模式转储支持。

* 添加了`Relation#load`，用于显式加载记录并返回`self`。

* `Model.all`现在返回`ActiveRecord::Relation`，而不是记录数组。如果确实需要数组，请使用`Relation#to_a`。在某些特定情况下，这可能会在升级时导致问题。
* 添加了`ActiveRecord::Migration.check_pending!`，如果存在未完成的迁移，则会引发错误。

* 为`ActiveRecord::Store`添加了自定义编码器的支持。现在可以像这样设置自定义编码器：

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* `mysql`和`mysql2`连接默认会设置`SQL_MODE=STRICT_ALL_TABLES`，以避免数据丢失。可以在`database.yml`中指定`strict: false`来禁用此功能。

* 移除了IdentityMap。

* 移除了自动执行EXPLAIN查询的功能。选项`active_record.auto_explain_threshold_in_seconds`不再使用，应该将其删除。

* 添加了`ActiveRecord::NullRelation`和`ActiveRecord::Relation#none`，实现了关系类的空对象模式。

* 添加了`create_join_table`迁移助手，用于创建HABTM连接表。

* 允许创建PostgreSQL hstore记录。

### 弃用

* 弃用了旧式的基于哈希的查找器API。这意味着以前接受“查找选项”的方法不再接受。

* 除了`find_by_...`和`find_by_...!`之外，所有动态方法都已弃用。以下是如何重写代码：

      * `find_all_by_...`可以使用`where(...)`来重写。
      * `find_last_by_...`可以使用`where(...).last`来重写。
      * `scoped_by_...`可以使用`where(...)`来重写。
      * `find_or_initialize_by_...`可以使用`find_or_initialize_by(...)`来重写。
      * `find_or_create_by_...`可以使用`find_or_create_by(...)`来重写。
      * `find_or_create_by_...!`可以使用`find_or_create_by!(...)`来重写。

致谢
-------

请参阅[Rails的完整贡献者列表](https://contributors.rubyonrails.org/)，感谢所有为Rails付出了许多时间的人，使其成为一个稳定而强大的框架。向他们致以崇高的敬意。
