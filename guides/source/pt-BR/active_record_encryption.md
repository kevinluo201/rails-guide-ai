**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Criptografia do Active Record
========================

Este guia aborda a criptografia das informações do seu banco de dados usando o Active Record.

Após ler este guia, você saberá:

* Como configurar a criptografia do banco de dados com o Active Record.
* Como migrar dados não criptografados.
* Como fazer diferentes esquemas de criptografia coexistirem.
* Como usar a API.
* Como configurar a biblioteca e como estendê-la.

--------------------------------------------------------------------------------

O Active Record suporta criptografia em nível de aplicativo. Ele funciona declarando quais atributos devem ser criptografados e criptografando e descriptografando-os de forma transparente quando necessário. A camada de criptografia fica entre o banco de dados e a aplicação. A aplicação acessará dados não criptografados, mas o banco de dados os armazenará criptografados.

## Por que Criptografar Dados em Nível de Aplicativo?

A criptografia do Active Record existe para proteger informações sensíveis em sua aplicação. Um exemplo típico é informações de identificação pessoal dos usuários. Mas por que você gostaria de ter criptografia em nível de aplicativo se já está criptografando seu banco de dados em repouso?

Como benefício prático imediato, a criptografia de atributos sensíveis adiciona uma camada adicional de segurança. Por exemplo, se um invasor ganhasse acesso ao seu banco de dados, a um snapshot dele ou aos logs de sua aplicação, ele não seria capaz de entender as informações criptografadas. Além disso, a criptografia pode impedir que desenvolvedores exponham inadvertidamente dados sensíveis dos usuários nos logs da aplicação.

