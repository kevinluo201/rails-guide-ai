**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Instalando as Dependências Principais de Desenvolvimento do Rails
==================================================================

Este guia aborda como configurar um ambiente para o desenvolvimento central do Ruby on Rails.

Após ler este guia, você saberá:

* Como configurar sua máquina para o desenvolvimento do Rails

--------------------------------------------------------------------------------

Outras Formas de Configurar seu Ambiente
----------------------------------------

Se você não quiser configurar o Rails para desenvolvimento em sua máquina local, você pode usar o Codespaces, o Plugin Remoto do VS Code ou o rails-dev-box. Saiba mais sobre essas opções [aqui](contributing_to_ruby_on_rails.html#setting-up-a-development-environment).

Desenvolvimento Local
---------------------

Se você deseja desenvolver o Ruby on Rails localmente em sua máquina, siga as etapas abaixo.

### Instale o Git

O Ruby on Rails usa o Git para controle de código-fonte. A página inicial do [Git](https://git-scm.com/) tem instruções de instalação. Existem várias fontes online que o ajudarão a se familiarizar com o Git.

### Clone o Repositório do Ruby on Rails

Navegue até a pasta onde você deseja baixar o código-fonte do Ruby on Rails (ele criará seu próprio subdiretório `rails`) e execute:

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Instale Ferramentas e Serviços Adicionais

Alguns testes do Rails dependem de ferramentas adicionais que você precisa instalar antes de executar esses testes específicos.

Aqui está a lista das dependências adicionais de cada gem:

* Action Cable depende do Redis
* Active Record depende do SQLite3, MySQL e PostgreSQL
* Active Storage depende do Yarn (além disso, o Yarn depende do
  [Node.js](https://nodejs.org/)), ImageMagick, libvips, FFmpeg, muPDF,
  Poppler e no macOS também XQuartz.
* Active Support depende do memcached e Redis
* Railties depende de um ambiente de execução JavaScript, como ter o
  [Node.js](https://nodejs.org/) instalado.

Instale todos os serviços de que você precisa para testar corretamente a gem completa na qual você fará alterações. Abaixo estão detalhadas as instruções de como instalar esses serviços no macOS, Ubuntu, Fedora/CentOS, Arch Linux e FreeBSD.

NOTA: A documentação do Redis desencoraja instalações com gerenciadores de pacotes, pois geralmente estão desatualizados. A instalação a partir do código-fonte e a inicialização do servidor são diretas e bem documentadas na [documentação do Redis](https://redis.io/download#installation).

NOTA: Os testes do Active Record _devem_ passar pelo menos para o MySQL, PostgreSQL e SQLite3. Sua correção será rejeitada se testada apenas em um adaptador, a menos que a alteração e os testes sejam específicos do adaptador.

Abaixo você encontrará instruções sobre como instalar todas as ferramentas adicionais para diferentes sistemas operacionais.

#### macOS

No macOS, você pode usar o [Homebrew](https://brew.sh/) para instalar todas as ferramentas adicionais.

Para instalar todas, execute:

```bash
$ brew bundle
```

Você também precisará iniciar cada um dos serviços instalados. Para listar todos
os serviços disponíveis, execute:

```bash
$ brew services list
```

Você pode então iniciar cada um dos serviços um por um desta forma:

```bash
$ brew services start mysql
```

Substitua `mysql` pelo nome do serviço que você deseja iniciar.

##### Problemas Potenciais

Esta seção detalha alguns dos problemas potenciais que você pode encontrar com extensões nativas no macOS, especialmente ao agrupar a gema mysql2 no desenvolvimento local. Esta documentação está sujeita a alterações e pode estar incorreta à medida que a Apple faz alterações no ambiente de desenvolvimento no Rails.

Para compilar a gema `mysql2` no macOS, você precisará do seguinte:

1. `openssl@1.1` instalado (não `openssl@3`)
2. Ruby compilado com `openssl@1.1`
3. Definir flags do compilador no arquivo de configuração do bundle para `mysql2`.

Se tanto `openssl@1.1` quanto `openssl@3` estiverem instalados, você precisará informar ao Ruby para usar `openssl@1.1` para que o Rails agrupe o `mysql2`.

No seu `.bash_profile`, defina o `PATH` e `RUBY_CONFIGURE_OPTS` para apontar para o `openssl@1.1`:

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

No seu `~/.bundle/config`, defina o seguinte para `mysql2`. Certifique-se de excluir quaisquer outras entradas para `BUNDLE_BUILD__MYSQL2`:

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

Ao definir essas flags antes de instalar o Ruby e agrupar o Rails, você deve conseguir fazer seu ambiente de desenvolvimento local no macOS funcionar.

#### Ubuntu

Para instalar todas, execute:

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Instale o Yarn
# Use este comando se você não tiver o Node.js instalado
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Depois de instalar o Node.js, instale o pacote npm do yarn
$ sudo npm install --global yarn
```
#### Fedora ou CentOS

Para instalar tudo, execute:

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Instalar o Yarn
# Use este comando se você não tiver o Node.js instalado
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Depois de instalar o Node.js, instale o pacote npm do yarn
$ sudo npm install --global yarn
```

#### Arch Linux

Para instalar tudo, execute:

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

NOTA: Se você estiver executando o Arch Linux, o MySQL não é mais suportado, então você precisará usar o MariaDB em vez disso (veja [este anúncio](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Para instalar tudo, execute:

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

Ou instale tudo através das portas (esses pacotes estão localizados na pasta `databases`).

NOTA: Se você encontrar problemas durante a instalação do MySQL, consulte a [documentação do MySQL](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

#### Debian

Para instalar todas as dependências, execute:

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

NOTA: Se você estiver executando o Debian, o MariaDB é o servidor MySQL padrão, portanto, esteja ciente de que pode haver diferenças.

### Configuração do Banco de Dados

Existem algumas etapas adicionais necessárias para configurar os motores de banco de dados necessários para executar os testes do Active Record.

A autenticação do PostgreSQL funciona de forma diferente. Para configurar o ambiente de desenvolvimento com sua conta de desenvolvimento, no Linux ou BSD, basta executar:

```bash
$ sudo -u postgres createuser --superuser $USER
```

e no macOS:

```bash
$ createuser --superuser $USER
```

NOTA: O MySQL criará os usuários quando os bancos de dados forem criados. A tarefa assume que seu usuário é `root` sem senha.

Em seguida, você precisa criar os bancos de dados de teste tanto para o MySQL quanto para o PostgreSQL com:

```bash
$ cd activerecord
$ bundle exec rake db:create
```

Você também pode criar bancos de dados de teste para cada mecanismo de banco de dados separadamente:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

e você pode excluir os bancos de dados usando:

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTA: Usar a tarefa Rake para criar os bancos de dados de teste garante que eles tenham o conjunto de caracteres e a ordenação corretos.

Se você estiver usando outro banco de dados, verifique o arquivo `activerecord/test/config.yml` ou `activerecord/test/config.example.yml` para obter informações de conexão padrão. Você pode editar `activerecord/test/config.yml` para fornecer credenciais diferentes em sua máquina, mas não deve enviar nenhuma dessas alterações de volta para o Rails.

### Instalar Dependências JavaScript

Se você instalou o Yarn, precisará instalar as dependências JavaScript:

```bash
$ yarn install
```

### Instalando Dependências Gem

As gems são instaladas com o [Bundler](https://bundler.io/), que é fornecido por padrão com o Ruby.

Para instalar o Gemfile para o Rails, execute:

```bash
$ bundle install
```

Se você não precisa executar os testes do Active Record, pode executar:

```bash
$ bundle install --without db
```

### Contribuir para o Rails

Depois de configurar tudo, leia como você pode começar a [contribuir](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch).
