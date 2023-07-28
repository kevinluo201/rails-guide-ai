**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736
Webpacker
=========

Este guia mostrará como instalar e usar o Webpacker para empacotar JavaScript, CSS e outros ativos para o lado do cliente da sua aplicação Rails, mas observe que [o Webpacker foi descontinuado](https://github.com/rails/webpacker#webpacker-has-been-retired-).

Após ler este guia, você saberá:

* O que o Webpacker faz e por que é diferente do Sprockets.
* Como instalar o Webpacker e integrá-lo ao seu framework de escolha.
* Como usar o Webpacker para ativos JavaScript.
* Como usar o Webpacker para ativos CSS.
* Como usar o Webpacker para ativos estáticos.
* Como implantar um site que usa o Webpacker.
* Como usar o Webpacker em contextos alternativos do Rails, como engines ou containers Docker.

--------------------------------------------------------------

O que é o Webpacker?
------------------

O Webpacker é um wrapper do Rails em torno do sistema de compilação [webpack](https://webpack.js.org) que fornece uma configuração webpack padrão e valores padrão razoáveis.

### O que é o Webpack?

O objetivo do webpack, ou qualquer sistema de compilação de front-end, é permitir que você escreva seu código de front-end de uma maneira conveniente para os desenvolvedores e, em seguida, empacote esse código de uma maneira conveniente para os navegadores. Com o webpack, você pode gerenciar JavaScript, CSS e ativos estáticos como imagens ou fontes. O webpack permitirá que você escreva seu código, referencie outro código em sua aplicação, transforme seu código e combine seu código em pacotes facilmente baixáveis.

Consulte a [documentação do webpack](https://webpack.js.org) para obter informações.

### Como o Webpacker é diferente do Sprockets?

O Rails também vem com o Sprockets, uma ferramenta de empacotamento de ativos cujas funcionalidades se sobrepõem ao Webpacker. Ambas as ferramentas irão compilar seu JavaScript em arquivos compatíveis com o navegador e também irão minificá-los e adicionar um fingerprint na produção. Em um ambiente de desenvolvimento, o Sprockets e o Webpacker permitem que você altere os arquivos incrementalmente.

O Sprockets, que foi projetado para ser usado com o Rails, é um pouco mais simples de integrar. Em particular, o código pode ser adicionado ao Sprockets por meio de uma gem Ruby. No entanto, o webpack é melhor na integração com ferramentas JavaScript mais atuais e pacotes NPM e permite uma gama mais ampla de integração. Novos aplicativos Rails são configurados para usar o webpack para JavaScript e o Sprockets para CSS, embora seja possível usar o webpack para CSS.

Você deve escolher o Webpacker em vez do Sprockets em um novo projeto se quiser usar pacotes NPM e/ou ter acesso às funcionalidades e ferramentas JavaScript mais atuais. Você deve escolher o Sprockets em vez do Webpacker para aplicativos legados em que a migração pode ser custosa, se quiser integrar usando Gems ou se tiver uma quantidade muito pequena de código para empacotar.

Se você está familiarizado com o Sprockets, o guia a seguir pode lhe dar uma ideia de como traduzir. Observe que cada ferramenta tem uma estrutura ligeiramente diferente, e os conceitos não se mapeiam diretamente um para o outro.

|Tarefa             | Sprockets            | Webpacker         |
|-------------------|----------------------|-------------------|
|Anexar JavaScript |javascript_include_tag|javascript_pack_tag|
|Anexar CSS        |stylesheet_link_tag   |stylesheet_pack_tag|
|Link para uma imagem  |image_url             |image_pack_tag     |
|Link para um ativo  |asset_url             |asset_pack_tag     |
|Requerer um script  |//= require           |import or require  |

Instalando o Webpacker
--------------------

Para usar o Webpacker, você deve instalar o gerenciador de pacotes Yarn, versão 1.x ou superior, e também deve ter o Node.js instalado, versão 10.13.0 ou superior.

NOTA: O Webpacker depende do NPM e do Yarn. O NPM, registro do gerenciador de pacotes do Node, é o repositório principal para publicação e download de projetos JavaScript de código aberto, tanto para o Node.js quanto para navegadores. É análogo ao rubygems.org para gems Ruby. O Yarn é uma utilidade de linha de comando que permite a instalação e gerenciamento de dependências JavaScript, assim como o Bundler faz para Ruby.

Para incluir o Webpacker em um novo projeto, adicione `--webpack` ao comando `rails new`. Para adicionar o Webpacker a um projeto existente, adicione a gem `webpacker` ao `Gemfile` do projeto, execute `bundle install` e, em seguida, execute `bin/rails webpacker:install`.

A instalação do Webpacker cria os seguintes arquivos locais:

|Arquivo                    |Localização                |Explicação                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|Pasta JavaScript       | `app/javascript`       |Um local para o seu código de front-end                                                                   |
|Configuração do Webpacker | `config/webpacker.yml` |Configura o gem Webpacker                                                                         |
|Configuração do Babel     | `babel.config.js`      |Configuração para o compilador JavaScript [Babel](https://babeljs.io)                               |
|Configuração do PostCSS   | `postcss.config.js`    |Configuração para o pós-processador CSS [PostCSS](https://postcss.org)                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) gerencia a configuração dos navegadores alvo   |


A instalação também chama o gerenciador de pacotes `yarn`, cria um arquivo `package.json` com um conjunto básico de pacotes listados e usa o Yarn para instalar essas dependências.

Uso
-----

### Usando o Webpacker para JavaScript

Com o Webpacker instalado, qualquer arquivo JavaScript no diretório `app/javascript/packs` será compilado para seu próprio arquivo de pacote por padrão.
Então, se você tiver um arquivo chamado `app/javascript/packs/application.js`, o Webpacker criará um pacote chamado `application` e você pode adicioná-lo à sua aplicação Rails com o código `<%= javascript_pack_tag "application" %>`. Com isso, no desenvolvimento, o Rails recompilará o arquivo `application.js` toda vez que ele for alterado e você carregar uma página que usa esse pacote. Normalmente, o arquivo no diretório `packs` será um manifesto que carrega principalmente outros arquivos, mas também pode ter código JavaScript arbitrário.

O pacote padrão criado para você pelo Webpacker será vinculado aos pacotes JavaScript padrão do Rails se eles tiverem sido incluídos no projeto:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

Você precisará incluir um pacote que requer esses pacotes para usá-los em sua aplicação Rails.

É importante observar que apenas os arquivos de entrada do webpack devem ser colocados no diretório `app/javascript/packs`; o Webpack criará um gráfico de dependências separado para cada ponto de entrada, portanto, um grande número de pacotes aumentará a sobrecarga de compilação. O restante do código-fonte de seus ativos deve estar fora deste diretório, embora o Webpacker não imponha restrições ou faça sugestões sobre como estruturar seu código-fonte. Aqui está um exemplo:

```sh
app/javascript:
  ├── packs:
  │   # apenas arquivos de entrada do webpack aqui
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Normalmente, o próprio arquivo de pacote é principalmente um manifesto que usa `import` ou `require` para carregar os arquivos necessários e também pode fazer alguma inicialização.

Se você quiser alterar esses diretórios, poderá ajustar o `source_path` (padrão `app/javascript`) e o `source_entry_path` (padrão `packs`) no arquivo `config/webpacker.yml`.

Nos arquivos de origem, as declarações `import` são resolvidas em relação ao arquivo que está importando, portanto, `import Bar from "./foo"` encontra um arquivo `foo.js` no mesmo diretório do arquivo atual, enquanto `import Bar from "../src/foo"` encontra um arquivo em um diretório irmão chamado `src`.

### Usando o Webpacker para CSS

Por padrão, o Webpacker suporta CSS e SCSS usando o processador PostCSS.

Para incluir código CSS em seus pacotes, primeiro inclua seus arquivos CSS em seu arquivo de pacote de nível superior como se fosse um arquivo JavaScript. Portanto, se seu manifesto de nível superior CSS estiver em `app/javascript/styles/styles.scss`, você pode importá-lo com `import styles/styles`. Isso diz ao webpack para incluir seu arquivo CSS no download. Para realmente carregá-lo na página, inclua `<%= stylesheet_pack_tag "application" %>` na visualização, onde o `application` é o mesmo nome do pacote que você estava usando.

Se você estiver usando um framework CSS, poderá adicioná-lo ao Webpacker seguindo as instruções para carregar o framework como um módulo NPM usando o `yarn`, normalmente `yarn add <framework>`. O framework deve ter instruções sobre como importá-lo em um arquivo CSS ou SCSS.

### Usando o Webpacker para Ativos Estáticos

A configuração padrão do Webpacker [configuration](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) deve funcionar sem problemas para ativos estáticos.
A configuração inclui várias extensões de formato de arquivo de imagem e fonte, permitindo que o webpack os inclua no arquivo `manifest.json` gerado.

Com o webpack, ativos estáticos podem ser importados diretamente em arquivos JavaScript. O valor importado representa a URL do ativo. Por exemplo:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "Eu sou uma imagem empacotada pelo Webpacker";
document.body.appendChild(myImage);
```

Se você precisar referenciar ativos estáticos do Webpacker a partir de uma visualização Rails, os ativos precisam ser explicitamente requeridos dos arquivos JavaScript empacotados pelo Webpacker. Ao contrário do Sprockets, o Webpacker não importa seus ativos estáticos por padrão. O arquivo `app/javascript/packs/application.js` padrão possui um modelo para importar arquivos de um determinado diretório, que você pode descomentar para cada diretório em que deseja ter arquivos estáticos. Os diretórios são relativos a `app/javascript`. O modelo usa o diretório `images`, mas você pode usar qualquer coisa em `app/javascript`:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

Os ativos estáticos serão gerados em um diretório em `public/packs/media`. Por exemplo, uma imagem localizada e importada em `app/javascript/images/my-image.jpg` será gerada em `public/packs/media/images/my-image-abcd1234.jpg`. Para renderizar uma tag de imagem para essa imagem em uma visualização Rails, use `image_pack_tag 'media/images/my-image.jpg`.

Os helpers do Webpacker para ativos estáticos no ActionView correspondem aos helpers do pipeline de ativos de acordo com a seguinte tabela:
|Helper do ActionView | Helper do Webpacker |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

Além disso, o helper genérico `asset_pack_path` recebe a localização local de um arquivo e retorna sua localização do Webpacker para uso em visualizações do Rails.

Você também pode acessar a imagem referenciando diretamente o arquivo de um arquivo CSS em `app/javascript`.

### Webpacker em Rails Engines

A partir da versão 6 do Webpacker, o Webpacker não é "consciente de engines", o que significa que o Webpacker não possui paridade de recursos com o Sprockets quando se trata de uso em Rails engines.

Os autores de gems de Rails engines que desejam oferecer suporte a consumidores que usam o Webpacker são incentivados a distribuir ativos de frontend como um pacote NPM, além da própria gem, e fornecer instruções (ou um instalador) para demonstrar como os aplicativos host devem integrar. Um bom exemplo dessa abordagem é o [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Hot Module Replacement (HMR)

O Webpacker suporta HMR com o webpack-dev-server por padrão, e você pode ativá-lo definindo a opção dev_server/hmr dentro do arquivo `webpacker.yml`.

Confira a [documentação do webpack sobre o DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) para obter mais informações.

Para oferecer suporte ao HMR com o React, você precisará adicionar o react-hot-loader. Confira o [guia _Getting Started_ do React Hot Loader](https://gaearon.github.io/react-hot-loader/getstarted/).

Não se esqueça de desativar o HMR se você não estiver executando o webpack-dev-server; caso contrário, você receberá um "erro não encontrado" para folhas de estilo.

Webpacker em Diferentes Ambientes
-----------------------------------

O Webpacker possui três ambientes por padrão: `development`, `test` e `production`. Você pode adicionar configurações de ambiente adicionais no arquivo `webpacker.yml` e definir padrões diferentes para cada ambiente. O Webpacker também carregará o arquivo `config/webpack/<environment>.js` para configuração adicional do ambiente.

## Executando o Webpacker em Desenvolvimento

O Webpacker é fornecido com dois arquivos binstub para execução em desenvolvimento: `./bin/webpack` e `./bin/webpack-dev-server`. Ambos são wrappers finos em torno dos executáveis `webpack.js` e `webpack-dev-server.js` padrão e garantem que os arquivos de configuração corretos e as variáveis de ambiente sejam carregados com base no seu ambiente.

Por padrão, o Webpacker compila automaticamente sob demanda no desenvolvimento quando uma página do Rails é carregada. Isso significa que você não precisa executar processos separados e os erros de compilação serão registrados no log padrão do Rails. Você pode alterar isso alterando para `compile: false` no arquivo `config/webpacker.yml`. Executar `bin/webpack` forçará a compilação de seus pacotes.

Se você deseja usar o carregamento de código ao vivo ou tem JavaScript suficiente para que a compilação sob demanda seja muito lenta, será necessário executar `./bin/webpack-dev-server` ou `ruby ./bin/webpack-dev-server`. Esse processo observará as alterações nos arquivos `app/javascript/packs/*.js` e recompilará e recarregará automaticamente o navegador para corresponder.

Usuários do Windows precisarão executar esses comandos em um terminal separado do `bundle exec rails server`.

Depois de iniciar este servidor de desenvolvimento, o Webpacker começará automaticamente a encaminhar todas as solicitações de ativos do webpack para este servidor. Quando você parar o servidor, ele voltará à compilação sob demanda.

A [Documentação do Webpacker](https://github.com/rails/webpacker) fornece informações sobre as variáveis de ambiente que você pode usar para controlar o `webpack-dev-server`. Consulte as notas adicionais na [documentação do rails/webpacker sobre o uso do webpack-dev-server](https://github.com/rails/webpacker#development).

### Implantação do Webpacker

O Webpacker adiciona uma tarefa `webpacker:compile` à tarefa `bin/rails assets:precompile`, portanto, qualquer pipeline de implantação existente que estava usando `assets:precompile` deve funcionar. A tarefa de compilação irá compilar os pacotes e colocá-los em `public/packs`.

Documentação Adicional
------------------------

Para obter mais informações sobre tópicos avançados, como usar o Webpacker com frameworks populares, consulte a [Documentação do Webpacker](https://github.com/rails/webpacker).
