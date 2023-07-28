**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Guia de migração do modo "classic" para o modo "zeitwerk"
===========================================================

Este guia documenta como migrar aplicativos Rails do modo "classic" para o modo "zeitwerk".

Após ler este guia, você saberá:

* O que são os modos "classic" e "zeitwerk"
* Por que mudar do modo "classic" para o modo "zeitwerk"
* Como ativar o modo "zeitwerk"
* Como verificar se o seu aplicativo está rodando no modo "zeitwerk"
* Como verificar se o seu projeto é carregado corretamente na linha de comando
* Como verificar se o seu projeto é carregado corretamente no conjunto de testes
* Como lidar com possíveis casos especiais
* Novos recursos no Zeitwerk que você pode aproveitar

--------------------------------------------------------------------------------

O que são os modos "classic" e "zeitwerk"?
--------------------------------------------------------

Desde o início e até o Rails 5, o Rails usava um carregador automático implementado no Active Support. Esse carregador automático é conhecido como "classic" e ainda está disponível no Rails 6.x. O Rails 7 não inclui mais esse carregador automático.

A partir do Rails 6, o Rails vem com uma nova e melhor forma de carregamento automático, que delega para a gem [Zeitwerk](https://github.com/fxn/zeitwerk). Esse é o modo "zeitwerk". Por padrão, os aplicativos que carregam as configurações padrão do framework 6.0 e 6.1 rodam no modo "zeitwerk", e esse é o único modo disponível no Rails 7.


Por que mudar do modo "classic" para o modo "zeitwerk"?
----------------------------------------

O carregador automático "classic" tem sido extremamente útil, mas tinha uma série de [problemas](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas) que tornavam o carregamento automático um pouco complicado e confuso às vezes. O Zeitwerk foi desenvolvido para resolver isso, entre outras [motivações](https://github.com/fxn/zeitwerk#motivation).

Ao atualizar para o Rails 6.x, é altamente recomendado mudar para o modo "zeitwerk", pois é um carregador automático melhor e o modo "classic" está obsoleto.

O Rails 7 encerra o período de transição e não inclui mais o modo "classic".

Estou com medo
-----------

Não fique :).

O Zeitwerk foi projetado para ser o mais compatível possível com o carregador automático clássico. Se você tem um aplicativo funcionando corretamente com o carregamento automático hoje, as chances são de que a mudança será fácil. Muitos projetos, grandes e pequenos, relataram transições muito tranquilas.

Este guia irá ajudá-lo a mudar o carregador automático com confiança.

Se, por qualquer motivo, você encontrar uma situação que não sabe como resolver, não hesite em [abrir uma issue em `rails/rails`](https://github.com/rails/rails/issues/new) e marcar [`@fxn`](https://github.com/fxn).


Como ativar o modo "zeitwerk"
-------------------------------

### Aplicativos rodando o Rails 5.x ou anterior

Em aplicativos que estão rodando uma versão anterior ao Rails 6.0, o modo "zeitwerk" não está disponível. Você precisa estar pelo menos no Rails 6.0.

### Aplicativos rodando o Rails 6.x

Em aplicativos que estão rodando o Rails 6.x, existem dois cenários.

Se o aplicativo está carregando as configurações padrão do framework do Rails 6.0 ou 6.1 e está rodando no modo "classic", ele deve estar optando por isso manualmente. Você deve ter algo semelhante a isso:

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # DELETE THIS LINE
```

Como observado, basta excluir a substituição, o modo "zeitwerk" é o padrão.

Por outro lado, se o aplicativo está carregando configurações antigas do framework, você precisa habilitar explicitamente o modo "zeitwerk":

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### Aplicativos rodando o Rails 7

No Rails 7, só existe o modo "zeitwerk", você não precisa fazer nada para ativá-lo.

De fato, no Rails 7, o setter `config.autoloader=` nem mesmo existe. Se `config/application.rb` o utiliza, por favor, exclua a linha.


Como verificar se o aplicativo está rodando no modo "zeitwerk"?
------------------------------------------------------

Para verificar se o aplicativo está rodando no modo "zeitwerk", execute

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

Se isso imprimir `true`, o modo "zeitwerk" está ativado.


Meu aplicativo está em conformidade com as convenções do Zeitwerk?
-----------------------------------------------------

### config.eager_load_paths

O teste de conformidade é executado apenas para arquivos carregados antecipadamente. Portanto, para verificar a conformidade do Zeitwerk, é recomendável ter todos os caminhos de carregamento automático nos caminhos de carregamento antecipado.

Isso já é o caso por padrão, mas se o projeto tiver caminhos de carregamento automático personalizados configurados assim:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

eles não serão carregados antecipadamente e não serão verificados. Adicioná-los aos caminhos de carregamento antecipado é fácil:

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

Depois que o modo "zeitwerk" estiver ativado e a configuração dos caminhos de carregamento antecipado for verificada, execute:

```
bin/rails zeitwerk:check
```

Uma verificação bem-sucedida será parecida com esta:

```
% bin/rails zeitwerk:check
Aguarde, estou carregando o aplicativo antecipadamente.
Tudo está bom!
```

Pode haver saída adicional dependendo da configuração do aplicativo, mas o último "Tudo está bom!" é o que você está procurando.
Se a verificação dupla explicada na seção anterior determinar que na verdade devem haver alguns caminhos de autoload personalizados fora dos caminhos de carregamento imediato, a tarefa irá detectar e avisar sobre eles. No entanto, se o conjunto de testes carregar esses arquivos com sucesso, está tudo bem.

Agora, se houver algum arquivo que não defina a constante esperada, a tarefa irá informá-lo. Ela faz isso um arquivo de cada vez, porque se ela continuar, a falha ao carregar um arquivo pode se propagar para outras falhas não relacionadas à verificação que queremos executar e o relatório de erro seria confuso.

Se houver uma constante relatada, corrija aquela em particular e execute a tarefa novamente. Repita até obter "Tudo está bem!".

Vamos tomar como exemplo:

```
% bin/rails zeitwerk:check
Aguarde, estou carregando a aplicação.
esperava que o arquivo app/models/vat.rb definisse a constante Vat
```

VAT é um imposto europeu. O arquivo `app/models/vat.rb` define `VAT`, mas o carregador automático espera `Vat`, por quê?

### Siglas

Este é o tipo mais comum de discrepância que você pode encontrar, tem a ver com siglas. Vamos entender por que recebemos essa mensagem de erro.

O carregador automático clássico é capaz de carregar automaticamente `VAT` porque sua entrada é o nome da constante ausente, `VAT`, invoca `underscore` nele, o que resulta em `vat`, e procura um arquivo chamado `vat.rb`. Isso funciona.

A entrada do novo carregador automático é o sistema de arquivos. Dado o arquivo `vat.rb`, o Zeitwerk invoca `camelize` em `vat`, o que resulta em `Vat`, e espera que o arquivo defina a constante `Vat`. Isso é o que a mensagem de erro diz.

Corrigir isso é fácil, você só precisa informar o inflector sobre essa sigla:

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

Fazendo isso afeta como o Active Support inflete globalmente. Isso pode ser bom, mas se preferir, você também pode passar substituições para os inflectors usados pelos carregadores automáticos:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

Com essa opção, você tem mais controle, porque apenas arquivos chamados exatamente `vat.rb` ou diretórios chamados exatamente `vat` serão infletidos como `VAT`. Um arquivo chamado `vat_rules.rb` não é afetado por isso e pode definir `VatRules` normalmente. Isso pode ser útil se o projeto tiver esse tipo de inconsistências de nomenclatura.

Com isso no lugar, a verificação é aprovada!

```
% bin/rails zeitwerk:check
Aguarde, estou carregando a aplicação.
Tudo está bem!
```

Uma vez que tudo está bem, é recomendado continuar validando o projeto no conjunto de testes. A seção [_Verificar a Conformidade do Zeitwerk no Conjunto de Testes_](#verificar-a-conformidade-do-zeitwerk-no-conjunto-de-testes) explica como fazer isso.

### Concerns

Você pode carregar automaticamente e carregar imediatamente a partir de uma estrutura padrão com subdiretórios `concerns` como

```
app/models
app/models/concerns
```

Por padrão, `app/models/concerns` pertence aos caminhos de autoload e, portanto, é assumido como um diretório raiz. Portanto, por padrão, `app/models/concerns/foo.rb` deve definir `Foo`, não `Concerns::Foo`.

Se sua aplicação usa `Concerns` como namespace, você tem duas opções:

1. Remova o namespace `Concerns` dessas classes e módulos e atualize o código do cliente.
2. Deixe as coisas como estão, removendo `app/models/concerns` dos caminhos de autoload:

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### Ter `app` nos Caminhos de Autoload

Alguns projetos desejam que algo como `app/api/base.rb` defina `API::Base` e adicionam `app` aos caminhos de autoload para conseguir isso.

Como o Rails adiciona automaticamente todos os subdiretórios de `app` aos caminhos de autoload (com algumas exceções), temos outra situação em que existem diretórios raiz aninhados, semelhante ao que acontece com `app/models/concerns`. Essa configuração não funciona mais como está.

No entanto, você pode manter essa estrutura, basta excluir `app/api` dos caminhos de autoload em um inicializador:

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

Cuidado com subdiretórios que não possuem arquivos para serem carregados automaticamente/carregados imediatamente. Por exemplo, se a aplicação tiver `app/admin` com recursos para o [ActiveAdmin](https://activeadmin.info/), você precisa ignorá-los. O mesmo vale para `assets` e similares:

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

Sem essa configuração, a aplicação carregaria essas árvores imediatamente. Daria erro em `app/admin` porque seus arquivos não definem constantes e definiria um módulo `Views`, por exemplo, como um efeito colateral indesejado.

Como você pode ver, ter `app` nos caminhos de autoload é tecnicamente possível, mas um pouco complicado.

### Constantes Carregadas Automaticamente e Namespaces Explícitos

Se um namespace for definido em um arquivo, como `Hotel` aqui:
```
app/models/hotel.rb         # Define Hotel.
app/models/hotel/pricing.rb # Define Hotel::Pricing.
```

a constante `Hotel` deve ser definida usando as palavras-chave `class` ou `module`. Por exemplo:

```ruby
class Hotel
end
```

é bom.

Alternativas como

```ruby
Hotel = Class.new
```

ou

```ruby
Hotel = Struct.new
```

não funcionarão, objetos filhos como `Hotel::Pricing` não serão encontrados.

Essa restrição se aplica apenas a namespaces explícitos. Classes e módulos que não definem um namespace podem ser definidos usando esses idiomas.

### Um Arquivo, Uma Constante (no Mesmo Nível Superior)

No modo `classic`, tecnicamente você poderia definir várias constantes no mesmo nível superior e todas serem recarregadas. Por exemplo, dado

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

enquanto `Bar` não poderia ser carregado automaticamente, carregar `Foo` marcaria `Bar` como carregado automaticamente também.

Isso não acontece no modo `zeitwerk`, você precisa mover `Bar` para seu próprio arquivo `bar.rb`. Um arquivo, uma constante no nível superior.

Isso afeta apenas as constantes no mesmo nível superior como no exemplo acima. Classes e módulos internos estão bem. Por exemplo, considere

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Se a aplicação recarregar `Foo`, também recarregará `Foo::InnerClass`.

### Globs em `config.autoload_paths`

Cuidado com configurações que usam curingas como

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

Cada elemento de `config.autoload_paths` deve representar o namespace de nível superior (`Object`). Isso não funcionará.

Para corrigir isso, basta remover os curingas:

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### Decorando Classes e Módulos de Engines

Se sua aplicação decora classes ou módulos de uma engine, é provável que esteja fazendo algo assim em algum lugar:

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

Isso precisa ser atualizado: você precisa informar ao autoloader `main` para ignorar o diretório com os overrides e precisa carregá-los com `load`. Algo assim:

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

O Rails 3.1 adicionou suporte a um callback chamado `before_remove_const` que era invocado se uma classe ou módulo respondesse a esse método e estivesse prestes a ser recarregado. Esse callback permaneceu sem documentação e é improvável que seu código o utilize.

No entanto, caso o utilize, você pode reescrever algo como

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

como

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring e o Ambiente `test`

O Spring recarrega o código da aplicação se algo mudar. No ambiente `test`, você precisa habilitar a recarga para que isso funcione:

```ruby
# config/environments/test.rb
config.cache_classes = false
```

ou, a partir do Rails 7.1:

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

Caso contrário, você verá:

```
reloading is disabled because config.cache_classes is true
```

ou

```
reloading is disabled because config.enable_reloading is false
```

Isso não tem penalidade de desempenho.

### Bootsnap

Certifique-se de depender pelo menos do Bootsnap 1.4.4.


Verifique a Conformidade do Zeitwerk no Conjunto de Testes
----------------------------------------------------------

A tarefa `zeitwerk:check` é útil durante a migração. Uma vez que o projeto esteja em conformidade, é recomendado automatizar essa verificação. Para fazer isso, é suficiente carregar a aplicação de forma ansiosa, que é exatamente o que `zeitwerk:check` faz.

### Integração Contínua

Se o projeto tiver integração contínua, é uma boa ideia carregar a aplicação de forma ansiosa quando o conjunto de testes for executado lá. Se a aplicação não puder ser carregada de forma ansiosa por qualquer motivo, é melhor saber na integração contínua do que na produção, certo?

As integrações contínuas geralmente definem alguma variável de ambiente para indicar que o conjunto de testes está sendo executado lá. Por exemplo, poderia ser `CI`:

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

A partir do Rails 7, as aplicações recém-geradas são configuradas dessa maneira por padrão.

### Conjuntos de Testes Simples

Se o projeto não tiver integração contínua, você ainda pode carregar de forma ansiosa no conjunto de testes chamando `Rails.application.eager_load!`:

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "carrega todos os arquivos sem erros" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Conformidade do Zeitwerk" do
  it "carrega todos os arquivos sem erros" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

Exclua quaisquer Chamadas `require`
-----------------------------------

Em minha experiência, projetos geralmente não fazem isso. Mas já vi alguns e ouvi falar de alguns outros.
Em um aplicativo Rails, você usa `require` exclusivamente para carregar código de `lib` ou de terceiros, como dependências de gemas ou da biblioteca padrão. **Nunca carregue código de aplicativo autoloadable com `require`**. Veja por que isso é uma má ideia no modo `classic` [aqui](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require).

```ruby
require "nokogiri" # BOM
require "net/http" # BOM
require "user"     # RUIM, DELETE ISSO (supondo que seja app/models/user.rb)
```

Por favor, exclua todas as chamadas de `require` desse tipo.

Novos recursos que você pode aproveitar
---------------------------------------

### Excluir chamadas de `require_dependency`

Todos os casos conhecidos de `require_dependency` foram eliminados com o Zeitwerk. Você deve procurar no projeto e excluí-los.

Se o seu aplicativo usa Herança de Tabela Única, consulte a seção [Herança de Tabela Única](autoloading_and_reloading_constants.html#single-table-inheritance) do guia Autoloading and Reloading Constants (Modo Zeitwerk).

### Nomes qualificados em definições de classe e módulo agora são possíveis

Agora você pode usar caminhos de constantes de forma robusta em definições de classe e módulo:

```ruby
# O carregamento automático neste corpo da classe agora corresponde à semântica do Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Um ponto a ser observado é que, dependendo da ordem de execução, o carregador automático clássico às vezes podia carregar automaticamente `Foo::Wadus` em

```ruby
class Foo::Bar
  Wadus
end
```

Isso não corresponde à semântica do Ruby porque `Foo` não está no aninhamento e não funcionará no modo `zeitwerk`. Se você encontrar esse caso especial, pode usar o nome qualificado `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

ou adicionar `Foo` ao aninhamento:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### Segurança em threads em todos os lugares

No modo `classic`, o carregamento automático de constantes não é seguro para threads, embora o Rails tenha bloqueios em vigor, por exemplo, para tornar as solicitações da web seguras para threads.

O carregamento automático de constantes é seguro para threads no modo `zeitwerk`. Por exemplo, agora você pode carregar automaticamente em scripts multithread executados pelo comando `runner`.

### Carregamento antecipado e carregamento automático são consistentes

No modo `classic`, se `app/models/foo.rb` define `Bar`, você não poderá carregar automaticamente esse arquivo, mas o carregamento antecipado funcionará porque carrega arquivos recursivamente às cegas. Isso pode ser uma fonte de erros se você testar as coisas primeiro com carregamento antecipado, a execução pode falhar mais tarde com o carregamento automático.

No modo `zeitwerk`, ambos os modos de carregamento são consistentes, eles falham e geram erros nos mesmos arquivos.
