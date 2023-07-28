**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Noções básicas do Action Mailer
====================

Este guia fornece tudo o que você precisa para começar a enviar e-mails a partir de sua aplicação, e muitos detalhes internos do Action Mailer. Ele também aborda como testar seus mailers.

Depois de ler este guia, você saberá:

* Como enviar e-mails dentro de uma aplicação Rails.
* Como gerar e editar uma classe Action Mailer e uma visualização de mailer.
* Como configurar o Action Mailer para o seu ambiente.
* Como testar suas classes Action Mailer.

--------------------------------------------------------------------------------

O que é o Action Mailer?
----------------------

O Action Mailer permite que você envie e-mails a partir de sua aplicação usando classes de mailer e visualizações.

### Mailers são semelhantes a Controllers

Eles herdam de [`ActionMailer::Base`][] e ficam em `app/mailers`. Mailers também funcionam de forma muito semelhante aos controllers. Alguns exemplos de semelhanças são enumerados abaixo. Mailers têm:

* Ações e também visualizações associadas que aparecem em `app/views`.
* Variáveis de instância que são acessíveis nas visualizações.
* A capacidade de utilizar layouts e partials.
* A capacidade de acessar um hash de parâmetros.


Enviando E-mails
--------------

Esta seção fornecerá um guia passo a passo para criar um mailer e suas visualizações.

### Passo a passo para gerar um Mailer

#### Crie o Mailer

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Como você pode ver, você pode gerar mailers da mesma forma que usa outros geradores com o Rails.

Se você não quiser usar um gerador, você pode criar seu próprio arquivo dentro de `app/mailers`, apenas certifique-se de que ele herda de `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Edite o Mailer

Mailers têm métodos chamados "ações" e eles usam visualizações para estruturar seu conteúdo. Onde um controller gera conteúdo como HTML para enviar de volta ao cliente, um Mailer cria uma mensagem para ser entregue por e-mail.

`app/mailers/user_mailer.rb` contém um mailer vazio:

```ruby
class UserMailer < ApplicationMailer
end
```

Vamos adicionar um método chamado `welcome_email`, que enviará um e-mail para o endereço de e-mail registrado do usuário:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Bem-vindo ao Meu Site Fantástico')
  end
end
```

Aqui está uma breve explicação dos itens apresentados no método anterior. Para uma lista completa de todas as opções disponíveis, por favor, dê uma olhada mais adiante na seção Lista completa de atributos configuráveis pelo usuário do Action Mailer.

* O método [`default`][] define valores padrão para todos os e-mails enviados a partir deste mailer. Neste caso, usamos para definir o valor do cabeçalho `:from` para todas as mensagens nesta classe. Isso pode ser substituído em cada e-mail.
* O método [`mail`][] cria a mensagem de e-mail real. Usamos para especificar os valores dos cabeçalhos como `:to` e `:subject` por e-mail.


#### Crie uma Visualização de Mailer

Crie um arquivo chamado `welcome_email.html.erb` em `app/views/user_mailer/`. Este será o modelo usado para o e-mail, formatado em HTML:
```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Bem-vindo ao exemplo.com, <%= @user.name %></h1>
    <p>
      Você se cadastrou com sucesso no exemplo.com,
      seu nome de usuário é: <%= @user.login %>.<br>
    </p>
    <p>
      Para fazer login no site, basta seguir este link: <%= @url %>.
    </p>
    <p>Obrigado por se juntar a nós e tenha um ótimo dia!</p>
  </body>
</html>
```

Vamos também criar uma parte de texto para este e-mail. Nem todos os clientes preferem e-mails em HTML,
então enviar ambos é uma boa prática. Para fazer isso, crie um arquivo chamado
`welcome_email.text.erb` em `app/views/user_mailer/`:

```erb
Bem-vindo ao exemplo.com, <%= @user.name %>
===============================================

Você se cadastrou com sucesso no exemplo.com,
seu nome de usuário é: <%= @user.login %>.

Para fazer login no site, basta seguir este link: <%= @url %>.

Obrigado por se juntar a nós e tenha um ótimo dia!
```

