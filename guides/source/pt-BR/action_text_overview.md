**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: a4b9132308ed3786777061bd137af660
Visão geral do Action Text
====================

Este guia fornece tudo o que você precisa para começar a lidar com conteúdo de texto rico.

Após ler este guia, você saberá:

* Como configurar o Action Text.
* Como lidar com conteúdo de texto rico.
* Como estilizar conteúdo de texto rico e anexos.

--------------------------------------------------------------------------------

O que é o Action Text?
--------------------

O Action Text traz conteúdo de texto rico e edição para o Rails. Ele inclui o [editor Trix](https://trix-editor.org) que lida com tudo, desde formatação até links, citações, listas, imagens incorporadas e galerias. O conteúdo de texto rico gerado pelo editor Trix é salvo em seu próprio modelo RichText que está associado a qualquer modelo Active Record existente na aplicação. As imagens incorporadas (ou outros anexos) são armazenadas automaticamente usando o Active Storage e associadas ao modelo RichText incluído.

## Trix Comparado a Outros Editores de Texto Rico

A maioria dos editores WYSIWYG são wrappers em torno das APIs `contenteditable` e `execCommand` do HTML, projetadas pela Microsoft para suportar a edição ao vivo de páginas da web no Internet Explorer 5.5 e, eventualmente, engenharia reversa e copiadas por outros navegadores.

Como essas APIs nunca foram totalmente especificadas ou documentadas, e porque os editores de HTML WYSIWYG são enormes em escopo, a implementação de cada navegador tem seu próprio conjunto de bugs e peculiaridades, e os desenvolvedores JavaScript são deixados para resolver as inconsistências.

O Trix evita essas inconsistências tratando o contenteditable como um dispositivo de E/S: quando a entrada chega ao editor, o Trix converte essa entrada em uma operação de edição em seu modelo de documento interno e, em seguida, renderiza novamente esse documento de volta para o editor. Isso dá ao Trix controle completo sobre o que acontece após cada pressionamento de tecla e evita a necessidade de usar o execCommand.

## Instalação

Execute `bin/rails action_text:install` para adicionar o pacote Yarn e copiar a migração necessária. Além disso, você precisa configurar o Active Storage para imagens incorporadas e outros anexos. Consulte o guia [Visão Geral do Active Storage](active_storage_overview.html) para obter mais informações.

NOTA: O Action Text usa relacionamentos polimórficos com a tabela `action_text_rich_texts` para que possa ser compartilhado com todos os modelos que possuem atributos de texto rico. Se seus modelos com conteúdo Action Text usam valores UUID para identificadores, todos os modelos que usam atributos Action Text também precisarão usar valores UUID para seus identificadores exclusivos. A migração gerada para o Action Text também precisará ser atualizada para especificar `type: :uuid` para a linha `references` `:record`.

Após a conclusão da instalação, um aplicativo Rails deve ter as seguintes alterações:

1. Tanto `trix` quanto `@rails/actiontext` devem ser requeridos em seu ponto de entrada JavaScript.

    ```js
    // application.js
    import "trix"
    import "@rails/actiontext"
    ```

2. A folha de estilo `trix` será incluída juntamente com os estilos do Action Text em seu arquivo `application.css`.

## Criando Conteúdo de Texto Rico

Adicione um campo de texto rico a um modelo existente:

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  has_rich_text :content
end
```

ou adicione um campo de texto rico ao criar um novo modelo usando:

```bash
$ bin/rails generate model Message content:rich_text
```

NOTA: você não precisa adicionar um campo `content` à tabela `messages`.

Em seguida, use [`rich_text_area`] para se referir a este campo no formulário do modelo:

```erb
<%# app/views/messages/_form.html.erb %>
<%= form_with model: message do |form| %>
  <div class="field">
    <%= form.label :content %>
    <%= form.rich_text_area :content %>
  </div>
<% end %>
```

E finalmente, exiba o texto rico sanitizado em uma página:

```erb
<%= @message.content %>
```

NOTA: Se houver um recurso anexado dentro do campo `content`, ele pode não ser exibido corretamente, a menos que você tenha o pacote *libvips/libvips42* instalado localmente em sua máquina. Verifique a documentação de instalação deles em [https://www.libvips.org/install.html](https://www.libvips.org/install.html) para saber como obtê-lo.

Para aceitar o conteúdo de texto rico, tudo o que você precisa fazer é permitir o atributo referenciado:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create! params.require(:message).permit(:title, :content)
    redirect_to message
  end
end
```


## Renderizando Conteúdo de Texto Rico

Por padrão, o Action Text renderizará o conteúdo de texto rico dentro de um elemento com a classe `.trix-content`:

```html+erb
<%# app/views/layouts/action_text/contents/_content.html.erb %>
<div class="trix-content">
  <%= yield %>
</div>
```

Elementos com essa classe, assim como o editor Action Text, são estilizados pela folha de estilo [`trix`](https://unpkg.com/trix/dist/trix.css). Para fornecer seus próprios estilos, remova a linha `= require trix` da folha de estilo `app/assets/stylesheets/actiontext.css` criada pelo instalador.

Para personalizar o HTML renderizado em torno do conteúdo de texto rico, edite o layout `app/views/layouts/action_text/contents/_content.html.erb` criado pelo instalador.

Para personalizar o HTML renderizado para imagens incorporadas e outros anexos (conhecidos como blobs), edite o modelo `app/views/active_storage/blobs/_blob.html.erb` criado pelo instalador.
### Renderizando anexos

Além dos anexos enviados através do Active Storage, o Action Text pode incorporar qualquer coisa que possa ser resolvida por um [Signed GlobalID](https://github.com/rails/globalid#signed-global-ids).

O Action Text renderiza elementos `<action-text-attachment>` incorporados resolvendo seu atributo `sgid` em uma instância. Uma vez resolvida, essa instância é passada para o [`render`](https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render). O HTML resultante é incorporado como um descendente do elemento `<action-text-attachment>`.

Por exemplo, considere um modelo `User`:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar
end

user = User.find(1)
user.to_global_id.to_s #=> gid://MyRailsApp/User/1
user.to_signed_global_id.to_s #=> BAh7CEkiCG…
```

Em seguida, considere um conteúdo de texto rico que incorpora um elemento `<action-text-attachment>` que faz referência ao GlobalID assinado da instância `User`:

```html
<p>Olá, <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>.</p>
```

O Action Text resolve o String "BAh7CEkiCG…" para resolver a instância `User`. Em seguida, considere o parcial `users/user` da aplicação:

```html+erb
<%# app/views/users/_user.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

O HTML resultante renderizado pelo Action Text ficaria assim:

```html
<p>Olá, <action-text-attachment sgid="BAh7CEkiCG…"><span><img src="..."> Jane Doe</span></action-text-attachment>.</p>
```

Para renderizar um parcial diferente, defina `User#to_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def to_attachable_partial_path
    "users/attachable"
  end
end
```

Em seguida, declare esse parcial. A instância `User` estará disponível como a variável local do parcial `user`:

```html+erb
<%# app/views/users/_attachable.html.erb %>
<span><%= image_tag user.avatar %> <%= user.name %></span>
```

Se o Action Text não conseguir resolver a instância `User` (por exemplo, se o registro tiver sido excluído), então um parcial de fallback padrão será renderizado.

O Rails fornece um parcial global para anexos ausentes. Este parcial é instalado em sua aplicação em `views/action_text/attachables/missing_attachable` e pode ser modificado se você quiser renderizar HTML diferente.

Para renderizar um parcial de anexo ausente diferente, defina um método de nível de classe `to_missing_attachable_partial_path`:

```ruby
class User < ApplicationRecord
  def self.to_missing_attachable_partial_path
    "users/missing_attachable"
  end
end
```

Em seguida, declare esse parcial.

```html+erb
<%# app/views/users/missing_attachable.html.erb %>
<span>Usuário excluído</span>
```

Para integrar com a renderização do elemento `<action-text-attachment>` do Action Text, uma classe deve:

* incluir o módulo `ActionText::Attachable`
* implementar `#to_sgid(**options)` (disponível através da preocupação [`GlobalID::Identification`][global-id])
* (opcional) declarar `#to_attachable_partial_path`
* (opcional) declarar um método de nível de classe `#to_missing_attachable_partial_path` para lidar com registros ausentes

Por padrão, todos os descendentes de `ActiveRecord::Base` misturam a preocupação [`GlobalID::Identification`][global-id] e, portanto, são compatíveis com `ActionText::Attachable`.


## Evite consultas N+1

Se você deseja pré-carregar o modelo dependente `ActionText::RichText`, assumindo que seu campo de texto rico é chamado `content`, você pode usar o escopo nomeado:

```ruby
Message.all.with_rich_text_content # Pré-carrega o corpo sem anexos.
Message.all.with_rich_text_content_and_embeds # Pré-carrega tanto o corpo quanto os anexos.
```

## API / Desenvolvimento Backend

1. Uma API backend (por exemplo, usando JSON) precisa de um endpoint separado para fazer upload de arquivos que cria um `ActiveStorage::Blob` e retorna seu `attachable_sgid`:

    ```json
    {
      "attachable_sgid": "BAh7CEkiCG…"
    }
    ```

2. Pegue esse `attachable_sgid` e peça ao seu frontend para inseri-lo no conteúdo de texto rico usando uma tag `<action-text-attachment>`:

    ```html
    <action-text-attachment sgid="BAh7CEkiCG…"></action-text-attachment>
    ```

Isso é baseado no Basecamp, então se você ainda não encontrar o que está procurando, verifique este [Documento do Basecamp](https://github.com/basecamp/bc3-api/blob/master/sections/rich_text.md).
[`rich_text_area`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-rich_text_area
[global-id]: https://github.com/rails/globalid#usage
