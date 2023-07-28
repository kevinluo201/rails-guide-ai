**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

本指南将向您展示如何安装和使用Webpacker来打包JavaScript、CSS和其他客户端的Rails应用程序的资源，但请注意[Webpacker已经被弃用](https://github.com/rails/webpacker#webpacker-has-been-retired-)。

阅读本指南后，您将了解以下内容：

* Webpacker是什么，以及它与Sprockets的区别。
* 如何安装Webpacker并将其与您选择的框架集成。
* 如何使用Webpacker处理JavaScript资源。
* 如何使用Webpacker处理CSS资源。
* 如何使用Webpacker处理静态资源。
* 如何部署使用Webpacker的网站。
* 如何在其他Rails上下文中使用Webpacker，例如引擎或Docker容器。

--------------------------------------------------------------

什么是Webpacker？
------------------

Webpacker是一个围绕[webpack](https://webpack.js.org)构建系统的Rails包装器，它提供了一个标准的webpack配置和合理的默认值。

### 什么是Webpack？

webpack或任何前端构建系统的目标是允许您以对开发人员方便的方式编写前端代码，然后以对浏览器方便的方式打包该代码。使用webpack，您可以管理JavaScript、CSS和静态资源，如图像或字体。Webpack将允许您编写代码、引用应用程序中的其他代码、转换代码并将代码组合成易于下载的包。

有关详细信息，请参阅[webpack文档](https://webpack.js.org)。

### Webpacker与Sprockets有何不同？

Rails还附带了Sprockets，这是一个与Webpacker功能重叠的资产打包工具。这两个工具都会将您的JavaScript编译为适用于浏览器的文件，并在生产环境中进行缩小和指纹处理。在开发环境中，Sprockets和Webpacker允许您逐步更改文件。

Sprockets是为与Rails一起使用而设计的，它的集成相对简单。特别是，可以通过Ruby gem向Sprockets添加代码。然而，webpack更擅长与更现代的JavaScript工具和NPM包集成，并允许更广泛的集成范围。新的Rails应用程序配置为使用webpack处理JavaScript和Sprockets处理CSS，尽管您也可以使用webpack处理CSS。

如果您想使用NPM包和/或访问最新的JavaScript功能和工具，应选择Webpacker而不是Sprockets来进行新项目开发。如果迁移可能代价高昂、想要使用Gems进行集成或者要打包的代码量非常少，应选择Sprockets而不是Webpacker。

如果您熟悉Sprockets，下面的指南可能会给您一些翻译的思路。请注意，每个工具的结构略有不同，概念之间并不直接对应。

|任务              | Sprockets            | Webpacker         |
|------------------|----------------------|-------------------|
|添加JavaScript    |javascript_include_tag|javascript_pack_tag|
|添加CSS           |stylesheet_link_tag   |stylesheet_pack_tag|
|链接到图像        |image_url             |image_pack_tag     |
|链接到资源        |asset_url             |asset_pack_tag     |
|引用脚本         |//= require           |import或require    |

安装Webpacker
--------------------

要使用Webpacker，您必须安装Yarn软件包管理器，版本为1.x或更高，并且必须安装Node.js，版本为10.13.0及更高。

注意：Webpacker依赖于NPM和Yarn。NPM是主要的节点包管理器注册表，用于发布和下载开源JavaScript项目，既适用于Node.js，也适用于浏览器运行时。它类似于Ruby的rubygems.org。Yarn是一个命令行实用程序，类似于Bundler，用于安装和管理JavaScript依赖项。

要在新项目中包含Webpacker，请将`--webpack`添加到`rails new`命令中。要将Webpacker添加到现有项目中，请将`webpacker` gem添加到项目的`Gemfile`中，运行`bundle install`，然后运行`bin/rails webpacker:install`。

安装Webpacker会创建以下本地文件：

|文件                    |位置                    |说明                                                                                               |
|------------------------|------------------------|--------------------------------------------------------------------------------------------------|
|JavaScript文件夹        | `app/javascript`       |用于存放前端源代码的位置                                                                             |
|Webpacker配置文件       | `config/webpacker.yml` |配置Webpacker gem                                                                                   |
|Babel配置文件           | `babel.config.js`      |[Babel](https://babeljs.io) JavaScript编译器的配置                                                  |
|PostCSS配置文件         | `postcss.config.js`    |[PostCSS](https://postcss.org) CSS后处理器的配置                                                    |
|Browserlist配置文件     | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist)管理目标浏览器的配置                      |


安装还会调用`yarn`软件包管理器，创建一个带有基本包列表的`package.json`文件，并使用Yarn安装这些依赖项。

用法
-----

### 使用Webpacker处理JavaScript

安装了Webpacker后，默认情况下，`app/javascript/packs`目录中的任何JavaScript文件都将被编译为自己的pack文件。
如果你有一个名为`app/javascript/packs/application.js`的文件，Webpacker将创建一个名为`application`的pack，并且你可以使用代码`<%= javascript_pack_tag "application" %>`将其添加到你的Rails应用中。这样一来，在开发环境中，每当`application.js`文件发生变化并且加载使用该pack的页面时，Rails都会重新编译它。通常，实际`packs`目录中的文件将是一个主要加载其他文件的清单，但它也可以包含任意的JavaScript代码。

Webpacker为你创建的默认pack将链接到Rails的默认JavaScript包（如果它们已经包含在项目中）：

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

你需要包含一个需要这些包的pack才能在你的Rails应用中使用它们。

需要注意的是，只有webpack入口文件应该放在`app/javascript/packs`目录中；Webpack将为每个入口点创建一个单独的依赖图，因此大量的pack将增加编译开销。你的其他资产源代码应该放在这个目录之外，尽管Webpacker对如何组织源代码没有任何限制或建议。这是一个示例：

```sh
app/javascript:
  ├── packs:
  │   # 只有webpack入口文件在这里
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

通常，pack文件本身主要是一个清单，使用`import`或`require`来加载必要的文件，也可能进行一些初始化。

如果你想更改这些目录，可以在`config/webpacker.yml`文件中调整`source_path`（默认为`app/javascript`）和`source_entry_path`（默认为`packs`）。

在源文件中，`import`语句是相对于进行导入的文件解析的，所以`import Bar from "./foo"`会在当前文件所在目录中找到一个名为`foo.js`的文件，而`import Bar from "../src/foo"`会在兄弟目录中的一个名为`src`的目录中找到一个文件。

### 使用Webpacker处理CSS

默认情况下，Webpacker支持使用PostCSS处理CSS和SCSS。

要在你的packs中包含CSS代码，首先在顶级pack文件中包含你的CSS文件，就像它是一个JavaScript文件一样。所以如果你的CSS顶级清单在`app/javascript/styles/styles.scss`中，你可以使用`import styles/styles`来导入它。这告诉webpack将你的CSS文件包含在下载中。要在页面中实际加载它，需要在视图中包含`<%= stylesheet_pack_tag "application" %>`，其中的`application`是你使用的pack名称。

如果你使用的是CSS框架，你可以按照使用`yarn`将框架作为NPM模块加载的说明添加到Webpacker中，通常是`yarn add <framework>`。框架应该有关于如何将其导入到CSS或SCSS文件中的说明。

### 使用Webpacker处理静态资源

默认的Webpacker配置应该可以直接处理静态资源。配置包括几个图像和字体文件格式扩展名，允许webpack将它们包含在生成的`manifest.json`文件中。

使用webpack，可以直接在JavaScript文件中导入静态资源。导入的值表示资源的URL。例如：

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "我是一个Webpacker打包的图像";
document.body.appendChild(myImage);
```

如果你需要从Rails视图引用Webpacker静态资源，需要从Webpacker打包的JavaScript文件中显式地引入这些资源。与Sprockets不同，Webpacker不会默认导入你的静态资源。默认的`app/javascript/packs/application.js`文件有一个从给定目录导入文件的模板，你可以取消注释每个你想要在其中有静态文件的目录。这些目录是相对于`app/javascript`的。模板使用了`images`目录，但你可以使用`app/javascript`中的任何目录：

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

静态资源将被输出到`public/packs/media`目录下。例如，位于`app/javascript/images/my-image.jpg`的图像将被输出到`public/packs/media/images/my-image-abcd1234.jpg`。要在Rails视图中为此图像渲染一个图像标签，使用`image_pack_tag 'media/images/my-image.jpg'`。

Webpacker的ActionView助手用于静态资源与asset pipeline助手对应，对应关系如下表所示：
|ActionView助手|Webpacker助手|
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

此外，通用助手`asset_pack_path`接受文件的本地位置，并返回其在Rails视图中使用的Webpacker位置。

您还可以通过在`app/javascript`中的CSS文件中直接引用文件来访问图像。

### Rails引擎中的Webpacker

从Webpacker 6版本开始，Webpacker不再“引擎感知”，这意味着Webpacker在使用Rails引擎时与Sprockets的功能平衡不足。

希望支持使用Webpacker的消费者的Rails引擎的Gem作者被鼓励将前端资产作为NPM包分发，除了Gem本身之外，并提供说明（或安装程序）以演示主机应用程序应如何集成。这种方法的一个很好的例子是[Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms)。

### 热模块替换（HMR）

Webpacker默认支持与webpack-dev-server的HMR，并且您可以通过在`webpacker.yml`中设置dev_server/hmr选项来切换它。

有关更多信息，请查看[webpack关于DevServer的文档](https://webpack.js.org/configuration/dev-server/#devserver-hot)。

要支持与React的HMR，您需要添加react-hot-loader。请查看[React Hot Loader的入门指南](https://gaearon.github.io/react-hot-loader/getstarted/)。

如果您没有运行webpack-dev-server，请不要忘记禁用HMR；否则，样式表将出现“未找到错误”。

不同环境中的Webpacker
-----------------------------------

Webpacker默认有三个环境：`development`、`test`和`production`。您可以在`webpacker.yml`文件中添加其他环境配置，并为每个环境设置不同的默认值。Webpacker还将加载`config/webpack/<environment>.js`文件以进行其他环境设置。

## 在开发中运行Webpacker

Webpacker附带了两个用于开发的binstub文件：`./bin/webpack`和`./bin/webpack-dev-server`。它们都是对标准`webpack.js`和`webpack-dev-server.js`可执行文件的薄包装，确保根据您的环境加载正确的配置文件和环境变量。

默认情况下，Webpacker在开发中会根据需要自动编译，当加载Rails页面时。这意味着您不必运行任何单独的进程，并且编译错误将记录在标准的Rails日志中。您可以通过在`config/webpacker.yml`文件中更改为`compile: false`来更改此设置。运行`bin/webpack`将强制编译您的packs。

如果您想使用实时代码重新加载或有足够的JavaScript使得按需编译太慢，您需要运行`./bin/webpack-dev-server`或`ruby ./bin/webpack-dev-server`。此过程将监视`app/javascript/packs/*.js`文件的更改，并自动重新编译和重新加载浏览器以匹配。

Windows用户需要在与`bundle exec rails server`不同的终端中运行这些命令。

一旦启动了这个开发服务器，Webpacker将自动开始将所有webpack资源请求代理到该服务器。当您停止服务器时，它将恢复到按需编译。

[Webpacker文档](https://github.com/rails/webpacker)提供了您可以用来控制`webpack-dev-server`的环境变量的信息。有关webpack-dev-server用法的其他说明，请参阅[rails/webpacker文档](https://github.com/rails/webpacker#development)。

### 部署Webpacker

Webpacker将`webpacker:compile`任务添加到`bin/rails assets:precompile`任务中，因此任何使用`assets:precompile`的现有部署流水线都应该工作。编译任务将编译packs并将它们放置在`public/packs`中。

其他文档
------------------------

有关高级主题的更多信息，例如如何与流行框架一起使用Webpacker，请参阅[Webpacker文档](https://github.com/rails/webpacker)。
