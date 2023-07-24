**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 282c6f5888c41f4c28238cd40bce5aa7
Installation des dépendances de développement de Rails Core
==============================================================

Ce guide explique comment configurer un environnement pour le développement de Rails Core.

Après avoir lu ce guide, vous saurez :

* Comment configurer votre machine pour le développement de Rails

--------------------------------------------------------------------------------

Autres façons de configurer votre environnement
------------------------------------------------

Si vous ne souhaitez pas configurer Rails pour le développement sur votre machine locale, vous pouvez utiliser Codespaces, le plugin VS Code Remote ou rails-dev-box. En savoir plus sur ces options [ici](contributing_to_ruby_on_rails.html#setting-up-a-development-environment).

Développement local
-------------------

Si vous souhaitez développer Ruby on Rails localement sur votre machine, suivez les étapes ci-dessous.

### Installer Git

Ruby on Rails utilise Git pour le contrôle du code source. La page d'accueil de [Git](https://git-scm.com/) contient les instructions d'installation. Il existe de nombreuses ressources en ligne qui vous aideront à vous familiariser avec Git.

### Cloner le référentiel Ruby on Rails

Accédez au dossier où vous souhaitez télécharger le code source de Ruby on Rails (il créera son propre sous-répertoire `rails`) et exécutez :

```bash
$ git clone https://github.com/rails/rails.git
$ cd rails
```

### Installer des outils et des services supplémentaires

Certains tests de Rails dépendent d'outils supplémentaires que vous devez installer avant d'exécuter ces tests spécifiques.

Voici la liste des dépendances supplémentaires de chaque gem :

* Action Cable dépend de Redis
* Active Record dépend de SQLite3, MySQL et PostgreSQL
* Active Storage dépend de Yarn (en plus de Yarn qui dépend de
  [Node.js](https://nodejs.org/)), ImageMagick, libvips, FFmpeg, muPDF,
  Poppler, et sur macOS également XQuartz.
* Active Support dépend de memcached et Redis
* Railties dépend d'un environnement d'exécution JavaScript, tel que
  l'installation de [Node.js](https://nodejs.org/).

Installez tous les services dont vous avez besoin pour tester correctement la gemme complète sur laquelle vous apporterez des modifications. Les instructions d'installation de ces services pour macOS, Ubuntu, Fedora/CentOS,
Arch Linux et FreeBSD sont détaillées ci-dessous.

NOTE : La documentation de Redis déconseille les installations avec des gestionnaires de paquets car ils sont généralement obsolètes. L'installation à partir des sources et la mise en service du serveur sont simples et bien documentées dans la [documentation de Redis](https://redis.io/download#installation).

NOTE : Les tests d'Active Record doivent réussir pour au moins MySQL, PostgreSQL et SQLite3. Votre correctif sera rejeté s'il est testé avec un seul adaptateur, sauf si les modifications et les tests sont spécifiques à l'adaptateur.

Vous trouverez ci-dessous des instructions sur la façon d'installer tous les outils supplémentaires pour différents systèmes d'exploitation.

#### macOS

Sur macOS, vous pouvez utiliser [Homebrew](https://brew.sh/) pour installer tous les outils supplémentaires.

Pour tout installer, exécutez :

```bash
$ brew bundle
```

Vous devrez également démarrer chacun des services installés. Pour afficher la liste de tous les services disponibles, exécutez :

```bash
$ brew services list
```

Vous pouvez ensuite démarrer chacun des services un par un de cette manière :

```bash
$ brew services start mysql
```

Remplacez `mysql` par le nom du service que vous souhaitez démarrer.

##### Problèmes potentiels

Cette section détaille certains des problèmes potentiels auxquels vous pourriez être confronté avec les extensions natives sur macOS, en particulier lors de l'inclusion de la gemme mysql2 en développement local. Cette documentation est susceptible de changer et peut être incorrecte car Apple apporte des modifications à l'environnement de développement sur Rails.

Pour compiler la gemme `mysql2` sur macOS, vous aurez besoin des éléments suivants :

1. `openssl@1.1` installé (pas `openssl@3`)
2. Ruby compilé avec `openssl@1.1`
3. Définir les indicateurs du compilateur dans la configuration du bundle pour `mysql2`.

Si à la fois `openssl@1.1` et `openssl@3` sont installés, vous devrez indiquer à Ruby d'utiliser `openssl@1.1` pour que Rails puisse inclure `mysql2`.

Dans votre fichier `.bash_profile`, définissez les variables `PATH` et `RUBY_CONFIGURE_OPTS` pour pointer vers `openssl@1.1` :

```
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

Dans votre fichier `~/.bundle/config`, définissez ce qui suit pour `mysql2`. Assurez-vous de supprimer toutes les autres entrées pour `BUNDLE_BUILD__MYSQL2` :

```
BUNDLE_BUILD__MYSQL2: "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib --with-cppflags=-L/usr/local/opt/openssl@1.1/include"
```

En définissant ces indicateurs avant d'installer Ruby et de regrouper Rails, vous devriez pouvoir faire fonctionner votre environnement de développement macOS local.

#### Ubuntu

Pour tout installer, exécutez :

```bash
$ sudo apt-get update
$ sudo apt-get install sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils

# Installer Yarn
# Utilisez cette commande si vous n'avez pas Node.js installé
$ curl --fail --silent --show-error --location https://deb.nodesource.com/setup_18.x | sudo -E bash -
$ sudo apt-get install -y nodejs
# Une fois que vous avez installé Node.js, installez le package npm yarn
$ sudo npm install --global yarn
```
#### Fedora ou CentOS

Pour tout installer, exécutez :

```bash
$ sudo dnf install sqlite-devel sqlite-libs mysql-server mysql-devel postgresql-server postgresql-devel redis memcached imagemagick ffmpeg mupdf libxml2-devel vips poppler-utils

# Installer Yarn
# Utilisez cette commande si vous n'avez pas Node.js installé
$ curl --silent --location https://rpm.nodesource.com/setup_18.x | sudo bash -
$ sudo dnf install -y nodejs
# Une fois que vous avez installé Node.js, installez le package npm yarn
$ sudo npm install --global yarn
```

#### Arch Linux

Pour tout installer, exécutez :

```bash
$ sudo pacman -S sqlite mariadb libmariadbclient mariadb-clients postgresql postgresql-libs redis memcached imagemagick ffmpeg mupdf mupdf-tools poppler yarn libxml2 libvips poppler
$ sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
$ sudo systemctl start redis mariadb memcached
```

NOTE : Si vous utilisez Arch Linux, MySQL n'est plus pris en charge, vous devrez donc utiliser MariaDB à la place (voir [cette annonce](https://www.archlinux.org/news/mariadb-replaces-mysql-in-repositories/)).

#### FreeBSD

Pour tout installer, exécutez :

```bash
$ sudo pkg install sqlite3 mysql80-client mysql80-server postgresql11-client postgresql11-server memcached imagemagick6 ffmpeg mupdf yarn libxml2 vips poppler-utils
# portmaster databases/redis
```

Ou installez tout via les ports (ces packages se trouvent dans le dossier `databases`).

NOTE : Si vous rencontrez des problèmes lors de l'installation de MySQL, veuillez consulter [la documentation MySQL](https://dev.mysql.com/doc/refman/en/freebsd-installation.html).

#### Debian

Pour installer toutes les dépendances, exécutez :

```bash
$ sudo apt-get install sqlite3 libsqlite3-dev default-mysql-server default-libmysqlclient-dev postgresql postgresql-client postgresql-contrib libpq-dev redis-server memcached imagemagick ffmpeg mupdf mupdf-tools libxml2-dev libvips42 poppler-utils
```

NOTE : Si vous utilisez Debian, MariaDB est le serveur MySQL par défaut, donc il peut y avoir des différences.

### Configuration de la base de données

Il y a quelques étapes supplémentaires nécessaires pour configurer les moteurs de base de données nécessaires pour exécuter les tests Active Record.

L'authentification de PostgreSQL fonctionne différemment. Pour configurer l'environnement de développement avec votre compte de développement, sous Linux ou BSD, vous devez simplement exécuter :

```bash
$ sudo -u postgres createuser --superuser $USER
```

et pour macOS :

```bash
$ createuser --superuser $USER
```

NOTE : MySQL créera les utilisateurs lorsque les bases de données seront créées. La tâche suppose que votre utilisateur est `root` sans mot de passe.

Ensuite, vous devez créer les bases de données de test pour MySQL et PostgreSQL avec :

```bash
$ cd activerecord
$ bundle exec rake db:create
```

Vous pouvez également créer des bases de données de test pour chaque moteur de base de données séparément :

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
$ bundle exec rake db:postgresql:build
```

et vous pouvez supprimer les bases de données avec :

```bash
$ cd activerecord
$ bundle exec rake db:drop
```

NOTE : Utiliser la tâche Rake pour créer les bases de données de test garantit qu'elles ont le bon jeu de caractères et la bonne collation.

Si vous utilisez une autre base de données, vérifiez le fichier `activerecord/test/config.yml` ou `activerecord/test/config.example.yml` pour obtenir les informations de connexion par défaut. Vous pouvez modifier `activerecord/test/config.yml` pour fournir des informations d'identification différentes sur votre machine, mais vous ne devez pas pousser ces modifications vers Rails.

### Installer les dépendances JavaScript

Si vous avez installé Yarn, vous devrez installer les dépendances JavaScript :

```bash
$ yarn install
```

### Installer les dépendances Gem

Les gems sont installées avec [Bundler](https://bundler.io/), qui est inclus par défaut avec Ruby.

Pour installer le Gemfile de Rails, exécutez :

```bash
$ bundle install
```

Si vous n'avez pas besoin d'exécuter les tests Active Record, vous pouvez exécuter :

```bash
$ bundle install --without db
```

### Contribuer à Rails

Une fois que vous avez tout configuré, lisez comment vous pouvez commencer à [contribuer](contributing_to_ruby_on_rails.html#running-an-application-against-your-local-branch).
