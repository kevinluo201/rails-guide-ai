**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
루비 온 레일즈에 기여하기
=============================

이 가이드는 루비 온 레일즈의 지속적인 개발에 참여하는 방법을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 될 것입니다:

* GitHub를 사용하여 문제를 보고하는 방법.
* 메인을 복제하고 테스트 스위트를 실행하는 방법.
* 기존 문제를 해결하는 방법.
* 루비 온 레일즈 문서에 기여하는 방법.
* 루비 온 레일즈 코드에 기여하는 방법.

루비 온 레일즈는 "다른 사람의 프레임워크"가 아닙니다. 수년 동안 수천 명의 사람들이 루비 온 레일즈에 기여했으며, 단일 문자에서 대규모 아키텍처 변경 또는 중요한 문서 작성까지 다양한 방법으로 루비 온 레일즈를 모두에게 더 좋게 만들기 위해 기여했습니다. 코드나 문서 작성에 자신감이 없더라도, 문제 보고서 작성부터 패치 테스트까지 다양한 방법으로 기여할 수 있습니다.

[Rails의 README](https://github.com/rails/rails/blob/main/README.md)에서 언급한 대로, Rails와 그 하위 프로젝트의 코드베이스, 이슈 트래커, 채팅방, 토론 게시판 및 메일링 리스트에 참여하는 모든 사람들은 Rails [행동 강령](https://rubyonrails.org/conduct)을 따를 것으로 예상됩니다.

--------------------------------------------------------------------------------

문제 보고하기
------------------

루비 온 레일즈는 문제(주로 버그 및 새로운 코드 기여)를 추적하기 위해 [GitHub 이슈 트래킹](https://github.com/rails/rails/issues)을 사용합니다. 루비 온 레일즈에서 버그를 발견한 경우, 이곳에서 시작해야 합니다. 문제를 제출하거나 문제에 대해 의견을 남기거나 풀 리퀘스트를 생성하려면 (무료) GitHub 계정을 만들어야 합니다.

참고: 가장 최근에 릴리스된 버전의 루비 온 레일즈에서 발생한 버그가 가장 많은 관심을 받을 것입니다. 또한, Rails 코어 팀은 항상 개발 중인 Rails 버전의 코드인 엣지 Rails를 테스트할 시간을 할애할 수 있는 사람들의 피드백에 관심이 있습니다. 이 가이드의 후반부에서 테스트를 위해 엣지 Rails를 어떻게 가져올 수 있는지 알아볼 수 있습니다. 지원되는 버전에 대한 정보는 [유지 보수 정책](maintenance_policy.html)을 참조하십시오. 보안 문제는 GitHub 이슈 트래커에 보고하지 마십시오.

### 버그 보고서 작성

루비 온 레일즈에서 보안 위험이 아닌 문제를 발견한 경우, 이미 보고된 문제가 있는지 확인하기 위해 GitHub의 [이슈](https://github.com/rails/rails/issues)를 검색하십시오. 발견한 문제를 해결하는 데 관련된 열린 GitHub 이슈를 찾을 수 없는 경우, 다음 단계는 [새로운 이슈를 열어](https://github.com/rails/rails/issues/new)야 합니다. (보안 문제에 대한 보고는 다음 섹션을 참조하십시오.)

문제가 있는지 여부를 판단하기 위해 프레임워크에 버그가 있는지 여부를 결정하기 위해 필요한 모든 정보를 포함하여 이슈 템플릿을 제공했습니다. 각 이슈는 제목과 문제에 대한 명확한 설명을 포함해야 합니다. 예상 동작을 보여주는 코드 샘플이나 실패하는 테스트와 함께 시스템 구성을 포함하여 가능한 관련 정보를 모두 포함하도록 해야 합니다. 버그를 재현하고 수정 방법을 찾기 쉽게 만드는 것이 목표입니다.

이슈를 열면 "코드 레드, 미션 크리티컬, 세상이 끝나는 중"과 같은 버그가 아니라면 바로 활동을 보지 못할 수도 있습니다. 이는 당신의 버그에 관심이 없다는 것을 의미하지 않습니다. 그저 많은 이슈와 풀 리퀘스트를 처리해야 할 뿐입니다. 같은 문제를 가진 다른 사람들은 당신의 이슈를 찾아볼 수 있고, 버그를 확인하고 수정하는 데 협력할 수 있습니다. 버그를 수정하는 방법을 알고 있다면 풀 리퀘스트를 열어 진행하십시오.

### 실행 가능한 테스트 케이스 생성

문제를 재현할 수 있는 방법이 있다면, 사람들이 문제를 확인하고 조사하며 최종적으로 문제를 해결할 수 있습니다. 이를 위해 실행 가능한 테스트 케이스를 제공할 수 있습니다. 이를 위해 시작점으로 사용할 수 있는 여러 버그 보고서 템플릿을 준비했습니다:

* Active Record(모델, 데이터베이스) 문제에 대한 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Active Record(마이그레이션) 문제에 대한 테스트 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Action Pack(컨트롤러, 라우팅) 문제에 대한 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Active Job 문제에 대한 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Active Storage 문제에 대한 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Action Mailbox 문제에 대한 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* 기타 문제에 대한 일반적인 템플릿: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

이러한 템플릿에는 릴리스된 버전의 Rails(`*_gem.rb`) 또는 엣지 Rails(`*_main.rb`)에 대한 테스트 케이스를 설정하기 위한 보일러플레이트 코드가 포함되어 있습니다.
`.rb` 파일로 적절한 템플릿의 내용을 복사하고 문제를 보여주기 위해 필요한 변경을 가하십시오. 터미널에서 `ruby the_file.rb`를 실행하여 실행할 수 있습니다. 모든 것이 잘 진행되면 테스트 케이스가 실패하는 것을 볼 수 있어야 합니다.

그런 다음 실행 가능한 테스트 케이스를 [gist](https://gist.github.com)로 공유하거나 내용을 이슈 설명에 붙여넣을 수 있습니다.

### 보안 문제에 대한 특별한 처리

경고: 보안 취약점을 공개 GitHub 이슈 보고서로 보고하지 마십시오. [Rails 보안 정책 페이지](https://rubyonrails.org/security)에는 보안 문제에 대한 절차가 자세히 설명되어 있습니다.

### 기능 요청은 어떻게 되나요?

기능 요청 항목을 GitHub 이슈에 넣지 마십시오. Ruby on Rails에 추가하고자 하는 새로운 기능이 있다면, 코드를 직접 작성하거나 다른 사람과 함께 코드를 작성하도록 설득해야 합니다. 이 가이드의 나중 부분에서는 Ruby on Rails에 패치를 제안하는 방법에 대한 자세한 지침을 찾을 수 있습니다. 코드가 없는 위시 리스트 항목을 GitHub 이슈에 입력하면 검토가 완료되는 즉시 "유효하지 않음"으로 표시될 것입니다.

때로는 '버그'와 '기능' 사이의 경계를 그리는 것이 어려울 수 있습니다. 일반적으로 기능은 새로운 동작을 추가하는 것이고, 버그는 잘못된 동작을 일으키는 것입니다. 때로는 코어 팀이 판단을 내려야 할 수도 있습니다. 그렇지만 일반적으로 이 구분은 변경 사항이 릴리스되는 패치를 결정합니다. 우리는 기능 제출을 사랑합니다! 그러나 유지 보수 브랜치로 다시 포트되지는 않습니다.

패치를 만들기 전에 기능에 대한 아이디어에 대한 피드백을 받고 싶다면 [rails-core 토론 게시판](https://discuss.rubyonrails.org/c/rubyonrails-core)에서 토론을 시작하십시오. 아무런 응답이 없을 수도 있으며, 이는 모두 무관심함을 의미합니다. 해당 기능을 구축하려는 다른 사람을 찾을 수도 있습니다. "이는 승인되지 않을 것입니다"라는 응답을 받을 수도 있습니다. 그러나 새로운 아이디어를 논의하기에 적절한 장소입니다. GitHub 이슈는 때로는 길고 복잡한 토론에 적합한 장소가 아닙니다.


기존 문제 해결에 도움을 주기
----------------------------------

문제를 보고하는 것 외에도, 핵심 팀이 기존 문제를 해결하는 데 도움을 주는 것도 가능합니다. Rails 코어 개발에 처음 참여하는 경우, 피드백을 제공하면 코드베이스와 프로세스에 익숙해지는 데 도움이 됩니다.

GitHub 이슈의 [문제 목록](https://github.com/rails/rails/issues)을 확인하면 이미 처리해야 할 많은 문제가 있습니다. 이에 대해 어떻게 할 수 있을까요? 실제로 많은 일을 할 수 있습니다:

### 버그 보고서 확인

먼저, 버그 보고서를 확인하는 것이 도움이 됩니다. 보고된 문제를 컴퓨터에서 재현할 수 있습니까? 그렇다면, 동일한 문제를 보고서에 댓글로 추가할 수 있습니다.

문제가 매우 모호한 경우, 더 구체적인 사항으로 좁히는 데 도움이 될 수 있습니까? 버그를 재현하기 위해 추가 정보를 제공하거나 문제를 나타내는 데 필요하지 않은 불필요한 단계를 제거할 수 있을지도 모릅니다.

테스트가 없는 버그 보고서를 찾으면 실패하는 테스트를 기여하는 것이 매우 유용합니다. 이는 소스 코드를 탐색하는 좋은 방법입니다. 기존의 테스트 파일을 살펴보면 어떻게 더 많은 테스트를 작성할 수 있는지 알 수 있습니다. 새로운 테스트는 [Ruby on Rails에 기여하는 방법](#contributing-to-the-rails-code) 섹션에서 설명된 대로 패치 형식으로 기여하는 것이 가장 좋습니다.

버그 보고서를 더 간결하게하거나 재현하기 쉽게하는 데 도움이 되는 모든 것은 해당 버그를 수정하기 위해 코드를 작성하든 그렇지 않든 도움이 됩니다.

### 패치 테스트

GitHub를 통해 Ruby on Rails에 제출된 풀 리퀘스트를 검토하여 도움을 줄 수도 있습니다. 다른 사람의 변경 사항을 적용하려면 먼저 전용 브랜치를 만듭니다.

```bash
$ git checkout -b testing_branch
```

그런 다음, 그들의 원격 브랜치를 사용하여 코드베이스를 업데이트할 수 있습니다. 예를 들어, GitHub 사용자 JohnSmith가 포크하고 "orange"라는 주제 브랜치를 https://github.com/JohnSmith/rails에 푸시했다고 가정해 봅시다.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

체크아웃에 그들의 원격을 추가하는 대신 [GitHub CLI 도구](https://cli.github.com/)를 사용하여 그들의 풀 리퀘스트를 체크아웃하는 것도 대안입니다.

그들의 브랜치를 적용한 후에 테스트해 보세요! 다음 사항을 생각해 볼만한 몇 가지 사항입니다:
* 변경 사항이 실제로 작동합니까?
* 테스트에 만족하십니까? 테스트가 무엇을 테스트하는지 이해할 수 있습니까? 누락된 테스트가 있습니까?
* 적절한 문서 커버리지가 있습니까? 다른 곳의 문서를 업데이트해야합니까?
* 구현을 좋아합니까? 변경 사항의 일부를 더 좋거나 빠르게 구현할 수 있는 방법을 생각할 수 있습니까?

풀 리퀘스트에 좋은 변경 사항이 포함되어 있는지 확인한 후 GitHub 이슈에 대한 의견을 남기십시오. 의견은 변경 사항을 좋아하고 그에 대해 좋아하는 내용을 나타내어야 합니다. 다음과 같은 내용으로:

> generate_finder_sql에서 코드를 재구성한 방식이 매우 좋습니다. 테스트도 좋아보입니다.

"+1"로만 읽힌다면 다른 리뷰어들이 그것을 심각하게 받아들이지 않을 가능성이 높습니다. 리뷰하는 데 시간을 들였다는 것을 보여주세요.

Rails 문서에 기여하기
---------------------------------------

Ruby on Rails에는 두 가지 주요 문서 세트가 있습니다. Ruby on Rails에 대해 배우는 데 도움이 되는 가이드와 참조로 사용되는 API입니다.

Ruby on Rails 가이드 또는 API 참조를 개선하여 더 일관되고 읽기 쉽고 누락된 정보를 추가하거나 사실적인 오류를 수정하거나 오타를 수정하거나 최신 엣지 Rails와 최신 상태로 업데이트하는 데 도움을 줄 수 있습니다.

이를 위해 Rails 가이드 소스 파일(https://github.com/rails/rails/tree/main/guides/source) 또는 소스 코드의 RDoc 주석을 변경하십시오. 그런 다음 변경 사항을 메인 브랜치에 적용하기 위해 풀 리퀘스트를 엽니다.

문서 작업을 할 때는 API 문서 지침(api_documentation_guidelines.html)과 Ruby on Rails 가이드 지침(ruby_on_rails_guides_guidelines.html)을 고려해주십시오.

Rails 가이드 번역하기
------------------------

Rails 가이드를 번역하려는 사람들의 참여를 환영합니다. 다음 단계를 따르세요:

* https://github.com/rails/rails를 포크합니다.
* 언어에 대한 소스 폴더를 추가합니다. 예를 들어, 이탈리아어의 경우 *guides/source/it-IT*와 같이 합니다.
* *guides/source*의 내용을 언어 디렉토리로 복사하고 번역합니다.
* HTML 파일은 자동으로 생성되므로 번역하지 마십시오.

번역은 Rails 저장소에 제출되지 않습니다. 작업은 위에서 설명한 대로 포크된 저장소에서 이루어집니다. 이는 실제로 영어로만 문서 유지 관리가 가능하기 때문입니다.

HTML 형식의 가이드를 생성하려면 가이드 종속성을 설치해야 합니다. *guides* 디렉토리로 이동한 다음 (예: it-IT의 경우) 다음을 실행합니다.

```bash
# 가이드에 필요한 젬만 설치합니다. 취소하려면 다음을 실행합니다: bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

이렇게 하면 *output* 디렉토리에 가이드가 생성됩니다.

참고: Redcarpet 젬은 JRuby에서 작동하지 않습니다.

알려진 번역 작업 (다양한 버전):

* **이탈리아어**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **스페인어**: [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **폴란드어**: [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **프랑스어**: [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **체코어**: [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **터키어**: [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **한국어**: [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **중국어 간체**: [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **중국어 번체**: [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **러시아어**: [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **일본어**: [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **브라질 포르투갈어**: [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Rails 코드에 기여하기
------------------------------

### 개발 환경 설정

버그를 제출하는 것에서 기존 문제를 해결하거나 Ruby on Rails에 자체 코드를 기여하기 위해선 컴퓨터에서 테스트 스위트를 실행할 수 있어야 합니다. 이 가이드의 이 부분에서는 컴퓨터에서 테스트를 설정하는 방법을 배우게 됩니다.

#### GitHub Codespaces 사용

Codespaces가 활성화된 조직의 구성원인 경우, Rails를 해당 조직으로 포크하고 GitHub에서 Codespaces를 사용할 수 있습니다. Codespace는 필요한 모든 종속성으로 초기화되며 모든 테스트를 실행할 수 있습니다.

#### VS Code Remote Containers 사용

[Visual Studio Code](https://code.visualstudio.com)와 [Docker](https://www.docker.com)가 설치된 경우, [VS Code Remote Containers 플러그인](https://code.visualstudio.com/docs/remote/containers-tutorial)을 사용할 수 있습니다. 이 플러그인은 저장소의 [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) 구성을 읽고 Docker 컨테이너를 로컬로 빌드합니다.

#### Dev Container CLI 사용

또는 [Docker](https://www.docker.com)와 [npm](https://github.com/npm/cli)이 설치된 경우, [Dev Container CLI](https://github.com/devcontainers/cli)를 실행하여 명령줄에서 [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) 구성을 활용할 수 있습니다.

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### rails-dev-box 사용

[rails-dev-box](https://github.com/rails/rails-dev-box)를 사용하여 개발 환경을 준비할 수도 있습니다. 그러나 rails-dev-box는 Vagrant와 Virtual Box를 사용하므로 Apple 실리콘을 사용하는 Mac에서는 작동하지 않습니다.
#### 로컬 개발

GitHub Codespaces를 사용할 수 없는 경우 로컬 개발 환경을 설정하는 방법에 대한 [다른 가이드](development_dependencies_install.html)를 참조하십시오. 이는 종속성을 설치하는 것이 OS에 따라 다를 수 있기 때문에 어려운 방법으로 간주됩니다.

### Rails 저장소 복제

코드를 기여하기 위해 Rails 저장소를 복제해야 합니다:

```bash
$ git clone https://github.com/rails/rails.git
```

그리고 전용 브랜치를 생성합니다:

```bash
$ cd rails
$ git checkout -b my_new_branch
```

사용하는 이름은 크게 중요하지 않습니다. 이 브랜치는 로컬 컴퓨터와 GitHub의 개인 저장소에서만 존재하며 Rails Git 저장소의 일부가 되지 않습니다.

### Bundle 설치

필요한 젬을 설치합니다.

```bash
$ bundle install
```

### 로컬 브랜치에 대한 애플리케이션 실행

변경 사항을 테스트하기 위해 더미 Rails 앱이 필요한 경우 `rails new`의 `--dev` 플래그를 사용하여 로컬 브랜치를 사용하는 애플리케이션을 생성할 수 있습니다:

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

`~/my-test-app`에 생성된 애플리케이션은 로컬 브랜치를 사용하며, 특히 서버 재부팅 시에 변경 사항을 볼 수 있습니다.

JavaScript 패키지의 경우 생성된 애플리케이션에서 로컬 브랜치를 소스로 사용하기 위해 [`yarn link`](https://yarnpkg.com/cli/link)를 사용할 수 있습니다:

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### 코드 작성

이제 코드를 작성할 시간입니다! Rails에 변경 사항을 가할 때 다음 사항을 염두에 두십시오:

* Rails 스타일과 규칙을 따르십시오.
* Rails 관용구와 도우미를 사용하십시오.
* 코드 없이 실패하고 코드와 함께 통과하는 테스트를 포함하십시오.
* 기여에 영향을 받는 문서, 다른 예제 및 가이드를 업데이트하십시오.
* 변경 사항이 기능을 추가, 제거 또는 변경하는 경우 CHANGELOG 항목을 포함하십시오. 변경 사항이 버그 수정인 경우 CHANGELOG 항목은 필요하지 않습니다.

팁: Rails의 안정성, 기능 또는 테스트 가능성에 실질적인 기여를 추가하지 않는 시각적인 변경 사항은 일반적으로 허용되지 않습니다(이 결정에 대한 [이유에 대해 자세히 읽어보세요](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### 코딩 규칙 따르기

Rails는 간단한 코딩 스타일 규칙을 따릅니다:

* 들여쓰기에는 탭 대신 두 개의 공백을 사용합니다.
* 뒤에 공백이 없어야 합니다. 빈 줄에는 공백이 없어야 합니다.
* private/protected 이후에는 들여쓰기와 빈 줄이 없어야 합니다.
* 해시에 대해 Ruby >= 1.9 구문을 사용하십시오. `{ :a => :b }`보다는 `{ a: :b }`를 선호합니다.
* `and`/`or` 대신에 `&&`/`||`를 선호합니다.
* 클래스 메서드에는 `self.method` 대신 `class << self`를 사용하십시오.
* `my_method( my_arg )` 또는 `my_method my_arg` 대신 `my_method(my_arg)`를 사용하십시오.
* `a=b` 대신 `a = b`를 사용하십시오.
* `refute` 대신 `assert_not` 메서드를 사용하십시오.
* 한 줄 블록에는 `method{do_stuff}` 대신 `method { do_stuff }`를 사용하십시오.
* 이미 사용된 소스의 규칙을 따르십시오.

위는 지침입니다 - 이를 사용하는 데 가장 적절한 판단을 사용하십시오.

또한, 일부 코딩 규칙을 명시화하기 위해 [RuboCop](https://www.rubocop.org/) 규칙을 정의했습니다. 풀 리퀘스트를 제출하기 전에 수정한 파일에 대해 RuboCop을 로컬에서 실행할 수 있습니다:

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

`rails-ujs` CoffeeScript 및 JavaScript 파일의 경우 `actionview` 폴더에서 `npm run lint`를 실행할 수 있습니다.

#### 스펠 체크

우리는 주로 [Golang](https://golang.org/)로 작성된 [misspell](https://github.com/client9/misspell)을 사용하여 [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml)에서 철자를 확인합니다. `misspell`을 사용하여 일반적으로 철자가 틀린 영어 단어를 빠르게 수정할 수 있습니다. `misspell`은 사용자 정의 사전을 사용하지 않기 때문에 다른 대부분의 철자 검사기와 다릅니다. 모든 파일에 대해 로컬에서 `misspell`을 실행할 수 있습니다:

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

주요 `misspell` 도움말 옵션 또는 플래그는 다음과 같습니다:

- `-i` 문자열: 다음 수정 사항을 무시, 쉼표로 구분
- `-w`: 수정으로 파일 덮어쓰기 (기본적으로 표시만 함)

또한, 우리는 철자를 확인하기 위해 [codespell](https://github.com/codespell-project/codespell)을 GitHub Actions에서 실행하며, [codespell](https://pypi.org/project/codespell/)은 [작은 사용자 정의 사전](https://github.com/rails/rails/blob/main/codespell.txt)에 대해 실행됩니다. `codespell`은 [Python](https://www.python.org/)으로 작성되었으며 다음과 같이 실행할 수 있습니다:

```bash
$ codespell --ignore-words=codespell.txt
```

### 코드 성능 측정

성능에 영향을 줄 수 있는 변경 사항의 경우 코드를 벤치마크하고 영향을 측정하십시오. 사용한 벤치마크 스크립트와 결과를 공유해주십시오. 이러한 정보를 커밋 메시지에 포함시키면 향후 기여자가 쉽게 결과를 확인하고 해당 결과가 여전히 유효한지 확인할 수 있습니다(예: 루비 VM의 향후 최적화가 특정 최적화를 불필요하게 만들 수 있음).
특정 시나리오에 대해 최적화를 수행할 때, 일반적인 경우에 대한 성능이 저하될 수 있습니다.
따라서, 실제 프로덕션 애플리케이션에서 추출한 대표적인 시나리오 목록을 사용하여 변경 사항을 테스트해야 합니다.

[벤치마크 템플릿](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb)을 시작점으로 사용할 수 있습니다. 이 템플릿은 [benchmark-ips](https://github.com/evanphx/benchmark-ips) 젬을 사용하여 벤치마크를 설정하는 보일러플레이트 코드를 포함하고 있습니다. 이 템플릿은 스크립트에 인라인으로 삽입할 수 있는 상대적으로 독립적인 변경 사항을 테스트하기 위해 설계되었습니다.

### 테스트 실행

변경 사항을 푸시하기 전에 전체 테스트 스위트를 실행하는 것은 Rails에서 일반적이지 않습니다. 특히 railties 테스트 스위트는 시간이 오래 걸리며, [rails-dev-box](https://github.com/rails/rails-dev-box)와 같이 권장되는 워크플로우에서 `/vagrant`에 소스 코드가 마운트되는 경우 특히 오랜 시간이 걸릴 수 있습니다.

타협책으로 코드가 명백하게 영향을 미치는 부분만 테스트하고, 변경 사항이 railties에 없는 경우 해당 컴포넌트의 전체 테스트 스위트를 실행하십시오. 모든 테스트가 통과하면 기여를 제안하는 데 충분합니다. 예기치 않은 오류를 잡기 위해 [Buildkite](https://buildkite.com/rails/rails)를 사용할 수 있습니다.

#### 전체 Rails:

모든 테스트를 실행하려면 다음을 수행하십시오:

```bash
$ cd rails
$ bundle exec rake test
```

#### 특정 컴포넌트에 대한 테스트

특정 컴포넌트(예: Action Pack)에 대한 테스트만 실행할 수 있습니다. 예를 들어, Action Mailer 테스트를 실행하려면:

```bash
$ cd actionmailer
$ bin/test
```

#### 특정 디렉토리에 대한 테스트

특정 컴포넌트의 특정 디렉토리(예: Active Storage의 모델)에 대한 테스트만 실행할 수 있습니다. 예를 들어, `/activestorage/test/models`에서 테스트를 실행하려면:

```bash
$ cd activestorage
$ bin/test models
```

#### 특정 파일에 대한 테스트

특정 파일에 대한 테스트를 실행할 수 있습니다:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### 단일 테스트 실행

`-n` 옵션을 사용하여 이름으로 특정 테스트를 실행할 수 있습니다:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### 특정 라인에 대한 테스트

이름을 찾는 것은 항상 쉽지 않지만, 테스트가 시작되는 라인 번호를 알고 있는 경우 이 옵션을 사용할 수 있습니다:

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### 특정 Seed로 테스트 실행

테스트 실행은 무작위로 실행됩니다. 무작위 테스트 실패가 발생하는 경우, 특정 Seed를 설정하여 실패하는 테스트 시나리오를 더 정확하게 재현할 수 있습니다.

컴포넌트의 모든 테스트 실행:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

단일 테스트 파일 실행:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### 직렬로 테스트 실행

Action Pack 및 Action View 단위 테스트는 기본적으로 병렬로 실행됩니다. 무작위 테스트 실패가 발생하는 경우, 무작위 Seed를 설정하고 `PARALLEL_WORKERS=1`을 설정하여 이 단위 테스트를 직렬로 실행할 수 있습니다.

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Active Record 테스트

먼저 필요한 데이터베이스를 생성하십시오. 필요한 테이블 이름, 사용자 이름 및 비밀번호 목록은 `activerecord/test/config.example.yml`에서 찾을 수 있습니다.

MySQL 및 PostgreSQL의 경우 다음을 실행하면 충분합니다:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

또는:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

SQLite3의 경우 이 작업은 필요하지 않습니다.

다음은 SQLite3에 대해서만 Active Record 테스트 스위트를 실행하는 방법입니다:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

이제 `sqlite3`에 대해 이전과 같이 테스트를 실행할 수 있습니다. 각각의 작업은 다음과 같습니다:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

마지막으로,

```bash
$ bundle exec rake test
```

이제 이 세 가지를 차례로 실행합니다.

단일 테스트를 별도로 실행할 수도 있습니다:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

모든 어댑터에 대해 단일 테스트를 실행하려면 다음을 사용하십시오:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

`test_jdbcmysql`, `test_jdbcsqlite3` 또는 `test_jdbcpostgresql`도 사용할 수 있습니다. 더 구체적인 데이터베이스 테스트 실행에 대한 정보는 `activerecord/RUNNING_UNIT_TESTS.rdoc` 파일을 참조하십시오.

#### 테스트에서 디버거 사용

외부 디버거(pry, byebug 등)를 사용하려면 디버거를 설치하고 일반적인 방법대로 사용하십시오. 디버거 문제가 발생하는 경우 `PARALLEL_WORKERS=1`을 설정하여 테스트를 직렬로 실행하거나 `-n test_long_test_name`을 사용하여 단일 테스트를 실행하십시오.

### 경고

테스트 스위트는 경고가 활성화된 상태로 실행됩니다. 이상적으로 Ruby on Rails는 경고를 발생시키지 않아야 하지만, 몇 가지 경고가 발생할 수 있으며, 타사 라이브러리에서도 일부 경고가 발생할 수 있습니다. 발생하는 경우 무시하거나(또는 수정하고!) 새로운 경고를 발생시키지 않는 패치를 제출하십시오.
Rails CI는 경고가 도입되면 예외를 발생시킵니다. 동일한 동작을 로컬에서 구현하려면 테스트 스위트를 실행할 때 `RAILS_STRICT_WARNINGS=1`을 설정하십시오.

### 문서 업데이트

Ruby on Rails [가이드](https://guides.rubyonrails.org/)는 Rails의 기능에 대한 고수준 개요를 제공하며, [API 문서](https://api.rubyonrails.org/)는 구체적인 내용을 다룹니다.

PR이 새로운 기능을 추가하거나 기존 기능의 동작을 변경하는 경우, 관련 문서를 확인하고 필요한 대로 업데이트하거나 추가해야 합니다.

예를 들어, Active Storage의 이미지 분석기를 수정하여 새로운 메타데이터 필드를 추가하는 경우, Active Storage 가이드의 [파일 분석](active_storage_overview.html#analyzing-files) 섹션을 해당 변경 사항을 반영하도록 업데이트해야 합니다.

### CHANGELOG 업데이트

CHANGELOG는 모든 릴리스의 중요한 부분입니다. 각 Rails 버전의 변경 사항 목록을 유지합니다.

기능을 추가하거나 제거하거나, 폐기 알림을 추가하는 경우 수정한 프레임워크의 CHANGELOG 맨 위에 항목을 추가해야 합니다. 리팩터링, 작은 버그 수정 및 문서 변경은 일반적으로 CHANGELOG에 포함되지 않아야 합니다.

CHANGELOG 항목은 변경된 내용을 요약하고 작성자의 이름으로 끝나야 합니다. 필요한 경우 여러 줄을 사용하고, 4개의 공백으로 들여쓴 코드 예제를 첨부할 수 있습니다. 변경 사항이 특정 이슈와 관련된 경우 이슈 번호를 첨부해야 합니다. 다음은 CHANGELOG 항목의 예입니다:

```
*   변경 내용을 간단히 설명하는 변경 요약입니다. 여러 줄을 사용하고, 약 80자 정도에서 줄을 바꿀 수 있습니다. 필요한 경우 코드 예제도 가능합니다:

        class Foo
          def bar
            puts 'baz'
          end
        end

    코드 예제 이후에도 계속 작성할 수 있으며, 이슈 번호를 첨부할 수 있습니다.

    Fixes #1234.

    *Your Name*
```

코드 예제나 여러 단락이 없는 경우 마지막 단어 바로 뒤에 이름을 추가할 수 있습니다. 그렇지 않은 경우 새로운 단락을 만드는 것이 좋습니다.

### 중요한 변경 사항

기존 애플리케이션을 망가뜨릴 수 있는 변경 사항은 중요한 변경 사항으로 간주됩니다. Rails 애플리케이션의 업그레이드를 용이하게 하기 위해 중요한 변경 사항은 폐기 주기를 필요로 합니다.

#### 동작 제거

중요한 변경 사항이 기존 동작을 제거하는 경우, 기존 동작을 유지하면서 폐기 경고를 추가해야 합니다.

예를 들어, `ActiveRecord::Base`의 공개 메소드를 제거하려는 경우, 메인 브랜치가 미배포된 7.0 버전을 가리킬 때 Rails 7.0은 폐기 경고를 표시해야 합니다. 이렇게 하면 어떤 Rails 7.0 버전으로 업그레이드하더라도 폐기 경고를 볼 수 있습니다. Rails 7.1에서 해당 메소드를 삭제할 수 있습니다.

다음과 같은 폐기 경고를 추가할 수 있습니다:

```ruby
def deprecated_method
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.deprecated_method` is deprecated and will be removed in Rails 7.1.
  MSG
  # 기존 동작
end
```

#### 동작 변경

중요한 변경 사항이 기존 동작을 변경하는 경우, 프레임워크 기본값을 추가해야 합니다. 프레임워크 기본값은 앱이 새로운 기본값으로 하나씩 전환할 수 있도록 돕습니다.

새로운 프레임워크 기본값을 구현하려면, 먼저 대상 프레임워크에 접근자를 추가하여 구성을 만듭니다. 기본값을 기존 동작으로 설정하여 업그레이드 중에 아무 문제가 발생하지 않도록 합니다.

```ruby
module ActiveJob
  mattr_accessor :existing_behavior, default: true
end
```

새로운 구성을 사용하여 새로운 동작을 조건부로 구현할 수 있습니다:

```ruby
def changed_method
  if ActiveJob.existing_behavior
    # 기존 동작
  else
    # 새로운 동작
  end
end
```

새로운 프레임워크 기본값을 설정하려면 `Rails::Application::Configuration#load_defaults`에서 새로운 값을 설정합니다:

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

업그레이드를 용이하게 하기 위해 `new_framework_defaults` 템플릿에 새로운 기본값을 주석 처리하여 추가합니다:

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.existing_behavior = false
```

마지막 단계로 `configuration.md`의 구성 가이드에 새로운 구성을 추가합니다:

```markdown
#### `config.active_job.existing_behavior`

| 버전부터 시작 | 기본값 |
| -------------- | ------ |
| (원래)        | `true` |
| 7.1            | `false` |
```

### 에디터 / IDE에서 생성된 파일 무시하기

일부 편집기와 IDE는 `rails` 폴더 내부에 숨겨진 파일이나 폴더를 생성할 수 있습니다. 이러한 파일을 각 커밋에서 수동으로 제외하거나 Rails의 `.gitignore`에 추가하는 대신, 컴퓨터의 [전역 gitignore 파일](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer)에 추가해야 합니다.

### Gemfile.lock 업데이트

일부 변경 사항은 종속성 업그레이드를 필요로 합니다. 이러한 경우 올바른 버전의 종속성을 얻기 위해 `bundle update`를 실행하고 변경 사항과 함께 `Gemfile.lock` 파일을 커밋해야 합니다.
### 변경 사항 커밋하기

컴퓨터에서 코드에 만족하면 변경 사항을 Git에 커밋해야 합니다:

```bash
$ git commit -a
```

이 명령을 실행하면 커밋 메시지를 작성하기 위해 편집기가 열립니다. 작성을 완료하면 저장하고 닫습니다.

잘 서식이 지정된 설명적인 커밋 메시지는 변경 사항이 왜 발생했는지 이해하는 데 다른 사람들에게 매우 도움이 됩니다. 따라서 시간을 내어 작성해 주세요.

좋은 커밋 메시지는 다음과 같습니다:

```
짧은 요약 (50자 이하가 좋음)

필요한 경우 더 자세한 설명. 각 줄은 72자에서 줄바꿈되어야 합니다. 가능한 한 자세하게 작성하십시오. 커밋 내용이 명백하다고 생각하더라도 다른 사람들에게는 명백하지 않을 수 있습니다. 관련된 이슈에 이미 존재하는 설명을 추가하십시오. 히스토리를 확인하기 위해 웹페이지를 방문할 필요는 없어야 합니다.

설명 섹션에는 여러 단락이 포함될 수 있습니다.

코드 예제는 4개의 공백으로 들여쓰기하여 포함할 수 있습니다:

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

또한 다음과 같이 글머리 기호를 추가할 수 있습니다:

- 대시 (-) 또는 별표 (*)로 시작하는 줄로 글머리 기호를 만듭니다.

- 72자에서 줄바꿈하고 가독성을 위해 추가 줄은 2개의 공백으로 들여쓰기합니다.
```

팁. 적절한 경우 커밋을 하나로 압축하세요. 이렇게 하면 나중에 체리 픽(cherry pick)을 간편하게 할 수 있으며 git 로그가 깨끗해집니다.

### 브랜치 업데이트하기

작업 중에 main에 다른 변경 사항이 발생한 가능성이 매우 높습니다. main에서 새 변경 사항을 가져오려면 다음을 실행합니다:

```bash
$ git checkout main
$ git pull --rebase
```

이제 최신 변경 사항 위에 패치를 다시 적용합니다:

```bash
$ git checkout my_new_branch
$ git rebase main
```

충돌이 없습니까? 테스트는 여전히 통과합니까? 변경 사항은 여전히 합리적으로 보입니다? 그렇다면 리베이스된 변경 사항을 GitHub에 푸시합니다:

```bash
$ git push --force-with-lease
```

rails/rails 저장소 기반에서 강제 푸시를 허용하지 않지만 포크에는 강제 푸시할 수 있습니다. 이 경우 리베이스할 때 이 요구사항이 필요합니다.

### 포크

Rails [GitHub 저장소](https://github.com/rails/rails)로 이동하여 오른쪽 상단에 있는 "Fork"를 클릭합니다.

로컬 머신의 로컬 저장소에 새 원격 저장소를 추가합니다:

```bash
$ git remote add fork https://github.com/<your username>/rails.git
```

로컬 저장소를 rails/rails에서 복제했을 수도 있고 포크한 저장소에서 복제했을 수도 있습니다. 다음 git 명령은 "rails"라는 이름의 원격 저장소가 rails/rails을 가리키고 있다고 가정합니다.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

공식 저장소에서 새 커밋과 브랜치를 다운로드합니다:

```bash
$ git fetch rails
```

새 내용을 병합합니다:

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

포크를 업데이트합니다:

```bash
$ git push fork main
$ git push fork my_new_branch
```

### 풀 리퀘스트 열기

방금 푸시한 Rails 저장소로 이동합니다 (예: https://github.com/your-user-name/rails) 그리고 상단 바(코드 바로 위)에 있는 "Pull Requests"를 클릭합니다. 다음 페이지에서 오른쪽 상단에 있는 "New pull request"를 클릭합니다.

풀 리퀘스트는 기본 저장소 `rails/rails`와 브랜치 `main`을 대상으로 해야 합니다. 헤드 저장소는 작업한 저장소 (`your-user-name/rails`)이고 브랜치는 생성한 브랜치의 이름입니다. 준비가 되었으면 "create pull request"를 클릭합니다.

소개한 변경 사항이 포함되어 있는지 확인합니다. 제공된 풀 리퀘스트 템플릿을 사용하여 패치에 대한 일부 세부 정보를 작성합니다. 완료되면 "Create pull request"를 클릭합니다.

### 피드백 받기

대부분의 풀 리퀘스트는 병합되기 전에 몇 차례 반복됩니다. 때로는 다른 기여자들이 다른 의견을 가지고 있을 수 있으며 종종 패치를 수정해야 합니다.

Rails의 일부 기여자들은 GitHub의 이메일 알림을 켜놓았지만 다른 사람들은 그렇지 않을 수도 있습니다. 게다가 Rails에서 작업하는 사람들은 (거의) 모두 자원봉사자이므로 풀 리퀘스트에 대한 첫 번째 피드백을 받기까지는 몇 일이 걸릴 수 있습니다. 희망을 잃지 마세요! 때로는 빠를 때도 있고 느릴 때도 있습니다. 그것이 오픈 소스 생활입니다.

1주일 이상 지났는데 아무런 피드백을 받지 못했다면 상황을 움직이기 위해 노력해 볼 수 있습니다. 이를 위해 [rubyonrails-core 토론 게시판](https://discuss.rubyonrails.org/c/rubyonrails-core)을 사용할 수 있습니다. 또는 풀 리퀘스트에 다른 코멘트를 남길 수도 있습니다.
풀 리퀘스트에 대한 피드백을 기다리는 동안 다른 몇 개의 풀 리퀘스트를 열어 다른 사람에게도 피드백을 주세요! 당신이 패치에 대한 피드백을 감사히 여기는 것처럼 다른 사람들도 그렇게 감사할 것입니다.

코드 변경 사항을 병합할 수 있는 권한은 Core 및 Committers 팀에만 부여됩니다.
누군가가 피드백을 제공하고 당신의 변경 사항을 "승인"한다고 해도, 그들은 변경 사항을 병합할 수 있는 능력이나 최종 결정권을 가지고 있지 않을 수 있습니다.

### 필요한 만큼 반복하세요

당신이 받은 피드백이 변경 사항을 제안한다면, 낙담하지 마세요: 활발한 오픈 소스 프로젝트에 기여하는 전체 목적은 커뮤니티의 지식을 활용하는 것입니다. 사람들이 코드를 조정하도록 권장한다면, 그 조정을 하고 다시 제출하는 가치가 있습니다. 만약 피드백이 당신의 코드가 병합되지 않을 것이라면, 여전히 젬으로 출시할 생각을 해볼 수 있습니다.

#### 커밋 합치기

우리가 요청할 수 있는 일 중 하나는 "커밋을 합치라"는 것입니다. 이렇게 하면 모든 커밋이 하나의 커밋으로 결합됩니다. 우리는 하나의 커밋으로 된 풀 리퀘스트를 선호합니다. 이렇게 하면 안정적인 브랜치로 변경 사항을 되돌리기가 쉬워지며, 잘못된 커밋을 되돌리기가 쉬워지며, git 히스토리를 조금 더 쉽게 따라갈 수 있습니다. Rails는 큰 프로젝트이며, 많은 불필요한 커밋은 많은 노이즈를 추가할 수 있습니다.

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< 첫 번째 커밋을 제외한 모든 커밋에 대해 'squash'를 선택하세요. >
< 의미가 있도록 커밋 메시지를 편집하고 모든 변경 사항을 설명하세요. >

$ git push fork my_new_branch --force-with-lease
```

GitHub에서 풀 리퀘스트를 새로 고칠 수 있어야 합니다.

#### 풀 리퀘스트 업데이트하기

가끔은 이미 커밋한 코드에 몇 가지 변경을 요청받을 수 있습니다. 이는 기존 커밋을 수정하는 것을 포함할 수 있습니다. 이 경우 Git은 변경 사항을 푸시할 수 없으므로 푸시된 브랜치와 로컬 브랜치가 일치하지 않습니다. 새로운 풀 리퀘스트를 열기보다는 앞서 설명한 커밋 합치기 섹션에서와 같이 GitHub의 브랜치에 강제로 푸시할 수 있습니다.

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

이렇게 하면 새 코드로 브랜치와 풀 리퀘스트가 GitHub에서 업데이트됩니다.
`--force-with-lease`와 함께 강제 푸시함으로써 git은 이미 가지고 있지 않은 원격 작업을 삭제할 수 있는 일반적인 `-f`보다 더 안전하게 원격을 업데이트합니다.

### 이전 버전의 Ruby on Rails

다음 릴리스보다 오래된 Ruby on Rails 버전에 수정 사항을 추가하려면, 자체 로컬 추적 브랜치를 설정하고 전환해야 합니다. 다음은 7-0-stable 브랜치로 전환하는 예입니다.

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

참고: 이전 버전에서 작업하기 전에 [유지 정책](maintenance_policy.html)을 확인하세요. 지원 종료된 버전에는 변경 사항이 허용되지 않습니다.

#### 백포팅

main에 병합된 변경 사항은 Rails의 다음 주요 릴리스를 위한 것입니다. 때로는 유지 보수 릴리스에 포함하기 위해 변경 사항을 안정 브랜치로 전파하는 것이 유익할 수 있습니다. 일반적으로 보안 수정 및 버그 수정은 백포팅에 적합한 후보입니다. 반면에 새로운 기능 및 예상 동작을 변경하는 패치는 허용되지 않습니다. 의문이 생길 경우, 변경 사항을 백포팅하기 전에 Rails 팀 멤버와 상담하는 것이 가장 좋습니다.

먼저, main 브랜치가 최신 상태인지 확인하세요.

```bash
$ git checkout main
$ git pull --rebase
```

백포팅할 브랜치, 예를 들어 `7-0-stable`로 이동하고 최신 상태인지 확인하세요.

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

병합된 풀 리퀘스트를 백포팅하는 경우, 병합을 위한 커밋을 찾아 cherry-pick하세요.

```bash
$ git cherry-pick -m1 MERGE_SHA
```

cherry-pick 중에 발생한 충돌을 해결하고 변경 사항을 푸시한 다음, 백포팅할 안정 브랜치를 가리키는 PR을 엽니다. 더 복잡한 변경 사항이 있는 경우 [cherry-pick](https://git-scm.com/docs/git-cherry-pick) 문서를 참조하세요.

Rails 기여자
------------------

모든 기여는 [Rails 기여자](https://contributors.rubyonrails.org)에서 인정받습니다.
