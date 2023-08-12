**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Guías de Ruby on Rails - Directrices
=====================================

Esta guía documenta las directrices para escribir guías de Ruby on Rails. Esta guía se sigue a sí misma en un bucle elegante, sirviéndose a sí misma como ejemplo.

Después de leer esta guía, sabrás:

* Sobre las convenciones que se deben utilizar en la documentación de Rails.
* Cómo generar guías localmente.

--------------------------------------------------------------------------------

Markdown
-------

Las guías se escriben en [Markdown con formato GitHub](https://help.github.com/articles/github-flavored-markdown). Existe una [documentación completa para Markdown](https://daringfireball.net/projects/markdown/syntax), así como una [hoja de referencia](https://daringfireball.net/projects/markdown/basics).

Prólogo
--------

Cada guía debe comenzar con un texto motivador en la parte superior (esa es la pequeña introducción en el área azul). El prólogo debe decirle al lector de qué trata la guía y qué aprenderá. Como ejemplo, consulta la [Guía de enrutamiento](routing.html).

Encabezados
------

El título de cada guía utiliza un encabezado `h1`; las secciones de la guía utilizan encabezados `h2`; las subsecciones utilizan encabezados `h3`; etc. Ten en cuenta que la salida HTML generada utilizará etiquetas de encabezado que comienzan con `<h2>`.

```markdown
Título de la Guía
=================

Sección
-------

### Subsección
```

Al escribir encabezados, se deben capitalizar todas las palabras excepto las preposiciones, conjunciones, artículos internos y formas del verbo "ser":

```markdown
#### Afirmaciones y pruebas de trabajos dentro de componentes
#### La pila de middleware es un arreglo
#### ¿Cuándo se guardan los objetos?
```

Utiliza el mismo formato en línea que el texto regular:

```markdown
##### La opción `:content_type`
```

Enlaces a la API
------------------

Los enlaces a la API (`api.rubyonrails.org`) son procesados por el generador de guías de la siguiente manera:

Los enlaces que incluyen una etiqueta de versión se dejan sin cambios. Por ejemplo:

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

no se modifica.

Utiliza estos enlaces en las notas de la versión, ya que deben apuntar a la versión correspondiente sin importar el destino que se esté generando.

Si el enlace no incluye una etiqueta de versión y se están generando guías de desarrollo, el dominio se reemplaza por `edgeapi.rubyonrails.org`. Por ejemplo:

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se convierte en

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Si el enlace no incluye una etiqueta de versión y se están generando guías de una versión específica, se inyecta la versión de Rails. Por ejemplo, si estamos generando las guías para v5.1.0, el enlace

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se convierte en

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Por favor, no enlaces a `edgeapi.rubyonrails.org` manualmente.


Directrices de Documentación de la API
----------------------------

Las guías y la API deben ser coherentes y consistentes cuando corresponda. En particular, estas secciones de las [Directrices de Documentación de la API](api_documentation_guidelines.html) también se aplican a las guías:

* [Redacción](api_documentation_guidelines.html#wording)
* [Inglés](api_documentation_guidelines.html#english)
* [Código de Ejemplo](api_documentation_guidelines.html#example-code)
* [Nombres de Archivo](api_documentation_guidelines.html#file-names)
* [Fuentes](api_documentation_guidelines.html#fonts)

Guías en HTML
-----------

Antes de generar las guías, asegúrate de tener la última versión de Bundler instalada en tu sistema. Para instalar la última versión de Bundler, ejecuta `gem install bundler`.

Si ya tienes Bundler instalado, puedes actualizarlo con `gem update bundler`.

### Generación

Para generar todas las guías, simplemente ve al directorio `guides`, ejecuta `bundle install` y luego ejecuta:

```bash
$ bundle exec rake guides:generate
```

o

```bash
$ bundle exec rake guides:generate:html
```

Los archivos HTML resultantes se pueden encontrar en el directorio `./output`.

Para procesar solo `my_guide.md` y nada más, utiliza la variable de entorno `ONLY`:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

De forma predeterminada, las guías que no se han modificado no se procesan, por lo que `ONLY` rara vez es necesario en la práctica.

Para forzar el procesamiento de todas las guías, pasa `ALL=1`.

Si deseas generar guías en un idioma distinto al inglés, puedes mantenerlas en un directorio separado dentro de `source` (por ejemplo, `source/es`) y utilizar la variable de entorno `GUIDES_LANGUAGE`:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

Si deseas ver todas las variables de entorno que puedes utilizar para configurar el script de generación, simplemente ejecuta:

```bash
$ rake
```

### Validación

Por favor, valida el HTML generado con:

```bash
$ bundle exec rake guides:validate
```

En particular, los títulos obtienen un ID generado a partir de su contenido y esto a menudo genera duplicados.

Guías para Kindle
-------------

### Generación

Para generar guías para Kindle, utiliza la siguiente tarea de rake:

```bash
$ bundle exec rake guides:generate:kindle
```
