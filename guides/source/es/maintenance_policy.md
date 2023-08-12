**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b3af31bbaec1019121ce4667087dc971
Política de Mantenimiento para Ruby on Rails
====================================

El soporte del framework Rails se divide en cuatro grupos: nuevas características, correcciones de errores, problemas de seguridad y problemas de seguridad graves. Se manejan de la siguiente manera, todas las versiones, excepto las versiones de seguridad, en formato `X.Y.Z`.

--------------------------------------------------------------------------------

Versionado
------------

Rails sigue una versión modificada de [semver](https://semver.org/):

**Parche `Z`**

Solo correcciones de errores, sin cambios en la API, sin nuevas características.
Excepto en caso de correcciones de seguridad necesarias.

**Menor `Y`**

Nuevas características, puede contener cambios en la API (se consideran versiones principales de Semver).
Los cambios que rompen la compatibilidad se acompañan de avisos de deprecación en la versión menor o mayor anterior.

**Mayor `X`**

Nuevas características, probablemente contenga cambios en la API. La diferencia entre las versiones menor y mayor de Rails es la magnitud de los cambios que rompen la compatibilidad, y generalmente se reservan para ocasiones especiales.

Nuevas Características
------------

Las nuevas características solo se agregan a la rama principal y no estarán disponibles en las versiones de punto.

Correcciones de Errores
---------

Solo la serie de versiones más reciente recibirá correcciones de errores. Las correcciones de errores se agregan típicamente a la rama principal y se retroportan a la rama x-y-stable de la serie de versiones más reciente si hay suficiente necesidad. Cuando se han agregado suficientes correcciones de errores a una rama x-y-stable, se crea una nueva versión de parche a partir de ella. Por ejemplo, una versión de parche teórica 1.2.2 se construiría a partir de la rama 1-2-stable.

En situaciones especiales, cuando alguien del Equipo Principal acepta dar soporte a más series, se incluyen en la lista de series admitidas.

Para series no admitidas, las correcciones de errores pueden coincidir en una rama estable, pero no se lanzarán en una versión oficial. Se recomienda apuntar su aplicación a la rama estable utilizando Git para versiones no admitidas.

**Series actualmente incluidas:** `7.1.Z`.

Problemas de Seguridad
---------------

La serie de versiones actual y la siguiente más reciente recibirán parches y nuevas versiones en caso de un problema de seguridad.

Estas versiones se crean tomando la última versión lanzada, aplicando los parches de seguridad y lanzando una nueva versión. Luego, esos parches se aplican al final de la rama x-y-stable. Por ejemplo, una versión de seguridad teórica 1.2.2.1 se construiría a partir de 1.2.2 y luego se agregaría al final de 1-2-stable. Esto significa que las versiones de seguridad son fáciles de actualizar si está ejecutando la última versión de Rails.

Solo se incluirán parches de seguridad directos en las versiones de seguridad. Las correcciones para errores no relacionados con la seguridad que resulten de un parche de seguridad pueden publicarse en la rama x-y-stable de una versión y solo se lanzarán como una nueva gema de acuerdo con la política de correcciones de errores.

Las versiones de seguridad se cortan a partir de la última rama/etiqueta de versión de seguridad. De lo contrario, podría haber cambios que rompan la compatibilidad en la versión de seguridad. Una versión de seguridad solo debe contener los cambios necesarios para garantizar que la aplicación sea segura, de modo que sea más fácil mantener las aplicaciones actualizadas.

**Series actualmente incluidas:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Problemas de Seguridad Graves
----------------------

Para problemas de seguridad graves, todas las versiones en la serie principal actual y también la última versión en la serie principal anterior recibirán parches y nuevas versiones. La clasificación del problema de seguridad es evaluada por el equipo principal.

**Series actualmente incluidas:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Series de Versiones No Admitidas
--------------------------

Cuando una serie de versiones ya no tiene soporte, es su responsabilidad ocuparse de los errores y problemas de seguridad. Podemos proporcionar retroportaciones de las correcciones y fusionarlas, sin embargo, no se lanzarán nuevas versiones. Recomendamos apuntar su aplicación a la rama estable utilizando Git. Si no se siente cómodo manteniendo sus propias versiones, debe actualizar a una versión admitida.

Paquetes NPM
------------

Debido a una limitación con npm, no podemos usar el cuarto dígito para las versiones de seguridad de los [paquetes NPM][] proporcionados por Rails. Esto significa que en lugar de la versión de gema equivalente `7.0.1.4`, el paquete NPM se versionará como `7.0.1-4`.

[Paquetes NPM]: https://www.npmjs.com/org/rails
