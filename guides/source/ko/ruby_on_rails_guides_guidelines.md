**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Ruby on Rails 가이드 지침
===============================

이 가이드는 Ruby on Rails 가이드를 작성하는 데 사용되는 지침을 문서화합니다. 이 가이드는 자체를 우아한 루프로 따라가며, 자체를 예로 제공합니다.

이 가이드를 읽은 후에는 다음을 알게됩니다:

* Rails 문서에서 사용할 규칙에 대해 알아보기
* 로컬에서 가이드를 생성하는 방법

--------------------------------------------------------------------------------

마크다운
-------

가이드는 [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown)으로 작성됩니다. [마크다운에 대한 포괄적인 문서](https://daringfireball.net/projects/markdown/syntax)와 [치트시트](https://daringfireball.net/projects/markdown/basics)가 있습니다.

서문
--------

각 가이드는 맨 위에 동기 부여 텍스트로 시작해야 합니다 (파란 영역에 있는 작은 소개입니다). 서문은 가이드가 무엇에 대한 것인지와 독자가 무엇을 배울 수 있는지 알려주어야 합니다. 예를 들어 [라우팅 가이드](routing.html)를 참조하십시오.

제목
------

모든 가이드의 제목은 `h1` 제목을 사용하며, 가이드 섹션은 `h2` 제목을 사용하고, 하위 섹션은 `h3` 제목을 사용합니다. 생성된 HTML 출력은 `<h2>`로 시작하는 제목 태그를 사용합니다.

```markdown
가이드 제목
===========

섹션
-------

### 하위 섹션
```

제목을 작성할 때, 전치사, 접속사, 내부 기사 및 "to be" 동사의 형태를 제외한 모든 단어를 대문자로 씁니다.

```markdown
#### Assertions and Testing Jobs inside Components
#### Middleware Stack is an Array
#### When are Objects Saved?
```

일반 텍스트와 동일한 인라인 서식을 사용합니다.

```markdown
##### The `:content_type` Option
```

API에 링크하기
------------------

API (`api.rubyonrails.org`)에 대한 링크는 가이드 생성기에서 다음과 같이 처리됩니다.

릴리스 태그를 포함하는 링크는 그대로 유지됩니다. 예를 들어

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

는 수정되지 않습니다.

릴리스 노트에서는 해당 버전을 가리키도록 해야 하므로 이러한 링크를 사용하십시오.

링크에 릴리스 태그가 포함되지 않고 엣지 가이드가 생성되는 경우, 도메인은 `edgeapi.rubyonrails.org`로 대체됩니다. 예를 들어,

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

는

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

로 변환됩니다.

링크에 릴리스 태그가 포함되지 않고 릴리스 가이드가 생성되는 경우, Rails 버전이 주입됩니다. 예를 들어, v5.1.0의 가이드를 생성하는 경우 링크

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

는

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

로 변환됩니다.

수동으로 `edgeapi.rubyonrails.org`에 링크하지 마십시오.


API 문서 지침
----------------------------

가이드와 API는 적절한 경우 일관성을 유지해야 합니다. 특히, [API 문서 지침](api_documentation_guidelines.html)의 다음 섹션도 가이드에 적용됩니다:

* [Wording](api_documentation_guidelines.html#wording)
* [English](api_documentation_guidelines.html#english)
* [Example Code](api_documentation_guidelines.html#example-code)
* [Filenames](api_documentation_guidelines.html#file-names)
* [Fonts](api_documentation_guidelines.html#fonts)

HTML 가이드
-----------

가이드를 생성하기 전에 시스템에 최신 버전의 Bundler가 설치되어 있는지 확인하십시오. 최신 버전의 Bundler를 설치하려면 `gem install bundler`를 실행하십시오.

이미 Bundler가 설치되어 있는 경우 `gem update bundler`로 업데이트할 수 있습니다.

### 생성

모든 가이드를 생성하려면 `guides` 디렉토리로 이동한 후 `bundle install`을 실행하고 다음을 실행하십시오:

```bash
$ bundle exec rake guides:generate
```

또는

```bash
$ bundle exec rake guides:generate:html
```

생성된 HTML 파일은 `./output` 디렉토리에서 찾을 수 있습니다.

`my_guide.md`만 처리하려면 `ONLY` 환경 변수를 사용하십시오:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

기본적으로 수정되지 않은 가이드는 처리되지 않으므로 실제로는 `ONLY`가 거의 필요하지 않습니다.

모든 가이드를 강제로 처리하려면 `ALL=1`을 전달하십시오.

영어 이외의 다른 언어로 가이드를 생성하려면 `source` 디렉토리 아래에 별도의 디렉토리 (예: `source/es`)에 보관하고 `GUIDES_LANGUAGE` 환경 변수를 사용하십시오:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

생성 스크립트를 구성하는 데 사용할 수 있는 모든 환경 변수를 보려면 다음을 실행하십시오:

```bash
$ rake
```

### 유효성 검사

생성된 HTML을 다음과 같이 유효성을 검사하십시오:

```bash
$ bundle exec rake guides:validate
```

특히, 제목은 내용에서 생성된 ID를 가지며, 이로 인해 종종 중복이 발생합니다.

Kindle 가이드
-------------

### 생성

Kindle용 가이드를 생성하려면 다음 rake 작업을 사용하십시오:

```bash
$ bundle exec rake guides:generate:kindle
```
