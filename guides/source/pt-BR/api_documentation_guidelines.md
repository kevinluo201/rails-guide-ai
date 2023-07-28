**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
Diretrizes de Documentação de API
============================

Este guia documenta as diretrizes de documentação de API do Ruby on Rails.

Após ler este guia, você saberá:

* Como escrever prosa eficaz para fins de documentação.
* Diretrizes de estilo para documentar diferentes tipos de código Ruby.

--------------------------------------------------------------------------------

RDoc
----

A documentação de API do Rails é gerada com o [RDoc](https://ruby.github.io/rdoc/). Para gerá-la, certifique-se de estar no diretório raiz do Rails, execute `bundle install` e execute:

```bash
$ bundle exec rake rdoc
```

Os arquivos HTML resultantes podem ser encontrados no diretório ./doc/rdoc.

NOTA: Consulte a [Referência de Marcação do RDoc][RDoc Markup] para obter ajuda com a sintaxe.

Links
-----

A documentação de API do Rails não deve ser visualizada no GitHub e, portanto, os links devem usar a marcação [`link`][RDoc Links] do RDoc em relação à API atual.

Isso ocorre devido às diferenças entre o Markdown do GitHub e o RDoc gerado que é publicado em [api.rubyonrails.org](https://api.rubyonrails.org) e [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org).

Por exemplo, usamos `[link:classes/ActiveRecord/Base.html]` para criar um link para a classe `ActiveRecord::Base` gerada pelo RDoc.

Isso é preferível a URLs absolutas como `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`, que levariam o leitor para fora da versão atual da documentação (por exemplo, edgeapi.rubyonrails.org).

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

Redação
-------

Escreva frases simples e declarativas. A brevidade é uma vantagem: vá direto ao ponto.

Escreva no tempo presente: "Retorna um hash que...", em vez de "Retornou um hash que..." ou "Retornará um hash que...".

Inicie os comentários em maiúsculas. Siga as regras normais de pontuação:

```ruby
# Declara um leitor de atributo com base em uma variável de instância
# com nome interno.
def attr_internal_reader(*attrs)
  # ...
end
```

Comunique ao leitor a maneira atual de fazer as coisas, tanto explicitamente quanto implicitamente. Use os idiomas recomendados na versão mais recente. Reorganize as seções para enfatizar as abordagens preferidas, se necessário, etc. A documentação deve ser um modelo das melhores práticas e do uso canônico e moderno do Rails.

A documentação deve ser breve, mas abrangente. Explore e documente casos extremos. O que acontece se um módulo for anônimo? E se uma coleção estiver vazia? E se um argumento for nulo?

Os nomes corretos dos componentes do Rails têm um espaço entre as palavras, como "Active Support". `ActiveRecord` é um módulo Ruby, enquanto Active Record é um ORM. Toda a documentação do Rails deve se referir consistentemente aos componentes do Rails pelos seus nomes corretos.

Ao se referir a uma "aplicação Rails", em oposição a um "engine" ou "plugin", sempre use "aplicação". Aplicativos Rails não são "serviços", a menos que estejam especificamente discutindo sobre arquitetura orientada a serviços.

Escreva os nomes corretamente: Arel, minitest, RSpec, HTML, MySQL, JavaScript, ERB, Hotwire. Em caso de dúvida, consulte uma fonte autoritativa como a documentação oficial.

Prefira redações que evitem "você" e "seu". Por exemplo, em vez de

```markdown
Se você precisar usar declarações `return` em seus callbacks, é recomendado que você as defina explicitamente como métodos.
```

use este estilo:

```markdown
Se for necessário `return`, é recomendado definir explicitamente um método.
```

Dito isso, ao usar pronomes em referência a uma pessoa hipotética, como "um usuário com um cookie de sessão", pronomes neutros de gênero (they/their/them) devem ser usados. Em vez de:

* ele ou ela... use they.
* ele ou ela... use them.
* dele ou dela... use their.
* dele ou dela... use theirs.
* ele mesmo ou ela mesma... use themselves.

Inglês
-------

Por favor, use o inglês americano (*color*, *center*, *modularize*, etc). Veja [uma lista de diferenças de ortografia entre o inglês americano e britânico aqui](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences).

Vírgula de Oxford
------------

Por favor, use a [vírgula de Oxford](https://en.wikipedia.org/wiki/Serial_comma)
("vermelho, branco e azul", em vez de "vermelho, branco e azul").

Exemplo de Código
------------

Escolha exemplos significativos que retratem e cubram o básico, bem como pontos interessantes ou armadilhas.

Use dois espaços para recuar trechos de código - ou seja, para fins de marcação, dois espaços em relação à margem esquerda. Os exemplos em si devem seguir as [convenções de codificação do Rails](contributing_to_ruby_on_rails.html#follow-the-coding-conventions).

Documentos curtos não precisam de um rótulo explícito "Exemplos" para introduzir trechos; eles seguem apenas os parágrafos:

```ruby
# Converte uma coleção de elementos em uma string formatada,
# chamando +to_s+ em todos os elementos e juntando-os.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

Por outro lado, grandes trechos de documentação estruturada podem ter uma seção separada de "Exemplos":

```ruby
# ==== Exemplos
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
Os resultados das expressões seguem abaixo e são introduzidos por "# => ", alinhados verticalmente:

```ruby
# Para verificar se um número inteiro é par ou ímpar.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

Se uma linha for muito longa, o comentário pode ser colocado na próxima linha:

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

Evite usar métodos de impressão como `puts` ou `p` para esse propósito.

Por outro lado, comentários regulares não usam uma seta:

```ruby
#   polymorphic_url(record)  # mesmo que comment_url(record)
```

### SQL

Ao documentar instruções SQL, o resultado não deve ter `=>` antes da saída.

Por exemplo,

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

Ao documentar o comportamento do IRB, o REPL interativo do Ruby, sempre prefixe os comandos com `irb>` e a saída deve ser prefixada com `=>`.

Por exemplo,

```
# Encontre o cliente com a chave primária (id) 10.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / Linha de Comando

Para exemplos de linha de comando, sempre prefixe o comando com `$`, a saída não precisa ser prefixada com nada.

```
# Execute o seguinte comando:
#   $ bin/rails new zomg
#   ...
```

Booleanos
--------

Em predicados e flags, prefira documentar a semântica booleana em vez de valores exatos.

Quando "true" ou "false" são usados como definidos em Ruby, use fonte regular. Os singletons `true` e `false` precisam de uma fonte de largura fixa. Evite termos como "truthy", Ruby define o que é verdadeiro e falso na linguagem, e, portanto, essas palavras têm um significado técnico e não precisam de substitutos.

Como regra geral, não documente singletons, a menos que seja absolutamente necessário. Isso impede construções artificiais como `!!` ou ternários, permite refatorações e o código não precisa depender dos valores exatos retornados pelos métodos chamados na implementação.

Por exemplo:

```markdown
`config.action_mailer.perform_deliveries` especifica se o email será realmente entregue e é verdadeiro por padrão
```

o usuário não precisa saber qual é o valor padrão real da flag,
e, portanto, documentamos apenas sua semântica booleana.

Um exemplo com um predicado:

```ruby
# Retorna true se a coleção estiver vazia.
#
# Se a coleção foi carregada
# é equivalente a <tt>collection.size.zero?</tt>. Se a
# coleção não foi carregada, é equivalente a
# <tt>!collection.exists?</tt>. Se a coleção ainda não foi
# carregada e você vai buscar os registros de qualquer maneira, é melhor
# verificar <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

A API tem cuidado para não se comprometer com nenhum valor específico, o método tem
semântica de predicado, isso é suficiente.

Nomes de Arquivos
----------

Como regra geral, use nomes de arquivos relativos à raiz da aplicação:

```
config/routes.rb            # SIM
routes.rb                   # NÃO
RAILS_ROOT/config/routes.rb # NÃO
```

Fontes
-----

### Fonte de Largura Fixa

Use fontes de largura fixa para:

* Constantes, em particular nomes de classes e módulos.
* Nomes de métodos.
* Literais como `nil`, `false`, `true`, `self`.
* Símbolos.
* Parâmetros de métodos.
* Nomes de arquivos.

```ruby
class Array
  # Chama +to_param+ em todos os seus elementos e junta o resultado com
  # barras. Isso é usado por +url_for+ no Action Pack.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

ATENÇÃO: Usar `+...+` para fonte de largura fixa só funciona com conteúdo simples como
classes comuns, módulos, nomes de métodos, símbolos, caminhos (com barras diagonais),
etc. Por favor, use `<tt>...</tt>` para todo o resto.

Você pode testar rapidamente a saída do RDoc com o seguinte comando:

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

Por exemplo, código com espaços ou aspas deve usar a forma `<tt>...</tt>`.

### Fonte Regular

Quando "true" e "false" são palavras em inglês em vez de palavras-chave Ruby, use uma fonte regular:

```ruby
# Executa todas as validações dentro do contexto especificado.
# Retorna true se nenhum erro for encontrado, false caso contrário.
#
# Se o argumento for false (o padrão é +nil+), o contexto é
# definido como <tt>:create</tt> se <tt>new_record?</tt> for verdadeiro,
# e como <tt>:update</tt> se não for.
#
# Validações sem a opção <tt>:on</tt> serão executadas
# independentemente do contexto. Validações com alguma opção <tt>:on</tt>
# serão executadas apenas no contexto especificado.
def valid?(context = nil)
  # ...
end
```
Listas de Descrição
-----------------

Em listas de opções, parâmetros, etc., use um hífen entre o item e sua descrição (lê-se melhor do que dois pontos porque normalmente as opções são símbolos):

```ruby
# * <tt>:allow_nil</tt> - Ignora a validação se o atributo for +nil+.
```

A descrição começa com letra maiúscula e termina com um ponto final - é o inglês padrão.

Uma abordagem alternativa, quando você deseja fornecer detalhes adicionais e exemplos, é usar o estilo de seção de opções.

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] é um ótimo exemplo disso.

```ruby
# ==== Opções
#
# [+:expires_at+]
#   A data e hora em que a mensagem expira. Após essa data e hora,
#   a verificação da mensagem falhará.
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24 horas depois...
#     encryptor.decrypt_and_verify(message) # => nil
```


Métodos Gerados Dinamicamente
-----------------------------

Métodos criados com `(module|class)_eval(STRING)` têm um comentário ao lado com uma instância do código gerado. Esse comentário fica a 2 espaços de distância do modelo:

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

Se as linhas resultantes forem muito largas, digamos, 200 colunas ou mais, coloque o comentário acima da chamada:

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

Visibilidade do Método
-----------------

Ao escrever documentação para o Rails, é importante entender a diferença entre a API pública voltada para o usuário e a API interna.

O Rails, como a maioria das bibliotecas, usa a palavra-chave `private` do Ruby para definir a API interna. No entanto, a API pública segue uma convenção ligeiramente diferente. Em vez de assumir que todos os métodos públicos são projetados para consumo do usuário, o Rails usa a diretiva `:nodoc:` para anotar esses tipos de métodos como API interna.

Isso significa que existem métodos no Rails com visibilidade `public` que não são destinados ao consumo do usuário.

Um exemplo disso é `ActiveRecord::Core::ClassMethods#arel_table`:

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # faça alguma mágica...
  end
end
```

Se você pensou: "esse método parece ser um método de classe público para `ActiveRecord::Core`", você está certo. Mas na verdade, a equipe do Rails não quer que os usuários dependam desse método. Então eles o marcam como `:nodoc:` e ele é removido da documentação pública. A razão por trás disso é permitir que a equipe altere esses métodos de acordo com suas necessidades internas em diferentes versões, conforme considerem adequado. O nome desse método pode mudar, ou o valor de retorno, ou toda essa classe pode desaparecer; não há garantia e, portanto, você não deve depender dessa API em seus plugins ou aplicativos. Caso contrário, você corre o risco de quebrar seu aplicativo ou gem ao atualizar para uma versão mais recente do Rails.

Como colaborador, é importante pensar se essa API se destina ao consumo do usuário final. A equipe do Rails está comprometida em não fazer alterações que quebrem a API pública em diferentes versões sem passar por um ciclo completo de depreciação. É recomendável que você use `:nodoc:` em seus métodos/classes internos, a menos que eles já sejam privados (em termos de visibilidade), nesse caso, eles são internos por padrão. Uma vez que a API estabiliza, a visibilidade pode mudar, mas alterar a API pública é muito mais difícil devido à compatibilidade com versões anteriores.

Uma classe ou módulo é marcado com `:nodoc:` para indicar que todos os métodos são API interna e nunca devem ser usados diretamente.

Para resumir, a equipe do Rails usa `:nodoc:` para marcar métodos e classes visíveis publicamente para uso interno; mudanças na visibilidade da API devem ser consideradas cuidadosamente e discutidas em uma solicitação de pull primeiro.

Sobre o Stack do Rails
-------------------------

Ao documentar partes da API do Rails, é importante lembrar de todas as partes que compõem o stack do Rails.

Isso significa que o comportamento pode mudar dependendo do escopo ou contexto do método ou classe que você está tentando documentar.

Em vários lugares, há comportamentos diferentes quando você considera todo o stack, um exemplo disso é `ActionView::Helpers::AssetTagHelper#image_tag`:

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

Embora o comportamento padrão para `#image_tag` seja sempre retornar `/images/icon.png`, levamos em consideração todo o stack do Rails (incluindo o Asset Pipeline) e podemos ver o resultado acima.

Estamos apenas preocupados com o comportamento experimentado ao usar o stack padrão completo do Rails.

Nesse caso, queremos documentar o comportamento do _framework_, e não apenas desse método específico.

Se você tiver alguma dúvida sobre como a equipe do Rails lida com determinada API, não hesite em abrir um chamado ou enviar um patch para o [rastreador de problemas](https://github.com/rails/rails/issues).
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
