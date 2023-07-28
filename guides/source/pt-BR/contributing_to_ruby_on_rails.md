**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
Contribuindo para o Ruby on Rails
=============================

Este guia aborda como _você_ pode se tornar parte do desenvolvimento contínuo do Ruby on Rails.

Após ler este guia, você saberá:

* Como usar o GitHub para relatar problemas.
* Como clonar o repositório principal e executar o conjunto de testes.
* Como ajudar a resolver problemas existentes.
* Como contribuir para a documentação do Ruby on Rails.
* Como contribuir para o código do Ruby on Rails.

O Ruby on Rails não é "o framework de outra pessoa". Ao longo dos anos, milhares de pessoas contribuíram para o Ruby on Rails, desde um único caractere até grandes mudanças arquiteturais ou documentação significativa - tudo para tornar o Ruby on Rails melhor para todos. Mesmo que você não se sinta capaz de escrever código ou documentação ainda, existem várias outras maneiras de contribuir, desde relatar problemas até testar correções.

Como mencionado no [README do Rails](https://github.com/rails/rails/blob/main/README.md), todos que interagem nos repositórios de código, rastreadores de problemas, salas de chat, fóruns de discussão e listas de e-mails do Rails e seus subprojetos devem seguir o [código de conduta](https://rubyonrails.org/conduct) do Rails.

--------------------------------------------------------------------------------

Relatando um Problema
------------------

O Ruby on Rails usa o [GitHub Issue Tracking](https://github.com/rails/rails/issues) para rastrear problemas (principalmente bugs e contribuições de novo código). Se você encontrou um bug no Ruby on Rails, este é o lugar para começar. Você precisará criar uma conta gratuita no GitHub para enviar um problema, comentar problemas ou criar pull requests.

NOTA: Bugs na versão mais recente lançada do Ruby on Rails provavelmente receberão mais atenção. Além disso, a equipe central do Rails está sempre interessada no feedback daqueles que podem dedicar tempo para testar o _edge Rails_ (o código da versão do Rails que está atualmente em desenvolvimento). Mais adiante neste guia, você descobrirá como obter o edge Rails para testar. Consulte nossa [política de manutenção](maintenance_policy.html) para obter informações sobre quais versões são suportadas. Nunca relate um problema de segurança no rastreador de problemas do GitHub.

### Criando um Relatório de Bug

Se você encontrou um problema no Ruby on Rails que não representa um risco de segurança, pesquise os [Issues](https://github.com/rails/rails/issues) no GitHub, caso já tenha sido relatado. Se você não encontrar nenhum problema aberto no GitHub que aborde o problema que você encontrou, seu próximo passo será [abrir um novo problema](https://github.com/rails/rails/issues/new). (Consulte a próxima seção para relatar problemas de segurança.)

Fornecemos um modelo de problema para que, ao criar um problema, você inclua todas as informações necessárias para determinar se há um bug no framework. Cada problema precisa incluir um título e uma descrição clara do problema. Certifique-se de incluir o máximo de informações relevantes possível, incluindo um exemplo de código ou teste falhando que demonstre o comportamento esperado, bem como sua configuração do sistema. Seu objetivo deve ser facilitar para você - e para os outros - reproduzir o bug e encontrar uma solução.

Depois de abrir um problema, ele pode ou não receber atividade imediatamente, a menos que seja um bug do tipo "Código Vermelho, Crítico, o Mundo está Acabando". Isso não significa que não nos importamos com o seu bug, apenas que há muitos problemas e pull requests para resolver. Outras pessoas com o mesmo problema podem encontrar seu problema, confirmar o bug e colaborar com você para corrigi-lo. Se você souber como corrigir o bug, vá em frente e abra um pull request.

### Criar um Caso de Teste Executável

Ter uma maneira de reproduzir seu problema ajudará as pessoas a confirmar, investigar e, finalmente, corrigir seu problema. Você pode fazer isso fornecendo um caso de teste executável. Para facilitar esse processo, preparamos vários modelos de relatório de bug para você usar como ponto de partida:

* Modelo para problemas do Active Record (modelos, banco de dados): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Modelo para problemas de teste do Active Record (migração): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Modelo para problemas do Action Pack (controladores, roteamento): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Modelo para problemas do Active Job: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Modelo para problemas do Active Storage: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Modelo para problemas do Action Mailbox: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* Modelo genérico para outros problemas: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

Esses modelos incluem o código básico para configurar um caso de teste em uma versão lançada do Rails (`*_gem.rb`) ou no edge Rails (`*_main.rb`).
Copie o conteúdo do modelo apropriado para um arquivo `.rb` e faça as alterações necessárias para demonstrar o problema. Você pode executá-lo executando `ruby the_file.rb` no seu terminal. Se tudo correr bem, você verá seu caso de teste falhando.

Você pode compartilhar seu caso de teste executável como um [gist](https://gist.github.com) ou colar o conteúdo na descrição do problema.

### Tratamento Especial para Problemas de Segurança

AVISO: Por favor, não relate vulnerabilidades de segurança com relatórios públicos de problemas do GitHub. A página de política de segurança do [Rails](https://rubyonrails.org/security) detalha o procedimento a ser seguido para problemas de segurança.

### E quanto a solicitações de recursos?

Por favor, não coloque itens de "solicitação de recurso" em problemas do GitHub. Se houver um novo recurso que você deseja ver adicionado ao Ruby on Rails, você precisará escrever o código você mesmo - ou convencer outra pessoa a se associar a você para escrever o código. Mais adiante neste guia, você encontrará instruções detalhadas para propor um patch para o Ruby on Rails. Se você inserir um item de lista de desejos em problemas do GitHub sem código, espere que ele seja marcado como "inválido" assim que for revisado.

Às vezes, a linha entre 'bug' e 'recurso' é difícil de traçar. Geralmente, um recurso é qualquer coisa que adiciona um novo comportamento, enquanto um bug é qualquer coisa que cause um comportamento incorreto. Às vezes, a equipe principal terá que tomar uma decisão. Dito isso, a distinção geralmente determina em qual patch sua alteração será lançada; adoramos envios de recursos! Eles simplesmente não serão retroportados para ramos de manutenção.

Se você gostaria de receber feedback sobre uma ideia de recurso antes de fazer o trabalho para criar um patch, por favor, inicie uma discussão no [fórum de discussão do rails-core](https://discuss.rubyonrails.org/c/rubyonrails-core). Você pode não receber resposta, o que significa que todos são indiferentes. Você pode encontrar alguém que também esteja interessado em construir esse recurso. Você pode receber um "Isso não será aceito". Mas é o lugar adequado para discutir novas ideias. Problemas do GitHub não são um local particularmente bom para as discussões às vezes longas e envolvidas que os novos recursos exigem.


Ajudando a Resolver Problemas Existentes
---------------------------------------

Além de relatar problemas, você pode ajudar a equipe principal a resolver os problemas existentes fornecendo feedback sobre eles. Se você é novo no desenvolvimento principal do Rails, fornecer feedback ajudará você a se familiarizar com o código e os processos.

Se você verificar a [lista de problemas](https://github.com/rails/rails/issues) em problemas do GitHub, encontrará muitos problemas que já requerem atenção. O que você pode fazer sobre isso? Na verdade, bastante coisa:

### Verificando Relatórios de Bugs

Para começar, ajuda apenas a verificar relatórios de bugs. Você consegue reproduzir o problema relatado no seu computador? Se sim, você pode adicionar um comentário ao problema dizendo que está vendo a mesma coisa.

Se um problema for muito vago, você pode ajudar a reduzi-lo a algo mais específico? Talvez você possa fornecer informações adicionais para reproduzir o bug, ou talvez possa eliminar etapas desnecessárias que não são necessárias para demonstrar o problema.

Se você encontrar um relatório de bug sem um teste, é muito útil contribuir com um teste que falhe. Esta também é uma ótima maneira de explorar o código-fonte: olhar os arquivos de teste existentes ensinará você a escrever mais testes. Novos testes são melhor contribuídos na forma de um patch, como explicado posteriormente na seção [Contribuindo para o Código do Rails](#contribuindo-para-o-código-do-rails).

Qualquer coisa que você possa fazer para tornar os relatórios de bugs mais sucintos ou mais fáceis de reproduzir ajuda as pessoas que tentam escrever código para corrigir esses bugs - quer você acabe escrevendo o código você mesmo ou não.

### Testando Patches

Você também pode ajudar examinando pull requests que foram enviados para o Ruby on Rails via GitHub. Para aplicar as alterações de alguém, primeiro crie um branch dedicado:

```bash
$ git checkout -b testing_branch
```

Em seguida, você pode usar o branch remoto deles para atualizar sua base de código. Por exemplo, digamos que o usuário do GitHub JohnSmith tenha bifurcado e enviado para um branch de tópico "orange" localizado em https://github.com/JohnSmith/rails.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

Uma alternativa para adicionar o branch remoto à sua verificação é usar a [ferramenta CLI do GitHub](https://cli.github.com/) para verificar a pull request deles.

Depois de aplicar o branch deles, teste-o! Aqui estão algumas coisas para pensar:
* A mudança realmente funciona?
* Você está satisfeito com os testes? Você consegue entender o que eles estão testando? Está faltando algum teste?
* A cobertura de documentação está adequada? A documentação em outros lugares deve ser atualizada?
* Você gosta da implementação? Consegue pensar em uma maneira melhor ou mais rápida de implementar uma parte da mudança deles?

Quando estiver satisfeito de que o pull request contém uma boa mudança, comente na issue do GitHub indicando suas descobertas. Seu comentário deve indicar que você gosta da mudança e o que você gosta nela. Algo como:

>Gosto da maneira como você reestruturou aquele código em generate_finder_sql - muito melhor. Os testes também parecem bons.

Se seu comentário simplesmente diz "+1", é provável que outros revisores não o levem muito a sério. Mostre que você dedicou tempo para revisar o pull request.

Contribuindo para a Documentação do Rails
-----------------------------------------

O Ruby on Rails possui dois conjuntos principais de documentação: os guias, que ajudam você a aprender sobre o Ruby on Rails, e a API, que serve como referência.

Você pode ajudar a melhorar os guias do Rails ou a referência da API tornando-os mais coerentes, consistentes ou legíveis, adicionando informações ausentes, corrigindo erros factuais, corrigindo erros de digitação ou atualizando-os com a versão mais recente do Rails.

Para fazer isso, faça alterações nos arquivos de origem dos guias do Rails (localizados [aqui](https://github.com/rails/rails/tree/main/guides/source) no GitHub) ou nos comentários RDoc no código-fonte. Em seguida, abra um pull request para aplicar suas alterações ao branch principal.

Ao trabalhar com a documentação, leve em consideração as [Diretrizes de Documentação da API](api_documentation_guidelines.html) e as [Diretrizes dos Guias do Ruby on Rails](ruby_on_rails_guides_guidelines.html).

Traduzindo os Guias do Rails
---------------------------

Ficamos felizes em ter pessoas voluntárias para traduzir os guias do Rails. Basta seguir estes passos:

* Faça um fork de https://github.com/rails/rails.
* Adicione uma pasta de origem para o seu idioma, por exemplo: *guides/source/it-IT* para italiano.
* Copie o conteúdo de *guides/source* para o diretório do seu idioma e traduza-os.
* NÃO traduza os arquivos HTML, pois eles são gerados automaticamente.

Observe que as traduções não são enviadas para o repositório do Rails; seu trabalho fica no seu fork, conforme descrito acima. Isso ocorre porque, na prática, a manutenção da documentação por meio de patches só é sustentável em inglês.

Para gerar os guias no formato HTML, você precisará instalar as dependências dos guias, `cd` para o diretório *guides* e, em seguida, execute (por exemplo, para it-IT):

```bash
# instale apenas as gems necessárias para os guias. Para desfazer, execute: bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

Isso irá gerar os guias em um diretório *output*.

NOTA: O Gem Redcarpet não funciona com o JRuby.

Esforços de tradução que conhecemos (várias versões):

* **Italiano**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Espanhol**: [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **Polonês**: [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **Francês**: [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Tcheco**: [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turco**: [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **Coreano**: [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Chinês Simplificado**: [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Chinês Tradicional**: [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Russo**: [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japonês**: [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **Português Brasileiro**: [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Contribuindo para o Código do Rails
-----------------------------------

### Configurando um Ambiente de Desenvolvimento

Para passar de enviar bugs para ajudar a resolver problemas existentes ou contribuir com seu próprio código para o Ruby on Rails, você _precisa_ ser capaz de executar sua suíte de testes. Nesta seção do guia, você aprenderá como configurar os testes em seu computador.

#### Usando GitHub Codespaces

Se você é membro de uma organização que tem os codespaces habilitados, você pode fazer um fork do Rails para essa organização e usar os codespaces no GitHub. O Codespace será inicializado com todas as dependências necessárias e permite que você execute todos os testes.

#### Usando o VS Code Remote Containers

Se você tiver o [Visual Studio Code](https://code.visualstudio.com) e o [Docker](https://www.docker.com) instalados, você pode usar o plugin [VS Code remote containers](https://code.visualstudio.com/docs/remote/containers-tutorial). O plugin lerá a configuração [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) no repositório e construirá o contêiner Docker localmente.

#### Usando o Dev Container CLI

Alternativamente, com o [Docker](https://www.docker.com) e o [npm](https://github.com/npm/cli) instalados, você pode executar o [Dev Container CLI](https://github.com/devcontainers/cli) para utilizar a configuração [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) a partir da linha de comando.

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### Usando rails-dev-box

Também é possível usar o [rails-dev-box](https://github.com/rails/rails-dev-box) para obter um ambiente de desenvolvimento pronto. No entanto, o rails-dev-box usa o Vagrant e o Virtual Box, que não funcionarão em Macs com Apple silicon.
#### Desenvolvimento Local

Quando você não pode usar o GitHub Codespaces, consulte [este outro guia](development_dependencies_install.html) para saber como configurar o desenvolvimento local. Isso é considerado o caminho difícil porque a instalação de dependências pode ser específica do sistema operacional.

### Clonar o Repositório do Rails

Para poder contribuir com o código, você precisa clonar o repositório do Rails:

```bash
$ git clone https://github.com/rails/rails.git
```

e criar um branch dedicado:

```bash
$ cd rails
$ git checkout -b my_new_branch
```

Não importa muito qual nome você usa porque esse branch só existirá em seu computador local e em seu repositório pessoal no GitHub. Ele não fará parte do repositório Git do Rails.

### Bundle install

Instale as gems necessárias.

```bash
$ bundle install
```

### Executando uma Aplicação com Base no Seu Branch Local

Caso você precise de um aplicativo Rails fictício para testar alterações, a opção `--dev` do comando `rails new` gera um aplicativo que usa seu branch local:

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

O aplicativo gerado em `~/my-test-app` é executado com base em seu branch local e, em particular, vê quaisquer modificações após a reinicialização do servidor.

Para pacotes JavaScript, você pode usar [`yarn link`](https://yarnpkg.com/cli/link) para vincular seu branch local a um aplicativo gerado:

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### Escreva seu Código

Agora é hora de escrever algum código! Ao fazer alterações para o Rails, aqui estão algumas coisas a serem observadas:

* Siga o estilo e as convenções do Rails.
* Use os idiomas e ajudantes do Rails.
* Inclua testes que falhem sem o seu código e passem com ele.
* Atualize a documentação (circundante), exemplos em outros lugares e os guias: tudo o que for afetado pela sua contribuição.
* Se a alteração adicionar, remover ou alterar um recurso, certifique-se de incluir uma entrada no CHANGELOG. Se sua alteração for uma correção de bug, uma entrada no CHANGELOG não é necessária.

DICA: Alterações que são cosméticas e não adicionam nada substancial à estabilidade, funcionalidade ou testabilidade do Rails geralmente não serão aceitas (leia mais sobre [nossa justificativa por trás dessa decisão](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### Siga as Convenções de Codificação

O Rails segue um conjunto simples de convenções de estilo de codificação:

* Dois espaços, sem tabulações (para indentação).
* Sem espaço em branco no final. Linhas em branco não devem ter espaços.
* Indente e não deixe uma linha em branco após private/protected.
* Use a sintaxe Ruby >= 1.9 para hashes. Prefira `{ a: :b }` em vez de `{ :a => :b }`.
* Prefira `&&`/`||` em vez de `and`/`or`.
* Prefira `class << self` em vez de `self.method` para métodos de classe.
* Use `my_method(my_arg)` em vez de `my_method( my_arg )` ou `my_method my_arg`.
* Use `a = b` e não `a=b`.
* Use métodos `assert_not` em vez de `refute`.
* Prefira `method { do_stuff }` em vez de `method{do_stuff}` para blocos de uma única linha.
* Siga as convenções no código-fonte que você vê sendo usado.

As diretrizes acima são orientações - por favor, use seu melhor julgamento ao usá-las.

Além disso, temos regras do [RuboCop](https://www.rubocop.org/) definidas para codificar algumas de nossas convenções de codificação. Você pode executar o RuboCop localmente no arquivo que você modificou antes de enviar uma solicitação de pull:

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

Para arquivos CoffeeScript e JavaScript do `rails-ujs`, você pode executar `npm run lint` na pasta `actionview`.

#### Verificação Ortográfica

Estamos executando o [misspell](https://github.com/client9/misspell), que é principalmente escrito em
[Golang](https://golang.org/), para verificar a ortografia com [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml). Corrija
palavras em inglês comumente escritas incorretamente rapidamente com o `misspell`. O `misspell` é diferente da maioria dos outros verificadores ortográficos
porque ele não usa um dicionário personalizado. Você pode executar o `misspell` localmente em todos os arquivos com:

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

As opções ou flags úteis do `misspell` são:

- `-i` string: ignore as seguintes correções, separadas por vírgula
- `-w`: Sobrescreva o arquivo com as correções (o padrão é apenas exibir)

Também executamos o [codespell](https://github.com/codespell-project/codespell) com o GitHub Actions para verificar a ortografia e
o [codespell](https://pypi.org/project/codespell/) é executado em um [pequeno dicionário personalizado](https://github.com/rails/rails/blob/main/codespell.txt).
O `codespell` é escrito em [Python](https://www.python.org/) e você pode executá-lo com:

```bash
$ codespell --ignore-words=codespell.txt
```

### Avalie o Desempenho do seu Código

Para alterações que possam ter impacto no desempenho, por favor, avalie o desempenho do seu
código e meça o impacto. Por favor, compartilhe o script de benchmark que você usou, bem como os resultados. Você deve considerar incluir essas informações em sua mensagem de commit, para permitir que futuros colaboradores verifiquem facilmente suas descobertas e determinem se elas ainda são relevantes. (Por exemplo, otimizações futuras na
VM Ruby podem tornar certas otimizações desnecessárias.)
Ao otimizar para um cenário específico que você se preocupa, é fácil regredir o desempenho para outros casos comuns.
Portanto, você deve testar sua alteração em uma lista de cenários representativos, idealmente extraídos de aplicativos de produção do mundo real.

Você pode usar o [modelo de benchmark](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb)
como ponto de partida. Ele inclui o código básico para configurar um benchmark
usando a gem [benchmark-ips](https://github.com/evanphx/benchmark-ips). O
modelo é projetado para testar alterações relativamente autônomas que podem ser
inseridas no script.

### Executando Testes

Não é comum no Rails executar o conjunto completo de testes antes de enviar
alterações. O conjunto de testes do railties, em particular, leva muito tempo e levará um
tempo especialmente longo se o código-fonte estiver montado em `/vagrant`, como acontece em
o fluxo de trabalho recomendado com o [rails-dev-box](https://github.com/rails/rails-dev-box).

Como compromisso, teste o que sua alteração afeta obviamente e, se a alteração não estiver em railties, execute o conjunto completo de testes do componente afetado. Se todos
os testes estiverem passando, isso é suficiente para propor sua contribuição. Temos
[Buildkite](https://buildkite.com/rails/rails) como uma rede de segurança para detectar
quebras inesperadas em outros lugares.

#### Rails Inteiro:

Para executar todos os testes, faça:

```bash
$ cd rails
$ bundle exec rake test
```

#### Para um Componente Específico

Você pode executar testes apenas para um componente específico (por exemplo, Action Pack). Por exemplo,
para executar testes do Action Mailer:

```bash
$ cd actionmailer
$ bin/test
```

#### Para um Diretório Específico

Você pode executar testes apenas para um diretório específico de um componente específico
(por exemplo, modelos em Active Storage). Por exemplo, para executar testes em `/activestorage/test/models`:

```bash
$ cd activestorage
$ bin/test models
```

#### Para um Arquivo Específico

Você pode executar os testes para um arquivo específico:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### Executando um Único Teste

Você pode executar um único teste pelo nome usando a opção `-n`:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### Para uma Linha Específica

Descobrir o nome nem sempre é fácil, mas se você souber em qual linha seu teste começa, esta opção é para você:

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### Executando Testes com uma Semente Específica

A execução do teste é randomizada com uma semente de randomização. Se você estiver enfrentando falhas de teste aleatórias, poderá reproduzir com mais precisão um cenário de teste com falha definindo especificamente a semente de randomização.

Executando todos os testes para um componente:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

Executando um único arquivo de teste:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### Executando Testes em Série

Os testes de unidade do Action Pack e do Action View são executados em paralelo por padrão. Se você estiver enfrentando falhas de teste aleatórias, poderá definir a semente de randomização e permitir que esses testes de unidade sejam executados em série definindo `PARALLEL_WORKERS=1`

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Testando o Active Record

Primeiro, crie os bancos de dados de que você precisa. Você pode encontrar uma lista dos nomes de tabela, nomes de usuário e senhas necessários em `activerecord/test/config.example.yml`.

Para MySQL e PostgreSQL, é suficiente executar:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

Ou:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

Isso não é necessário para o SQLite3.

Assim você executa apenas o conjunto de testes do Active Record para o SQLite3:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

Agora você pode executar os testes como fez para `sqlite3`. As tarefas são, respectivamente:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

Finalmente,

```bash
$ bundle exec rake test
```

agora executará os três em sequência.

Você também pode executar qualquer teste separadamente:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

Para executar um único teste em todos os adaptadores, use:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

Você também pode usar `test_jdbcmysql`, `test_jdbcsqlite3` ou `test_jdbcpostgresql`. Consulte o arquivo `activerecord/RUNNING_UNIT_TESTS.rdoc` para obter informações sobre a execução de testes de banco de dados mais direcionados.

#### Usando Depuradores com Testes

Para usar um depurador externo (pry, byebug, etc), instale o depurador e use-o normalmente. Se ocorrerem problemas com o depurador, execute os testes em série definindo `PARALLEL_WORKERS=1` ou execute um único teste com `-n test_long_test_name`.

### Avisos

O conjunto de testes é executado com avisos habilitados. Idealmente, o Ruby on Rails não deve emitir avisos, mas pode haver alguns, bem como alguns de bibliotecas de terceiros. Por favor, ignore (ou corrija!) eles, se houver, e envie patches que não emitam novos avisos.
O Rails CI irá gerar um erro se forem introduzidos avisos. Para implementar o mesmo comportamento localmente, defina `RAILS_STRICT_WARNINGS=1` ao executar o conjunto de testes.

### Atualizando a Documentação

Os [guias](https://guides.rubyonrails.org/) do Ruby on Rails fornecem uma visão geral das funcionalidades do Rails, enquanto a [documentação da API](https://api.rubyonrails.org/) explora os detalhes específicos.

Se o seu PR adiciona uma nova funcionalidade ou altera o comportamento de uma funcionalidade existente, verifique a documentação relevante e atualize-a ou adicione informações conforme necessário.

Por exemplo, se você modificar o analisador de imagens do Active Storage para adicionar um novo campo de metadados, você deve atualizar a seção [Analisando Arquivos](active_storage_overview.html#analyzing-files) do guia do Active Storage para refletir isso.

### Atualizando o CHANGELOG

O CHANGELOG é uma parte importante de cada versão. Ele mantém a lista de alterações para cada versão do Rails.

Você deve adicionar uma entrada **no topo** do CHANGELOG do framework que você modificou se estiver adicionando ou removendo uma funcionalidade, ou adicionando avisos de depreciação. Refatorações, correções de bugs menores e alterações na documentação geralmente não devem ser adicionados ao CHANGELOG.

Uma entrada no CHANGELOG deve resumir o que foi alterado e deve terminar com o nome do autor. Você pode usar várias linhas se precisar de mais espaço e pode anexar exemplos de código recuados com 4 espaços. Se uma alteração estiver relacionada a um problema específico, você deve anexar o número do problema. Aqui está um exemplo de entrada no CHANGELOG:

```
*   Resumo de uma alteração que descreve brevemente o que foi alterado. Você pode usar várias
    linhas e quebrá-las em torno de 80 caracteres. Exemplos de código também são aceitos, se necessário:

        class Foo
          def bar
            puts 'baz'
          end
        end

    Você pode continuar após o exemplo de código e pode anexar o número do problema.

    Corrige #1234.

    *Seu Nome*
```

Seu nome pode ser adicionado diretamente após a última palavra se não houver exemplos de código ou vários parágrafos. Caso contrário, é melhor fazer um novo parágrafo.

### Mudanças que Quebram a Compatibilidade

Qualquer alteração que possa quebrar aplicativos existentes é considerada uma alteração que quebra a compatibilidade. Para facilitar a atualização de aplicativos Rails, alterações que quebram a compatibilidade requerem um ciclo de depreciação.

#### Removendo Comportamento

Se a sua alteração quebra a compatibilidade removendo um comportamento existente, você precisará primeiro adicionar um aviso de depreciação mantendo o comportamento existente.

Como exemplo, vamos dizer que você deseja remover um método público em `ActiveRecord::Base`. Se o branch principal aponta para a versão 7.0 não lançada, o Rails 7.0 precisará exibir um aviso de depreciação. Isso garante que qualquer pessoa que faça upgrade para qualquer versão do Rails 7.0 verá o aviso de depreciação. No Rails 7.1, o método pode ser excluído.

Você pode adicionar o seguinte aviso de depreciação:

```ruby
def metodo_depreciado
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.metodo_depreciado` está depreciado e será removido no Rails 7.1.
  MSG
  # Comportamento existente
end
```

#### Alterando Comportamento

Se a sua alteração quebra a compatibilidade alterando um comportamento existente, você precisará adicionar um padrão de framework. Os padrões de framework facilitam as atualizações do Rails, permitindo que os aplicativos mudem para os novos padrões aos poucos.

Para implementar um novo padrão de framework, primeiro crie uma configuração adicionando um acessor no framework de destino. Defina o valor padrão como o comportamento existente para garantir que nada quebre durante uma atualização.

```ruby
module ActiveJob
  mattr_accessor :comportamento_existente, default: true
end
```

A nova configuração permite que você implemente condicionalmente o novo comportamento:

```ruby
def metodo_alterado
  if ActiveJob.comportamento_existente
    # Comportamento existente
  else
    # Novo comportamento
  end
end
```

Para definir o novo padrão de framework, defina o novo valor em
`Rails::Application::Configuration#load_defaults`:

```ruby
def load_defaults(target_version)
  case target_version.to_s
  when "7.1"
    ...
    if respond_to?(:active_job)
      active_job.comportamento_existente = false
    end
    ...
  end
end
```

Para facilitar a atualização, é necessário adicionar o novo padrão ao
modelo `new_framework_defaults`. Adicione uma seção comentada, definindo o novo
valor:

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.comportamento_existente = false
```

Como último passo, adicione a nova configuração ao guia de configuração em
`configuration.md`:

```markdown
#### `config.active_job.comportamento_existente`

| A partir da versão | O valor padrão é |
| ------------------ | ---------------- |
| (original)         | `true`           |
| 7.1                | `false`          |
```

### Ignorando Arquivos Criados pelo seu Editor / IDE

Alguns editores e IDEs criam arquivos ou pastas ocultas dentro da pasta `rails`. Em vez de excluí-los manualmente de cada commit ou adicioná-los ao `.gitignore` do Rails, você deve adicioná-los ao seu próprio [arquivo global de gitignore](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer).

### Atualizando o Gemfile.lock

Algumas alterações exigem atualizações de dependências. Nesses casos, certifique-se de executar `bundle update` para obter a versão correta da dependência e commitar o arquivo `Gemfile.lock` junto com suas alterações.
### Faça o commit das suas alterações

Quando estiver satisfeito com o código no seu computador, você precisa fazer o commit das alterações no Git:

```bash
$ git commit -a
```

Isso abrirá o seu editor para escrever uma mensagem de commit. Quando terminar, salve e feche para continuar.

Uma mensagem de commit bem formatada e descritiva é muito útil para os outros entenderem por que a alteração foi feita, então, por favor, reserve um tempo para escrevê-la.

Uma boa mensagem de commit se parece com isso:

```
Resumo curto (idealmente com 50 caracteres ou menos)

Descrição mais detalhada, se necessário. Cada linha deve ter no máximo
72 caracteres. Tente ser o mais descritivo possível. Mesmo que você
ache que o conteúdo do commit é óbvio, pode não ser óbvio
para os outros. Adicione qualquer descrição que já esteja presente nas
questões relevantes; não deve ser necessário visitar uma página da web
para verificar o histórico.

A seção de descrição pode ter vários parágrafos.

Exemplos de código podem ser inseridos recuando-os com 4 espaços:

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

Você também pode adicionar marcadores:

- faça um marcador começando uma linha com um traço (-)
  ou um asterisco (*)

- quebre as linhas em 72 caracteres e recue qualquer linha adicional
  com 2 espaços para facilitar a leitura
```

DICA. Por favor, agrupe seus commits em um único commit quando apropriado. Isso
simplifica futuras escolhas de commits e mantém o log do git limpo.

### Atualize o seu branch

É bem provável que outras alterações tenham ocorrido no branch principal enquanto você estava trabalhando. Para obter as novas alterações no branch principal:

```bash
$ git checkout main
$ git pull --rebase
```

Agora, reaplique o seu patch sobre as últimas alterações:

```bash
$ git checkout my_new_branch
$ git rebase main
```

Sem conflitos? Os testes ainda passam? A alteração ainda parece razoável para você? Então, envie as alterações rebaseadas para o GitHub:

```bash
$ git push --force-with-lease
```

Não permitimos o force push no repositório base do rails/rails, mas você pode fazer o force push para o seu fork. Ao fazer o rebase, isso é necessário, pois o histórico foi alterado.

### Fork

Acesse o repositório do Rails no GitHub (https://github.com/rails/rails) e clique em "Fork" no canto superior direito.

Adicione o novo remote ao seu repositório local na sua máquina:

```bash
$ git remote add fork https://github.com/<seu nome de usuário>/rails.git
```

Você pode ter clonado o seu repositório local a partir de rails/rails, ou pode ter clonado do seu repositório fork. Os comandos git a seguir pressupõem que você tenha criado um remote "rails" que aponta para rails/rails.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Baixe novos commits e branches do repositório oficial:

```bash
$ git fetch rails
```

Faça o merge do novo conteúdo:

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

Atualize o seu fork:

```bash
$ git push fork main
$ git push fork my_new_branch
```

### Abra um Pull Request

Acesse o repositório do Rails que você acabou de enviar (por exemplo,
https://github.com/seu-nome-de-usuário/rails) e clique em "Pull Requests" na barra superior (logo acima do código).
Na próxima página, clique em "New pull request" no canto superior direito.

O pull request deve ter como destino o repositório base `rails/rails` e o branch `main`.
O repositório de origem será o seu trabalho (`seu-nome-de-usuário/rails`), e o branch será
o nome que você deu ao seu branch. Clique em "create pull request" quando estiver pronto.

Verifique se as alterações que você introduziu estão incluídas. Preencha alguns detalhes sobre
a sua correção potencial, usando o modelo de pull request fornecido. Quando terminar, clique em "Create
pull request".

### Obtenha um Feedback

A maioria dos pull requests passará por algumas iterações antes de serem mesclados.
Diferentes colaboradores às vezes têm opiniões diferentes, e frequentemente
as correções precisarão ser revisadas antes de poderem ser mescladas.

Alguns colaboradores do Rails têm notificações por e-mail do GitHub ativadas, mas
outros não têm. Além disso, (quase) todos que trabalham no Rails são
voluntários, então pode levar alguns dias para você obter o primeiro feedback em
um pull request. Não desanime! Às vezes é rápido; às vezes é lento. Assim
é a vida do código aberto.

Se já faz mais de uma semana e você não recebeu nada, talvez queira tentar
dar um empurrãozinho. Você pode usar o [fórum de discussão rubyonrails-core](https://discuss.rubyonrails.org/c/rubyonrails-core) para isso. Você também pode
deixar outro comentário no pull request.
Enquanto você espera por feedback em sua solicitação de pull, abra algumas outras solicitações de pull e dê feedback para outra pessoa! Eles vão apreciar da mesma forma que você aprecia o feedback em suas correções.

Observe que apenas as equipes Core e Committers têm permissão para mesclar alterações de código. Se alguém der feedback e "aprovar" suas alterações, eles podem não ter a capacidade ou a palavra final para mesclar sua alteração.

### Iterar conforme necessário

É totalmente possível que o feedback que você recebe sugira alterações. Não desanime: o objetivo de contribuir para um projeto de código aberto ativo é aproveitar o conhecimento da comunidade. Se as pessoas incentivarem você a ajustar seu código, vale a pena fazer os ajustes e enviar novamente. Se o feedback for de que seu código não será mesclado, você ainda pode pensar em lançá-lo como uma gem.

#### Combinando commits

Uma das coisas que podemos pedir a você é "combinar seus commits", o que irá combinar todos os seus commits em um único commit. Preferimos solicitações de pull que sejam um único commit. Isso facilita a portabilidade de alterações para branches estáveis, a combinação facilita a reversão de commits ruins e o histórico do git pode ser um pouco mais fácil de seguir. O Rails é um projeto grande e um monte de commits desnecessários podem adicionar muito ruído.

```bash
$ git fetch rails
$ git checkout minha_nova_branch
$ git rebase -i rails/main

< Escolha 'squash' para todos os seus commits, exceto o primeiro. >
< Edite a mensagem do commit para fazer sentido e descrever todas as suas alterações. >

$ git push fork minha_nova_branch --force-with-lease
```

Você deve ser capaz de atualizar a solicitação de pull no GitHub e ver que ela foi atualizada.

#### Atualizando uma solicitação de pull

Às vezes, você será solicitado a fazer algumas alterações no código que você já enviou. Isso pode incluir a correção de commits existentes. Nesse caso, o Git não permitirá que você envie as alterações, pois o branch enviado e o branch local não correspondem. Em vez de abrir uma nova solicitação de pull, você pode fazer um push forçado para o seu branch no GitHub, conforme descrito anteriormente na seção de combinação de commits:

```bash
$ git commit --amend
$ git push fork minha_nova_branch --force-with-lease
```

Isso atualizará o branch e a solicitação de pull no GitHub com seu novo código. Ao fazer um push forçado com `--force-with-lease`, o git atualizará o remoto de forma mais segura do que com um `-f` típico, que pode excluir o trabalho do remoto que você ainda não possui.

### Versões mais antigas do Ruby on Rails

Se você quiser adicionar uma correção para versões do Ruby on Rails anteriores à próxima versão, será necessário configurar e alternar para seu próprio branch de rastreamento local. Aqui está um exemplo para alternar para o branch 7-0-stable:

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

NOTA: Antes de trabalhar em versões mais antigas, verifique a [política de manutenção](maintenance_policy.html). Alterações não serão aceitas em versões que atingiram o fim da vida útil.

#### Portando para trás

As alterações que são mescladas em main são destinadas à próxima versão principal do Rails. Às vezes, pode ser benéfico propagar suas alterações de volta para branches estáveis para inclusão em lançamentos de manutenção. Geralmente, correções de segurança e correções de bugs são bons candidatos para uma portabilidade para trás, enquanto novos recursos e patches que alteram o comportamento esperado não serão aceitos. Em caso de dúvida, é melhor consultar um membro da equipe do Rails antes de portar suas alterações para evitar esforço desperdiçado.

Primeiro, certifique-se de que seu branch main está atualizado.

```bash
$ git checkout main
$ git pull --rebase
```

Faça o checkout do branch para o qual você está portando, por exemplo, `7-0-stable`, e certifique-se de que ele está atualizado:

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b meu-branch-de-portabilidade
```

Se você estiver portando uma solicitação de pull mesclada, encontre o commit da mesclagem e faça um cherry-pick:

```bash
$ git cherry-pick -m1 MERGE_SHA
```

Corrija quaisquer conflitos que ocorreram no cherry-pick, faça o push de suas alterações e abra uma PR apontando para o branch estável para o qual você está portando. Se você tiver um conjunto mais complexo de alterações, a documentação do [cherry-pick](https://git-scm.com/docs/git-cherry-pick) pode ajudar.

Contribuidores do Rails
------------------

Todas as contribuições recebem crédito em [Contribuidores do Rails](https://contributors.rubyonrails.org).
