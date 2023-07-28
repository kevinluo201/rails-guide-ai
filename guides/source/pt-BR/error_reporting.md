**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Relatório de Erros em Aplicações Rails
========================

Este guia apresenta maneiras de gerenciar exceções que ocorrem em aplicações Ruby on Rails.

Após ler este guia, você saberá:

* Como usar o relatório de erros do Rails para capturar e relatar erros.
* Como criar assinantes personalizados para o seu serviço de relatório de erros.

--------------------------------------------------------------------------------

Relatório de Erros
------------------------

O relatório de erros do Rails [error reporter](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html) fornece uma maneira padrão de coletar exceções que ocorrem em sua aplicação e relatá-las para o serviço ou localização de sua preferência.

O relatório de erros tem como objetivo substituir o código de tratamento de erros repetitivo, como este:

```ruby
begin
  faça_algo
rescue AlgoEstáQuebrado => erro
  MeuServiçoDeRelatórioDeErros.notificar(erro)
end
```

por uma interface consistente:

```ruby
Rails.error.handle(AlgoEstáQuebrado) do
  faça_algo
end
```

O Rails envolve todas as execuções (como requisições HTTP, jobs e invocações `rails runner`) no relatório de erros, então quaisquer erros não tratados levantados em sua aplicação serão automaticamente relatados para o seu serviço de relatório de erros por meio de seus assinantes.

Isso significa que bibliotecas de relatório de erros de terceiros não precisam mais inserir um middleware Rack ou fazer qualquer monkey-patching para capturar exceções não tratadas. Bibliotecas que usam o ActiveSupport também podem usar isso para relatar avisos de forma não intrusiva que anteriormente seriam perdidos nos logs.

O uso do relatório de erros do Rails não é obrigatório. Todos os outros meios de capturar erros ainda funcionam.

### Assinando o Relatório

Para usar o relatório de erros, você precisa de um _assinante_. Um assinante é qualquer objeto com um método `report`. Quando ocorre um erro em sua aplicação ou é relatado manualmente, o relatório de erros do Rails chamará esse método com o objeto de erro e algumas opções.

Algumas bibliotecas de relatório de erros, como [Sentry](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) e [Honeybadger](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/), registram automaticamente um assinante para você. Consulte a documentação do seu provedor para obter mais detalhes.

Você também pode criar um assinante personalizado. Por exemplo:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

Após definir a classe do assinante, registre-a chamando o método [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe):

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

Você pode registrar quantos assinantes desejar. O Rails os chamará em sequência, na ordem em que foram registrados.

NOTA: O relatório de erros do Rails sempre chamará os assinantes registrados, independentemente do seu ambiente. No entanto, muitos serviços de relatório de erros relatam apenas erros em produção por padrão. Você deve configurar e testar sua configuração em todos os ambientes conforme necessário.

### Usando o Relatório de Erros

Existem três maneiras de usar o relatório de erros:

#### Relatando e Ignorando Erros

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle) irá relatar qualquer erro levantado dentro do bloco. Em seguida, ele irá **ignorar** o erro, e o restante do seu código fora do bloco continuará normalmente.

```ruby
resultado = Rails.error.handle do
  1 + '1' # levanta TypeError
end
resultado # => nil
1 + 1 # Isso será executado
```

Se nenhum erro for levantado no bloco, `Rails.error.handle` retornará o resultado do bloco, caso contrário, retornará `nil`. Você pode substituir isso fornecendo um `fallback`:

```ruby
usuário = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### Relatando e Levantando Novamente Erros

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record) irá relatar erros para todos os assinantes registrados e, em seguida, levantará novamente o erro, o que significa que o restante do seu código não será executado.

```ruby
Rails.error.record do
  1 + '1' # levanta TypeError
end
1 + 1 # Isso não será executado
```

Se nenhum erro for levantado no bloco, `Rails.error.record` retornará o resultado do bloco.

#### Relatando Erros Manualmente

Você também pode relatar erros manualmente chamando [`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report):

```ruby
begin
  # código
rescue StandardError => e
  Rails.error.report(e)
end
```

Quaisquer opções que você passar serão repassadas aos assinantes de erros.

### Opções de Relatório de Erros

As 3 APIs de relatório (`#handle`, `#record` e `#report`) suportam as seguintes opções, que são então repassadas a todos os assinantes registrados:

- `handled`: um `Boolean` para indicar se o erro foi tratado. Isso é definido como `true` por padrão. `#record` define isso como `false`.
- `severity`: um `Symbol` que descreve a gravidade do erro. Os valores esperados são: `:error`, `:warning` e `:info`. `#handle` define isso como `:warning`, enquanto `#record` define como `:error`.
- `context`: um `Hash` para fornecer mais contexto sobre o erro, como detalhes da requisição ou do usuário.
- `source`: uma `String` sobre a origem do erro. A origem padrão é `"application"`. Erros relatados por bibliotecas internas podem definir outras origens; a biblioteca de cache Redis pode usar `"redis_cache_store.active_support"`, por exemplo. Seu assinante pode usar a origem para ignorar erros que você não está interessado.
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### Filtrando por Classes de Erro

Com `Rails.error.handle` e `Rails.error.record`, você também pode escolher reportar apenas erros de certas classes. Por exemplo:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # gera TypeError
end
1 + 1 # TypeErrors não são IOErrors, então isso *não* será executado
```

Aqui, o `TypeError` não será capturado pelo relator de erros do Rails. Apenas instâncias de `IOError` e suas subclasses serão reportadas. Quaisquer outros erros serão lançados normalmente.

### Definindo Contexto Globalmente

Além de definir o contexto através da opção `context`, você pode usar a API [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context). Por exemplo:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

Qualquer contexto definido dessa maneira será mesclado com a opção `context`.

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# O contexto reportado será: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# O contexto reportado será: {:a=>1, :b=>3}
```

### Para Bibliotecas

Bibliotecas de relatório de erros podem registrar seus assinantes em um `Railtie`:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

Se você registrar um assinante de erros, mas ainda tiver outros mecanismos de erro como um middleware Rack, você pode acabar com erros reportados várias vezes. Você deve remover seus outros mecanismos ou ajustar sua funcionalidade de relatório para pular a reportagem de uma exceção que já foi vista antes.
