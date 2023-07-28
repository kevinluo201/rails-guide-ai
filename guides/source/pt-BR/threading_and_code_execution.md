**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
Threading e Execução de Código no Rails
========================================

Após ler este guia, você saberá:

* Qual código o Rails executará automaticamente em paralelo
* Como integrar concorrência manual com as internas do Rails
* Como envolver todo o código da aplicação
* Como afetar o recarregamento da aplicação

--------------------------------------------------------------------------------

Concorrência Automática
-----------------------

O Rails permite automaticamente que várias operações sejam executadas ao mesmo tempo.

Ao usar um servidor web com threads, como o Puma padrão, várias requisições HTTP serão atendidas simultaneamente, cada uma com sua própria instância de controlador.

Adaptadores de Active Job com threads, incluindo o Async integrado, também executarão vários jobs ao mesmo tempo. Os canais do Action Cable também são gerenciados dessa forma.

Esses mecanismos envolvem várias threads, cada uma gerenciando o trabalho para uma instância única de algum objeto (controlador, job, canal), enquanto compartilham o espaço de processo global (como classes e suas configurações e variáveis globais). Desde que seu código não modifique nenhuma dessas coisas compartilhadas, ele pode ignorar em grande parte a existência de outras threads.

O restante deste guia descreve os mecanismos que o Rails usa para tornar isso "em grande parte ignorável" e como extensões e aplicações com necessidades especiais podem usá-los.

Executor
--------

O Executor do Rails separa o código da aplicação do código do framework: toda vez que o framework invoca o código que você escreveu em sua aplicação, ele será envolvido pelo Executor.

O Executor consiste em dois callbacks: `to_run` e `to_complete`. O callback Run é chamado antes do código da aplicação e o callback Complete é chamado depois.

### Callbacks Padrão

Em uma aplicação Rails padrão, os callbacks do Executor são usados para:

* rastrear quais threads estão em posições seguras para o carregamento automático e recarregamento
* habilitar e desabilitar o cache de consultas do Active Record
* retornar conexões adquiridas do Active Record para o pool
* limitar a vida útil do cache interno

Antes do Rails 5.0, alguns desses callbacks eram tratados por classes de middleware separadas do Rack (como `ActiveRecord::ConnectionAdapters::ConnectionManagement`) ou envolvendo diretamente o código com métodos como `ActiveRecord::Base.connection_pool.with_connection`. O Executor substitui esses métodos por uma única interface mais abstrata.

### Envolvendo o Código da Aplicação

Se você está escrevendo uma biblioteca ou componente que invocará o código da aplicação, você deve envolvê-lo com uma chamada ao executor:

```ruby
Rails.application.executor.wrap do
  # chame o código da aplicação aqui
end
```

