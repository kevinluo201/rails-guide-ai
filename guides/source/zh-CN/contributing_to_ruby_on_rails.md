**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
贡献到Ruby on Rails
=============================

本指南介绍了如何成为Ruby on Rails持续开发的一部分。

阅读完本指南后，您将了解：

* 如何使用GitHub报告问题。
* 如何克隆主分支并运行测试套件。
* 如何帮助解决现有问题。
* 如何为Ruby on Rails文档做出贡献。
* 如何为Ruby on Rails代码做出贡献。

Ruby on Rails不是“别人的框架”。多年来，成千上万的人为Ruby on Rails做出了贡献，从一个字符到大规模的架构变更或重要的文档，所有这些都是为了使Ruby on Rails对每个人都更好。即使您还不想编写代码或文档，您也可以通过报告问题或测试补丁等其他方式做出贡献。

如[Rails的README](https://github.com/rails/rails/blob/main/README.md)中所述，与Rails及其子项目的代码库、问题跟踪器、聊天室、讨论板和邮件列表进行交互的每个人都应遵守Rails的[行为准则](https://rubyonrails.org/conduct)。

--------------------------------------------------------------------------------

报告问题
------------------

Ruby on Rails使用[GitHub问题跟踪](https://github.com/rails/rails/issues)来跟踪问题（主要是错误和新代码的贡献）。如果您在Ruby on Rails中发现了一个错误，这是开始的地方。您需要创建一个（免费）GitHub账户来提交问题、对问题发表评论或创建拉取请求。

注意：最新发布版本的Ruby on Rails中的错误可能会得到最多的关注。此外，Rails核心团队始终对那些可以花时间测试_edge Rails_（当前正在开发中的Rails版本的代码）的人的反馈感兴趣。在本指南的后面，您将了解如何获取edge Rails进行测试。有关支持的版本信息，请参阅我们的[维护政策](maintenance_policy.html)。请勿在GitHub问题跟踪器上报告安全问题。

### 创建错误报告

如果您在Ruby on Rails中发现的问题不是安全风险，请在GitHub上搜索[Issues](https://github.com/rails/rails/issues)，以防已经有人报告过了。如果您找不到任何解决您发现的问题的开放GitHub问题，那么您的下一步将是[创建新问题](https://github.com/rails/rails/issues/new)（有关报告安全问题，请参见下一节）。

我们为您提供了一个问题模板，以便在创建问题时包含确定框架中是否存在错误所需的所有信息。每个问题都需要包括标题和清晰的问题描述。请确保包含尽可能多的相关信息，包括演示预期行为的代码示例或失败的测试，以及您的系统配置。您的目标应该是使自己和其他人能够轻松地重现错误并找出修复方法。

一旦您打开一个问题，除非它是“红色代码，任务关键，世界即将终结”级别的错误，否则可能不会立即看到活动。这并不意味着我们不关心您的错误，只是因为有很多问题和拉取请求要处理。有相同问题的其他人可以找到您的问题，并确认该错误，并可能与您合作修复它。如果您知道如何修复错误，请打开一个拉取请求。

### 创建可执行的测试用例

有一种方法可以重现您的问题，这将有助于其他人确认、调查和最终修复您的问题。您可以通过提供可执行的测试用例来实现这一点。为了使这个过程更容易，我们为您准备了几个bug报告模板，供您使用：

* Active Record（模型、数据库）问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* 测试Active Record（迁移）问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Action Pack（控制器、路由）问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Active Job问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Active Storage问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Action Mailbox问题的模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* 其他问题的通用模板：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

这些模板包括设置针对已发布版本的Rails（`*_gem.rb`）或edge Rails（`*_main.rb`）的测试用例的样板代码。
将适当模板的内容复制到一个`.rb`文件中，并进行必要的更改以展示问题。您可以通过在终端中运行`ruby the_file.rb`来执行它。如果一切顺利，您应该会看到测试用例失败。

然后，您可以将可执行的测试用例共享为[gist](https://gist.github.com)，或将内容粘贴到问题描述中。

### 安全问题的特殊处理

警告：请不要通过公开的GitHub问题报告来报告安全漏洞。[Rails安全策略页面](https://rubyonrails.org/security)详细介绍了处理安全问题的程序。

### 功能请求呢？

请不要将“功能请求”项放入GitHub问题中。如果您想要在Ruby on Rails中添加新功能，您需要自己编写代码，或者说服其他人与您合作编写代码。在本指南的后面部分，您将找到有关向Ruby on Rails提出补丁建议的详细说明。如果您在GitHub问题中输入了一个没有代码的愿望清单项，那么一旦被审查，它将被标记为“无效”。

有时，“错误”和“功能”之间的界线很难划定。一般来说，功能是指添加新行为的任何内容，而错误是指导致不正确行为的任何内容。有时，核心团队必须做出判断。也就是说，这个区别通常决定了您的更改将与哪个补丁一起发布；我们喜欢功能提交！只是它们不会被回溯到维护分支。

如果您想在为补丁做准备的工作之前就某个功能的想法获得反馈，请在[rails-core讨论板](https://discuss.rubyonrails.org/c/rubyonrails-core)上发起讨论。您可能得不到任何回应，这意味着每个人都无所谓。您可能会找到其他对构建该功能也感兴趣的人。您可能会得到“这不会被接受”的回答。但这是讨论新想法的正确地方。GitHub问题并不是讨论新功能所需的有时冗长而复杂的讨论的特别好的场所。


帮助解决现有问题
----------------------------------

除了报告问题，您还可以通过提供有关问题的反馈来帮助核心团队解决现有问题。如果您是Rails核心开发的新手，提供反馈将帮助您熟悉代码库和流程。

如果您在GitHub问题中检查[问题列表](https://github.com/rails/rails/issues)，您会发现有很多问题需要处理。您可以做些什么呢？实际上有很多：

### 验证错误报告

首先，验证错误报告有所帮助。您能在自己的计算机上重现报告的问题吗？如果可以，您可以在问题中添加一条评论，说明您也遇到了同样的问题。

如果问题非常模糊，您能帮助将其缩小到更具体的内容吗？也许您可以提供额外的信息来重现错误，或者您可以消除不必要的步骤，这些步骤不需要来演示问题。

如果您发现一个没有测试的错误报告，贡献一个失败的测试非常有用。这也是探索源代码的好方法：查看现有的测试文件将教您如何编写更多的测试。新的测试最好以补丁的形式贡献，后面的[贡献到Rails代码](#contributing-to-the-rails-code)部分将对此进行解释。

您所能做的任何事情，使错误报告更简洁或更易于重现，都有助于那些试图编写代码来修复这些错误的人们，无论您最终是否自己编写代码。

### 测试补丁

您还可以通过检查通过GitHub提交给Ruby on Rails的拉取请求来提供帮助。为了应用某人的更改，首先创建一个专用的分支：

```bash
$ git checkout -b testing_branch
```

然后，您可以使用他们的远程分支来更新您的代码库。例如，假设GitHub用户JohnSmith已经fork并推送到位于https://github.com/JohnSmith/rails的主题分支“orange”。

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

除了将他们的远程添加到您的检出中，还可以使用[GitHub CLI工具](https://cli.github.com/)来检出他们的拉取请求。

应用他们的分支后，测试一下！以下是一些需要考虑的事情：
* 这个改变真的有效吗？
* 你对这些测试满意吗？你能理解它们在测试什么吗？有没有缺少的测试？
* 它有适当的文档覆盖吗？是否应该更新其他地方的文档？
* 你喜欢这个实现吗？你能想到一个更好或更快的实现他们改变的一部分吗？

一旦你对拉取请求的改变感到满意，请在GitHub问题上发表评论，指出你的发现。你的评论应该表明你喜欢这个改变以及你喜欢它的哪些方面。例如：

> 我喜欢你在generate_finder_sql中重构代码的方式 - 很好看。测试看起来也不错。

如果你的评论只是写"+1"，那么其他审查者可能不会太认真对待。表明你花时间审查了拉取请求。

贡献给Rails文档
---------------------------------------

Ruby on Rails有两个主要的文档集合：指南，帮助你学习Ruby on Rails，和API，作为参考。

你可以通过使它们更连贯、一致或可读，添加缺失的信息，纠正事实错误，修复拼写错误或使它们与最新的边缘Rails保持一致来帮助改进Rails指南或API参考。

为此，请对Rails指南源文件进行更改（位于GitHub上的[这里](https://github.com/rails/rails/tree/main/guides/source)）或源代码中的RDoc注释。然后打开一个拉取请求，将你的更改应用到主分支上。

在处理文档时，请考虑[API文档指南](api_documentation_guidelines.html)和[Ruby on Rails指南指南](ruby_on_rails_guides_guidelines.html)。

翻译Rails指南
------------------------

我们很高兴有人自愿翻译Rails指南。只需按照以下步骤操作：

* Fork https://github.com/rails/rails。
* 为您的语言添加一个源文件夹，例如：*guides/source/it-IT*用于意大利语。
* 将*guides/source*的内容复制到您的语言目录中并进行翻译。
* 不要翻译HTML文件，因为它们是自动生成的。

请注意，翻译不会提交到Rails存储库；您的工作位于您的fork中，如上所述。这是因为在实践中，通过补丁进行文档维护只在英语中可持续。

要以HTML格式生成指南，您需要安装指南依赖项，`cd`到*guides*目录，然后运行（例如，对于it-IT）：

```bash
# 仅安装指南所需的gems。要撤消运行：bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

这将在一个*output*目录中生成指南。

注意：Redcarpet Gem在JRuby上不起作用。

我们知道的翻译工作（各个版本）：

* **意大利语**：[https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **西班牙语**：[https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **波兰语**：[https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **法语**：[https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **捷克语**：[https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **土耳其语**：[https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **韩语**：[https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **简体中文**：[https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **繁体中文**：[https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **俄语**：[https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **日语**：[https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **巴西葡萄牙语**：[https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

贡献给Rails代码
------------------------------

### 设置开发环境

要从提交错误报告转向帮助解决现有问题或向Ruby on Rails贡献自己的代码，您必须能够运行其测试套件。在本指南的这一部分，您将学习如何在计算机上设置测试。

#### 使用GitHub Codespaces

如果您是启用了codespaces的组织的成员，您可以将Rails fork到该组织中，并在GitHub上使用codespaces。Codespace将初始化所有所需的依赖项，并允许您运行所有测试。

#### 使用VS Code Remote Containers

如果您已经安装了[Visual Studio Code](https://code.visualstudio.com)和[Docker](https://www.docker.com)，您可以使用[VS Code remote containers插件](https://code.visualstudio.com/docs/remote/containers-tutorial)。该插件将读取存储库中的[`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer)配置，并在本地构建Docker容器。

#### 使用Dev Container CLI

另外，使用安装了[Docker](https://www.docker.com)和[npm](https://github.com/npm/cli)的情况下，您可以运行[Dev Container CLI](https://github.com/devcontainers/cli)来利用命令行中的[`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer)配置。

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### 使用rails-dev-box

也可以使用[rails-dev-box](https://github.com/rails/rails-dev-box)来准备开发环境。但是，rails-dev-box使用Vagrant和Virtual Box，在搭载了Apple芯片的Mac上无法工作。
#### 本地开发

当无法使用GitHub Codespaces时，请参考[此指南](development_dependencies_install.html)以了解如何设置本地开发环境。这被认为是一种较困难的方式，因为安装依赖可能与操作系统有关。

### 克隆Rails代码库

为了能够贡献代码，您需要克隆Rails代码库：

```bash
$ git clone https://github.com/rails/rails.git
```

并创建一个专用的分支：

```bash
$ cd rails
$ git checkout -b my_new_branch
```

使用什么名称并不重要，因为这个分支只会存在于您的本地计算机和GitHub上的个人代码库中。它不会成为Rails Git代码库的一部分。

### 安装依赖

安装所需的gem包。

```bash
$ bundle install
```

### 运行应用程序与本地分支

如果您需要一个虚拟的Rails应用程序来测试更改，`rails new`命令的`--dev`标志会生成一个使用您的本地分支的应用程序：

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

在`~/my-test-app`中生成的应用程序将运行在您的本地分支上，并且在服务器重新启动时可以看到任何修改。

对于JavaScript包，您可以使用[`yarn link`](https://yarnpkg.com/cli/link)将您的本地分支链接到生成的应用程序中：

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### 编写您的代码

现在是时候编写一些代码了！在为Rails进行更改时，请记住以下几点：

* 遵循Rails的风格和约定。
* 使用Rails的习惯用法和辅助函数。
* 包含在没有您的代码的情况下会失败的测试，并且在有了您的代码后会通过。
* 更新（周围的）文档、其他示例和指南：任何受您贡献影响的内容。
* 如果更改添加、删除或更改了某个功能，请确保包含一个CHANGELOG条目。如果您的更改是修复错误，则不需要CHANGELOG条目。

提示：通常不会接受对稳定性、功能性或可测试性没有实质性增益的纯粹表面的更改（请阅读更多关于[我们做出此决定的原因](https://github.com/rails/rails/pull/13771#issuecomment-32746700)）。

#### 遵循编码规范

Rails遵循一套简单的编码风格约定：

* 使用两个空格，不使用制表符（用于缩进）。
* 没有尾随空格。空行不应包含任何空格。
* 在private/protected之后缩进并且不留空行。
* 对于哈希，请使用Ruby >= 1.9的语法。优先使用`{ a: :b }`而不是`{ :a => :b }`。
* 优先使用`&&`/`||`而不是`and`/`or`。
* 优先使用`class << self`而不是`self.method`来定义类方法。
* 使用`my_method(my_arg)`而不是`my_method( my_arg )`或`my_method my_arg`。
* 使用`a = b`而不是`a=b`。
* 使用`assert_not`方法而不是`refute`。
* 对于单行块，使用`method { do_stuff }`而不是`method{do_stuff}`。
* 遵循您已经看到的源代码中的约定。

以上是一些建议 - 请根据您的判断力使用它们。

此外，我们定义了[RuboCop](https://www.rubocop.org/)规则来规范一些编码约定。您可以在提交拉取请求之前在本地运行RuboCop来检查您修改的文件：

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

对于`rails-ujs`的CoffeeScript和JavaScript文件，您可以在`actionview`文件夹中运行`npm run lint`。

#### 拼写检查

我们使用[misspell](https://github.com/client9/misspell)来检查拼写错误，它主要是用[Golang](https://golang.org/)编写的，并通过[GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml)运行。使用`misspell`可以快速纠正常见的拼写错误。`misspell`与大多数其他拼写检查器不同，它不使用自定义字典。您可以在所有文件上本地运行`misspell`：

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

`misspell`的一些重要帮助选项或标志包括：

- `-i` 字符串：忽略以下更正，以逗号分隔
- `-w`：用更正后的内容覆盖文件（默认只显示）

我们还使用GitHub Actions运行[codespell](https://github.com/codespell-project/codespell)来检查拼写错误，而[codespell](https://pypi.org/project/codespell/)则针对一个[小型自定义字典](https://github.com/rails/rails/blob/main/codespell.txt)运行。`codespell`是用[Python](https://www.python.org/)编写的，您可以使用以下命令运行它：

```bash
$ codespell --ignore-words=codespell.txt
```

### 对代码进行基准测试

对于可能对性能产生影响的更改，请对您的代码进行基准测试并测量其影响。请分享您使用的基准测试脚本以及结果。您应该考虑将此信息包含在提交消息中，以便未来的贡献者可以轻松验证您的发现并确定它们是否仍然相关（例如，Ruby VM中的未来优化可能会使某些优化变得不必要）。
当针对特定场景进行优化时，很容易降低其他常见情况下的性能。因此，您应该针对一系列代表性场景进行测试，最好是从真实的生产应用程序中提取。

您可以使用[基准模板](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb)作为起点。它包含了使用[benchmark-ips](https://github.com/evanphx/benchmark-ips) gem设置基准测试的样板代码。该模板适用于测试相对独立的可以内联到脚本中的改变。

### 运行测试

在推送更改之前，Rails通常不会运行完整的测试套件。特别是，railties测试套件需要很长时间，如果源代码像在推荐的[rails-dev-box](https://github.com/rails/rails-dev-box)工作流中一样挂载在`/vagrant`中，那么所需时间会更长。

作为妥协，测试您的代码明显影响的部分，如果更改不在railties中，请运行受影响组件的整个测试套件。如果所有测试都通过，那就足以提出您的贡献。我们有[Buildkite](https://buildkite.com/rails/rails)作为捕捉其他意外故障的安全网。

#### 整个Rails：

要运行所有测试，请执行以下操作：

```bash
$ cd rails
$ bundle exec rake test
```

#### 针对特定组件

您可以仅运行特定组件的测试（例如，Action Pack）。例如，要运行Action Mailer的测试：

```bash
$ cd actionmailer
$ bin/test
```

#### 针对特定目录

您可以仅运行特定组件的特定目录的测试（例如，Active Storage中的模型）。例如，要运行`/activestorage/test/models`中的测试：

```bash
$ cd activestorage
$ bin/test models
```

#### 针对特定文件

您可以运行特定文件的测试：

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### 运行单个测试

您可以使用`-n`选项按名称运行单个测试：

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### 针对特定行

确定名称并不总是容易的，但如果您知道测试开始的行号，可以使用此选项：

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### 使用特定种子运行测试

测试执行是随机化的，使用随机化种子。如果您遇到随机测试失败，可以通过明确设置随机化种子来更准确地重现失败的测试场景。

运行组件的所有测试：

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

运行单个测试文件：

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### 串行运行测试

默认情况下，Action Pack和Action View单元测试是并行运行的。如果您遇到随机测试失败，可以设置随机化种子，并通过设置`PARALLEL_WORKERS=1`使这些单元测试串行运行。

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### 测试Active Record

首先，创建所需的数据库。您可以在`activerecord/test/config.example.yml`中找到所需的表名、用户名和密码的列表。

对于MySQL和PostgreSQL，只需运行：

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

或：

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

对于SQLite3，不需要这样做。

这是如何仅针对SQLite3运行Active Record测试套件的方法：

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

现在，您可以像对待`sqlite3`一样运行测试。任务分别是：

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

最后，

```bash
$ bundle exec rake test
```

将按顺序运行这三个任务。

您还可以单独运行任何单个测试：

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

要针对所有适配器运行单个测试，请使用：

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

您还可以使用`test_jdbcmysql`、`test_jdbcsqlite3`或`test_jdbcpostgresql`。有关运行更有针对性的数据库测试的详细信息，请参阅文件`activerecord/RUNNING_UNIT_TESTS.rdoc`。

#### 在测试中使用调试器

要使用外部调试器（pry、byebug等），请安装调试器并像平常一样使用它。如果出现调试器问题，请通过设置`PARALLEL_WORKERS=1`以串行方式运行测试，或者使用`-n test_long_test_name`运行单个测试。

### 警告

测试套件在启用警告的情况下运行。理想情况下，Ruby on Rails不应发出任何警告，但可能会有一些警告，以及一些来自第三方库的警告。请忽略（或修复！）它们（如果有的话），并提交不发出新警告的补丁。
Rails CI会在引入警告时引发错误。要在本地实现相同的行为，请在运行测试套件时设置`RAILS_STRICT_WARNINGS=1`。

### 更新文档

Ruby on Rails的[指南](https://guides.rubyonrails.org/)提供了Rails功能的高级概述，而[API文档](https://api.rubyonrails.org/)则深入介绍了具体细节。

如果您的PR添加了一个新功能，或者更改了现有功能的行为，请检查相关文档，并根据需要进行更新或添加。

例如，如果您修改了Active Storage的图像分析器以添加一个新的元数据字段，您应该更新Active Storage指南中的[分析文件](active_storage_overview.html#analyzing-files)部分以反映这一点。

### 更新CHANGELOG

CHANGELOG是每个版本发布的重要组成部分。它记录了每个Rails版本的更改列表。

如果您正在添加或删除功能，或者添加弃用通知，则应将条目添加到您修改的框架的CHANGELOG的**顶部**。重构、次要错误修复和文档更改通常不应包含在CHANGELOG中。

CHANGELOG条目应概述所做的更改，并以作者的姓名结尾。如果需要更多空间，可以使用多行，并附加使用4个空格缩进的代码示例。如果更改与特定问题相关，则应附加问题编号。以下是CHANGELOG条目的示例：

```
*   简要描述更改的摘要。您可以使用多行，并在大约80个字符处换行。如果需要，可以附加代码示例：

        class Foo
          def bar
            puts 'baz'
          end
        end

    您可以在代码示例后继续，并附加问题编号。

    Fixes #1234.

    *您的姓名*
```

如果没有代码示例或多个段落，您的姓名可以直接添加在最后一个单词之后。否则，最好另起一段。

### 破坏性更改

任何可能破坏现有应用程序的更改都被视为破坏性更改。为了简化升级Rails应用程序，破坏性更改需要进行弃用周期。

#### 删除行为

如果您的破坏性更改删除了现有行为，您需要首先添加一个弃用警告，同时保留现有行为。

例如，假设您想要删除`ActiveRecord::Base`上的一个公共方法。如果主分支指向未发布的7.0版本，Rails 7.0将需要显示一个弃用警告。这样可以确保升级到任何Rails 7.0版本的用户都能看到弃用警告。在Rails 7.1中，该方法可以被删除。

您可以添加以下弃用警告：

```ruby
def deprecated_method
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.deprecated_method` is deprecated and will be removed in Rails 7.1.
  MSG
  # 现有行为
end
```

#### 更改行为

如果您的破坏性更改更改了现有行为，您需要添加一个框架默认值。框架默认值通过允许应用程序逐个切换到新的默认值来简化Rails升级。

要实现新的框架默认值，首先在目标框架上添加一个访问器来创建一个配置。将默认值设置为现有行为，以确保在升级过程中不会出现任何问题。

```ruby
module ActiveJob
  mattr_accessor :existing_behavior, default: true
end
```

新的配置允许您有条件地实现新的行为：

```ruby
def changed_method
  if ActiveJob.existing_behavior
    # 现有行为
  else
    # 新行为
  end
end
```

要设置新的框架默认值，请在`Rails::Application::Configuration#load_defaults`中设置新值：

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

为了简化升级，需要将新的默认值添加到`new_framework_defaults`模板中。添加一个注释掉的部分，设置新值：

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.existing_behavior = false
```

最后一步是将新的配置添加到`configuration.md`中的配置指南中：

```markdown
#### `config.active_job.existing_behavior`

| 从版本开始 | 默认值 |
| ---------- | ------ |
| （原始）   | `true` |
| 7.1        | `false`|
```

### 忽略编辑器/IDE创建的文件

某些编辑器和IDE会在`rails`文件夹内创建隐藏文件或文件夹。您应该将它们添加到您自己的[全局gitignore文件](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)，而不是手动将它们从每个提交中排除或将它们添加到Rails的`.gitignore`中。

### 更新Gemfile.lock

某些更改需要更新依赖项。在这些情况下，请确保运行`bundle update`以获取正确的依赖项版本，并在您的更改中提交`Gemfile.lock`文件。
### 提交你的更改

当你对电脑上的代码感到满意时，你需要将更改提交到Git：

```bash
$ git commit -a
```

这将启动你的编辑器以编写提交消息。完成后，保存并关闭以继续。

一个格式良好且描述性的提交消息对于其他人理解为什么进行了更改非常有帮助，所以请花时间编写它。

一个好的提交消息应该像这样：

```
简短的摘要（最好不超过50个字符）

更详细的描述，如果需要的话。每行应该在72个字符处换行。
尽量详细地描述。即使你认为提交内容很明显，对其他人来说可能并不明显。
添加任何已经存在于相关问题中的描述；不需要访问网页来查看历史记录。

描述部分可以有多个段落。

可以通过缩进4个空格来嵌入代码示例：

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

你也可以添加项目符号：

- 通过在行首使用破折号（-）或星号（*）来创建项目符号

- 在72个字符处换行，并使用2个空格缩进任何额外的行以提高可读性
```

提示：在适当的时候，请将你的提交合并为一个单独的提交。这样可以简化将来的挑选操作，并保持git日志的清晰。

### 更新你的分支

在你工作的过程中，很可能会有其他对主分支的更改。要获取主分支上的新更改：

```bash
$ git checkout main
$ git pull --rebase
```

现在将你的补丁重新应用到最新更改之上：

```bash
$ git checkout my_new_branch
$ git rebase main
```

没有冲突？测试仍然通过？你仍然认为更改是合理的吗？然后将重新应用的更改推送到GitHub：

```bash
$ git push --force-with-lease
```

我们禁止在rails/rails存储库基础上进行强制推送，但你可以强制推送到你的分支。在进行变基操作时，这是一个要求，因为历史记录已经发生了变化。

### Fork

转到Rails的[GitHub存储库](https://github.com/rails/rails)并点击右上角的“Fork”。

将新的远程仓库添加到你的本地机器上的本地仓库：

```bash
$ git remote add fork https://github.com/<你的用户名>/rails.git
```

你可能已经从rails/rails克隆了你的本地仓库，或者你可能已经从你的分叉仓库克隆了。以下git命令假设你已经创建了一个指向rails/rails的“rails”远程仓库。

```bash
$ git remote add rails https://github.com/rails/rails.git
```

从官方存储库下载新的提交和分支：

```bash
$ git fetch rails
```

合并新内容：

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

更新你的分叉仓库：

```bash
$ git push fork main
$ git push fork my_new_branch
```

### 发起拉取请求

转到你刚刚推送的Rails存储库（例如 https://github.com/your-user-name/rails ）并点击顶部栏中的“Pull Requests”。在下一页中，点击右上角的“New pull request”。

拉取请求应该将目标存储库设置为`rails/rails`，分支设置为`main`。源存储库将是你的工作（`your-user-name/rails`），分支将是你给分支起的任何名称。当准备好时，点击“create pull request”。

确保你引入的更改集已包含在内。使用提供的拉取请求模板填写有关你的潜在补丁的一些细节。完成后，点击“Create pull request”。

### 获取一些反馈

大多数拉取请求在合并之前都会经历几个迭代。不同的贡献者有时会有不同的意见，通常需要修改补丁才能合并。

Rails的一些贡献者已经打开了GitHub的电子邮件通知，但其他人没有。此外，（几乎）所有在Rails上工作的人都是志愿者，所以你可能需要等待几天才能得到对拉取请求的第一个反馈。不要绝望！有时候很快，有时候很慢。这就是开源生活。

如果已经过去一周，你还没有听到任何消息，你可能想尝试推动事情的进展。你可以使用[rubyonrails-core讨论板](https://discuss.rubyonrails.org/c/rubyonrails-core)来做这件事。你也可以在拉取请求上再留下一条评论。
在等待对您的拉取请求的反馈时，打开几个其他的拉取请求并给别人一些反馈！他们会像您对补丁的反馈一样感激。

请注意，只有核心团队和提交者团队有权合并代码更改。
如果有人给出反馈并“批准”您的更改，他们可能没有能力或最终决定权来合并您的更改。

### 根据需要进行迭代

您得到的反馈可能会建议进行更改。不要灰心：参与活跃的开源项目的整个目的就是利用社区的知识。如果有人鼓励您调整代码，那么值得进行调整并重新提交。如果反馈是您的代码不会被合并，您可能仍然考虑将其发布为一个 gem。

#### 合并提交

我们可能要求您“合并提交”，将所有提交合并为一个提交。我们更喜欢只有一个提交的拉取请求。这样可以更容易地将更改回溯到稳定分支，合并提交更容易撤销，而且 git 历史记录可能更容易跟踪。Rails 是一个庞大的项目，大量的无关提交会增加很多噪音。

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< 选择除第一个提交之外的所有提交都选择 'squash'。 >
< 编辑提交消息以使其有意义，并描述您的所有更改。 >

$ git push fork my_new_branch --force-with-lease
```

您应该能够刷新 GitHub 上的拉取请求，并看到它已经更新。

#### 更新拉取请求

有时您会被要求对您已经提交的代码进行一些更改。这可能包括修改现有的提交。在这种情况下，Git 不允许您推送更改，因为推送的分支和本地分支不匹配。您可以像前面在合并提交部分中描述的那样，强制推送到 GitHub 上的分支，而不是打开一个新的拉取请求：

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

这将使用您的新代码更新分支和拉取请求。通过使用 `--force-with-lease` 强制推送，git 将比使用典型的 `-f` 更安全地更新远程，后者可能会删除您尚未拥有的远程工作。

### 旧版本的 Ruby on Rails

如果您想为早于下一个发布版本的 Ruby on Rails 添加修复程序，您需要设置并切换到自己的本地跟踪分支。以下是一个示例，切换到 7-0-stable 分支：

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

注意：在处理旧版本之前，请检查[维护政策](maintenance_policy.html)。不会接受已经到达生命周期终点的版本的更改。

#### 回溯

合并到 main 的更改是为 Rails 的下一个主要版本而设计的。有时，将您的更改传播回稳定分支以包含在维护版本中可能是有益的。通常，安全修复和错误修复是回溯的好候选，而新功能和更改预期行为的补丁将不会被接受。如果有疑问，最好在回溯您的更改之前咨询 Rails 团队成员，以避免浪费努力。

首先，确保您的 main 分支是最新的。

```bash
$ git checkout main
$ git pull --rebase
```

检出您要回溯的分支，例如 `7-0-stable`，并确保它是最新的：

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

如果您要回溯合并的拉取请求，请找到合并的提交并进行 cherry-pick：

```bash
$ git cherry-pick -m1 MERGE_SHA
```

解决在 cherry-pick 中发生的任何冲突，推送您的更改，然后打开一个指向您要回溯的稳定分支的 PR。如果您有一组更复杂的更改，[cherry-pick](https://git-scm.com/docs/git-cherry-pick) 文档可以提供帮助。

Rails 贡献者
------------------

所有贡献都会在[Rails 贡献者](https://contributors.rubyonrails.org)中得到认可。
