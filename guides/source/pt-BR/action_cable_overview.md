**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Visão geral do Action Cable
=============================

Neste guia, você aprenderá como o Action Cable funciona e como usar WebSockets para incorporar recursos em tempo real em sua aplicação Rails.

Após ler este guia, você saberá:

* O que é o Action Cable e sua integração backend e frontend
* Como configurar o Action Cable
* Como configurar canais
* Implantação e configuração de arquitetura para executar o Action Cable

--------------------------------------------------------------------------------

O que é o Action Cable?
-----------------------

O Action Cable integra perfeitamente [WebSockets](https://en.wikipedia.org/wiki/WebSocket) com o restante de sua aplicação Rails. Ele permite que recursos em tempo real sejam escritos em Ruby no mesmo estilo e formato do restante de sua aplicação Rails, mantendo ao mesmo tempo desempenho e escalabilidade. É uma oferta de pilha completa que fornece tanto um framework JavaScript do lado do cliente quanto um framework Ruby do lado do servidor. Você tem acesso ao seu modelo de domínio inteiro escrito com Active Record ou seu ORM de escolha.

Terminologia
-----------

O Action Cable usa WebSockets em vez do protocolo de solicitação-resposta HTTP. Tanto o Action Cable quanto os WebSockets introduzem algumas terminologias menos familiares:

### Conexões

*Conexões* formam a base do relacionamento cliente-servidor. Um único servidor Action Cable pode lidar com várias instâncias de conexão. Ele tem uma instância de conexão por conexão WebSocket. Um único usuário pode ter várias WebSockets abertas em sua aplicação se ele usar várias guias do navegador ou dispositivos.

### Consumidores

O cliente de uma conexão WebSocket é chamado de *consumidor*. No Action Cable, o consumidor é criado pelo framework JavaScript do lado do cliente.

### Canais

Cada consumidor pode, por sua vez, se inscrever em vários *canais*. Cada canal encapsula uma unidade lógica de trabalho, semelhante ao que um controlador faz em uma configuração típica de MVC. Por exemplo, você pode ter um `ChatChannel` e um `AppearancesChannel`, e um consumidor pode se inscrever em um ou ambos desses canais. No mínimo, um consumidor deve estar inscrito em um canal.

### Assinantes

Quando o consumidor está inscrito em um canal, ele age como um *assinante*. A conexão entre o assinante e o canal é, surpreendentemente, chamada de assinatura. Um consumidor pode agir como um assinante de um determinado canal várias vezes. Por exemplo, um consumidor pode se inscrever em várias salas de bate-papo ao mesmo tempo. (E lembre-se de que um usuário físico pode ter vários consumidores, um por guia/dispositivo aberto em sua conexão).

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) ou Publicar-Inscrever-se refere-se a um paradigma de fila de mensagens em que os remetentes de informações (publicadores) enviam dados para uma classe abstrata de destinatários (assinantes), sem especificar destinatários individuais. O Action Cable usa essa abordagem para se comunicar entre o servidor e muitos clientes.

### Transmissões

Uma transmissão é um link pub/sub onde tudo transmitido pelo transmissor é enviado diretamente para os assinantes do canal que estão transmitindo essa transmissão nomeada. Cada canal pode estar transmitindo zero ou mais transmissões.

## Componentes do lado do servidor

### Conexões

Para cada WebSocket aceito pelo servidor, um objeto de conexão é instanciado. Este objeto se torna o pai de todas as *assinaturas de canal* que são criadas a partir de então. A conexão em si não lida com nenhuma lógica de aplicativo específica além da autenticação e autorização. O cliente de uma conexão WebSocket é chamado de *consumidor* da conexão. Um usuário individual criará um par consumidor-conexão por guia do navegador, janela ou dispositivo que ele tiver aberto.

As conexões são instâncias de `ApplicationCable::Connection`, que estende [`ActionCable::Connection::Base`][]. Em `ApplicationCable::Connection`, você autoriza a conexão de entrada e prossegue para estabelecê-la se o usuário puder ser identificado.

