**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b21dbc892c0a841f1bc1fafdf5ee0126
Ruby on Rails 4.0 Notas de Lançamento
======================================

Destaques no Rails 4.0:

* Ruby 2.0 preferido; 1.9.3+ requerido
* Parâmetros Fortes
* Turbolinks
* Caching em forma de Boneca Russa

Estas notas de lançamento cobrem apenas as mudanças principais. Para saber sobre várias correções de bugs e mudanças, por favor, consulte os registros de alterações ou confira a [lista de commits](https://github.com/rails/rails/commits/4-0-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 4.0
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de começar. Você também deve primeiro atualizar para o Rails 3.2, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione como esperado antes de tentar uma atualização para o Rails 4.0. Uma lista de coisas a observar ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-3-2-to-rails-4-0).

Criando um aplicativo Rails 4.0
-------------------------------

```bash
# Você deve ter o RubyGem 'rails' instalado
$ rails new myapp
$ cd myapp
```

### Vendendo Gems

O Rails agora usa um `Gemfile` na raiz do aplicativo para determinar as gems que você precisa para iniciar seu aplicativo. Este `Gemfile` é processado pela gem [Bundler](https://github.com/carlhuda/bundler), que então instala todas as dependências. Ele até mesmo pode instalar todas as dependências localmente para o seu aplicativo, para que ele não dependa das gems do sistema.

Mais informações: [Página do Bundler](https://bundler.io)

### Vivendo no Limite

O `Bundler` e o `Gemfile` tornam fácil congelar seu aplicativo Rails com o novo comando `bundle` dedicado. Se você quiser agrupar diretamente do repositório Git, você pode passar a flag `--edge`:

```bash
$ rails new myapp --edge
```

Se você tiver um checkout local do repositório do Rails e quiser gerar um aplicativo usando isso, você pode passar a flag `--dev`:

```bash
$ ruby /caminho/para/rails/railties/bin/rails new myapp --dev
```

Principais Recursos
-------------------

[![Rails 4.0](images/4_0_release_notes/rails4_features.png)](https://guides.rubyonrails.org/images/4_0_release_notes/rails4_features.png)

### Atualização

* **Ruby 1.9.3** ([commit](https://github.com/rails/rails/commit/a0380e808d3dbd2462df17f5d3b7fcd8bd812496)) - Ruby 2.0 preferido; 1.9.3+ requerido
* **[Nova política de depreciação](https://www.youtube.com/watch?v=z6YgD6tVPQs)** - Recursos depreciados são avisos no Rails 4.0 e serão removidos no Rails 4.1.
* **Caching de página e ação do ActionPack** ([commit](https://github.com/rails/rails/commit/b0a7068564f0c95e7ef28fc39d0335ed17d93e90)) - O caching de página e ação são extraídos para uma gem separada. O caching de página e ação requer muita intervenção manual (expirar caches manualmente quando os objetos do modelo subjacente são atualizados). Em vez disso, use o caching em forma de Boneca Russa.
* **Observadores do ActiveRecord** ([commit](https://github.com/rails/rails/commit/ccecab3ba950a288b61a516bf9b6962e384aae0b)) - Os observadores são extraídos para uma gem separada. Os observadores são necessários apenas para o caching de página e ação, e podem levar a código spaghetti.
* **Armazenamento de sessão do ActiveRecord** ([commit](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad)) - O armazenamento de sessão do ActiveRecord é extraído para uma gem separada. Armazenar sessões em SQL é custoso. Em vez disso, use sessões de cookie, sessões de memcache ou um armazenamento de sessão personalizado.
* **Proteção de atribuição em massa do ActiveModel** ([commit](https://github.com/rails/rails/commit/f8c9a4d3e88181cee644f91e1342bfe896ca64c6)) - A proteção de atribuição em massa do Rails 3 é depreciada. Em vez disso, use parâmetros fortes.
* **ActiveResource** ([commit](https://github.com/rails/rails/commit/f1637bf2bb00490203503fbd943b73406e043d1d)) - ActiveResource é extraído para uma gem separada. O ActiveResource não era amplamente utilizado.
* **vendor/plugins removido** ([commit](https://github.com/rails/rails/commit/853de2bd9ac572735fa6cf59fcf827e485a231c3)) - Use um `Gemfile` para gerenciar as gems instaladas.

### ActionPack

* **Parâmetros fortes** ([commit](https://github.com/rails/rails/commit/a8f6d5c6450a7fe058348a7f10a908352bb6c7fc)) - Permita apenas parâmetros permitidos para atualizar objetos do modelo (`params.permit(:title, :text)`).
* **Preocupações de roteamento** ([commit](https://github.com/rails/rails/commit/0dd24728a088fcb4ae616bb5d62734aca5276b1b)) - Na DSL de roteamento, extraia sub-rotas comuns (`comments` de `/posts/1/comments` e `/videos/1/comments`).
* **ActionController::Live** ([commit](https://github.com/rails/rails/commit/af0a9f9eefaee3a8120cfd8d05cbc431af376da3)) - Transmita JSON com `response.stream`.
* **ETags declarativos** ([commit](https://github.com/rails/rails/commit/ed5c938fa36995f06d4917d9543ba78ed506bb8d)) - Adicione adições de etag no nível do controlador que farão parte do cálculo do etag da ação.
* **[Caching em forma de Boneca Russa](https://37signals.com/svn/posts/3113-how-key-based-cache-expiration-works)** ([commit](https://github.com/rails/rails/commit/4154bf012d2bec2aae79e4a49aa94a70d3e91d49)) - Faça cache de fragmentos aninhados de visualizações. Cada fragmento expira com base em um conjunto de dependências (uma chave de cache). A chave de cache geralmente é um número de versão do template e um objeto do modelo.
* **Turbolinks** ([commit](https://github.com/rails/rails/commit/e35d8b18d0649c0ecc58f6b73df6b3c8d0c6bb74)) - Sirva apenas uma página HTML inicial. Quando o usuário navegar para outra página, use pushState para atualizar a URL e use AJAX para atualizar o título e o corpo.
* **Desacoplar ActionView de ActionController** ([commit](https://github.com/rails/rails/commit/78b0934dd1bb84e8f093fb8ef95ca99b297b51cd)) - ActionView foi desacoplado do ActionPack e será movido para uma gem separada no Rails 4.1.
* **Não depender do ActiveModel** ([commit](https://github.com/rails/rails/commit/166dbaa7526a96fdf046f093f25b0a134b277a68)) - ActionPack não depende mais do ActiveModel.
### Geral

 * **ActiveModel::Model** ([commit](https://github.com/rails/rails/commit/3b822e91d1a6c4eab0064989bbd07aae3a6d0d08)) - `ActiveModel::Model`, uma mistura para fazer objetos Ruby normais funcionarem com o ActionPack (por exemplo, para `form_for`).
 * **Nova API de escopo** ([commit](https://github.com/rails/rails/commit/50cbc03d18c5984347965a94027879623fc44cce)) - Os escopos devem sempre usar chamáveis.
 * **Despejo de cache de esquema** ([commit](https://github.com/rails/rails/commit/5ca4fc95818047108e69e22d200e7a4a22969477)) - Para melhorar o tempo de inicialização do Rails, em vez de carregar o esquema diretamente do banco de dados, carregue o esquema de um arquivo de despejo.
 * **Suporte para especificar o nível de isolamento da transação** ([commit](https://github.com/rails/rails/commit/392eeecc11a291e406db927a18b75f41b2658253)) - Escolha se leituras repetíveis ou desempenho aprimorado (menos bloqueio) são mais importantes.
 * **Dalli** ([commit](https://github.com/rails/rails/commit/82663306f428a5bbc90c511458432afb26d2f238)) - Use o cliente de memcache Dalli para a loja de memcache.
 * **Notificações de início e término** ([commit](https://github.com/rails/rails/commit/f08f8750a512f741acb004d0cebe210c5f949f28)) - O Active Support Instrumentation relata notificações de início e término para assinantes.
 * **Thread safe por padrão** ([commit](https://github.com/rails/rails/commit/5d416b907864d99af55ebaa400fff217e17570cd)) - O Rails pode ser executado em servidores de aplicativos com threads sem configuração adicional.

NOTA: Verifique se as gems que você está usando são thread-safe.

 * **Verbo PATCH** ([commit](https://github.com/rails/rails/commit/eed9f2539e3ab5a68e798802f464b8e4e95e619e)) - No Rails, PATCH substitui PUT. PATCH é usado para atualizações parciais de recursos.

### Segurança

* **match não captura tudo** ([commit](https://github.com/rails/rails/commit/90d2802b71a6e89aedfe40564a37bd35f777e541)) - Na DSL de roteamento, o match requer que o verbo HTTP seja especificado.
* **entidades HTML escapadas por padrão** ([commit](https://github.com/rails/rails/commit/5f189f41258b83d49012ec5a0678d827327e7543)) - Strings renderizadas em erb são escapadas a menos que sejam envolvidas com `raw` ou `html_safe` seja chamado.
* **Novos cabeçalhos de segurança** ([commit](https://github.com/rails/rails/commit/6794e92b204572d75a07bd6413bdae6ae22d5a82)) - O Rails envia os seguintes cabeçalhos com cada solicitação HTTP: `X-Frame-Options` (impede o clickjacking, proibindo o navegador de incorporar a página em um quadro), `X-XSS-Protection` (pede ao navegador para interromper a injeção de script) e `X-Content-Type-Options` (impede o navegador de abrir um jpeg como um exe).

Extração de recursos para gems
---------------------------

No Rails 4.0, vários recursos foram extraídos para gems. Você pode simplesmente adicionar as gems extraídas ao seu `Gemfile` para trazer a funcionalidade de volta.

* Métodos de busca baseados em hash e dinâmicos ([GitHub](https://github.com/rails/activerecord-deprecated_finders))
* Proteção contra atribuição em massa em modelos Active Record ([GitHub](https://github.com/rails/protected_attributes), [Pull Request](https://github.com/rails/rails/pull/7251))
* ActiveRecord::SessionStore ([GitHub](https://github.com/rails/activerecord-session_store), [Pull Request](https://github.com/rails/rails/pull/7436))
* Observadores do Active Record ([GitHub](https://github.com/rails/rails-observers), [Commit](https://github.com/rails/rails/commit/39e85b3b90c58449164673909a6f1893cba290b2))
* Active Resource ([GitHub](https://github.com/rails/activeresource), [Pull Request](https://github.com/rails/rails/pull/572), [Blog](http://yetimedia-blog-blog.tumblr.com/post/35233051627/activeresource-is-dead-long-live-activeresource))
* Action Caching ([GitHub](https://github.com/rails/actionpack-action_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Page Caching ([GitHub](https://github.com/rails/actionpack-page_caching), [Pull Request](https://github.com/rails/rails/pull/7833))
* Sprockets ([GitHub](https://github.com/rails/sprockets-rails))
* Testes de desempenho ([GitHub](https://github.com/rails/rails-perftest), [Pull Request](https://github.com/rails/rails/pull/8876))

Documentação
-------------

* Os guias foram reescritos em Markdown com suporte ao GitHub Flavored Markdown.

* Os guias têm um design responsivo.

Railties
--------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/railties/CHANGELOG.md) para obter alterações detalhadas.

### Mudanças notáveis

* Novos locais de teste `test/models`, `test/helpers`, `test/controllers` e `test/mailers`. Tarefas rake correspondentes também foram adicionadas. ([Pull Request](https://github.com/rails/rails/pull/7878))

* Os executáveis do seu aplicativo agora estão no diretório `bin/`. Execute `rake rails:update:bin` para obter `bin/bundle`, `bin/rails` e `bin/rake`.

* Threadsafe ativado por padrão.

* A capacidade de usar um construtor personalizado passando `--builder` (ou `-b`) para `rails new` foi removida. Considere usar modelos de aplicativo em vez disso. ([Pull Request](https://github.com/rails/rails/pull/9401))

### Depreciações

* `config.threadsafe!` está obsoleto em favor de `config.eager_load`, que fornece um controle mais refinado sobre o que é carregado antecipadamente.

* `Rails::Plugin` foi removido. Em vez de adicionar plugins ao `vendor/plugins`, use gems ou bundler com dependências de caminho ou git.

Action Mailer
-------------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionmailer/CHANGELOG.md) para obter alterações detalhadas.

### Mudanças notáveis

### Depreciações

Active Model
------------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/activemodel/CHANGELOG.md) para obter alterações detalhadas.
### Mudanças notáveis

* Adicionado `ActiveModel::ForbiddenAttributesProtection`, um módulo simples para proteger atributos de atribuição em massa quando atributos não permitidos são passados.

* Adicionado `ActiveModel::Model`, uma mistura para fazer objetos Ruby funcionarem com o Action Pack sem precisar de configurações adicionais.

### Descontinuações

Active Support
--------------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/activesupport/CHANGELOG.md) para obter detalhes das mudanças.

### Mudanças notáveis

* Substituída a gem `memcache-client` obsoleta por `dalli` em `ActiveSupport::Cache::MemCacheStore`.

* Otimizado `ActiveSupport::Cache::Entry` para reduzir o uso de memória e processamento.

* As inflexões agora podem ser definidas por localidade. `singularize` e `pluralize` aceitam a localidade como um argumento adicional.

* `Object#try` agora retornará nil em vez de lançar um NoMethodError se o objeto receptor não implementar o método, mas você ainda pode obter o comportamento antigo usando o novo `Object#try!`.

* `String#to_date` agora gera `ArgumentError: data inválida` em vez de `NoMethodError: undefined method 'div' for nil:NilClass`
  quando uma data inválida é fornecida. Agora é o mesmo que `Date.parse` e aceita mais datas inválidas do que na versão 3.x, como:

    ```ruby
    # ActiveSupport 3.x
    "asdf".to_date # => NoMethodError: undefined method `div' for nil:NilClass
    "333".to_date # => NoMethodError: undefined method `div' for nil:NilClass

    # ActiveSupport 4
    "asdf".to_date # => ArgumentError: data inválida
    "333".to_date # => Fri, 29 Nov 2013
    ```

### Descontinuações

* Descontinuado o método `ActiveSupport::TestCase#pending`, use `skip` do minitest em seu lugar.

* `ActiveSupport::Benchmarkable#silence` foi descontinuado devido à falta de segurança de thread. Ele será removido sem substituição no Rails 4.1.

* `ActiveSupport::JSON::Variable` está obsoleto. Defina seus próprios métodos `#as_json` e `#encode_json` para literais de string JSON personalizados.

* Descontinua o método de compatibilidade `Module#local_constant_names`, use `Module#local_constants` em seu lugar (que retorna símbolos).

* `ActiveSupport::BufferedLogger` está obsoleto. Use `ActiveSupport::Logger` ou o logger da biblioteca padrão do Ruby.

* Descontinuado `assert_present` e `assert_blank` em favor de `assert object.blank?` e `assert object.present?`

Action Pack
-----------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/actionpack/CHANGELOG.md) para obter detalhes das mudanças.

### Mudanças notáveis

* Alterado o estilo da folha de estilos das páginas de exceção para o modo de desenvolvimento. Além disso, exibe também a linha de código e o fragmento que geraram a exceção em todas as páginas de exceção.

### Descontinuações


Active Record
-------------

Consulte o [Changelog](https://github.com/rails/rails/blob/4-0-stable/activerecord/CHANGELOG.md) para obter detalhes das mudanças.

### Mudanças notáveis

* Melhoradas as formas de escrever migrações `change`, tornando os antigos métodos `up` e `down` desnecessários.

    * Os métodos `drop_table` e `remove_column` agora são reversíveis, desde que as informações necessárias sejam fornecidas.
      O método `remove_column` costumava aceitar vários nomes de colunas; em vez disso, use `remove_columns` (que não é reversível).
      O método `change_table` também é reversível, desde que seu bloco não chame `remove`, `change` ou `change_default`

    * O novo método `reversible` permite especificar o código a ser executado ao migrar para cima ou para baixo.
      Consulte o [Guia de Migração](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#using-reversible)

    * O novo método `revert` irá reverter uma migração inteira ou o bloco fornecido.
      Se estiver migrando para baixo, a migração/bloco fornecido é executado normalmente.
      Consulte o [Guia de Migração](https://github.com/rails/rails/blob/main/guides/source/active_record_migrations.md#reverting-previous-migrations)

* Adicionado suporte ao tipo de array do PostgreSQL. Qualquer tipo de dado pode ser usado para criar uma coluna de array, com suporte completo para migração e geração de esquema.

* Adicionado `Relation#load` para carregar explicitamente o registro e retornar `self`.

* `Model.all` agora retorna uma `ActiveRecord::Relation`, em vez de um array de registros. Use `Relation#to_a` se realmente desejar um array. Em alguns casos específicos, isso pode causar problemas ao atualizar.
* Adicionado `ActiveRecord::Migration.check_pending!` que gera um erro se houver migrações pendentes.

* Adicionado suporte a codificadores personalizados para `ActiveRecord::Store`. Agora você pode definir seu codificador personalizado desta forma:

        store :settings, accessors: [ :color, :homepage ], coder: JSON

* As conexões `mysql` e `mysql2` definirão `SQL_MODE=STRICT_ALL_TABLES` por padrão para evitar perda silenciosa de dados. Isso pode ser desativado especificando `strict: false` no seu `database.yml`.

* Removido IdentityMap.

* Removida a execução automática de consultas EXPLAIN. A opção `active_record.auto_explain_threshold_in_seconds` não é mais usada e deve ser removida.

* Adiciona `ActiveRecord::NullRelation` e `ActiveRecord::Relation#none` implementando o padrão de objeto nulo para a classe Relation.

* Adicionado auxiliar de migração `create_join_table` para criar tabelas de junção HABTM.

* Permite a criação de registros hstore no PostgreSQL.

### Descontinuações

* Descontinuada a API de busca antiga baseada em hash. Isso significa que os métodos que anteriormente aceitavam "opções de busca" não o fazem mais.

* Todos os métodos dinâmicos, exceto `find_by_...` e `find_by_...!`, estão descontinuados. Aqui está como você pode reescrever o código:

      * `find_all_by_...` pode ser reescrito usando `where(...)`.
      * `find_last_by_...` pode ser reescrito usando `where(...).last`.
      * `scoped_by_...` pode ser reescrito usando `where(...)`.
      * `find_or_initialize_by_...` pode ser reescrito usando `find_or_initialize_by(...)`.
      * `find_or_create_by_...` pode ser reescrito usando `find_or_create_by(...)`.
      * `find_or_create_by_...!` pode ser reescrito usando `find_or_create_by!(...)`.

Créditos
-------

Consulte a [lista completa de contribuidores para o Rails](https://contributors.rubyonrails.org/) para ver as muitas pessoas que passaram muitas horas fazendo do Rails o framework estável e robusto que ele é. Parabéns a todos eles.