Quando você chamar o método `mail` agora, o Action Mailer detectará os dois templates
(texto e HTML) e automaticamente gerará um e-mail `multipart/alternative`.

#### Chamando o Mailer

Mailers são apenas outra forma de renderizar uma view. Em vez de renderizar uma
view e enviá-la através do protocolo HTTP, eles a enviam através
dos protocolos de e-mail. Por causa disso, faz sentido que o seu
controller instrua o Mailer a enviar um e-mail quando um usuário for criado com sucesso.

Configurar isso é simples.

Primeiro, vamos criar um scaffold para `User`:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

Agora que temos um modelo de usuário para trabalhar, vamos editar o arquivo
`app/controllers/users_controller.rb`, fazendo com que ele instrua o `UserMailer` a enviar
um e-mail para o usuário recém-criado, editando a ação create e inserindo uma
chamada para `UserMailer.with(user: @user).welcome_email` logo após o usuário ser salvo com sucesso.

Vamos enfileirar o e-mail para ser enviado usando [`deliver_later`][], que é
suportado pelo Active Job. Dessa forma, a ação do controller pode continuar sem
esperar o envio ser concluído.

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Diga ao UserMailer para enviar um e-mail de boas-vindas após salvar
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'Usuário criado com sucesso.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

NOTA: O comportamento padrão do Active Job é executar jobs via o adaptador `:async`.
Então, você pode usar `deliver_later` para enviar e-mails de forma assíncrona.
O adaptador padrão do Active Job executa jobs com uma thread pool em processo.
Isso é adequado para ambientes de desenvolvimento/teste, pois não requer
nenhuma infraestrutura externa, mas não é adequado para produção, pois descarta
jobs pendentes ao reiniciar.
Se você precisa de um backend persistente, você precisará usar um adaptador do Active Job
que tenha um backend persistente (Sidekiq, Resque, etc).

Se você quiser enviar e-mails imediatamente (de um cronjob, por exemplo), basta chamar
[`deliver_now`][]:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```
Qualquer par chave-valor passado para [`with`][] se torna os `params` para a ação do mailer. Portanto, `with(user: @user, account: @user.account)` torna `params[:user]` e `params[:account]` disponíveis na ação do mailer. Assim como os controladores têm params.

O método `welcome_email` retorna um objeto [`ActionMailer::MessageDelivery`][] que pode ser instruído a `deliver_now` ou `deliver_later` para enviar-se. O objeto `ActionMailer::MessageDelivery` é um invólucro em torno de um [`Mail::Message`][]. Se você quiser inspecionar, alterar ou fazer qualquer outra coisa com o objeto `Mail::Message`, você pode acessá-lo com o método [`message`][] no objeto `ActionMailer::MessageDelivery`.


### Codificação automática de valores de cabeçalho

O Action Mailer lida com a codificação automática de caracteres multibyte dentro de cabeçalhos e corpos.

Para exemplos mais complexos, como definir conjuntos de caracteres alternativos ou texto de auto-codificação primeiro, consulte a biblioteca [Mail](https://github.com/mikel/mail).

### Lista completa dos métodos do Action Mailer

Existem apenas três métodos que você precisa para enviar praticamente qualquer mensagem de email:

* [`headers`][] - Especifica qualquer cabeçalho no email que você deseja. Você pode passar um hash de nomes de campo de cabeçalho e pares de valores, ou pode chamar `headers[:nome_do_campo] = 'valor'`.
* [`attachments`][] - Permite adicionar anexos ao seu email. Por exemplo, `attachments['nome-do-arquivo.jpg'] = File.read('nome-do-arquivo.jpg')`.
* [`mail`][] - Cria o próprio email. Você pode passar cabeçalhos como um hash para o método `mail` como um parâmetro. `mail` criará um email - seja texto simples ou multipart - dependendo dos modelos de email que você definiu.


#### Adicionando anexos

O Action Mailer torna muito fácil adicionar anexos.

* Passe o nome do arquivo e o conteúdo e o Action Mailer e o [gem Mail](https://github.com/mikel/mail) adivinharão automaticamente o `mime_type`, definirão a `encoding` e criarão o anexo.

    ```ruby
    attachments['nome-do-arquivo.jpg'] = File.read('/caminho/para/nome-do-arquivo.jpg')
    ```

  Quando o método `mail` for acionado, ele enviará um email multipart com um anexo, devidamente aninhado, sendo o nível superior `multipart/mixed` e a primeira parte sendo um `multipart/alternative` contendo as mensagens de email em texto simples e HTML.

NOTA: O Mail codificará automaticamente em Base64 um anexo. Se você quiser algo diferente, codifique seu conteúdo e passe o conteúdo codificado e a codificação em um `Hash` para o método `attachments`.

* Passe o nome do arquivo e especifique cabeçalhos e conteúdo e o Action Mailer e o Mail usarão as configurações que você passar.

    ```ruby
    conteudo_codificado = SpecialEncode(File.read('/caminho/para/nome-do-arquivo.jpg'))
    attachments['nome-do-arquivo.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: conteudo_codificado
    }
    ```

NOTA: Se você especificar uma codificação, o Mail assumirá que seu conteúdo já está codificado e não tentará codificá-lo em Base64.

#### Criando anexos inline

O Action Mailer 3.0 torna os anexos inline, que envolviam muita manipulação nas versões anteriores à 3.0, muito mais simples e triviais como deveriam ser.

* Primeiro, para informar ao Mail para transformar um anexo em um anexo inline, basta chamar `#inline` no método attachments dentro do seu Mailer:

    ```ruby
    def welcome
      attachments.inline['imagem.jpg'] = File.read('/caminho/para/imagem.jpg')
    end
    ```

* Em seguida, em sua visualização, você pode simplesmente referenciar `attachments` como um hash e especificar qual anexo você deseja mostrar, chamando `url` nele e passando o resultado para o método `image_tag`:
    ```html+erb
    <p>Olá, esta é a nossa imagem</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Como esta é uma chamada padrão para `image_tag`, você pode passar um hash de opções
  após a URL do anexo, assim como faria para qualquer outra imagem:

    ```html+erb
    <p>Olá, esta é a nossa imagem</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'Minha Foto', class: 'fotos' %>
    ```

#### Enviando Email para Vários Destinatários

É possível enviar email para um ou mais destinatários em um único email (por exemplo,
informando todos os administradores sobre um novo cadastro) definindo a lista de emails na chave `:to`.
A lista de emails pode ser um array de endereços de email ou uma única string
com os endereços separados por vírgulas.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notificacao@example.com'

  def novo_cadastro(usuario)
    @usuario = usuario
    mail(subject: "Novo Cadastro de Usuário: #{@usuario.email}")
  end
end
```

O mesmo formato pode ser usado para definir destinatários em cópia (Cc:) e cópia oculta
(Bcc:), usando as chaves `:cc` e `:bcc`, respectivamente.

#### Enviando Email com Nome

Às vezes, você deseja mostrar o nome da pessoa em vez de apenas o endereço de email
quando ela recebe o email. Você pode usar [`email_address_with_name`][] para
isso:

```ruby
def email_de_boas_vindas
  @usuario = params[:usuario]
  mail(
    to: email_address_with_name(@usuario.email, @usuario.nome),
    subject: 'Bem-vindo ao Meu Site Fantástico'
  )
end
```

A mesma técnica funciona para especificar um nome de remetente:

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notificacao@example.com', 'Notificações da Empresa Exemplo')
end
```

Se o nome for uma string vazia, apenas o endereço será retornado.


### Visualizações de Mailer

As visualizações de mailer estão localizadas no diretório `app/views/nome_da_classe_mailer`.
A visualização de mailer específica é conhecida pela classe porque seu nome é o mesmo que o
método do mailer. No nosso exemplo acima, a visualização de mailer para o
método `email_de_boas_vindas` estará em `app/views/user_mailer/email_de_boas_vindas.html.erb`
para a versão HTML e `email_de_boas_vindas.text.erb` para a versão de texto simples.

Para alterar a visualização de mailer padrão para sua ação, você faz algo como:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notificacoes@example.com'

  def email_de_boas_vindas
    @usuario = params[:usuario]
    @url  = 'http://example.com/login'
    mail(to: @usuario.email,
         subject: 'Bem-vindo ao Meu Site Fantástico',
         template_path: 'notificacoes',
         template_name: 'outra')
  end
end
```

