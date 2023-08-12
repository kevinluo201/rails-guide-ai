**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Encriptación de Active Record
========================

Esta guía cubre cómo encriptar la información de tu base de datos utilizando Active Record.

Después de leer esta guía, sabrás:

* Cómo configurar la encriptación de la base de datos con Active Record.
* Cómo migrar datos no encriptados.
* Cómo hacer que diferentes esquemas de encriptación coexistan.
* Cómo utilizar la API.
* Cómo configurar la biblioteca y cómo extenderla.

--------------------------------------------------------------------------------

Active Record admite la encriptación a nivel de aplicación. Funciona declarando qué atributos deben ser encriptados y encriptándolos y desencriptándolos de manera transparente cuando sea necesario. La capa de encriptación se encuentra entre la base de datos y la aplicación. La aplicación accederá a los datos no encriptados, pero la base de datos los almacenará encriptados.

## ¿Por qué encriptar datos a nivel de aplicación?

La encriptación de Active Record existe para proteger la información sensible en tu aplicación. Un ejemplo típico es la información de identificación personal de los usuarios. Pero, ¿por qué querrías una encriptación a nivel de aplicación si ya estás encriptando tu base de datos en reposo?

Como beneficio práctico inmediato, encriptar atributos sensibles agrega una capa de seguridad adicional. Por ejemplo, si un atacante obtuviera acceso a tu base de datos, una instantánea de la misma o los registros de tu aplicación, no podrían entender la información encriptada. Además, la encriptación puede evitar que los desarrolladores expongan involuntariamente datos sensibles de los usuarios en los registros de la aplicación.

