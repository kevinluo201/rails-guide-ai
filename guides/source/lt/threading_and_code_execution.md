**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: ffc6bf535a0dbd3487837673547ae486
Gijimo ir kodo vykdymas „Rails“
=====================================

Po šio vadovo perskaitymo žinosite:

* Kokią kodą „Rails“ automatiškai vykdo vienu metu
* Kaip integruoti rankinį lygiagretumą su „Rails“ vidiniais komponentais
* Kaip apgaubti visą programos kodą
* Kaip paveikti programos perkrovimą

--------------------------------------------------------------------------------

Automatinis lygiagretumas
---------------------

„Rails“ automatiškai leidžia atlikti įvairias operacijas vienu metu.

Naudojant gijinį interneto serverį, pvz., numatytąjį „Puma“, kelios HTTP užklausos bus aptarnaujamos tuo pačiu metu, kiekvienai užklausai suteikiant jos pačios valdiklio egzempliorių.

Gijinės „Active Job“ adapteriai, įskaitant įdiegtąjį „Async“, taip pat vykdys kelias užduotis vienu metu. Taip pat taip valdomi ir „Action Cable“ kanalai.

Visi šie mechanizmai apima kelias gijas, kurios kiekviena tvarko darbą tam tikram objekto egzemplioriui (valdiklis, užduotis, kanalas), tuo pačiu dalindamos bendrą procesų erdvę (tokią kaip klasės ir jų konfigūracijos, globalūs kintamieji). Jei jūsų kodas nepakeičia šių bendrų dalykų, jis daugiausia gali ignoruoti kitas gijas.

Šio vadovo likusi dalis aprašo mechanizmus, kuriuos „Rails“ naudoja, kad tai būtų „daugiausia ignoruojama“, ir kaip juos gali naudoti plėtiniai ir programos su specialiais poreikiais.

Vykdytojas
--------

„Rails“ vykdytojas atskiria programos kodą nuo pagrindo kodo: kiekvieną kartą, kai pagrindas iškviečia jūsų parašytą kodą jūsų programoje, jis bus apgaubtas vykdytoju.

Vykdytojas susideda iš dviejų atgalinių iškvietimų: `to_run` ir `to_complete`. „Run“ atgalinis iškvietimas yra iškviečiamas prieš programos kodą, o „Complete“ atgalinis iškvietimas yra iškviečiamas po jo.

### Numatytieji atgaliniai iškvietimai

Numatytoje „Rails“ programoje vykdytojo atgaliniai iškvietimai naudojami šiems tikslams:

* stebėti, kurios gijos yra saugiose padėtyse autokrovimui ir perkrovimui
* įjungti ir išjungti „Active Record“ užklausų kešą
* grąžinti gautus „Active Record“ ryšius į baseiną
* apriboti vidinio kešo gyvavimo laiką

Iki „Rails“ 5.0 šie dalykai buvo tvarkomi atskirais „Rack“ tarpiniais sluoksniais (tokiais kaip „ActiveRecord::ConnectionAdapters::ConnectionManagement“) arba tiesiog apgaubiant kodą metodais, pvz., „ActiveRecord::Base.connection_pool.with_connection“. Vykdytojas juos pakeičia vienu abstrakčesniu sąsaja.

### Programos kodo apgaubimas

Jei rašote biblioteką ar komponentą, kuris iškvies programos kodą, turėtumėte jį apgaubti vykdytojo iškvietimu:

```ruby
Rails.application.executor.wrap do
  # čia iškviečiamas programos kodas
end
```

PATARIMAS: Jei nuolat iškviečiate programos kodą iš ilgai veikiančio proceso, galite jį apgaubti naudodami [Perkrovėją](#perkrovėjas) vietoj to.

Kiekviena gija turėtų būti apgaubta prieš vykdant programos kodą, todėl jei jūsų programa rankiniu būdu perduoda darbą kitoms gijoms, pvz., naudojant `Thread.new` arba „Concurrent Ruby“ funkcijas, kurios naudoja gijų baseinus, turėtumėte nedelsdami apgaubti bloką:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # jūsų kodas čia
  end
end
```

PASTABA: „Concurrent Ruby“ naudoja „ThreadPoolExecutor“, kurį kartais konfigūruoja su „executor“ parinktimi. Nepaisant pavadinimo, tai nesusiję.

Vykdytojas yra saugiai reentrantas; jei jis jau aktyvus dabartinėje gijoje, „wrap“ nevykdo jokios veiksmų.

Jei nepraktiška apgaubti programos kodo bloku (pvz., „Rack“ API tai apsunkina), galite naudoti `run!` / `complete!` porą:

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # jūsų kodas čia
ensure
  execution_context.complete! if execution_context
end
```

### Lygiagretumas

Vykdytojas įterpia dabartinę giją į „vykdomą“ būseną [Krovimo sąsaja](#krovimo-sąsaja). Ši operacija laikinai blokuos, jei kita gija šiuo metu autokrauna konstantą arba iškrauna/perkrauna programą.

Perkrovėjas
--------

Kaip ir Vykdytojas, Perkrovėjas taip pat apgaubia programos kodą. Jei Vykdytojas dar neaktyvus dabartinėje gijoje, Perkrovėjas jį iškvies už jus, todėl jums tereikia iškviesti tik vieną. Tai taip pat užtikrina, kad viskas, ką daro Perkrovėjas, įskaitant visus jo atgalinių iškvietimų iškvietimus, vyksta apgaubtoje Vykdytojo viduje.

```ruby
Rails.application.reloader.wrap do
  # čia iškviečiamas programos kodas
end
```

Perkrovėjas tinkamas tik ten, kur ilgai veikiantis pagrindo lygmens procesas nuolat iškviečia programos kodą, pvz., interneto serveriui ar užduočių eilei. „Rails“ automatiškai apgaubia interneto užklausas ir „Active Job“ darbininkus, todėl retai kada reikės iškviesti Perkrovėją patiems. Visada apsvarstykite, ar Vykdytojas yra tinkamesnis jūsų naudojimo atvejui.

### Atgaliniai iškvietimai

Prieš įeinant į apgaubtą bloką, Perkrovėjas patikrins, ar reikia perkrauti veikiančią programą - pavyzdžiui, jei modelio šaltinio failas buvo pakeistas. Jei nustatoma, kad perkrovimas yra būtinas, jis palauks, kol tai bus saugu, ir tada tai padarys, prieš tęsdamas. Kai programa sukonfigūruota visada perkrauti, nepaisant to, ar aptinkami pakeitimai, perkrovimas vykdomas bloko pabaigoje.
Reloader taip pat teikia `to_run` ir `to_complete` atgalinio kvietimo funkcijas; jos yra iškviestos tais pačiais taškais kaip ir Executor, bet tik tada, kai dabartinis vykdymas inicijavo programos perkrovimą. Kai nėra laikoma, kad perkrovimas yra būtinas, Reloader iškviečia apgaubto bloko be kitų atgalinių kvietimų.

### Klasės iškrovimas

Svarbiausia perkrovimo proceso dalis yra Klasės iškrovimas, kai visos automatiškai įkeltos klasės yra pašalinamos, kad būtų galima jas vėl įkelti. Tai įvyks tuojau prieš Run arba Complete atgalinį kvietimą, priklausomai nuo `reload_classes_only_on_change` nustatymo.

Dažnai reikia atlikti papildomus perkrovimo veiksmus arba tiesiog po Klasės iškrovimo, todėl Reloader taip pat teikia `before_class_unload` ir `after_class_unload` atgalinius kvietimus.

### Lygiagretumas

Tik ilgai veikiantys "viršutinio lygio" procesai turėtų kviečti Reloader, nes jei jis nustato, kad perkrovimas yra būtinas, jis blokuos, kol visi kiti gijos baigs visus Executor kvietimus.

Jei tai įvyktų "vaiko" gijoje, kurioje laukia tėvas viduje Executor, tai sukeltų neišvengiamą užstrigimą: perkrovimas turi įvykti prieš vykdant vaiko giją, bet jis negali būti saugiai atliktas, kol tėvo gija yra viduryje vykdymo. Vaiko gijos turėtų naudoti vietoj to Executor.

Karkaso elgsena
------------------

Rails karkaso komponentai taip pat naudoja šiuos įrankius, kad valdytų savo lygiagretumo poreikius.

`ActionDispatch::Executor` ir `ActionDispatch::Reloader` yra Rack vidurinės programinės įrangos, kurios apgaubia užklausas su pateiktu Executor arba Reloader atitinkamai. Jos automatiškai įtrauktos į numatytąją programos eilutę. Reloader užtikrins, kad kiekviena atvykusi HTTP užklausa būtų aptarnaujama su naujausia įkelta programos kopija, jei įvyko kokios nors kodų pakeitimai.

Active Job taip pat apgaubia savo darbo vykdymą su Reloader, įkeliant naujausią kodą, kad būtų galima vykdyti kiekvieną darbą, kai jis išeina iš eilės.

Action Cable vietoj to naudoja Executor: nes kabelio ryšys yra susietas su konkretaus klasės egzemplioriumi, neįmanoma perkrauti kiekvienos atvykstančios WebSocket žinutės. Tačiau apgaubiamas tik žinutės tvarkytojas; ilgai veikiantis kabelio ryšys neleidžia perkrovai, kurią sukelia nauja atvykstanti užklausa ar darbas. Vietoj to, Action Cable naudoja Reloader `before_class_unload` atgalinį kvietimą, kad atjungtų visus savo ryšius. Kai klientas automatiškai prisijungs iš naujo, jis kalbės su kodo nauja versija.

Aukščiau pateikti yra karkaso įėjimo taškai, todėl jie atsakingi už tai, kad jų atitinkamos gijos būtų apsaugotos ir nuspręstų, ar perkrovimas yra būtinas. Kiti komponentai turi naudoti Executor tik tada, kai jie paleidžia papildomas gijas.

### Konfigūracija

Reloader tikrina failų pakeitimus tik tada, kai `config.enable_reloading` yra `true`, taip pat `config.reload_classes_only_on_change`. Tai yra numatytieji nustatymai `development` aplinkoje.

Kai `config.enable_reloading` yra `false` (numatytasis `production`), Reloader yra tik perduodamas į Executor.

Executor visada turi svarbų darbą, pvz., duomenų bazės prisijungimų valdymą. Kai `config.enable_reloading` yra `false` ir `config.eager_load` yra `true` (numatytieji `production` nustatymai), nebus vykdomas perkrovimas, todėl jam nereikia įkrovos užrakto. Su numatytosiomis `development` aplinkos nustatymais Executor naudos įkrovos užraktą, kad užtikrintų, jog konstantos būtų įkeltos tik tada, kai tai yra saugu.

Įkrovos užraktas
--------------

Įkrovos užraktas leidžia įjungti automatinį įkėlimą ir perkrovimą daugiausiai gijų aplinkoje.

Kai viena gija atlieka automatinį įkėlimą, įvertindama klasės apibrėžimą iš tinkamo failo, svarbu, kad kitos gijos neatitiktų dalinai apibrėžtos konstantos nuorodos.

Panašiai, saugu atlikti iškrovimą/perkrovimą tik tada, kai jokia programos kodas nevykdomas: po perkrovimo, pavyzdžiui, `User` konstanta gali rodyti į kitą klasę. Be šios taisyklės, blogai laiku atliktas perkrovimas reikštų, kad `User.new.class == User`, arba net `User == User`, gali būti netiesa.

Abu šie apribojimai yra sprendžiami naudojant įkrovos užraktą. Jis seka, kurios gijos šiuo metu vykdo programos kodą, įkelia klasę arba iškelia automatiškai įkeltas konstantas.

Tik viena gija gali įkelti arba iškelti vienu metu, ir norint tai padaryti, ji turi palaukti, kol kitos gijos nevykdo programos kodo. Jei gija laukia atlikti įkėlimą, tai neleidžia kitoms gijoms įkelti (iš tikrųjų jos bendradarbiaus ir kiekviena atliks savo eilėje esantį įkėlimą, prieš visi kartu vėl pradėdami vykdyti).

### `permit_concurrent_loads`

Executor automatiškai įgyvendina `running` užraktą per visą bloką, ir automatinis įkėlimas žino, kada perjungti į `load` užraktą ir po to vėl perjungti į `running`.
Kitos blokavimo operacijos, atliekamos viduje Executor bloko (į kurį įeina visos programos kodas), gali nereikalingai išlaikyti `running` užrakto. Jei kitas gijas susiduria su konstanta, kurią reikia automatiškai įkelti, tai gali sukelti užstrigimą.

Pavyzdžiui, jei `User` dar nėra įkeltas, tai sukels užstrigimą:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # vidinė gija laukia čia; ji negali įkelti
           # User, kol vyksta kita gija
    end
  end

  th.join # išorinė gija laukia čia, laikydamas 'running' užraktą
end
```

Norint išvengti šio užstrigimo, išorinė gija gali naudoti `permit_concurrent_loads` metodą. Iškvietus šį metodą, gija garantuoja, kad ji nebus nuorodinėjama į jokį galimai automatiškai įkeltą kintamąjį šaltiniame bloke. Saugiausias būdas įvykdyti šią pažadą yra jį įdėti kuo arčiau blokuojančio kvietimo:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # vidinė gija gali gauti 'load' užraktą,
           # įkelti User ir tęsti darbą
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # išorinė gija laukia čia, bet neturi užrakto
  end
end
```

Kitas pavyzdys, naudojant Concurrent Ruby:

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # atlikti darbą čia
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

Jei jūsų programa užstrigo ir manote, kad įsijungė Load Interlock, laikinai galite pridėti ActionDispatch::DebugLocks middleware prie `config/application.rb`:

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

Jei tuomet paleidžiate programą iš naujo ir vėl sukeliama užstrigimo būsena, `/rails/locks` rodo santrauką visų gijų, kurios žinomos interlock, kurios užraktą jos laiko ar laukia ir jų dabartinį atgalinį taką.

Paprastai užstrigimas bus sukeltas interlock konfliktuojant su kitu išoriniu užraktu ar blokuojančiu I/O kvietimu. Radus tai, galite jį apgaubti `permit_concurrent_loads`.