Neste caso, ele procurará os templates em `app/views/notificacoes` com o nome
`outra`. Você também pode especificar um array de caminhos para `template_path`, e eles
serão pesquisados em ordem.

Se você deseja mais flexibilidade, também pode passar um bloco e renderizar templates específicos
ou até mesmo renderizar inline ou texto sem usar um arquivo de template:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notificacoes@example.com'

  def email_de_boas_vindas
    @usuario = params[:usuario]
    @url  = 'http://example.com/login'
    mail(to: @usuario.email,
         subject: 'Bem-vindo ao Meu Site Fantástico') do |format|
      format.html { render 'outro_template' }
      format.text { render plain: 'Renderizar texto' }
    end
  end
end
```

Isso renderizará o template 'outro_template.html.erb' para a parte HTML e
usará o texto renderizado para a parte de texto. O comando de renderização é o mesmo usado
dentro do Action Controller, então você pode usar todas as mesmas opções, como
`:text`, `:inline`, etc.

Se você deseja renderizar um template localizado fora do diretório padrão `app/views/nome_do_mailer/`, você pode aplicar o [`prepend_view_path`][], assim:
```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # Isso tentará carregar o template "custom/path/to/mailer/view/welcome_email"
  def welcome_email
    # ...
  end
end
```

Você também pode considerar usar o método [`append_view_path`][].


#### Caching de Visualização de Email

Você pode realizar o cache de fragmentos nas visualizações de email, assim como nas visualizações de aplicativos, usando o método [`cache`][].

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

E para usar esse recurso, você precisa configurar sua aplicação com isso:

```ruby
config.action_mailer.perform_caching = true
```

O cache de fragmentos também é suportado em emails multipartes.
Leia mais sobre o cache no [guia de cache do Rails](caching_with_rails.html).


### Layouts do Action Mailer

Assim como as visualizações de controladores, você também pode ter layouts de mailer. O nome do layout
precisa ser o mesmo do seu mailer, como `user_mailer.html.erb` e
`user_mailer.text.erb` para serem automaticamente reconhecidos pelo seu mailer como um
layout.

Para usar um arquivo diferente, chame [`layout`][] no seu mailer:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # use awesome.(html|text).erb como o layout
end
```

Assim como nas visualizações de controladores, use `yield` para renderizar a visualização dentro do
layout.

Você também pode passar uma opção `layout: 'nome_do_layout'` para a chamada de renderização dentro
do bloco de formato para especificar layouts diferentes para formatos diferentes:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Irá renderizar a parte HTML usando o arquivo `my_layout.html.erb` e a parte de texto
com o arquivo `user_mailer.text.erb` usual, se existir.


### Visualizando Emails

As visualizações do Action Mailer fornecem uma maneira de ver como os emails são exibidos visitando uma
URL especial que os renderiza. No exemplo acima, a classe de visualização para
`UserMailer` deve ser chamada `UserMailerPreview` e localizada em
`test/mailers/previews/user_mailer_preview.rb`. Para ver a visualização de
`welcome_email`, implemente um método que tenha o mesmo nome e chame
`UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Então a visualização estará disponível em <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Se você alterar algo em `app/views/user_mailer/welcome_email.html.erb`
ou no mailer em si, ele será recarregado e renderizado automaticamente para que você possa
ver o novo estilo instantaneamente. Uma lista de visualizações também está disponível
em <http://localhost:3000/rails/mailers>.

Por padrão, essas classes de visualização ficam em `test/mailers/previews`.
Isso pode ser configurado usando a opção `preview_paths`. Por exemplo, se você
quiser adicionar `lib/mailer_previews` a ele, você pode configurá-lo em
`config/application.rb`:

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### Gerando URLs nas Visualizações do Action Mailer

Ao contrário dos controladores, a instância do mailer não possui nenhum contexto sobre a
solicitação de entrada, então você precisará fornecer o parâmetro `:host` você mesmo.

Como o `:host` geralmente é consistente em toda a aplicação, você pode configurá-lo
globalmente em `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

