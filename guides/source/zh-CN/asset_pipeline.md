**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
资产管道
==================

本指南介绍了资产管道。

阅读本指南后，您将了解以下内容：

* 资产管道是什么以及它的作用。
* 如何正确组织应用程序资产。
* 资产管道的好处。
* 如何向管道添加预处理器。
* 如何使用 gem 打包资产。

--------------------------------------------------------------------------------

什么是资产管道？
---------------------------

资产管道提供了一个处理 JavaScript 和 CSS 资产交付的框架。这是通过利用诸如 HTTP/2 和合并和压缩等技术来实现的。最后，它允许您的应用程序自动与其他 gem 的资产组合在一起。

资产管道由 [importmap-rails](https://github.com/rails/importmap-rails)、[sprockets](https://github.com/rails/sprockets) 和 [sprockets-rails](https://github.com/rails/sprockets-rails) gem 实现，并默认启用。您可以在创建新应用程序时禁用它，通过传递 `--skip-asset-pipeline` 选项。

```bash
$ rails new appname --skip-asset-pipeline
```

注意：本指南专注于使用 `sprockets` 处理 CSS 和 `importmap-rails` 处理 JavaScript 的默认资产管道。这两者的主要限制是不支持转译，因此无法使用诸如 `Babel`、`Typescript`、`Sass`、`React JSX 格式` 或 `TailwindCSS` 等内容。如果您需要对 JavaScript/CSS 进行转译，请阅读 [替代库部分](#alternative-libraries)。

## 主要特性

资产管道的第一个特性是在每个文件名中插入 SHA256 指纹，以便文件被 Web 浏览器和 CDN 缓存。当您更改文件内容时，此指纹会自动更新，从而使缓存失效。

资产管道的第二个特性是在提供 JavaScript 文件时使用 [import maps](https://github.com/WICG/import-maps)。这使您可以构建使用 ES 模块（ESM）制作的现代应用程序，而无需进行转译和捆绑。反过来，**这消除了对 Webpack、yarn、node 或任何其他 JavaScript 工具链的需求**。

资产管道的第三个特性是将所有 CSS 文件合并为一个主要的 `.css` 文件，然后进行压缩。正如您将在本指南后面了解到的那样，您可以自定义此策略以任何您喜欢的方式分组文件。在生产环境中，Rails 会在每个文件名中插入 SHA256 指纹，以便文件被 Web 浏览器缓存。您可以通过更改此指纹来使缓存失效，这在您更改文件内容时会自动发生。

资产管道的第四个特性是它允许使用更高级的语言编写 CSS 资产。

### 什么是指纹和为什么我应该关注？

指纹是一种技术，使文件的名称依赖于文件的内容。当文件内容发生变化时，文件名也会发生变化。对于静态或不经常更改的内容，这提供了一种简单的方法来判断两个版本的文件是否相同，即使在不同的服务器或部署日期之间也是如此。

当文件名是唯一的并且基于其内容时，可以设置 HTTP 标头以鼓励各处的缓存（无论是在 CDN、ISP、网络设备还是 Web 浏览器中）保留其自己的内容副本。当内容更新时，指纹将发生变化。这将导致远程客户端请求内容的新副本。这通常被称为 _缓存破坏_。

Sprockets 用于指纹的技术是将内容的哈希插入到名称中，通常是在末尾。例如，一个 CSS 文件 `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

这是 Rails 资产管道采用的策略。

指纹默认在开发和生产环境中启用。您可以通过配置中的 [`config.assets.digest`][] 选项来启用或禁用它。

### 什么是 Import Maps 以及为什么我应该关注？

Import Maps 允许您使用逻辑名称导入 JavaScript 模块，这些名称与版本化/摘要文件直接映射。因此，您可以使用为 ES 模块（ESM）制作的 JavaScript 库构建现代 JavaScript 应用程序，而无需进行转译或捆绑。

通过这种方法，您将发送许多小的 JavaScript 文件，而不是一个大的 JavaScript 文件。由于 HTTP/2 在初始传输期间不再带来实质性的性能损失，并且实际上由于更好的缓存动态而在长期运行中提供了实质性的好处。
如何将Import Maps用作JavaScript资源管道
-----------------------------

Import Maps是默认的JavaScript处理器，生成import maps的逻辑由[`importmap-rails`](https://github.com/rails/importmap-rails) gem处理。

警告：Import Maps仅用于JavaScript文件，无法用于CSS交付。请查看[Sprockets部分](#how-to-use-sprockets)以了解CSS的使用方法。

您可以在Gem主页上找到详细的使用说明，但了解`importmap-rails`的基本原理很重要。

### 工作原理

Import Maps本质上是对所谓的“裸模块规范符号”进行字符串替换。它们允许您标准化JavaScript模块导入的名称。

例如，如果没有import map，以下导入定义将无法工作：

```javascript
import React from "react"
```

要使其工作，您必须像这样定义它：

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

这就是import map的作用，我们将`react`名称定义为固定到`https://ga.jspm.io/npm:react@17.0.2/index.js`地址。有了这样的信息，我们的浏览器接受简化的`import React from "react"`定义。将import map视为库源地址的别名。

### 使用方法

使用`importmap-rails`创建importmap配置文件，将库路径固定到名称上：

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

所有配置的import map都应通过添加`<%= javascript_importmap_tags %>`将其附加到应用程序的`<head>`元素中。`javascript_importmap_tags`在`head`元素中渲染一堆脚本：

- 包含所有配置的import map的JSON：

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims)作为polyfill，在旧版浏览器上确保对`import maps`的支持：

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- 从`app/javascript/application.js`加载JavaScript的入口点：

```html
<script type="module">import "application"</script>
```

### 通过JavaScript CDNs使用npm包

您可以使用作为`importmap-rails`安装的一部分添加的`./bin/importmap`命令，在import map中固定、取消固定或更新npm包。该binstub使用[`JSPM.org`](https://jspm.org/)。

它的工作原理如下：

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

如您所见，两个包react和react-dom通过jspm默认解析为四个依赖项。

现在，您可以像使用其他模块一样在`application.js`入口点中使用它们：

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

您还可以指定要固定的特定版本：

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

甚至可以删除固定：

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

您可以控制包的环境，对于具有单独的“生产”（默认）和“开发”构建的包：

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

在固定时，您还可以选择另一个受支持的CDN提供程序，例如[`unpkg`](https://unpkg.com/)或[`jsdelivr`](https://www.jsdelivr.com/)（默认为[`jspm`](https://jspm.org/)）：

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

请记住，如果您将固定从一个提供程序切换到另一个提供程序，您可能需要清理第一个提供程序添加的第二个提供程序不使用的依赖项。

运行`./bin/importmap`以查看所有选项。

请注意，此命令只是将逻辑包名称解析为CDN URL的便利包装器。您也可以自己查找CDN URL，然后固定它们。例如，如果您想要使用Skypack来使用React，您可以将以下内容添加到`config/importmap.rb`中：

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### 预加载固定模块

为了避免浏览器在可以到达最深层嵌套导入之前必须加载一个文件接着加载另一个文件的瀑布效应，importmap-rails支持[modulepreload链接](https://developers.google.com/web/updates/2017/12/modulepreload)。可以通过在pin后面添加`preload: true`来预加载固定模块。

最好预加载在整个应用程序中使用的库或框架，因为这将告诉浏览器尽早下载它们。

示例：

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# 在设置importmap之前，将包含以下链接：
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
注意：有关最新文档，请参考[`importmap-rails`](https://github.com/rails/importmap-rails)存储库。

如何使用Sprockets
-----------------------------

将应用程序资源公开到Web的一种简单方法是将它们存储在`public`文件夹的子目录中，例如`images`和`stylesheets`。手动这样做可能很困难，因为大多数现代Web应用程序需要以特定方式处理资源，例如压缩和添加指纹。

Sprockets旨在自动预处理配置目录中存储的资源，并在处理后将它们公开在`public/assets`文件夹中，包括指纹、压缩、源映射生成和其他可配置功能。

资源仍然可以放置在`public`层次结构中。当[`config.public_file_server.enabled`][]设置为true时，`public`下的任何资源都将由应用程序或Web服务器作为静态文件提供。您必须为需要在提供之前进行某些预处理的文件定义`manifest.js`指令。

在生产环境中，默认情况下，Rails会将这些文件预编译到`public/assets`中。然后，Web服务器将这些预编译副本作为静态资源提供。在生产环境中，`app/assets`中的文件永远不会直接提供。

### Manifest文件和指令

在使用Sprockets编译资源时，Sprockets需要决定要编译的顶级目标，通常是`application.css`和图片。顶级目标在Sprockets的`manifest.js`文件中定义，默认情况下如下所示：

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

它包含_指令_ - 指示Sprockets构建单个CSS或JavaScript文件所需的文件。

这意味着它将包含在`./app/assets/images`目录或任何子目录中找到的所有文件的内容，以及在`./app/javascript`或`./vendor/javascript`中直接识别为JS的任何文件。

它将加载`./app/assets/stylesheets`目录中的任何CSS（不包括子目录）。假设您在`./app/assets/stylesheets`文件夹中有`application.css`和`marketing.css`文件，它将允许您使用`<%= stylesheet_link_tag "application" %>`或`<%= stylesheet_link_tag "marketing" %>`从视图中加载这些样式表。

您可能会注意到，默认情况下我们的JavaScript文件不是从`assets`目录加载的，这是因为`./app/javascript`是`importmap-rails` gem的默认入口点，而`vendor`文件夹是下载的JS包存储的位置。

在`manifest.js`中，您还可以使用`link`指令来加载特定文件而不是整个目录。`link`指令需要提供明确的文件扩展名。

Sprockets加载指定的文件，如果需要，对其进行处理，将它们合并为一个单独的文件，然后压缩它们（基于`config.assets.css_compressor`或`config.assets.js_compressor`的值）。压缩可以减小文件大小，使浏览器能够更快地下载文件。

### 控制器特定的资源

当您生成一个脚手架或控制器时，Rails还会为该控制器生成一个级联样式表文件。此外，当生成一个脚手架时，Rails会生成`scaffolds.css`文件。

例如，如果您生成一个`ProjectsController`，Rails还会在`app/assets/stylesheets/projects.css`中添加一个新文件。默认情况下，这些文件将立即可以通过`manifest.js`文件中的`link_directory`指令在应用程序中使用。

您还可以选择仅在各自的控制器中包含特定于控制器的样式表文件，使用以下方式：

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

在执行此操作时，请确保您的`application.css`中没有使用`require_tree`指令，因为这可能导致您的控制器特定资源被包含多次。

### 资源组织

Pipeline资源可以放置在应用程序的三个位置之一：`app/assets`、`lib/assets`或`vendor/assets`。

* `app/assets`用于应用程序拥有的资源，例如自定义图像或样式表。

* `app/javascript`用于您的JavaScript代码

* `vendor/[assets|javascript]`用于由外部实体拥有的资源，例如CSS框架或JavaScript库。请记住，具有对其他文件的引用的第三方代码也会被资源Pipeline处理（图像、样式表等），因此需要重写以使用`asset_path`等辅助函数。

其他位置可以在`manifest.js`文件中进行配置，请参考[Manifest文件和指令](#manifest-files-and-directives)。

#### 搜索路径

当从manifest或helper引用文件时，Sprockets会在`manifest.js`中指定的所有位置中搜索它。您可以通过在Rails控制台中检查[`Rails.application.config.assets.paths`](configuring.html#config-assets-paths)来查看搜索路径。
#### 使用索引文件作为文件夹的代理

Sprockets使用以`index`命名的文件（带有相关扩展名）来实现特殊功能。

例如，如果你有一个包含许多模块的CSS库，存储在`lib/assets/stylesheets/library_name`中，那么文件`lib/assets/stylesheets/library_name/index.css`将作为该库中所有文件的清单。该文件可以包含按顺序列出的所有所需文件，或者一个简单的`require_tree`指令。

这与`public/library_name/index.html`中的文件可以通过请求`/library_name`来访问的方式有些相似。这意味着你不能直接使用索引文件。

在`.css`文件中，可以像这样访问整个库：

```css
/* ...
*= require library_name
*/
```

这样做简化了维护工作，并通过允许将相关代码分组在其他地方之前，保持了代码的整洁。

### 编码链接到资源

Sprockets不会添加任何新的方法来访问你的资源 - 你仍然使用熟悉的`stylesheet_link_tag`：

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

如果使用默认包含在Rails中的[`turbo-rails`](https://github.com/hotwired/turbo-rails) gem，那么可以包含`data-turbo-track`选项，这会导致Turbo检查资源是否已更新，如果是，则将其加载到页面中：

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

在常规视图中，可以像这样访问`app/assets/images`目录中的图像：

```erb
<%= image_tag "rails.png" %>
```

只要在你的应用程序中启用了pipeline（并且在当前环境上下文中没有禁用），这个文件就会由Sprockets提供。如果在`public/assets/rails.png`存在一个文件，它将由Web服务器提供。

或者，对于具有SHA256哈希的文件的请求，例如`public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`，处理方式是相同的。如何生成这些哈希在本指南的[在生产中](#in-production)部分中有介绍。

如果需要，图像也可以组织到子目录中，然后可以通过在标签中指定目录名称来访问：

```erb
<%= image_tag "icons/rails.png" %>
```

警告：如果你正在预编译你的资源（参见下面的[在生产中](#in-production)），链接到不存在的资源将在调用页面中引发异常。这包括链接到空字符串。因此，在使用`image_tag`和其他帮助程序时要小心使用用户提供的数据。

#### CSS和ERB

资产管道会自动评估ERB。这意味着，如果你将`erb`扩展名添加到CSS资源中（例如，`application.css.erb`），那么在CSS规则中可以使用`asset_path`等帮助程序：

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

这将写入对特定资源的路径。在这个例子中，有一个图像在其中一个资源加载路径中，比如`app/assets/images/image.png`，它将在这里被引用。如果这个图像已经作为指纹文件存在于`public/assets`中，那么将引用该路径。

如果你想使用[data URI](https://en.wikipedia.org/wiki/Data_URI_scheme) - 一种将图像数据直接嵌入到CSS文件中的方法 - 你可以使用`asset_data_uri`帮助程序。

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

这将在CSS源代码中插入一个格式正确的data URI。

请注意，关闭标签不能是`-%>`样式。

### 当找不到资源时引发错误

如果你使用的是sprockets-rails >= 3.2.0，你可以配置在执行资源查找并且找不到资源时发生的情况。如果关闭了"asset fallback"，那么在找不到资源时将引发错误。

```ruby
config.assets.unknown_asset_fallback = false
```

如果启用了"asset fallback"，那么当找不到资源时，路径将被输出，而不会引发错误。默认情况下，禁用了资源回退行为。

### 关闭摘要

你可以通过更新`config/environments/development.rb`来关闭摘要：

```ruby
config.assets.digest = false
```

当这个选项为true时，将为资源URL生成摘要。

### 打开源映射

你可以通过更新`config/environments/development.rb`来打开源映射：

```ruby
config.assets.debug = true
```

当调试模式打开时，Sprockets将为每个资源生成一个源映射。这允许你在浏览器的开发者工具中单独调试每个文件。

资源在服务器启动后的第一个请求上被编译和缓存。Sprockets设置了一个`must-revalidate`的Cache-Control HTTP头，以减少后续请求的请求开销 - 在这些请求中，浏览器会收到一个304（未修改）的响应。
如果清单中的任何文件在请求之间发生更改，服务器将响应一个新的编译文件。

在生产环境中
-------------

在生产环境中，Sprockets使用上述指纹方案。默认情况下，Rails假设资产已经被预编译，并将由您的Web服务器作为静态资产提供。

在预编译阶段，从编译文件的内容生成SHA256，并将其插入到写入磁盘的文件名中。这些带有指纹的名称由Rails助手在清单名称的位置使用。

例如：

```erb
<%= stylesheet_link_tag "application" %>
```

生成类似于：

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

指纹行为由[`config.assets.digest`]初始化选项控制（默认为`true`）。

注意：在正常情况下，不应更改默认的`config.assets.digest`选项。如果文件名中没有摘要，并且设置了远期标头，则远程客户端在其内容更改时将永远不会知道重新获取文件的情况。

### 预编译资产

Rails捆绑了一个命令来编译资产清单和管道中的其他文件。

编译后的资产被写入[`config.assets.prefix`]指定的位置。默认情况下，这是`/assets`目录。

您可以在部署期间在服务器上调用此命令，直接在服务器上创建编译后的资产版本。有关本地编译的信息，请参阅下一节。

命令是：

```bash
$ RAILS_ENV=production rails assets:precompile
```

这将链接到`config.assets.prefix`指定的文件夹`shared/assets`。如果您已经使用此共享文件夹，则需要编写自己的部署命令。

重要的是，此文件夹在部署之间共享，以便引用旧编译资产的远程缓存页面在缓存页面的生命周期内仍然有效。

注意。始终指定以`.js`或`.css`结尾的预期编译文件名。

该命令还会生成一个`.sprockets-manifest-randomhex.json`（其中`randomhex`是一个16字节的随机十六进制字符串），其中包含所有资产及其各自指纹的列表。Rails助手方法使用此文件来避免将映射请求返回给Sprockets。典型的清单文件如下所示：

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

在您的应用程序中，清单中将列出更多的文件和资产，还将生成`<fingerprint>`和`<random-string>`。

清单的默认位置是`config.assets.prefix`指定的位置的根目录（默认为'/assets'）。

注意：如果在生产中缺少预编译文件，则会收到`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`异常，指示缺少文件的名称。

#### 远期过期标头

预编译的资产存在于文件系统上，并由您的Web服务器直接提供。它们默认没有远期标头，因此要获得指纹的好处，您需要更新服务器配置以添加这些标头。

对于Apache：

```apache
# Expires*指令需要启用Apache模块`mod_expires`。
<Location /assets/>
  # 当存在Last-Modified时，不鼓励使用ETag
  Header unset ETag
  FileETag None
  # RFC规定只缓存1年
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

对于NGINX：

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### 本地预编译

有时，您可能不希望或无法在生产服务器上编译资产。例如，您可能对生产文件系统的写入访问权限有限，或者您可能计划频繁部署而不对资产进行任何更改。

在这种情况下，您可以在推送到生产之前向源代码存储库添加一个已完成的、编译后的、适用于生产的资产集，而无需在每次部署时在生产服务器上单独预编译它们。这样，它们就不需要在每次部署时在生产服务器上单独预编译。

与上述相同，您可以使用以下命令执行此步骤：

```bash
$ RAILS_ENV=production rails assets:precompile
```

请注意以下注意事项：

* 如果可用的预编译资产，它们将被提供 - 即使它们不再与原始（未编译）资产匹配，_即使在开发服务器上也是如此_。

    为了确保开发服务器始终即时编译资产（从而始终反映代码的最新状态），开发环境必须配置为将预编译资产保存在与生产环境不同的位置。否则，用于生产的任何预编译资产都将覆盖开发中对它们的请求（即，您对资产所做的后续更改将不会在浏览器中反映出来）。
您可以通过将以下行添加到`config/environments/development.rb`来实现：

```ruby
config.assets.prefix = "/dev-assets"
```

* 在部署工具（例如Capistrano）中应禁用资产预编译任务。
* 开发系统上必须可用任何必要的压缩器或缩小器。

您还可以设置`ENV["SECRET_KEY_BASE_DUMMY"]`以触发使用存储在临时文件中的随机生成的`secret_key_base`。这在预编译生产资产作为不需要访问生产密钥的构建步骤的一部分时非常有用。

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### 实时编译

在某些情况下，您可能希望使用实时编译。在此模式下，管道中的所有资产请求都由Sprockets直接处理。

要启用此选项，请设置：

```ruby
config.assets.compile = true
```

在第一次请求时，资产将按照[资产缓存存储](#assets-cache-store)中概述的方式进行编译和缓存，并且助手中使用的清单名称将被修改以包含SHA256哈希。

Sprockets还将`Cache-Control` HTTP头设置为`max-age=31536000`。这向您的服务器和客户端浏览器之间的所有缓存发出信号，表明此内容（提供的文件）可以缓存1年。这样做的效果是减少来自服务器的此资产的请求数量；该资产很有可能在本地浏览器缓存或某个中间缓存中。

此模式使用更多内存，性能较差，不推荐使用。

### CDN

CDN代表[内容分发网络](https://en.wikipedia.org/wiki/Content_delivery_network)，它们主要用于在全球范围内缓存资产，以便当浏览器请求资产时，将会有一个缓存副本地理上接近该浏览器。如果您在生产中直接从Rails服务器提供资产，则最佳做法是在应用程序前面使用CDN。

使用CDN的常见模式是将生产应用程序设置为“源”服务器。这意味着当浏览器从CDN请求资产并且缓存未命中时，它将即时从您的服务器获取文件并进行缓存。例如，如果您在`example.com`上运行Rails应用程序，并且在`mycdnsubdomain.fictional-cdn.com`上配置了CDN，则当请求`mycdnsubdomain.fictional-cdn.com/assets/smile.png`时，CDN将在`example.com/assets/smile.png`上查询您的服务器一次并缓存请求。对于相同URL的下一个发送到CDN的请求将命中缓存副本。当CDN可以直接提供资产时，请求永远不会触及您的Rails服务器。由于CDN的资产地理位置更接近浏览器，因此请求速度更快，并且由于您的服务器不需要花费时间提供资产，因此可以专注于尽快提供应用程序代码。

#### 设置CDN以提供静态资产

要设置CDN，您必须在公共可用的URL上在互联网上运行应用程序，例如`example.com`。接下来，您需要从云托管提供商那里注册CDN服务。在这样做时，您需要将CDN的“源”配置为指向您的网站`example.com`。请查看提供商的文档以了解如何配置源服务器。

您配置的CDN应该为您的应用程序提供一个自定义子域，例如`mycdnsubdomain.fictional-cdn.com`（请注意，fictional-cdn.com在撰写本文时不是有效的CDN提供商）。现在，您已经配置了CDN服务器，您需要告诉浏览器使用CDN来获取资产，而不是直接从您的Rails服务器获取。您可以通过在Rails中配置您的资产主机来实现这一点，而不是使用相对路径。要在Rails中设置资产主机，您需要在`config/environments/production.rb`中设置[`config.asset_host`][]：

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

注意：您只需要提供“主机”，即子域和根域，无需指定协议或“方案”，例如`http://`或`https://`。当请求网页时，生成的链接中的协议将与默认情况下访问网页的方式匹配。

您还可以通过[环境变量](https://en.wikipedia.org/wiki/Environment_variable)设置此值，以便更轻松地运行站点的暂存副本：
```ruby
config.asset_host = ENV['CDN_HOST']
```

注意：您需要在服务器上将`CDN_HOST`设置为`mycdnsubdomain.fictional-cdn.com`才能使其正常工作。

一旦您配置了服务器和CDN，像下面这样的辅助函数中的资源路径：

```erb
<%= asset_path('smile.png') %>
```

将被渲染为完整的CDN URL，例如`http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`（为了可读性省略了摘要）。

如果CDN有`smile.png`的副本，它将将其提供给浏览器，您的服务器甚至不知道它被请求过。如果CDN没有副本，它将尝试在“源”`example.com/assets/smile.png`中找到它，然后将其存储以供将来使用。

如果您只想从CDN中提供某些资源，请使用自定义的`:host`选项来设置您的资源辅助函数，它会覆盖[`config.action_controller.asset_host`][]中设置的值。

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### 自定义CDN缓存行为

CDN通过缓存内容来工作。如果CDN有过时或错误的内容，那么它对您的应用程序没有帮助，反而会有害。本节的目的是描述大多数CDN的一般缓存行为。您的特定提供商可能会有稍微不同的行为。

##### CDN请求缓存

尽管CDN被描述为对缓存资源有好处，但它实际上缓存了整个请求。这包括资源的正文以及任何头信息。其中最重要的是`Cache-Control`，它告诉CDN（和Web浏览器）如何缓存内容。这意味着如果有人请求一个不存在的资源，比如`/assets/i-dont-exist.png`，而您的Rails应用程序返回一个404错误页面，如果存在有效的`Cache-Control`头信息，您的CDN很可能会缓存这个404页面。

##### CDN头部调试

检查CDN中的头部是否正确缓存的一种方法是使用[curl](https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com)。您可以请求您的服务器和CDN的头部来验证它们是否相同：

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

与CDN副本相比：

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

请查阅您的CDN文档，了解他们可能提供的任何其他信息，例如`X-Cache`，或者他们可能添加的任何其他头部。

##### CDN和Cache-Control头部

[`Cache-Control`][]头部描述了请求的缓存方式。当没有使用CDN时，浏览器将使用此信息来缓存内容。这对于不需要修改的资源非常有帮助，这样浏览器就不需要在每个请求上重新下载网站的CSS或JavaScript。通常，我们希望我们的Rails服务器告诉CDN（和浏览器）该资源是“public”。这意味着任何缓存都可以存储该请求。我们通常还希望设置`max-age`，这是缓存在无效之前存储对象的时间。`max-age`的值以秒为单位，最大可能值为`31536000`，即一年。您可以通过设置以下内容在Rails应用程序中实现：

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

现在，当您的应用程序在生产环境中提供资源时，CDN将为该资源存储长达一年的时间。由于大多数CDN还会缓存请求的头部，这个`Cache-Control`将传递给所有未来寻找此资源的浏览器。然后，浏览器知道在需要重新请求之前，它可以将此资源存储很长时间。

##### CDN和基于URL的缓存失效

大多数CDN将根据完整的URL缓存资源的内容。这意味着对于以下请求：

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

与以下请求完全不同的缓存：

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

如果您想在`Cache-Control`中设置远期`max-age`（您确实想要这样做），请确保在更改资源时使缓存失效。例如，当将图像中的笑脸从黄色更改为蓝色时，您希望站点的所有访问者都能获得新的蓝色笑脸。当使用Rails资源管道和默认情况下将`config.assets.digest`设置为true时，每个资源在更改时都会有一个不同的文件名。这样，您就不必手动使缓存中的任何项失效。通过使用不同的唯一资源名称，您的用户可以获取最新的资源。
自定义流水线
------------------------

### CSS压缩

压缩CSS的选项之一是YUI。[YUI CSS压缩器](https://yui.github.io/yuicompressor/css.html)提供了代码压缩功能。

以下代码启用YUI压缩，并需要安装`yui-compressor` gem。

```ruby
config.assets.css_compressor = :yui
```

### JavaScript压缩

JavaScript压缩的可能选项有`:terser`、`:closure`和`:yui`。分别需要使用`terser`、`closure-compiler`或`yui-compressor` gem。

以`terser` gem为例。该gem在Ruby中封装了[Terser](https://github.com/terser/terser)（用于Node.js）。它通过删除空格和注释、缩短局部变量名以及执行其他微小优化（例如将`if`和`else`语句更改为三元运算符）来压缩代码。

以下代码调用`terser`进行JavaScript压缩。

```ruby
config.assets.js_compressor = :terser
```

注意：使用`terser`需要安装[ExecJS](https://github.com/rails/execjs#readme)支持的运行时。如果您使用的是macOS或Windows，操作系统中已安装了JavaScript运行时。

注意：当通过`importmap-rails`或`jsbundling-rails` gems加载资源时，JavaScript压缩也适用于JavaScript文件。

### 压缩资产为GZip格式

默认情况下，编译的资产将生成GZip格式和非GZip格式的版本。GZip格式的资产有助于减少数据在网络传输中的大小。您可以通过设置`gzip`标志来配置此功能。

```ruby
config.assets.gzip = false # 禁用GZip格式的资产生成
```

请参考您的Web服务器文档以了解如何提供GZip格式的资产。

### 使用自定义压缩器

CSS和JavaScript的压缩器配置设置也可以接受任何对象。该对象必须具有一个接受字符串作为唯一参数的`compress`方法，并且必须返回一个字符串。

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

要启用此功能，请在`application.rb`中的配置选项中传递一个新对象：

```ruby
config.assets.css_compressor = Transformer.new
```

### 更改_assets_路径

Sprockets默认使用的公共路径是`/assets`。

您可以将其更改为其他内容：

```ruby
config.assets.prefix = "/some_other_path"
```

如果您正在更新一个旧项目，该项目没有使用资产流水线并且已经使用此路径，或者您希望为新资源使用此路径，这是一个方便的选项。

### X-Sendfile头

X-Sendfile头是一种指示Web服务器忽略应用程序的响应，而是从磁盘上提供指定文件的指令。默认情况下，此选项处于关闭状态，但如果您的服务器支持该选项，则可以启用它。启用后，将文件的提供责任传递给Web服务器，这样可以提高速度。请参考[send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)以了解如何使用此功能。

Apache和NGINX支持此选项，可以在`config/environments/production.rb`中启用：

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # 适用于Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # 适用于NGINX
```

警告：如果您正在升级现有应用程序并打算使用此选项，请注意仅将此配置选项粘贴到`production.rb`和任何其他定义具有生产行为的环境（而不是`application.rb`）中。

提示：有关更多详细信息，请查看生产Web服务器的文档：

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

资产缓存存储
------------------

默认情况下，Sprockets在开发和生产环境中将资产缓存到`tmp/cache/assets`中。可以按如下方式更改：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

要禁用资产缓存存储：

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

将资产添加到您的Gems中
--------------------------

资产也可以来自于Gems的外部来源。

一个很好的例子是`jquery-rails` gem。该gem包含一个继承自`Rails::Engine`的引擎类。通过这样做，Rails被告知该gem的目录可能包含资产，并且该引擎的`app/assets`、`lib/assets`和`vendor/assets`目录将添加到Sprockets的搜索路径中。

使您的库或Gem成为预处理器
------------------------------------------

Sprockets使用处理器、转换器、压缩器和导出器来扩展其功能。请查看[扩展Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)以了解更多信息。在这里，我们注册了一个预处理器，向text/css（`.css`）文件的末尾添加了一个注释。

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

现在，您有了一个修改输入数据的模块，是时候将其注册为您的MIME类型的预处理器了。
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```

替代库
------------------------------------------

多年来，处理资产的默认方法有多种。随着Web的发展，我们开始看到越来越多的JavaScript重型应用程序。在Rails Doctrine中，我们相信[菜单是大厨](https://rubyonrails.org/doctrine#omakase)，所以我们专注于默认设置：**使用Sprockets和Import Maps**。

我们知道，对于各种JavaScript和CSS框架/扩展，没有一种大小适合所有的解决方案。在Rails生态系统中，还有其他捆绑库，可以在默认设置不足的情况下为您提供支持。

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails)是一个依赖于Node.js的替代方案，用于使用[esbuild](https://esbuild.github.io/)、[rollup.js](https://rollupjs.org/)或[Webpack](https://webpack.js.org/)对JavaScript进行捆绑。

该gem提供了`yarn build --watch`进程，在开发中自动生成输出。对于生产环境，它会自动将`javascript:build`任务挂钩到`assets:precompile`任务中，以确保所有包依赖项都已安装，并为所有入口点构建了JavaScript。

**何时使用`jsbundling-rails`而不是`importmap-rails`？** 如果您的JavaScript代码依赖于转译，即如果您使用[Babel](https://babeljs.io/)、[TypeScript](https://www.typescriptlang.org/)或React的`JSX`格式，则应使用`jsbundling-rails`。

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html)是Rails 5和6的默认JavaScript预处理器和捆绑器。现在已经被弃用。有一个名为[`shakapacker`](https://github.com/shakacode/shakapacker)的继任者存在，但不由Rails团队或项目维护。

与此列表中的其他库不同，`webpacker`/`shakapacker`完全独立于Sprockets，可以处理JavaScript和CSS文件。阅读[Webpacker指南](https://guides.rubyonrails.org/webpacker.html)以了解更多信息。

注意：阅读[与Webpacker的比较](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md)文档，了解`jsbundling-rails`与`webpacker`/`shakapacker`之间的区别。

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails)允许使用[Tailwind CSS](https://tailwindcss.com/)、[Bootstrap](https://getbootstrap.com/)、[Bulma](https://bulma.io/)、[PostCSS](https://postcss.org/)或[Dart Sass](https://sass-lang.com/)对CSS进行捆绑和处理，然后通过资产管道传递CSS。

它的工作方式与`jsbundling-rails`类似，因此在开发中添加了Node.js依赖项，使用`yarn build:css --watch`进程在开发中重新生成样式表，并在生产中挂钩到`assets:precompile`任务中。

**与Sprockets的区别是什么？** Sprockets本身无法将Sass转译为CSS，需要使用Node.js从`.sass`文件生成`.css`文件。一旦生成了`.css`文件，`Sprockets`就能够将它们传递给客户端。

注意：`cssbundling-rails`依赖于Node来处理CSS。`dartsass-rails`和`tailwindcss-rails` gem使用独立版本的Tailwind CSS和Dart Sass，意味着没有Node依赖性。如果您使用`importmap-rails`处理JavaScript和`dartsass-rails`或`tailwindcss-rails`处理CSS，您可以完全避免Node依赖性，从而得到一个更简单的解决方案。

### dartsass-rails

如果您想在应用程序中使用[`Sass`](https://sass-lang.com/)，则[`dartsass-rails`](https://github.com/rails/dartsass-rails)是对传统的`sassc-rails` gem的替代品。`dartsass-rails`使用了2020年弃用的[`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated)的`Dart Sass`实现。

与`sassc-rails`不同，新的gem没有直接集成到`Sprockets`中。有关安装/迁移说明，请参阅[gem主页](https://github.com/rails/dartsass-rails)。

警告：流行的`sassc-rails` gem自2019年以来未维护。

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails)是Tailwind CSS v3框架的[独立可执行版本](https://tailwindcss.com/blog/standalone-cli)的包装gem。在使用`rails new`命令时，如果提供了`--css tailwind`，则用于新应用程序。提供一个`watch`进程，在开发中自动生成Tailwind输出。对于生产环境，它会挂钩到`assets:precompile`任务中。
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
