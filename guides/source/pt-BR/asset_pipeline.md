**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
O Pipeline de Ativos
==================

Este guia aborda o pipeline de ativos.

Após ler este guia, você saberá:

* O que é o pipeline de ativos e o que ele faz.
* Como organizar corretamente os ativos da sua aplicação.
* Os benefícios do pipeline de ativos.
* Como adicionar um pré-processador ao pipeline.
* Como empacotar ativos com uma gem.

--------------------------------------------------------------------------------

O que é o Pipeline de Ativos?
---------------------------

O pipeline de ativos fornece uma estrutura para lidar com a entrega de ativos JavaScript e CSS. Isso é feito aproveitando tecnologias como HTTP/2 e técnicas como concatenação e minificação. Por fim, permite que sua aplicação seja automaticamente combinada com ativos de outras gems.

O pipeline de ativos é implementado pelas gems [importmap-rails](https://github.com/rails/importmap-rails), [sprockets](https://github.com/rails/sprockets) e [sprockets-rails](https://github.com/rails/sprockets-rails), e está habilitado por padrão. Você pode desabilitá-lo ao criar uma nova aplicação passando a opção `--skip-asset-pipeline`.

```bash
$ rails new appname --skip-asset-pipeline
```

NOTA: Este guia está focado no pipeline de ativos padrão, usando apenas `sprockets` para CSS e `importmap-rails` para processamento de JavaScript. A principal limitação dessas duas é que não há suporte para transpilação, portanto, você não pode usar coisas como `Babel`, `Typescript`, `Sass`, `React JSX format` ou `TailwindCSS`. Recomendamos que você leia a seção [Bibliotecas Alternativas](#alternative-libraries) se precisar de transpilação para seu JavaScript/CSS.

## Principais Recursos

O primeiro recurso do pipeline de ativos é inserir uma impressão digital SHA256 em cada nome de arquivo, para que o arquivo seja armazenado em cache pelo navegador da web e pelo CDN. Essa impressão digital é atualizada automaticamente quando você altera o conteúdo do arquivo, o que invalida o cache.

O segundo recurso do pipeline de ativos é usar [import maps](https://github.com/WICG/import-maps) ao servir arquivos JavaScript. Isso permite que você construa aplicativos modernos usando bibliotecas JavaScript feitas para módulos ES (ESM) sem a necessidade de transpilação e empacotamento. Por sua vez, **isso elimina a necessidade do Webpack, yarn, node ou qualquer outra parte da cadeia de ferramentas JavaScript**.

O terceiro recurso do pipeline de ativos é concatenar todos os arquivos CSS em um único arquivo `.css`, que é então minificado ou comprimido. Como você aprenderá mais adiante neste guia, você pode personalizar essa estratégia para agrupar os arquivos da maneira que desejar. Na produção, o Rails insere uma impressão digital SHA256 em cada nome de arquivo, para que o arquivo seja armazenado em cache pelo navegador da web. Você pode invalidar o cache alterando essa impressão digital, o que acontece automaticamente sempre que você altera o conteúdo do arquivo.

O quarto recurso do pipeline de ativos é permitir a codificação de ativos por meio de uma linguagem de nível superior para CSS.

### O que é Impressão Digital e por que devo me importar?

A impressão digital é uma técnica que torna o nome de um arquivo dependente do conteúdo do arquivo. Quando o conteúdo do arquivo muda, o nome do arquivo também é alterado. Para conteúdo estático ou alterado com pouca frequência, isso fornece uma maneira fácil de determinar se duas versões de um arquivo são idênticas, mesmo em servidores diferentes ou datas de implantação diferentes.

Quando um nome de arquivo é único e baseado em seu conteúdo, cabeçalhos HTTP podem ser definidos para incentivar caches em todos os lugares (sejam em CDNs, ISPs, equipamentos de rede ou navegadores da web) a manter sua própria cópia do conteúdo. Quando o conteúdo é atualizado, a impressão digital será alterada. Isso fará com que os clientes remotos solicitem uma nova cópia do conteúdo. Isso é geralmente conhecido como _cache busting_.

A técnica que o Sprockets usa para impressão digital é inserir um hash do conteúdo no nome, geralmente no final. Por exemplo, um arquivo CSS `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

Essa é a estratégia adotada pelo pipeline de ativos do Rails.

A impressão digital está habilitada por padrão nos ambientes de desenvolvimento e produção. Você pode habilitá-la ou desabilitá-la em sua configuração por meio da opção [`config.assets.digest`][].

### O que são Import Maps e por que devo me importar?

Os import maps permitem que você importe módulos JavaScript usando nomes lógicos que mapeiam para arquivos versionados/digestados - diretamente do navegador. Portanto, você pode construir aplicativos JavaScript modernos usando bibliotecas JavaScript feitas para módulos ES (ESM) sem a necessidade de transpilação ou empacotamento.

Com essa abordagem, você enviará muitos arquivos JavaScript pequenos em vez de um grande arquivo JavaScript. Graças ao HTTP/2, que não carrega mais uma penalidade de desempenho material durante o transporte inicial e, na verdade, oferece benefícios substanciais a longo prazo devido a melhores dinâmicas de cache.
Como usar Import Maps como um pipeline de ativos JavaScript
-----------------------------

Import Maps são o processador JavaScript padrão, a lógica de geração de import maps é tratada pela gem [`importmap-rails`](https://github.com/rails/importmap-rails).

AVISO: Import maps são usados apenas para arquivos JavaScript e não podem ser usados para entrega de CSS. Verifique a seção [Sprockets](#como-usar-sprockets) para aprender sobre CSS.

Você pode encontrar instruções detalhadas de uso na página inicial da Gem, mas é importante entender o básico do `importmap-rails`.

### Como funciona

Import maps são essencialmente uma substituição de string para o que é chamado de "bare module specifiers". Eles permitem que você padronize os nomes das importações de módulos JavaScript.

Por exemplo, esta definição de importação não funcionará sem um import map:

```javascript
import React from "react"
```

Você teria que defini-lo assim para fazê-lo funcionar:

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Aqui entra o import map, definimos o nome `react` para ser vinculado ao endereço `https://ga.jspm.io/npm:react@17.0.2/index.js`. Com essa informação, nosso navegador aceita a definição simplificada `import React from "react"`. Pense no import map como um alias para o endereço de origem da biblioteca.

### Uso

Com o `importmap-rails`, você cria o arquivo de configuração do importmap, vinculando o caminho da biblioteca a um nome:

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Todos os import maps configurados devem ser anexados ao elemento `<head>` de sua aplicação, adicionando `<%= javascript_importmap_tags %>`. O `javascript_importmap_tags` renderiza um conjunto de scripts no elemento `head`:

- JSON com todos os import maps configurados:

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims) atuando como polyfill garantindo suporte para `import maps` em navegadores mais antigos:

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- Ponto de entrada para carregar JavaScript de `app/javascript/application.js`:

```html
<script type="module">import "application"</script>
```

### Usando pacotes npm via JavaScript CDNs

Você pode usar o comando `./bin/importmap` que é adicionado como parte da instalação do `importmap-rails` para fixar, desafixar ou atualizar pacotes npm em seu import map. O binstub usa o [`JSPM.org`](https://jspm.org/).

Funciona assim:

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

Como você pode ver, os dois pacotes react e react-dom resolvem um total de quatro dependências, quando resolvidos via jspm padrão.

Agora você pode usar esses pacotes no seu ponto de entrada `application.js` como faria com qualquer outro módulo:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Você também pode designar uma versão específica para fixar:

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Ou até mesmo remover fixações:

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

Você pode controlar o ambiente do pacote para pacotes com compilações separadas "production" (o padrão) e "development":

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Você também pode escolher um provedor CDN alternativo suportado ao fixar, como [`unpkg`](https://unpkg.com/) ou [`jsdelivr`](https://www.jsdelivr.com/) (o [`jspm`](https://jspm.org/) é o padrão):

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

Lembre-se, porém, que se você trocar uma fixação de um provedor para outro, talvez seja necessário limpar as dependências adicionadas pelo primeiro provedor que não são usadas pelo segundo provedor.

Execute `./bin/importmap` para ver todas as opções.

Observe que este comando é apenas uma conveniência para resolver nomes lógicos de pacotes em URLs de CDN. Você também pode procurar os URLs de CDN você mesmo e fixá-los. Por exemplo, se você quiser usar o Skypack para o React, você pode simplesmente adicionar o seguinte em `config/importmap.rb`:

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### Pré-carregando módulos fixados

Para evitar o efeito cascata em que o navegador precisa carregar um arquivo após o outro antes de poder chegar à importação mais aninhada, o importmap-rails suporta links de [modulepreload](https://developers.google.com/web/updates/2017/12/modulepreload). Módulos fixados podem ser pré-carregados adicionando `preload: true` à fixação.

É uma boa ideia pré-carregar bibliotecas ou frameworks que são usados em toda a sua aplicação, pois isso dirá ao navegador para baixá-los mais cedo.

Exemplo:

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# incluirá o seguinte link antes da configuração do importmap:
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
NOTA: Consulte o repositório [`importmap-rails`](https://github.com/rails/importmap-rails) para obter a documentação mais atualizada.

Como usar o Sprockets
-----------------------------

A abordagem ingênua para expor os ativos da sua aplicação na web seria armazená-los em subdiretórios da pasta `public`, como `images` e `stylesheets`. Fazer isso manualmente seria difícil, pois a maioria das aplicações web modernas requer que os ativos sejam processados de maneira específica, por exemplo, compactação e adição de identificadores aos ativos.

O Sprockets foi projetado para pré-processar automaticamente seus ativos armazenados nos diretórios configurados e, após o processamento, expô-los na pasta `public/assets` com identificadores, compactação, geração de mapas de origem e outras funcionalidades configuráveis.

Os ativos ainda podem ser colocados na hierarquia `public`. Quaisquer ativos em `public` serão servidos como arquivos estáticos pela aplicação ou servidor web quando [`config.public_file_server.enabled`][] estiver definido como true. Você deve definir diretivas `manifest.js` para arquivos que precisam passar por algum pré-processamento antes de serem servidos.

Na produção, o Rails pré-compila esses arquivos para `public/assets` por padrão. As cópias pré-compiladas são então servidas como ativos estáticos pelo servidor web. Os arquivos em `app/assets` nunca são servidos diretamente em produção.


### Arquivos e Diretivas de Manifesto

Ao compilar ativos com o Sprockets, o Sprockets precisa decidir quais alvos de nível superior compilar, geralmente `application.css` e imagens. Os alvos de nível superior são definidos no arquivo `manifest.js` do Sprockets, por padrão, ele se parece com isso:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

Ele contém _diretivas_ - instruções que dizem ao Sprockets quais arquivos são necessários para construir um único arquivo CSS ou JavaScript.

Isso é destinado a incluir o conteúdo de todos os arquivos encontrados no diretório `./app/assets/images` ou em qualquer subdiretório, bem como qualquer arquivo reconhecido como JS diretamente em `./app/javascript` ou `./vendor/javascript`.

Ele carregará qualquer CSS do diretório `./app/assets/stylesheets` (sem incluir subdiretórios). Supondo que você tenha os arquivos `application.css` e `marketing.css` na pasta `./app/assets/stylesheets`, você poderá carregar essas folhas de estilo com `<%= stylesheet_link_tag "application" %>` ou `<%= stylesheet_link_tag "marketing" %>` em suas visualizações.

Você pode notar que nossos arquivos JavaScript não são carregados do diretório `assets` por padrão, isso ocorre porque `./app/javascript` é o ponto de entrada padrão para a gem `importmap-rails` e a pasta `vendor` é o local onde os pacotes JS baixados seriam armazenados.

No `manifest.js`, você também pode especificar a diretiva `link` para carregar um arquivo específico em vez de todo o diretório. A diretiva `link` requer a especificação da extensão de arquivo explícita.

O Sprockets carrega os arquivos especificados, os processa se necessário, os concatena em um único arquivo e, em seguida, os comprime (com base no valor de `config.assets.css_compressor` ou `config.assets.js_compressor`). A compressão reduz o tamanho do arquivo, permitindo que o navegador faça o download dos arquivos mais rapidamente.

### Ativos Específicos do Controlador

Quando você gera um scaffold ou um controlador, o Rails também gera um arquivo de Cascading Style Sheet para esse controlador. Além disso, ao gerar um scaffold, o Rails gera o arquivo `scaffolds.css`.

Por exemplo, se você gerar um `ProjectsController`, o Rails também adicionará um novo arquivo em `app/assets/stylesheets/projects.css`. Por padrão, esses arquivos estarão prontos para uso imediato pela sua aplicação usando a diretiva `link_directory` no arquivo `manifest.js`.

Você também pode optar por incluir arquivos de folhas de estilo específicos do controlador apenas em seus respectivos controladores usando o seguinte:

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

Ao fazer isso, certifique-se de não usar a diretiva `require_tree` no seu `application.css`, pois isso poderia resultar na inclusão dos ativos específicos do controlador mais de uma vez.

### Organização de Ativos

Os ativos do pipeline podem ser colocados dentro de uma aplicação em um dos três locais: `app/assets`, `lib/assets` ou `vendor/assets`.

* `app/assets` é para ativos de propriedade da aplicação, como imagens ou folhas de estilo personalizadas.

* `app/javascript` é para o seu código JavaScript

* `vendor/[assets|javascript]` é para ativos de propriedade de entidades externas, como frameworks CSS ou bibliotecas JavaScript. Tenha em mente que o código de terceiros com referências a outros arquivos também processados pelo Pipeline de ativos (imagens, folhas de estilo, etc.) precisará ser reescrito para usar ajudantes como `asset_path`.

Outros locais podem ser configurados no arquivo `manifest.js`, consulte os [Arquivos e Diretivas de Manifesto](#arquivos-e-diretivas-de-manifesto).

#### Caminhos de Pesquisa

Quando um arquivo é referenciado a partir de um manifesto ou um ajudante, o Sprockets procura em todos os locais especificados no `manifest.js` por ele. Você pode visualizar o caminho de pesquisa inspecionando [`Rails.application.config.assets.paths`](configuring.html#config-assets-paths) no console do Rails.
#### Usando arquivos de índice como proxies para pastas

O Sprockets usa arquivos chamados `index` (com as extensões relevantes) para um propósito especial.

Por exemplo, se você tem uma biblioteca CSS com muitos módulos, que está armazenada em `lib/assets/stylesheets/library_name`, o arquivo `lib/assets/stylesheets/library_name/index.css` serve como o manifesto para todos os arquivos desta biblioteca. Este arquivo pode incluir uma lista de todos os arquivos necessários em ordem, ou uma simples diretiva `require_tree`.

É também um pouco semelhante à forma como um arquivo em `public/library_name/index.html` pode ser acessado por uma solicitação para `/library_name`. Isso significa que você não pode usar diretamente um arquivo de índice.

A biblioteca como um todo pode ser acessada nos arquivos `.css` da seguinte forma:

```css
/* ...
*= require library_name
*/
```

Isso simplifica a manutenção e mantém as coisas limpas, permitindo que o código relacionado seja agrupado antes da inclusão em outros lugares.

### Codificando links para ativos

O Sprockets não adiciona nenhum novo método para acessar seus ativos - você ainda usa o familiar `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Se estiver usando a gem [`turbo-rails`](https://github.com/hotwired/turbo-rails), que está incluída por padrão no Rails, então inclua a opção `data-turbo-track`, que faz com que o Turbo verifique se um ativo foi atualizado e, se sim, o carrega na página:

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

Em visualizações regulares, você pode acessar imagens no diretório `app/assets/images` assim:

```erb
<%= image_tag "rails.png" %>
```

Desde que o pipeline esteja habilitado em sua aplicação (e não desabilitado no contexto do ambiente atual), este arquivo é servido pelo Sprockets. Se um arquivo existir em `public/assets/rails.png`, ele será servido pelo servidor web.

Alternativamente, uma solicitação para um arquivo com um hash SHA256, como `public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`, é tratada da mesma forma. Como esses hashes são gerados é abordado na seção [Em Produção](#em-produção) mais adiante neste guia.

As imagens também podem ser organizadas em subdiretórios, se necessário, e então podem ser acessadas especificando o nome do diretório na tag:

```erb
<%= image_tag "icons/rails.png" %>
```

AVISO: Se você estiver pré-compilando seus ativos (veja [Em Produção](#em-produção) abaixo), vincular a um ativo que não existe causará uma exceção na página chamadora. Isso inclui vincular a uma string em branco. Portanto, tenha cuidado ao usar `image_tag` e os outros helpers com dados fornecidos pelo usuário.

#### CSS e ERB

O pipeline de ativos avalia automaticamente o ERB. Isso significa que se você adicionar uma extensão `erb` a um ativo CSS (por exemplo, `application.css.erb`), então helpers como `asset_path` estão disponíveis em suas regras CSS:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

Isso escreve o caminho para o ativo específico que está sendo referenciado. Neste exemplo, faria sentido ter uma imagem em um dos caminhos de carregamento de ativos, como `app/assets/images/image.png`, que seria referenciada aqui. Se esta imagem já estiver disponível em `public/assets` como um arquivo com fingerprint, então esse caminho é referenciado.

Se você quiser usar um [data URI](https://en.wikipedia.org/wiki/Data_URI_scheme) - um método de incorporar os dados da imagem diretamente no arquivo CSS - você pode usar o helper `asset_data_uri`.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

Isso insere um data URI formatado corretamente no código CSS.

Observe que a tag de fechamento não pode ser do estilo `-%>`.

### Gerar um erro quando um ativo não é encontrado

Se você estiver usando sprockets-rails >= 3.2.0, você pode configurar o que acontece quando uma busca por um ativo é feita e nada é encontrado. Se você desativar o "fallback de ativo", então um erro será gerado quando um ativo não puder ser encontrado.

```ruby
config.assets.unknown_asset_fallback = false
```

Se o "fallback de ativo" estiver habilitado, então quando um ativo não puder ser encontrado, o caminho será exibido e nenhum erro será gerado. O comportamento de fallback de ativo está desabilitado por padrão.

### Desativando os hashes

Você pode desativar os hashes atualizando `config/environments/development.rb` para incluir:

```ruby
config.assets.digest = false
```

Quando esta opção está ativada, os hashes serão gerados para URLs de ativos.

### Ativando os Source Maps

Você pode ativar os Source Maps atualizando `config/environments/development.rb` para incluir:

```ruby
config.assets.debug = true
```

Quando o modo de depuração está ativado, o Sprockets irá gerar um Source Map para cada ativo. Isso permite que você depure cada arquivo individualmente nas ferramentas de desenvolvedor do seu navegador.

Os ativos são compilados e armazenados em cache na primeira solicitação após o servidor ser iniciado. O Sprockets define um cabeçalho HTTP `must-revalidate` Cache-Control para reduzir a sobrecarga de solicitações nas solicitações subsequentes - nessas solicitações, o navegador recebe uma resposta 304 (Não Modificado).
Se algum dos arquivos no manifesto mudar entre as solicitações, o servidor responde com um novo arquivo compilado.

Em Produção
-----------

No ambiente de produção, o Sprockets usa o esquema de impressão digital descrito acima. Por padrão, o Rails assume que os ativos foram pré-compilados e serão servidos como ativos estáticos pelo seu servidor web.

Durante a fase de pré-compilação, um SHA256 é gerado a partir do conteúdo dos arquivos compilados e inserido nos nomes dos arquivos conforme são gravados no disco. Esses nomes com impressão digital são usados pelos helpers do Rails no lugar do nome do manifesto.

Por exemplo, isso:

```erb
<%= stylesheet_link_tag "application" %>
```

gera algo como isso:

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

O comportamento de impressão digital é controlado pela opção de inicialização [`config.assets.digest`][] (que tem como padrão `true`).

NOTA: Em circunstâncias normais, a opção padrão `config.assets.digest` não deve ser alterada. Se não houver impressões digitais nos nomes dos arquivos e os cabeçalhos de longo prazo estiverem definidos, os clientes remotos nunca saberão quando buscar novamente os arquivos quando seu conteúdo mudar.


### Pré-compilando Ativos

O Rails vem com um comando para compilar os manifestos de ativos e outros arquivos no pipeline.

Os ativos compilados são gravados no local especificado em [`config.assets.prefix`][]. Por padrão, isso é o diretório `/assets`.

Você pode chamar esse comando no servidor durante a implantação para criar versões compiladas dos seus ativos diretamente no servidor. Consulte a próxima seção para obter informações sobre a compilação local.

O comando é:

```bash
$ RAILS_ENV=production rails assets:precompile
```

Isso vincula a pasta especificada em `config.assets.prefix` a `shared/assets`. Se você já usa essa pasta compartilhada, precisará escrever seu próprio comando de implantação.

É importante que esta pasta seja compartilhada entre as implantações para que as páginas em cache remotas que fazem referência aos ativos compilados antigos ainda funcionem durante a vida útil da página em cache.

NOTA. Sempre especifique um nome de arquivo compilado esperado que termine com `.js` ou `.css`.

O comando também gera um arquivo `.sprockets-manifest-randomhex.json` (onde `randomhex` é uma sequência hexadecimal aleatória de 16 bytes) que contém uma lista com todos os seus ativos e suas respectivas impressões digitais. Isso é usado pelos métodos auxiliares do Rails para evitar devolver as solicitações de mapeamento para o Sprockets. Um arquivo de manifesto típico se parece com isso:

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

Em sua aplicação, haverá mais arquivos e ativos listados no manifesto, `<fingerprint>` e `<random-string>` também serão gerados.

O local padrão para o manifesto é a raiz do local especificado em `config.assets.prefix` ('/assets' por padrão).

NOTA: Se houver arquivos pré-compilados ausentes na produção, você receberá uma exceção `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` indicando o nome do(s) arquivo(s) ausente(s).


#### Cabeçalho Expires de Longo Prazo

Os ativos pré-compilados existem no sistema de arquivos e são servidos diretamente pelo seu servidor web. Por padrão, eles não têm cabeçalhos de longo prazo, então, para obter o benefício da impressão digital, você precisará atualizar a configuração do seu servidor para adicionar esses cabeçalhos.

Para o Apache:

```apache
# As diretivas Expires* requerem que o módulo Apache
# `mod_expires` esteja habilitado.
<Location /assets/>
  # O uso de ETag é desencorajado quando Last-Modified está presente
  Header unset ETag
  FileETag None
  # A RFC diz que só deve ser armazenado em cache por 1 ano
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

Para o NGINX:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### Pré-compilação Local

Às vezes, você pode não querer ou não ser capaz de compilar ativos no servidor de produção. Por exemplo, você pode ter acesso limitado de gravação ao sistema de arquivos de produção ou pode planejar implantar com frequência sem fazer alterações nos seus ativos.

Nesses casos, você pode pré-compilar ativos _localmente_ - ou seja, adicionar um conjunto finalizado de ativos compilados e prontos para produção ao seu repositório de código-fonte antes de fazer o push para produção. Dessa forma, eles não precisam ser pré-compilados separadamente no servidor de produção a cada implantação.

Como mencionado acima, você pode executar essa etapa usando

```bash
$ RAILS_ENV=production rails assets:precompile
```

Observe as seguintes ressalvas:

* Se os ativos pré-compilados estiverem disponíveis, eles serão servidos - mesmo que não correspondam mais aos ativos originais (não compilados), _mesmo no servidor de desenvolvimento_.

    Para garantir que o servidor de desenvolvimento sempre compile os ativos sob demanda (e, portanto, sempre reflita o estado mais recente do código), o ambiente de desenvolvimento _deve ser configurado para manter os ativos pré-compilados em um local diferente do que o ambiente de produção faz_. Caso contrário, quaisquer ativos pré-compilados para uso em produção substituirão as solicitações para eles no desenvolvimento (ou seja, as alterações subsequentes que você fizer nos ativos não serão refletidas no navegador).
Você pode fazer isso adicionando a seguinte linha ao arquivo `config/environments/development.rb`:

```ruby
config.assets.prefix = "/dev-assets"
```

* A tarefa de pré-compilação de ativos em sua ferramenta de implantação (por exemplo, Capistrano) deve ser desativada.
* Quaisquer compressores ou minificadores necessários devem estar disponíveis em seu sistema de desenvolvimento.

Você também pode definir `ENV["SECRET_KEY_BASE_DUMMY"]` para acionar o uso de uma `secret_key_base` gerada aleatoriamente que é armazenada em um arquivo temporário. Isso é útil ao pré-compilar ativos para produção como parte de uma etapa de construção que não precisa de acesso às chaves de produção.

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### Compilação ao Vivo

Em algumas circunstâncias, você pode desejar usar a compilação ao vivo. Nesse modo, todas as solicitações de ativos no pipeline são tratadas diretamente pelo Sprockets.

Para ativar essa opção, defina:

```ruby
config.assets.compile = true
```

Na primeira solicitação, os ativos são compilados e armazenados em cache conforme descrito em [Armazenamento de Cache de Ativos](#assets-cache-store), e os nomes do manifesto usados nos helpers são alterados para incluir o hash SHA256.

O Sprockets também define o cabeçalho HTTP `Cache-Control` como `max-age=31536000`. Isso sinaliza todos os caches entre o servidor e o navegador do cliente que esse conteúdo (o arquivo servido) pode ser armazenado em cache por 1 ano. O efeito disso é reduzir o número de solicitações para esse ativo a partir do seu servidor; o ativo tem uma boa chance de estar no cache do navegador local ou em algum cache intermediário.

Esse modo usa mais memória, tem um desempenho pior que o padrão e não é recomendado.

### CDNs

CDN significa [Content Delivery Network](https://en.wikipedia.org/wiki/Content_delivery_network), eles são projetados principalmente para armazenar em cache ativos em todo o mundo, para que, quando um navegador solicitar o ativo, uma cópia em cache esteja geograficamente próxima a esse navegador. Se você estiver servindo ativos diretamente do seu servidor Rails em produção, a melhor prática é usar um CDN na frente de sua aplicação.

Um padrão comum para usar um CDN é definir sua aplicação de produção como o servidor "origem". Isso significa que, quando um navegador solicita um ativo do CDN e há uma falta de cache, ele buscará o arquivo do seu servidor na hora e, em seguida, fará o cache. Por exemplo, se você estiver executando uma aplicação Rails em `example.com` e tiver um CDN configurado em `mycdnsubdomain.fictional-cdn.com`, quando uma solicitação for feita para `mycdnsubdomain.fictional-cdn.com/assets/smile.png`, o CDN consultará seu servidor uma vez em `example.com/assets/smile.png` e fará o cache da solicitação. A próxima solicitação ao CDN que chegar à mesma URL atingirá a cópia em cache. Quando o CDN pode servir um ativo diretamente, a solicitação nunca toca no seu servidor Rails. Como os ativos de um CDN estão geograficamente mais próximos ao navegador, a solicitação é mais rápida e, como seu servidor não precisa gastar tempo servindo ativos, ele pode se concentrar em servir o código da aplicação o mais rápido possível.

#### Configurando um CDN para Servir Ativos Estáticos

Para configurar seu CDN, você precisa ter sua aplicação em execução em produção na internet em uma URL publicamente disponível, por exemplo, `example.com`. Em seguida, você precisará se inscrever em um serviço de CDN de um provedor de hospedagem em nuvem. Ao fazer isso, você precisa configurar a "origem" do CDN para apontar de volta para seu site `example.com`. Verifique a documentação do seu provedor para obter informações sobre a configuração do servidor de origem.

O CDN que você provisionou deve fornecer um subdomínio personalizado para sua aplicação, como `mycdnsubdomain.fictional-cdn.com` (observe que fictional-cdn.com não é um provedor de CDN válido no momento em que este texto foi escrito). Agora que você configurou seu servidor CDN, precisa informar aos navegadores para usar seu CDN para buscar ativos em vez de seu servidor Rails diretamente. Você pode fazer isso configurando o Rails para definir seu CDN como o host de ativos em vez de usar um caminho relativo. Para definir seu host de ativos no Rails, você precisa definir [`config.asset_host`][] em `config/environments/production.rb`:

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

OBSERVAÇÃO: Você só precisa fornecer o "host", ou seja, o subdomínio e o domínio raiz, não é necessário especificar um protocolo ou "esquema" como `http://` ou `https://`. Quando uma página da web é solicitada, o protocolo no link para seu ativo que é gerado corresponderá à forma como a página da web é acessada por padrão.

Você também pode definir esse valor por meio de uma [variável de ambiente](https://en.wikipedia.org/wiki/Environment_variable) para facilitar a execução de uma cópia de teste do seu site:
```ruby
config.asset_host = ENV['CDN_HOST']
```

NOTA: Você precisará definir `CDN_HOST` em seu servidor para `mycdnsubdomain.fictional-cdn.com` para que isso funcione.

Depois de configurar seu servidor e seu CDN, os caminhos dos ativos dos helpers, como:

```erb
<%= asset_path('smile.png') %>
```

Serão renderizados como URLs completos do CDN, como `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`
(digest omitido para legibilidade).

Se o CDN tiver uma cópia de `smile.png`, ele a servirá para o navegador e seu
servidor nem mesmo saberá que foi solicitado. Se o CDN não tiver uma cópia, ele
tentará encontrá-la na "origem" `example.com/assets/smile.png` e, em seguida, armazená-la
para uso futuro.

Se você quiser servir apenas alguns ativos do seu CDN, você pode usar a opção `:host`
personalizada em seu helper de ativos, que sobrescreve o valor definido em
[`config.action_controller.asset_host`][].

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```


#### Personalizar o Comportamento de Cache do CDN

Um CDN funciona armazenando em cache o conteúdo. Se o CDN tiver conteúdo obsoleto ou ruim, ele estará
prejudicando em vez de ajudar sua aplicação. O objetivo desta seção é
descrever o comportamento geral de cache da maioria dos CDNs. Seu provedor específico pode
se comportar um pouco diferente.

##### Armazenamento em Cache de Solicitação do CDN

Embora um CDN seja descrito como sendo bom para armazenar em cache ativos, ele realmente armazena em cache a
solicitação inteira. Isso inclui o corpo do ativo, bem como quaisquer cabeçalhos. O
mais importante é o `Cache-Control`, que informa ao CDN (e aos navegadores da web)
como armazenar em cache o conteúdo. Isso significa que se alguém solicitar um ativo que não
existe, como `/assets/i-dont-exist.png`, e sua aplicação Rails retornar um erro 404,
então seu CDN provavelmente armazenará em cache a página de erro 404 se um cabeçalho `Cache-Control` válido
estiver presente.

##### Depuração de Cabeçalhos do CDN

Uma maneira de verificar se os cabeçalhos estão sendo armazenados em cache corretamente no seu CDN é usando o [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com). Você
pode solicitar os cabeçalhos tanto do seu servidor quanto do seu CDN para verificar se eles são
os mesmos:

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

Em comparação com a cópia do CDN:

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

Verifique a documentação do seu CDN para obter informações adicionais que eles possam fornecer,
como `X-Cache` ou quaisquer cabeçalhos adicionais que eles possam adicionar.

##### CDNs e o Cabeçalho Cache-Control

O cabeçalho [`Cache-Control`][] descreve como uma solicitação pode ser armazenada em cache. Quando nenhum CDN é usado, um
navegador usa essas informações para armazenar em cache o conteúdo. Isso é muito útil para
ativos que não são modificados, para que um navegador não precise baixar novamente o CSS ou JavaScript de um site em cada solicitação. Geralmente, queremos que nosso servidor Rails
informe ao nosso CDN (e navegador) que o ativo é "público". Isso significa que qualquer cache
pode armazenar a solicitação. Também é comum definir `max-age`, que é por quanto tempo
o cache armazenará o objeto antes de invalidar o cache. O valor `max-age` é definido em segundos, com um valor máximo possível de `31536000`, que é um
ano. Você pode fazer isso em sua aplicação Rails definindo

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

Agora, quando sua aplicação servir um ativo em produção, o CDN armazenará o
ativo por até um ano. Como a maioria dos CDNs também armazena em cache os cabeçalhos da solicitação, esse `Cache-Control` será transmitido a todos os navegadores futuros que procurarem esse ativo.
O navegador então sabe que pode armazenar esse ativo por um longo período de tempo antes de
precisar solicitá-lo novamente.


##### CDNs e Invalidez de Cache Baseada em URL

A maioria dos CDNs armazenará em cache o conteúdo de um ativo com base na URL completa. Isso significa
que uma solicitação para

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

Será um cache completamente diferente de

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

Se você deseja definir um `max-age` futuro distante em seu `Cache-Control` (e você deseja),
certifique-se de que, ao alterar seus ativos, seu cache seja invalidado. Por
exemplo, ao alterar o rosto sorridente em uma imagem de amarelo para azul, você deseja
que todos os visitantes do seu site obtenham o novo rosto azul. Ao usar um CDN com o
pipeline de ativos do Rails, `config.assets.digest` é definido como true por padrão, para que
cada ativo tenha um nome de arquivo diferente quando for alterado. Dessa forma, você
nunca precisa invalidar manualmente nenhum item em seu cache. Ao usar um
nome de ativo exclusivo diferente, seus usuários obtêm o ativo mais recente.
```
Personalizando o Pipeline
------------------------

### Compressão de CSS

Uma das opções para compressão de CSS é o YUI. O [YUI CSS
compressor](https://yui.github.io/yuicompressor/css.html) fornece
minificação.

A seguinte linha habilita a compressão do YUI e requer a gem `yui-compressor`.

```ruby
config.assets.css_compressor = :yui
```

### Compressão de JavaScript

As opções possíveis para compressão de JavaScript são `:terser`, `:closure` e
`:yui`. Essas opções requerem o uso das gems `terser`, `closure-compiler` ou
`yui-compressor`, respectivamente.

Vamos tomar como exemplo a gem `terser`.
Essa gem envolve o [Terser](https://github.com/terser/terser) (escrito para
Node.js) em Ruby. Ela comprime seu código removendo espaços em branco e comentários,
encurtando nomes de variáveis locais e realizando outras micro-otimizações, como
transformar declarações `if` e `else` em operadores ternários sempre que possível.

A seguinte linha invoca o `terser` para compressão de JavaScript.

```ruby
config.assets.js_compressor = :terser
```

NOTA: Você precisará de um runtime suportado pelo [ExecJS](https://github.com/rails/execjs#readme)
para usar o `terser`. Se você estiver usando macOS ou
Windows, você já tem um runtime JavaScript instalado em seu sistema operacional.

NOTA: A compressão de JavaScript também funcionará para seus arquivos JavaScript quando você estiver carregando seus assets através das gems `importmap-rails` ou `jsbundling-rails`.

### Compactando seus assets

Por padrão, uma versão compactada dos assets compilados será gerada, juntamente com
a versão não compactada dos assets. Os assets compactados ajudam a reduzir a transmissão
de dados pela rede. Você pode configurar isso definindo a flag `gzip`.

```ruby
config.assets.gzip = false # desabilita a geração de assets compactados
```

Consulte a documentação do seu servidor web para obter instruções sobre como servir assets compactados.

### Usando seu próprio compressor

As configurações do compressor para CSS e JavaScript também aceitam qualquer objeto.
Esse objeto deve ter um método `compress` que recebe uma string como único
argumento e deve retornar uma string.

```ruby
class Transformer
  def compress(string)
    faça_algo_retornando_uma_string(string)
  end
end
```

Para habilitar isso, passe um novo objeto para a opção de configuração em `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```

### Alterando o caminho dos _assets_

O caminho público padrão usado pelo Sprockets é `/assets`.

Isso pode ser alterado para outra coisa:

```ruby
config.assets.prefix = "/algum_outro_caminho"
```

Essa é uma opção útil se você estiver atualizando um projeto mais antigo que não usava o
asset pipeline e já usa esse caminho, ou se você deseja usar esse caminho para
um novo recurso.

### Cabeçalhos X-Sendfile

O cabeçalho X-Sendfile é uma diretiva para o servidor web ignorar a resposta
da aplicação e, em vez disso, servir um arquivo específico do disco. Essa opção
está desativada por padrão, mas pode ser ativada se o seu servidor suportar. Quando ativada,
a responsabilidade por servir o arquivo é transferida para o servidor web, o que é
mais rápido. Veja [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)
para saber como usar esse recurso.

O Apache e o NGINX suportam essa opção, que pode ser ativada em
`config/environments/production.rb`:

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # para o Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # para o NGINX
```

ATENÇÃO: Se você estiver atualizando uma aplicação existente e pretende usar essa
opção, tome cuidado para colar essa opção de configuração apenas em `production.rb`
e em qualquer outro ambiente que você defina com comportamento de produção (não em
`application.rb`).

DICA: Para mais detalhes, consulte a documentação do seu servidor web de produção:

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

Armazenamento em Cache dos Assets
------------------

Por padrão, o Sprockets armazena em cache os assets em `tmp/cache/assets` nos ambientes
de desenvolvimento e produção. Isso pode ser alterado da seguinte forma:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

Para desabilitar o armazenamento em cache dos assets:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Adicionando Assets aos seus Gems
--------------------------

Os assets também podem vir de fontes externas na forma de gems.

Um bom exemplo disso é a gem `jquery-rails`.
Essa gem contém uma classe de engine que herda de `Rails::Engine`.
Ao fazer isso, o Rails é informado de que o diretório dessa
gem pode conter assets e os diretórios `app/assets`, `lib/assets` e
`vendor/assets` dessa engine são adicionados ao caminho de busca do
Sprockets.

Tornando sua Biblioteca ou Gem um Pré-processador
------------------------------------------

O Sprockets usa Processors, Transformers, Compressors e Exporters para estender
a funcionalidade do Sprockets. Dê uma olhada em
[Estendendo o Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)
para saber mais. Aqui registramos um pré-processador para adicionar um comentário ao final
dos arquivos de texto/css (`.css`).

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Olá da minha extensão do sprockets */" }
  end
end
```

Agora que você tem um módulo que modifica os dados de entrada, é hora de registrá-lo
como um pré-processador para o seu tipo MIME.
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```

Bibliotecas Alternativas
------------------------------------------

Ao longo dos anos, houve várias abordagens padrão para lidar com os ativos. A web evoluiu e começamos a ver cada vez mais aplicações com muito Javascript. Na Doutrina Rails, acreditamos que [O Menu é Omakase](https://rubyonrails.org/doctrine#omakase), então nos concentramos na configuração padrão: **Sprockets com Import Maps**.

Estamos cientes de que não existem soluções únicas para todos os frameworks/extensões de JavaScript e CSS disponíveis. Existem outras bibliotecas de empacotamento no ecossistema Rails que devem capacitar você nos casos em que a configuração padrão não é suficiente.

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails) é uma alternativa dependente do Node.js para a forma de empacotar JavaScript com [esbuild](https://esbuild.github.io/), [rollup.js](https://rollupjs.org/) ou [Webpack](https://webpack.js.org/).

A gema fornece o processo `yarn build --watch` para gerar automaticamente a saída no desenvolvimento. Para produção, ele automaticamente conecta a tarefa `javascript:build` à tarefa `assets:precompile` para garantir que todas as dependências do seu pacote tenham sido instaladas e que o JavaScript tenha sido construído para todos os pontos de entrada.

**Quando usar em vez de `importmap-rails`?** Se o seu código JavaScript depende de transpilação, ou seja, se você está usando [Babel](https://babeljs.io/), [TypeScript](https://www.typescriptlang.org/) ou o formato `JSX` do React, então `jsbundling-rails` é o caminho correto a seguir.

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html) era o pré-processador e empacotador JavaScript padrão para o Rails 5 e 6. Agora ele foi aposentado. Existe um sucessor chamado [`shakapacker`](https://github.com/shakacode/shakapacker), mas ele não é mantido pela equipe ou projeto Rails.

Ao contrário de outras bibliotecas desta lista, o `webpacker`/`shakapacker` é completamente independente do Sprockets e pode processar tanto arquivos JavaScript quanto CSS. Leia o [guia do Webpacker](https://guides.rubyonrails.org/webpacker.html) para saber mais.

NOTA: Leia o documento [Comparação com o Webpacker](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md) para entender as diferenças entre `jsbundling-rails` e `webpacker`/`shakapacker`.

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails) permite empacotar e processar seu CSS usando [Tailwind CSS](https://tailwindcss.com/), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org/) ou [Dart Sass](https://sass-lang.com/), e então entrega o CSS através do pipeline de ativos.

Ele funciona de maneira semelhante ao `jsbundling-rails`, adicionando a dependência do Node.js à sua aplicação com o processo `yarn build:css --watch` para regenerar suas folhas de estilo no desenvolvimento e conecta à tarefa `assets:precompile` na produção.

**Qual é a diferença em relação ao Sprockets?** O Sprockets por si só não é capaz de transpilar o Sass para CSS, é necessário o Node.js para gerar os arquivos `.css` a partir dos arquivos `.sass`. Uma vez que os arquivos `.css` são gerados, o `Sprockets` é capaz de entregá-los aos seus clientes.

NOTA: O `cssbundling-rails` depende do Node para processar o CSS. As gemas `dartsass-rails` e `tailwindcss-rails` usam versões independentes do Tailwind CSS e do Dart Sass, o que significa que não há dependência do Node. Se você estiver usando o `importmap-rails` para lidar com seus JavaScripts e o `dartsass-rails` ou `tailwindcss-rails` para o CSS, você pode evitar completamente a dependência do Node, resultando em uma solução menos complexa.

### dartsass-rails

Se você deseja usar [`Sass`](https://sass-lang.com/) em sua aplicação, o [`dartsass-rails`](https://github.com/rails/dartsass-rails) é uma substituição para a gema legada `sassc-rails`. O `dartsass-rails` usa a implementação `Dart Sass` em favor do [`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated) usado pelo `sassc-rails`, que foi descontinuado em 2020.

Ao contrário do `sassc-rails`, a nova gema não está diretamente integrada ao `Sprockets`. Consulte a página inicial da gema para obter instruções de instalação/migração.

AVISO: A popular gema `sassc-rails` não é mantida desde 2019.

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails) é uma gema de envoltório para a versão executável independente do framework Tailwind CSS v3. Usado para novas aplicações quando `--css tailwind` é fornecido ao comando `rails new`. Fornece um processo `watch` para gerar automaticamente a saída do Tailwind no desenvolvimento. Na produção, ele se conecta à tarefa `assets:precompile`.
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