Devido a esse comportamento, você não pode usar nenhum dos ajudantes `*_path` dentro de
um email. Em vez disso, você precisará usar o ajudante associado `*_url`. Por exemplo,
em vez de usar

```html+erb
<%= link_to 'welcome', welcome_path %>
```

Você precisará usar:

```html+erb
<%= link_to 'welcome', welcome_url %>
```

Ao usar a URL completa, seus links agora funcionarão em seus emails.
#### Gerando URLs com `url_for`

[`url_for`][] gera uma URL completa por padrão em templates.

Se você não configurou a opção `:host` globalmente, certifique-se de passá-la para
`url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### Gerando URLs com Rotas Nomeadas

Clientes de e-mail não possuem contexto web e, portanto, os caminhos não possuem uma URL base para formar endereços web completos. Assim, você sempre deve usar a variante `*_url` dos auxiliares de rota nomeada.

Se você não configurou a opção `:host` globalmente, certifique-se de passá-la para o auxiliar de URL.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTA: links não-`GET` requerem [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) ou
[jQuery UJS](https://github.com/rails/jquery-ujs), e não funcionarão em templates de mailer. Eles resultarão em requisições `GET` normais.

### Adicionando Imagens em Visualizações de Action Mailer

Ao contrário dos controladores, a instância do mailer não possui nenhum contexto sobre a solicitação recebida, portanto, você precisará fornecer o parâmetro `:asset_host` você mesmo.

Como o `:asset_host` geralmente é consistente em toda a aplicação, você pode configurá-lo globalmente em `config/application.rb`:

```ruby
config.asset_host = 'http://example.com'
```

Agora você pode exibir uma imagem dentro do seu e-mail.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Enviando E-mails Multipartes

O Action Mailer enviará automaticamente e-mails multipartes se você tiver templates diferentes para a mesma ação. Portanto, para o nosso exemplo `UserMailer`, se você tiver `welcome_email.text.erb` e `welcome_email.html.erb` em `app/views/user_mailer`, o Action Mailer enviará automaticamente um e-mail multipartes com as versões HTML e texto configuradas como partes diferentes.

A ordem das partes inseridas é determinada pelo `:parts_order` dentro do método `ActionMailer::Base.default`.

### Enviando E-mails com Opções de Entrega Dinâmicas

Se você deseja substituir as opções de entrega padrão (por exemplo, credenciais SMTP) ao enviar e-mails, você pode fazer isso usando `delivery_method_options` na ação do mailer.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### Enviando E-mails sem Renderização de Template

Pode haver casos em que você deseja pular a etapa de renderização do template e fornecer o corpo do e-mail como uma string. Você pode fazer isso usando a opção `:body`. Nesses casos, não se esqueça de adicionar a opção `:content_type`. Caso contrário, o Rails usará `text/plain` como padrão.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Callbacks do Action Mailer
-----------------------

O Action Mailer permite que você especifique um [`before_action`][], [`after_action`][] e
[`around_action`][] para configurar a mensagem, e [`before_deliver`][], [`after_deliver`][] e
[`around_deliver`][] para controlar a entrega.

* Callbacks podem ser especificados com um bloco ou um símbolo para um método na classe do mailer, semelhante aos controladores.

* Você pode usar um `before_action` para definir variáveis de instância, preencher o objeto de e-mail com padrões ou inserir cabeçalhos e anexos padrão.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* Você pode usar um `after_action` para fazer uma configuração semelhante a um `before_action`, mas usando variáveis de instância definidas na ação do seu mailer.

* Usar um callback `after_action` também permite que você substitua as configurações do método de entrega atualizando `mail.delivery_method.settings`.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # Você tem acesso à instância do mail,
      # às variáveis de instância @business e @user aqui
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Você pode usar um `after_delivery` para registrar o envio da mensagem.

* Os callbacks do Mailer interrompem o processamento adicional se o corpo for definido como um valor diferente de `nil`. `before_deliver` pode interromper com `throw :abort`.


Usando os Helpers do Action Mailer
----------------------------------

O Action Mailer herda de `AbstractController`, então você tem acesso à maioria
dos mesmos helpers que você tem no Action Controller.

Também existem alguns métodos auxiliares específicos do Action Mailer disponíveis em
[`ActionMailer::MailHelper`][]. Por exemplo, eles permitem acessar a instância do mailer
a partir da sua view com [`mailer`][MailHelper#mailer], e acessar a mensagem como [`message`][MailHelper#message]:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```