Mas, mais importante, ao usar a criptografia do Active Record, você define o que constitui informações sensíveis em sua aplicação no nível do código. A criptografia do Active Record permite um controle granular do acesso aos dados em sua aplicação e nos serviços que consomem dados de sua aplicação. Por exemplo, considere [consoles Rails auditáveis que protegem dados criptografados](https://github.com/basecamp/console1984) ou verifique o sistema integrado para [filtrar automaticamente os parâmetros do controlador](#filtering-params-named-as-encrypted-columns).

## Uso Básico

### Configuração(duplicated)

Primeiro, você precisa adicionar algumas chaves às suas [credenciais do Rails](/security.html#custom-credentials). Execute `bin/rails db:encryption:init` para gerar um conjunto de chaves aleatórias:

```bash
$ bin/rails db:encryption:init
Adicione esta entrada às credenciais do ambiente de destino:

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

NOTA: Esses valores gerados têm 32 bytes de comprimento. Se você gerá-los por conta própria, os comprimentos mínimos que você deve usar são 12 bytes para a chave primária (que será usada para derivar a chave AES de 32 bytes) e 20 bytes para o salt.

### Declaração de Atributos Criptografados

Atributos criptografáveis são definidos no nível do modelo. Eles são atributos regulares do Active Record com um coluna com o mesmo nome.

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

A biblioteca criptografará esses atributos de forma transparente antes de salvá-los no banco de dados e os descriptografará ao recuperá-los:

```ruby
article = Article.create title: "Criptografe tudo!"
article.title # => "Criptografe tudo!"
```

Mas, por baixo dos panos, o SQL executado se parece com isso:

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### Importante: Sobre Armazenamento e Tamanho da Coluna

A criptografia requer espaço extra devido à codificação Base64 e aos metadados armazenados junto com as cargas criptografadas. Ao usar o provedor de chave de criptografia de envelope integrado, você pode estimar a sobrecarga no pior caso em cerca de 255 bytes. Essa sobrecarga é negligível em tamanhos maiores. Não apenas porque ela se dilui, mas porque a biblioteca usa compressão por padrão, o que pode oferecer até 30% de economia de armazenamento em relação à versão não criptografada para cargas maiores.

Há uma preocupação importante sobre os tamanhos das colunas de string: nos bancos de dados modernos, o tamanho da coluna determina o *número de caracteres* que ela pode alocar, não o número de bytes. Por exemplo, com UTF-8, cada caractere pode ocupar até quatro bytes, então, potencialmente, uma coluna em um banco de dados usando UTF-8 pode armazenar até quatro vezes o seu tamanho em termos de *número de bytes*. Agora, as cargas criptografadas são strings binárias serializadas como Base64, então elas podem ser armazenadas em colunas `string` regulares. Por serem uma sequência de bytes ASCII, uma coluna criptografada pode ocupar até quatro vezes o tamanho de sua versão clara. Portanto, mesmo que os bytes armazenados no banco de dados sejam os mesmos, a coluna deve ser quatro vezes maior.

Na prática, isso significa:

* Ao criptografar textos curtos escritos em alfabetos ocidentais (principalmente caracteres ASCII), você deve considerar essa sobrecarga adicional de 255 ao definir o tamanho da coluna.
* Ao criptografar textos curtos escritos em alfabetos não ocidentais, como o cirílico, você deve multiplicar o tamanho da coluna por 4. Observe que a sobrecarga de armazenamento é de no máximo 255 bytes.
* Ao criptografar textos longos, você pode ignorar as preocupações com o tamanho da coluna.
Alguns exemplos:

| Conteúdo a ser criptografado                     | Tamanho original da coluna | Tamanho recomendado da coluna criptografada | Sobrecarga de armazenamento (pior caso) |
| ------------------------------------------------- | ------------------------- | ------------------------------------------ | --------------------------------------- |
| Endereços de e-mail                              | string(255)               | string(510)                                | 255 bytes                              |
| Sequência curta de emojis                         | string(255)               | string(1020)                               | 255 bytes                              |
| Resumo de textos escritos em alfabetos não ocidentais | string(500)               | string(2000)                               | 255 bytes                              |
| Texto arbitrariamente longo                      | text                      | text                                       | insignificante                          |

### Criptografia Determinística e Não-determinística

Por padrão, o Active Record Encryption utiliza uma abordagem não-determinística para criptografia. Não-determinístico, nesse contexto, significa que criptografar o mesmo conteúdo com a mesma senha duas vezes resultará em textos cifrados diferentes. Essa abordagem melhora a segurança tornando a criptoanálise dos textos cifrados mais difícil e a consulta ao banco de dados impossível.

Você pode usar a opção `deterministic:` para gerar vetores de inicialização de forma determinística, permitindo a consulta de dados criptografados.

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("algum@email.com") # Você pode consultar o modelo normalmente
```

A abordagem não-determinística é recomendada, a menos que você precise consultar os dados.

NOTA: No modo não-determinístico, o Active Record utiliza AES-GCM com uma chave de 256 bits e um vetor de inicialização aleatório. No modo determinístico, ele também utiliza AES-GCM, mas o vetor de inicialização é gerado como um digest HMAC-SHA-256 da chave e do conteúdo a ser criptografado.

NOTA: Você pode desativar a criptografia determinística omitindo uma `deterministic_key`.

## Recursos

### Action Text

Você pode criptografar atributos do Action Text passando `encrypted: true` em sua declaração.

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

NOTA: A passagem de opções de criptografia individuais para atributos do Action Text ainda não é suportada. Ele utilizará a criptografia não-determinística com as opções de criptografia globais configuradas.

### Fixtures

Você pode fazer com que as fixtures do Rails sejam criptografadas automaticamente adicionando essa opção ao seu `test.rb`:

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

Quando ativado, todos os atributos criptografáveis serão criptografados de acordo com as configurações de criptografia definidas no modelo.

#### Fixtures do Action Text

Para criptografar fixtures do Action Text, você deve colocá-las em `fixtures/action_text/encrypted_rich_texts.yml`.

### Tipos Suportados

O `active_record.encryption` serializará os valores usando o tipo subjacente antes de criptografá-los, mas *eles devem ser serializáveis como strings*. Tipos estruturados como `serialized` são suportados por padrão.

Se você precisar suportar um tipo personalizado, a maneira recomendada é usar um [atributo serializado](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html). A declaração do atributo serializado deve vir **antes** da declaração de criptografia:

```ruby
# CORRETO
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# INCORRETO
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### Ignorando Maiúsculas e Minúsculas

Você pode precisar ignorar o uso de maiúsculas e minúsculas ao consultar dados criptografados de forma determinística. Duas abordagens facilitam a realização disso:

Você pode usar a opção `:downcase` ao declarar o atributo criptografado para transformar o conteúdo em minúsculas antes da criptografia ocorrer.

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

Ao usar `:downcase`, a caixa original é perdida. Em algumas situações, você pode querer ignorar a caixa apenas durante a consulta, mantendo a caixa original ao armazenar. Para essas situações, você pode usar a opção `:ignore_case`. Isso requer que você adicione uma nova coluna chamada `original_<nome_da_coluna>` para armazenar o conteúdo com a caixa inalterada:

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # o conteúdo com a caixa original será armazenado na coluna `original_name`
end
```

### Suporte para Dados Não Criptografados

Para facilitar a migração de dados não criptografados, a biblioteca inclui a opção `config.active_record.encryption.support_unencrypted_data`. Quando definida como `true`:

* Tentar ler atributos criptografados que não estão criptografados funcionará normalmente, sem gerar erros.
* Consultas com atributos criptografados de forma determinística incluirão a versão "texto claro" deles para suportar a busca por conteúdo criptografado e não criptografado. Você precisa definir `config.active_record.encryption.extend_queries = true` para habilitar isso.

**Essa opção deve ser usada durante períodos de transição** em que dados claros e dados criptografados devem coexistir. Ambos são definidos como `false` por padrão, que é o objetivo recomendado para qualquer aplicação: erros serão gerados ao trabalhar com dados não criptografados.

### Suporte para Esquemas de Criptografia Anteriores

Alterar as propriedades de criptografia dos atributos pode quebrar dados existentes. Por exemplo, imagine que você queira tornar um atributo determinístico não-determinístico. Se você apenas alterar a declaração no modelo, a leitura dos textos cifrados existentes falhará porque o método de criptografia é diferente agora.
Para dar suporte a essas situações, você pode declarar esquemas de criptografia anteriores que serão usados em dois cenários:

* Ao ler dados criptografados, o Active Record Encryption tentará esquemas de criptografia anteriores se o esquema atual não funcionar.
* Ao consultar dados determinísticos, ele adicionará textos cifrados usando esquemas anteriores para que as consultas funcionem perfeitamente com dados criptografados com esquemas diferentes. Você deve definir `config.active_record.encryption.extend_queries = true` para habilitar isso.

Você pode configurar esquemas de criptografia anteriores:

* Globalmente
* Em uma base de atributo por atributo

#### Esquemas de Criptografia Anteriores Globais

Você pode adicionar esquemas de criptografia anteriores adicionando-os como uma lista de propriedades usando a propriedade de configuração `previous` em seu `application.rb`:

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### Esquemas de Criptografia por Atributo

Use `:previous` ao declarar o atributo:

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### Esquemas de Criptografia e Atributos Determinísticos

Ao adicionar esquemas de criptografia anteriores:

* Com criptografia **não-determinística**, novas informações sempre serão criptografadas com o esquema de criptografia *mais recente* (atual).
* Com criptografia **determinística**, novas informações sempre serão criptografadas com o esquema de criptografia *mais antigo* por padrão.

Normalmente, com criptografia determinística, você deseja que os textos cifrados permaneçam constantes. Você pode alterar esse comportamento definindo `deterministic: { fixed: false }`. Nesse caso, ele usará o esquema de criptografia *mais recente* para criptografar novos dados.

### Restrições Únicas

NOTA: Restrições únicas só podem ser usadas com dados criptografados de forma determinística.

#### Validações Únicas

As validações únicas são suportadas normalmente desde que as consultas estendidas estejam habilitadas (`config.active_record.encryption.extend_queries = true`).

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

Elas também funcionarão ao combinar dados criptografados e não criptografados, e ao configurar esquemas de criptografia anteriores.

NOTA: Se você quiser ignorar maiúsculas e minúsculas, certifique-se de usar `downcase:` ou `ignore_case:` na declaração `encrypts`. Usar a opção `case_sensitive:` na validação não funcionará.

#### Índices Únicos

Para dar suporte a índices únicos em colunas criptografadas de forma determinística, você precisa garantir que o texto cifrado delas nunca mude.

Para incentivar isso, os atributos determinísticos sempre usarão o esquema de criptografia mais antigo disponível por padrão quando vários esquemas de criptografia estiverem configurados. Caso contrário, é seu trabalho garantir que as propriedades de criptografia não mudem para esses atributos, ou os índices únicos não funcionarão.

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### Filtragem de Parâmetros Nomeados como Colunas Criptografadas

Por padrão, as colunas criptografadas são configuradas para serem [filtradas automaticamente nos logs do Rails](action_controller_overview.html#parameters-filtering). Você pode desabilitar esse comportamento adicionando o seguinte ao seu `application.rb`:

Ao gerar o parâmetro de filtro, ele usará o nome do modelo como prefixo. Por exemplo: Para `Person#name`, o parâmetro de filtro será `person.name`.

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

Caso você queira excluir colunas específicas dessa filtragem automática, adicione-as a `config.active_record.encryption.excluded_from_filter_parameters`.

### Codificação

A biblioteca preservará a codificação para valores de string criptografados de forma não-determinística.

Como a codificação é armazenada juntamente com a carga útil criptografada, os valores criptografados de forma determinística forçarão a codificação UTF-8 por padrão. Portanto, o mesmo valor com uma codificação diferente resultará em um texto cifrado diferente quando criptografado. Normalmente, você deseja evitar isso para manter as consultas e restrições de unicidade funcionando, então a biblioteca realizará a conversão automaticamente em seu nome.

Você pode configurar a codificação padrão desejada para criptografia determinística com:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

E você pode desabilitar esse comportamento e preservar a codificação em todos os casos com:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## Gerenciamento de Chaves

Os provedores de chave implementam estratégias de gerenciamento de chaves. Você pode configurar provedores de chave globalmente ou em uma base de atributo por atributo.

### Provedores de Chave Incorporados

#### DerivedSecretKeyProvider

Um provedor de chave que fornecerá chaves derivadas das senhas fornecidas usando PBKDF2.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["algumas senhas", "para derivar chaves. ", "Essas devem estar em", "credenciais"])
```

NOTA: Por padrão, `active_record.encryption` configura um `DerivedSecretKeyProvider` com as chaves definidas em `active_record.encryption.primary_key`.

#### EnvelopeEncryptionKeyProvider

Implementa uma estratégia simples de [envelope encryption](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping):

- Gera uma chave aleatória para cada operação de criptografia de dados
- Armazena a chave de dados junto com os dados em si, criptografada com uma chave primária definida na credencial `active_record.encryption.primary_key`.

Você pode configurar o Active Record para usar esse provedor de chave adicionando isso ao seu `application.rb`:

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

Como acontece com outros provedores de chave incorporados, você pode fornecer uma lista de chaves primárias em `active_record.encryption.primary_key` para implementar esquemas de rotação de chaves.
### Provedores de Chave Personalizados

Para esquemas de gerenciamento de chave mais avançados, você pode configurar um provedor de chave personalizado em um inicializador:

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

Um provedor de chave deve implementar esta interface:

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

Ambos os métodos retornam objetos `ActiveRecord::Encryption::Key`:

- `encryption_key` retorna a chave usada para criptografar algum conteúdo
- `decryption_keys` retorna uma lista de chaves potenciais para descriptografar uma mensagem específica

Uma chave pode incluir tags arbitrárias que serão armazenadas sem criptografia com a mensagem. Você pode usar `ActiveRecord::Encryption::Message#headers` para examinar esses valores ao descriptografar.

### Provedores de Chave Específicos do Modelo

Você pode configurar um provedor de chave em uma base de classe com a opção `:key_provider`:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### Chaves Específicas do Modelo

Você pode configurar uma chave específica para uma classe com a opção `:key`:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "alguma chave secreta para resumos de artigos"
end
```

O Active Record usa a chave para derivar a chave usada para criptografar e descriptografar os dados.

### Rotação de Chaves

`active_record.encryption` pode trabalhar com listas de chaves para suportar a implementação de esquemas de rotação de chaves:

- A **última chave** será usada para criptografar novo conteúdo.
- Todas as chaves serão testadas ao descriptografar o conteúdo até que uma funcione.

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # Chaves anteriores ainda podem descriptografar conteúdo existente
    - bc17e7b413fd4720716a7633027f8cc4 # Ativa, criptografa novo conteúdo
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

Isso permite fluxos de trabalho nos quais você mantém uma lista curta de chaves, adicionando novas chaves, recriptografando conteúdo e excluindo chaves antigas.

NOTA: A rotação de chaves não é atualmente suportada para criptografia determinística.

NOTA: O Active Record Encryption ainda não fornece gerenciamento automático de processos de rotação de chaves. Todas as peças estão lá, mas isso ainda não foi implementado.

### Armazenando Referências de Chave

Você pode configurar `active_record.encryption.store_key_references` para fazer com que `active_record.encryption` armazene uma referência à chave de criptografia na própria mensagem criptografada.

```ruby
config.active_record.encryption.store_key_references = true
```

Fazer isso torna a descriptografia mais eficiente, pois o sistema agora pode localizar as chaves diretamente em vez de tentar listas de chaves. O preço a pagar é o armazenamento: os dados criptografados serão um pouco maiores.

## API

### API Básica

A criptografia do ActiveRecord destina-se a ser usada de forma declarativa, mas oferece uma API para cenários de uso avançados.

#### Criptografar e Descriptografar

```ruby
article.encrypt # criptografa ou recriptografa todos os atributos criptografáveis
article.decrypt # descriptografa todos os atributos criptografáveis
```

#### Ler Ciphertext

```ruby
article.ciphertext_for(:title)
```

#### Verificar se o Atributo está Criptografado ou Não

```ruby
article.encrypted_attribute?(:title)
```

## Configuração

### Opções de Configuração

Você pode configurar as opções do Active Record Encryption em seu `application.rb` (cenário mais comum) ou em um arquivo de configuração específico do ambiente `config/environments/<nome do ambiente>.rb` se você quiser defini-las com base no ambiente.

AVISO: É recomendado usar o suporte embutido de credenciais do Rails para armazenar chaves. Se você preferir defini-las manualmente por meio de propriedades de configuração, certifique-se de não commitá-las com seu código (por exemplo, use variáveis de ambiente).

#### `config.active_record.encryption.support_unencrypted_data`

Quando verdadeiro, os dados não criptografados podem ser lidos normalmente. Quando falso, ele lançará erros. Padrão: `false`.

#### `config.active_record.encryption.extend_queries`

Quando verdadeiro, as consultas que referenciam atributos criptografados de forma determinística serão modificadas para incluir valores adicionais, se necessário. Esses valores adicionais serão a versão limpa do valor (quando `config.active_record.encryption.support_unencrypted_data` é verdadeiro) e valores criptografados com esquemas de criptografia anteriores, se houver (conforme fornecido com a opção `previous:`). Padrão: `false` (experimental).

#### `config.active_record.encryption.encrypt_fixtures`

Quando verdadeiro, os atributos criptografáveis em fixtures serão automaticamente criptografados ao serem carregados. Padrão: `false`.

#### `config.active_record.encryption.store_key_references`

Quando verdadeiro, uma referência à chave de criptografia é armazenada nos cabeçalhos da mensagem criptografada. Isso torna a descriptografia mais rápida quando várias chaves estão em uso. Padrão: `false`.

#### `config.active_record.encryption.add_to_filter_parameters`

Quando verdadeiro, os nomes dos atributos criptografados são adicionados automaticamente aos [`config.filter_parameters`][] e não serão exibidos nos logs. Padrão: `true`.


#### `config.active_record.encryption.excluded_from_filter_parameters`

Você pode configurar uma lista de parâmetros que não serão filtrados quando `config.active_record.encryption.add_to_filter_parameters` for verdadeiro. Padrão: `[]`.

#### `config.active_record.encryption.validate_column_size`

Adiciona uma validação com base no tamanho da coluna. Isso é recomendado para evitar o armazenamento de valores enormes usando payloads altamente compressíveis. Padrão: `true`.

#### `config.active_record.encryption.primary_key`

A chave ou lista de chaves usadas para derivar chaves de criptografia de dados raiz. A forma como elas são usadas depende do provedor de chave configurado. É preferível configurá-lo via credencial `active_record_encryption.primary_key`.
#### `config.active_record.encryption.deterministic_key`

A chave ou lista de chaves usadas para criptografia determinística. É preferível configurá-la por meio da credencial `active_record_encryption.deterministic_key`.

#### `config.active_record.encryption.key_derivation_salt`

O salt usado ao derivar chaves. É preferível configurá-lo por meio da credencial `active_record_encryption.key_derivation_salt`.

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

A codificação padrão para atributos criptografados de forma determinística. Você pode desabilitar a codificação forçada definindo essa opção como `nil`. Por padrão, é `Encoding::UTF_8`.

#### `config.active_record.encryption.hash_digest_class`

O algoritmo de digest usado para derivar chaves. Por padrão, é `OpenSSL::Digest::SHA1`.

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Suporta descriptografar dados criptografados de forma não determinística com uma classe de digest SHA1. O padrão é falso, o que significa que só suportará o algoritmo de digest configurado em `config.active_record.encryption.hash_digest_class`.

### Contextos de Criptografia

Um contexto de criptografia define os componentes de criptografia que são usados em um determinado momento. Existe um contexto de criptografia padrão com base na sua configuração global, mas você pode configurar um contexto personalizado para um determinado atributo ou ao executar um bloco de código específico.

NOTA: Os contextos de criptografia são um mecanismo de configuração flexível, mas avançado. A maioria dos usuários não precisa se preocupar com eles.

Os principais componentes dos contextos de criptografia são:

* `encryptor`: expõe a API interna para criptografar e descriptografar dados. Ele interage com um `key_provider` para construir mensagens criptografadas e lidar com sua serialização. A criptografia/descriptografia em si é feita pelo `cipher` e a serialização pelo `message_serializer`.
* `cipher`: o próprio algoritmo de criptografia (AES 256 GCM)
* `key_provider`: fornece chaves de criptografia e descriptografia.
* `message_serializer`: serializa e desserializa payloads criptografados (`Message`).

NOTA: Se você decidir construir seu próprio `message_serializer`, é importante usar mecanismos seguros que não possam desserializar objetos arbitrários. Um cenário comum suportado é criptografar dados não criptografados existentes. Um atacante pode aproveitar isso para inserir uma carga útil adulterada antes que a criptografia ocorra e realizar ataques RCE. Isso significa que os serializadores personalizados devem evitar `Marshal`, `YAML.load` (use `YAML.safe_load` em vez disso) ou `JSON.load` (use `JSON.parse` em vez disso).

#### Contexto de Criptografia Global

O contexto de criptografia global é aquele usado por padrão e é configurado como outras propriedades de configuração em seu `application.rb` ou arquivos de configuração de ambiente.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### Contextos de Criptografia por Atributo

Você pode substituir os parâmetros do contexto de criptografia passando-os na declaração do atributo:

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### Contexto de Criptografia ao Executar um Bloco de Código

Você pode usar `ActiveRecord::Encryption.with_encryption_context` para definir um contexto de criptografia para um determinado bloco de código:

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### Contextos de Criptografia Incorporados

##### Desabilitar Criptografia

Você pode executar código sem criptografia:

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

Isso significa que a leitura de texto criptografado retornará o texto cifrado e o conteúdo salvo será armazenado sem criptografia.

##### Proteger Dados Criptografados

Você pode executar código sem criptografia, mas impedir a sobrescrita de conteúdo criptografado:

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

Isso pode ser útil se você quiser proteger dados criptografados enquanto ainda executa código arbitrário contra eles (por exemplo, em um console do Rails).
[`config.filter_parameters`]: configuring.html#config-filter-parameters