#### Configuração da conexão

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Aqui, [`identified_by`][] designa um identificador de conexão que pode ser usado para encontrar a conexão específica posteriormente. Observe que qualquer coisa marcada como um identificador criará automaticamente um delegado com o mesmo nome em todas as instâncias de canal criadas a partir da conexão.

Este exemplo depende do fato de que você já tenha lidado com a autenticação do usuário em algum outro lugar de sua aplicação e que uma autenticação bem-sucedida defina um cookie criptografado com o ID do usuário.

O cookie é então enviado automaticamente para a instância de conexão quando uma nova conexão é tentada, e você o usa para definir o `current_user`. Ao identificar a conexão com este mesmo usuário atual, você também está garantindo que pode recuperar posteriormente todas as conexões abertas por um determinado usuário (e potencialmente desconectá-las todas se o usuário for excluído ou não autorizado).
Se a sua abordagem de autenticação inclui o uso de uma sessão, você usa o cookie store para a sessão, o cookie da sessão é chamado `_session` e a chave do ID do usuário é `user_id`, você pode usar esta abordagem:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### Tratamento de Exceções

Por padrão, exceções não tratadas são capturadas e registradas no logger do Rails. Se você deseja interceptar globalmente essas exceções e reportá-las para um serviço externo de rastreamento de bugs, por exemplo, você pode fazer isso com [`rescue_from`][]:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### Callbacks de Conexão

Existem callbacks `before_command`, `after_command` e `around_command` disponíveis para serem invocados antes, depois ou em torno de cada comando recebido por um cliente, respectivamente.
O termo "comando" aqui se refere a qualquer interação recebida por um cliente (inscrever-se, cancelar a inscrição ou realizar ações):

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # Agora todos os canais podem usar Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### Canais

Um *canal* encapsula uma unidade lógica de trabalho, similar ao que um controlador faz em uma configuração típica de MVC. Por padrão, o Rails cria uma classe pai `ApplicationCable::Channel` (que estende [`ActionCable::Channel::Base`][]) para encapsular a lógica compartilhada entre seus canais.

#### Configuração do Canal Pai

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Em seguida, você criaria suas próprias classes de canal. Por exemplo, você poderia ter um
`ChatChannel` e um `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


Um consumidor poderia então se inscrever em um ou ambos desses canais.

#### Inscrições

Os consumidores se inscrevem em canais, atuando como *assinantes*. Sua conexão é
chamada de *inscrição*. As mensagens produzidas são então roteadas para essas inscrições de canal
com base em um identificador enviado pelo consumidor do canal.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Chamado quando o consumidor se torna um assinante deste canal com sucesso.
  def subscribed
  end
end
```

#### Tratamento de Exceções

Assim como `ApplicationCable::Connection`, você também pode usar [`rescue_from`][] em um
canal específico para lidar com exceções lançadas:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### Callbacks de Canal

`ApplicationCable::Channel` fornece vários callbacks que podem ser usados para acionar lógica
durante o ciclo de vida de um canal. Os callbacks disponíveis são:

- `before_subscribe`
- `after_subscribe` (também chamado de: `on_subscribe`)
- `before_unsubscribe`
- `after_unsubscribe` (também chamado de: `on_unsubscribe`)

NOTA: O callback `after_subscribe` é acionado sempre que o método `subscribed` é chamado,
mesmo que a inscrição tenha sido rejeitada com o método `reject`. Para acionar `after_subscribe`
apenas em inscrições bem-sucedidas, use `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## Componentes do Lado do Cliente

### Conexões

Os consumidores requerem uma instância da conexão em seu lado. Isso pode ser
estabelecido usando o seguinte JavaScript, que é gerado por padrão pelo Rails:

#### Conectar Consumidor

```js
// app/javascript/channels/consumer.js
// Action Cable fornece o framework para lidar com WebSockets no Rails.
// Você pode gerar novos canais onde recursos do WebSocket vivem usando o comando `bin/rails generate channel`.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Isso irá preparar um consumidor que se conectará a `/cable` em seu servidor por padrão.
A conexão não será estabelecida até que você também tenha especificado pelo menos uma inscrição
que você está interessado em ter.