Configuração do Action Mailer
----------------------------

As seguintes opções de configuração são melhores definidas em um dos arquivos de ambiente
(environment.rb, production.rb, etc...)

| Configuração | Descrição |
|---------------|-------------|
|`logger`|Gera informações sobre a execução do envio de emails, se disponível. Pode ser definido como `nil` para desativar o registro. Compatível tanto com o `Logger` padrão do Ruby quanto com o `Log4r`.|
|`smtp_settings`|Permite configuração detalhada para o método de entrega `:smtp`:<ul><li>`:address` - Permite usar um servidor de email remoto. Basta alterá-lo do valor padrão `"localhost"`.</li><li>`:port` - Caso o servidor de email não esteja em execução na porta 25, você pode alterá-la.</li><li>`:domain` - Se você precisar especificar um domínio HELO, pode fazê-lo aqui.</li><li>`:user_name` - Se o servidor de email exigir autenticação, defina o nome de usuário nesta opção.</li><li>`:password` - Se o servidor de email exigir autenticação, defina a senha nesta opção.</li><li>`:authentication` - Se o servidor de email exigir autenticação, você precisa especificar o tipo de autenticação aqui. Isso é um símbolo e pode ser `:plain` (enviará a senha em texto claro), `:login` (enviará a senha codificada em Base64) ou `:cram_md5` (combina um mecanismo de Desafio/Resposta para trocar informações e um algoritmo criptográfico de Digest de Mensagem 5 para gerar hashes de informações importantes)</li><li>`:enable_starttls` - Use STARTTLS ao se conectar ao servidor SMTP e falhe se não for suportado. Padrão: `false`.</li><li>`:enable_starttls_auto` - Detecta se o STARTTLS está habilitado no servidor SMTP e começa a usá-lo. Padrão: `true`.</li><li>`:openssl_verify_mode` - Ao usar TLS, você pode definir como o OpenSSL verifica o certificado. Isso é muito útil se você precisar validar um certificado autoassinado e/ou um certificado curinga. Você pode usar o nome de uma constante de verificação do OpenSSL ('none' ou 'peer') ou diretamente a constante (`OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Habilita a conexão SMTP para usar SMTP/TLS (SMTPS: conexão SMTP sobre TLS direto)</li><li>`:open_timeout` - Número de segundos para aguardar ao tentar abrir uma conexão.</li><li>`:read_timeout` - Número de segundos para aguardar até que ocorra um timeout em uma chamada de leitura (read(2)).</li></ul>|
|`sendmail_settings`|Permite substituir as opções para o método de entrega `:sendmail`.<ul><li>`:location` - A localização do executável sendmail. Padrão: `/usr/sbin/sendmail`.</li><li>`:arguments` - Os argumentos da linha de comando a serem passados para o sendmail. Padrão: `["-i"]`.</li></ul>|
|`raise_delivery_errors`|Se erros devem ser levantados caso o email não seja entregue. Isso só funciona se o servidor de email externo estiver configurado para entrega imediata. Padrão: `true`.|
|`delivery_method`|Define um método de entrega. Os valores possíveis são:<ul><li>`:smtp` (padrão), pode ser configurado usando [`config.action_mailer.smtp_settings`][].</li><li>`:sendmail`, pode ser configurado usando [`config.action_mailer.sendmail_settings`][].</li><li>`:file`: salva os emails em arquivos; pode ser configurado usando `config.action_mailer.file_settings`.</li><li>`:test`: salva os emails no array `ActionMailer::Base.deliveries`.</li></ul>Consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionMailer/Base.html) para mais informações.|
|`perform_deliveries`|Determina se os envios são realmente realizados quando o método `deliver` é invocado na mensagem do Mail. Por padrão, eles são realizados, mas isso pode ser desativado para ajudar nos testes funcionais. Se esse valor for `false`, o array `deliveries` não será preenchido mesmo se o `delivery_method` for `:test`.|
|`deliveries`|Mantém um array com todos os emails enviados pelo Action Mailer com o método de entrega `:test`. Mais útil para testes unitários e funcionais.|
|`delivery_job`|A classe de job usada com `deliver_later`. Padrão: `ActionMailer::MailDeliveryJob`.|
|`deliver_later_queue_name`|O nome da fila usada com o `delivery_job` padrão. Padrão: a fila padrão do Active Job.|
|`default_options`|Permite definir valores padrão para as opções do método `mail` (`:from`, `:reply_to`, etc.).|
Para uma descrição completa das possíveis configurações, consulte o [Configurando o Action Mailer](configuring.html#configuring-action-mailer) em nosso guia Configurando Aplicações Rails.


### Exemplo de Configuração do Action Mailer

Um exemplo seria adicionar o seguinte ao seu arquivo `config/environments/$RAILS_ENV.rb` apropriado:

```ruby
config.action_mailer.delivery_method = :sendmail
# Padrão:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Configuração do Action Mailer para o Gmail

O Action Mailer usa a [gem Mail](https://github.com/mikel/mail) e aceita uma configuração similar. Adicione isso ao seu arquivo `config/environments/$RAILS_ENV.rb` para enviar via Gmail:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

Se você estiver usando uma versão antiga da gem Mail (2.6.x ou anterior), use `enable_starttls_auto` em vez de `enable_starttls`.

NOTA: O Google [bloqueia logins](https://support.google.com/accounts/answer/6010255) de aplicativos que considera menos seguros. Você pode alterar suas configurações do Gmail [aqui](https://www.google.com/settings/security/lesssecureapps) para permitir as tentativas. Se sua conta do Gmail tiver autenticação em duas etapas ativada, você precisará definir uma [senha de aplicativo](https://myaccount.google.com/apppasswords) e usá-la em vez de sua senha regular.

Testando o Mailer
--------------

Você pode encontrar instruções detalhadas sobre como testar seus mailers no [guia de testes](testing.html#testing-your-mailers).

Interceptando e Observando Emails
-------------------

O Action Mailer fornece ganchos nos métodos de observação e interceptação do Mail. Isso permite que você registre classes que são chamadas durante o ciclo de vida de entrega de e-mails enviados.

### Interceptando Emails

Os interceptadores permitem que você faça modificações nos e-mails antes de serem entregues aos agentes de entrega. Uma classe de interceptador deve implementar o método `::delivering_email(message)`, que será chamado antes do envio do e-mail.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Antes que o interceptador possa fazer seu trabalho, você precisa registrá-lo usando a opção de configuração `interceptors`. Você pode fazer isso em um arquivo de inicialização como `config/initializers/mail_interceptors.rb`:

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

NOTA: O exemplo acima usa um ambiente personalizado chamado "staging" para um servidor semelhante a produção, mas para fins de teste. Você pode ler [Criando Ambientes Rails](configuring.html#creating-rails-environments) para obter mais informações sobre ambientes Rails personalizados.

### Observando Emails

Os observadores permitem que você tenha acesso à mensagem de e-mail depois que ela foi enviada. Uma classe de observador deve implementar o método `:delivered_email(message)`, que será chamado após o envio do e-mail.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

Semelhante aos interceptadores, você deve registrar os observadores usando a opção de configuração `observers`. Você pode fazer isso em um arquivo de inicialização como `config/initializers/mail_observers.rb`:

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
