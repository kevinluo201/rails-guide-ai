**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 95d91c83726e012162afc60c78688099
Ruby on Rails 4.1 Notas de Lançamento
======================================

Destaques no Rails 4.1:

* Carregador de aplicativos Spring
* `config/secrets.yml`
* Variantes do Action Pack
* Visualizações do Action Mailer

Estas notas de lançamento cobrem apenas as principais mudanças. Para saber sobre várias correções de bugs e mudanças, consulte os registros de alterações ou confira a [lista de commits](https://github.com/rails/rails/commits/4-1-stable) no repositório principal do Rails no GitHub.

--------------------------------------------------------------------------------

Atualizando para o Rails 4.1
----------------------------

Se você está atualizando um aplicativo existente, é uma ótima ideia ter uma boa cobertura de testes antes de prosseguir. Você também deve primeiro atualizar para o Rails 4.0, caso ainda não tenha feito isso, e garantir que seu aplicativo ainda funcione conforme o esperado antes de tentar atualizar para o Rails 4.1. Uma lista de coisas a serem observadas ao atualizar está disponível no guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1).

Recursos Principais
-------------------

### Carregador de Aplicativos Spring

O Spring é um pré-carregador de aplicativos Rails. Ele acelera o desenvolvimento mantendo seu aplicativo em execução em segundo plano, para que você não precise inicializá-lo toda vez que executar um teste, tarefa rake ou migração.

Novos aplicativos Rails 4.1 serão enviados com binstubs "springificados". Isso significa que `bin/rails` e `bin/rake` aproveitarão automaticamente os ambientes spring pré-carregados.

**Executando tarefas rake:**

```bash
$ bin/rake test:models
```

**Executando um comando Rails:**

```bash
$ bin/rails console
```

**Introspecção do Spring:**

```bash
$ bin/spring status
O Spring está em execução:

 1182 spring server | my_app | iniciado há 29 minutos
 3656 spring app    | my_app | iniciado há 23 segundos | modo de teste
 3746 spring app    | my_app | iniciado há 10 segundos | modo de desenvolvimento
```