O consumidor pode opcionalmente receber um argumento que especifica a URL para se conectar. Isso
pode ser uma string ou uma função que retorna uma string que será chamada quando o
WebSocket for aberto.

```js
// Especificar uma URL diferente para se conectar
createConsumer('wss://example.com/cable')
// Ou ao usar websockets sobre HTTP
createConsumer('https://ws.example.com/cable')

// Use uma função para gerar dinamicamente a URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### Assinante

Um consumidor se torna um assinante criando uma inscrição em um determinado canal:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Embora isso crie a inscrição, a funcionalidade necessária para responder a
dados recebidos será descrita posteriormente.
Um consumidor pode agir como um assinante de um determinado canal várias vezes. Por exemplo, um consumidor pode se inscrever em várias salas de bate-papo ao mesmo tempo:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## Interações Cliente-Servidor

### Streams

*Streams* fornecem o mecanismo pelo qual os canais roteiam o conteúdo publicado (transmissões) para seus assinantes. Por exemplo, o seguinte código usa [`stream_from`][] para se inscrever na transmissão chamada `chat_Best Room` quando o valor do parâmetro `:room` é `"Best Room"`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Em seguida, em outro lugar em sua aplicação Rails, você pode transmitir para essa sala chamando [`broadcast`][]:

```ruby
ActionCable.server.broadcast("chat_Best Room", { body: "Esta sala é a melhor sala." })
```

Se você tiver um stream relacionado a um modelo, o nome da transmissão pode ser gerado a partir do canal e do modelo. Por exemplo, o seguinte código usa [`stream_for`][] para se inscrever em uma transmissão como `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`, onde `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` é o GlobalID do modelo Post.

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Você pode então transmitir para este canal chamando [`broadcast_to`][]:

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### Transmissões

Uma *transmissão* é um link pub/sub onde qualquer coisa transmitida por um publicador é roteada diretamente para os assinantes do canal que estão transmitindo essa transmissão nomeada. Cada canal pode estar transmitindo zero ou mais transmissões.

As transmissões são puramente uma fila online e dependente do tempo. Se um consumidor não estiver transmitindo (inscrito em um determinado canal), ele não receberá a transmissão caso se conecte posteriormente.

### Assinaturas

Quando um consumidor está inscrito em um canal, ele age como um assinante. Essa conexão é chamada de assinatura. As mensagens recebidas são então roteadas para essas assinaturas de canal com base em um identificador enviado pelo consumidor de cabo.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### Passando Parâmetros para Canais

Você pode passar parâmetros do lado do cliente para o lado do servidor ao criar uma assinatura. Por exemplo:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Um objeto passado como primeiro argumento para `subscriptions.create` se torna o hash de parâmetros no canal de cabo. A palavra-chave `channel` é obrigatória:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# Em algum lugar do seu aplicativo isso é chamado, talvez
# de um NewCommentJob.
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'Este é um aplicativo de bate-papo legal.'
  }
)
```

### Rebroadcasting de uma Mensagem

