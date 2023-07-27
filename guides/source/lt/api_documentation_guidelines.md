**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
API Dokumentacijos Gairės
============================

Šiame vadove dokumentuojamos Ruby on Rails API dokumentacijos gairės.

Po šio vadovo perskaitymo žinosite:

* Kaip rašyti efektyvų prozą dokumentacijos tikslais.
* Stilių gairės dokumentuojant skirtingus Ruby kodo tipus.

--------------------------------------------------------------------------------

RDoc
----

[Rails API dokumentacija](https://api.rubyonrails.org) generuojama naudojant
[RDoc](https://ruby.github.io/rdoc/). Norėdami ją sugeneruoti, įsitikinkite, kad esate
Rails šakninėje direktorijoje, paleiskite `bundle install` ir vykdykite:

```bash
$ bundle exec rake rdoc
```

Sugeneruoti HTML failai rasomi ./doc/rdoc direktorijoje.

PASTABA: Norint gauti pagalbą dėl sintaksės, prašome pasikonsultuoti su RDoc [Markup Reference][RDoc Markup].

Nuorodos
--------

Rails API dokumentacija nėra skirta peržiūrėti GitHub'e, todėl nuorodos turėtų naudoti RDoc [`link`][RDoc Links] žymėjimą atsižvelgiant į esamą API.

Tai yra dėl skirtumų tarp GitHub Markdown ir sugeneruoto RDoc, kuris yra publikuojamas adresu [api.rubyonrails.org](https://api.rubyonrails.org) ir [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org).

Pavyzdžiui, naudojame `[link:classes/ActiveRecord/Base.html]` nuorodą į `ActiveRecord::Base` klasę, sugeneruotą RDoc.

Tai yra pageidautina nei absoliučios nuorodos, pvz., `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`, kuri išvestų skaitytoją iš dabartinės dokumentacijos versijos (pvz., edgeapi.rubyonrails.org).

[RDoc Markup]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc Links]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

Formulavimas
------------

Rašykite paprastus, deklaratyvius sakinio struktūras. Trumpumas yra pliusas: pereikite prie esmės.

Rašykite dabarties laiku: "Gražina hash'ą, kuris...", o ne "Gražino hash'ą, kuris..." arba "Gražins hash'ą, kuris...".

Komentarus pradėkite didžiąja raide. Laikykitės įprastų skyrybos taisyklių:

```ruby
# Deklaruoja atributo skaitytuvą, kuris remiasi viduje pavadintu
# kintamuoju.
def attr_internal_reader(*attrs)
  # ...
end
```

Skaitytojui perteikite dabartinį veikimo būdą, tiek aiškiai, tiek neaiškiai. Naudokite rekomenduojamus idiomus. Jei reikia, pertvarkykite skyrius, kad būtų pabrėžti pageidaujami požiūriai ir pan. Dokumentacija turėtų būti modelis geriausioms praktikoms ir kanoniškam, moderniam Rails naudojimui.

Dokumentacija turi būti trumpa, bet išsamiai. Ištyrinkite ir aprašykite ribinius atvejus. Kas nutinka, jei modulis yra anoniminis? Kas nutinka, jei kolekcija yra tuščia? Kas nutinka, jei argumentas yra nil?

Rails komponentų pavadinimai turi tarpą tarp žodžių, pvz., "Active Support". `ActiveRecord` yra Ruby modulis, o Active Record yra ORM. Visos Rails dokumentacijos turėtų nuosekliai nuorodyti į Rails komponentus pagal jų tikrus pavadinimus.

Kalbant apie "Rails aplikaciją", priešingai nei "engine" ar "plugin", visada naudokite "application". Rails aplikacijos nėra "paslaugos", nebent konkretaus aptariamojo paslaugų orientuoto architektūros atveju.

Rašykite pavadinimus teisingai: Arel, minitest, RSpec, HTML, MySQL, JavaScript, ERB, Hotwire. Jei abejojate, prašome pasitikrinti autoritetingą šaltinį, pvz., jų oficialią dokumentaciją.

Pirmenybę teikite formulavimui, kuriame nėra "you" ir "your". Pavyzdžiui, vietoj

```markdown
If you need to use `return` statements in your callbacks, it is recommended that you explicitly define them as methods.
```

naudokite šį stilių:

```markdown
If `return` is needed, it is recommended to explicitly define a method.
```

Tačiau, naudojant įvardžius atsižvelgiant į hipotetinį asmenį, pvz., "vartotojas su sesijos slapukais", reikėtų naudoti lyties neutralius įvardžius (they/their/them). Vietoje:

* he arba she... naudokite they.
* him arba her... naudokite them.
* his arba her... naudokite their.
* his arba hers... naudokite theirs.
* himself arba herself... naudokite themselves.

Anglų kalba
-----------

Prašome naudoti Amerikos anglų kalbą (*color*, *center*, *modularize*, ir pan.). Žr. [čia Amerikos ir Britų anglų kalbos rašybos skirtumų sąrašą](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences).

Oxford kablelis
---------------

Prašome naudoti [Oxford kablelį](https://en.wikipedia.org/wiki/Serial_comma)
("red, white, and blue", o ne "red, white and blue").

Pavyzdžio kodas
---------------

Pasirinkite prasmingus pavyzdžius, kurie atspindi ir apima pagrindinius dalykus bei įdomius momentus ar klaidas.

Kodo gabalams įrėminti naudokite dvi tarpas--tai yra, žymint žymėjimo tikslais, dvi tarpas atsižvelgiant į kairįjį kraštinę. Patys pavyzdžiai turėtų naudoti [Rails kodavimo konvencijas](contributing_to_ruby_on_rails.html#follow-the-coding-conventions).

Trumpiems dokumentams nereikia aiškiai nurodyti "Pavyzdžiai" žymės, kad būtų įterpti fragmentai; jie tiesiog seka po pastraipų:

```ruby
# Converts a collection of elements into a formatted string by
# calling +to_s+ on all elements and joining them.
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

Kita vertus, dideliems struktūruotiems dokumentams gali būti atskiras "Pavyzdžiai" skyrius:

```ruby
# ==== Examples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
Rezultatai išraiškų seka juos seka ir pristatoma "# => ", vertikaliai išlyginta:

```ruby
# Tikrinant, ar sveikasis skaičius yra lyginis ar nelyginis.
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

Jei eilutė per ilga, komentaras gali būti perkeltas į kitą eilutę:

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

Vengti naudoti spausdinimo metodus, pvz., `puts` ar `p`, tam tikslui.

Kita vertus, įprasti komentarai nenaudoja rodyklės:

```ruby
#   polymorphic_url(record)  # tas pats kaip comment_url(record)
```

### SQL

Dokumentuojant SQL teiginius, rezultatas neturi turėti `=>` prieš išvestį.

Pavyzdžiui,

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

Dokumentuojant elgesį su IRB, Ruby interaktyviu REPL, visada prieš komandas naudokite prefiksą `irb>` ir išvestis turi būti su prefiksu `=>`.

Pavyzdžiui,

```
# Rasti klientą su pagrindiniu raktu (id) 10.
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / komandinė eilutė

Komandinės eilutės pavyzdžiams visada prieš komandą naudokite `$`, išvestis neturi turėti jokio prefikso.

```
# Paleiskite šią komandą:
#   $ bin/rails new zomg
#   ...
```

Booleans
--------

Predikatuose ir vėliavose pageidautina dokumentuoti boolean semantiką, o ne tikslų reikšmes.

Kai "true" arba "false" naudojami, kaip apibrėžta Ruby, naudokite įprastą šriftą. Vienetiniai `true` ir `false` reikalauja fiksuoto pločio šrifto. Prašome vengti terminų, tokio kaip "truthy", Ruby apibrėžia, kas yra tiesa ir netiesa kalboje, todėl šie žodžiai turi techninį prasmės ir nereikalauja jokių pakaitų.

Taisyklės pagalba nereikia dokumentuoti vienetinių, nebūtina. Tai neleidžia dirbtiniams konstruktams, tokiam kaip `!!` ar ternariniai operatoriai, leidžia atlikti pertvarkymus ir kodas neturi remtis tiksliais grąžinamų metodų reikšmėmis, kurie yra iškviesti įgyvendinime.

Pavyzdžiui:

```markdown
`config.action_mailer.perform_deliveries` nurodo, ar paštas iš tikrųjų bus pristatomas ir pagal numatytuosius nustatymus yra tiesa
```

vartotojui nereikia žinoti, kokia yra vėliavos numatytoji reikšmė, todėl dokumentuojame tik jos boolean semantiką.

Pavyzdys su predikatu:

```ruby
# Grąžina true, jei kolekcija yra tuščia.
#
# Jei kolekcija yra įkelta
# tai yra lygu <tt>collection.size.zero?</tt>. Jei
# kolekcija nebuvo įkelta, tai yra lygu
# <tt>!collection.exists?</tt>. Jei kolekcija dar nebuvo
# įkelta ir jūs vis tiek ketinate gauti įrašus, geriau
# patikrinkite <tt>collection.length.zero?</tt>.
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

API atsargus neprisiima jokios konkretaus reikšmės, metodas turi predikato semantiką, tai pakanka.

Failų pavadinimai
----------

Taisyklės pagalba naudokite failų pavadinimus, susijusius su programos šaknimi:

```
config/routes.rb            # TAIP
routes.rb                   # NE
RAILS_ROOT/config/routes.rb # NE
```

Šriftai
-----

### Fiksuoto pločio šriftas

Naudokite fiksuoto pločio šriftus:

* Konstantoms, ypač klasės ir modulio pavadinimams.
* Metodų pavadinimams.
* Literalomis, tokiais kaip `nil`, `false`, `true`, `self`.
* Simboliais.
* Metodų parametrais.
* Failų pavadinimais.

```ruby
class Array
  # Iškviečia +to_param+ visuose savo elementuose ir sujungia rezultatą su
  # pasviraisiais brūkšniais. Tai naudojama +url_for+ veiksmo pakete.
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

ĮSPĖJIMAS: Naudoti `+...+` fiksuoto pločio šriftui veikia tik su paprastu turiniu, tokiais kaip įprastos klasės, modulio, metodo pavadinimai, simboliai, keliai (su įstrižainėmis brūkšneliais) ir kt. Prašome naudoti `<tt>...</tt>` visam kitam turiniui.

RDoc išvestį galite greitai patikrinti naudodami šią komandą:

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

Pavyzdžiui, kodas su tarpais ar kabutėmis turėtų naudoti formą `<tt>...</tt>`.

### Įprastas šriftas

Kai "true" ir "false" yra anglų žodžiai, o ne Ruby raktiniai žodžiai, naudokite įprastą šriftą:

```ruby
# Paleidžia visas patikras nurodytoje kontekste.
# Grąžina true, jei klaidų nerasta, false kitu atveju.
#
# Jei argumentas yra false (numatytasis yra +nil+), kontekstas yra
# nustatomas į <tt>:create</tt>, jei <tt>new_record?</tt> yra true,
# ir į <tt>:update</tt>, jei nėra.
#
# Patikros be <tt>:on</tt> parinkties bus vykdomos
# nepriklausomai nuo konteksto. Patikros su # kai kuriais <tt>:on</tt>
# parinktimis bus vykdomos tik nurodytame kontekste.
def valid?(context = nil)
  # ...
end
```
Aprašymo sąrašai
-----------------

Sąrašuose su pasirinkimais, parametrais ir kt. tarp elemento ir jo aprašymo naudokite brūkšnį (geriau skaitosi nei dvitaškis, nes paprastai pasirinkimai yra simboliai):

```ruby
# * <tt>:allow_nil</tt> - Praleisti patikrinimą, jei atributas yra +nil+.
```

Aprašymas prasideda didžiąja raide ir baigiasi tašku - tai standartinė anglų kalba.

Alternatyvus požiūris, kai norite pateikti papildomų detalės ir pavyzdžių, yra naudoti parinkčių skyriaus stilių.

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] yra puikus šio pavyzdžio pavyzdys.

```ruby
# ==== Parinktys
#
# [+:expires_at+]
#   Laikas, kada žinutė pasibaigs. Po šio laiko žinutės patikrinimas
#   nepavyks.
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # Po 24 valandų...
#     encryptor.decrypt_and_verify(message) # => nil
```


Dinamiškai generuojami metodai
-----------------------------

Metodai, sukurti naudojant `(module|class)_eval(STRING)`, turi komentarą šalia su sugeneruoto kodo pavyzdžiu. Šis komentaras yra 2 tarpai nuo šablono:

[![(module|class)_eval(STRING) kodo komentarai](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

Jei rezultatas yra per platus, pvz., 200 stulpelių ar daugiau, komentarą padėkite virš kvietimo:

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

Metodo matomumas
-----------------

Rašant dokumentaciją Rails, svarbu suprasti skirtumą tarp viešo naudotojo sąsajos ir vidinės sąsajos.

Rails, kaip ir dauguma bibliotekų, naudoja privataus raktažodį iš Ruby vidinei sąsajai apibrėžti. Tačiau viešoji sąsaja laikosi šiek tiek kitokio konvencijos. Vietoj to, kad būtų priimta, jog visi vieši metodai skirti naudotojui, Rails naudoja `:nodoc:` direktyvą, kad pažymėtų šios rūšies metodus kaip vidinę sąsają.

Tai reiškia, kad yra metodų Rails su `public` matomumu, kurie nėra skirti naudotojui.

Pavyzdys to yra `ActiveRecord::Core::ClassMethods#arel_table`:

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # padaryti kažką magiško..
  end
end
```

Jei pagalvojote, "šis metodas atrodo kaip viešas klasės metodas `ActiveRecord::Core`", buvote teisus. Tačiau iš tikrųjų Rails komanda nenori, kad naudotojai pasitikėtų šiuo metodu. Todėl jie pažymi jį kaip `:nodoc:` ir jis pašalinamas iš viešos dokumentacijos. Tokio sprendimo priežastis yra leisti komandai keisti šiuos metodus pagal jų vidines poreikius per išleidimus, kaip jie mano tinkamus. Šio metodo pavadinimas gali pasikeisti, arba grąžinimo reikšmė, arba visa klasė gali išnykti; nėra jokios garantijos, todėl neturėtumėte priklausyti nuo šios sąsajos savo įskiepiuose ar programose. Kitu atveju rizikuojate, kad jūsų programa ar juvelyras suges, kai atnaujinsite naujesnę Rails versiją.

Kaip bendradarbis, svarbu pagalvoti, ar ši sąsaja skirta galutiniam naudotojui. Rails komanda įsipareigoja nepakeisti viešos sąsajos per išleidimus be pilno pasenusio ciklo. Rekomenduojama `:nodoc:` pažymėti bet kurį vidinį jūsų metodą/klasę, nebent jie jau yra privačios (tai reiškia matomumą), tuomet jie pagal nutylėjimą yra vidinės. Kai sąsaja stabilizuojasi, matomumas gali pasikeisti, tačiau viešos sąsajos keitimas yra daug sunkesnis dėl suderinamumo atgal.

Klasė ar modulis pažymimas `:nodoc:`, kad būtų nurodyta, jog visi metodai yra vidinė sąsaja ir jais neturėtų būti naudojamasi tiesiogiai.

Apibendrinant, Rails komanda naudoja `:nodoc:`, kad pažymėtų viešai matomus metodus ir klases kaip vidinę sąsają; API matomumo pakeitimai turėtų būti apgalvoti ir aptarti per pull request'ą.

Dėl Rails steko
-------------------------

Dokumentuojant dalis iš Rails API, svarbu prisiminti visas dalis, kurios sudaro Rails steką.

Tai reiškia, kad elgsena gali keistis priklausomai nuo metodo ar klasės konteksto ar srities, kurią bandote dokumentuoti.

Skirtingose vietose yra skirtinga elgsena, kai atsižvelgiame į visą steką, vienas tokių pavyzdžių yra `ActionView::Helpers::AssetTagHelper#image_tag`:

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

Nors numatytoji `#image_tag` elgsena visada yra grąžinti `/images/icon.png`, atsižvelgiant į visą Rails steką (įskaitant turinio rinkinį), galime matyti aukščiau pateiktą rezultatą.

Mums rūpi tik elgsena, patiriama naudojant visą numatytąjį Rails steką.

Šiuo atveju norime dokumentuoti _framework_'o elgseną, o ne tik šį konkretų metodą.

Jei turite klausimų, kaip Rails komanda tvarko tam tikrą API, nebijokite atidaryti užklausos arba siųsti pataisymą į [problemos sekimo sistemą](https://github.com/rails/rails/issues).
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
