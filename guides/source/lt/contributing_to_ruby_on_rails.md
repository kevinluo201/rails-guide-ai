**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 17dc214f52c294509e9b174971ef1ab3
Prisidėjimas prie Ruby on Rails
=============================

Šis vadovas aprašo, kaip _jūs_ galite tapti dalimi nuolatinio Ruby on Rails vystymosi.

Po šio vadovo perskaitymo jūs žinosite:

* Kaip naudoti GitHub, kad praneštumėte apie problemas.
* Kaip klonuoti pagrindinį kodą ir paleisti testų rinkinį.
* Kaip padėti išspręsti esamas problemas.
* Kaip prisidėti prie Ruby on Rails dokumentacijos.
* Kaip prisidėti prie Ruby on Rails kodo.

Ruby on Rails nėra "kito žmogaus karkasas". Per metus tūkstančiai žmonių prisidėjo prie Ruby on Rails, nuo vieno simbolio iki masinių architektūrinių pakeitimų ar svarbios dokumentacijos - visa tai, kad Ruby on Rails būtų geresnis visiems. Net jei dar nesijaučiate pajėgūs rašyti kodo ar dokumentacijos, yra įvairių kitų būdų, kuriuos galite prisidėti, nuo problemų pranešimo iki patikrinimo.

Kaip minima [Rails'io
README](https://github.com/rails/rails/blob/main/README.md), visi, kurie bendrauja su Rails ir jo sub-projektų kodu, problemų sekimo sistemomis, pokalbių kambariais, diskusijų forumais ir pašto sąrašais, turi laikytis Rails [elgesio kodekso](https://rubyonrails.org/conduct).

--------------------------------------------------------------------------------

Problemos pranešimas
------------------

Ruby on Rails naudoja [GitHub problemų sekimą](https://github.com/rails/rails/issues) norint sekti problemas (daugiausia klaidas ir naujo kodo indėlius). Jei radote klaidą Ruby on Rails, tai yra vieta, kur pradėti. Norėdami pateikti problemą, komentuoti problemas ar kurti pull užklausas, turėsite sukurti (nemokamą) GitHub paskyrą.

PASTABA: Klaidos naujausioje išleistoje Ruby on Rails versijoje tikriausiai sulauks daugiausia dėmesio. Be to, Rails branduolio komanda visada domisi atsiliepimais iš tų, kurie gali skirti laiko testuoti _edge Rails_ (kodo versijai, kuri šiuo metu yra vystoma). Vėliau šiame vadove sužinosite, kaip gauti edge Rails testavimui. Peržiūrėkite mūsų [palaikymo politiką](maintenance_policy.html), kad sužinotumėte, kurios versijos yra palaikomos. Niekada nepraneškite apie saugumo problemą GitHub problemų sekimo sistemoje.

### Klaidos pranešimo kūrimas

Jeigu radote problemą Ruby on Rails, kuri nėra saugumo rizika, ieškokite [Issues](https://github.com/rails/rails/issues) GitHub'e, galbūt ji jau buvo pranešta. Jei negalite rasti jokių atvirų GitHub problemų, kurios spręstų jūsų rastą problemą, jūsų kitas žingsnis bus [atidaryti naują problemą](https://github.com/rails/rails/issues/new). (Dėl saugumo problemų pranešimo žr. sekančią sekciją.)

Mes paruošėme problemos šabloną, kad galėtumėte įtraukti visą reikiamą informaciją, kuri padės nustatyti, ar karkase yra klaida. Kiekviena problema turi turėti pavadinimą ir aiškų problemos aprašymą. Įsitikinkite, kad įtraukiate kuo daugiau atitinkamos informacijos, įskaitant kodavimo pavyzdį arba nepavykusį testą, kuris parodo tikimąjį elgesį, taip pat jūsų sistemos konfigūraciją. Jūsų tikslas turėtų būti padaryti tai lengva tiek sau, tiek kitiems, kad galėtų atkartoti klaidą ir rasti sprendimą.

Kai atidarote problemą, ji gali arba negali būti aktyvi iš karto, nebent tai yra "Code Red, Mission Critical, the World is Coming to an End" tipo klaida. Tai nereiškia, kad mums nerūpi jūsų klaida, tiesiog yra daug problemų ir pull užklausų, kuriuos reikia peržiūrėti. Kiti žmonės, turintys tą patį problemą, gali rasti jūsų problemą, patvirtinti klaidą ir galbūt bendradarbiauti su jumis ją ištaisant. Jei žinote, kaip ištaisyti klaidą, drąsiai atidarykite pull užklausą.

### Sukurkite vykdomąjį testavimo atvejį

Turėti būdą atkartoti jūsų problemą padės žmonėms patvirtinti, ištirti ir galiausiai ištaisyti jūsų problemą. Tai galite padaryti pateikdami vykdomąjį testavimo atvejį. Norėdami palengvinti šį procesą, paruošėme keletą problemos pranešimo šablonų, kuriuos galite naudoti kaip pradžios tašką:

* Šablonas Active Record (modeliai, duomenų bazės) problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Šablonas testavimo Active Record (migracijos) problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Šablonas Action Pack (valdikliai, maršrutizavimas) problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Šablonas Active Job problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Šablonas Active Storage problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Šablonas Action Mailbox problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* Bendras šablonas kitoms problemoms: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

Šie šablonai įtraukia pagrindinį kodą, skirtą testavimo atvejui su išleista Rails versija (`*_gem.rb`) arba edge Rails versija (`*_main.rb`) nustatyti.
Nukopijuokite tinkamo šablono turinį į `.rb` failą ir atlikite būtinas pakeitimus, kad parodytumėte problemą. Galite jį paleisti, paleisdami `ruby the_file.rb` terminalo lange. Jei viskas gerai, turėtumėte pamatyti, kad jūsų testo atvejis nepavyksta.

Tada galite pasidalinti savo vykdomuoju testo atveju kaip [gist](https://gist.github.com) arba įklijuokite turinį į problemos aprašymą.

### Specialus apdorojimas saugumo problemoms

ĮSPĖJIMAS: Prašome nepranešti apie saugumo pažeidimus viešose GitHub problemų ataskaitose. [Rails saugumo politikos puslapyje](https://rubyonrails.org/security) yra nurodyta procedūra, kaip elgtis su saugumo problemomis.

### O kas dėl funkcijų prašymų?

Prašome neįtraukti "funkcijos prašymo" elementų į GitHub problemų ataskaitas. Jei norite matyti naują funkciją, kurią norite pridėti prie Ruby on Rails, turėsite parašyti kodą patys - arba įtikinti kitą asmenį partneriu parašyti kodą. Vėliau šiame vadove rasite išsamias instrukcijas, kaip pasiūlyti pataisą Ruby on Rails. Jei į GitHub problemų ataskaitas įvesite norų sąrašo elementą be kodo, galite tikėtis, kad jis bus pažymėtas "neleistinu", kai tik bus peržiūrėtas.

Kartais "klaidos" ir "funkcijos" riba yra sunkiai nustatoma. Paprastai funkcija yra bet kas, kas prideda naują elgesį, o klaida yra bet kas, kas sukelia neteisingą elgesį. Kartais pagrindinė komanda turės priimti sprendimą. Nepaisant to, skirtumas paprastai nustato, su kuria pataisa išleidžiamas jūsų pakeitimas; mes mylime funkcijos pateikimus! Tik jie nebus atgalinio portavimo įlaikyti.

Jei norite gauti atsiliepimą apie idėją dėl funkcijos prieš atlikdami darbą, kad sukurtumėte pataisą, prašome pradėti diskusiją [rails-core diskusijų forumo](https://discuss.rubyonrails.org/c/rubyonrails-core) dalyje. Jūs galite gauti jokio atsakymo, tai reiškia, kad visiems yra abejinga. Galbūt rasite kažką, kas taip pat domisi tuo funkciją kurti. Galbūt gausite "Tai nebus priimta". Bet tai yra tinkama vieta naujoms idėjoms aptarti. GitHub problemos nėra ypač geras forumas kartais ilgiems ir sudėtingiems naujų funkcijų aptarimams.

Padedant išspręsti esamas problemas
----------------------------------

Be problemų pranešimo, galite padėti pagrindinės komandai išspręsti esamas problemas teikdami apie jas atsiliepimus. Jei esate naujas Rails pagrindinės komandos plėtotojas, atsiliepimas padės jums susipažinti su kodu ir procesais.

Jei patikrinsite [problemos sąrašą](https://github.com/rails/rails/issues) GitHub problemose, rasite daugybę jau reikalaujančių dėmesio problemų. Ką galite daryti dėl jų? Iš tikrųjų gana daug:

### Klaidų ataskaitų patvirtinimas

Pradžioje padeda tik patvirtinti klaidų ataskaitas. Ar galite atkartoti praneštą problemą savo kompiuteryje? Jei taip, galite pridėti komentarą prie problemos, kad matote tą patį dalyką.

Jei problema yra labai neaiški, ar galite padėti ją susiaurinti iki kažko konkrečesnio? Galbūt galite pateikti papildomos informacijos, kad atkartotumėte klaidą, arba galbūt galite pašalinti nereikalingus žingsnius, kurie nėra būtini problemos parodymui.

Jei randa klaidos ataskaitą be testo, labai naudinga prisidėti priešingą testą. Tai taip pat puikus būdas tyrinėti šaltinio kodą: pažvelgus į esamus testų failus, išmoksite, kaip rašyti daugiau testų. Nauji testai geriausiai prisideda kaip pataisos, kaip vėliau paaiškinta [Prisidedant prie Rails kodo](#prisidedant-prie-rails-kodo) skyriuje.

Bet koks jūsų indėlis, kad klaidos ataskaitos būtų aiškesnės ar lengviau atkartojamos, padeda žmonėms, bandantiems rašyti kodą, kad ištaisytų tas klaidas - nepriklausomai nuo to, ar galiausiai patys rašote kodą, ar ne.

### Testavimo pataisos

Galite padėti ir tikrinti per GitHub pateiktus "pull request" užklausimus, kurie buvo pateikti Ruby on Rails. Norėdami taikyti kažkieno pakeitimus, pirmiausia sukurkite atskirą šaką:

```bash
$ git checkout -b testing_branch
```

Tada galite naudoti jų nuotolinę šaką, kad atnaujintumėte savo kodinę bazę. Pavyzdžiui, sakykime, kad GitHub naudotojas JohnSmith yra padalinęs ir nusiuntęs į temos šaką "orange", esančią adresu https://github.com/JohnSmith/rails.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

Alternatyva pridėti jų nuotolinę prie savo patikrinimo yra naudoti [GitHub CLI įrankį](https://cli.github.com/) norint patikrinti jų "pull request".

Po jų šakos pritaikymo, išbandykite! Čia yra keletas dalykų, kuriuos galite apsvarstyti:
* Ar pakeitimas iš tikrųjų veikia?
* Ar esate patenkintas testais? Ar galite suprasti, ką jie testuoja? Ar trūksta kokio nors testo?
* Ar jis turi tinkamą dokumentacijos aprėptį? Ar reikia atnaujinti dokumentaciją kitur?
* Ar jums patinka įgyvendinimas? Ar galite pagalvoti apie gražesnį ar greitesnį būdą įgyvendinti dalį jų pakeitimo?

Kai būsite patenkintas, kad „pull request“ yra geras pakeitimas, komentuokite „GitHub“ klausimą, nurodydami savo išvadas. Jūsų komentare turėtų būti nurodyta, kad jums patinka pakeitimas ir kas jums patinka. Kažkas panašaus į:

> Man patinka, kaip restruktūrizavote kodą „generate_finder_sql“ - daug gražiau. Testai atrodo gerai.

Jei jūsų komentaras tiesiog skaitomas "+1", tikimybės yra tokios, kad kiti recenzentai jo nebus labai rimtai vertinami. Parodykite, kad skyrėte laiko peržiūrėti „pull request“.

Prisidėjimas prie „Rails“ dokumentacijos
---------------------------------------

„Ruby on Rails“ turi dvi pagrindines dokumentacijos rinkinius: vadovus, kurie padeda jums išmokti „Ruby on Rails“, ir API, kuris tarnauja kaip nuorodinė medžiaga.

Galite padėti pagerinti „Rails“ vadovus arba API nuorodinę medžiagą, padarant juos sąsningesnius, nuoseklesnius ar skaitomesnius, pridėdant trūkstamą informaciją, taisant faktinius klaidas, taisant rašybos klaidas ar atnaujinant juos pagal naujausią „edge Rails“ versiją.

Tam padaryti, atlikite pakeitimus „Rails“ vadovų šaltinio failuose (rasti [čia](https://github.com/rails/rails/tree/main/guides/source) „GitHub“) arba RDoc komentaruose šaltinio kode. Tada atidarykite „pull request“, kad pritaikytumėte savo pakeitimus pagrindiniam šakos.

Dirbdami su dokumentacija, atkreipkite dėmesį į [API dokumentacijos gaires](api_documentation_guidelines.html) ir [„Ruby on Rails“ vadovų gaires](ruby_on_rails_guides_guidelines.html).

„Rails“ vadovų vertimas
------------------------

Džiaugiamės, kad žmonės savanoriauja vertindami „Rails“ vadovus. Tiesiog laikykitės šių žingsnių:

* Nukopijuokite https://github.com/rails/rails.
* Pridėkite šaltinio aplanką savo kalbai, pavyzdžiui: *guides/source/it-IT* italų kalbai.
* Nukopijuokite *guides/source* turinį į savo kalbos katalogą ir jį išversti.
* NEverkite HTML failų, nes jie automatiškai generuojami.

Atkreipkite dėmesį, kad vertimai nėra pateikiami į „Rails“ saugyklą; jūsų darbas gyvena jūsų šakoje, kaip aprašyta aukščiau. Tai yra todėl, kad praktiškai dokumentacijos priežiūra per patarimus yra tvarbi tik anglų kalba.

Norėdami sugeneruoti vadovus HTML formatu, turėsite įdiegti vadovų priklausomybes, `cd` į *guides* katalogą ir tada paleisti (pvz., it-IT):

```bash
# įdiekite tik priklausomybes, reikalingas vadovams. Atšaukti paleidus: bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

Tai sugeneruos vadovus *output* kataloge.

PASTABA: „Redcarpet“ juosta nesuveikia su „JRuby“.

Žinomi vertimo pastangos (įvairios versijos):

* **Italų**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Ispanų**: [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **Lenkų**: [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **Prancūzų**: [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Čekų**: [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turkų**: [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **Korėjiečių**: [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Supaprastinta kinų**: [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Tradicinė kinų**: [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Rusų**: [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japonų**: [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **Brazilų portugalų**: [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Prisidėjimas prie „Rails“ kodo
------------------------------

### Kūrimo aplinkos nustatymas

Norėdami pereiti nuo klaidų pateikimo iki pagalbos esamų problemų sprendime ar savo kodo prisidėjimo prie „Ruby on Rails“, _turite_ galėti paleisti jo testų rinkinį. Šioje vadovo dalyje sužinosite, kaip nustatyti testus savo kompiuteryje.

#### Naudodami „GitHub Codespaces“

Jei esate organizacijos narys, kurioje įgalinti „codespaces“, galite nukopijuoti „Rails“ į tą organizaciją ir naudoti „codespaces“ „GitHub“. „Codespace“ bus inicializuotas su visomis reikalingomis priklausomybėmis ir leis jums paleisti visus testus.

#### Naudodami „VS Code Remote Containers“

Jei turite [Visual Studio Code](https://code.visualstudio.com) ir [Docker](https://www.docker.com) įdiegtus, galite naudoti [VS Code remote containers plugin](https://code.visualstudio.com/docs/remote/containers-tutorial). Įskiepis perskaitys saugykloje esančią [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) konfigūraciją ir vietiniame kompiuteryje sukurs „Docker“ konteinerį.

#### Naudodami Dev Container CLI

Alternatyviai, su įdiegtu [Docker](https://www.docker.com) ir [npm](https://github.com/npm/cli), galite paleisti [Dev Container CLI](https://github.com/devcontainers/cli), kad naudotumėte saugykloje esančią [`.devcontainer`](https://github.com/rails/rails/tree/main/.devcontainer) konfigūraciją iš komandinės eilutės.

```bash
$ npm install -g @devcontainers/cli
$ cd rails
$ devcontainer up --workspace-folder .
$ devcontainer exec --workspace-folder . bash
```

#### Naudodami rails-dev-box

Taip pat galite naudoti [rails-dev-box](https://github.com/rails/rails-dev-box), kad gautumėte paruoštą kūrimo aplinką. Tačiau rails-dev-box naudoja „Vagrant“ ir „Virtual Box“, kurie neveiks „Mac“ su „Apple silicon“.
#### Vietinė plėtra

Kai negalite naudoti „GitHub Codespaces“, žr. [šį kitą vadovą](development_dependencies_install.html), kaip nustatyti vietinę plėtrą. Tai laikoma sunkesniu būdu, nes diegiant priklausomybes gali būti priklausoma nuo operacinės sistemos.

### Nuklonuokite „Rails“ saugyklą

Norėdami galėti prisidėti prie kodo, turite nuklonuoti „Rails“ saugyklą:

```bash
$ git clone https://github.com/rails/rails.git
```

ir sukurti atskirą šaką:

```bash
$ cd rails
$ git checkout -b mano_nauja_saka
```

Nesvarbu, kokią vardą naudosite, nes ši šaka egzistuos tik jūsų vietiniame kompiuteryje ir jūsų asmeninėje saugykloje „GitHub“. Ji nebus dalis „Rails“ „Git“ saugyklos.

### Įdiekite „Bundle“

Įdiekite reikalingas juvelyrines medžiagas.

```bash
$ bundle install
```

### Paleiskite programą naudodami vietinę šaką

Jei jums reikia fiktyvaus „Rails“ programos, skirtos pakeitimams testuoti, naudokite `--dev` žymą `rails new`, kad būtų sugeneruota programa, kuri naudoja jūsų vietinę šaką:

```bash
$ cd rails
$ bundle exec rails new ~/mano-testinė-programa --dev
```

Sugeneruota programa `~/mano-testinė-programa` veikia naudojant jūsų vietinę šaką ir ypač matys bet kokius pakeitimus paleidus serverį iš naujo.

JavaScript paketams galite naudoti [`yarn link`](https://yarnpkg.com/cli/link), kad savo vietinę šaką šaltinio programoje:

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/mano-testinė-programa
$ yarn link "@rails/activestorage"
```

### Rašykite savo kodą

Dabar laikas parašyti kodą! Keičiant „Rails“, turėkite omenyje šiuos dalykus:

* Laikykitės „Rails“ stiliaus ir konvencijų.
* Naudokite „Rails“ idiomus ir pagalbinius metodus.
* Įtraukite testus, kurie nepavyks be jūsų kodo ir pavyks su juo.
* Atnaujinkite (aplinkos) dokumentaciją, pavyzdžius kitur ir vadovus: visa tai, kas paveikta jūsų indėlio.
* Jei pakeitimas prideda, pašalina arba keičia funkciją, būtinai įtraukite įrašą į „CHANGELOG“. Jei jūsų pakeitimas yra klaidos taisymas, įrašas į „CHANGELOG“ nėra būtinas.

PATARIMAS: Kosmetiniai pakeitimai, kurie nepriklauso nuo stabilumo, funkcionalumo ar testuojamumo, paprastai nebus priimti (daugiau informacijos apie [mūsų sprendimo pagrindą](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### Laikykitės kodavimo konvencijų

„Rails“ laikosi paprastų kodavimo stiliaus konvencijų:

* Du tarpai, o ne tabuliacija (atitraukimui).
* Nėra tuščių tarpų gale. Tuščios eilutės neturėtų turėti jokių tarpų.
* Atitraukimas ir tuščia eilutė po privačių / apsaugotų.
* Naudojamas Ruby >= 1.9 sintaksė žodynuose. Pageidautina `{ a: :b }` vietoje `{ :a => :b }`.
* Pageidautina `&&`/`||` vietoje `and`/`or`.
* Pageidautina `class << self` vietoje `self.method` klasės metodams.
* Naudokite `my_method(my_arg)` vietoje `my_method( my_arg )` arba `my_method my_arg`.
* Naudokite `a = b` ir ne `a=b`.
* Naudokite `assert_not` metodus vietoje `refute`.
* Pageidautina `method { do_stuff }` vietoje `method{do_stuff}` vienos eilutės blokams.
* Laikykitės konvencijų, kurias matote naudojamas šaltinyje.

Aukščiau pateikti nurodymai - tai tik gairės - naudokite savo geriausią nuovoką, juos naudodami.

Be to, mes turime [RuboCop](https://www.rubocop.org/) taisykles, apibrėžtas, kad kodifikuotume kai kurias mūsų kodavimo konvencijas. Prieš pateikdami užklausą „pull request“, galite paleisti RuboCop vietiniame modifikuotame faile:

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Tikrinamas 1 failas
.

Tikrinamas 1 failas, nėra nusižengimų
```

„rails-ujs“ „CoffeeScript“ ir „JavaScript“ failams galite paleisti `npm run lint` „actionview“ aplanke.

#### Rašybos tikrinimas

Mes naudojame [misspell](https://github.com/client9/misspell), kuris yra pagrindinai parašytas
[Golang](https://golang.org/) tikrinti rašybą su [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml). Teisingai
dažnai klaidingai rašomi anglų kalbos žodžiai greitai su „misspell“. „misspell“ skiriasi nuo daugumos kitų rašybos tikrintuvų
dėl to, kad jis nenaudoja specialaus žodyno. Galite paleisti „misspell“ vietiniame režime visiems failams su:

```bash
$ find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

Pastebimi „misspell“ pagalbos variantai arba vėliavos:

- `-i` eilutė: ignoruoti šiuos pataisymus, atskirtus kableliais
- `-w`: perrašyti failą su pataisymais (numatytasis yra tik rodyti)

Mes taip pat naudojame [codespell](https://github.com/codespell-project/codespell) su „GitHub Actions“ tikrinti rašybą ir
[codespell](https://pypi.org/project/codespell/) veikia su [mažu papildomu žodynu](https://github.com/rails/rails/blob/main/codespell.txt).
„codespell“ parašytas [Python](https://www.python.org/) ir jį galite paleisti su:

```bash
$ codespell --ignore-words=codespell.txt
```

### Įvertinkite savo kodą

Keičiantys pakeitimai, kurie gali turėti įtakos našumui, prašome įvertinti savo
kodą ir išmatuokite poveikį. Prašome pasidalinti naudotu įvertinimo scenarijumi ir
rezultatais. Svarbu įtraukti šią informaciją į savo įsipareigojimų
pranešimą, kad ateityje prisidėję asmenys galėtų lengvai patikrinti jūsų išvadas ir
nustatyti, ar jos vis dar aktualios. (Pavyzdžiui, ateityje vykdomos optimizacijos
Ruby VM gali padaryti tam tikras optimizacijas nereikalingas.)
Optimizuojant konkrečiam scenarijui, kuriam jums rūpi, lengva prarasti našumą kitoms įprastoms situacijoms. Todėl turėtumėte išbandyti savo pakeitimus pagal atstovaujamų scenarijų sąrašą, idealiai išgautą iš realaus pasaulio produkcinės programinės įrangos.

Galite naudoti [benchmarko šabloną](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb) kaip pradžios tašką. Jame yra šabloninės kodas, skirtas sukurti benchmarką naudojant [benchmark-ips](https://github.com/evanphx/benchmark-ips) gemą. Šablonas skirtas testuoti santykinai savarankiškus pakeitimus, kurie gali būti įterpti į scenariją.

### Testų vykdymas

Rails nėra įprasta paleisti visą testų rinkinį prieš spausdinant pakeitimus. Ypač ilgai trunka railties testų rinkinys, ypač jei šaltinio kodas prijungtas prie `/vagrant`, kaip rekomenduojama naudojant [rails-dev-box](https://github.com/rails/rails-dev-box).

Kaip kompromisas, išbandykite tai, ką jūsų kodas akivaizdžiai veikia, ir jei pakeitimas nėra railties, paleiskite visą testų rinkinį, kurį paveikėte. Jei visi testai sėkmingai įvykdomi, tai pakanka pasiūlyti savo indėlį. Mums yra [Buildkite](https://buildkite.com/rails/rails) kaip saugos tinklas, kuris aptinka netikėtus sutrikimus kitur.

#### Visas Rails:

Norėdami paleisti visus testus, atlikite šias komandas:

```bash
$ cd rails
$ bundle exec rake test
```

#### Tam tikram komponentui

Galite paleisti testus tik tam tikram komponentui (pvz., Action Pack). Pavyzdžiui, paleiskite Action Mailer testus:

```bash
$ cd actionmailer
$ bin/test
```

#### Tam tikram katalogui

Galite paleisti testus tik tam tikram komponento katalogui (pvz., modeliams Active Storage). Pavyzdžiui, paleiskite testus `/activestorage/test/models` kataloge:

```bash
$ cd activestorage
$ bin/test models
```

#### Tam tikram failui

Galite paleisti testus tam tikram failui:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### Paleidimas vieno testo

Galite paleisti vieną testą pagal pavadinimą naudodami `-n` parinktį:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### Tam tikrai eilutei

Nustatyti pavadinimą kartais nėra lengva, bet jei žinote, nuo kurios eilutės prasideda jūsų testas, ši parinktis jums:

```bash
$ cd railties
$ bin/test test/application/asset_debugging_test.rb:69
```

#### Testų vykdymas su konkretaus sėklos reikšme

Testų vykdymas yra atsitiktinis su atsitiktinės sėklos reikšme. Jei patiriate atsitiktinių testų nesėkmę, galite tiksliau atkurti nesėkmingą testo scenarijų, nustatydami konkrečią atsitiktinės sėklos reikšmę.

Paleidus visus komponento testus:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

Paleidus vieną testo failą:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### Testų vykdymas sekančiai

Pagal nutylėjimą Action Pack ir Action View vienetiniai testai vykdomi lygiagrečiai. Jei patiriate atsitiktinių testų nesėkmę, galite nustatyti atsitiktinės sėklos reikšmę ir leisti šiems vienetiniams testams vykti sekančia tvarka, nustatydami `PARALLEL_WORKERS=1`.

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Active Record testavimas

Pirmiausia, sukurkite reikiamus duomenų bazes. Lentelių pavadinimų, vartotojo vardų ir slaptažodžių sąrašą galite rasti `activerecord/test/config.example.yml` faile.

MySQL ir PostgreSQL atveju pakanka paleisti:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```

Arba:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

Tai nereikalinga SQLite3 atveju.

Taip paleidžiate tik Active Record testų rinkinį tik su SQLite3:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

Dabar galite paleisti testus kaip ir `sqlite3`. Atitinkamos užduotys yra:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:trilogy
$ bundle exec rake test:postgresql
```

Galiausiai,

```bash
$ bundle exec rake test
```

dabar juos visus paleis vienas po kito.

Taip pat galite paleisti bet kurį atskirą testą atskirai:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

Norėdami paleisti vieną testą visais adapteriais, naudokite:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

Taip pat galite naudoti `test_jdbcmysql`, `test_jdbcsqlite3` arba `test_jdbcpostgresql`. Daugiau informacijos apie vykdomą tikslinės duomenų bazės testavimą rasite faile `activerecord/RUNNING_UNIT_TESTS.rdoc`.

#### Derinant testus su derintuvais

Norėdami naudoti išorinį derintuvą (pry, byebug ir kt.), įdiekite derintuvą ir naudokite jį kaip įprasta. Jei kyla derintuvo problemų, paleiskite testus sekančia tvarka, nustatydami `PARALLEL_WORKERS=1` arba paleiskite vieną testą su `-n test_long_test_name`.

### Įspėjimai

Testų rinkinys paleidžiamas su įspėjimais. Idealiu atveju, Ruby on Rails neturėtų kelti jokių įspėjimų, bet gali būti keli, taip pat ir iš trečiųjų šalių bibliotekų. Prašome ignoruoti (arba ištaisyti!), jei yra, ir pateikti pataisas, kurios nekelia naujų įspėjimų.
Rails CI pakils, jei bus įvestos įspėjimai. Norėdami įgyvendinti tą patį elgesį vietiniame aplinkos, paleidus testų rinkinį, nustatykite `RAILS_STRICT_WARNINGS=1`.

### Dokumentacijos atnaujinimas

Ruby on Rails [vadovėliai](https://guides.rubyonrails.org/) pateikia aukšto lygio apžvalgą apie Rails funkcijas, o [API dokumentacija](https://api.rubyonrails.org/) nagrinėja konkretumus.

Jei Jūsų PR prideda naują funkciją ar keičia esamą funkcionalumą, patikrinkite atitinkamą dokumentaciją ir atnaujinkite ją arba papildykite, kaip reikia.

Pavyzdžiui, jei modifikavote Active Storage paveikslėlio analizatorių, kad būtų pridėtas naujas metaduomenų laukas, turėtumėte atnaujinti Active Storage vadovėlio [Failų analizavimas](active_storage_overview.html#analyzing-files) skyrių, kad tai atspindėtų.

### CHANGELOG atnaujinimas

CHANGELOG yra svarbi kiekvieno leidimo dalis. Jame pateikiamas pakeitimų sąrašas kiekvienai Rails versijai.

Jei pridedate ar pašalinate funkcionalumą arba pridedate pasenusius pranešimus, turėtumėte pridėti įrašą **į viršų** pakeistos framework dalies CHANGELOG, jei modifikavote. Refaktorinimai, maži klaidų taisymai ir dokumentacijos pakeitimai paprastai neturėtų būti įtraukti į CHANGELOG.

CHANGELOG įrašas turėtų apibendrinti, kas buvo pakeista, ir turėtų baigtis autoriaus vardu. Jei reikia daugiau vietos, galite naudoti kelias eilutes, ir galite pridėti kodavimo pavyzdžius, įdėdami 4 tarpus. Jei pakeitimas susijęs su konkretaus problema, turėtumėte pridėti problemos numerį. Štai pavyzdinis CHANGELOG įrašas:

```
*   Pakeitimo santrauka, kuri trumpai apibūdina, kas buvo pakeista. Galite naudoti kelias
    eilutes ir jas apriboti apie 80 simbolių. Jei reikia, kodavimo pavyzdžiai yra geri:

        class Foo
          def bar
            puts 'baz'
          end
        end

    Po kodavimo pavyzdžiaus galite tęsti ir pridėti problemos numerį.

    Taiso #1234.

    *Jūsų Vardas*
```

Jūsų vardas gali būti pridėtas tiesiai po paskutinio žodžio, jei nėra kodavimo
pavyzdžių arba kelių pastraipų. Kitu atveju geriau sukurti naują pastraipą.

### Pakeitimai, kurie gali sukelti sutrikimus

Kiekvieną kartą, kai pakeitimas gali sugadinti esamas programas, jis laikomas pakeitimu, kuris gali sukelti sutrikimus. Norint palengvinti Rails programų atnaujinimą, pakeitimai, kurie gali sukelti sutrikimus, reikalauja pasenusio laikotarpio.

#### Elgesio pašalinimas

Jei Jūsų pakeitimas pašalina esamą elgesį, pirmiausia turėsite pridėti
pasenusį įspėjimą, tuo pačiu išlaikant esamą elgesį.

Pavyzdžiui, sakykime, norite pašalinti viešąją metodą iš
`ActiveRecord::Base`. Jei pagrindinė šaka rodo neįleistą 7.0 versiją,
Rails 7.0 turės rodyti pasenusį įspėjimą. Tai užtikrina, kad bet kas
atnaujinantis į bet kurią Rails 7.0 versiją matys pasenusį įspėjimą.
Rails 7.1 versijoje galima ištrinti metodą.

Galėtumėte pridėti šį pasenusį įspėjimą:

```ruby
def pasenusias_metodas
  ActiveRecord.deprecator.warn(<<-MSG.squish)
    `ActiveRecord::Base.pasenusias_metodas` yra pasenusias ir bus pašalintas Rails 7.1 versijoje.
  MSG
  # Esamas elgesys
end
```

#### Elgesio keitimas

Jei Jūsų pakeitimas keičia esamą elgesį, turėsite pridėti
framework numatytąjį elgesį. Framework numatytieji elgesiai palengvina Rails atnaujinimus, leisdami programoms pereiti prie naujų numatytųjų elgesių vienas po kito.

Norėdami įgyvendinti naują framework numatytąjį elgesį, pirmiausia sukurkite konfigūraciją, pridėdami prie tikslo framework prieigos teikėjo. Nustatykite numatytąją reikšmę esamam elgesiui, kad užtikrintumėte, jog niekas nesulaužys atnaujinimo metu.

```ruby
module ActiveJob
  mattr_accessor :esamas_elgesys, default: true
end
```

Nauja konfigūracija leidžia sąlygiškai įgyvendinti naują elgesį:

```ruby
def pakeistas_metodas
  if ActiveJob.esamas_elgesys
    # Esamas elgesys
  else
    # Naujas elgesys
  end
end
```

Norėdami nustatyti naują framework numatytąjį elgesį, nustatykite naują reikšmę
`Rails::Application::Configuration#load_defaults`:

```ruby
def load_defaults(target_version)
  case target_version.to_s
  when "7.1"
    ...
    if respond_to?(:active_job)
      active_job.esamas_elgesys = false
    end
    ...
  end
end
```

Norint palengvinti atnaujinimą, būtina pridėti naują numatytąjį elgesį
`new_framework_defaults` šablonui. Pridėkite užkomentuotą skyrių, nustatydami naują
reikšmę:

```ruby
# new_framework_defaults_7_1.rb.tt

# Rails.application.config.active_job.esamas_elgesys = false
```

Paskutiniu žingsniu pridėkite naują konfigūraciją į konfigūracijos vadovėlį
`configuration.md`:

```markdown
#### `config.active_job.esamas_elgesys`

| Pradedant nuo versijos | Numatytoji reikšmė yra |
| --------------------- | --------------------- |
| (originali)           | `true`                |
| 7.1                   | `false`               |
```

### Ignoruojant failus, sukurtus jūsų redaktoriaus / IDE

Kai kurie redaktoriai ir IDE kūrimo aplinkoje sukuria paslėptus failus ar aplankus `rails` aplanke. Vietoje rankiniu būdu išskiriant juos iš kiekvieno įsipareigojimo ar pridedant juos prie Rails `.gitignore`, turėtumėte juos pridėti prie savo [globalinio gitignore failo](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer).

### Gemfile.lock atnaujinimas

Kai kurie pakeitimai reikalauja priklausomybių atnaujinimo. Tokiais atvejais įsitikinkite, kad paleidote `bundle update`, kad gautumėte tinkamą priklausomybės versiją, ir įtraukite `Gemfile.lock` failą į savo pakeitimus.
### Įsitikinkite, kad įvykdėte pakeitimus

Kai esate patenkintas kodu savo kompiuteryje, turite įvykdyti pakeitimus "Git" repozitorijoje:

```bash
$ git commit -a
```

Tai turėtų atidaryti jūsų redaktorių, kad galėtumėte parašyti pranešimą apie įvykdytus pakeitimus. Kai baigsite, išsaugokite ir uždarykite redaktorių, kad tęstumėte.

Gerai suformatuotas ir aprašomasis įvykio pranešimas yra labai naudingas kitiems žmonėms, kad suprastų, kodėl buvo atliktas pakeitimas, todėl prašome skirti laiko jį parašyti.

Geras įvykio pranešimas atrodo taip:

```
Trumpas santrauka (idealus atvejis - ne daugiau kaip 50 simbolių)

Išsamesnis aprašymas, jei reikia. Kiekviena eilutė turėtų būti apribota iki
72 simbolių. Bandykite būti kuo aprašomesni. Net jei
manote, kad įvykio turinys yra akivaizdus, tai gali nebūti akivaizdu
kitiems. Pridėkite bet kokį aprašymą, kuris jau yra
susijusiose problemose; nereikėtų turėti būti būtina apsilankyti
svetainėje, kad patikrintumėte istoriją.

Aprašymo skyriuje gali būti kelios pastraipos.

Kodo pavyzdžiai gali būti įterpti, įtraukiant juos į 4 tarpus:

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

Taip pat galite pridėti sąrašo taškus:

- sąrašo tašką galima pradėti eilute, pradedant brūkšniu (-)
  arba žvaigždute (*)

- eilutes apribokite iki 72 simbolių ir įtraukite bet kokias papildomas eilutes
  su 2 tarpais, kad būtų lengva skaityti
```

PATARIMAS. Prašome suspausti savo įvykius į vieną įvykį, kai tai
palengvina ateities pasirinkimus ir išlaiko tvarkingą git žurnalą.

### Atnaujinkite savo šaką

Gana tikėtina, kad kiti pakeitimai įvyko, kol dirbote. Norėdami gauti naujus pakeitimus pagrindinėje šakoje:

```bash
$ git checkout main
$ git pull --rebase
```

Dabar vėl pritaikykite savo pataisą naujausiems pakeitimams:

```bash
$ git checkout my_new_branch
$ git rebase main
```

Nėra konfliktų? Testai vis dar veikia? Pakeitimas vis dar atrodo pagrįstas? Tada įkelkite pakeistus pakeitimus į "GitHub":

```bash
$ git push --force-with-lease
```

Mes neleidžiame priverstinai įkelti į "rails/rails" repozitorijos pagrindą, bet galite priverstinai įkelti į savo šaknį. Kai atliekate šią procedūrą, tai yra būtina, nes istorija pasikeitė.

### Šaknies kūrimas

Eikite į "Rails" [GitHub repozitoriją](https://github.com/rails/rails) ir paspauskite "Fork" viršutiniame dešiniajame kampe.

Pridėkite naują nuotolinį adresą į vietinį repozitoriją savo vietiniame kompiuteryje:

```bash
$ git remote add fork https://github.com/<jūsų vartotojo vardas>/rails.git
```

Galbūt jūs klonojote vietinį repozitoriją iš "rails/rails" arba klonojote iš savo šaknies repozitorijos. Sekantys "git" komandos priklauso nuo to, kad sukūrėte "rails" nuotolinį adresą, kuris rodo į "rails/rails".

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Atsisiųskite naujus įvykius ir šakas iš oficialaus repozitorijos:

```bash
$ git fetch rails
```

Suliejimas naujo turinio:

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

Atnaujinkite savo šaknį:

```bash
$ git push fork main
$ git push fork my_new_branch
```

### Atidarykite "Pull Request"

Eikite į "Rails" repozitoriją, kurią ką tik įkėlėte (pvz.
https://github.com/jūsų-vartotojo-vardas/rails) ir paspauskite "Pull Requests" viršuje (virš kodų).
Kitame puslapyje, viršutiniame dešiniajame kampe, paspauskite "New pull request".

"Pul Request" turėtų būti nukreiptas į pagrindinį repozitoriją `rails/rails` ir šaką `main`.
Pagrindinė repozitorija bus jūsų darbas (`jūsų-vartotojo-vardas/rails`), o šaka bus
bet kokio pavadinimo, kurį suteikėte šakai. Kai būsite pasiruošę, spustelėkite "create pull request".

Įsitikinkite, kad įtraukti pakeitimai, kuriuos įvedėte. Užpildykite kelis duomenis apie
galimą jūsų pataisą, naudodami pateiktą "pull request" šabloną. Baigę, spustelėkite "Create
pull request".

### Gaukite grįžtamąjį ryšį

Dauguma "pull request" bus keletą kartų peržiūrimi, kol jie bus sujungti.
Skirtingi "Rails" bendradarbiai kartais turės skirtingas nuomones, ir dažnai
pataisos turės būti peržiūrėtos prieš jas galima sujungti.

Kai kurie "Rails" bendradarbiai turi įjungtą "GitHub" el. pašto pranešimų funkciją, bet
kai kurie to neturi. Be to, (beveik) visi, kurie dirba su "Rails", yra
savivolontieriai, todėl gali užtrukti kelios dienos, kol gausite pirmąjį atsiliepimą dėl
"pull request". Nesidiskredituokite! Kartais tai vyksta greitai, kartais lėtai. Tokia
yra atvirojo kodo gyvenimas.

Jei praėjo daugiau nei savaitė, ir nieko negirdėjote, galbūt norėsite paskatinti veiksmus. Tam galite naudoti [rubyonrails-core diskusijų forumą](https://discuss.rubyonrails.org/c/rubyonrails-core). Taip pat galite
palikti dar vieną komentarą "pull request".
Kol laukiate atsiliepimo dėl savo prašymo ištraukti, atidarykite kelis kitus prašymus ištraukti ir suteikite kitiems žmonėms! Jie tai vertins taip pat, kaip ir jūs vertinate atsiliepimus apie savo pataisas.

Atkreipkite dėmesį, kad tik Core ir Committers komandos gali sujungti kodo pakeitimus. Jei kas nors duoda atsiliepimą ir "patvirtina" jūsų pakeitimus, jie gali neturėti galimybės ar galutinio žodžio, kad sujungtų jūsų pakeitimą.

### Iteruokite, jei reikia

Visiškai įmanoma, kad gausite atsiliepimą, kuris siūlo pakeitimus. Nepasiduokite: viso prisidėjimo prie aktyvaus atvirojo kodo projekto tikslas yra pasinaudoti bendruomenės žiniomis. Jei žmonės jums pataria keisti kodą, tai verta padaryti pakeitimus ir pateikti iš naujo. Jei atsiliepimas yra tas, kad jūsų kodas nebus sujungtas, galbūt vis tiek galvojate apie jį išleisti kaip gemą.

#### Suspaudžiant įsipareigojimus

Vienas iš dalykų, kurį mes galime paprašyti jūsų padaryti, yra "suspausti įsipareigojimus", kuris sujungia visus jūsų įsipareigojimus į vieną įsipareigojimą. Mes pageidaujame ištraukas, kurios yra vienas įsipareigojimas. Tai palengvina pakeitimų atgalinį perkėlimą į stabilias šakas, suspaudimas palengvina blogų įsipareigojimų atšaukimą, o "git" istorija gali būti šiek tiek lengviau sekti. "Rails" yra didelis projektas, o daugybė nereikalingų įsipareigojimų gali sukelti daug triukšmo.

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< Pasirinkite "suspausti" visiems savo įsipareigojimams, išskyrus pirmąjį. >
< Redaguokite įsipareigojimo pranešimą, kad jis būtų suprantamas ir aprašytų visus jūsų pakeitimus. >

$ git push fork my_new_branch --force-with-lease
```

Turėtumėte galėti atnaujinti prašymą ištraukti "GitHub" ir pamatyti, kad jis buvo atnaujintas.

#### Prašymo ištraukti atnaujinimas

Kartais jums bus paprašyta padaryti keletą pakeitimų jau įtrauktame kode. Tai gali apimti esamų įsipareigojimų pakeitimą. Šiuo atveju "Git" neleis jums įkelti pakeitimų, nes įkeltas šaka ir vietinė šaka nesutampa. Vietoje naujo prašymo ištraukti atidarymo galite priverstinai įkelti savo šaką į "GitHub", kaip anksčiau aprašyta įsipareigojimų suspaudimo skyriuje:

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

Tai atnaujins šaką ir prašymą ištraukti "GitHub" su jūsų nauju kodu. Priverstinai įkeliant su `--force-with-lease`, "git" saugiau atnaujins nuotolinį šaltinį nei su įprastiniu `-f`, kuris gali ištrinti darbą iš nuotolinio šaltinio, kurio jūs dar neturite.

### Senesnės "Ruby on Rails" versijos

Jei norite pridėti taisymą prie "Ruby on Rails" versijų, senesnių nei kitas leidimas, turėsite nustatyti ir perjungti į savo vietinę sekimo šaką. Čia pateikiamas pavyzdys, kaip perjungti į 7-0-stable šaką:

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

PASTABA: Prieš dirbdami su senesnėmis versijomis, patikrinkite [priežiūros politiką](maintenance_policy.html). Pakeitimai nebus priimti versijoms, kurios pasiekė gyvavimo pabaigą.

#### Atgalinės perkėlimas

Pakeitimai, kurie yra sujungiami į pagrindinę šaką, skirti kitam pagrindiniam "Rails" leidimui. Kartais gali būti naudinga plisti savo pakeitimus atgal į stabilias šakas, kad jie būtų įtraukti į palaikymo leidimus. Paprastai, saugumo taisymai ir klaidų taisymai yra geri kandidatai atgaliniam perkėlimui, o naujos funkcijos ir pakeitimai, keičiantys tikėtiną elgesį, nebus priimti. Jei abejojate, geriau pasikonsultuoti su "Rails" komandos nariu prieš atgalinį perkėlimą, kad išvengtumėte veltui švaistomo darbo.

Pirmiausia įsitikinkite, kad jūsų pagrindinė šaka yra atnaujinta.

```bash
$ git checkout main
$ git pull --rebase
```

Perjunkite į šaką, į kurią atgalinį perkėlimą, pavyzdžiui, `7-0-stable`, ir įsitikinkite, kad ji yra atnaujinta:

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

Jei atgaliniam perkėlimui naudojate sujungtą prašymą ištraukti, raskite sujungimo įsipareigojimo komitą ir jį įdėkite:

```bash
$ git cherry-pick -m1 MERGE_SHA
```

Ištaisykite bet kokius konfliktus, kurie atsirado per šeriamą įsipareigojimą, įkelkite savo pakeitimus, tada atidarykite PR, nurodydami stabilią šaką, į kurią atgalinį perkėlimą. Jei turite sudėtingesnį pakeitimų rinkinį, [cherry-pick](https://git-scm.com/docs/git-cherry-pick) dokumentacija gali padėti.

"Rails" prisidėtojai
------------------

Visi prisidėjimai gaus kreditą [Rails Contributors](https://contributors.rubyonrails.org).
