**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b95e1fead49349e056e5faed88aa5760
Atualizando o Ruby on Rails
=======================

Este guia fornece os passos a serem seguidos ao atualizar suas aplicações para uma versão mais recente do Ruby on Rails. Esses passos também estão disponíveis nos guias de lançamento individuais.

--------------------------------------------------------------------------------

Conselhos Gerais
--------------

Antes de tentar atualizar uma aplicação existente, você deve ter um bom motivo para fazer a atualização. Você precisa equilibrar vários fatores: a necessidade de novos recursos, a dificuldade crescente de encontrar suporte para código antigo e o tempo e habilidades disponíveis, para citar alguns.

### Cobertura de Testes

A melhor maneira de garantir que sua aplicação ainda funcione após a atualização é ter uma boa cobertura de testes antes de iniciar o processo. Se você não tiver testes automatizados que exercitem a maior parte da sua aplicação, precisará gastar tempo exercitando manualmente todas as partes que foram alteradas. No caso de uma atualização do Rails, isso significará cada funcionalidade individual da aplicação. Faça um favor a si mesmo e certifique-se de que sua cobertura de testes está boa _antes_ de iniciar uma atualização.

### Versões do Ruby

O Rails geralmente se mantém próximo à versão mais recente do Ruby lançada quando é lançado:

* Rails 7 requer Ruby 2.7.0 ou mais recente.
* Rails 6 requer Ruby 2.5.0 ou mais recente.
* Rails 5 requer Ruby 2.2.2 ou mais recente.

É uma boa ideia atualizar o Ruby e o Rails separadamente. Atualize primeiro para a versão mais recente do Ruby que você puder e depois atualize o Rails.

### O Processo de Atualização

Ao alterar as versões do Rails, é melhor avançar lentamente, uma versão menor de cada vez, para aproveitar ao máximo os avisos de depreciação. Os números de versão do Rails têm a forma Major.Minor.Patch. As versões Major e Minor podem fazer alterações na API pública, o que pode causar erros em sua aplicação. As versões Patch incluem apenas correções de bugs e não alteram nenhuma API pública.

O processo deve seguir da seguinte forma:

1. Escreva testes e certifique-se de que eles passem.
2. Avance para a versão de patch mais recente após a sua versão atual.
3. Corrija testes e recursos obsoletos.
4. Avance para a versão de patch mais recente da próxima versão menor.

Repita esse processo até alcançar a versão desejada do Rails.

#### Movendo entre versões

Para mover entre versões:

1. Altere o número da versão do Rails no `Gemfile` e execute `bundle update`.
2. Altere as versões dos pacotes JavaScript do Rails no `package.json` e execute `yarn install`, se estiver usando o Webpacker.
3. Execute a [tarefa de atualização](#a-tarefa-de-atualizacao).
4. Execute seus testes.

Você pode encontrar uma lista de todos os gems do Rails lançados [aqui](https://rubygems.org/gems/rails/versions).

### A Tarefa de Atualização

O Rails fornece o comando `rails app:update`. Após atualizar a versão do Rails no `Gemfile`, execute este comando.
Isso ajudará na criação de novos arquivos e alterações nos arquivos antigos em uma sessão interativa.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

Não se esqueça de revisar as diferenças para ver se houve alguma alteração inesperada.

### Configurar Padrões do Framework

A nova versão do Rails pode ter padrões de configuração diferentes da versão anterior. No entanto, após seguir os passos descritos acima, sua aplicação ainda será executada com os padrões de configuração da *versão anterior* do Rails. Isso ocorre porque o valor de `config.load_defaults` em `config/application.rb` ainda não foi alterado.

Para permitir que você atualize para os novos padrões gradualmente, a tarefa de atualização criou um arquivo `config/initializers/new_framework_defaults_X.Y.rb` (com a versão desejada do Rails no nome do arquivo). Você deve habilitar os novos padrões de configuração descomentando-os no arquivo; isso pode ser feito gradualmente ao longo de várias implantações. Assim que sua aplicação estiver pronta para ser executada com os novos padrões, você pode remover este arquivo e alterar o valor de `config.load_defaults`.

Atualizando do Rails 7.0 para o Rails 7.1
-------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 7.1, consulte as [notas de lançamento](7_1_release_notes.html).

### Os caminhos carregados automaticamente não estão mais no caminho de carregamento

A partir do Rails 7.1, todos os caminhos gerenciados pelo carregador automático não serão mais adicionados ao `$LOAD_PATH`.
Isso significa que não será possível carregá-los com uma chamada manual de `require`, a classe ou módulo pode ser referenciado diretamente.

Reduzir o tamanho do `$LOAD_PATH` acelera as chamadas de `require` para aplicativos que não usam `bootsnap` e reduz o
tamanho do cache do `bootsnap` para os outros.
### `ActiveStorage::BaseController` não inclui mais a preocupação com streaming

Controladores de aplicativos que herdam de `ActiveStorage::BaseController` e usam streaming para implementar lógica personalizada de servir arquivos agora devem incluir explicitamente o módulo `ActiveStorage::Streaming`.

### `MemCacheStore` e `RedisCacheStore` agora usam pooling de conexão por padrão

A gem `connection_pool` foi adicionada como uma dependência da gem `activesupport`,
e o `MemCacheStore` e `RedisCacheStore` agora usam pooling de conexão por padrão.

Se você não deseja usar pooling de conexão, defina a opção `:pool` como `false` ao configurar o armazenamento em cache:

```ruby
config.cache_store = :mem_cache_store, "cache.example.com", pool: false
```

Consulte o guia [caching with Rails](https://guides.rubyonrails.org/v7.1/caching_with_rails.html#connection-pool-options) para obter mais informações.

### `SQLite3Adapter` agora está configurado para ser usado em modo estrito de strings

O uso de um modo estrito de strings desativa literais de string entre aspas duplas.

O SQLite tem algumas peculiaridades em relação a literais de string entre aspas duplas.
Ele primeiro tenta considerar as strings entre aspas duplas como nomes de identificadores, mas se eles não existirem
ele então as considera como literais de string. Por causa disso, erros de digitação podem passar despercebidos.
Por exemplo, é possível criar um índice para uma coluna que não existe.
Consulte a [documentação do SQLite](https://www.sqlite.org/quirks.html#double_quoted_string_literals_are_accepted) para mais detalhes.

Se você não deseja usar o `SQLite3Adapter` em modo estrito, você pode desabilitar esse comportamento:

```ruby
# config/application.rb
config.active_record.sqlite3_adapter_strict_strings_by_default = false
```

### Suporte a vários caminhos de visualização para `ActionMailer::Preview`

A opção `config.action_mailer.preview_path` está obsoleta em favor de `config.action_mailer.preview_paths`. Adicionar caminhos a essa opção de configuração fará com que esses caminhos sejam usados na busca por visualizações de mailer.

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### `config.i18n.raise_on_missing_translations = true` agora gera um erro em qualquer tradução ausente.

Anteriormente, ele só gerava um erro quando chamado em uma visualização ou controlador. Agora ele gera um erro sempre que `I18n.t` recebe uma chave não reconhecida.

```ruby
# com config.i18n.raise_on_missing_translations = true

# em uma visualização ou controlador:
t("missing.key") # gera erro na versão 7.0, gera erro na versão 7.1
I18n.t("missing.key") # não gerava erro na versão 7.0, gera erro na versão 7.1

# em qualquer lugar:
I18n.t("missing.key") # não gerava erro na versão 7.0, gera erro na versão 7.1
```

Se você não deseja esse comportamento, você pode definir `config.i18n.raise_on_missing_translations = false`:

```ruby
# com config.i18n.raise_on_missing_translations = false

# em uma visualização ou controlador:
t("missing.key") # não gerava erro na versão 7.0, não gera erro na versão 7.1
I18n.t("missing.key") # não gerava erro na versão 7.0, não gera erro na versão 7.1

# em qualquer lugar:
I18n.t("missing.key") # não gerava erro na versão 7.0, não gera erro na versão 7.1
```

Alternativamente, você pode personalizar o `I18n.exception_handler`.
Consulte o guia [i18n](https://guides.rubyonrails.org/v7.1/i18n.html#using-different-exception-handlers) para obter mais informações.

Atualizando do Rails 6.1 para o Rails 7.0
-------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 7.0, consulte as [notas de lançamento](7_0_release_notes.html).

### O comportamento de `ActionView::Helpers::UrlHelper#button_to` foi alterado

A partir do Rails 7.0, `button_to` renderiza uma tag `form` com o verbo HTTP `patch` se um objeto Active Record persistido for usado para construir a URL do botão.
Para manter o comportamento atual, considere passar explicitamente a opção `method:`:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

ou usando um helper para construir a URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

Se o seu aplicativo usa o Spring, ele precisa ser atualizado para pelo menos a versão 3.0.0. Caso contrário, você receberá

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

Além disso, verifique se [`config.cache_classes`][] está definido como `false` em `config/environments/test.rb`.


### Sprockets agora é uma dependência opcional

A gem `rails` não depende mais do `sprockets-rails`. Se o seu aplicativo ainda precisa usar o Sprockets,
certifique-se de adicionar `sprockets-rails` ao seu Gemfile.

```ruby
gem "sprockets-rails"
```

### Os aplicativos precisam ser executados no modo `zeitwerk`

Os aplicativos que ainda estão sendo executados no modo `classic` precisam mudar para o modo `zeitwerk`. Consulte o guia [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/v7.0/classic_to_zeitwerk_howto.html) para obter detalhes.

### O setter `config.autoloader=` foi excluído

No Rails 7, não há ponto de configuração para definir o modo de carregamento automático, `config.autoloader=` foi excluído. Se você o tinha definido como `:zeitwerk` por qualquer motivo, basta removê-lo.

### A API privada de `ActiveSupport::Dependencies` foi excluída

A API privada de `ActiveSupport::Dependencies` foi excluída. Isso inclui métodos como `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism` e muitos outros.

Alguns destaques:

* Se você usou `ActiveSupport::Dependencies.constantize` ou `ActiveSupport::Dependencies.safe_constantize`, basta substituí-los por `String#constantize` ou `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # NÃO É MAIS POSSÍVEL
  "User".constantize # 👍
  ```

* Qualquer uso de `ActiveSupport::Dependencies.mechanism`, leitor ou gravador, deve ser substituído acessando `config.cache_classes` de acordo.

* Se você deseja rastrear a atividade do carregador automático, `ActiveSupport::Dependencies.verbose=` não está mais disponível, basta adicionar `Rails.autoloaders.log!` em `config/application.rb`.
Classes ou módulos internos auxiliares também foram removidos, como `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable` e outros.

### Carregamento automático durante a inicialização

Aplicações que carregavam constantes recarregáveis durante a inicialização fora dos blocos `to_prepare` tiveram essas constantes descarregadas e receberam um aviso desde o Rails 6.0:

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Ser capaz de fazer isso está obsoleto. O carregamento automático durante a inicialização será uma condição de erro em versões futuras do Rails.

...
```

Se você ainda receber esse aviso nos logs, verifique a seção sobre carregamento automático quando a aplicação é inicializada no [guia de carregamento automático](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots). Caso contrário, você receberá um `NameError` no Rails 7.

### Capacidade de configurar `config.autoload_once_paths`

[`config.autoload_once_paths`][] pode ser definido no corpo da classe de aplicação definida em `config/application.rb` ou na configuração para ambientes em `config/environments/*`.

Da mesma forma, os engines podem configurar essa coleção no corpo da classe do engine ou na configuração para ambientes.

Depois disso, a coleção é congelada e você pode carregar automaticamente a partir desses caminhos. Em particular, você pode carregar automaticamente a partir deles durante a inicialização. Eles são gerenciados pelo carregador automático `Rails.autoloaders.once`, que não recarrega, apenas carrega automaticamente/carrega antecipadamente.

Se você configurou essa configuração após a configuração dos ambientes ter sido processada e está recebendo `FrozenError`, por favor, apenas mova o código.


### `ActionDispatch::Request#content_type` agora retorna o cabeçalho Content-Type como está.

Anteriormente, o valor retornado por `ActionDispatch::Request#content_type` NÃO continha a parte de conjunto de caracteres (charset).
Esse comportamento foi alterado para retornar o cabeçalho Content-Type contendo a parte de conjunto de caracteres como está.

Se você deseja apenas o tipo MIME, use `ActionDispatch::Request#media_type` em vez disso.

Antes:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

Depois:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### Mudança na classe de digest do gerador de chaves requer um rotator de cookies

A classe de digest padrão para o gerador de chaves está mudando de SHA1 para SHA256.
Isso tem consequências em qualquer mensagem criptografada gerada pelo Rails, incluindo
cookies criptografados.

Para poder ler mensagens usando a classe de digest antiga, é necessário
registrar um rotator. Não fazer isso pode resultar em usuários tendo suas sessões
invalidadas durante a atualização.

A seguir, um exemplo de rotator para os cookies criptografados e assinados.

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    authenticated_encrypted_cookie_salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_cookie_salt = Rails.application.config.action_dispatch.signed_cookie_salt

    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len

    old_encrypted_secret = key_generator.generate_key(authenticated_encrypted_cookie_salt, key_len)
    old_signed_secret = key_generator.generate_key(signed_cookie_salt)

    cookies.rotate :encrypted, old_encrypted_secret
    cookies.rotate :signed, old_signed_secret
  end
end
```

### Mudança na classe de digest para ActiveSupport::Digest para SHA256

A classe de digest padrão para ActiveSupport::Digest está mudando de SHA1 para SHA256.
Isso tem consequências para coisas como Etags que serão alteradas e chaves de cache também.
Alterar essas chaves pode ter impacto nas taxas de acerto do cache, então tenha cuidado e fique atento
a isso ao atualizar para o novo hash.

### Novo formato de serialização do ActiveSupport::Cache

Um formato de serialização mais rápido e compacto foi introduzido.

Para ativá-lo, você deve definir `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

Ou simplesmente:

```ruby
# config/application.rb

config.load_defaults 7.0
```

No entanto, as aplicações Rails 6.1 não são capazes de ler esse novo formato de serialização,
portanto, para garantir uma atualização tranquila, você deve primeiro implantar sua atualização do Rails 7.0 com
`config.active_support.cache_format_version = 6.1`, e somente quando todos os processos do Rails
forem atualizados, você pode definir `config.active_support.cache_format_version = 7.0`.

O Rails 7.0 é capaz de ler ambos os formatos, portanto, o cache não será invalidado durante a
atualização.

### Geração de imagem de visualização de vídeo do Active Storage

A geração de imagem de visualização de vídeo agora usa a detecção de mudança de cena do FFmpeg para gerar
imagens de visualização mais significativas. Anteriormente, o primeiro quadro do vídeo era usado
e isso causava problemas se o vídeo desvanecesse do preto. Essa mudança requer
o FFmpeg v3.4+.

### Processador de variantes padrão do Active Storage alterado para `:vips`

Para novos aplicativos, a transformação de imagens usará o libvips em vez do ImageMagick. Isso reduzirá
o tempo necessário para gerar variantes, bem como o uso de CPU e memória, melhorando o tempo de resposta
em aplicativos que dependem do Active Storage para servir suas imagens.

A opção `:mini_magick` não está sendo depreciada, então é bom continuar usando-a.

Para migrar um aplicativo existente para o libvips, defina:
```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

Em seguida, você precisará alterar o código de transformação de imagem existente para as macros `image_processing` e substituir as opções do ImageMagick pelas opções do libvips.

#### Substitua o redimensionamento por resize_to_limit

```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

Se você não fizer isso, ao alternar para o vips, verá o seguinte erro: `no implicit conversion to float from string`.

#### Use um array ao recortar

```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

Se você não fizer isso ao migrar para o vips, verá o seguinte erro: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Ajuste os valores de recorte:

O Vips é mais rigoroso do que o ImageMagick quando se trata de recortar:

1. Ele não irá recortar se `x` e/ou `y` forem valores negativos. Por exemplo: `[-10, -10, 100, 100]`
2. Ele não irá recortar se a posição (`x` ou `y`) mais a dimensão do recorte (`width`, `height`) for maior do que a imagem. Por exemplo: uma imagem de 125x125 e um recorte de `[50, 50, 100, 100]`

Se você não fizer isso ao migrar para o vips, verá o seguinte erro: `extract_area: bad extract area`

#### Ajuste a cor de fundo usada para `resize_and_pad`

O Vips usa preto como a cor de fundo padrão para `resize_and_pad`, em vez de branco como o ImageMagick. Corrija isso usando a opção `background`:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Remova qualquer rotação baseada em EXIF

O Vips irá girar automaticamente as imagens usando o valor EXIF ao processar variantes. Se você estava armazenando valores de rotação de fotos enviadas pelo usuário para aplicar a rotação com o ImageMagick, você deve parar de fazer isso:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Substitua monochrome por colourspace

O Vips usa uma opção diferente para criar imagens monocromáticas:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Mude para opções do libvips para comprimir imagens

JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Implante em produção

O Active Storage codifica na URL da imagem a lista de transformações que devem ser realizadas. Se o seu aplicativo estiver armazenando em cache essas URLs, suas imagens serão quebradas após implantar o novo código em produção. Por causa disso, você deve invalidar manualmente as chaves de cache afetadas.

Por exemplo, se você tiver algo assim em uma view:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

Você pode invalidar o cache tocando no produto ou alterando a chave de cache:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### A versão do Rails agora está incluída no despejo do esquema do Active Record

O Rails 7.0 alterou alguns valores padrão para alguns tipos de coluna. Para evitar que aplicativos atualizem da versão 6.1 para 7.0 carreguem o esquema atual usando os novos padrões do 7.0, o Rails agora inclui a versão do framework no despejo do esquema.

Antes de carregar o esquema pela primeira vez no Rails 7.0, certifique-se de executar `rails app:update` para garantir que a versão do esquema seja incluída no despejo do esquema.

O arquivo de esquema ficará assim:

```ruby
# Este arquivo é gerado automaticamente a partir do estado atual do banco de dados. Em vez
# de editar este arquivo, use o recurso de migrações do Active Record para
# modificar incrementalmente seu banco de dados e, em seguida, regenerar essa definição de esquema.
#
# Este arquivo é a fonte que o Rails usa para definir seu esquema ao executar `bin/rails
# db:schema:load`. Ao criar um novo banco de dados, `bin/rails db:schema:load` tende a
# ser mais rápido e potencialmente menos propenso a erros do que executar todas as suas
# migrações do zero. Migrações antigas podem falhar ao serem aplicadas corretamente se essas
# migrações usarem dependências externas ou código de aplicativo.
#
# É altamente recomendável que você verifique este arquivo em seu sistema de controle de versão.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```
NOTA: Na primeira vez em que você despejar o esquema com o Rails 7.0, você verá muitas alterações nesse arquivo, incluindo algumas informações de coluna. Certifique-se de revisar o novo conteúdo do arquivo de esquema e commitá-lo em seu repositório.

Atualizando do Rails 6.0 para o Rails 6.1
-----------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 6.1, consulte as [notas de lançamento](6_1_release_notes.html).

### O valor de retorno de `Rails.application.config_for` não suporta mais acesso com chaves String.

Dado um arquivo de configuração como este:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Anteriormente, isso retornava um hash no qual você poderia acessar valores com chaves String. Isso foi descontinuado na versão 6.0 e agora não funciona mais.

Você pode chamar `with_indifferent_access` no valor de retorno de `config_for` se ainda quiser acessar valores com chaves String, por exemplo:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### O Content-Type da resposta ao usar `respond_to#any`

O cabeçalho Content-Type retornado na resposta pode ser diferente do que o Rails 6.0 retornava, mais especificamente se sua aplicação usa `respond_to { |format| format.any }`. O Content-Type agora será baseado no bloco fornecido em vez do formato da solicitação.

Exemplo:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

O comportamento anterior era retornar um Content-Type de resposta `text/csv`, o que é impreciso, pois está sendo renderizada uma resposta JSON. O comportamento atual retorna corretamente um Content-Type de resposta `application/json`.

Se sua aplicação depende do comportamento anterior incorreto, é recomendável especificar quais formatos sua ação aceita, ou seja:

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` agora recebe um segundo argumento

O Active Support permite substituir o `halted_callback_hook` sempre que um callback interrompe a cadeia. Este método agora recebe um segundo argumento, que é o nome do callback que está sendo interrompido. Se você tiver classes que substituem esse método, certifique-se de que ele aceite dois argumentos. Observe que esta é uma alteração incompatível sem um ciclo de depreciação anterior (por motivos de desempenho).

Exemplo:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Este método agora aceita 2 argumentos em vez de 1
    Rails.logger.info("O livro não pôde ser #{callback_name}ado")
  end
end
```

### O método de classe `helper` nos controladores usa `String#constantize`

Conceitualmente, antes do Rails 6.1

```ruby
helper "foo/bar"
```

resultava em

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Agora, faz o seguinte:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Essa alteração é compatível com versões anteriores para a maioria das aplicações, caso em que você não precisa fazer nada.

Tecnicamente, no entanto, os controladores poderiam configurar `helpers_path` para apontar para um diretório em `$LOAD_PATH` que não estava nos caminhos de carregamento automático. Esse caso de uso não é mais suportado por padrão. Se o módulo helper não puder ser carregado automaticamente, a aplicação é responsável por carregá-lo antes de chamar `helper`.

### A redireção para HTTPS a partir de HTTP agora usará o código de status HTTP 308

O código de status HTTP padrão usado em `ActionDispatch::SSL` ao redirecionar solicitações não GET/HEAD de HTTP para HTTPS foi alterado para `308`, conforme definido em https://tools.ietf.org/html/rfc7538.

### Active Storage agora requer o Image Processing

Ao processar variantes no Active Storage, agora é necessário ter o [gem image_processing](https://github.com/janko/image_processing) incluído em vez de usar diretamente o `mini_magick`. O Image Processing é configurado por padrão para usar o `mini_magick` nos bastidores, portanto, a maneira mais fácil de atualizar é substituir o gem `mini_magick` pelo gem `image_processing` e garantir a remoção do uso explícito de `combine_options`, pois ele não é mais necessário.

Para melhorar a legibilidade, você pode optar por alterar chamadas brutas de `resize` para macros do `image_processing`. Por exemplo, em vez de:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

você pode fazer respectivamente:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

### Nova classe `ActiveModel::Error`

Os erros agora são instâncias de uma nova classe `ActiveModel::Error`, com alterações na API. Algumas dessas alterações podem gerar erros dependendo de como você manipula os erros, enquanto outras exibirão avisos de depreciação para serem corrigidos no Rails 7.0.

Mais informações sobre essa alteração e detalhes sobre as alterações na API podem ser encontradas [neste PR](https://github.com/rails/rails/pull/32313).

Atualizando do Rails 5.2 para o Rails 6.0
-----------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 6.0, consulte as [notas de lançamento](6_0_release_notes.html).

### Usando o Webpacker
[Webpacker](https://github.com/rails/webpacker)
é o compilador JavaScript padrão para o Rails 6. Mas se você estiver atualizando o aplicativo, ele não é ativado por padrão.
Se você quiser usar o Webpacker, inclua-o no seu Gemfile e instale-o:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Forçar SSL

O método `force_ssl` nos controladores foi descontinuado e será removido no
Rails 6.1. É recomendado que você habilite [`config.force_ssl`][] para forçar conexões HTTPS
em todo o seu aplicativo. Se você precisar isentar determinados endpoints
da redireção, você pode usar [`config.ssl_options`][] para configurar esse comportamento.


### Metadados de propósito e expiração agora estão incorporados em cookies assinados e criptografados para aumentar a segurança

Para melhorar a segurança, o Rails incorpora os metadados de propósito e expiração dentro do valor dos cookies assinados ou criptografados.

O Rails pode então impedir ataques que tentem copiar o valor assinado/criptografado
de um cookie e usá-lo como o valor de outro cookie.

Esses novos metadados incorporados tornam esses cookies incompatíveis com versões do Rails anteriores à 6.0.

Se você precisa que seus cookies sejam lidos pelo Rails 5.2 e anteriores, ou ainda está validando sua implantação 6.0 e deseja
poder reverter, defina
`Rails.application.config.action_dispatch.use_cookies_with_metadata` como `false`.

### Todos os pacotes npm foram movidos para o escopo `@rails`

Se você estava carregando anteriormente os pacotes `actioncable`, `activestorage`,
ou `rails-ujs` através do npm/yarn, você precisa atualizar os nomes dessas
dependências antes de poder atualizá-las para `6.0.0`:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Mudanças na API JavaScript do Action Cable

O pacote JavaScript do Action Cable foi convertido de CoffeeScript
para ES2015, e agora publicamos o código-fonte na distribuição npm.

Esta versão inclui algumas mudanças quebradoras em partes opcionais da
API JavaScript do Action Cable:

- A configuração do adaptador WebSocket e do adaptador de registro foi movida
  das propriedades de `ActionCable` para as propriedades de `ActionCable.adapters`.
  Se você está configurando esses adaptadores, você precisará fazer
  essas mudanças:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- Os métodos `ActionCable.startDebugging()` e `ActionCable.stopDebugging()`
  foram removidos e substituídos pela propriedade
  `ActionCable.logger.enabled`. Se você está usando esses métodos, você
  precisará fazer essas mudanças:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` agora retorna o cabeçalho Content-Type sem modificações

Anteriormente, o valor retornado por `ActionDispatch::Response#content_type` NÃO continha a parte do charset.
Esse comportamento foi alterado para incluir a parte do charset que anteriormente era omitida.

Se você deseja apenas o tipo MIME, use `ActionDispatch::Response#media_type` em vez disso.

Antes:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

Depois:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Nova configuração `config.hosts`

O Rails agora possui uma nova configuração `config.hosts` por motivos de segurança. Essa configuração
tem como padrão `localhost` no desenvolvimento. Se você usar outros domínios no desenvolvimento,
você precisa permiti-los da seguinte forma:

```ruby
# config/environments/development.rb

config.hosts << 'dev.myapp.com'
config.hosts << /[a-z0-9-]+\.myapp\.com/ # Opcionalmente, expressões regulares também são permitidas
```

Para outros ambientes, `config.hosts` está vazio por padrão, o que significa que o Rails
não validará o host de forma alguma. Você pode adicioná-los opcionalmente se quiser
validá-lo em produção.

### Autoloading

A configuração padrão para o Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

habilita o modo de carregamento automático `zeitwerk` no CRuby. Nesse modo, o carregamento automático, o recarregamento e o carregamento antecipado são gerenciados pelo [Zeitwerk](https://github.com/fxn/zeitwerk).

Se você estiver usando as configurações padrão de uma versão anterior do Rails, você pode habilitar o zeitwerk da seguinte forma:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### API Pública

Em geral, os aplicativos não precisam usar a API do Zeitwerk diretamente. O Rails configura as coisas de acordo com o contrato existente: `config.autoload_paths`, `config.cache_classes`, etc.

Embora os aplicativos devam aderir a essa interface, o objeto de carregador real do Zeitwerk pode ser acessado como

```ruby
Rails.autoloaders.main
```

Isso pode ser útil se você precisar pré-carregar classes de Herança de Tabela Única (STI) ou configurar um inflector personalizado, por exemplo.

#### Estrutura do Projeto

Se o aplicativo que está sendo atualizado estiver carregando automaticamente corretamente, a estrutura do projeto deve estar em grande parte compatível.

No entanto, o modo `classic` infere nomes de arquivo a partir de nomes de constantes ausentes (`underscore`), enquanto o modo `zeitwerk` infere nomes de constantes a partir de nomes de arquivo (`camelize`). Esses ajudantes nem sempre são inversos um do outro, especialmente se houver acrônimos envolvidos. Por exemplo, `"FOO".underscore` é `"foo"`, mas `"foo".camelize` é `"Foo"`, não `"FOO"`.
A compatibilidade pode ser verificada com a tarefa `zeitwerk:check`:

```bash
$ bin/rails zeitwerk:check
Aguarde, estou carregando a aplicação.
Tudo está bom!
```

#### require_dependency

Todos os casos conhecidos de `require_dependency` foram eliminados, você deve procurar no projeto e excluí-los.

Se sua aplicação usa Herança de Tabela Única, consulte a seção [Herança de Tabela Única](autoloading_and_reloading_constants.html#single-table-inheritance) do guia Autoloading and Reloading Constants (Modo Zeitwerk).

#### Nomes qualificados em definições de classes e módulos

Agora você pode usar caminhos de constantes de forma robusta em definições de classes e módulos:

```ruby
# O carregamento automático no corpo dessa classe agora corresponde à semântica do Ruby.
class Admin::UsersController < ApplicationController
  # ...
end
```

Um detalhe importante a ser observado é que, dependendo da ordem de execução, o carregador automático clássico às vezes poderia carregar automaticamente `Foo::Wadus` em

```ruby
class Foo::Bar
  Wadus
end
```

Isso não corresponde à semântica do Ruby porque `Foo` não está no aninhamento e não funcionará no modo `zeitwerk`. Se você encontrar esse caso específico, pode usar o nome qualificado `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

ou adicionar `Foo` ao aninhamento:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### Concerns

Você pode carregar automaticamente e carregar antecipadamente a partir de uma estrutura padrão como

```
app/models
app/models/concerns
```

Nesse caso, `app/models/concerns` é considerado um diretório raiz (porque pertence aos caminhos de carregamento automático) e é ignorado como namespace. Portanto, `app/models/concerns/foo.rb` deve definir `Foo`, não `Concerns::Foo`.

O namespace `Concerns::` funcionava com o carregador automático clássico como um efeito colateral da implementação, mas na verdade não era um comportamento pretendido. Uma aplicação que usa `Concerns::` precisa renomear essas classes e módulos para poder executar no modo `zeitwerk`.

#### Ter `app` nos caminhos de carregamento automático

Alguns projetos desejam que algo como `app/api/base.rb` defina `API::Base` e adicionam `app` aos caminhos de carregamento automático para realizar isso no modo `classic`. Como o Rails adiciona automaticamente todos os subdiretórios de `app` aos caminhos de carregamento automático, temos outra situação em que existem diretórios raiz aninhados, então essa configuração não funciona mais. O mesmo princípio que explicamos acima com `concerns`.

Se você deseja manter essa estrutura, precisará excluir o subdiretório dos caminhos de carregamento automático em um inicializador:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Constantes carregadas automaticamente e namespaces explícitos

Se um namespace for definido em um arquivo, como `Hotel` aqui:

```
app/models/hotel.rb         # Define Hotel.
app/models/hotel/pricing.rb # Define Hotel::Pricing.
```

a constante `Hotel` deve ser definida usando as palavras-chave `class` ou `module`. Por exemplo:

```ruby
class Hotel
end
```

está correto.

Alternativas como

```ruby
Hotel = Class.new
```

ou

```ruby
Hotel = Struct.new
```

não funcionarão, objetos filhos como `Hotel::Pricing` não serão encontrados.

Essa restrição se aplica apenas a namespaces explícitos. Classes e módulos que não definem um namespace podem ser definidos usando esses idiomas.

#### Um arquivo, uma constante (no mesmo nível superior)

No modo `classic`, tecnicamente você poderia definir várias constantes no mesmo nível superior e todas serem recarregadas. Por exemplo, dado

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

enquanto `Bar` não poderia ser carregado automaticamente, carregar automaticamente `Foo` marcaria `Bar` como carregado automaticamente também. Isso não acontece no modo `zeitwerk`, você precisa mover `Bar` para seu próprio arquivo `bar.rb`. Um arquivo, uma constante.

Isso se aplica apenas a constantes no mesmo nível superior, como no exemplo acima. Classes e módulos internos estão corretos. Por exemplo, considere

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Se a aplicação recarregar `Foo`, também recarregará `Foo::InnerClass`.

#### Spring e o ambiente `test`

O Spring recarrega o código da aplicação se algo for alterado. No ambiente `test`, você precisa habilitar a recarga para que isso funcione:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

Caso contrário, você receberá esse erro:

```
a recarga está desativada porque config.cache_classes é true
```

#### Bootsnap

O Bootsnap deve ser pelo menos na versão 1.4.2.

Além disso, o Bootsnap precisa desabilitar o cache iseq devido a um bug no interpretador se estiver executando o Ruby 2.5. Certifique-se de depender pelo menos do Bootsnap 1.4.4 nesse caso.

#### `config.add_autoload_paths_to_load_path`

O novo ponto de configuração [`config.add_autoload_paths_to_load_path`][] é `true` por padrão para compatibilidade com versões anteriores, mas permite que você opte por não adicionar os caminhos de carregamento automático a `$LOAD_PATH`.

Isso faz sentido na maioria das aplicações, pois você nunca deve exigir um arquivo em `app/models`, por exemplo, e o Zeitwerk usa apenas nomes de arquivo absolutos internamente.
Ao optar por sair, você otimiza as pesquisas em `$LOAD_PATH` (menos diretórios para verificar) e economiza trabalho e consumo de memória do Bootsnap, pois ele não precisa construir um índice para esses diretórios.


#### Segurança de Thread

No modo clássico, o carregamento automático de constantes não é seguro para threads, embora o Rails tenha bloqueios em vigor, por exemplo, para tornar as solicitações da web seguras para threads quando o carregamento automático está habilitado, como é comum no ambiente de desenvolvimento.

O carregamento automático de constantes é seguro para threads no modo `zeitwerk`. Por exemplo, agora você pode carregar automaticamente em scripts multithread executados pelo comando `runner`.

#### Globs em config.autoload_paths

Cuidado com configurações como

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Cada elemento de `config.autoload_paths` deve representar o namespace de nível superior (`Object`) e eles não podem ser aninhados em consequência (com exceção dos diretórios `concerns` explicados acima).

Para corrigir isso, basta remover os wildcards:

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### Carregamento antecipado e carregamento automático são consistentes

No modo `clássico`, se `app/models/foo.rb` define `Bar`, você não poderá carregar automaticamente esse arquivo, mas o carregamento antecipado funcionará porque carrega arquivos recursivamente às cegas. Isso pode ser uma fonte de erros se você testar as coisas primeiro com o carregamento antecipado, a execução poderá falhar mais tarde com o carregamento automático.

No modo `zeitwerk`, ambos os modos de carregamento são consistentes, eles falham e erram nos mesmos arquivos.

#### Como usar o carregador automático clássico no Rails 6

As aplicações podem carregar as configurações padrão do Rails 6 e ainda usar o carregador automático clássico definindo `config.autoloader` desta forma:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Ao usar o Carregador Automático Clássico em uma aplicação Rails 6, é recomendável definir o nível de concorrência como 1 no ambiente de desenvolvimento, para os servidores web e processadores em segundo plano, devido às preocupações com a segurança de threads.

### Mudança no comportamento da atribuição do Active Storage

Com as configurações padrão do Rails 5.2, atribuir a uma coleção de anexos declarados com `has_many_attached` anexa novos arquivos:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Com as configurações padrão do Rails 6.0, atribuir a uma coleção de anexos substitui os arquivos existentes em vez de anexar a eles. Isso corresponde ao comportamento do Active Record ao atribuir a uma associação de coleção:

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` pode ser usado para adicionar novos anexos sem remover os existentes:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Aplicações existentes podem aderir a esse novo comportamento definindo [`config.active_storage.replace_on_assign_to_many`][] como `true`. O comportamento antigo será descontinuado no Rails 7.0 e removido no Rails 7.1.


### Aplicativos de tratamento de exceções personalizados

Cabeçalhos de solicitação `Accept` ou `Content-Type` inválidos agora gerarão uma exceção.
O [`config.exceptions_app`][] padrão trata especificamente esse erro e compensa por ele.
Os aplicativos de exceções personalizados também precisarão lidar com esse erro, caso contrário, essas solicitações farão com que o Rails use o aplicativo de exceções de fallback, que retorna um `500 Internal Server Error`.


Atualizando do Rails 5.1 para o Rails 5.2
-------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 5.2, consulte as [notas de lançamento](5_2_release_notes.html).

### Bootsnap

O Rails 5.2 adiciona o gem bootsnap no [Gemfile do aplicativo recém-gerado](https://github.com/rails/rails/pull/29313).
O comando `app:update` o configura em `boot.rb`. Se você deseja usá-lo, adicione-o ao Gemfile:

```ruby
# Reduz os tempos de inicialização por meio de cache; necessário em config/boot.rb
gem 'bootsnap', require: false
```

Caso contrário, altere o `boot.rb` para não usar o bootsnap.

### O vencimento em cookies assinados ou criptografados agora está incorporado nos valores dos cookies

Para melhorar a segurança, o Rails agora incorpora as informações de vencimento também no valor dos cookies assinados ou criptografados.

Essas novas informações incorporadas tornam esses cookies incompatíveis com versões do Rails anteriores à 5.2.

Se você precisar que seus cookies sejam lidos pelo Rails 5.1 e anteriores, ou se ainda estiver validando sua implantação do Rails 5.2 e quiser permitir o rollback, defina
`Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` como `false`.

Atualizando do Rails 5.0 para o Rails 5.1
-------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 5.1, consulte as [notas de lançamento](5_1_release_notes.html).

### `HashWithIndifferentAccess` de nível superior está obsoleto

Se o seu aplicativo usa a classe `HashWithIndifferentAccess` de nível superior, você
deve mover lentamente seu código para usar `ActiveSupport::HashWithIndifferentAccess` em vez disso.
É apenas uma depreciação suave, o que significa que seu código não será quebrado no momento e nenhuma advertência de depreciação será exibida, mas essa constante será removida no futuro.

Além disso, se você tiver documentos YAML antigos contendo despejos desses objetos, talvez seja necessário carregá-los e despejá-los novamente para garantir que eles façam referência à constante correta e que o carregamento deles não seja quebrado no futuro.

### `application.secrets` agora é carregado com todas as chaves como símbolos

Se sua aplicação armazena configurações aninhadas em `config/secrets.yml`, todas as chaves agora são carregadas como símbolos, então o acesso usando strings deve ser alterado.

De:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

Para:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Suporte deprecado removido para `:text` e `:nothing` em `render`

Se seus controladores estão usando `render :text`, eles não funcionarão mais. O novo método para renderizar texto com o tipo MIME `text/plain` é usar `render :plain`.

Da mesma forma, `render :nothing` também foi removido e você deve usar o método `head` para enviar respostas que contenham apenas cabeçalhos. Por exemplo, `head :ok` envia uma resposta 200 sem corpo para renderizar.

### Suporte deprecado removido para `redirect_to :back`

No Rails 5.0, `redirect_to :back` foi depreciado. No Rails 5.1, ele foi completamente removido.

Como alternativa, use `redirect_back`. É importante observar que `redirect_back` também aceita uma opção `fallback_location` que será usada caso o `HTTP_REFERER` esteja ausente.

```ruby
redirect_back(fallback_location: root_path)
```

Atualizando do Rails 4.2 para o Rails 5.0
-----------------------------------------

Para obter mais informações sobre as alterações feitas no Rails 5.0, consulte as [notas de lançamento](5_0_release_notes.html).

### Ruby 2.2.2+ requerido

A partir do Ruby on Rails 5.0, a versão do Ruby 2.2.2+ é a única versão do Ruby suportada. Certifique-se de estar na versão 2.2.2 do Ruby ou superior antes de prosseguir.

### Modelos Active Record agora herdam de ApplicationRecord por padrão

No Rails 4.2, um modelo Active Record herda de `ActiveRecord::Base`. No Rails 5.0, todos os modelos herdam de `ApplicationRecord`.

`ApplicationRecord` é uma nova superclasse para todos os modelos do aplicativo, análoga aos controladores do aplicativo que herdam de `ApplicationController` em vez de `ActionController::Base`. Isso fornece aos aplicativos um único local para configurar o comportamento do modelo em todo o aplicativo.

Ao atualizar do Rails 4.2 para o Rails 5.0, você precisa criar um arquivo `application_record.rb` em `app/models/` e adicionar o seguinte conteúdo:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Em seguida, certifique-se de que todos os seus modelos herdem dele.

### Interrupção de cadeias de retorno de chamada via `throw(:abort)`

No Rails 4.2, quando um retorno de chamada 'before' retorna `false` no Active Record e no Active Model, toda a cadeia de retorno de chamada é interrompida. Em outras palavras, os retornos de chamada 'before' sucessivos não são executados e a ação não é envolvida em retornos de chamada.

No Rails 5.0, retornar `false` em um retorno de chamada do Active Record ou do Active Model não terá esse efeito colateral de interromper a cadeia de retorno de chamada. Em vez disso, as cadeias de retorno de chamada devem ser explicitamente interrompidas chamando `throw(:abort)`.

Ao atualizar do Rails 4.2 para o Rails 5.0, retornar `false` nesse tipo de retorno de chamada ainda interromperá a cadeia de retorno de chamada, mas você receberá um aviso de depreciação sobre essa mudança futura.

Quando estiver pronto, você pode optar pelo novo comportamento e remover o aviso de depreciação adicionando a seguinte configuração ao seu `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Observe que essa opção não afetará os retornos de chamada do Active Support, pois eles nunca interromperam a cadeia quando qualquer valor era retornado.

Consulte [#17227](https://github.com/rails/rails/pull/17227) para mais detalhes.

### ActiveJob agora herda de ApplicationJob por padrão

No Rails 4.2, um Active Job herda de `ActiveJob::Base`. No Rails 5.0, esse comportamento foi alterado para herdar de `ApplicationJob`.

Ao atualizar do Rails 4.2 para o Rails 5.0, você precisa criar um arquivo `application_job.rb` em `app/jobs/` e adicionar o seguinte conteúdo:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Em seguida, certifique-se de que todas as suas classes de trabalho herdem dele.

Consulte [#19034](https://github.com/rails/rails/pull/19034) para mais detalhes.

### Testes de controladores do Rails

#### Extração de alguns métodos auxiliares para `rails-controller-testing`

`assigns` e `assert_template` foram extraídos para a gem `rails-controller-testing`. Para continuar usando esses métodos em seus testes de controladores, adicione `gem 'rails-controller-testing'` ao seu `Gemfile`.

Se você estiver usando o RSpec para testar, consulte a documentação da gem para obter a configuração extra necessária.

#### Novo comportamento ao fazer upload de arquivos

Se você estiver usando `ActionDispatch::Http::UploadedFile` em seus testes para fazer upload de arquivos, será necessário alterar para usar a classe `Rack::Test::UploadedFile` semelhante.
Veja [#26404](https://github.com/rails/rails/issues/26404) para mais detalhes.

### O Carregamento Automático está Desabilitado Após o Boot no Ambiente de Produção

Agora, por padrão, o carregamento automático está desabilitado após o boot no ambiente de produção.

O carregamento antecipado da aplicação faz parte do processo de boot, então as constantes de nível superior estão bem e ainda são carregadas automaticamente, não é necessário requerer seus arquivos.

As constantes em lugares mais profundos, que só são executadas em tempo de execução, como corpos de métodos regulares, também estão bem, porque o arquivo que as define será carregado antecipadamente durante o boot.

Para a grande maioria das aplicações, essa mudança não requer nenhuma ação. Mas no caso muito raro de sua aplicação precisar do carregamento automático enquanto estiver em execução em produção, defina `Rails.application.config.enable_dependency_loading` como true.

### Serialização XML

`ActiveModel::Serializers::Xml` foi extraído do Rails para a gema `activemodel-serializers-xml`. Para continuar usando a serialização XML em sua aplicação, adicione `gem 'activemodel-serializers-xml'` ao seu `Gemfile`.

### Suporte Removido para o Adaptador de Banco de Dados Legado `mysql`

O Rails 5 remove o suporte para o adaptador de banco de dados legado `mysql`. A maioria dos usuários deve ser capaz de usar o `mysql2` em seu lugar. Ele será convertido em uma gema separada quando encontrarmos alguém para mantê-lo.

### Suporte Removido para o Debugger

O `debugger` não é suportado pelo Ruby 2.2, que é necessário pelo Rails 5. Use o `byebug` em seu lugar.

### Use `bin/rails` para executar tarefas e testes

O Rails 5 adiciona a capacidade de executar tarefas e testes através do `bin/rails` em vez do rake. Geralmente, essas mudanças são paralelas ao rake, mas algumas foram portadas completamente.

Para usar o novo executor de testes, basta digitar `bin/rails test`.

`rake dev:cache` agora é `bin/rails dev:cache`.

Execute `bin/rails` dentro do diretório raiz de sua aplicação para ver a lista de comandos disponíveis.

### `ActionController::Parameters` não herda mais de `HashWithIndifferentAccess`

Chamar `params` em sua aplicação agora retornará um objeto em vez de um hash. Se seus parâmetros já estiverem permitidos, então você não precisará fazer nenhuma alteração. Se você estiver usando `map` e outros métodos que dependem de poder ler o hash independentemente de `permitted?`, você precisará atualizar sua aplicação para primeiro permitir e depois converter para um hash.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` agora tem `prepend: false` como padrão

`protect_from_forgery` agora tem `prepend: false` como padrão, o que significa que ele será inserido na cadeia de chamadas no ponto em que você o chama em sua aplicação. Se você quiser que `protect_from_forgery` sempre seja executado primeiro, então você deve alterar sua aplicação para usar `protect_from_forgery prepend: true`.

### O Manipulador de Template Padrão Agora é RAW

Arquivos sem um manipulador de template em sua extensão serão renderizados usando o manipulador raw. Anteriormente, o Rails renderizava os arquivos usando o manipulador de template ERB.

Se você não quiser que seu arquivo seja tratado pelo manipulador raw, você deve adicionar uma extensão ao seu arquivo que possa ser analisada pelo manipulador de template apropriado.

### Adicionada Correspondência de Curinga para Dependências de Template

Agora você pode usar correspondência de curinga para suas dependências de template. Por exemplo, se você estivesse definindo seus templates da seguinte forma:

```erb
<% # Dependência de Template: recordings/threads/events/subscribers_changed %>
<% # Dependência de Template: recordings/threads/events/completed %>
<% # Dependência de Template: recordings/threads/events/uncompleted %>
```

Agora você pode chamar a dependência apenas uma vez com um curinga.

```erb
<% # Dependência de Template: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` movido para a gema externa (record_tag_helper)

`content_tag_for` e `div_for` foram removidos em favor de apenas usar `content_tag`. Para continuar usando os métodos antigos, adicione a gema `record_tag_helper` ao seu `Gemfile`:

```ruby
gem 'record_tag_helper', '~> 1.0'
```

Veja [#18411](https://github.com/rails/rails/pull/18411) para mais detalhes.

### Suporte Removido para a Gema `protected_attributes`

A gema `protected_attributes` não é mais suportada no Rails 5.

### Suporte Removido para a Gema `activerecord-deprecated_finders`

A gema `activerecord-deprecated_finders` não é mais suportada no Rails 5.

### A Ordem Padrão dos Testes em `ActiveSupport::TestCase` Agora é Aleatória

Quando os testes são executados em sua aplicação, a ordem padrão agora é `:random` em vez de `:sorted`. Use a seguinte opção de configuração para definir de volta para `:sorted`.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` se tornou um `Concern`

Se você incluir `ActionController::Live` em outro módulo que é incluído em seu controlador, então você também deve estender o módulo com `ActiveSupport::Concern`. Alternativamente, você pode usar o gancho `self.included` para incluir `ActionController::Live` diretamente no controlador assim que o `StreamingSupport` for incluído.

Isso significa que se sua aplicação costumava ter seu próprio módulo de streaming, o código a seguir quebraria em produção:
```ruby
# Esta é uma solução alternativa para controladores de streaming que realizam autenticação com Warden/Devise.
# Veja https://github.com/plataformatec/devise/issues/2332
# Autenticar no roteador é outra solução sugerida nessa questão.
class StreamingSupport
  include ActionController::Live # isso não funcionará em produção para o Rails 5
  # extend ActiveSupport::Concern # a menos que você descomente esta linha.

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Novos padrões do framework

#### Opção `belongs_to` obrigatório por padrão no Active Record

`belongs_to` agora irá gerar um erro de validação por padrão se a associação não estiver presente.

Isso pode ser desativado por associação usando `optional: true`.

Essa configuração padrão será automaticamente configurada em novas aplicações. Se uma aplicação existente
desejar adicionar esse recurso, será necessário ativá-lo em um inicializador:

```ruby
config.active_record.belongs_to_required_by_default = true
```

A configuração é global por padrão para todos os modelos, mas você pode
sobrescrevê-la em um modelo específico. Isso deve ajudar a migrar todos os modelos para ter suas
associações obrigatórias por padrão.

```ruby
class Book < ApplicationRecord
  # modelo ainda não está pronto para ter sua associação obrigatória por padrão

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # modelo está pronto para ter sua associação obrigatória por padrão

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### Tokens CSRF por formulário

O Rails 5 agora suporta tokens CSRF por formulário para mitigar ataques de injeção de código com formulários
criados por JavaScript. Com essa opção ativada, os formulários em sua aplicação terão seu
próprio token CSRF específico para a ação e método desse formulário.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Proteção contra falsificação com verificação de origem

Agora você pode configurar sua aplicação para verificar se o cabeçalho HTTP `Origin` deve ser verificado
em relação à origem do site como uma defesa CSRF adicional. Defina o seguinte em sua configuração para
true:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Permitir configuração do nome da fila do Action Mailer

O nome padrão da fila do mailer é `mailers`. Essa opção de configuração permite que você altere globalmente
o nome da fila. Defina o seguinte em sua configuração:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Suporte ao cache de fragmentos nas visualizações do Action Mailer

Defina [`config.action_mailer.perform_caching`][] em sua configuração para determinar se as visualizações do Action Mailer
devem suportar o cache.

```ruby
config.action_mailer.perform_caching = true
```

#### Configurar a saída do `db:structure:dump`

Se você estiver usando `schema_search_path` ou outras extensões do PostgreSQL, você pode controlar como o esquema é
dumped. Defina como `:all` para gerar todos os dumps ou como `:schema_search_path` para gerar a partir do caminho de pesquisa do esquema.

```ruby
config.active_record.dump_schemas = :all
```

#### Configurar opções SSL para habilitar HSTS com subdomínios

Defina o seguinte em sua configuração para habilitar HSTS ao usar subdomínios:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Preservar o fuso horário do receptor

Ao usar o Ruby 2.4, você pode preservar o fuso horário do receptor ao chamar `to_time`.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Mudanças na serialização JSON/JSONB

No Rails 5.0, a forma como os atributos JSON/JSONB são serializados e desserializados mudou. Agora, se
você definir uma coluna igual a uma `String`, o Active Record não mais transformará essa string
em um `Hash` e, em vez disso, retornará apenas a string. Isso não se limita ao código
que interage com modelos, mas também afeta as configurações de coluna `:default` em `db/schema.rb`.
Recomenda-se que você não defina colunas igual a uma `String`, mas passe um `Hash`
em vez disso, que será convertido automaticamente para e de uma string JSON.

Atualizando do Rails 4.1 para o Rails 4.2
-----------------------------------------

### Web Console

Primeiro, adicione `gem 'web-console', '~> 2.0'` ao grupo `:development` em seu `Gemfile` e execute `bundle install` (ele não terá sido incluído quando você atualizou o Rails). Depois de instalado, você pode simplesmente adicionar uma referência ao helper do console (ou seja, `<%= console %>`) em qualquer visualização que você deseja habilitá-lo. Um console também será fornecido em qualquer página de erro que você visualizar em seu ambiente de desenvolvimento.

### Responders

`respond_with` e os métodos `respond_to` em nível de classe foram extraídos para a gem `responders`. Para usá-los, basta adicionar `gem 'responders', '~> 2.0'` ao seu `Gemfile`. Chamadas para `respond_with` e `respond_to` (novamente, em nível de classe) não funcionarão mais sem ter incluído a gem `responders` em suas dependências:
```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

O `respond_to` de nível de instância não é afetado e não requer a gem adicional:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

Veja [#16526](https://github.com/rails/rails/pull/16526) para mais detalhes.

### Tratamento de erros em callbacks de transação

Atualmente, o Active Record suprime erros levantados dentro dos callbacks `after_rollback` ou `after_commit` e apenas os imprime nos logs. Na próxima versão, esses erros não serão mais suprimidos. Em vez disso, os erros serão propagados normalmente, assim como em outros callbacks do Active Record.

Quando você define um callback `after_rollback` ou `after_commit`, você receberá um aviso de depreciação sobre essa mudança futura. Quando estiver pronto, você pode optar pelo novo comportamento e remover o aviso de depreciação adicionando a seguinte configuração ao seu `config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Veja [#14488](https://github.com/rails/rails/pull/14488) e
[#16537](https://github.com/rails/rails/pull/16537) para mais detalhes.

### Ordenação dos casos de teste

No Rails 5.0, os casos de teste serão executados em ordem aleatória por padrão. Em antecipação a essa mudança, o Rails 4.2 introduziu uma nova opção de configuração `active_support.test_order` para especificar explicitamente a ordem dos testes. Isso permite que você mantenha o comportamento atual definindo a opção como `:sorted`, ou opte pelo comportamento futuro definindo a opção como `:random`.

Se você não especificar um valor para essa opção, um aviso de depreciação será emitido. Para evitar isso, adicione a seguinte linha ao seu ambiente de teste:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # ou `:random` se preferir
end
```

### Atributos serializados

Ao usar um codificador personalizado (por exemplo, `serialize :metadata, JSON`), atribuir `nil` a um atributo serializado irá salvá-lo no banco de dados como `NULL`, em vez de passar o valor `nil` pelo codificador (por exemplo, `"null"` ao usar o codificador `JSON`).

### Nível de log de produção

No Rails 5, o nível de log padrão para o ambiente de produção será alterado para `:debug` (de `:info`). Para preservar o padrão atual, adicione a seguinte linha ao seu `production.rb`:

```ruby
# Defina como `:info` para corresponder ao padrão atual, ou defina como `:debug` para optar pelo padrão futuro.
config.log_level = :info
```

### `after_bundle` nos templates do Rails

Se você tiver um template do Rails que adiciona todos os arquivos ao controle de versão, ele falhará ao adicionar os binstubs gerados porque é executado antes do Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Agora você pode envolver as chamadas `git` em um bloco `after_bundle`. Ele será executado após a geração dos binstubs.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails HTML Sanitizer

Há uma nova opção para sanitizar fragmentos HTML em suas aplicações. A abordagem antiga do html-scanner agora está oficialmente em desuso em favor do [`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Isso significa que os métodos `sanitize`, `sanitize_css`, `strip_tags` e `strip_links` são suportados por uma nova implementação.

Esse novo sanitizador usa o [Loofah](https://github.com/flavorjones/loofah) internamente. O Loofah, por sua vez, usa o Nokogiri, que envolve analisadores XML escritos em C e Java, então a sanitização deve ser mais rápida, independentemente da versão do Ruby que você estiver executando.

A nova versão atualiza o `sanitize`, para que ele possa receber um `Loofah::Scrubber` para uma limpeza poderosa.
[Veja alguns exemplos de scrubbers aqui](https://github.com/flavorjones/loofah#loofahscrubber).

Dois novos scrubbers também foram adicionados: `PermitScrubber` e `TargetScrubber`.
Leia o [readme da gem](https://github.com/rails/rails-html-sanitizer) para mais informações.

A documentação para `PermitScrubber` e `TargetScrubber` explica como você pode ter controle completo sobre quando e como os elementos devem ser removidos.

Se sua aplicação precisar usar a implementação antiga do sanitizador, inclua `rails-deprecated_sanitizer` em seu `Gemfile`:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Rails DOM Testing

O módulo [`TagAssertions`](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (que contém métodos como `assert_tag`) [foi depreciado](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) em favor dos métodos `assert_select` do módulo `SelectorAssertions`, que foi extraído para a [gem rails-dom-testing](https://github.com/rails/rails-dom-testing).

### Masked Authenticity Tokens

Para mitigar ataques SSL, o `form_authenticity_token` agora é mascarado para variar a cada requisição. Assim, os tokens são validados desmascarando e depois descriptografando. Como resultado, qualquer estratégia para verificar requisições de formulários não-Rails que dependia de um token CSRF de sessão estático precisa levar isso em consideração.
### Action Mailer

Anteriormente, chamar um método de mailer em uma classe de mailer resultaria na execução direta do método de instância correspondente. Com a introdução do Active Job e `#deliver_later`, isso não é mais verdade. No Rails 4.2, a invocação dos métodos de instância é adiada até que `deliver_now` ou `deliver_later` seja chamado. Por exemplo:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Chamado"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify ainda não é chamado neste ponto
mail = mail.deliver_now           # Imprime "Chamado"
```

Isso não deve resultar em nenhuma diferença perceptível para a maioria das aplicações. No entanto, se você precisar que alguns métodos não-mailer sejam executados de forma síncrona e estava contando com o comportamento de proxy síncrono anterior, você deve defini-los como métodos de classe diretamente na classe de mailer:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Suporte a Chave Estrangeira

A DSL de migração foi expandida para suportar definições de chave estrangeira. Se você estava usando a gem Foreigner, pode considerar removê-la. Observe que o suporte a chave estrangeira do Rails é um subconjunto do Foreigner. Isso significa que nem toda definição do Foreigner pode ser totalmente substituída por sua contraparte na DSL de migração do Rails.

O procedimento de migração é o seguinte:

1. Remova `gem "foreigner"` do `Gemfile`.
2. Execute `bundle install`.
3. Execute `bin/rake db:schema:dump`.
4. Verifique se `db/schema.rb` contém todas as definições de chave estrangeira com as opções necessárias.

Atualizando do Rails 4.0 para o Rails 4.1
-------------------------------------

### Proteção CSRF de tags `<script>` remotas

Ou, "o quê, meus testes estão falhando!!?" ou "meu widget `<script>` está quebrado!!"

A proteção contra falsificação de solicitação entre sites (CSRF) agora também cobre solicitações GET com respostas JavaScript. Isso impede que um site de terceiros faça referência remota ao seu JavaScript com uma tag `<script>` para extrair dados sensíveis.

Isso significa que seus testes funcionais e de integração que usam

```ruby
get :index, format: :js
```

agora acionarão a proteção CSRF. Mude para

```ruby
xhr :get, :index, format: :js
```

para testar explicitamente uma `XmlHttpRequest`.

NOTA: Suas próprias tags `<script>` também são tratadas como de origem cruzada e bloqueadas por padrão. Se você realmente deseja carregar JavaScript de tags `<script>`, agora deve explicitamente pular a proteção CSRF nessas ações.

### Spring

Se você deseja usar o Spring como seu pré-carregador de aplicativo, você precisa:

1. Adicionar `gem 'spring', group: :development` ao seu `Gemfile`.
2. Instalar o spring usando `bundle install`.
3. Gerar o binstub do Spring com `bundle exec spring binstub`.

NOTA: As tarefas rake definidas pelo usuário serão executadas no ambiente `development` por padrão. Se você deseja que elas sejam executadas em outros ambientes, consulte o [README do Spring](https://github.com/rails/spring#rake).

### `config/secrets.yml`

Se você deseja usar a nova convenção `secrets.yml` para armazenar os segredos da sua aplicação, você precisa:

1. Criar um arquivo `secrets.yml` na pasta `config` com o seguinte conteúdo:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Use a sua `secret_key_base` existente do inicializador `secret_token.rb` para definir a variável de ambiente `SECRET_KEY_BASE` para os usuários que executam a aplicação Rails em produção. Alternativamente, você pode simplesmente copiar a `secret_key_base` existente do inicializador `secret_token.rb` para o `secrets.yml` na seção `production`, substituindo `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Remova o inicializador `secret_token.rb`.

4. Use `rake secret` para gerar novas chaves para as seções `development` e `test`.

5. Reinicie o servidor.

### Mudanças no helper de teste

Se o seu helper de teste contém uma chamada para `ActiveRecord::Migration.check_pending!`, isso pode ser removido. A verificação agora é feita automaticamente quando você `require "rails/test_help"`, embora deixar essa linha no seu helper não seja prejudicial de forma alguma.

### Serializador de cookies

Aplicações criadas antes do Rails 4.1 usam `Marshal` para serializar os valores dos cookies nos jars de cookies assinados e criptografados. Se você deseja usar o novo formato baseado em `JSON` em sua aplicação, você pode adicionar um arquivo de inicialização com o seguinte conteúdo:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

Isso migrará automaticamente seus cookies serializados com `Marshal` para o novo formato baseado em `JSON`.

Ao usar o serializador `:json` ou `:hybrid`, você deve estar ciente de que nem todos os objetos Ruby podem ser serializados como JSON. Por exemplo, objetos `Date` e `Time` serão serializados como strings, e `Hash`es terão suas chaves convertidas em strings.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```
É aconselhável armazenar apenas dados simples (strings e números) em cookies.
Se você precisar armazenar objetos complexos, será necessário lidar com a conversão
manualmente ao ler os valores em solicitações subsequentes.

Se você usar o armazenamento de sessão em cookie, isso também se aplicará ao hash `session` e
`flash`.

### Mudanças na estrutura do Flash

As chaves das mensagens do Flash são
[normalizadas para strings](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). Elas
ainda podem ser acessadas usando símbolos ou strings. Percorrer o flash
sempre retornará chaves em formato de string:

```ruby
flash["string"] = "uma string"
flash[:symbol] = "um símbolo"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

Certifique-se de comparar as chaves das mensagens do Flash com strings.

### Mudanças no tratamento de JSON

Existem algumas mudanças importantes relacionadas ao tratamento de JSON no Rails 4.1.

#### Remoção do MultiJSON

O MultiJSON chegou ao seu [fim de vida](https://github.com/rails/rails/pull/10576)
e foi removido do Rails.

Se sua aplicação atualmente depende diretamente do MultiJSON, você tem algumas opções:

1. Adicione 'multi_json' ao seu `Gemfile`. Observe que isso pode deixar de funcionar no futuro.

2. Migre para longe do MultiJSON usando `obj.to_json` e `JSON.parse(str)`.

ATENÇÃO: Não substitua simplesmente `MultiJson.dump` e `MultiJson.load` por
`JSON.dump` e `JSON.load`. Essas APIs de gem JSON são destinadas à serialização e
desserialização de objetos Ruby arbitrários e geralmente são [inseguras](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### Compatibilidade com a gem JSON

Historicamente, o Rails tinha alguns problemas de compatibilidade com a gem JSON. Usar
`JSON.generate` e `JSON.dump` dentro de uma aplicação Rails poderia produzir
erros inesperados.

O Rails 4.1 corrigiu esses problemas isolando seu próprio codificador da gem JSON. As
APIs da gem JSON funcionarão normalmente, mas não terão acesso a nenhuma
funcionalidade específica do Rails. Por exemplo:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### Novo codificador JSON

O codificador JSON no Rails 4.1 foi reescrito para aproveitar a gem JSON. Para a maioria das aplicações, isso deve ser uma mudança transparente. No entanto, como
parte da reescrita, as seguintes funcionalidades foram removidas do codificador:

1. Detecção de estruturas de dados circulares
2. Suporte ao gancho `encode_json`
3. Opção para codificar objetos `BigDecimal` como números em vez de strings

Se sua aplicação depende de uma dessas funcionalidades, você pode recuperá-las
adicionando a gem [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder)
ao seu `Gemfile`.

#### Representação JSON de objetos Time

`#as_json` para objetos com componente de tempo (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)
agora retorna precisão de milissegundos por padrão. Se você precisar manter o comportamento antigo sem precisão de milissegundos,
defina o seguinte em um inicializador:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### Uso de `return` dentro de blocos de retorno de chamada inline

Anteriormente, o Rails permitia que blocos de retorno de chamada inline usassem `return` desta forma:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # RUIM
end
```

Esse comportamento nunca foi intencionalmente suportado. Devido a uma mudança nas entranhas
de `ActiveSupport::Callbacks`, isso não é mais permitido no Rails 4.1. Usar um
comando `return` em um bloco de retorno de chamada inline causa um `LocalJumpError`
ser lançado quando o retorno de chamada é executado.

Blocos de retorno de chamada inline usando `return` podem ser refatorados para avaliar o
valor retornado:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # BOM
end
```

Alternativamente, se `return` for preferido, é recomendável definir explicitamente
um método:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # BOM

  private
    def before_save_callback
      false
    end
end
```

Essa mudança se aplica à maioria dos lugares no Rails onde os retornos de chamada são usados, incluindo
retornos de chamada do Active Record e Active Model, bem como filtros no Action
Controller (por exemplo, `before_action`).

Veja [esta solicitação de pull](https://github.com/rails/rails/pull/13271) para mais
detalhes.

### Métodos definidos em fixtures do Active Record

O Rails 4.1 avalia o ERB de cada fixture em um contexto separado, portanto, os métodos auxiliares
definidos em uma fixture não estarão disponíveis em outras fixtures.

Métodos auxiliares usados em várias fixtures devem ser definidos em módulos
incluídos na nova classe de contexto `ActiveRecord::FixtureSet.context_class`, em
`test_helper.rb`.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n forçando locais disponíveis

O Rails 4.1 agora define por padrão a opção I18n `enforce_available_locales` como `true`. Isso
significa que ele garantirá que todos os locais passados para ele devem ser declarados na
lista `available_locales`.
Para desativá-lo (e permitir que o I18n aceite qualquer opção de localidade), adicione a seguinte configuração à sua aplicação:

```ruby
config.i18n.enforce_available_locales = false
```

Observe que essa opção foi adicionada como uma medida de segurança, para garantir que a entrada do usuário não possa ser usada como informações de localidade, a menos que seja previamente conhecida. Portanto, é recomendável não desativar essa opção, a menos que você tenha um motivo forte para fazê-lo.

### Métodos mutadores chamados em Relation

`Relation` não possui mais métodos mutadores como `#map!` e `#delete_if`. Converta para um `Array` chamando `#to_a` antes de usar esses métodos.

Isso visa evitar bugs estranhos e confusão no código que chama métodos mutadores diretamente no `Relation`.

```ruby
# Em vez disso
Author.where(name: 'Hank Moody').compact!

# Agora você precisa fazer isso
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### Mudanças nos Escopos Padrão

Os escopos padrão não são mais substituídos por condições encadeadas.

Nas versões anteriores, quando você definia um `default_scope` em um modelo, ele era substituído por condições encadeadas no mesmo campo. Agora, ele é mesclado como qualquer outro escopo.

Antes:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Depois:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

Para obter o comportamento anterior, é necessário remover explicitamente a condição do `default_scope` usando `unscoped`, `unscope`, `rewhere` ou `except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### Renderizando conteúdo a partir de uma string

O Rails 4.1 introduz as opções `:plain`, `:html` e `:body` para `render`. Essas opções são agora a maneira preferida de renderizar conteúdo baseado em string, pois permite especificar o tipo de conteúdo que você deseja enviar na resposta.

* `render :plain` definirá o tipo de conteúdo como `text/plain`
* `render :html` definirá o tipo de conteúdo como `text/html`
* `render :body` *não* definirá o cabeçalho do tipo de conteúdo.

Do ponto de vista de segurança, se você não espera ter qualquer marcação no corpo da resposta, você deve usar `render :plain`, pois a maioria dos navegadores escapará o conteúdo inseguro na resposta para você.

Estaremos descontinuando o uso de `render :text` em uma versão futura. Portanto, comece a usar as opções mais precisas `:plain`, `:html` e `:body`. O uso de `render :text` pode representar um risco de segurança, pois o conteúdo é enviado como `text/html`.

### Tipos de dados JSON e hstore do PostgreSQL

O Rails 4.1 mapeará as colunas `json` e `hstore` para um `Hash` Ruby com chaves de string. Em versões anteriores, era usado um `HashWithIndifferentAccess`. Isso significa que o acesso por símbolo não é mais suportado. Isso também se aplica a `store_accessors` baseados em colunas `json` ou `hstore`. Certifique-se de usar chaves de string consistentemente.

### Uso explícito de bloco para `ActiveSupport::Callbacks`

O Rails 4.1 agora espera que um bloco explícito seja passado ao chamar `ActiveSupport::Callbacks.set_callback`. Essa mudança decorre do fato de que `ActiveSupport::Callbacks` foi amplamente reescrito para a versão 4.1.

```ruby
# Anteriormente no Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Agora no Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Atualizando do Rails 3.2 para o Rails 4.0
-----------------------------------------

Se sua aplicação está atualmente em uma versão do Rails anterior à 3.2.x, você deve atualizar para o Rails 3.2 antes de tentar atualizar para o Rails 4.0.

As seguintes mudanças são destinadas a atualizar sua aplicação para o Rails 4.0.

### HTTP PATCH
Rails 4 agora usa `PATCH` como o verbo HTTP primário para atualizações quando um recurso RESTful é declarado em `config/routes.rb`. A ação `update` ainda é usada, e as solicitações `PUT` continuarão sendo roteadas para a ação `update` também. Portanto, se você estiver usando apenas as rotas RESTful padrão, nenhuma alteração precisa ser feita:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # Nenhuma alteração necessária; PATCH será preferido, e PUT ainda funcionará.
  end
end
```

No entanto, você precisará fazer uma alteração se estiver usando `form_for` para atualizar um recurso em conjunto com uma rota personalizada usando o método HTTP `PUT`:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Alteração necessária; form_for tentará usar uma rota PATCH inexistente.
  end
end
```

Se a ação não estiver sendo usada em uma API pública e você estiver livre para alterar o método HTTP, você pode atualizar sua rota para usar `patch` em vez de `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

As solicitações `PUT` para `/users/:id` no Rails 4 são roteadas para `update` como estão hoje. Portanto, se você tiver uma API que recebe solicitações PUT reais, ela funcionará. O roteador também roteia as solicitações `PATCH` para `/users/:id` para a ação `update`.

Se a ação estiver sendo usada em uma API pública e você não puder alterar o método HTTP sendo usado, você pode atualizar seu formulário para usar o método `PUT` em vez disso:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Para mais informações sobre PATCH e por que essa alteração foi feita, consulte [este post](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method-for-updates/) no blog do Rails.

#### Uma observação sobre tipos de mídia

As correções para o verbo `PATCH` [especificam que um tipo de mídia 'diff' deve ser usado com `PATCH`](http://www.rfc-editor.org/errata_search.php?rfc=5789). Um formato desse tipo é o [JSON Patch](https://tools.ietf.org/html/rfc6902). Embora o Rails não suporte nativamente o JSON Patch, é fácil adicionar suporte:

```ruby
# no seu controlador:
def update
  respond_to do |format|
    format.json do
      # realizar uma atualização parcial
      @article.update params[:article]
    end

    format.json_patch do
      # realizar uma alteração sofisticada
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Como o JSON Patch foi recentemente transformado em um RFC, ainda não existem muitas bibliotecas Ruby excelentes. O [hana](https://github.com/tenderlove/hana) do Aaron Patterson é uma dessas gemas, mas não tem suporte completo para as últimas alterações na especificação.

### Gemfile

O Rails 4.0 removeu o grupo `assets` do `Gemfile`. Você precisará remover essa linha do seu `Gemfile` ao fazer a atualização. Você também deve atualizar o arquivo de aplicação (em `config/application.rb`):

```ruby
# Requer as gemas listadas no Gemfile, incluindo quaisquer gemas
# que você tenha limitado a :test, :development ou :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

O Rails 4.0 não oferece mais suporte para carregar plugins de `vendor/plugins`. Você deve substituir qualquer plugin extraindo-os para gemas e adicionando-os ao seu `Gemfile`. Se você optar por não transformá-los em gemas, você pode movê-los para, por exemplo, `lib/my_plugin/*` e adicionar um inicializador apropriado em `config/initializers/my_plugin.rb`.

### Active Record

* O Rails 4.0 removeu o mapa de identidade do Active Record, devido a [algumas inconsistências com associações](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Se você o habilitou manualmente em sua aplicação, precisará remover a seguinte configuração que não tem mais efeito: `config.active_record.identity_map`.

* O método `delete` em associações de coleção agora pode receber argumentos `Integer` ou `String` como ids de registros, além de registros, assim como o método `destroy` faz. Anteriormente, ele gerava uma exceção `ActiveRecord::AssociationTypeMismatch` para esses argumentos. A partir do Rails 4.0, o `delete` automaticamente tenta encontrar os registros correspondentes aos ids fornecidos antes de excluí-los.

* No Rails 4.0, quando uma coluna ou tabela é renomeada, os índices relacionados também são renomeados. Se você tiver migrações que renomeiam os índices, eles não serão mais necessários.

* O Rails 4.0 alterou `serialized_attributes` e `attr_readonly` para serem apenas métodos de classe. Você não deve mais usar métodos de instância, pois agora estão obsoletos. Você deve alterá-los para usar métodos de classe, por exemplo, `self.serialized_attributes` para `self.class.serialized_attributes`.

* Ao usar o codificador padrão, atribuir `nil` a um atributo serializado irá salvá-lo no banco de dados como `NULL` em vez de passar o valor `nil` através do YAML (`"--- \n...\n"`).
* O Rails 4.0 removeu o recurso `attr_accessible` e `attr_protected` em favor de Strong Parameters. Você pode usar a [gem Protected Attributes](https://github.com/rails/protected_attributes) para uma atualização tranquila.

* Se você não estiver usando Protected Attributes, pode remover quaisquer opções relacionadas a essa gem, como `whitelist_attributes` ou `mass_assignment_sanitizer`.

* O Rails 4.0 requer que os escopos usem um objeto chamável, como um Proc ou lambda:

    ```ruby
      scope :ativo, -> { where(ativo: true) }
    ```

* O Rails 4.0 deprecia `ActiveRecord::Fixtures` em favor de `ActiveRecord::FixtureSet`.

* O Rails 4.0 deprecia `ActiveRecord::TestCase` em favor de `ActiveSupport::TestCase`.

* O Rails 4.0 deprecia a antiga API de busca baseada em hash. Isso significa que os métodos que anteriormente aceitavam "opções de busca" não o fazem mais. Por exemplo, `Livro.find(:all, conditions: { nome: '1984' })` foi depreciado em favor de `Livro.where(nome: '1984')`.

* Todos os métodos dinâmicos, exceto `find_by_...` e `find_by_...!`, foram depreciados. Veja como lidar com as mudanças:

      * `find_all_by_...`           se torna `where(...)`.
      * `find_last_by_...`          se torna `where(...).last`.
      * `scoped_by_...`             se torna `where(...)`.
      * `find_or_initialize_by_...` se torna `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     se torna `find_or_create_by(...)`.

* Observe que `where(...)` retorna uma relação, não um array como os antigos métodos de busca. Se você precisar de um `Array`, use `where(...).to_a`.

* Esses métodos equivalentes podem não executar o mesmo SQL que a implementação anterior.

* Para reabilitar os antigos métodos de busca, você pode usar a [gem activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders).

* O Rails 4.0 alterou a tabela de junção padrão para relações `has_and_belongs_to_many` para remover o prefixo comum do nome da segunda tabela. Qualquer relacionamento `has_and_belongs_to_many` existente entre modelos com um prefixo comum deve ser especificado com a opção `join_table`. Por exemplo:

    ```ruby
    CategoriaCatalogo < ActiveRecord::Base
      has_and_belongs_to_many :produtos_catalogo, join_table: 'categorias_catalogo_produtos_catalogo'
    end

    ProdutoCatalogo < ActiveRecord::Base
      has_and_belongs_to_many :categorias_catalogo, join_table: 'categorias_catalogo_produtos_catalogo'
    end
    ```

* Observe que o prefixo também leva em consideração os escopos, portanto, os relacionamentos entre `Catalog::Categoria` e `Catalog::Produto` ou `Catalog::Categoria` e `CatalogProduto` precisam ser atualizados da mesma forma.

### Active Resource

O Rails 4.0 extraiu o Active Resource para sua própria gem. Se você ainda precisa desse recurso, pode adicionar a [gem Active Resource](https://github.com/rails/activeresource) no seu `Gemfile`.

### Active Model

* O Rails 4.0 alterou a forma como os erros são anexados com o `ActiveModel::Validations::ConfirmationValidator`. Agora, quando as validações de confirmação falham, o erro será anexado a `:#{attribute}_confirmation` em vez de `attribute`.

* O Rails 4.0 alterou o valor padrão de `ActiveModel::Serializers::JSON.include_root_in_json` para `false`. Agora, Active Model Serializers e objetos Active Record têm o mesmo comportamento padrão. Isso significa que você pode comentar ou remover a seguinte opção no arquivo `config/initializers/wrap_parameters.rb`:

    ```ruby
    # Desabilita o elemento raiz no JSON por padrão.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### Action Pack

* O Rails 4.0 introduz `ActiveSupport::KeyGenerator` e usa isso como base para gerar e verificar cookies assinados (entre outras coisas). Cookies assinados existentes gerados com o Rails 3.x serão atualizados automaticamente se você deixar seu `secret_token` existente no lugar e adicionar o novo `secret_key_base`.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    Observe que você deve esperar para definir `secret_key_base` até que 100% da sua base de usuários esteja no Rails 4.x e você esteja razoavelmente certo de que não precisará reverter para o Rails 3.x. Isso ocorre porque cookies assinados com base no novo `secret_key_base` no Rails 4.x não são compatíveis com versões anteriores do Rails 3.x. Você pode deixar seu `secret_token` existente no lugar, não definir o novo `secret_key_base` e ignorar os avisos de depreciação até ter certeza de que sua atualização está concluída.

    Se você depende da capacidade de aplicativos externos ou JavaScript de ler os cookies de sessão assinados do seu aplicativo Rails (ou cookies assinados em geral), você não deve definir `secret_key_base` até que tenha separado essas preocupações.

* O Rails 4.0 criptografa o conteúdo das sessões baseadas em cookies se `secret_key_base` tiver sido definido. O Rails 3.x assinava, mas não criptografava, o conteúdo das sessões baseadas em cookies. Cookies assinados são "seguros" no sentido de que são verificados como tendo sido gerados pelo seu aplicativo e são à prova de adulteração. No entanto, o conteúdo pode ser visualizado pelos usuários finais, e a criptografia do conteúdo elimina essa ressalva/preocupação sem uma penalidade significativa de desempenho.

    Leia [Pull Request #9978](https://github.com/rails/rails/pull/9978) para obter detalhes sobre a mudança para cookies de sessão criptografados.

* O Rails 4.0 removeu a opção `ActionController::Base.asset_path`. Use o recurso de pipeline de assets.
* Rails 4.0 deprecia a opção `ActionController::Base.page_cache_extension`. Use `ActionController::Base.default_static_extension` em seu lugar.

* Rails 4.0 removeu o cache de ação e página do Action Pack. Você precisará adicionar a gema `actionpack-action_caching` para usar `caches_action` e a gema `actionpack-page_caching` para usar `caches_page` em seus controladores.

* Rails 4.0 removeu o analisador de parâmetros XML. Você precisará adicionar a gema `actionpack-xml_parser` se precisar dessa funcionalidade.

* Rails 4.0 altera a busca padrão de `layout` usando símbolos ou procs que retornam nil. Para obter o comportamento "sem layout", retorne false em vez de nil.

* Rails 4.0 altera o cliente memcached padrão de `memcache-client` para `dalli`. Para atualizar, basta adicionar `gem 'dalli'` ao seu `Gemfile`.

* Rails 4.0 deprecia os métodos `dom_id` e `dom_class` nos controladores (eles ainda funcionam nas views). Você precisará incluir o módulo `ActionView::RecordIdentifier` nos controladores que precisam dessa funcionalidade.

* Rails 4.0 deprecia a opção `:confirm` para o helper `link_to`. Você deve usar um atributo de dados (por exemplo, `data: { confirm: 'Tem certeza?' }`) em vez disso. Essa depreciação também se aplica aos helpers baseados nesse (como `link_to_if` ou `link_to_unless`).

* Rails 4.0 alterou o funcionamento dos métodos `assert_generates`, `assert_recognizes` e `assert_routing`. Agora, todas essas asserções lançam `Assertion` em vez de `ActionController::RoutingError`.

* Rails 4.0 gera um `ArgumentError` se rotas nomeadas conflitantes forem definidas. Isso pode ser acionado por rotas nomeadas explicitamente definidas ou pelo método `resources`. Aqui estão dois exemplos que entram em conflito com rotas nomeadas `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    No primeiro caso, você pode simplesmente evitar usar o mesmo nome para várias rotas. No segundo caso, você pode usar as opções `only` ou `except` fornecidas pelo método `resources` para restringir as rotas criadas, conforme detalhado no [Guia de Roteamento](routing.html#restricting-the-routes-created).

* Rails 4.0 também alterou a forma como as rotas de caracteres unicode são desenhadas. Agora você pode desenhar rotas de caracteres unicode diretamente. Se você já desenha essas rotas, precisará alterá-las, por exemplo:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    se torna

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

* Rails 4.0 exige que rotas usando `match` especifiquem o método de solicitação. Por exemplo:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # se torna
      match '/' => 'root#index', via: :get

      # ou
      get '/' => 'root#index'
    ```

* Rails 4.0 removeu o middleware `ActionDispatch::BestStandardsSupport`, `<!DOCTYPE html>` já aciona o modo de padrões conforme https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85).aspx e o cabeçalho ChromeFrame foi movido para `config.action_dispatch.default_headers`.

    Lembre-se de remover qualquer referência ao middleware de seu código de aplicativo, por exemplo:

    ```ruby
    # Lança uma exceção
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    Verifique também as configurações do ambiente para `config.action_dispatch.best_standards_support` e remova-o se estiver presente.

* Rails 4.0 permite a configuração de cabeçalhos HTTP definindo `config.action_dispatch.default_headers`. Os valores padrão são os seguintes:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    Observe que, se sua aplicação depende do carregamento de determinadas páginas em um `<frame>` ou `<iframe>`, você pode precisar definir explicitamente `X-Frame-Options` como `ALLOW-FROM ...` ou `ALLOWALL`.

* No Rails 4.0, a pré-compilação de assets não copia mais automaticamente assets que não sejam JS/CSS de `vendor/assets` e `lib/assets`. Desenvolvedores de aplicativos e engines Rails devem colocar esses assets em `app/assets` ou configurar [`config.assets.precompile`][].

* No Rails 4.0, `ActionController::UnknownFormat` é lançado quando a ação não lida com o formato da solicitação. Por padrão, a exceção é tratada respondendo com 406 Not Acceptable, mas agora você pode substituir isso. No Rails 3, sempre era retornado 406 Not Acceptable. Sem substituições.

* No Rails 4.0, uma exceção genérica `ActionDispatch::ParamsParser::ParseError` é lançada quando o `ParamsParser` falha ao analisar os parâmetros da solicitação. Você deve resgatar essa exceção em vez da `MultiJson::DecodeError` de baixo nível, por exemplo.

* No Rails 4.0, `SCRIPT_NAME` é aninhado corretamente quando os engines são montados em um aplicativo que é servido a partir de um prefixo de URL. Você não precisa mais definir `default_url_options[:script_name]` para contornar prefixos de URL sobrescritos.

* Rails 4.0 deprecia `ActionController::Integration` em favor de `ActionDispatch::Integration`.
* Rails 4.0 deprecia `ActionController::IntegrationTest` em favor de `ActionDispatch::IntegrationTest`.
* Rails 4.0 deprecia `ActionController::PerformanceTest` em favor de `ActionDispatch::PerformanceTest`.
* Rails 4.0 deprecia `ActionController::AbstractRequest` em favor de `ActionDispatch::Request`.
* Rails 4.0 deprecia `ActionController::Request` em favor de `ActionDispatch::Request`.
* Rails 4.0 deprecia `ActionController::AbstractResponse` em favor de `ActionDispatch::Response`.
* Rails 4.0 deprecia `ActionController::Response` em favor de `ActionDispatch::Response`.
* Rails 4.0 deprecia `ActionController::Routing` em favor de `ActionDispatch::Routing`.
### Active Support

Rails 4.0 remove o alias `j` para `ERB::Util#json_escape` já que `j` já é usado para `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### Cache

O método de cache mudou entre o Rails 3.x e o 4.0. Você deve [mudar o namespace do cache](https://guides.rubyonrails.org/v4.0/caching_with_rails.html#activesupport-cache-store) e lançar com um cache vazio.

### Ordem de Carregamento dos Helpers

A ordem em que os helpers de mais de um diretório são carregados mudou no Rails 4.0. Anteriormente, eles eram coletados e depois classificados em ordem alfabética. Após a atualização para o Rails 4.0, os helpers preservarão a ordem dos diretórios carregados e serão classificados em ordem alfabética apenas dentro de cada diretório. A menos que você use explicitamente o parâmetro `helpers_path`, essa mudança só afetará a forma de carregar os helpers dos engines. Se você depende da ordem, verifique se os métodos corretos estão disponíveis após a atualização. Se você deseja alterar a ordem em que os engines são carregados, pode usar o método `config.railties_order=`.

### Active Record Observer e Action Controller Sweeper

`ActiveRecord::Observer` e `ActionController::Caching::Sweeper` foram extraídos para a gem `rails-observers`. Você precisará adicionar a gem `rails-observers` se precisar desses recursos.

### sprockets-rails

* `assets:precompile:primary` e `assets:precompile:all` foram removidos. Use `assets:precompile` em vez disso.
* A opção `config.assets.compress` deve ser alterada para [`config.assets.js_compressor`][] assim, por exemplo:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```


### sass-rails

* `asset-url` com dois argumentos está obsoleto. Por exemplo: `asset-url("rails.png", image)` se torna `asset-url("rails.png")`.

Atualizando do Rails 3.1 para o Rails 3.2
-------------------------------------

Se sua aplicação está atualmente em qualquer versão do Rails anterior à 3.1.x, você
deve atualizar para o Rails 3.1 antes de tentar atualizar para o Rails 3.2.

As seguintes mudanças são destinadas a atualizar sua aplicação para a versão mais recente
3.2.x do Rails.

### Gemfile

Faça as seguintes mudanças no seu `Gemfile`.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Existem algumas novas configurações que você deve adicionar ao seu ambiente de desenvolvimento:

```ruby
# Levanta exceção na proteção de atribuição em massa para modelos Active Record
config.active_record.mass_assignment_sanitizer = :strict

# Registra o plano de consulta para consultas que levam mais tempo que isso (funciona
# com SQLite, MySQL e PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

A configuração `mass_assignment_sanitizer` também deve ser adicionada ao `config/environments/test.rb`:

```ruby
# Levanta exceção na proteção de atribuição em massa para modelos Active Record
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

O Rails 3.2 deprecia `vendor/plugins` e o Rails 4.0 os removerá completamente. Embora não seja estritamente necessário como parte de uma atualização para o Rails 3.2, você pode começar a substituir qualquer plugin extraindo-os para gems e adicionando-os ao seu `Gemfile`. Se você optar por não torná-los gems, você pode movê-los para, por exemplo, `lib/my_plugin/*` e adicionar um inicializador apropriado em `config/initializers/my_plugin.rb`.

### Active Record

A opção `:dependent => :restrict` foi removida de `belongs_to`. Se você deseja impedir a exclusão do objeto se houver objetos associados, você pode definir `:dependent => :destroy` e retornar `false` após verificar a existência da associação a partir de qualquer um dos callbacks de destruição do objeto associado.

Atualizando do Rails 3.0 para o Rails 3.1
-------------------------------------

Se sua aplicação está atualmente em qualquer versão do Rails anterior à 3.0.x, você deve atualizar para o Rails 3.0 antes de tentar atualizar para o Rails 3.1.

As seguintes mudanças são destinadas a atualizar sua aplicação para o Rails 3.1.12, a última versão 3.1.x do Rails.

### Gemfile

Faça as seguintes mudanças no seu `Gemfile`.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# Necessário para o novo pipeline de assets
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery é a biblioteca JavaScript padrão no Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

O pipeline de assets requer as seguintes adições:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Se sua aplicação estiver usando uma rota "/assets" para um recurso, você pode querer alterar o prefixo usado para assets para evitar conflitos:

```ruby
# Padrão é '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Remova a configuração RJS `config.action_view.debug_rjs = true`.

Adicione essas configurações se você habilitar o pipeline de assets:

```ruby
# Não comprima os assets
config.assets.compress = false

# Expande as linhas que carregam os assets
config.assets.debug = true
```

### config/environments/production.rb

Novamente, a maioria das mudanças abaixo são para o pipeline de assets. Você pode ler mais sobre isso no guia [Asset Pipeline](asset_pipeline.html).
```ruby
# Comprimir JavaScripts e CSS
config.assets.compress = true

# Não recorrer ao pipeline de ativos se um ativo pré-compilado estiver faltando
config.assets.compile = false

# Gerar hashes para URLs de ativos
config.assets.digest = true

# Padrão: Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Pré-compilar ativos adicionais (application.js, application.css e todos os não-JS/CSS já estão adicionados)
# config.assets.precompile += %w( admin.js admin.css )

# Forçar todo o acesso ao aplicativo por SSL, usar Strict-Transport-Security e cookies seguros.
# config.force_ssl = true
```

### config/environments/test.rb

Você pode ajudar a testar o desempenho com estas adições ao seu ambiente de teste:

```ruby
# Configurar servidor de ativos estáticos para testes com Cache-Control para desempenho
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Adicione este arquivo com o seguinte conteúdo, se desejar envolver parâmetros em um hash aninhado. Isso está ativado por padrão em novas aplicações.

```ruby
# Certifique-se de reiniciar o servidor quando modificar este arquivo.
# Este arquivo contém configurações para ActionController::ParamsWrapper que
# está ativado por padrão.

# Ativar envolvimento de parâmetros para JSON. Você pode desativar isso definindo :format para um array vazio.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Desativar elemento raiz em JSON por padrão.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Você precisa alterar a chave da sessão para algo novo ou remover todas as sessões:

```ruby
# em config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

ou

```bash
$ bin/rake db:sessions:clear
```

### Remova as opções :cache e :concat nas referências de helpers de ativos nas visualizações

* Com o Asset Pipeline, as opções :cache e :concat não são mais usadas, exclua essas opções de suas visualizações.
[`config.cache_classes`]: configuring.html#config-cache-classes
[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths
[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options
[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path
[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many
[`config.exceptions_app`]: configuring.html#config-exceptions-app
[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching
[`config.assets.precompile`]: configuring.html#config-assets-precompile
[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor
