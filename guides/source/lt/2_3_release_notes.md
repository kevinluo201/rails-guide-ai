**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 77b47af4826df984dead9f6263cfd135
Ruby on Rails 2.3 Išleidimo pastabos
===============================

Rails 2.3 įgyvendina įvairias naujas ir patobulintas funkcijas, įskaitant visapusišką Rack integraciją, atnaujintą palaikymą Rails Engines, įdėtines transakcijas Active Record, dinamines ir numatytas sritis, vieningą atvaizdavimą, efektyvesnį maršrutizavimą, taikomųjų šablonų ir tylų atgalines sekas. Šis sąrašas apima pagrindinius atnaujinimus, tačiau neįtraukia kiekvienos mažos klaidos taisymo ir pakeitimo. Jei norite pamatyti viską, peržiūrėkite [įsipareigojimų sąrašą](https://github.com/rails/rails/commits/2-3-stable) pagrindiniame „Rails“ saugykloje „GitHub“ arba peržiūrėkite „CHANGELOG“ failus atskiriems „Rails“ komponentams.

--------------------------------------------------------------------------------

Programos architektūra
------------------------

„Rails“ programų architektūroje yra dvi pagrindinės pokyčių: visiška [Rack](https://rack.github.io/) modulinio interneto serverio sąsajos integracija ir atnaujintas palaikymas „Rails Engines“.

### Rack integracija

„Rails“ dabar nutraukė savo CGI praeitį ir visur naudoja Rack. Tai reikalavo ir sukėlė didžiulį vidinių pakeitimų skaičių (bet jei naudojate CGI, nesijaudinkite; „Rails“ dabar palaiko CGI per tarpinę sąsają). Vis dėlto tai yra didelis pokytis „Rails“ viduje. Po atnaujinimo į 2.3 versiją, turėtumėte išbandyti savo vietinę aplinką ir gamybos aplinką. Keletas dalykų, kuriuos reikia išbandyti:

* Sesionai
* Slapukai
* Failų įkėlimai
* JSON/XML API

Čia pateikiamas santrauka apie susijusius su Rack pokyčius:

* `script/server` dabar naudoja Rack, tai reiškia, kad jis palaiko bet kurį Rack suderinamą serverį. `script/server` taip pat naudos rackup konfigūracijos failą, jei jis egzistuoja. Pagal numatytuosius nustatymus jis ieškos `config.ru` failo, bet tai galima pakeisti naudojant `-c` perjungiklį.
* FCGI tvarkyklė eina per Rack.
* `ActionController::Dispatcher` išlaiko savo numatytąjį tarpinės programinės įrangos paketą. Tarpinės programinės įrangos galima įterpti, pertvarkyti ir pašalinti. Paleidus, šis paketas kompiliuojamas į grandinę. Tarpinės programinės įrangos paketą galima konfigūruoti `environment.rb` faile.
* Pridėtas `rake middleware` užduotis, skirta tikrinti tarpinės programinės įrangos paketo tvarką. Tai naudinga, jei norite atlikti tarpinės programinės įrangos paketo tvarkos derinimą.
* Integruotojo testo vykdytojas buvo modifikuotas, kad vykdytų visą tarpinės programinės įrangos paketą ir programos paketą. Tai padaro integracinius testus puikiai tinkamus tarpinės programinės įrangos paketui testuoti.
* `ActionController::CGIHandler` yra atgalinės suderinamos CGI apvalkalas, kuris naudoja Rack. „CGIHandler“ skirtas senam CGI objektui priimti ir konvertuoti jo aplinkos informaciją į Rack suderinamą formą.
* Pašalinti `CgiRequest` ir `CgiResponse`.
* Sesionų saugyklos dabar yra tingiai įkraunamos. Jei niekada nenaudojate sesijos objekto užklausos metu, ji niekada nebandys įkelti sesijos duomenų (analizuoti slapuką, įkelti duomenis iš memcache ar ieškoti „Active Record“ objekto).
* Jums nebūtina naudoti `CGI::Cookie.new` savo testuose, norint nustatyti slapuko reikšmę. Priskyrus `String` reikšmę `request.cookies["foo"]`, slapukas bus nustatytas kaip tikėtasi.
* `CGI::Session::CookieStore` pakeistas į `ActionController::Session::CookieStore`.
* `CGI::Session::MemCacheStore` pakeistas į `ActionController::Session::MemCacheStore`.
* `CGI::Session::ActiveRecordStore` pakeistas į `ActiveRecord::SessionStore`.
* Vis tiek galite pakeisti savo sesijos saugyklą naudodami `ActionController::Base.session_store = :active_record_store`.
* Numatytosios sesijos parinktys vis dar nustatomos naudojant `ActionController::Base.session = { :key => "..." }`. Tačiau `:session_domain` parinktis buvo pervadinta į `:domain`.
* Jūsų visos užklausos įvyniojimo grandinė dabar yra vidinė programinė įranga, `ActionController::Lock`.
* `ActionController::AbstractRequest` ir `ActionController::Request` buvo sujungti. Naujasis `ActionController::Request` paveldi iš `Rack::Request`. Tai veikia prieiga prie `response.headers['type']` testo užklausose. Vietoj to naudokite `response.content_type`.
* Jei įkelta `ActiveRecord`, į tarpinės programinės įrangos paketą automatiškai įterpiamas `ActiveRecord::QueryCache` programinės įrangos paketas. Ši programinė įranga nustato ir išvalo per užklausą aktyvaus įrašo užklausų talpyklą.
* „Rails“ maršrutizatorius ir valdiklių klasės atitinka Rack specifikaciją. Galite tiesiogiai paskambinti valdikliui naudodami `SomeController.call(env)`. Maršrutizatorius saugo maršrutizavimo parametrus `rack.routing_args`.
* `ActionController::Request` paveldi iš `Rack::Request`.
* Vietoj `config.action_controller.session = { :session_key => 'foo', ...` naudokite `config.action_controller.session = { :key => 'foo', ...`.
* Naudodamas `ParamsParser` programinės įrangos paketą, galite iš anksto apdoroti bet kokias XML, JSON ar YAML užklausas, kad jos būtų galima skaityti normaliai su bet kuriuo `Rack::Request` objektu po to.
Dokumentacija
-------------

[Ruby on Rails vadovai](https://guides.rubyonrails.org/) projektas išleido kelis papildomus vadovus Rails 2.3 versijai. Be to, [atskiras tinklalapis](https://edgeguides.rubyonrails.org/) palaiko atnaujintas Rails vadovų kopijas. Kiti dokumentacijos projektai apima [Rails wiki](http://newwiki.rubyonrails.org/) atnaujinimą ir ankstyvą planavimą dėl Rails knygos.

* Daugiau informacijos: [Rails dokumentacijos projektai](https://weblog.rubyonrails.org/2009/1/15/rails-documentation-projects)

Ruby 1.9.1 palaikymas
------------------

Rails 2.3 turėtų sėkmingai praeiti visus savo testus, nepriklausomai nuo to, ar naudojate Ruby 1.8, ar jau išleistą Ruby 1.9.1 versiją. Tačiau turėtumėte žinoti, kad pereinant į 1.9.1 versiją, reikia patikrinti visus duomenų adapterius, įskaitant įskiepius ir kitą kodą, nuo kurio priklauso Ruby 1.9.1 suderinamumas, taip pat ir Rails pagrindas.

Active Record
-------------

Active Record gavo daug naujų funkcijų ir klaidų taisymų Rails 2.3 versijoje. Svarbiausios naujovės apima įdėtinius atributus, įdėtines transakcijas, dinaminius ir numatytuosius taikinius bei partijų apdorojimą.

### Įdėtiniai atributai

Active Record dabar gali tiesiogiai atnaujinti įdėtinių modelių atributus, jei tam leidžiate:

```ruby
class Book < ActiveRecord::Base
  has_one :author
  has_many :pages

  accepts_nested_attributes_for :author, :pages
end
```

Įjungus įdėtinius atributus, įmanoma automatiškai (ir atomiškai) išsaugoti įrašą kartu su susijusiais vaikais, atlikti vaiko sąmoningus patikrinimus ir palaikyti įdėtinius formos laukus (apie tai bus kalbama vėliau).

Taip pat galite nurodyti reikalavimus naujiems įrašams, kurie yra pridedami per įdėtinius atributus, naudodami `:reject_if` parinktį:

```ruby
accepts_nested_attributes_for :author,
  :reject_if => proc { |attributes| attributes['name'].blank? }
```

* Pagrindinis prisidėjusysis: [Eloy Duran](http://superalloy.nl/)
* Daugiau informacijos: [Įdėtinių modelių formos](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)

### Įdėtinės transakcijos

Active Record dabar palaiko įdėtines transakcijas, ilgai lauktą funkciją. Dabar galite rašyti kodą taip:

```ruby
User.transaction do
  User.create(:username => 'Admin')
  User.transaction(:requires_new => true) do
    User.create(:username => 'Regular')
    raise ActiveRecord::Rollback
  end
end

User.find(:all)  # => Grąžina tik Admin
```

Įdėtinės transakcijos leidžia atšaukti vidinę transakciją, nepaveikiant išorinės transakcijos būsenos. Jei norite, kad transakcija būtų įdėtinė, turite aiškiai pridėti `:requires_new` parinktį; kitu atveju, įdėtinė transakcija tiesiog tampa dalimi pagrindinės transakcijos (kaip tai daroma dabar Rails 2.2 versijoje). Viduje įdėtinės transakcijos naudojamos [išsaugojimo taškai](http://rails.lighthouseapp.com/projects/8994/tickets/383), todėl jos veikia net ir duomenų bazėse, kuriose nėra tikrų įdėtinių transakcijų. Taip pat yra šiek tiek magijos, kad šios transakcijos gerai veiktų su transakcijų fiksuotuvėmis testavimo metu.

* Pagrindiniai prisidėjusieji: [Jonathan Viney](http://www.workingwithrails.com/person/4985-jonathan-viney) ir [Hongli Lai](http://izumi.plan99.net/blog/)

### Dinaminiai taikiniai

Jūs žinote apie dinaminius paieškos metodus Rails (leidžiančius dinamiškai kurti metodus, pvz., `find_by_color_and_flavor`) ir vardinius taikinius (leidžiančius įtraukti pakartotinai naudojamus užklausos sąlygas į draugiškus pavadinimus, pvz., `currently_active`). Na, dabar galite turėti dinaminius taikinių metodus. Idėja yra sukurti sintaksę, kuri leidžia dinamiškai filtruoti ir metodų grandinėlę. Pavyzdžiui:

```ruby
Order.scoped_by_customer_id(12)
Order.scoped_by_customer_id(12).find(:all,
  :conditions => "status = 'open'")
Order.scoped_by_customer_id(12).scoped_by_status("open")
```

Nereikia nieko apibrėžti, kad naudotumėte dinaminius taikinius: jie tiesiog veikia.

* Pagrindinis prisidėjusysis: [Yaroslav Markin](http://evilmartians.com/)
* Daugiau informacijos: [Kas naujo Edge Rails: Dinaminiai taikinių metodai](http://archives.ryandaigle.com/articles/2008/12/29/what-s-new-in-edge-rails-dynamic-scope-methods)

### Numatytieji taikiniai

Rails 2.3 versijoje bus įvestas _numatytųjų taikinių_ sąvoka, panaši į vardinius taikinius, tačiau taikoma visiems vardiniams taikiniams arba find metodams modelyje. Pavyzdžiui, galite parašyti `default_scope :order => 'name ASC'` ir kiekvieną kartą, kai gaunate įrašus iš to modelio, jie bus surūšiuoti pagal pavadinimą (išskyrus, jei pakeisite parinktį).

* Pagrindinis prisidėjusysis: Paweł Kondzior
* Daugiau informacijos: [Kas naujo Edge Rails: Numatytasis taikinimas](http://archives.ryandaigle.com/articles/2008/11/18/what-s-new-in-edge-rails-default-scoping)

### Partijų apdorojimas

Dabar galite apdoroti didelį kiekį įrašų iš Active Record modelio, mažinant atminties naudojimą, naudodami `find_in_batches`:

```ruby
Customer.find_in_batches(:conditions => {:active => true}) do |customer_group|
  customer_group.each { |customer| customer.update_account_balance! }
end
```

Į `find_in_batches` galite perduoti daugumą `find` parinkčių. Tačiau negalite nurodyti įrašų grąžinimo tvarkos (jie visada bus grąžinami pagal pagrindinio rakto didėjimo tvarką, kuris turi būti sveikasis skaičius) arba naudoti `:limit` parinkties. Vietoj to, naudokite `:batch_size` parinktį, kuri pagal numatytuosius nustatymus yra 1000, nustatyti, kiek įrašų bus grąžinama kiekvienoje partijoje.

Naujasis `find_each` metodas apgaubia `find_in_batches` ir grąžina atskirus įrašus, o paieška pati vykdoma partijomis (pagal numatytuosius nustatymus po 1000):

```ruby
Customer.find_each do |customer|
  customer.update_account_balance!
end
```
Atkreipkite dėmesį, kad šią metodą turėtumėte naudoti tik masiniam apdorojimui: mažų įrašų (mažiau nei 1000) atveju turėtumėte naudoti įprastus paieškos metodus su savo ciklu.

* Daugiau informacijos (tuo metu patogus metodas buvo vadintas tiesiog "each"):
    * [Rails 2.3: Grupinė paieška](http://afreshcup.com/2009/02/23/rails-23-batch-finding/)
    * [Kas naujo Edge Rails: Grupinė paieška](http://archives.ryandaigle.com/articles/2009/2/23/what-s-new-in-edge-rails-batched-find)

### Kelios sąlygos atgaliniam iškvietimui

Naudojant Active Record atgalinius iškvietimus, dabar galite derinti `:if` ir `:unless` parinktis tame pačiame atgaliniame iškvietime ir pateikti kelias sąlygas kaip masyvą:

```ruby
before_save :update_credit_rating, :if => :active,
  :unless => [:admin, :cash_only]
```
* Pagrindinis prisidėjusysis: L. Caviola

### Paieška su turinio sąlyga

Rails dabar turi `:having` parinktį paieškai (taip pat `has_many` ir `has_and_belongs_to_many` asociacijoms), skirtą filtruoti įrašus grupuotose paieškose. Kaip žmonės su gilia SQL patirtimi žino, tai leidžia filtruoti pagal grupuotus rezultatus:

```ruby
developers = Developer.find(:all, :group => "salary",
  :having => "sum(salary) > 10000", :select => "salary")
```

* Pagrindinis prisidėjusysis: [Emilio Tagua](https://github.com/miloops)

### Prisijungimo prie MySQL atnaujinimas

MySQL palaiko prisijungimo vėl jungimo vėliavą - jei ji nustatyta kaip true, tada klientas bandys prisijungti prie serverio iš naujo, jei ryšys bus prarastas. Dabar galite nustatyti `reconnect = true` savo MySQL prisijungimams `database.yml`, kad gautumėte šį elgesį iš Rails aplikacijos. Numatytoji reikšmė yra `false`, todėl esamų aplikacijų elgesys nepasikeičia.

* Pagrindinis prisidėjusysis: [Dov Murik](http://twitter.com/dubek)
* Daugiau informacijos:
    * [Automatinio prisijungimo elgesio valdymas](http://dev.mysql.com/doc/refman/5.6/en/auto-reconnect.html)
    * [MySQL automatinio prisijungimo peržiūra](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/49d2a7e9c96cb9f4)

### Kiti Active Record pakeitimai

* Iš generuojamo SQL pašalintas papildomas `AS` iš `has_and_belongs_to_many` išankstinio įkėlimo, todėl tai geriau veikia kai kuriems duomenų bazėms.
* `ActiveRecord::Base#new_record?` dabar grąžina `false`, o ne `nil`, kai susiduria su esamu įrašu.
* Ištaisytas klaida, susijusi su lentelių pavadinimų citavimu kai kuriuose `has_many :through` asociacijose.
* Dabar galite nurodyti konkretų laiko žymeklį `updated_at` žymekliams: `cust = Customer.create(:name => "ABC Industries", :updated_at => 1.day.ago)`
* Geresnės klaidų pranešimai, kai nepavyksta `find_by_attribute!` iškvietimai.
* Active Record `to_xml` palaikymas tampa šiek tiek lankstesnis pridedant `:camelize` parinktį.
* Ištaisytas klaida, susijusi su atšaukiant atgalinius iškvietimus iš `before_update` arba `before_create`.
* Pridėtos Rake užduotys, skirtos duomenų bazių testavimui per JDBC.
* `validates_length_of` naudos tinkamą klaidos pranešimą su `:in` arba `:within` parinktimis (jei yra pateikta).
* Skaičiavimai su apribotais pasirinkimais dabar veikia tinkamai, todėl galite daryti tokias operacijas kaip `Account.scoped(:select => "DISTINCT credit_limit").count`.
* `ActiveRecord::Base#invalid?` dabar veikia kaip `ActiveRecord::Base#valid?` priešingybė.
* Pagrindinis prisidėjėjas: [Gregg Kellogg](http://www.kellogg-assoc.com/)
* Daugiau informacijos: [Kas naujo Edge Rails: HTTP Digest autentifikacija](http://archives.ryandaigle.com/articles/2009/1/30/what-s-new-in-edge-rails-http-digest-authentication)

### Efektyvesnis maršrutizavimas

Rails 2.3 yra keletas svarbių maršrutizavimo pakeitimų. `formatted_` maršrutų pagalbininkai išnyko, vietoje jų dabar tiesiog perduodamas `:format` kaip parinktis. Tai sumažina maršrutų generavimo procesą 50% bet kokiam ištekliui - ir gali sutaupyti ženkliai daug atminties (iki 100 MB dideliuose programuose). Jei jūsų kodas naudoja `formatted_` pagalbinius metodus, jie vis dar veiks kol kas - tačiau šis elgesys yra pasenus ir jūsų programa bus efektyvesnė, jei perrašysite tuos maršrutus naudodami naują standartą. Kitas didelis pokytis yra tai, kad Rails dabar palaiko kelis maršrutų failus, ne tik `routes.rb`. Galite naudoti `RouteSet#add_configuration_file` bet kuriuo metu įkelti daugiau maršrutų - nereikia išvalyti jau įkeltų maršrutų. Nors šis pokytis yra naudingiausias varikliams, jį galima naudoti bet kurioje programoje, kuriai reikia įkelti maršrutus partijomis.

* Pagrindiniai prisidėjėjai: [Aaron Batalion](http://blog.hungrymachine.com/)

### Lazdinis sesijų įkėlimas pagrįstas Rack

Didelis pokytis nukreipė Action Controller sesijų saugojimo pagrindus į Rack lygį. Tai reikalavo daug darbo kode, tačiau tai turėtų būti visiškai nematomas jūsų Rails programoms (kaip papildomą naudą, buvo pašalinti keletas neaiškių pataisų senajame CGI sesijų tvarkyklėje). Tačiau tai vis dar yra svarbu dėl vieno paprasto dalyko: ne-Rails Rack programos turi prieigą prie to paties sesijų saugojimo tvarkyklės (ir todėl tos pačios sesijos) kaip ir jūsų Rails programos. Be to, sesijos dabar yra lazdiškai įkeliama (atitinkamai su kitais pagrindinio rėmo darbo pagerinimais). Tai reiškia, kad jums nebeprireiks išjungti sesijų, jei jų nenorite; tiesiog jų nenurodykite ir jos nebus įkeltos.

### MIME tipo tvarkymo pokyčiai

Yra keletas pakeitimų kode, skirtame MIME tipų tvarkymui Rails. Pirmiausia, `MIME::Type` dabar įgyvendina `=~` operatorių, kas padaro daug tvarkingesnį, kai reikia patikrinti, ar yra sinonimų turintis tipas:

```ruby
if content_type && Mime::JS =~ content_type
  # daryk kažką nuostabaus
end

Mime::JS =~ "text/javascript"        => true
Mime::JS =~ "application/javascript" => true
```

Kitas pokytis yra tai, kad pagrindinė rėmo dalis dabar naudoja `Mime::JS`, kai tikrinama, ar yra JavaScript įvairiose vietose, tai leidžia tvarkingai tvarkyti šiuos variantus.

* Pagrindinis prisidėjėjas: [Seth Fitzsimmons](http://www.workingwithrails.com/person/5510-seth-fitzsimmons)

### `respond_to` optimizavimas

Kai kurie `respond_to` metodo optimizavimai yra vienas iš pirmųjų vaisių iš Rails-Merb komandos sujungimo, kurie yra žinoma, kad yra labai naudojami daugelyje Rails programų, leidžiantys jūsų valdikliui skirtingai formatuoti rezultatus pagal gautų užklausų MIME tipą. Pašalinus `method_missing` iškvietimą ir atlikus keletą profiliavimo ir derinimo veiksmų, matome 8% pagerinimą užklausų skaičiu per sekundę, aptarnaujamų su paprastu `respond_to`, kuris keičia tris formatus. Geriausia dalis? Jūsų programos kodui nereikia jokio pakeitimo, kad pasinaudotumėte šiuo pagreitėjimu.

### Gerintas talpyklos našumas

Rails dabar laiko per užklausą vietinę talpyklą, kuri yra nuskaityta iš nuotolinės talpyklos, taip sumažinant nereikalingus skaitymus ir pagerinant svetainės našumą. Nors šis darbas pradinai buvo apribotas `MemCacheStore`, jis yra prieinamas bet kuriai nuotolinės talpyklos tvarkyklei, kuri įgyvendina reikiamus metodus.

* Pagrindinis prisidėjėjas: [Nahum Wild](http://www.motionstandingstill.com/)

### Lokalizuotos vaizdai

Rails dabar gali pateikti lokalizuotus vaizdus, priklausomai nuo nustatytos lokalės. Pavyzdžiui, tarkime, turite `Posts` valdiklį su `show` veiksmu. Pagal numatytuosius nustatymus, tai atvaizduos `app/views/posts/show.html.erb`. Bet jei nustatysite `I18n.locale = :da`, tai atvaizduos `app/views/posts/show.da.html.erb`. Jei lokalizuotas šablonas nėra, bus naudojamas neapipavidalintas versijas. Rails taip pat įtraukia `I18n#available_locales` ir `I18n::SimpleBackend#available_locales`, kurie grąžina masyvą su vertimais, kurie yra prieinami esamoje Rails projekte.

Be to, galite naudoti tą patį schemą, kad lokalizuotumėte gelbėjimo failus viešajame kataloge: `public/500.da.html` arba `public/404.en.html` veikia, pavyzdžiui.

### Dalinis apimtis vertimams

Pakeitimas vertimo API padaro dalykus lengvesnius ir mažiau kartojančius rašyti raktų vertimus daliniuose. Jei iš `people/index.html.erb` šablono iškviečiate `translate(".foo")`, iš tikrųjų iškviečiate `I18n.translate("people.index.foo")`. Jei nepridedate raktui taško priekyje, API netaikys apimties, kaip ir anksčiau.
### Kiti Action Controller pakeitimai

* ETag tvarkymas buvo šiek tiek patobulintas: kai nėra atsakymo kūno arba siunčiant failus su `send_file`, Rails dabar praleis siųsti ETag antraštę.
* Faktas, kad Rails tikrina IP suklastojimą, gali būti nepatogus svetainėms, kurios turi didelį srautą iš mobiliojo ryšio telefonų, nes jų tarpininkai paprastai neteisingai nustato nustatymus. Jei tai jūs, dabar galite nustatyti `ActionController::Base.ip_spoofing_check = false`, kad išjungtumėte tikrinimą visiškai.
* `ActionController::Dispatcher` dabar įgyvendina savo vidinį middleware rinkinį, kurį galite pamatyti paleidę `rake middleware`.
* Slapuko sesijos dabar turi nuolatinį sesijos identifikatorių, kuris yra suderinamas su serverio pusės saugyklos API.
* Dabar galite naudoti simbolius `:type` parinktyje `send_file` ir `send_data`, pavyzdžiui: `send_file("fabulous.png", :type => :png)`.
* `:only` ir `:except` parinktys `map.resources` daugiau nėra paveldimos įvesties resursams.
* Pridėtas memcached klientas atnaujintas iki 1.6.4.99 versijos.
* `expires_in`, `stale?` ir `fresh_when` metodai dabar priima `:public` parinktį, kad gerai veiktų su tarpinio talpinimo.
* `:requirements` parinktis dabar teisingai veikia su papildomais RESTful nario maršrutais.
* Paviršiniai maršrutai dabar tinkamai gerbia vardų erdves.
* `polymorphic_url` geriau tvarko objektus su nereguliariais daugiskaitos pavadinimais.

Action View
-----------

Rails 2.3 versijoje Action View įgyvendina įdėtinių modelio formų, `render` patobulinimų, lankstesnių datos pasirinkimo pagalbininkų ir pagreitėjimą turtų talpinime, tarp kitų dalykų.

### Įdėtinių objektų formos

Jei pagrindinė modelis priima įdėtinius atributus vaiko objektams (kaip aptarta Aktyviame įraše skyriuje), galite kurti įdėtines formas naudodami `form_for` ir `field_for`. Šios formos gali būti įdėtos bet kokiu gylį, leisdamos jums redaguoti sudėtingus objektų hierarchijas viename rodinyje be perteklinio kodo. Pavyzdžiui, turint tokį modelį:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders

  accepts_nested_attributes_for :orders, :allow_destroy => true
end
```

Galite parašyti šį rodinį Rails 2.3 versijoje:

```html+erb
<% form_for @customer do |customer_form| %>
  <div>
    <%= customer_form.label :name, 'Customer Name:' %>
    <%= customer_form.text_field :name %>
  </div>

  <!-- Čia mes iškviečiame fields_for ant customer_form kūrėjo pavyzdžio.
   Blokas yra iškviestas kiekvienam užsakymų kolekcijos nariui. -->
  <% customer_form.fields_for :orders do |order_form| %>
    <p>
      <div>
        <%= order_form.label :number, 'Order Number:' %>
        <%= order_form.text_field :number %>
      </div>

  <!-- allow_destroy parinktis modelyje įgalina vaiko įrašų trynimą. -->
      <% unless order_form.object.new_record? %>
        <div>
          <%= order_form.label :_delete, 'Remove:' %>
          <%= order_form.check_box :_delete %>
        </div>
      <% end %>
    </p>
  <% end %>

  <%= customer_form.submit %>
<% end %>
```

* Pagrindinis prisidėjusysis: [Eloy Duran](http://superalloy.nl/)
* Daugiau informacijos:
    * [Įdėtinių modelio formų](https://weblog.rubyonrails.org/2009/1/26/nested-model-forms)
    * [complex-form-examples](https://github.com/alloy/complex-form-examples)
    * [Kas naujo Edge Rails: Įdėtinių objektų formos](http://archives.ryandaigle.com/articles/2009/2/1/what-s-new-in-edge-rails-nested-attributes)

### Išmanusis dalinių rodinimas

`render` metodas per metus tapo vis išmanesnis, ir dabar jis dar išmanesnis. Jei turite objektą ar kolekciją ir tinkamą dalinį, ir pavadinimai atitinka, dabar tiesiog galite rodyti objektą ir viskas veiks. Pavyzdžiui, Rails 2.3 versijoje šie `render` kvietimai veiks jūsų rodinyje (jei pavadinimai yra protingi):

```ruby
# Ekvivalentas render :partial => 'articles/_article',
# :object => @article
render @article

# Ekvivalentas render :partial => 'articles/_article',
# :collection => @articles
render @articles
```

* Daugiau informacijos: [Kas naujo Edge Rails: render nebereikalauja daug priežiūros](http://archives.ryandaigle.com/articles/2008/11/20/what-s-new-in-edge-rails-render-stops-being-high-maintenance)

### Datos pasirinkimo pagalbininkų pasirinkimai

Rails 2.3 versijoje galite nurodyti pasirinktinius pasirinkimus įvairiems datos pasirinkimo pagalbininkams (`date_select`, `time_select` ir `datetime_select`), taip pat kaip ir kolekcijos pasirinkimo pagalbininkams. Galite nurodyti pasirinkimo eilutę arba maišą su atskirais pasirinkimo eilučių tekstais skirtingiems komponentams. Taip pat galite tiesiog nustatyti `:prompt` reikšmę `true`, kad naudotumėte pasirinkimo bendrinį pasirinkimą:

```ruby
select_datetime(DateTime.now, :prompt => true)

select_datetime(DateTime.now, :prompt => "Choose date and time")

select_datetime(DateTime.now, :prompt =>
  {:day => 'Choose day', :month => 'Choose month',
   :year => 'Choose year', :hour => 'Choose hour',
   :minute => 'Choose minute'})
```

* Pagrindinis prisidėjusysis: [Sam Oliver](http://samoliver.com/)

### Turtų žymės laiko talpinimas

Tikriausiai jums žinoma, kad Rails prideda laiko žymes prie statinių turtų kelių kaip "podėklio sugadinimo" priemonę. Tai padeda užtikrinti, kad pasenusios kopijos, pvz., paveikslėliai ir stiliaus lapai, nebus siunčiami iš vartotojo naršyklės podėlio, kai juos pakeičiate serveryje. Dabar galite keisti šį elgesį naudodami `cache_asset_timestamps` konfigūracijos parinktį Action View. Jei įjungiate podėklio talpinimą, tada Rails apskaičiuos laiko žymę tik kartą, kai pirmą kartą aptarnaus turtą, ir išsaugos tą reikšmę. Tai reiškia mažiau (brangių) failų sistemos kvietimų, skirtų aptarnauti statinius turtus - bet tai taip pat reiškia, kad negalite keisti jokių turtų, kol serveris veikia, ir tikėtis, kad klientai pastebės pokyčius.
### Turtiniai objektai kaip turto serveriai

Turtų serveriai tampa lankstesni edge Rails, galimybe deklaruoti turto serverį kaip konkretų objektą, kuris atsako į kvietimą. Tai leidžia jums įgyvendinti bet kokią sudėtingą logiką, kurią jums reikia jūsų turto serverio talpinime.

* Daugiau informacijos: [asset-hosting-with-minimum-ssl](https://github.com/dhh/asset-hosting-with-minimum-ssl/tree/master)

### grouped_options_for_select pagalbinės funkcijos metodas

Veiksmo rodinys jau turėjo daug pagalbinių funkcijų, padedančių generuoti pasirinkimo valdiklius, bet dabar yra dar vienas: `grouped_options_for_select`. Šis priima masyvą arba hashą su eilutėmis ir juos konvertuoja į `option` žymas, apgaubtas `optgroup` žymomis. Pavyzdžiui:

```ruby
grouped_options_for_select([["Kepurės", ["Basebolo kepurė", "Kovbojų kepurė"]]],
  "Kovbojų kepurė", "Pasirinkite produktą...")
```

grąžina

```html
<option value="">Pasirinkite produktą...</option>
<optgroup label="Kepurės">
  <option value="Basebolo kepurė">Basebolo kepurė</option>
  <option selected="selected" value="Kovbojų kepurė">Kovbojų kepurė</option>
</optgroup>
```

### Išjungtos parinkties žymos formos pasirinkimo pagalbininkams

Formos pasirinkimo pagalbininkai (tokie kaip `select` ir `options_for_select`) dabar palaiko `:disabled` parinktį, kuri gali priimti vieną reikšmę arba reikšmių masyvą, kurios bus išjungtos rezultatų žymose:

```ruby
select(:post, :category, Post::CATEGORIES, :disabled => 'private')
```

grąžina

```html
<select name="post[category]">
<option>story</option>
<option>joke</option>
<option>poem</option>
<option disabled="disabled">private</option>
</select>
```

Taip pat galite naudoti anoniminę funkciją, kad nustatytumėte vykdymo metu, kurie pasirinkimai iš kolekcijų bus pasirinkti ir/arba išjungti:

```ruby
options_from_collection_for_select(@product.sizes, :name, :id, :disabled => lambda{|size| size.out_of_stock?})
```

* Pagrindinis prisidėjusysis: [Tekin Suleyman](http://tekin.co.uk/)
* Daugiau informacijos: [New in rails 2.3 - disabled option tags and lambdas for selecting and disabling options from collections](https://tekin.co.uk/2009/03/new-in-rails-23-disabled-option-tags-and-lambdas-for-selecting-and-disabling-options-from-collections)

### Pastaba apie šablonų įkėlimą

Rails 2.3 įtraukia galimybę įjungti arba išjungti talpyklą šablonams bet kurioje konkretiame aplinkoje. Talpyklos šablonai suteikia jums greitį, nes jie nesitikrina naujo šablono failo, kai jie yra atvaizduojami, tačiau tai taip pat reiškia, kad negalite pakeisti šablono "iš karto" be serverio paleidimo.

Daugeliu atvejų norėsite, kad šablonų talpinimas būtų įjungtas gamyboje, tai galite padaryti nustatydami parametrą savo `production.rb` faile:

```ruby
config.action_view.cache_template_loading = true
```

Ši eilutė jums bus sugeneruota pagal numatytuosius nustatymus naujoje Rails 2.3 programoje. Jei atnaujinote iš senesnės Rails versijos, Rails pagal numatymą talpins šablonus gamyboje ir testuose, bet ne vystymosi metu.

### Kitos veiksmo rodinio pakeitimai

* CSRF apsaugos žetonų generavimas supaprastintas; dabar Rails naudoja paprastą atsitiktinį eilutę, sugeneruotą naudojant `ActiveSupport::SecureRandom`, o ne manipuliuoja sesijos ID.
* `auto_link` dabar tinkamai taiko parinktis (tokias kaip `:target` ir `:class`) sugeneruotoms el. pašto nuorodoms.
* `autolink` pagalbininkas buvo pertvarkytas, kad būtų šiek tiek tvarkingesnis ir intuityvesnis.
* `current_page?` dabar veikia tinkamai net tada, kai URL yra kelios užklausos parametrų.

Active Support
--------------

Active Support turi keletą įdomių pakeitimų, įskaitant `Object#try` įvedimą.

### Object#try

Daugelis žmonių priėmė idėją naudoti `try()` bandant atlikti operacijas su objektais. Tai ypač naudinga rodiniuose, kur galite išvengti `nil` tikrinimo, rašydami kodą kaip `<%= @person.try(:name) %>`. Na, dabar tai yra tiesiogine prasme įtraukta į Rails. Kaip įgyvendinta Rails, ji iškelia `NoMethodError` privatiems metodams ir visada grąžina `nil`, jei objektas yra `nil`.

* Daugiau informacijos: [try()](http://ozmm.org/posts/try.html)

### Object#tap atgalinė versija

`Object#tap` yra papildymas [Ruby 1.9](http://www.ruby-doc.org/core-1.9/classes/Object.html#M000309) ir 1.8.7, kuris panašus į `returning` metodą, kurį Rails jau turėjo ilgą laiką: jis perduoda bloką ir tada grąžina perduotą objektą. Rails dabar įtraukia kodą, kad tai būtų prieinama ir senesnėse Ruby versijose.

### Keičiami analizatoriai XMLmini

Aktyviojoje paramoje XML analizavimo parametrai tapo lankstesni, leidžiantys pakeisti skirtingus analizatorius. Pagal numatytuosius nustatymus naudojama standartinė REXML implementacija, bet savo programose galite lengvai nurodyti greitesnes LibXML ar Nokogiri implementacijas, jei įdiegėte atitinkamus paketus:

```ruby
XmlMini.backend = 'LibXML'
```

* Pagrindinis prisidėjusysis: [Bart ten Brinke](http://www.movesonrails.com/)
* Pagrindinis prisidėjusysis: [Aaron Patterson](http://tenderlovemaking.com/)

### Laiko su sekundėmis dalimis TimeWithZone

`Time` ir `TimeWithZone` klasės įtraukia `xmlschema` metodą, skirtą grąžinti laiką XML draugiškoje eilutėje. Nuo Rails 2.3, `TimeWithZone` palaiko tą pačią argumentą, skirtą nurodyti grąžinamos eilutės dalies skaitmenų skaičiui, kaip ir `Time`:

```ruby
Time.zone.now.xmlschema(6) # => "2009-01-16T13:00:06.13653Z"
```
* Pagrindinis prisidėjėjas: [Nicholas Dainty](http://www.workingwithrails.com/person/13536-nicholas-dainty)

### JSON rakto citavimas

Jei pažvelgsite į specifikaciją "json.org" svetainėje, sužinosite, kad visi raktai JSON struktūroje turi būti eilutės ir turi būti cituojami dvigubais kabutėmis. Pradedant nuo Rails 2.3, mes čia darome teisingą dalyką, net su skaitiniais raktais.

### Kiti Active Support pakeitimai

* Galite naudoti `Enumerable#none?`, kad patikrintumėte, ar nė vienas elementas neatitinka pateiktos bloko sąlygos.
* Jei naudojate Active Support [delegatus](https://afreshcup.com/home/2008/10/19/coming-in-rails-22-delegate-prefixes), naujoji `:allow_nil` parinktis leidžia grąžinti `nil`, o ne iškelti išimtį, kai tikslinis objektas yra `nil`.
* `ActiveSupport::OrderedHash`: dabar įgyvendina `each_key` ir `each_value`.
* `ActiveSupport::MessageEncryptor` suteikia paprastą būdą užšifruoti informaciją, skirtą saugoti nepatikimoje vietoje (pvz., slapukų).
* Active Support `from_xml` daugiau neprisideda nuo XmlSimple. Vietoj to, Rails dabar įtraukia savo XmlMini įgyvendinimą, turintį tik reikalingą funkcionalumą. Tai leidžia Rails atsisakyti kartu vežamo XmlSimple kopijos.
* Jei memoizavote privačią metodą, rezultatas dabar bus privatus.
* `String#parameterize` priima pasirinktinį skyriklį: `"Quick Brown Fox".parameterize('_') => "quick_brown_fox"`.
* `number_to_phone` dabar priima 7 skaitmenų telefono numerius.
* `ActiveSupport::Json.decode` dabar tvarko `\u0000` stiliaus išsisukinėjimo seka.

Railties
--------

Be aukščiau aptartų Rack pakeitimų, Railties (paties Rails pagrindinio kodo) turi keletą svarbių pakeitimų, įskaitant Rails Metal, aplikacijos šablonus ir tylų atgalinį iškvietimą.

### Rails Metal

Rails Metal yra naujas mechanizmas, kuris suteikia labai greitus taškus jūsų Rails aplikacijose. Metal klasės apeina maršrutizavimą ir Action Controller, suteikdamos jums gryną greitį (žinoma, už tai mokant viską, kas yra Action Controller). Tai remiasi visais pastaraisiais pagrindiniais darbais, kad Rails taptų Rack aplikacija su atidengtu middleware paketu. Metal taškai gali būti įkelti iš jūsų aplikacijos arba iš įskiepių.

* Daugiau informacijos:
    * [Introducing Rails Metal](https://weblog.rubyonrails.org/2008/12/17/introducing-rails-metal)
    * [Rails Metal: a micro-framework with the power of Rails](http://soylentfoo.jnewland.com/articles/2008/12/16/rails-metal-a-micro-framework-with-the-power-of-rails-m)
    * [Metal: Super-fast Endpoints within your Rails Apps](http://www.railsinside.com/deployment/180-metal-super-fast-endpoints-within-your-rails-apps.html)
    * [What's New in Edge Rails: Rails Metal](http://archives.ryandaigle.com/articles/2008/12/18/what-s-new-in-edge-rails-rails-metal)

### Aplikacijos šablonai

Rails 2.3 įtraukia Jeremy McAnally [rg](https://github.com/jm/rg) aplikacijos generatorių. Tai reiškia, kad dabar turime šablonų pagrindu veikiančią aplikacijų generavimo sistemą, įdiegtą tiesiogiai į Rails; jei turite rinkinį įskiepių, kurį įtraukiate į kiekvieną aplikaciją (tarp daugelio kitų naudojimo atvejų), galite tiesiog nustatyti šabloną vieną kartą ir naudoti jį visą laiką, kai paleidžiate `rails` komandą. Taip pat yra rake užduotis, skirta taikyti šabloną esamai aplikacijai:

```bash
$ rake rails:template LOCATION=~/template.rb
```

Tai pritaikys šablono pakeitimus virš bet kokio kodo, kurį projektas jau turi.

* Pagrindinis prisidėjėjas: [Jeremy McAnally](http://www.jeremymcanally.com/)
* Daugiau informacijos: [Rails šablonai](http://m.onkey.org/2008/12/4/rails-templates)

### Tylesni atgaliniai iškvietimai

Remiantis thoughtbot [Quiet Backtrace](https://github.com/thoughtbot/quietbacktrace) įskiepiu, kuris leidžia selektyviai pašalinti eilutes iš `Test::Unit` atgalinių iškvietimų, Rails 2.3 įgyvendina `ActiveSupport::BacktraceCleaner` ir `Rails::BacktraceCleaner` pagrindinėje dalyje. Tai palaiko tiek filtrus (atlikti regex pagrindu pakeitimus atgalinių iškvietimų eilutėse), tiek tylintis (visiškai pašalinti atgalinių iškvietimų eilutes). Rails automatiškai prideda tylintis, kad atsikratytų dažniausiai pasitaikančio triukšmo naujoje aplikacijoje, ir sukuria `config/backtrace_silencers.rb` failą, kuriame galite pridėti savo pačių pakeitimus. Ši funkcija taip pat leidžia gražiau spausdinti bet kurioje juostoje esančius gemus.

### Greitesnis paleidimo laikas kūrimo režime su tingiu įkėlimu/automatiniu įkėlimu

Buvo atliktas daug darbo, kad būtų užtikrinta, jog Rails dalys (ir jų priklausomybės) įkeliama į atmintį tik tada, kai jos iš tikrųjų reikalingos. Pagrindiniai pagrindai - Active Support, Active Record, Action Controller, Action Mailer ir Action View - dabar naudoja `autoload`, kad tingiai įkeltų atskiras klases. Šis darbas turėtų padėti išlaikyti atminties naštą žemą ir pagerinti bendrą Rails našumą.

Taip pat galite nurodyti (naujos `preload_frameworks` parinkties naudojimu), ar pagrindinės bibliotekos turėtų būti įkeliama į atmintį paleidimo metu. Pagal numatytuosius nustatymus tai yra `false`, todėl Rails tingiai įkelia save dalimis, tačiau yra keletas aplinkybių, kai vis tiek reikia viską įkelti iš karto - Passenger ir JRuby nori matyti visą įkeltą Rails.

### rake gem užduoties persirašymas

Skirtingų <code>rake gem</code> užduočių vidinės dalys buvo žymiai peržiūrėtos, kad sistema geriau veiktų įvairiais atvejais. Dabar gem sistema žino skirtumą tarp plėtros ir vykdymo priklausomybių, turi patikimesnę išpakuojimo sistemą, suteikia geresnę informaciją, kai ieškoma gemų būklės, ir mažiau linkusi į "vištos ir kiaušinio" priklausomybių problemas, kai viską kuriate iš naujo. Taip pat yra pataisymai naudojant gem komandas naudojant JRuby ir priklausomybėms, kurios bando įtraukti išorines gemų kopijas, kurios jau yra pardavė.
* Pagrindinis bendradarbis: [David Dollar](http://www.workingwithrails.com/person/12240-david-dollar)

### Kiti Railties pakeitimai

* Atnaujintos ir išplėstos instrukcijos, kaip atnaujinti CI serverį, kad jis galėtų sukurti Rails.
* Vidiniai Rails testai buvo perjungti nuo `Test::Unit::TestCase` iki `ActiveSupport::TestCase`, o Rails branduolys reikalauja Mocha testams atlikti.
* Numatytasis `environment.rb` failas buvo išvalytas.
* dbconsole scenarijus dabar leidžia naudoti visiškai skaitmeninį slaptažodį be programos nulūžimo.
* `Rails.root` dabar grąžina `Pathname` objektą, tai reiškia, kad galite jį naudoti tiesiogiai su `join` metodu, kad [sutvarkytumėte esamą kodą](https://afreshcup.wordpress.com/2008/12/05/a-little-rails_root-tidiness/), kuris naudoja `File.join`.
* Įvairūs /public aplankale esantys failai, susiję su CGI ir FCGI išsiuntimu, daugiau nekuriami kiekviename Rails aplikacijoje pagal numatytuosius nustatymus (vis tiek galite juos gauti, jei jums reikia, pridedant `--with-dispatchers`, kai paleidžiate `rails` komandą, arba pridėkite juos vėliau naudodami `rake rails:update:generate_dispatchers`).
* Rails vadovai buvo konvertuoti iš AsciiDoc į Textile žymėjimą.
* Scaffolded vaizdai ir valdikliai buvo šiek tiek išvalyti.
* `script/server` dabar priima `--path` argumentą, kad galėtumėte prijungti Rails aplikaciją iš konkretaus kelio.
* Jei trūksta bet kurių sukonfigūruotų juvelyrinių akmenų, juvelyrinių akmenų rake užduotys praleis daugelį aplinkos įkėlimo. Tai turėtų išspręsti daugelį "vištos ir kiaušinio" problemų, kai rake gems:install negalėjo paleisti, nes trūko juvelyrinių akmenų.
* Juvelyriniai akmenys dabar išpakuojami tik vieną kartą. Tai ištaisys problemas su juvelyriniais akmenimis (pvz., hoe), kurie yra supakuoti su skaitymo teisėmis failams.

Pasenusi informacija
----------

Šiame leidime yra keletas pasenusio kodo:

* Jei esate vienas iš (gana retų) Rails kūrėjų, kuris diegia taip, kad priklauso nuo inspector, reaper ir spawner scenarijų, turėsite žinoti, kad šie scenarijai daugiau neįtraukti į pagrindinį Rails. Jei jums reikia jų, galėsite gauti kopijas per [irs_process_scripts](https://github.com/rails/irs_process_scripts) įskiepį.
* `render_component` nuo šiol iš "pasenusio" tampa "neegzistuojančiu" Rails 2.3. Jei jums vis dar reikia jo, galite įdiegti [render_component įskiepį](https://github.com/rails/render_component/tree/master).
* Palaikymas Rails komponentams buvo pašalintas.
* Jei buvote vienas iš žmonių, kurie įprato paleisti `script/performance/request` scenarijų, kad galėtumėte stebėti našumą pagal integracijos testus, turite išmokti naują triuką: šis scenarijus dabar pašalintas iš pagrindinio Rails. Yra naujas request_profiler įskiepis, kurį galite įdiegti, kad gautumėte tą pačią funkcionalumą atgal.
* `ActionController::Base#session_enabled?` yra pasenusi, nes dabar sesijos yra tingiai įkeliama.
* `:digest` ir `:secret` parametrai `protect_from_forgery` yra pasenusi ir neturi jokio poveikio.
* Kai kurie integracijos testų pagalbininkai buvo pašalinti. `response.headers["Status"]` ir `headers["Status"]` daugiau nebebus grąžinami. Rack neleidžia "Status" savo grąžinimo antraštėse. Tačiau vis tiek galite naudoti `status` ir `status_message` pagalbinius metodus. `response.headers["cookie"]` ir `headers["cookie"]` daugiau nebebus grąžinami jokie CGI slapukai. Galite patikrinti `headers["Set-Cookie"]` norėdami pamatyti neapdorotą slapuko antraštę arba naudoti `cookies` pagalbininką, kad gautumėte klientui išsiųstų slapukų maišą.
* `formatted_polymorphic_url` yra pasenusi. Vietoj to naudokite `polymorphic_url` su `:format`.
* `:http_only` parametras `ActionController::Response#set_cookie` buvo pervadintas į `:httponly`.
* `:connector` ir `:skip_last_comma` parametrai `to_sentence` buvo pakeisti į `:words_connector`, `:two_words_connector` ir `:last_word_connector` parametrus.
* Siunčiant daugialypę formą su tuščiu `file_field` kontrolės elementu, anksčiau buvo siunčiama tuščia eilutė į valdiklį. Dabar siunčiama `nil`, dėl skirtumo tarp Rack daugialypės analizės ir senojo Rails analizės.

Kreditai
-------

Leidimo pastabas sudarė [Mike Gunderloy](http://afreshcup.com). Šios Rails 2.3 leidimo pastabos buvo sudarytos remiantis Rails 2.3 RC2.