Dê uma olhada no [README do Spring](https://github.com/rails/spring/blob/master/README.md) para ver todos os recursos disponíveis.

Consulte o guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#spring) para saber como migrar aplicativos existentes para usar esse recurso.

### `config/secrets.yml`

O Rails 4.1 gera um novo arquivo `secrets.yml` na pasta `config`. Por padrão, este arquivo contém a `secret_key_base` do aplicativo, mas também pode ser usado para armazenar outras informações secretas, como chaves de acesso para APIs externas.

As informações secretas adicionadas a este arquivo são acessíveis através de `Rails.application.secrets`. Por exemplo, com o seguinte `config/secrets.yml`:

```yaml
development:
  secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
  some_api_key: SOMEKEY
```

`Rails.application.secrets.some_api_key` retorna `SOMEKEY` no ambiente de desenvolvimento.

Consulte o guia [Atualizando o Ruby on Rails](upgrading_ruby_on_rails.html#config-secrets-yml) para saber como migrar aplicativos existentes para usar esse recurso.

### Variantes do Action Pack

Muitas vezes queremos renderizar templates HTML/JSON/XML diferentes para telefones, tablets e navegadores de desktop. As variantes facilitam isso.

A variante da requisição é uma especialização do formato da requisição, como `:tablet`, `:phone` ou `:desktop`.

Você pode definir a variante em um `before_action`:

```ruby
request.variant = :tablet if request.user_agent =~ /iPad/
```

Responda às variantes na ação da mesma forma que responde aos formatos:

```ruby
respond_to do |format|
  format.html do |html|
    html.tablet # renderiza app/views/projects/show.html+tablet.erb
    html.phone { extra_setup; render ... }
  end
end
```

Forneça templates separados para cada formato e variante:

```
app/views/projects/show.html.erb
app/views/projects/show.html+tablet.erb
app/views/projects/show.html+phone.erb
```

Você também pode simplificar a definição das variantes usando a sintaxe inline:

```ruby
respond_to do |format|
  format.js         { render "trash" }
  format.html.phone { redirect_to progress_path }
  format.html.none  { render "trash" }
end
```

### Visualizações do Action Mailer

As visualizações do Action Mailer fornecem uma maneira de ver como os emails são exibidos visitando uma URL especial que os renderiza.

Você implementa uma classe de visualização cujos métodos retornam o objeto de email que você deseja verificar:

```ruby
class NotifierPreview < ActionMailer::Preview
  def welcome
    Notifier.welcome(User.first)
  end
end
```

A visualização está disponível em http://localhost:3000/rails/mailers/notifier/welcome, e uma lista delas em http://localhost:3000/rails/mailers.

Por padrão, essas classes de visualização ficam em `test/mailers/previews`. Isso pode ser configurado usando a opção `preview_path`.

Consulte sua [documentação](https://api.rubyonrails.org/v4.1.0/classes/ActionMailer/Base.html#class-ActionMailer::Base-label-Previewing+emails) para obter uma descrição detalhada.

### Enums do Active Record

Declare um atributo enum em que os valores são mapeados para inteiros no banco de dados, mas podem ser consultados pelo nome.

```ruby
class Conversation < ActiveRecord::Base
  enum status: [ :active, :archived ]
end

conversation.archived!
conversation.active? # => false
conversation.status  # => "archived"

Conversation.archived # => Relação de todas as Conversations arquivadas

Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

Consulte sua [documentação](https://api.rubyonrails.org/v4.1.0/classes/ActiveRecord/Enum.html) para obter uma descrição detalhada.

### Verificadores de Mensagens

Verificadores de mensagens podem ser usados para gerar e verificar mensagens assinadas. Isso pode ser útil para transportar com segurança dados sensíveis, como tokens de "lembrar-me" e amigos.

O método `Rails.application.message_verifier` retorna um novo verificador de mensagens que assina mensagens com uma chave derivada de secret_key_base e o nome do verificador de mensagens fornecido:
```ruby
signed_token = Rails.application.message_verifier(:remember_me).generate(token)
Rails.application.message_verifier(:remember_me).verify(signed_token) # => token

Rails.application.message_verifier(:remember_me).verify(tampered_token)
# raises ActiveSupport::MessageVerifier::InvalidSignature
```

### Module#concerning

Uma maneira natural e de baixa cerimônia de separar responsabilidades dentro de uma classe:

```ruby
class Todo < ActiveRecord::Base
  concerning :EventTracking do
    included do
      has_many :events
    end

    def latest_event
      # ...
    end

    private
      def some_internal_method
        # ...
      end
  end
end
```

Este exemplo é equivalente a definir um módulo `EventTracking` inline,
estendendo-o com `ActiveSupport::Concern` e misturando-o na classe `Todo`.

Consulte sua
[documentação](https://api.rubyonrails.org/v4.1.0/classes/Module/Concerning.html)
para obter uma descrição detalhada e os casos de uso pretendidos.

### Proteção CSRF de tags `<script>` remotas

A proteção contra falsificação de solicitação entre sites (CSRF) agora cobre solicitações GET com respostas JavaScript também. Isso impede que um site de terceiros faça referência à sua URL JavaScript e tente executá-la para extrair dados sensíveis.

Isso significa que qualquer um dos seus testes que acessam URLs `.js` agora falharão na proteção CSRF, a menos que usem `xhr`. Atualize seus testes para serem explícitos sobre a expectativa de XmlHttpRequests. Em vez de `post :create, format: :js`, mude para o `xhr :post, :create, format: :js` explícito.


Railties
--------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/railties/CHANGELOG.md)
para obter alterações detalhadas.

### Remoções

* Removida a tarefa rake `update:application_controller`.

* Removido `Rails.application.railties.engines` obsoleto.

* Removido `threadsafe!` obsoleto do Rails Config.

* Removido `ActiveRecord::Generators::ActiveModel#update_attributes` obsoleto em
  favor de `ActiveRecord::Generators::ActiveModel#update`.

* Removida a opção `config.whiny_nils` obsoleta.

* Removidas as tarefas rake obsoletas para executar testes: `rake test:uncommitted` e
  `rake test:recent`.

### Mudanças notáveis

* O preloader de aplicativos Spring
  [Spring](https://github.com/rails/spring) agora é instalado
  por padrão para novas aplicações. Ele usa o grupo de desenvolvimento do
  `Gemfile`, portanto, não será instalado em
  produção. ([Pull Request](https://github.com/rails/rails/pull/12958))

* Variável de ambiente `BACKTRACE` para mostrar backtraces não filtrados para falhas nos testes. ([Commit](https://github.com/rails/rails/commit/84eac5dab8b0fe9ee20b51250e52ad7bfea36553))

* Exposto `MiddlewareStack#unshift` para configuração de ambiente. ([Pull Request](https://github.com/rails/rails/pull/12479))

* Adicionado o método `Application#message_verifier` para retornar um verificador de mensagens. ([Pull Request](https://github.com/rails/rails/pull/12995))

* O arquivo `test_help.rb`, que é exigido pelo auxiliar de teste gerado por padrão, manterá automaticamente seu banco de dados de teste atualizado com
  `db/schema.rb` (ou `db/structure.sql`). Ele gera um erro se
  recarregar o esquema não resolver todas as migrações pendentes. Desative
  com `config.active_record.maintain_test_schema = false`. ([Pull
  Request](https://github.com/rails/rails/pull/13528))

* Introduza `Rails.gem_version` como um método de conveniência para retornar
  `Gem::Version.new(Rails.version)`, sugerindo uma maneira mais confiável de realizar
  comparação de versões. ([Pull Request](https://github.com/rails/rails/pull/14103))


Action Pack
-----------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionpack/CHANGELOG.md)
para obter alterações detalhadas.

### Remoções

* Removido fallback de aplicativo Rails obsoleto para testes de integração, defina
  `ActionDispatch.test_app` em vez disso.

* Removida a configuração obsoleta `page_cache_extension`.

* Removido `ActionController::RecordIdentifier` obsoleto, use
  `ActionView::RecordIdentifier` em seu lugar.

* Removidas constantes obsoletas do Action Controller:

| Removido                            | Sucessor                       |
|:-----------------------------------|:--------------------------------|
| ActionController::AbstractRequest  | ActionDispatch::Request         |
| ActionController::Request          | ActionDispatch::Request         |
| ActionController::AbstractResponse | ActionDispatch::Response        |
| ActionController::Response         | ActionDispatch::Response        |
| ActionController::Routing          | ActionDispatch::Routing         |
| ActionController::Integration      | ActionDispatch::Integration     |
| ActionController::IntegrationTest  | ActionDispatch::IntegrationTest |

### Mudanças notáveis

* `protect_from_forgery` também impede tags `<script>` de origem cruzada.
  Atualize seus testes para usar `xhr :get, :foo, format: :js` em vez de
  `get :foo, format: :js`.
  ([Pull Request](https://github.com/rails/rails/pull/13345))

* `#url_for` recebe um hash com opções dentro de um
  array. ([Pull Request](https://github.com/rails/rails/pull/9599))

* Adicionado o método `session#fetch` que se comporta de forma semelhante a
  [Hash#fetch](https://www.ruby-doc.org/core-1.9.3/Hash.html#method-i-fetch),
  com a exceção de que o valor retornado é sempre salvo na
  sessão. ([Pull Request](https://github.com/rails/rails/pull/12692))

* Separou completamente o Action View do Action
  Pack. ([Pull Request](https://github.com/rails/rails/pull/11032))

* Registre as chaves afetadas por deep
  munge. ([Pull Request](https://github.com/rails/rails/pull/13813))

* Nova opção de configuração `config.action_dispatch.perform_deep_munge` para desativar
  "deep munging" de parâmetros que foi usado para resolver a vulnerabilidade de segurança
  CVE-2013-0155. ([Pull Request](https://github.com/rails/rails/pull/13188))

* Nova opção de configuração `config.action_dispatch.cookies_serializer` para especificar um
  serializador para os jars de cookies assinados e criptografados. (Pull Requests
  [1](https://github.com/rails/rails/pull/13692),
  [2](https://github.com/rails/rails/pull/13945) /
  [Mais Detalhes](upgrading_ruby_on_rails.html#cookies-serializer))

* Adicionados `render :plain`, `render :html` e `render
  :body`. ([Pull Request](https://github.com/rails/rails/pull/14062) /
  [Mais Detalhes](upgrading_ruby_on_rails.html#rendering-content-from-string))


Action Mailer
-------------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/actionmailer/CHANGELOG.md)
para obter alterações detalhadas.

### Mudanças notáveis

* Adicionado recurso de visualizações de mailer baseado na gem mail_view do 37 Signals. ([Commit](https://github.com/rails/rails/commit/d6dec7fcb6b8fddf8c170182d4fe64ecfc7b2261))

* Instrumente a geração de mensagens do Action Mailer. O tempo necessário para
  gerar uma mensagem é registrado no log. ([Pull Request](https://github.com/rails/rails/pull/12556))


Active Record
-------------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activerecord/CHANGELOG.md)
para obter alterações detalhadas.

### Remoções

* Removido o envio de nil obsoleto para os seguintes métodos de `SchemaCache`:
  `primary_keys`, `tables`, `columns` e `columns_hash`.

* Removido o filtro de bloco obsoleto de `ActiveRecord::Migrator#migrate`.

* Removido o construtor de String obsoleto de `ActiveRecord::Migrator`.

* Removido o uso obsoleto de `scope` sem passar um objeto chamável.

* Removido `transaction_joinable=` obsoleto em favor de `begin_transaction`
  com a opção `:joinable`.

* Removido `decrement_open_transactions` obsoleto.

* Removido `increment_open_transactions` obsoleto.
* Removido o método `PostgreSQLAdapter#outside_transaction?` obsoleto. Agora você pode usar `#transaction_open?` no lugar.

* Removido o método obsoleto `ActiveRecord::Fixtures.find_table_name` em favor de `ActiveRecord::Fixtures.default_fixture_model_name`.

* Removido o método `columns_for_remove` obsoleto de `SchemaStatements`.

* Removido o método obsoleto `SchemaStatements#distinct`.

* Movido o `ActiveRecord::TestCase` obsoleto para o conjunto de testes do Rails. A classe não é mais pública e é usada apenas para testes internos do Rails.

* Removido o suporte à opção obsoleta `:restrict` para `:dependent` em associações.

* Removido o suporte às opções obsoletas `:delete_sql`, `:insert_sql`, `:finder_sql` e `:counter_sql` em associações.

* Removido o método obsoleto `type_cast_code` de Column.

* Removido o método obsoleto `ActiveRecord::Base#connection`. Certifique-se de acessá-lo através da classe.

* Removido o aviso de depreciação para `auto_explain_threshold_in_seconds`.

* Removida a opção obsoleta `:distinct` de `Relation#count`.

* Removidos os métodos obsoletos `partial_updates`, `partial_updates?` e `partial_updates=`.

* Removido o método obsoleto `scoped`.

* Removido o método obsoleto `default_scopes?`.

* Removidas as referências implícitas de junção que foram obsoletas na versão 4.0.

* Removida a dependência do `activerecord-deprecated_finders`. Consulte [o README do gem](https://github.com/rails/activerecord-deprecated_finders#active-record-deprecated-finders) para mais informações.

* Removido o uso de `implicit_readonly`. Use o método `readonly` explicitamente para marcar registros como `readonly`. ([Pull Request](https://github.com/rails/rails/pull/10769))

### Depreciações

* Depreciado o método `quoted_locking_column`, que não é usado em nenhum lugar.

* Depreciado o método `ConnectionAdapters::SchemaStatements#distinct`, pois não é mais usado internamente. ([Pull Request](https://github.com/rails/rails/pull/10556))

* Depreciadas as tarefas `rake db:test:*`, pois o banco de dados de teste agora é mantido automaticamente. Consulte as notas de lançamento do railties. ([Pull Request](https://github.com/rails/rails/pull/13528))

* Depreciados `ActiveRecord::Base.symbolized_base_class` e `ActiveRecord::Base.symbolized_sti_name`, que não têm substituição. [Commit](https://github.com/rails/rails/commit/97e7ca48c139ea5cce2fa9b4be631946252a1ebd)

### Mudanças notáveis

* As scopes padrão não são mais substituídas por condições encadeadas.

  Antes dessa mudança, quando você definia um `default_scope` em um modelo, ele era substituído por condições encadeadas no mesmo campo. Agora ele é mesclado como qualquer outra scope. [Mais detalhes](upgrading_ruby_on_rails.html#changes-on-default-scopes).

* Adicionado `ActiveRecord::Base.to_param` para URLs "bonitos" derivados de um atributo ou método do modelo. ([Pull Request](https://github.com/rails/rails/pull/12891))

* Adicionado `ActiveRecord::Base.no_touching`, que permite ignorar o toque em modelos. ([Pull Request](https://github.com/rails/rails/pull/12772))

* Unificar a conversão de tipo booleano para `MysqlAdapter` e `Mysql2Adapter`. `type_cast` retornará `1` para `true` e `0` para `false`. ([Pull Request](https://github.com/rails/rails/pull/12425))

* `.unscope` agora remove as condições especificadas em `default_scope`. ([Commit](https://github.com/rails/rails/commit/94924dc32baf78f13e289172534c2e71c9c8cade))

* Adicionado `ActiveRecord::QueryMethods#rewhere`, que sobrescreverá uma condição `where` existente com nome. ([Commit](https://github.com/rails/rails/commit/f950b2699f97749ef706c6939a84dfc85f0b05f2))

* Estendido `ActiveRecord::Base#cache_key` para aceitar uma lista opcional de atributos de data e hora, em que o mais alto será usado. ([Commit](https://github.com/rails/rails/commit/e94e97ca796c0759d8fcb8f946a3bbc60252d329))

* Adicionado `ActiveRecord::Base#enum` para declarar atributos de enumeração em que os valores são mapeados para inteiros no banco de dados, mas podem ser consultados por nome. ([Commit](https://github.com/rails/rails/commit/db41eb8a6ea88b854bf5cd11070ea4245e1639c5))

* Converter valores JSON na gravação, para que o valor seja consistente com a leitura do banco de dados. ([Pull Request](https://github.com/rails/rails/pull/12643))

* Converter valores hstore na gravação, para que o valor seja consistente com a leitura do banco de dados. ([Commit](https://github.com/rails/rails/commit/5ac2341fab689344991b2a4817bd2bc8b3edac9d))

* Tornar `next_migration_number` acessível para geradores de terceiros. ([Pull Request](https://github.com/rails/rails/pull/12407))

* Chamar `update_attributes` agora lançará um `ArgumentError` sempre que receber um argumento `nil`. Mais especificamente, lançará um erro se o argumento passado não responder a `stringify_keys`. ([Pull Request](https://github.com/rails/rails/pull/9860))

* `CollectionAssociation#first`/`#last` (por exemplo, `has_many`) usam uma consulta `LIMIT` para buscar resultados em vez de carregar toda a coleção. ([Pull Request](https://github.com/rails/rails/pull/12137))

* `inspect` nas classes de modelo do Active Record não inicia uma nova conexão. Isso significa que chamar `inspect`, quando o banco de dados está ausente, não lançará mais uma exceção. ([Pull Request](https://github.com/rails/rails/pull/11014))

* Restrições de coluna removidas para `count`, deixando o banco de dados lançar um erro se o SQL for inválido. ([Pull Request](https://github.com/rails/rails/pull/10710))

* O Rails agora detecta automaticamente associações inversas. Se você não definir a opção `:inverse_of` na associação, o Active Record adivinhará a associação inversa com base em heurísticas. ([Pull Request](https://github.com/rails/rails/pull/10886))

* Lidar com atributos com alias em ActiveRecord::Relation. Ao usar chaves de símbolo, o ActiveRecord agora traduzirá nomes de atributos com alias para o nome real da coluna usado no banco de dados. ([Pull Request](https://github.com/rails/rails/pull/7839))

* O ERB nos arquivos de fixture não é mais avaliado no contexto do objeto principal. Os métodos auxiliares usados por várias fixtures devem ser definidos em módulos incluídos em `ActiveRecord::FixtureSet.context_class`. ([Pull Request](https://github.com/rails/rails/pull/13022))

* Não criar ou excluir o banco de dados de teste se RAILS_ENV for especificado explicitamente. ([Pull Request](https://github.com/rails/rails/pull/13629))

* `Relation` não possui mais métodos mutadores como `#map!` e `#delete_if`. Converta para um `Array` chamando `#to_a` antes de usar esses métodos. ([Pull Request](https://github.com/rails/rails/pull/13314))

* `find_in_batches`, `find_each`, `Result#each` e `Enumerable#index_by` agora retornam um `Enumerator` que pode calcular seu tamanho. ([Pull Request](https://github.com/rails/rails/pull/13938))

* `scope`, `enum` e Associações agora lançam um erro em caso de conflitos de nome "perigosos". ([Pull Request](https://github.com/rails/rails/pull/13450), [Pull Request](https://github.com/rails/rails/pull/13896))

* Os métodos `second` a `fifth` agem como o localizador `first`. ([Pull Request](https://github.com/rails/rails/pull/13757))

* Fazer com que `touch` acione os callbacks `after_commit` e `after_rollback`. ([Pull Request](https://github.com/rails/rails/pull/12031))
* Habilitar índices parciais para `sqlite >= 3.8.0`.
  ([Pull Request](https://github.com/rails/rails/pull/13350))

* Tornar `change_column_null`
  reversível. ([Commit](https://github.com/rails/rails/commit/724509a9d5322ff502aefa90dd282ba33a281a96))

* Adicionada uma flag para desabilitar o dump do esquema após a migração. Isso é definido como `false`
  por padrão no ambiente de produção para novas aplicações.
  ([Pull Request](https://github.com/rails/rails/pull/13948))

Active Model
------------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activemodel/CHANGELOG.md)
para obter detalhes das alterações.

### Depreciações

* Depreciar `Validator#setup`. Isso agora deve ser feito manualmente no
  construtor do validador. ([Commit](https://github.com/rails/rails/commit/7d84c3a2f7ede0e8d04540e9c0640de7378e9b3a))

### Alterações notáveis

* Adicionados novos métodos de API `reset_changes` e `changes_applied` para
  `ActiveModel::Dirty` que controlam o estado das alterações.

* Possibilidade de especificar vários contextos ao definir uma
  validação. ([Pull Request](https://github.com/rails/rails/pull/13754))

* `attribute_changed?` agora aceita um hash para verificar se o atributo foi alterado
  `:from` e/ou `:to` um determinado valor. ([Pull Request](https://github.com/rails/rails/pull/13131))


Active Support
--------------

Consulte o
[Changelog](https://github.com/rails/rails/blob/4-1-stable/activesupport/CHANGELOG.md)
para obter detalhes das alterações.


### Remoções

* Removida a dependência `MultiJSON`. Como resultado, `ActiveSupport::JSON.decode`
  não aceita mais um hash de opções para `MultiJSON`. ([Pull Request](https://github.com/rails/rails/pull/10576) / [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Removido suporte para o gancho `encode_json` usado para codificar objetos personalizados em
  JSON. Essa funcionalidade foi extraída para o [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder)
  gem.
  ([Pull Request relacionado](https://github.com/rails/rails/pull/12183) /
  [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Removido `ActiveSupport::JSON::Variable` depreciado sem substituição.

* Removidas as extensões de núcleo `String#encoding_aware?` (`core_ext/string/encoding`) depreciadas.

* Removido `DateTime.local_offset` depreciado em favor de `DateTime.civil_from_format`.

* Removidas as extensões de núcleo `Logger` (`core_ext/logger.rb`) depreciadas.

* Removidos `Time#time_with_datetime_fallback`, `Time#utc_time` e
  `Time#local_time` depreciados em favor de `Time#utc` e `Time#local`.

* Removido `Hash#diff` depreciado sem substituição.

* Removido `Date#to_time_in_current_zone` depreciado em favor de `Date#in_time_zone`.

* Removido `Proc#bind` depreciado sem substituição.

* Removidos `Array#uniq_by` e `Array#uniq_by!` depreciados, use `Array#uniq` e `Array#uniq!` nativos em vez disso.

* Removido `ActiveSupport::BasicObject`, use
  `ActiveSupport::ProxyObject` em vez disso.

* Removido `BufferedLogger`, use `ActiveSupport::Logger` em vez disso.

* Removidos os métodos `assert_present` e `assert_blank`, use `assert
  object.blank?` e `assert object.present?` em vez disso.

* Remover o método `#filter` depreciado para objetos de filtro, use o método correspondente em vez disso (por exemplo, `#before` para um filtro antes).

* Removida a irregularidade de inflexão 'cow' => 'kine' do
  inflections padrão. ([Commit](https://github.com/rails/rails/commit/c300dca9963bda78b8f358dbcb59cabcdc5e1dc9))

### Depreciações

* Depreciados `Numeric#{ago,until,since,from_now}`, espera-se que o usuário
  converta explicitamente o valor em uma AS::Duration, ou seja, `5.ago` => `5.seconds.ago`
  ([Pull Request](https://github.com/rails/rails/pull/12389))

* Depreciado o caminho de require `active_support/core_ext/object/to_json`. Requer
  `active_support/core_ext/object/json` em vez disso. ([Pull Request](https://github.com/rails/rails/pull/12203))

* Depreciado `ActiveSupport::JSON::Encoding::CircularReferenceError`. Essa funcionalidade
  foi extraída para o [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder)
  gem.
  ([Pull Request](https://github.com/rails/rails/pull/12785) /
  [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Depreciado a opção `ActiveSupport.encode_big_decimal_as_string`. Essa funcionalidade foi
  extraída para o [activesupport-json_encoder](https://github.com/rails/activesupport-json_encoder)
  gem.
  ([Pull Request](https://github.com/rails/rails/pull/13060) /
  [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Depreciar a serialização personalizada de `BigDecimal`. ([Pull Request](https://github.com/rails/rails/pull/13911))

### Alterações notáveis

* O codificador JSON do `ActiveSupport` foi reescrito para aproveitar o
  gem JSON em vez de fazer codificação personalizada em Ruby puro.
  ([Pull Request](https://github.com/rails/rails/pull/12183) /
  [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Melhorada a compatibilidade com o gem JSON.
  ([Pull Request](https://github.com/rails/rails/pull/12862) /
  [Mais detalhes](upgrading_ruby_on_rails.html#changes-in-json-handling))

* Adicionados `ActiveSupport::Testing::TimeHelpers#travel` e `#travel_to`. Esses
  métodos alteram o tempo atual para o tempo ou duração fornecidos, substituindo
  `Time.now` e `Date.today`.

* Adicionado `ActiveSupport::Testing::TimeHelpers#travel_back`. Este método retorna
  o tempo atual para o estado original, removendo as substituições adicionadas por `travel`
  e `travel_to`. ([Pull Request](https://github.com/rails/rails/pull/13884))

* Adicionado `Numeric#in_milliseconds`, como `1.hour.in_milliseconds`, para que possamos usá-los em funções JavaScript como
  `getTime()`. ([Commit](https://github.com/rails/rails/commit/423249504a2b468d7a273cbe6accf4f21cb0e643))

* Adicionados métodos `Date#middle_of_day`, `DateTime#middle_of_day` e `Time#middle_of_day`.
  Também adicionados `midday`, `noon`, `at_midday`, `at_noon` e
  `at_middle_of_day` como
  aliases. ([Pull Request](https://github.com/rails/rails/pull/10879))

* Adicionados `Date#all_week/month/quarter/year` para gerar intervalos de datas.
  ([Pull Request](https://github.com/rails/rails/pull/9685))

* Adicionados `Time.zone.yesterday` e
  `Time.zone.tomorrow`. ([Pull Request](https://github.com/rails/rails/pull/12822))

* Adicionado `String#remove(pattern)` como uma forma abreviada do padrão comum de
  `String#gsub(pattern,'')`. ([Commit](https://github.com/rails/rails/commit/5da23a3f921f0a4a3139495d2779ab0d3