Um caso de uso comum é *rebroadcastar* uma mensagem enviada por um cliente para qualquer outro cliente conectado.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "Este é um aplicativo de bate-papo legal." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "Este é um aplicativo de bate-papo legal." })
```

O rebroadcast será recebido por todos os clientes conectados, _incluindo_ o cliente que enviou a mensagem. Observe que os parâmetros são os mesmos que quando você se inscreveu no canal.

## Exemplos Full-Stack

As seguintes etapas de configuração são comuns a ambos os exemplos:

  1. [Configure sua conexão](#connection-setup).
  2. [Configure seu canal pai](#parent-channel-setup).
  3. [Conecte seu consumidor](#connect-consumer).

### Exemplo 1: Aparências de Usuários

Aqui está um exemplo simples de um canal que rastreia se um usuário está online ou não e em qual página eles estão. (Isso é útil para criar recursos de presença, como mostrar um ponto verde ao lado de um nome de usuário se eles estiverem online).

Crie o canal de aparência do lado do servidor:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```
Quando uma assinatura é iniciada, o callback `subscribed` é acionado e aproveitamos essa oportunidade para dizer "o usuário atual realmente apareceu". Essa API de aparecer/desaparecer pode ser suportada pelo Redis, um banco de dados ou qualquer outra coisa.

Crie a assinatura do canal de aparecimento no lado do cliente:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Chamado uma vez quando a assinatura é criada.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Chamado quando a assinatura está pronta para uso no servidor.
  connected() {
    this.install()
    this.update()
  },

  // Chamado quando a conexão WebSocket é fechada.
  disconnected() {
    this.uninstall()
  },

  // Chamado quando a assinatura é rejeitada pelo servidor.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Chama `AppearanceChannel#appear(data)` no servidor.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Chama `AppearanceChannel#away` no servidor.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### Interação Cliente-Servidor

1. **Cliente** se conecta ao **Servidor** via `createConsumer()`. (`consumer.js`). O
   **Servidor** identifica essa conexão pelo `current_user`.

2. **Cliente** se inscreve no canal de aparecimento via
   `consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Servidor** reconhece que uma nova assinatura foi iniciada para o canal de
   aparecimento e executa seu callback `subscribed`, chamando o método `appear`
   em `current_user`. (`appearance_channel.rb`)

4. **Cliente** reconhece que uma assinatura foi estabelecida e chama
   `connected` (`appearance_channel.js`), que por sua vez chama `install` e `appear`.
   `appear` chama `AppearanceChannel#appear(data)` no servidor e fornece um
   hash de dados `{ appearing_on: this.appearingOn }`. Isso é
   possível porque a instância do canal no lado do servidor automaticamente expõe todos
   os métodos públicos declarados na classe (exceto os callbacks), para que eles possam ser
   acessados como chamadas de procedimento remoto através do método `perform` de uma assinatura.

5. **Servidor** recebe a solicitação para a ação `appear` no canal de aparecimento para a conexão identificada por `current_user`
   (`appearance_channel.rb`). **Servidor** recupera os dados com a
   chave `:appearing_on` do hash de dados e define-o como o valor para a chave `:on`
   que está sendo passada para `current_user.appear`.

### Exemplo 2: Recebendo Novas Notificações Web

O exemplo de aparecimento tratava de expor funcionalidades do servidor para
invocação no lado do cliente por meio da conexão WebSocket. Mas a grande coisa
sobre WebSockets é que é uma via de mão dupla. Então, agora, vamos mostrar um exemplo
em que o servidor invoca uma ação no cliente.

Este é um canal de notificações web que permite acionar notificações web no lado do cliente
quando você transmite para os fluxos relevantes:

Crie o canal de notificações web no lado do servidor:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Crie a assinatura do canal de notificações web no lado do cliente:

```js
// app/javascript/channels/web_notifications_channel.js
// Lado do cliente que pressupõe que você já solicitou
// a permissão para enviar notificações web.
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

Transmita conteúdo para uma instância do canal de notificações web de qualquer outro lugar em seu
aplicativo:

```ruby
# Em algum lugar do seu aplicativo, isso é chamado, talvez de um NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'Coisas novas!',
  body: 'Todas as notícias que cabem imprimir'
)
```

A chamada `WebNotificationsChannel.broadcast_to` coloca uma mensagem na fila de pubsub do adaptador de assinatura atual sob um nome de transmissão separado para cada
usuário. Para um usuário com um ID de 1, o nome de transmissão seria
`web_notifications:1`.

O canal foi instruído a transmitir tudo o que chega em
`web_notifications:1` diretamente para o cliente, invocando o callback `received`.
Os dados passados como argumento são o hash enviado como segundo parâmetro
para a chamada de transmissão no lado do servidor, codificado em JSON para a viagem pela rede
e descompactado para o argumento de dados que chega como `received`.

### Exemplos Mais Completos

Consulte o repositório [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
para um exemplo completo de como configurar o Action Cable em um aplicativo Rails e adicionar canais.

## Configuração

O Action Cable tem duas configurações obrigatórias: um adaptador de assinatura e as origens de solicitação permitidas.

### Adaptador de Assinatura

Por padrão, o Action Cable procura por um arquivo de configuração em `config/cable.yml`.
O arquivo deve especificar um adaptador para cada ambiente do Rails. Consulte a
seção [Dependências](#dependências) para obter informações adicionais sobre adaptadores.

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### Configuração do Adaptador

Abaixo está uma lista dos adaptadores de assinatura disponíveis para os usuários finais.

##### Adaptador Async

O adaptador async é destinado para desenvolvimento/teste e não deve ser usado em produção.

##### Adaptador Redis

O adaptador Redis requer que os usuários forneçam uma URL apontando para o servidor Redis.
Além disso, um `channel_prefix` pode ser fornecido para evitar colisões de nomes de canal
quando se usa o mesmo servidor Redis para várias aplicações. Consulte a documentação do [Redis Pub/Sub](https://redis.io/docs/manual/pubsub/#database--scoping) para mais detalhes.

O adaptador Redis também suporta conexões SSL/TLS. Os parâmetros SSL/TLS necessários podem ser passados na chave `ssl_params` no arquivo de configuração YAML.

```
produção:
  adaptador: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/caminho/para/ca.crt"
  }
```

As opções fornecidas para `ssl_params` são passadas diretamente para o método `OpenSSL::SSL::SSLContext#set_params` e podem ser qualquer atributo válido do contexto SSL.
Consulte a documentação do [OpenSSL::SSL::SSLContext](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) para outros atributos disponíveis.

Se você estiver usando certificados autoassinados para o adaptador Redis atrás de um firewall e optar por pular a verificação do certificado, então o `verify_mode` do SSL deve ser definido como `OpenSSL::SSL::VERIFY_NONE`.

AVISO: Não é recomendado usar `VERIFY_NONE` em produção, a menos que você entenda absolutamente as implicações de segurança. Para definir essa opção para o adaptador Redis, a configuração deve ser `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`.

##### Adaptador PostgreSQL

