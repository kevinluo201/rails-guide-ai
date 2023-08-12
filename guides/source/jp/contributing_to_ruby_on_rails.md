**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
Ruby on Railsへの貢献
=============================

このガイドでは、Ruby on Railsの進行中の開発に参加する方法について説明します。

このガイドを読み終えると、以下のことがわかるようになります。

* GitHubを使用して問題を報告する方法。
* メインをクローンしてテストスイートを実行する方法。
* 既存の問題の解決に役立つ方法。
* Ruby on Railsのドキュメントへの貢献方法。
* Ruby on Railsのコードへの貢献方法。

Ruby on Railsは「他の誰かのフレームワーク」ではありません。これまでに、一文字から大規模なアーキテクチャの変更や重要なドキュメントまで、数千人の人々がRuby on Railsに貢献してきました。これらの貢献は、Ruby on Railsをより良くするためのものです。コードやドキュメントの作成に自信がない場合でも、問題の報告からパッチのテストまで、さまざまな方法で貢献することができます。

[RailsのREADME](https://github.com/rails/rails/blob/main/README.md)で説明されているように、Railsおよびそのサブプロジェクトのコードベース、問題追跡システム、チャットルーム、ディスカッションボード、メーリングリストへの参加者は、Railsの[行動規範](https://rubyonrails.org/conduct)に従うことが期待されています。

--------------------------------------------------------------------------------

問題の報告
------------------

Ruby on Railsでは、問題（主にバグや新しいコードの貢献）を追跡するために[GitHub Issue Tracking](https://github.com/rails/rails/issues)を使用しています。Ruby on Railsのバグを見つけた場合は、まずここから始める必要があります。問題を報告したり、問題にコメントしたり、プルリクエストを作成するには、(無料の)GitHubアカウントを作成する必要があります。

注意：最新リリースバージョンのRuby on Railsのバグは、最も注目される可能性があります。また、Railsコアチームは常に、時間をかけて_edge Rails_（現在開発中のRailsのコード）をテストできる人々からのフィードバックに興味を持っています。このガイドの後半で、テスト用のedge Railsを取得する方法について説明します。サポートされているバージョンに関する情報については、[メンテナンスポリシー](maintenance_policy.html)を参照してください。セキュリティの問題は、GitHubの問題追跡システムで報告しないでください。

### バグレポートの作成

セキュリティリスクではないRuby on Railsの問題を見つけた場合は、まずGitHubの[Issues](https://github.com/rails/rails/issues)で報告されていないか検索してください。報告されていない場合は、次のステップとして[新しい問題を作成](https://github.com/rails/rails/issues/new)します（セキュリティの問題については、次のセクションを参照してください）。

問題がフレームワークにバグがあるかどうかを判断するために必要なすべての情報を含めるために、問題のテンプレートを用意しました。各問題には、タイトルと問題の明確な説明が必要です。期待される動作を示すコードサンプルや失敗するテストなど、関連する情報をできるだけ多く含めるようにしてください。また、システムの構成も含めてください。バグを再現し、修正方法を見つけるために、自分自身や他の人が問題を再現しやすくすることが目標です。

問題を報告すると、すぐにアクティビティが表示されるわけではありません。ただし、「コードレッド、ミッションクリティカル、世界が終わりに近づいている」というような重大なバグでない限り、すぐにアクティビティが表示されるわけではありません。これは、私たちがあなたのバグに関心を持っていないという意味ではありません。ただ、多くの問題とプルリクエストがあるためです。同じ問題を抱えている他の人があなたの問題を見つけ、バグを確認し、修正に協力することがあります。バグを修正する方法を知っている場合は、プルリクエストを作成してください。

### 実行可能なテストケースの作成

問題を再現する方法を提供することで、他の人が問題を確認し、調査し、最終的に修正するのに役立ちます。これは、実行可能なテストケースを提供することで行うことができます。このプロセスを簡単にするために、いくつかのバグレポートのテンプレートを準備しました。これらのテンプレートは、リリースされたバージョンのRails (`*_gem.rb`) またはedge Rails (`*_main.rb`) のいずれかに対してテストケースを設定するためのボイラープレートコードが含まれています。

* Active Record（モデル、データベース）の問題のテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Active Record（マイグレーション）の問題のテストのテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Action Pack（コントローラ、ルーティング）の問題のテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Active Jobの問題のテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Active Storageの問題のテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Action Mailboxの問題のテンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* その他の問題の汎用テンプレート：[gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

これらのテンプレートには、リリースされたバージョンのRails (`*_gem.rb`) またはedge Rails (`*_main.rb`) のいずれかに対してテストケースを設定するためのボイラープレートコードが含まれています。
適切なテンプレートの内容を`.rb`ファイルにコピーし、必要な変更を行って問題を示してください。ターミナルで`ruby the_file.rb`を実行することで、テストケースが失敗するはずです。

その後、実行可能なテストケースを[gist](https://gist.github.com)に共有するか、内容を問題の説明に貼り付けることができます。

### セキュリティの問題に対する特別な取り扱い

警告: セキュリティの脆弱性に関しては、公開されたGitHubの問題報告で報告しないでください。[Railsセキュリティポリシーページ](https://rubyonrails.org/security)には、セキュリティの問題に関する手順が詳細に記載されています。

### 機能リクエストについてはどうですか？

GitHubの問題に「機能リクエスト」の項目を入れないでください。Ruby on Railsに追加される新しい機能を要求する場合は、自分でコードを書くか、他の誰かにコードの作成を依頼する必要があります。このガイドの後半では、Ruby on Railsへのパッチの提案方法について詳細な手順が説明されています。コードのないウィッシュリストの項目をGitHubの問題に入力すると、レビューされるとすぐに「無効」とマークされることが予想されます。

時には、「バグ」と「機能」の間の境界線は曖昧なものです。一般的に、機能は新しい動作を追加するものであり、バグは正しくない動作を引き起こすものです。時には、コアチームが判断を下す必要があります。ただし、この区別は通常、変更がリリースされるパッチを決定するものです。私たちは機能の提出を歓迎します！ただし、メンテナンスブランチにはバックポートされません。

パッチを作成する前に、アイデアのフィードバックを受ける場合は、[rails-coreディスカッションボード](https://discuss.rubyonrails.org/c/rubyonrails-core)でディスカッションを開始してください。誰も関心を持っていない場合は、返信がないかもしれません。その機能を構築することに興味を持っている他の人を見つけるかもしれません。受け入れられないという意見を得るかもしれません。しかし、新しいアイデアを議論するのに適切な場所です。GitHubの問題は、新しい機能に必要な長くて複雑な議論にはあまり適していません。

既存の問題の解決に協力する
----------------------------------

問題を報告するだけでなく、コアチームが既存の問題を解決するのを助けるためにフィードバックを提供することもできます。Railsコア開発に初めて参加する場合、フィードバックを提供することでコードベースとプロセスに慣れるのに役立ちます。

GitHubの問題リストをチェックすると、すでに対応が必要な問題がたくさんあります。これらについてどのように対処できますか？実際にはかなりのことができます。

### バグレポートの検証

まずは、バグレポートを検証するだけでも役立ちます。報告された問題を自分のコンピュータで再現できますか？もしそうなら、同じことを見ているというコメントを問題に追加することができます。

問題が非常に曖昧な場合、より具体的なものに絞り込むのに役立ちますか？バグを再現するための追加情報を提供したり、問題を示すために必要のない手順を削除したりすることができるかもしれません。

テストがないバグレポートを見つけた場合、失敗するテストを提供すると非常に役立ちます。これはソースコードを調査するための素晴らしい方法でもあります。既存のテストファイルを見ることで、より多くのテストを書く方法を学ぶことができます。新しいテストは、後述する「Railsコードへの貢献」セクションで説明されているように、パッチの形で提供するのが最適です。

バグレポートをより簡潔かつ再現しやすくするためにできることは何でも、それらのバグを修正するためのコードを書こうとしている人々に役立ちます。自分自身でコードを書くかどうかに関係なく。
* 変更は実際に機能していますか？
* テストは満足していますか？テストが何をテストしているのか理解できますか？不足しているテストはありますか？
* 適切なドキュメンテーションのカバレッジがありますか？他の場所のドキュメントを更新する必要がありますか？
* 実装は好きですか？変更の一部をより良いまたは高速な方法で実装できますか？

プルリクエストが良い変更を含んでいると満足したら、GitHubの問題にコメントして調査結果を示してください。コメントには、変更が好きであり、その点について何が好きかを示す必要があります。以下のような内容です。

> generate_finder_sqlのコードの再構築方法が気に入りました。テストも良さそうです。

コメントが単に「+1」という場合、他のレビュワーはそれをあまり真剣に受け取らない可能性があります。レビューに時間をかけたことを示してください。

Railsドキュメントへの貢献
--------------------------

Ruby on Railsには、Ruby on Railsの学習を支援するガイドと、リファレンスとして機能するAPIの2つの主要なドキュメントセットがあります。

RailsガイドまたはAPIリファレンスをより一貫性のある、一貫性のある、読みやすいものにしたり、欠落している情報を追加したり、事実の誤りを修正したり、タイポを修正したり、最新のエッジRailsに合わせて更新したりすることで、RailsガイドまたはAPIリファレンスを改善することができます。

そのためには、Railsガイドのソースファイル（GitHubの[こちら](https://github.com/rails/rails/tree/main/guides/source)にあります）またはソースコードのRDocコメントを変更します。その後、変更をメインブランチに適用するためにプルリクエストを開きます。

ドキュメント作業を行う際には、[APIドキュメントガイドライン](api_documentation_guidelines.html)と[Ruby on Railsガイドライン](ruby_on_rails_guides_guidelines.html)を考慮してください。

Railsガイドの翻訳
------------------

Railsガイドの翻訳に協力していただけると嬉しいです。以下の手順に従ってください。

* https://github.com/rails/rails をフォークします。
* 言語ごとのソースフォルダを追加します。例えば、イタリア語の場合は*guides/source/it-IT*とします。
* *guides/source*の内容を言語ディレクトリにコピーして翻訳します。
* HTMLファイルは翻訳しないでください。これらは自動的に生成されます。

翻訳はRailsリポジトリに提出されません。作業は上記のようにフォーク内で行われます。これは、実際にはドキュメントのメンテナンスは英語でのみ持続可能であるためです。

HTML形式のガイドを生成するには、ガイドの依存関係をインストールする必要があります。*guides*ディレクトリに移動し、次のコマンドを実行します（例：it-ITの場合）。

```bash
# ガイドに必要なジェムのみをインストールします。元に戻すには、bundle config --delete without を実行します
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

これにより、*output*ディレクトリにガイドが生成されます。

注意：Redcarpet GemはJRubyでは動作しません。

既知の翻訳作業（さまざまなバージョン）：

* **イタリア語**：[https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **スペイン語**：[https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **ポーランド語**：[https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **フランス語**：[https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **チェコ語**：[https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **トルコ語**：[https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **韓国語**：[https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **簡体字中国語**：[https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **繁体字中国語**：[https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **ロシア語**：[https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **日本語**：[https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **ブラジルポルトガル語**：[https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Railsコードへの貢献
------------------

### 開発環境のセットアップ

バグの報告から既存の問題の解決や独自のコードの貢献に移るためには、Ruby on Railsのテストスイートを実行できる必要があります。このガイドのこのセクションでは、コンピュータ上でテストをセットアップする方法について学びます。

#### GitHub Codespacesを使用する

Codespacesが有効な組織のメンバーであれば、Railsをその組織にフォークし、GitHub上でCodespacesを使用することができます。Codespaceは必要なすべての依存関係で初期化され、すべてのテストを実行できます。

#### VS Code Remote Containersを使用する

[Visual Studio Code](https://code.visualstudio.com)と[Docker](https://www.docker.com)がインストールされている場合、[VS Code remote containersプラグイン](https://code.visualstudio.com/docs/remote/containers-tutorial)を使用できます。このプラグインは、リポジトリの[`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer)の設定を読み取り、Dockerコンテナをローカルでビルドします。

#### Dev Container CLIを使用する

または、[Docker](https://www.docker.com)と[npm](https://github.com/npm/cli)がインストールされている場合、[Dev Container CLI](https://github.com/devcontainers/cli)を実行して、コマンドラインから[`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer)の設定を利用することもできます。

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### rails-dev-boxを使用する

[rails-dev-box](https://github.com/rails/rails-dev-box)を使用して開発環境を準備することもできます。ただし、rails-dev-boxはVagrantとVirtual Boxを使用しており、Appleシリコンを搭載したMacでは動作しません。
#### ローカル開発

GitHub Codespacesを使用できない場合は、ローカル開発の設定方法については[この別のガイド](development_dependencies_install.html)を参照してください。これは、依存関係のインストールがOSに依存するため、難しい方法とされています。

### Railsリポジトリのクローン

コードの貢献をするためには、Railsリポジトリをクローンする必要があります。

```bash
$ git clone https://github.com/rails/rails.git
```

そして、専用のブランチを作成します。

```bash
$ cd rails
$ git checkout -b my_new_branch
```

使用する名前はあまり重要ではありません。このブランチは、ローカルコンピュータとGitHub上の個人リポジトリにのみ存在し、RailsのGitリポジトリの一部ではありません。

### Bundle install

必要なgemをインストールします。

```bash
$ bundle install
```

### ローカルブランチを使用してアプリケーションを実行する

変更をテストするためにダミーのRailsアプリが必要な場合、`rails new`の`--dev`フラグを使用してローカルブランチを使用するアプリケーションを生成します。

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

`~/my-test-app`に生成されたアプリケーションは、ローカルブランチを使用して実行され、特にサーバーの再起動時に行われた変更が反映されます。

JavaScriptパッケージの場合、生成されたアプリケーションでローカルブランチをソースとして使用するために、[`yarn link`](https://yarnpkg.com/cli/link)を使用できます。

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### コードを書く

さあ、コードを書く時間です！Railsの変更を行う際には、以下のことに注意してください。

* Railsのスタイルと規約に従うこと。
* Railsのイディオムとヘルパーを使用すること。
* コードがないと失敗し、コードがあると成功するテストを含めること。
* 貢献に影響を受けるドキュメント、他の場所の例、ガイドを更新すること。
* 変更が機能を追加、削除、または変更する場合は、CHANGELOGエントリを含めること。バグ修正の場合は、CHANGELOGエントリは必要ありません。

TIP: Railsの安定性、機能、テスト可能性に実質的な追加を行わない見た目の変更は、一般的には受け入れられません（この決定の背後にある理由については、[こちらを参照してください](https://github.com/rails/rails/pull/13771#issuecomment-32746700)）。

#### コーディング規約に従う

Railsは、シンプルなコーディングスタイルの規約に従います。

* インデントには2つのスペースを使用し、タブは使用しません。
* 末尾の空白はありません。空白を含む空行はありません。
* private/protectedの後にはインデントと空行はありません。
* ハッシュにはRuby >= 1.9の構文を使用します。`{ a: :b }`を`{ :a => :b }`よりも好みます。
* `and`/`or`よりも`&&`/`||`を好みます。
* クラスメソッドには`self.method`ではなく`class << self`を使用します。
* `my_method( my_arg )`や`my_method my_arg`ではなく、`my_method(my_arg)`を使用します。
* `a=b`ではなく`a = b`を使用します。
* `refute`の代わりに`assert_not`メソッドを使用します。
* 1行のブロックでは、`method{do_stuff}`ではなく`method { do_stuff }`を使用します。
* 既に使用されているソースの規約に従います。

上記はガイドラインです - これらを使用する際には、最善の判断を行ってください。

さらに、いくつかのコーディング規約を明確化するために[RuboCop](https://www.rubocop.org/)ルールが定義されています。プルリクエストを送信する前に、変更したファイルに対してローカルでRuboCopを実行できます。

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

`rails-ujs`のCoffeeScriptとJavaScriptファイルに対しては、`actionview`フォルダで`npm run lint`を実行できます。

#### スペルチェック

私たちは、スペルチェックのために[Golang](https://golang.org/)で主に書かれた[misspell](https://github.com/client9/misspell)を実行しています。[GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml)でスペルチェックを行います。`misspell`は、カスタム辞書を使用しないため、他のほとんどのスペルチェッカーとは異なります。すべてのファイルに対してローカルで`misspell`を実行できます。

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

注目すべき`misspell`のヘルプオプションまたはフラグは次のとおりです。

- `-i` string: 以下の修正を無視します。カンマで区切ります。
- `-w`: 修正でファイルを上書きします（デフォルトは表示のみです）。

私たちはまた、スペルチェックのために[Python](https://www.python.org/)で書かれた[codespell](https://github.com/codespell-project/codespell)をGitHub Actionsで実行しています。[codespell](https://pypi.org/project/codespell/)は、[小さなカスタム辞書](https://github.com/rails/rails/blob/main/codespell.txt)に対して実行されます。`codespell`は次のように実行できます。

```bash
$ codespell --ignore-words=codespell.txt
```

### コードのベンチマーク

パフォーマンスに影響を与える可能性のある変更については、コードのベンチマークを行い、影響を測定してください。使用したベンチマークスクリプトと結果を共有してください。これにより、将来の貢献者が簡単に結果を確認し、それがまだ有効かどうかを判断できるように、コミットメッセージにこの情報を含めることを検討してください（たとえば、Ruby VMの将来の最適化によって、特定の最適化が不要になる場合があります）。
特定のシナリオに最適化する際には、他の一般的なケースのパフォーマンスが低下する可能性があります。
そのため、実際のプロダクションアプリケーションから抽出した代表的なシナリオのリストに対して変更をテストすることが重要です。

[ベンチマークテンプレート](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb)を使用すると、ベンチマークを設定するためのボイラープレートコードが含まれています。このテンプレートは、スクリプトにインラインで組み込むことができる比較的独立した変更をテストするために設計されています。

### テストの実行

Railsでは、変更をプッシュする前に完全なテストスイートを実行することは一般的ではありません。特にrailtiesのテストスイートは時間がかかりますし、[rails-dev-box](https://github.com/rails/rails-dev-box)を使用した推奨されるワークフローでは、ソースコードが`/vagrant`にマウントされるため、特に時間がかかります。

そのため、コードに明らかに影響を与えるテストを実行し、変更がrailtiesに含まれていない場合は、関連するコンポーネントの全体のテストスイートを実行します。すべてのテストがパスする場合、貢献を提案するために十分です。予期しないエラーが他の場所で発生する可能性を捕捉するために、[Buildkite](https://buildkite.com/rails/rails)を使用しています。

#### Rails全体のテスト:

すべてのテストを実行するには、次のコマンドを実行します:

```bash
$ cd rails
$ bundle exec rake test
```

#### 特定のコンポーネントのテスト

特定のコンポーネント（例：Action Pack）のテストのみを実行することもできます。たとえば、Action Mailerのテストを実行するには次のコマンドを実行します:

```bash
$ cd actionmailer
$ bin/test
```

#### 特定のディレクトリのテスト

特定のコンポーネントの特定のディレクトリのテストのみを実行することもできます（例：Active Storageのモデル）。たとえば、`/activestorage/test/models`のテストを実行するには次のコマンドを実行します:

```bash
$ cd activestorage
$ bin/test models
```

#### 特定のファイルのテスト

特定のファイルのテストを実行するには次のコマンドを実行します:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### 単一のテストの実行

`-n`オプションを使用して、テスト名で単一のテストを実行することができます:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### 特定の行のテスト

テストの名前を特定することは常に簡単ではありませんが、テストが開始する行番号を知っている場合は、このオプションを使用します:

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### 特定のシードでテストの実行

テストの実行はランダムなシードで行われます。ランダムなテストの失敗が発生している場合、特定のランダム化シードを設定することで、失敗するテストシナリオをより正確に再現することができます。

コンポーネントのすべてのテストを実行する場合:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

単一のテストファイルを実行する場合:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### 直列でテストの実行

デフォルトでは、Action PackとAction Viewのユニットテストは並列で実行されます。ランダムなテストの失敗が発生している場合、ランダム化シードを設定し、これらのユニットテストを直列で実行するために`PARALLEL_WORKERS=1`を設定することができます。

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Active Recordのテスト

まず、必要なデータベースを作成します。必要なテーブル名、ユーザー名、パスワードのリストは、`activerecord/test/config.example.yml`に記載されています。

MySQLとPostgreSQLの場合は、次のコマンドを実行するだけで十分です:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

または:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

SQLite3の場合はこれは必要ありません。

次に、SQLite3のActive Recordテストスイートのみを実行する方法です:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

これで、`sqlite3`の場合と同様にテストを実行できます。それぞれのタスクは次のとおりです:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

最後に、

```bash
$ bundle exec rake test
```

これで、それらのテストを順番に実行します。

単一のテストを個別に実行することもできます:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

すべてのアダプタに対して単一のテストを実行するには、次のコマンドを使用します:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

`test_jdbcmysql`、`test_jdbcsqlite3`、または`test_jdbcpostgresql`も使用できます。よりターゲットを絞ったデータベーステストの実行方法については、`activerecord/RUNNING_UNIT_TESTS.rdoc`ファイルを参照してください。

#### テストでデバッガを使用する

外部のデバッガ（pry、byebugなど）を使用するには、デバッガをインストールし、通常どおり使用します。デバッガの問題が発生した場合は、`PARALLEL_WORKERS=1`を設定してテストを直列で実行するか、`-n test_long_test_name`を使用して単一のテストを実行します。

### 警告

テストスイートは警告が有効になって実行されます。理想的には、Ruby on Railsは警告を発生させないはずですが、いくつかの警告が発生する場合や、サードパーティのライブラリから警告が発生する場合があります。それらを無視（または修正）してください。新しい警告を発生させないパッチを提出してください。
Rails CIは、警告が導入された場合にエラーを発生させます。同じ動作をローカルで実装するには、テストスイートを実行する際に`RAILS_STRICT_WARNINGS=1`を設定してください。

### ドキュメントの更新

Ruby on Railsの[ガイド](https://guides.rubyonrails.org/)は、Railsの機能の概要を提供しています。一方、[APIドキュメント](https://api.rubyonrails.org/)は具体的な内容について詳しく説明しています。

もしPRが新しい機能を追加したり、既存の機能の動作を変更したりする場合は、関連するドキュメントを確認し、必要に応じて更新または追加してください。

例えば、Active Storageの画像解析機能を変更して新しいメタデータフィールドを追加した場合、Active Storageガイドの[ファイルの解析](active_storage_overview.html#analyzing-files)セクションを更新して反映させる必要があります。

### CHANGELOGの更新

CHANGELOGは、各リリースの変更内容を記録する重要な部分です。

もし新しい機能を追加したり、機能の削除、非推奨通知の追加を行った場合は、変更したフレームワークのCHANGELOGの**一番上に**エントリを追加してください。リファクタリング、マイナーバグ修正、ドキュメントの変更などは通常CHANGELOGには含めません。

CHANGELOGのエントリは、変更内容を要約し、最後に著者の名前を記述する必要があります。必要に応じて複数行を使用することができ、4つのスペースでインデントされたコード例を添付することもできます。変更が特定の問題に関連している場合は、問題番号を添付する必要があります。以下にCHANGELOGエントリの例を示します。

```
*   変更内容を簡潔に説明する変更の要約。複数行を使用し、80文字程度で折り返すことができます。必要に応じてコード例も使用できます:

        class Foo
          def bar
            puts 'baz'
          end
        end

    コード例の後に続けることができ、問題番号を添付することもできます。

    Fixes #1234.

    *Your Name*
```

コード例や複数の段落がない場合は、最後の単語の直後に名前を追加することができます。それ以外の場合は、新しい段落を作成するのが最適です。

### 互換性のない変更

既存のアプリケーションに影響を与える可能性のある変更は、互換性のない変更と見なされます。Railsアプリケーションのアップグレードを容易にするために、互換性のない変更には非推奨サイクルが必要です。

#### 挙動の削除

互換性のない変更が既存の挙動を削除する場合、既存の挙動を保持しながら非推奨の警告を追加する必要があります。

例えば、`ActiveRecord::Base`のパブリックメソッドを削除したいとします。もしメインブランチがリリースされていない7.0バージョンを指している場合、Rails 7.0は非推奨の警告を表示する必要があります。これにより、Rails 7.0のどのバージョンにアップグレードしても非推奨の警告が表示されることが保証されます。Rails 7.1では、メソッドを削除することができます。

以下の非推奨の警告を追加することができます。

```ruby
def deprecated_method
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.deprecated_method` is deprecated and will be removed in Rails 7.1.
  MSG
  # 既存の挙動
end
```

#### 挙動の変更

互換性のない変更が既存の挙動を変更する場合、フレームワークのデフォルトを追加する必要があります。フレームワークのデフォルトは、アプリケーションが新しいデフォルトに一つずつ切り替えることで、Railsのアップグレードを容易にします。

新しいフレームワークのデフォルトを実装するには、まず対象のフレームワークにアクセサを追加して設定を作成します。デフォルト値を既存の挙動に設定することで、アップグレード中に何も壊れないようにします。

```ruby
module ActiveJob
  mattr_accessor :existing_behavior, default: true
end
```

新しい設定により、条件に応じて新しい挙動を実装することができます。

```ruby
def changed_method
  if ActiveJob.existing_behavior
    # 既存の挙動
  else
    # 新しい挙動
  end
end
```

新しいフレームワークのデフォルトを設定するには、`Rails::Application::Configuration#load_defaults`で新しい値を設定します。

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

アップグレードを容易にするために、`new_framework_defaults`テンプレートに新しいデフォルトを追加する必要があります。新しい値を設定するコメントアウトされたセクションを追加してください。

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.existing_behavior = false
```

最後のステップとして、`configuration.md`の設定ガイドに新しい設定を追加します。

```markdown
#### `config.active_job.existing_behavior`

| バージョン | デフォルト値 |
| ---------- | ------------ |
| (元の値)   | `true`       |
| 7.1        | `false`      |
```

### エディタ/IDEが作成したファイルを無視する

一部のエディタやIDEは、`rails`フォルダ内に隠しファイルやフォルダを作成する場合があります。これらを各コミットから手動で除外するか、Railsの`.gitignore`に追加する代わりに、[グローバルgitignoreファイル](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)に追加することをおすすめします。

### Gemfile.lockの更新

一部の変更には依存関係のアップグレードが必要です。その場合は、正しいバージョンの依存関係を取得するために`bundle update`を実行し、変更とともに`Gemfile.lock`ファイルをコミットしてください。
### 変更をコミットする

コンピュータ上のコードに満足したら、変更をGitにコミットする必要があります。

```bash
$ git commit -a
```

これにより、コミットメッセージを書くためにエディタが起動します。終了したら、保存して閉じて続行します。

整形された説明的なコミットメッセージは、他の人が変更がなぜ行われたのかを理解するのに非常に役立ちますので、書くために時間をかけてください。

良いコミットメッセージは以下のようになります。

```
短い要約（理想的には50文字以下）

必要に応じて、より詳細な説明を記述します。各行は72文字で折り返します。
できるだけ説明的にしてください。コミットの内容が明らかだと思っていても、
他の人には明らかではないかもしれません。関連する問題に既に存在する
説明を追加してください。履歴を確認するためにウェブページを訪れる必要はありません。

説明セクションには複数の段落を含めることができます。

コードの例は、4つのスペースでインデントすることで埋め込むことができます。

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

また、箇条書きも追加できます。

- ダッシュ（-）またはアスタリスク（*）で行を始めることで、箇条書きを作成します。

- 72文字で行を折り返し、可読性のために追加の行は2つのスペースでインデントします。
```

TIP. 適切な場合は、コミットを1つにまとめてください。これにより、将来のチェリーピックが簡素化され、gitのログがきれいに保たれます。

### ブランチを更新する

作業中にmainに他の変更が行われた可能性が非常に高いです。mainに新しい変更を取得するには：

```bash
$ git checkout main
$ git pull --rebase
```

次に、最新の変更の上にパッチを再適用します：

```bash
$ git checkout my_new_branch
$ git rebase main
```

競合はありませんか？テストはまだパスしますか？変更はまだ合理的に見えますか？それなら、リベースされた変更をGitHubにプッシュしてください：

```bash
$ git push --force-with-lease
```

rails/railsリポジトリベースでは、強制プッシュは許可されていませんが、フォークには強制プッシュできます。リベースする場合、これは必須です。なぜなら、履歴が変更されたからです。

### フォーク

Railsの[GitHubリポジトリ](https://github.com/rails/rails)に移動し、右上隅の「Fork」をクリックします。

新しいリモートをローカルマシン上のローカルリポジトリに追加します：

```bash
$ git remote add fork https://github.com/<your username>/rails.git
```

ローカルリポジトリをrails/railsからクローンしたか、フォークしたリポジトリからクローンしたかによって、以下のgitコマンドは、rails/railsを指す「rails」という名前のリモートが作成されていることを前提としています。

```bash
$ git remote add rails https://github.com/rails/rails.git
```

公式リポジトリから新しいコミットとブランチをダウンロードします：

```bash
$ git fetch rails
```

新しいコンテンツをマージします：

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

フォークを更新します：

```bash
$ git push fork main
$ git push fork my_new_branch
```

### プルリクエストを作成する

作成したRailsリポジトリ（例：https://github.com/your-user-name/rails）に移動し、コードの上にある「Pull Requests」をクリックします。
次のページで、右上隅にある「New pull request」をクリックします。

プルリクエストは、ベースリポジトリが`rails/rails`であり、ブランチが`main`である必要があります。
ヘッドリポジトリはあなたの作業（`your-user-name/rails`）であり、ブランチは
作成したブランチの名前です。準備ができたら、「create pull request」をクリックします。

導入した変更セットが含まれていることを確認してください。プルリクエストテンプレートを使用して、パッチに関する詳細を入力します。完了したら、「Create pull request」をクリックします。

### フィードバックを受け取る

ほとんどのプルリクエストは、マージされる前に数回の反復を経ることになります。
異なる貢献者によって異なる意見があることがあり、
パッチを修正する必要があることがよくあります。

Railsのいくつかの貢献者は、GitHubからのメール通知をオンにしていますが、
他の人はしていません。さらに、Railsで作業する（ほぼ）すべての人は
ボランティアですので、プルリクエストに最初のフィードバックを得るまでには数日かかる場合があります。諦めないでください！時には速く、時には遅くなります。それがオープンソースの生活です。

1週間以上経っても何も聞こえてこない場合は、事態を進展させるために試みることができます。
これには、[rubyonrails-coreディスカッションボード](https://discuss.rubyonrails.org/c/rubyonrails-core)を使用できます。また、プルリクエストに別のコメントを残すこともできます。
フィードバックを待っている間に、他のいくつかのプルリクエストを開いて、他の人にフィードバックを提供しましょう！あなたがパッチのフィードバックを評価するのと同じように、他の人もそれを感謝するでしょう。

ただし、コードの変更をマージする権限は、CoreチームとCommittersチームにのみ与えられています。
誰かがフィードバックをしてあなたの変更を「承認」した場合、彼らにはマージする能力や最終的な判断権がないかもしれません。

### 必要に応じて反復する

フィードバックを受け取った場合、変更が提案される可能性があります。落胆しないでください：活発なオープンソースプロジェクトへの貢献の目的は、コミュニティの知識を活用することです。人々があなたのコードを微調整するように勧めるなら、それは微調整して再提出する価値があります。もしフィードバックがあなたのコードがマージされないというものであれば、それをジェムとしてリリースすることを考える価値があります。

#### コミットの統合

私たちがお願いすることの一つは、「コミットを統合する」ということです。これにより、すべてのコミットが1つのコミットに統合されます。私たちは、1つのコミットであるプルリクエストを好みます。これにより、安定したブランチへの変更のバックポートが容易になり、悪いコミットを元に戻すことが容易になり、gitの履歴を追いやすくなります。Railsは大規模なプロジェクトであり、不要なコミットが多くのノイズを生む可能性があります。

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< 最初のコミット以外のすべてのコミットについて 'squash' を選択します。 >
< コミットメッセージを編集して意味を持たせ、すべての変更を説明します。 >

$ git push fork my_new_branch --force-with-lease
```

GitHub上でプルリクエストを更新したことが確認できるはずです。

#### プルリクエストの更新

既にコミットしたコードにいくつかの変更を加えるように求められることがあります。これには既存のコミットの修正も含まれます。この場合、Gitは変更をプッシュできないため、プッシュされたブランチとローカルブランチが一致しないためです。新しいプルリクエストを開く代わりに、先ほど説明したように強制プッシュしてGitHubのブランチに強制的にプッシュすることができます。

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

これにより、新しいコードでブランチとプルリクエストがGitHub上で更新されます。
`--force-with-lease`を使用して強制プッシュすることで、typicalな`-f`よりもgitはリモートをより安全に更新します。これにより、既に持っていないリモートの作業を削除することができます。

### 古いバージョンのRuby on Rails

次のリリースよりも古いバージョンのRuby on Railsに修正を追加したい場合は、独自のローカルトラッキングブランチを設定して切り替える必要があります。以下は、7-0-stableブランチに切り替える例です。

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

注意：古いバージョンで作業する前に、[メンテナンスポリシー](maintenance_policy.html)を確認してください。寿命が切れたバージョンには変更は受け入れられません。

#### バックポート

mainにマージされた変更は、Railsの次のメジャーリリースを目指しています。時には、メンテナンスリリースに含めるために安定したブランチに変更を伝播させることが有益な場合もあります。一般的に、セキュリティ修正やバグ修正はバックポートの候補ですが、新機能や期待される動作を変更するパッチは受け入れられません。迷った場合は、無駄な努力を避けるためにRailsチームのメンバーに相談することが最善です。

まず、mainブランチが最新であることを確認してください。

```bash
$ git checkout main
$ git pull --rebase
```

バックポートするブランチにチェックアウトし、最新であることを確認してください。例えば、`7-0-stable`にチェックアウトする場合は次のようにします。

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

マージされたプルリクエストをバックポートする場合は、マージのためのコミットを見つけてcherry-pickします。

```bash
$ git cherry-pick -m1 MERGE_SHA
```

cherry-pickで発生した競合を修正し、変更をプッシュし、バックポート先の安定したブランチを指すPRを開いてください。より複雑な変更セットがある場合は、[cherry-pick](https://git-scm.com/docs/git-cherry-pick)のドキュメントが役立ちます。

Railsの貢献者
------------------

すべての貢献者は[Rails Contributors](https://contributors.rubyonrails.org)でクレジットを受けます。