Pero lo más importante es que, al utilizar la encriptación de Active Record, defines qué información se considera sensible en tu aplicación a nivel de código. La encriptación de Active Record permite un control granular del acceso a los datos en tu aplicación y en los servicios que consumen datos de tu aplicación. Por ejemplo, considera [consolas de Rails auditables que protegen datos encriptados](https://github.com/basecamp/console1984) o verifica el sistema incorporado para [filtrar automáticamente los parámetros del controlador](#filtrado-de-parámetros-nombrados-como-columnas-encriptadas).

## Uso básico

### Configuración

Primero, necesitas agregar algunas claves a tus [credenciales de Rails](/security.html#custom-credentials). Ejecuta `bin/rails db:encryption:init` para generar un conjunto de claves aleatorias:

```bash
$ bin/rails db:encryption:init
Agrega esta entrada a las credenciales del entorno objetivo:

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

NOTA: Estos valores generados tienen una longitud de 32 bytes. Si los generas tú mismo, las longitudes mínimas que debes usar son 12 bytes para la clave primaria (que se utilizará para derivar la clave AES de 32 bytes) y 20 bytes para la sal.

### Declaración de Atributos Encriptados

Los atributos encriptables se definen a nivel del modelo. Estos son atributos regulares de Active Record respaldados por una columna con el mismo nombre.

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

La biblioteca encriptará estos atributos de manera transparente antes de guardarlos en la base de datos y los desencriptará al recuperarlos:

```ruby
article = Article.create title: "¡Encripta todo!"
article.title # => "¡Encripta todo!"
```

Pero, en realidad, la ejecución de SQL se ve así:

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### Importante: Sobre Almacenamiento y Tamaño de Columna

La encriptación requiere espacio adicional debido a la codificación Base64 y los metadatos almacenados junto con las cargas encriptadas. Cuando se utiliza el proveedor de claves de encriptación de sobre, puedes estimar el sobrecosto máximo en alrededor de 255 bytes. Este sobrecosto es insignificante en tamaños más grandes. No solo porque se diluye, sino porque la biblioteca utiliza compresión de forma predeterminada, lo que puede ofrecer ahorros de almacenamiento de hasta un 30% en comparación con la versión no encriptada para cargas más grandes.

Existe una preocupación importante sobre los tamaños de columna de cadena: en las bases de datos modernas, el tamaño de columna determina el *número de caracteres* que puede asignar, no el número de bytes. Por ejemplo, con UTF-8, cada carácter puede ocupar hasta cuatro bytes, por lo que, potencialmente, una columna en una base de datos que utiliza UTF-8 puede almacenar hasta cuatro veces su tamaño en términos de *número de bytes*. Ahora, las cargas encriptadas son cadenas binarias serializadas como Base64, por lo que se pueden almacenar en columnas `string` regulares. Debido a que son una secuencia de bytes ASCII, una columna encriptada puede ocupar hasta cuatro veces el tamaño de su versión sin encriptar. Entonces, incluso si los bytes almacenados en la base de datos son los mismos, la columna debe ser cuatro veces más grande.

En la práctica, esto significa:

* Al encriptar textos cortos escritos en alfabetos occidentales (principalmente caracteres ASCII), debes tener en cuenta esos 255 bytes adicionales al definir el tamaño de la columna.
* Al encriptar textos cortos escritos en alfabetos no occidentales, como el cirílico, debes multiplicar el tamaño de la columna por 4. Ten en cuenta que el sobrecosto de almacenamiento es de 255 bytes como máximo.
* Al encriptar textos largos, puedes ignorar las preocupaciones sobre el tamaño de la columna.
Algunos ejemplos:

| Contenido a encriptar                             | Tamaño de columna original | Tamaño recomendado de columna encriptada | Sobrecarga de almacenamiento (peor caso) |
| ------------------------------------------------- | ------------------------- | --------------------------------------- | --------------------------------------- |
| Direcciones de correo electrónico                 | string(255)               | string(510)                             | 255 bytes                               |
| Secuencia corta de emojis                         | string(255)               | string(1020)                            | 255 bytes                               |
| Resumen de textos escritos en alfabetos no occidentales | string(500)               | string(2000)                            | 255 bytes                               |
| Texto arbitrariamente largo                       | text                      | text                                    | insignificante                          |

### Encriptación determinista y no determinista

Por defecto, Active Record Encryption utiliza un enfoque no determinista para la encriptación. No determinista, en este contexto, significa que encriptar el mismo contenido con la misma contraseña dos veces dará como resultado diferentes textos cifrados. Este enfoque mejora la seguridad al dificultar el criptoanálisis de los textos cifrados y hacer que las consultas a la base de datos sean imposibles.

Puede utilizar la opción `deterministic:` para generar vectores de inicialización de manera determinista, lo que permite consultar datos encriptados.

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # Puede consultar el modelo normalmente
```

Se recomienda el enfoque no determinista a menos que necesite consultar los datos.

NOTA: En el modo no determinista, Active Record utiliza AES-GCM con una clave de 256 bits y un vector de inicialización aleatorio. En el modo determinista, también utiliza AES-GCM, pero el vector de inicialización se genera como un resumen HMAC-SHA-256 de la clave y el contenido a encriptar.

NOTA: Puede desactivar la encriptación determinista omitiendo una `deterministic_key`.

## Características

### Action Text

Puede encriptar los atributos de Action Text pasando `encrypted: true` en su declaración.

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

NOTA: Aún no se admite pasar opciones de encriptación individuales a los atributos de Action Text. Utilizará encriptación no determinista con las opciones de encriptación global configuradas.

### Fixtures

Puede obtener las fixtures de Rails encriptadas automáticamente agregando esta opción a su `test.rb`:

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

Cuando está habilitado, todos los atributos encriptables se encriptarán según la configuración de encriptación definida en el modelo.

#### Fixtures de Action Text

Para encriptar las fixtures de Action Text, debe colocarlas en `fixtures/action_text/encrypted_rich_texts.yml`.

### Tipos admitidos

`active_record.encryption` serializará los valores utilizando el tipo subyacente antes de encriptarlos, pero *deben ser serializables como cadenas*. Los tipos estructurados como `serialized` son compatibles de forma predeterminada.

Si necesita admitir un tipo personalizado, la forma recomendada es utilizar un [atributo serializado](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html). La declaración del atributo serializado debe ir **antes** de la declaración de encriptación:

```ruby
# CORRECTO
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# INCORRECTO
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### Ignorar mayúsculas y minúsculas

Es posible que necesite ignorar las mayúsculas y minúsculas al consultar datos encriptados de manera determinista. Hay dos enfoques que facilitan esto:

Puede utilizar la opción `:downcase` al declarar el atributo encriptado para convertir el contenido a minúsculas antes de que ocurra la encriptación.

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

Al utilizar `:downcase`, se pierde la mayúscula original. En algunas situaciones, es posible que desee ignorar la mayúscula y minúscula solo al realizar consultas y también almacenar la mayúscula original. Para esas situaciones, puede utilizar la opción `:ignore_case`. Esto requiere agregar una nueva columna llamada `original_<nombre_de_columna>` para almacenar el contenido con la mayúscula sin cambios:

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # el contenido con la mayúscula original se almacenará en la columna `original_name`
end
```

### Soporte para datos no encriptados

Para facilitar las migraciones de datos no encriptados, la biblioteca incluye la opción `config.active_record.encryption.support_unencrypted_data`. Cuando se establece en `true`:

* Intentar leer atributos encriptados que no están encriptados funcionará normalmente, sin generar ningún error.
* Las consultas con atributos encriptados de manera determinista incluirán la versión "texto sin formato" de ellos para admitir la búsqueda de contenido encriptado y no encriptado. Debe establecer `config.active_record.encryption.extend_queries = true` para habilitar esto.

**Esta opción está destinada a ser utilizada durante períodos de transición** cuando los datos claros y los datos encriptados deben coexistir. Ambos se establecen en `false` de forma predeterminada, lo cual es el objetivo recomendado para cualquier aplicación: se generarán errores al trabajar con datos no encriptados.

### Soporte para esquemas de encriptación anteriores

Cambiar las propiedades de encriptación de los atributos puede romper los datos existentes. Por ejemplo, imagine que desea hacer que un atributo determinista sea no determinista. Si simplemente cambia la declaración en el modelo, la lectura de los textos cifrados existentes fallará porque el método de encriptación es diferente ahora.
Para respaldar estas situaciones, puedes declarar esquemas de cifrado anteriores que se utilizarán en dos escenarios:

* Al leer datos cifrados, Active Record Encryption intentará esquemas de cifrado anteriores si el esquema actual no funciona.
* Al consultar datos deterministas, agregará textos cifrados utilizando esquemas anteriores para que las consultas funcionen sin problemas con datos cifrados con diferentes esquemas. Debes configurar `config.active_record.encryption.extend_queries = true` para habilitar esto.

Puedes configurar esquemas de cifrado anteriores:

* Globalmente
* En una base de atributos por atributo

#### Esquemas de cifrado anteriores globales

Puedes agregar esquemas de cifrado anteriores agregándolos como una lista de propiedades utilizando la propiedad de configuración `previous` en tu archivo `application.rb`:

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### Esquemas de cifrado por atributo

Usa `:previous` al declarar el atributo:

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### Esquemas de cifrado y atributos deterministas

Al agregar esquemas de cifrado anteriores:

* Con **cifrado no determinista**, la nueva información siempre se cifrará con el esquema de cifrado *más nuevo* (actual).
* Con **cifrado determinista**, la nueva información siempre se cifrará con el esquema de cifrado *más antiguo* de forma predeterminada.

Normalmente, con el cifrado determinista, quieres que los textos cifrados permanezcan constantes. Puedes cambiar este comportamiento configurando `deterministic: { fixed: false }`. En ese caso, se utilizará el esquema de cifrado *más nuevo* para cifrar nuevos datos.

### Restricciones únicas

NOTA: Las restricciones únicas solo se pueden utilizar con datos cifrados de forma determinista.

#### Validaciones únicas

Las validaciones únicas se admiten normalmente siempre que las consultas extendidas estén habilitadas (`config.active_record.encryption.extend_queries = true`).

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

También funcionarán cuando se combinen datos cifrados y no cifrados, y cuando se configuren esquemas de cifrado anteriores.

NOTA: Si quieres ignorar mayúsculas y minúsculas, asegúrate de usar `downcase:` o `ignore_case:` en la declaración de `encrypts`. Usar la opción `case_sensitive:` en la validación no funcionará.

#### Índices únicos

Para admitir índices únicos en columnas cifradas de forma determinista, debes asegurarte de que su texto cifrado nunca cambie.

Para fomentar esto, los atributos deterministas siempre utilizarán el esquema de cifrado más antiguo disponible de forma predeterminada cuando se configuren múltiples esquemas de cifrado. De lo contrario, es tu responsabilidad asegurarte de que las propiedades de cifrado no cambien para estos atributos, o los índices únicos no funcionarán.

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### Filtrado de parámetros con nombres de columnas cifradas

De forma predeterminada, las columnas cifradas están configuradas para ser [filtradas automáticamente en los registros de Rails](action_controller_overview.html#parameters-filtering). Puedes deshabilitar este comportamiento agregando lo siguiente a tu archivo `application.rb`:

Al generar el parámetro de filtro, utilizará el nombre del modelo como prefijo. Por ejemplo: para `Person#name`, el parámetro de filtro será `person.name`.

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

En caso de que desees excluir columnas específicas de este filtrado automático, agrégalas a `config.active_record.encryption.excluded_from_filter_parameters`.

### Codificación

La biblioteca conservará la codificación de los valores de cadena cifrados de forma no determinista.

Debido a que la codificación se almacena junto con la carga útil cifrada, los valores cifrados de forma determinista forzarán la codificación UTF-8 de forma predeterminada. Por lo tanto, el mismo valor con una codificación diferente dará como resultado un texto cifrado diferente cuando se cifre. Por lo general, quieres evitar esto para que las consultas y las restricciones de unicidad funcionen, por lo que la biblioteca realizará la conversión automáticamente en tu nombre.

Puedes configurar la codificación predeterminada deseada para el cifrado determinista con:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

Y puedes deshabilitar este comportamiento y conservar la codificación en todos los casos con:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## Gestión de claves

Los proveedores de claves implementan estrategias de gestión de claves. Puedes configurar proveedores de claves globalmente o por atributo.

### Proveedores de claves integrados

#### DerivedSecretKeyProvider

Un proveedor de claves que servirá claves derivadas de las contraseñas proporcionadas utilizando PBKDF2.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

NOTA: De forma predeterminada, `active_record.encryption` configura un `DerivedSecretKeyProvider` con las claves definidas en `active_record.encryption.primary_key`.

#### EnvelopeEncryptionKeyProvider

Implementa una estrategia simple de [envelope encryption](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping):

- Genera una clave aleatoria para cada operación de cifrado de datos
- Almacena la clave de datos junto con los datos mismos, cifrada con una clave principal definida en la credencial `active_record.encryption.primary_key`.

Puedes configurar Active Record para usar este proveedor de claves agregando esto a tu archivo `application.rb`:

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

Al igual que con otros proveedores de claves integrados, puedes proporcionar una lista de claves principales en `active_record.encryption.primary_key` para implementar esquemas de rotación de claves.
### Proveedores de claves personalizados

Para esquemas de gestión de claves más avanzados, puede configurar un proveedor de claves personalizado en un inicializador:

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

Un proveedor de claves debe implementar esta interfaz:

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

Ambos métodos devuelven objetos `ActiveRecord::Encryption::Key`:

- `encryption_key` devuelve la clave utilizada para cifrar algún contenido
- `decryption_keys` devuelve una lista de claves potenciales para descifrar un mensaje dado

Una clave puede incluir etiquetas arbitrarias que se almacenarán sin cifrar con el mensaje. Puede utilizar `ActiveRecord::Encryption::Message#headers` para examinar esos valores al descifrar.

### Proveedores de claves específicos del modelo

Puede configurar un proveedor de claves para cada clase con la opción `:key_provider`:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### Claves específicas del modelo

Puede configurar una clave específica para una clase con la opción `:key`:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "una clave secreta para resúmenes de artículos"
end
```

Active Record utiliza la clave para derivar la clave utilizada para cifrar y descifrar los datos.

### Rotación de claves

`active_record.encryption` puede trabajar con listas de claves para admitir la implementación de esquemas de rotación de claves:

- La **última clave** se utilizará para cifrar contenido nuevo.
- Se probarán todas las claves al descifrar contenido hasta que una funcione.

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # Las claves anteriores aún pueden descifrar contenido existente
    - bc17e7b413fd4720716a7633027f8cc4 # Activa, cifra contenido nuevo
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

Esto permite flujos de trabajo en los que se mantiene una lista corta de claves mediante la adición de nuevas claves, el cifrado de contenido y la eliminación de claves antiguas.

NOTA: Actualmente no se admite la rotación de claves para el cifrado determinista.

NOTA: Active Record Encryption aún no proporciona la gestión automática de los procesos de rotación de claves. Todas las piezas están ahí, pero aún no se ha implementado.

### Almacenamiento de referencias de claves

Puede configurar `active_record.encryption.store_key_references` para que `active_record.encryption` almacene una referencia a la clave de cifrado en el propio mensaje cifrado.

```ruby
config.active_record.encryption.store_key_references = true
```

Al hacerlo, se logra un descifrado más eficiente porque el sistema ahora puede localizar las claves directamente en lugar de probar listas de claves. El precio a pagar es el almacenamiento: los datos cifrados serán un poco más grandes.

## API

### API básica

La encriptación de ActiveRecord está diseñada para ser utilizada de forma declarativa, pero ofrece una API para escenarios de uso avanzados.

#### Cifrar y descifrar

```ruby
article.encrypt # cifra o vuelve a cifrar todos los atributos cifrables
article.decrypt # descifra todos los atributos cifrables
```

#### Leer texto cifrado

```ruby
article.ciphertext_for(:title)
```

#### Comprobar si el atributo está cifrado o no

```ruby
article.encrypted_attribute?(:title)
```

## Configuración(title)

### Opciones de configuración

Puede configurar las opciones de Active Record Encryption en su archivo `application.rb` (escenario más común) o en un archivo de configuración específico del entorno `config/environments/<nombre de entorno>.rb` si desea configurarlas según el entorno.

ADVERTENCIA: Se recomienda utilizar el soporte de credenciales incorporado de Rails para almacenar claves. Si prefiere configurarlas manualmente a través de propiedades de configuración, asegúrese de no incluirlas en su código (por ejemplo, utilice variables de entorno).

#### `config.active_record.encryption.support_unencrypted_data`

Cuando es verdadero, los datos no cifrados se pueden leer normalmente. Cuando es falso, se generará un error. Valor predeterminado: `false`.

#### `config.active_record.encryption.extend_queries`

Cuando es verdadero, las consultas que hacen referencia a atributos cifrados de forma determinista se modificarán para incluir valores adicionales si es necesario. Esos valores adicionales serán la versión sin cifrar del valor (cuando `config.active_record.encryption.support_unencrypted_data` es verdadero) y valores cifrados con esquemas de cifrado anteriores, si los hay (como se proporciona con la opción `previous:`). Valor predeterminado: `false` (experimental).

#### `config.active_record.encryption.encrypt_fixtures`

Cuando es verdadero, los atributos cifrables en los fixtures se cifrarán automáticamente al cargarlos. Valor predeterminado: `false`.

#### `config.active_record.encryption.store_key_references`

Cuando es verdadero, se almacena una referencia a la clave de cifrado en los encabezados del mensaje cifrado. Esto permite un descifrado más rápido cuando se utilizan múltiples claves. Valor predeterminado: `false`.

#### `config.active_record.encryption.add_to_filter_parameters`

Cuando es verdadero, los nombres de los atributos cifrados se agregan automáticamente a [`config.filter_parameters`][] y no se mostrarán en los registros. Valor predeterminado: `true`.


#### `config.active_record.encryption.excluded_from_filter_parameters`

Puede configurar una lista de parámetros que no se filtrarán cuando `config.active_record.encryption.add_to_filter_parameters` sea verdadero. Valor predeterminado: `[]`.

#### `config.active_record.encryption.validate_column_size`

Agrega una validación basada en el tamaño de la columna. Se recomienda para evitar almacenar valores enormes utilizando cargas útiles altamente compresibles. Valor predeterminado: `true`.

#### `config.active_record.encryption.primary_key`

La clave o lista de claves utilizadas para derivar claves de cifrado de datos raíz. La forma en que se utilizan depende del proveedor de claves configurado. Se prefiere configurarlo a través de la credencial `active_record_encryption.primary_key`.
#### `config.active_record.encryption.deterministic_key`

La clave o lista de claves utilizadas para el cifrado determinístico. Se recomienda configurarlo a través de la credencial `active_record_encryption.deterministic_key`.

#### `config.active_record.encryption.key_derivation_salt`

La sal utilizada al derivar claves. Se recomienda configurarlo a través de la credencial `active_record_encryption.key_derivation_salt`.

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

La codificación predeterminada para los atributos cifrados de manera determinística. Puede desactivar la codificación forzada estableciendo esta opción en `nil`. Por defecto es `Encoding::UTF_8`.

#### `config.active_record.encryption.hash_digest_class`

El algoritmo de resumen utilizado para derivar claves. Por defecto es `OpenSSL::Digest::SHA1`.

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Permite descifrar datos cifrados de manera no determinística con una clase de resumen SHA1. Por defecto es falso, lo que significa que solo admitirá el algoritmo de resumen configurado en `config.active_record.encryption.hash_digest_class`.

### Contextos de cifrado

Un contexto de cifrado define los componentes de cifrado que se utilizan en un momento dado. Existe un contexto de cifrado predeterminado basado en su configuración global, pero puede configurar un contexto personalizado para un atributo específico o al ejecutar un bloque de código específico.

NOTA: Los contextos de cifrado son un mecanismo de configuración flexible pero avanzado. La mayoría de los usuarios no deberían tener que preocuparse por ellos.

Los principales componentes de los contextos de cifrado son:

* `encryptor`: expone la API interna para cifrar y descifrar datos. Interactúa con un `key_provider` para construir mensajes cifrados y manejar su serialización. El cifrado/descifrado en sí se realiza mediante el `cipher` y la serialización mediante `message_serializer`.
* `cipher`: el algoritmo de cifrado en sí (AES 256 GCM)
* `key_provider`: proporciona claves de cifrado y descifrado.
* `message_serializer`: serializa y deserializa las cargas cifradas (`Message`).

NOTA: Si decide construir su propio `message_serializer`, es importante utilizar mecanismos seguros que no puedan deserializar objetos arbitrarios. Un escenario comúnmente admitido es cifrar datos no cifrados existentes. Un atacante puede aprovechar esto para ingresar una carga manipulada antes de que se realice el cifrado y realizar ataques de ejecución de código remoto (RCE). Esto significa que los serializadores personalizados deben evitar `Marshal`, `YAML.load` (usar `YAML.safe_load` en su lugar) o `JSON.load` (usar `JSON.parse` en su lugar).

#### Contexto de cifrado global

El contexto de cifrado global es el que se utiliza de forma predeterminada y se configura como otras propiedades de configuración en su archivo `application.rb` o archivos de configuración de entorno.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### Contextos de cifrado por atributo

Puede anular los parámetros del contexto de cifrado pasándolos en la declaración del atributo:

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### Contexto de cifrado al ejecutar un bloque de código

Puede utilizar `ActiveRecord::Encryption.with_encryption_context` para establecer un contexto de cifrado para un bloque de código específico:

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### Contextos de cifrado integrados

##### Desactivar el cifrado

Puede ejecutar código sin cifrado:

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

Esto significa que al leer texto cifrado se devolverá el texto cifrado y el contenido guardado se almacenará sin cifrar.

##### Proteger datos cifrados

Puede ejecutar código sin cifrado pero evitar sobrescribir el contenido cifrado:

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

Esto puede ser útil si desea proteger datos cifrados mientras ejecuta código arbitrario contra ellos (por ejemplo, en una consola de Rails).
[`config.filter_parameters`]: configuring.html#config-filter-parameters
