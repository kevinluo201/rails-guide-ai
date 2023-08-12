**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Ruby on Railsガイドライン
===============================

このガイドでは、Ruby on Railsガイドの作成に関するガイドラインについて説明します。このガイドは、自己を例として優雅なループで続きます。

このガイドを読み終えると、以下のことがわかります。

* Railsドキュメントで使用する規約について
* ローカルでガイドを生成する方法

--------------------------------------------------------------------------------

Markdown
-------

ガイドは、[GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown)で書かれています。[Markdownの詳しいドキュメント](https://daringfireball.net/projects/markdown/syntax)や[チートシート](https://daringfireball.net/projects/markdown/basics)もあります。

プロローグ
--------

各ガイドは、上部のモチベーションテキストで始まるべきです（それは青い領域の小さな紹介です）。プロローグは、ガイドの内容と読者が何を学ぶかを伝えるべきです。例として、[ルーティングガイド](routing.html)を参照してください。

見出し
------

各ガイドのタイトルは`h1`見出しを使用し、ガイドのセクションは`h2`見出しを使用し、サブセクションは`h3`見出しを使用します。なお、生成されるHTMLの出力は`<h2>`から始まる見出しタグを使用します。

```markdown
ガイドのタイトル
===========

セクション
-------

### サブセクション
```

見出しを書く際には、前置詞、接続詞、内部の冠詞、および動詞「to be」の形を除いて、すべての単語を大文字にします。

```markdown
#### Assertions and Testing Jobs inside Components
#### Middleware Stack is an Array
#### When are Objects Saved?
```

通常のテキストと同じインラインの書式を使用します。

```markdown
##### The `:content_type` Option
```

APIへのリンク
------------------

API（`api.rubyonrails.org`）へのリンクは、ガイドジェネレータによって以下のように処理されます。

リリースタグを含むリンクはそのままになります。例えば

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

は変更されません。

リリースノートでは、対応するバージョンを指す必要があるため、これらを使用してください。

リンクにリリースタグが含まれておらず、エッジガイドが生成されている場合、ドメインは`edgeapi.rubyonrails.org`に置き換えられます。例えば、

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

は

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

になります。

リンクにリリースタグが含まれておらず、リリースガイドが生成されている場合、Railsのバージョンが挿入されます。例えば、v5.1.0のガイドを生成している場合、リンク

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

は

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

になります。

手動で`edgeapi.rubyonrails.org`にリンクしないでください。


APIドキュメントのガイドライン
----------------------------

ガイドとAPIは、適切な場所で一貫性があるべきです。特に、[APIドキュメントのガイドライン](api_documentation_guidelines.html)の次のセクションもガイドに適用されます。

* [Wording](api_documentation_guidelines.html#wording)
* [English](api_documentation_guidelines.html#english)
* [Example Code](api_documentation_guidelines.html#example-code)
* [Filenames](api_documentation_guidelines.html#file-names)
* [Fonts](api_documentation_guidelines.html#fonts)

HTMLガイド
-----------

ガイドを生成する前に、システムに最新バージョンのBundlerがインストールされていることを確認してください。最新バージョンのBundlerをインストールするには、`gem install bundler`を実行します。

すでにBundlerがインストールされている場合は、`gem update bundler`で更新できます。

### 生成

すべてのガイドを生成するには、`guides`ディレクトリに移動し、`bundle install`を実行してから次のコマンドを実行します。

```bash
$ bundle exec rake guides:generate
```

または

```bash
$ bundle exec rake guides:generate:html
```

生成されたHTMLファイルは`./output`ディレクトリにあります。

`my_guide.md`のみを処理する場合は、`ONLY`環境変数を使用します。

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

デフォルトでは、変更されていないガイドは処理されないため、`ONLY`は実際にはほとんど必要ありません。

すべてのガイドを強制的に処理するには、`ALL=1`を渡します。

英語以外の言語でガイドを生成したい場合は、`source`ディレクトリの下に別のディレクトリ（例：`source/es`）を作成し、`GUIDES_LANGUAGE`環境変数を使用します。

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

生成スクリプトを設定するために使用できるすべての環境変数を表示するには、次のコマンドを実行します。

```bash
$ rake
```

### 検証

生成されたHTMLを次のコマンドで検証してください。

```bash
$ bundle exec rake guides:validate
```

特に、タイトルはその内容から生成されたIDを持つため、重複することがよくあります。

Kindleガイド
-------------

### 生成

Kindle用のガイドを生成するには、次のrakeタスクを使用します。

```bash
$ bundle exec rake guides:generate:kindle
```
