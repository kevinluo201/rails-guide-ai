**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Diretrizes do Guia Ruby on Rails
===============================

Este guia documenta as diretrizes para escrever Guias Ruby on Rails. Este guia segue um loop gracioso, servindo-se como exemplo.

Após ler este guia, você saberá:

* Sobre as convenções a serem usadas na documentação do Rails.
* Como gerar guias localmente.

--------------------------------------------------------------------------------

Markdown
-------

Os guias são escritos em [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown). Há uma [documentação abrangente para Markdown](https://daringfireball.net/projects/markdown/syntax), bem como uma [folha de referência](https://daringfireball.net/projects/markdown/basics).

Prólogo
--------

Cada guia deve começar com um texto motivacional no topo (essa é a pequena introdução na área azul). O prólogo deve dizer ao leitor sobre o que é o guia e o que eles aprenderão. Como exemplo, veja o [Guia de Roteamento](routing.html).

Títulos
------

O título de cada guia usa um cabeçalho `h1`; as seções do guia usam cabeçalhos `h2`; as subseções usam cabeçalhos `h3`; etc. Observe que a saída HTML gerada usará tags de cabeçalho começando com `<h2>`.

```markdown
Título do Guia
===========

Seção
-------

### Subseção
```

Ao escrever títulos, capitalize todas as palavras, exceto preposições, conjunções, artigos internos e formas do verbo "ser":

```markdown
#### Afirmações e Testes de Trabalhos dentro de Componentes
#### Pilha de Middleware é um Array
#### Quando os Objetos são Salvos?
```

Use a mesma formatação inline que o texto regular:

```markdown
##### A Opção `:content_type`
```

Link para a API
------------------

Os links para a API (`api.rubyonrails.org`) são processados pelo gerador de guias da seguinte maneira:

Links que incluem uma tag de versão são deixados intactos. Por exemplo

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

não é modificado.

Por favor, use esses links nas notas de lançamento, pois eles devem apontar para a versão correspondente, independentemente do destino gerado.

Se o link não incluir uma tag de versão e os guias de desenvolvimento estiverem sendo gerados, o domínio é substituído por `edgeapi.rubyonrails.org`. Por exemplo,

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se torna

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Se o link não incluir uma tag de versão e os guias de lançamento estiverem sendo gerados, a versão do Rails é injetada. Por exemplo, se estivermos gerando os guias para v5.1.0, o link

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se torna

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Por favor, não faça links para `edgeapi.rubyonrails.org` manualmente.


Diretrizes de Documentação da API
----------------------------

Os guias e a API devem ser coerentes e consistentes quando apropriado. Em particular, estas seções das [Diretrizes de Documentação da API](api_documentation_guidelines.html) também se aplicam aos guias:

* [Redação](api_documentation_guidelines.html#wording)
* [Inglês](api_documentation_guidelines.html#english)
* [Código de Exemplo](api_documentation_guidelines.html#example-code)
* [Nomes de Arquivos](api_documentation_guidelines.html#file-names)
* [Fontes](api_documentation_guidelines.html#fonts)

Guias HTML
-----------

Antes de gerar os guias, certifique-se de ter a versão mais recente do Bundler instalada em seu sistema. Para instalar a versão mais recente do Bundler, execute `gem install bundler`.

Se você já tiver o Bundler instalado, você pode atualizá-lo com `gem update bundler`.

### Geração

Para gerar todos os guias, basta entrar no diretório `guides`, executar `bundle install` e executar:

```bash
$ bundle exec rake guides:generate
```

ou

```bash
$ bundle exec rake guides:generate:html
```

Os arquivos HTML resultantes podem ser encontrados no diretório `./output`.

Para processar `my_guide.md` e nada mais, use a variável de ambiente `ONLY`:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

Por padrão, os guias que não foram modificados não são processados, então `ONLY` raramente é necessário na prática.

Para forçar o processamento de todos os guias, passe `ALL=1`.

Se você quiser gerar guias em um idioma diferente do inglês, você pode mantê-los em um diretório separado em `source` (por exemplo, `source/es`) e usar a variável de ambiente `GUIDES_LANGUAGE`:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

Se você quiser ver todas as variáveis de ambiente que pode usar para configurar o script de geração, execute:

```bash
$ rake
```

### Validação

Por favor, valide o HTML gerado com:

```bash
$ bundle exec rake guides:validate
```

Em particular, os títulos recebem um ID gerado a partir de seu conteúdo e isso muitas vezes leva a duplicatas.

Guias Kindle
-------------

### Geração

Para gerar guias para o Kindle, use a seguinte tarefa rake:

```bash
$ bundle exec rake guides:generate:kindle
```
