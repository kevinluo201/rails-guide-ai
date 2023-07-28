**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Noções básicas do Active Job
============================

Este guia fornece tudo o que você precisa para começar a criar, enfileirar e executar jobs em segundo plano.

Após ler este guia, você saberá:

* Como criar jobs.
* Como enfileirar jobs.
* Como executar jobs em segundo plano.
* Como enviar emails de forma assíncrona a partir da sua aplicação.

--------------------------------------------------------------------------------

O que é o Active Job?
---------------------

O Active Job é um framework para declarar jobs e executá-los em vários backends de enfileiramento. Esses jobs podem ser desde limpezas programadas regularmente, até cobranças de faturamento, até envios de emails. Qualquer coisa que possa ser dividida em unidades de trabalho menores e executadas em paralelo, na verdade.

O objetivo do Active Job
------------------------

O principal objetivo é garantir que todos os aplicativos Rails tenham uma infraestrutura de jobs em funcionamento. Assim, podemos ter recursos do framework e outras gems construídas em cima disso, sem nos preocuparmos com diferenças de API entre vários executores de jobs, como Delayed Job e Resque. A escolha do backend de enfileiramento se torna mais uma preocupação operacional. E você poderá alternar entre eles sem precisar reescrever seus jobs.

NOTA: O Rails vem por padrão com uma implementação de enfileiramento assíncrono que executa jobs com uma pool de threads em processo. Os jobs serão executados de forma assíncrona, mas qualquer job na fila será descartado ao reiniciar.

Criando um Job
--------------

Esta seção fornecerá um guia passo a passo para criar um job e enfileirá-lo.

### Criar o Job

O Active Job fornece um gerador do Rails para criar jobs. O seguinte comando criará um job em `app/jobs` (com um caso de teste associado em `test/jobs`):

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

Você também pode criar um job que será executado em uma fila específica:

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

Se você não quiser usar um gerador, pode criar seu próprio arquivo dentro de `app/jobs`, apenas certifique-se de que ele herde de `ApplicationJob`.

Veja como um job se parece:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Faça algo mais tarde
  end
end
```

Observe que você pode definir `perform` com quantos argumentos quiser.

Se você já tem uma classe abstrata e o nome dela é diferente de `ApplicationJob`, você pode passar a opção `--parent` para indicar que deseja uma classe abstrata diferente:

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # Faça algo mais tarde
  end
end
```

### Enfileirar o Job

Enfileire um job usando [`perform_later`][] e, opcionalmente, [`set`][]. Assim:

```ruby
# Enfileire um job para ser executado assim que o sistema de enfileiramento estiver livre.
GuestsCleanupJob.perform_later guest
```

```ruby
# Enfileire um job para ser executado amanhã ao meio-dia.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Enfileire um job para ser executado daqui a 1 semana.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` e `perform_later` chamarão `perform` internamente, então
# você pode passar quantos argumentos forem definidos no último.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'algum_filtro')
```

É isso!

Execução do Job
---------------

Para enfileirar e executar jobs em produção, você precisa configurar um backend de enfileiramento, ou seja, precisa escolher uma biblioteca de enfileiramento de terceiros que o Rails deve usar. O Rails em si fornece apenas um sistema de enfileiramento em processo, que mantém os jobs apenas na memória. Se o processo falhar ou a máquina for reiniciada, todos os jobs pendentes serão perdidos com o backend assíncrono padrão. Isso pode ser aceitável para aplicativos menores ou jobs não críticos, mas a maioria dos aplicativos em produção precisará escolher um backend persistente.

### Backends

O Active Job possui adaptadores integrados para vários backends de enfileiramento (Sidekiq, Resque, Delayed Job e outros). Para obter uma lista atualizada dos adaptadores, consulte a Documentação da API para [`ActiveJob::QueueAdapters`][].

### Configurando o Backend

Você pode facilmente configurar o seu backend de enfileiramento com [`config.active_job.queue_adapter`]:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Certifique-se de ter a gem do adaptador no seu Gemfile
    # e siga as instruções específicas de instalação
    # e implantação do adaptador.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

Você também pode configurar o seu backend em uma base por job:

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# Agora o seu job usará `resque` como adaptador de fila de backend, substituindo o que
# foi configurado em `config.active_job.queue_adapter`.
```
### Iniciando o Backend

Como os jobs são executados em paralelo com a sua aplicação Rails, a maioria das bibliotecas de filas de espera requer que você inicie um serviço de fila específico da biblioteca (além de iniciar sua aplicação Rails) para que o processamento do job funcione. Consulte a documentação da biblioteca para obter instruções sobre como iniciar o backend da fila.

Aqui está uma lista não abrangente de documentação:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

Filas
------

A maioria dos adaptadores suporta várias filas. Com o Active Job, você pode agendar o job para ser executado em uma fila específica usando [`queue_as`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

Você pode adicionar um prefixo ao nome da fila para todos os seus jobs usando [`config.active_job.queue_name_prefix`][] em `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Agora o seu job será executado na fila production_low_priority no ambiente de produção e na fila staging_low_priority no ambiente de staging
```

Você também pode configurar o prefixo em um job específico.

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# Agora a fila do seu job não terá prefixo, substituindo o que foi configurado em `config.active_job.queue_name_prefix`.
```

O delimitador padrão do prefixo do nome da fila é '\_'. Isso pode ser alterado definindo [`config.active_job.queue_name_delimiter`][] em `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# Agora o seu job será executado na fila production.low_priority no ambiente de produção e na fila staging.low_priority no ambiente de staging
```

Se você deseja ter mais controle sobre em qual fila um job será executado, pode passar a opção `:queue` para `set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

Para controlar a fila a partir do nível do job, você pode passar um bloco para `queue_as`. O bloco será executado no contexto do job (para que possa acessar `self.arguments`) e deve retornar o nome da fila:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Fazer o processamento do vídeo
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

NOTA: Certifique-se de que o backend da fila esteja "ouvindo" o nome da sua fila. Para alguns backends, você precisa especificar as filas a serem ouvidas.


Callbacks
---------

O Active Job fornece ganchos para acionar lógica durante o ciclo de vida de um job. Assim como outros callbacks no Rails, você pode implementar os callbacks como métodos comuns e usar um método de classe no estilo macro para registrá-los como callbacks:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Fazer algo mais tarde
  end

  private
    def around_cleanup
      # Fazer algo antes da execução
      yield
      # Fazer algo depois da execução
    end
end
```

Os métodos de classe no estilo macro também podem receber um bloco. Considere usar esse estilo se o código dentro do seu bloco for tão curto que caiba em uma única linha. Por exemplo, você pode enviar métricas para cada job enfileirado:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### Callbacks Disponíveis

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


Action Mailer
------------

Um dos jobs mais comuns em uma aplicação web moderna é o envio de emails fora do ciclo de solicitação-resposta, para que o usuário não precise esperar por ele. O Active Job está integrado ao Action Mailer, para que você possa enviar emails de forma assíncrona facilmente:

```ruby
# Se você quiser enviar o email agora, use #deliver_now
UserMailer.welcome(@user).deliver_now

# Se você quiser enviar o email através do Active Job, use #deliver_later
UserMailer.welcome(@user).deliver_later
```

NOTA: Usar a fila assíncrona a partir de uma tarefa Rake (por exemplo, para enviar um email usando `.deliver_later`) geralmente não funcionará porque o Rake provavelmente será encerrado, fazendo com que o pool de threads em execução seja excluído, antes que todos os emails `.deliver_later` sejam processados. Para evitar esse problema, use `.deliver_now` ou execute uma fila persistente no ambiente de desenvolvimento.


Internacionalização
--------------------

Cada job usa o `I18n.locale` definido quando o job foi criado. Isso é útil se você enviar emails de forma assíncrona:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # O email será localizado para Esperanto.
```


Tipos Suportados para Argumentos
----------------------------
O ActiveJob suporta os seguintes tipos de argumentos por padrão:

  - Tipos básicos (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (As chaves devem ser do tipo `String` ou `Symbol`)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

O Active Job suporta o [GlobalID](https://github.com/rails/globalid/blob/master/README.md) para parâmetros. Isso torna possível passar objetos ativos do Active Record para o seu job em vez de pares de classe/id, que você então precisa desserializar manualmente. Antes, os jobs ficavam assim:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Agora você pode simplesmente fazer:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

Isso funciona com qualquer classe que mistura `GlobalID::Identification`, que
por padrão foi misturado nas classes do Active Record.

### Serializadores

Você pode estender a lista de tipos de argumentos suportados. Você só precisa definir seu próprio serializador:

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Verifica se um argumento deve ser serializado por este serializador.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Converte um objeto para uma representação mais simples usando tipos de objeto suportados.
  # A representação recomendada é um Hash com uma chave específica. As chaves podem ser apenas de tipos básicos.
  # Você deve chamar `super` para adicionar o tipo de serializador personalizado ao hash.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Converte o valor serializado em um objeto adequado.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

e adicione este serializador à lista:

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Observe que o carregamento automático de código recarregável durante a inicialização não é suportado. Portanto, é recomendado
configurar os serializadores para serem carregados apenas uma vez, por exemplo, alterando `config/application.rb` assim:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

Exceções
----------

As exceções lançadas durante a execução do job podem ser tratadas com
[`rescue_from`][]:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Faça algo com a exceção
  end

  def perform
    # Faça algo depois
  end
end
```

Se uma exceção de um job não for resgatada, então o job é considerado "falhado".


### Retentativa ou Descarte de Jobs Falhados

Um job falhado não será retentado, a menos que configurado de outra forma.

É possível retentar ou descartar um job falhado usando [`retry_on`] ou
[`discard_on`], respectivamente. Por exemplo:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # espera padrão de 3s, 5 tentativas

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Pode lançar CustomAppException ou ActiveJob::DeserializationError
  end
end
```


### Desserialização

O GlobalID permite serializar objetos completos do Active Record passados para `#perform`.

Se um registro passado for excluído após o job ser enfileirado, mas antes do método `#perform`
ser chamado, o Active Job lançará uma exceção [`ActiveJob::DeserializationError`][]
.


Testando Jobs
--------------

Você pode encontrar instruções detalhadas sobre como testar seus jobs no
[guia de testes](testing.html#testing-jobs).

Depuração
---------

Se você precisar de ajuda para descobrir de onde vêm os jobs, você pode ativar o [registro detalhado](debugging_rails_applications.html#verbose-enqueue-logs).
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