DICA: Se você invocar repetidamente o código da aplicação a partir de um processo em execução contínua, talvez queira envolvê-lo usando o [Reloader](#reloader) em vez disso.

Cada thread deve ser envolvida antes de executar o código da aplicação, portanto, se sua aplicação delegar manualmente o trabalho para outras threads, como via `Thread.new` ou recursos do Concurrent Ruby que usam pools de threads, você deve envolver imediatamente o bloco:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # seu código aqui
  end
end
```

NOTA: O Concurrent Ruby usa um `ThreadPoolExecutor`, que às vezes é configurado com uma opção `executor`. Apesar do nome, não está relacionado.

O Executor é seguramente reentrante; se ele já estiver ativo na thread atual, `wrap` não fará nada.

Se não for prático envolver o código da aplicação em um bloco (por exemplo, a API do Rack torna isso problemático), você também pode usar o par `run!` / `complete!`:

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # seu código aqui
ensure
  execution_context.complete! if execution_context
end
```

### Concorrência

O Executor colocará a thread atual no modo `running` no [Load Interlock](#load-interlock). Essa operação bloqueará temporariamente se outra thread estiver atualmente carregando automaticamente uma constante ou descarregando/recarregando a aplicação.

Reloader
--------

Assim como o Executor, o Reloader também envolve o código da aplicação. Se o Executor não estiver ativo na thread atual, o Reloader o invocará para você, então você só precisa chamar um. Isso também garante que tudo o que o Reloader faz, incluindo todas as suas invocações de callback, ocorra envolvido pelo Executor.

```ruby
Rails.application.reloader.wrap do
  # chame o código da aplicação aqui
end
```

O Reloader é adequado apenas onde um processo de nível de framework em execução contínua chama repetidamente o código da aplicação, como um servidor web ou fila de jobs. O Rails envolve automaticamente as requisições web e os workers do Active Job, então raramente será necessário invocar o Reloader por conta própria. Sempre considere se o Executor é mais adequado para o seu caso de uso.

### Callbacks

Antes de entrar no bloco envolvido, o Reloader verificará se a aplicação em execução precisa ser recarregada - por exemplo, porque o arquivo de origem de um modelo foi modificado. Se determinar que uma recarga é necessária, ele aguardará até que seja seguro e, em seguida, fará a recarga antes de continuar. Quando a aplicação está configurada para sempre recarregar, independentemente de haver ou não alterações detectadas, a recarga é feita no final do bloco.
O Reloader também fornece callbacks `to_run` e `to_complete`; eles são
invocados nos mesmos pontos que os do Executor, mas apenas quando a execução atual
iniciou uma recarga da aplicação. Quando nenhuma recarga é considerada
necessária, o Reloader invocará o bloco envolvido sem outros callbacks.

### Descarregamento de Classe

A parte mais significativa do processo de recarga é o Descarregamento de Classe, onde
todas as classes carregadas automaticamente são removidas, prontas para serem carregadas novamente. Isso ocorrerá
imediatamente antes do callback Run ou Complete, dependendo da configuração
`reload_classes_only_on_change`.

Muitas vezes, ações adicionais de recarga precisam ser executadas antes ou depois
do Descarregamento de Classe, então o Reloader também fornece callbacks `before_class_unload`
e `after_class_unload`.

### Concorrência

Apenas processos "top level" de longa duração devem invocar o Reloader, porque se
ele determinar que uma recarga é necessária, ele bloqueará até que todas as outras threads
tenham concluído quaisquer invocações do Executor.

Se isso ocorrer em uma thread "filha", com um pai esperando dentro do
Executor, isso causaria um impasse inevitável: a recarga deve ocorrer antes
da thread filha ser executada, mas não pode ser realizada com segurança enquanto o pai
thread está em execução. As threads filhas devem usar o Executor em vez disso.

Comportamento do Framework
------------------

Os componentes do framework Rails também usam essas ferramentas para gerenciar suas próprias
necessidades de concorrência.

`ActionDispatch::Executor` e `ActionDispatch::Reloader` são middlewares do Rack
que envolvem as solicitações com um Executor ou Reloader fornecido, respectivamente. Eles
são automaticamente incluídos na pilha de aplicativos padrão. O Reloader garantirá
que qualquer solicitação HTTP que chegar seja atendida com uma cópia recarregada da
aplicação se ocorrerem alterações no código.

O Active Job também envolve suas execuções de trabalho com o Reloader, carregando o código mais recente
para executar cada trabalho conforme ele sai da fila.

O Action Cable usa o Executor em vez disso: porque uma conexão Cable está vinculada a
uma instância específica de uma classe, não é possível recarregar a cada mensagem WebSocket que chega. Apenas o manipulador de mensagens é envolvido; uma conexão Cable de longa duração não impede uma recarga que é acionada por uma nova solicitação ou trabalho recebido. Em vez disso, o Action Cable usa o callback `before_class_unload` do Reloader para desconectar todas as suas conexões. Quando o cliente se reconectar automaticamente, ele estará se comunicando com a nova versão do código.

Os acima são os pontos de entrada do framework, então eles são responsáveis por
garantir que suas respectivas threads estejam protegidas e decidir se uma recarga
é necessária. Outros componentes só precisam usar o Executor quando eles criam
threads adicionais.

### Configuração

O Reloader só verifica as alterações de arquivo quando `config.enable_reloading` é
`true` e também `config.reload_classes_only_on_change`. Esses são os valores padrão no
ambiente `development`.

Quando `config.enable_reloading` é `false` (em `production`, por padrão), o
Reloader é apenas um pass-through para o Executor.

O Executor sempre tem um trabalho importante a fazer, como gerenciamento de conexão de banco de dados. Quando `config.enable_reloading` é `false` e `config.eager_load` é
`true` (padrões de `production`), nenhuma recarga ocorrerá, então não é necessário o
Load Interlock. Com as configurações padrão no ambiente `development`, o
Executor usará o Load Interlock para garantir que as constantes sejam carregadas apenas quando
for seguro.

Load Interlock
--------------

O Load Interlock permite que o carregamento automático e a recarga sejam ativados em um
ambiente de tempo de execução com várias threads.

Quando uma thread está realizando um carregamento automático, avaliando a definição da classe
a partir do arquivo apropriado, é importante que nenhuma outra thread encontre uma
referência à constante parcialmente definida.

Da mesma forma, só é seguro realizar um descarregamento/recarga quando nenhum código da aplicação
está em execução: após a recarga, a constante `User`, por exemplo, pode
apontar para uma classe diferente. Sem essa regra, uma recarga mal programada significaria
`User.new.class == User`, ou até mesmo `User == User`, poderia ser falso.

Ambas as restrições são tratadas pelo Load Interlock. Ele mantém o controle de
quais threads estão atualmente executando código da aplicação, carregando uma classe ou
descarregando constantes carregadas automaticamente.

Apenas uma thread pode carregar ou descarregar por vez, e para fazer qualquer uma das duas, ela deve esperar
até que nenhuma outra thread esteja executando código da aplicação. Se uma thread está esperando para
realizar um carregamento, isso não impede que outras threads carreguem (na verdade, elas vão
cooperar e cada uma realizará seu carregamento em fila, antes de todas retomarem
a execução juntas).

### `permit_concurrent_loads`

O Executor adquire automaticamente um bloqueio `running` durante a duração de seu
bloco, e o carregamento automático sabe quando atualizar para um bloqueio de `load` e alternar de volta para
`running` novamente depois.
Outras operações de bloqueio executadas dentro do bloco Executor (que inclui todo o código do aplicativo), no entanto, podem reter desnecessariamente o bloqueio "running". Se outra thread encontrar uma constante que precisa ser carregada automaticamente, isso pode causar um deadlock.

Por exemplo, supondo que o "User" ainda não esteja carregado, o seguinte causará um deadlock:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # a thread interna aguarda aqui; ela não pode carregar
           # o User enquanto outra thread estiver em execução
    end
  end

  th.join # a thread externa aguarda aqui, mantendo o bloqueio 'running'
end
```

Para evitar esse deadlock, a thread externa pode chamar `permit_concurrent_loads`. Ao chamar esse método, a thread garante que não irá desreferenciar nenhuma constante possivelmente carregada automaticamente dentro do bloco fornecido. A maneira mais segura de cumprir essa promessa é colocá-la o mais próximo possível da chamada de bloqueio:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # a thread interna pode adquirir o bloqueio 'load',
           # carregar o User e continuar
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # a thread externa aguarda aqui, mas não possui bloqueio
  end
end
```

Outro exemplo, usando o Concurrent Ruby:

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # faça o trabalho aqui
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

Se o seu aplicativo estiver em deadlock e você acredita que o Load Interlock pode estar envolvido, você pode adicionar temporariamente o middleware ActionDispatch::DebugLocks ao `config/application.rb`:

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

Se você reiniciar o aplicativo e recriar a condição de deadlock, `/rails/locks` mostrará um resumo de todas as threads atualmente conhecidas pelo interlock, em que nível de bloqueio elas estão mantendo ou aguardando e sua pilha de chamadas atual.

Geralmente, um deadlock será causado pelo interlock entrando em conflito com algum outro bloqueio externo ou chamada de E/S bloqueante. Uma vez que você o encontrar, você pode envolvê-lo com `permit_concurrent_loads`.