O adaptador PostgreSQL usa o pool de conexões do Active Record e, portanto, a
configuração do banco de dados `config/database.yml` da aplicação para sua conexão.
Isso pode mudar no futuro. [#27214](https://github.com/rails/rails/issues/27214)

### Origens de Solicitação Permitidas

Action Cable só aceitará solicitações de origens especificadas, que são
passadas para a configuração do servidor como um array. As origens podem ser instâncias de
strings ou expressões regulares, contra as quais será feita uma verificação de correspondência.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

Para desabilitar e permitir solicitações de qualquer origem:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

Por padrão, o Action Cable permite todas as solicitações de localhost:3000 quando executado
no ambiente de desenvolvimento.

### Configuração do Consumidor

Para configurar a URL, adicione uma chamada para [`action_cable_meta_tag`][] no seu layout HTML
HEAD. Isso usa uma URL ou caminho normalmente definido via [`config.action_cable.url`][] nos
arquivos de configuração do ambiente.


### Configuração do Pool de Trabalhadores

O pool de trabalhadores é usado para executar callbacks de conexão e ações de canal em
isolamento da thread principal do servidor. O Action Cable permite que a aplicação
configure o número de threads processadas simultaneamente no pool de trabalhadores.

```ruby
config.action_cable.worker_pool_size = 4
```

Além disso, observe que seu servidor deve fornecer pelo menos o mesmo número de conexões de banco de dados
que você tem trabalhadores. O tamanho padrão do pool de trabalhadores é definido como 4, então
isso significa que você deve disponibilizar pelo menos 4 conexões de banco de dados.
Você pode alterar isso em `config/database.yml` através do atributo `pool`.

### Registro do Lado do Cliente

O registro do lado do cliente está desabilitado por padrão. Você pode habilitar isso definindo `ActionCable.logger.enabled` como true.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### Outras Configurações

A outra opção comum a ser configurada são as tags de log aplicadas ao
logger de conexão por conexão. Aqui está um exemplo que usa
o ID da conta do usuário, se disponível, caso contrário, "no-account" enquanto marca:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Para uma lista completa de todas as opções de configuração, consulte a
classe `ActionCable::Server::Configuration`.

## Executando Servidores Cable Autônomos

O Action Cable pode ser executado como parte da sua aplicação Rails ou como
um servidor autônomo. No desenvolvimento, executar como parte do aplicativo Rails
geralmente é bom, mas em produção você deve executá-lo como um servidor autônomo.

### No Aplicativo

O Action Cable pode ser executado junto com sua aplicação Rails. Por exemplo, para
ouvir solicitações WebSocket em `/websocket`, especifique esse caminho para
[`config.action_cable.mount_path`][]:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Você pode usar `ActionCable.createConsumer()` para se conectar ao servidor de cabo
se [`action_cable_meta_tag`][] for invocado no layout. Caso contrário, um caminho é
especificado como primeiro argumento para `createConsumer` (por exemplo, `ActionCable.createConsumer("/websocket")`).

Para cada instância do servidor que você cria e para cada trabalhador que seu servidor
inicia, você também terá uma nova instância do Action Cable, mas o adaptador Redis ou
PostgreSQL mantém as mensagens sincronizadas entre as conexões.


### Autônomo

Os servidores de cabo podem ser separados do seu servidor de aplicação normal. É
ainda uma aplicação Rack, mas é sua própria aplicação Rack. A configuração básica recomendada
é a seguinte:
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

Em seguida, para iniciar o servidor:

```
bundle exec puma -p 28080 cable/config.ru
```

Isso inicia um servidor de cabo na porta 28080. Para informar ao Rails para usar este
servidor, atualize sua configuração:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # use wss:// in production
end
```

Por fim, certifique-se de ter [configurado o consumidor corretamente](#consumer-configuration).

### Notas

O servidor WebSocket não tem acesso à sessão, mas tem
acesso aos cookies. Isso pode ser usado quando você precisa lidar
com autenticação. Você pode ver uma maneira de fazer isso com o Devise neste [artigo](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## Dependências

Action Cable fornece uma interface de adaptador de assinatura para processar suas
internos de pubsub. Por padrão, os adaptadores assíncronos, inline, PostgreSQL e Redis
são incluídos. O adaptador padrão
em novas aplicações Rails é o adaptador assíncrono (`async`).

O lado Ruby das coisas é construído em cima de [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) e [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Implantação

Action Cable é alimentado por uma combinação de WebSockets e threads. Tanto o
encanamento do framework quanto o trabalho do canal especificado pelo usuário são tratados internamente por
utilizando o suporte nativo de threads do Ruby. Isso significa que você pode usar todos os seus modelos Rails existentes sem problemas, desde que você não tenha cometido nenhum pecado de segurança de thread.

O servidor Action Cable implementa a API de sequestro de soquete do Rack,
permitindo assim o uso de um padrão multithread para gerenciar conexões
internamente, independentemente de o servidor de aplicativos ser multithread ou não.

Consequentemente, o Action Cable funciona com servidores populares como Unicorn, Puma e
Passenger.

## Testando

Você pode encontrar instruções detalhadas sobre como testar a funcionalidade do Action Cable no
[guia de testes](testing.html#testing-action-cable).
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
