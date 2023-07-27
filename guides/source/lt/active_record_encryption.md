**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Aktyvusis įrašo šifravimas
========================

Šis vadovas aprašo, kaip naudoti Aktyvųjį įrašą šifruojant duomenis duomenų bazėje.

Po šio vadovo perskaitymo žinosite:

* Kaip nustatyti duomenų bazės šifravimą su Aktyviuoju įrašu.
* Kaip migruoti nesušifruotus duomenis.
* Kaip leisti egzistuoti skirtingoms šifravimo schemoms.
* Kaip naudoti API.
* Kaip konfigūruoti biblioteką ir kaip ją plėsti.

--------------------------------------------------------------------------------

Aktyvusis įrašas palaiko programinio lygio šifravimą. Tai veikia taip, kad deklaruojamos atributai, kurie turi būti šifruojami, ir kai reikia, jie automatiškai šifruojami ir dešifruojami. Šifravimo sluoksnis yra tarp duomenų bazės ir programos. Programa gali pasiekti nesušifruotus duomenis, tačiau duomenų bazė juos saugos šifruotus.

## Kodėl šifruoti duomenis programos lygiu?

Aktyvusis įrašo šifravimas yra skirtas apsaugoti jautrią informaciją jūsų programoje. Tipiškas pavyzdys yra asmeniškai identifikuojama informacija apie vartotojus. Bet kodėl jums reikia šifruoti duomenis programos lygiu, jei jau šifruojate duomenų bazę?

Tiesioginė praktinė nauda yra ta, kad šifruojant jautrius atributus pridedamas papildomas saugumo sluoksnis. Pavyzdžiui, jei įsilaužėlis gautų prieigą prie jūsų duomenų bazės, jos momentinės kopijos arba jūsų programos žurnalų, jis negalėtų suprasti šifruotos informacijos. Be to, šifravimas gali užkirsti kelią programuotojams netyčia atskleisti vartotojų jautrių duomenų programos žurnaluose.

Bet svarbiausia, naudojant Aktyvųjį įrašo šifravimą, apibrėžiate, kas sudaro jautrią informaciją jūsų programoje kodo lygiu. Aktyvusis įrašo šifravimas leidžia tiksliai kontroliuoti duomenų prieigą jūsų programoje ir paslaugose, kurios naudoja duomenis iš jūsų programos. Pavyzdžiui, galite apsvarstyti [audituojamas „Rails“ konsolas, kurios apsaugo šifruotus duomenis](https://github.com/basecamp/console1984) arba patikrinti įdiegtą sistemą, kuri automatiškai [filtruoja valdiklio parametrus, pavadintus šifruotais stulpeliais](#filtravimo-parametrai, pavadinti šifruotais stulpeliais).

## Pagrindinis naudojimas

### Nustatymas

Pirmiausia turite pridėti keletą raktų į savo [„Rails“ kredencialus](/security.html#custom-credentials). Paleiskite `bin/rails db:encryption:init`, kad sugeneruotumėte atsitiktinį raktų rinkinį:

```bash
$ bin/rails db:encryption:init
Pridėkite šį įrašą į tikslinio aplinkos kredencialus:

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

PASTABA: Šie sugeneruoti reikšmės yra 32 baitų ilgio. Jei patys generuojate, minimalus naudojamas ilgis turėtų būti 12 baitų pagrindiniam raktui (jis bus naudojamas išvesti AES 32 baitų raktą) ir 20 baitų druskai.

### Šifruotų atributų deklaravimas

Šifruojami atributai apibrėžiami modelio lygiu. Tai yra įprasti Aktyvaus įrašo atributai, kurie yra palaikomi stulpeliu su tuo pačiu pavadinimu.

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

Biblioteka automatiškai šifruos šiuos atributus prieš juos įrašant į duomenų bazę ir dešifruos juos gavimo metu:

```ruby
article = Article.create title: "Šifruok viską!"
article.title # => "Šifruok viską!"
```

Tačiau, užkulisiuose vykdomas SQL užklausa atrodo taip:

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### Svarbu: apie saugyklą ir stulpelio dydį

Šifravimas reikalauja papildomo vietos dėl Base64 kodavimo ir šifruotų duomenų kartu su jais saugomų metadu. Naudojant įdiegtą vokų šifravimo rakto tiekėją, galite apytiksliai įvertinti didžiausią galimą perteklių, kuris yra apie 255 baitus. Šis perteklius yra nepastebimas didesniuose dydžiuose. Ne tik dėl to, kad jis išsisklaido, bet ir dėl to, kad biblioteka pagal nutylėjimą naudoja suspaudimą, kuris gali sutaupyti iki 30% saugojimo vietos palyginti su nesušifruota versija didesniems duomenų kiekiams.

Yra svarbus klausimas dėl eilutės stulpelių dydžių: moderniose duomenų bazėse stulpelio dydis nustato *simbolių skaičių*, kurį jis gali priskirti, o ne baitų skaičių. Pavyzdžiui, naudojant UTF-8, kiekvienas simbolis gali užimti iki keturių baitų, todėl potencialiai duomenų bazėje naudojant UTF-8 stulpelis gali būti saugoma iki keturių kartų daugiau baitų, nei jo dydis *simbolių skaičiumi*. Šifruoti duomenys yra binarinės eilutės, serializuotos kaip Base64, todėl jas galima saugoti įprastuose `string` stulpeliuose. Kadangi tai yra seka iš ASCII baitų, šifruotas stulpelis gali užimti iki keturių kartų daugiau vietos nei jo aiškios versijos dydis. Taigi, net jei duomenys, saugomi duomenų bazėje, yra tokie patys baitai, stulpelis turi būti keturis kartus didesnis.

Praktiškai tai reiškia:

* Kai šifruojate trumpus tekstus, rašytus vakarų abėcėlės (daugiausia ASCII simboliais), turėtumėte atsižvelgti į tą papildomą 255 perteklių, nustatydami stulpelio dydį.
* Kai šifruojate trumpus tekstus, rašytus nevakarų abėcėlėmis, pvz., kirilica, turėtumėte stulpelio dydį padauginti iš 4. Pastebėkite, kad saugojimo perteklius yra ne daugiau kaip 255 baitai.
* Kai šifruojate ilgus tekstus, galite ignoruoti stulpelio dydžio klausimus.
Kai kurie pavyzdžiai:

| Užšifruojamas turinys                            | Originalus stulpelio dydis | Rekomenduojamas užšifruoto stulpelio dydis | Saugojimo perteklius (blogiausiu atveju) |
| ------------------------------------------------- | ------------------------- | ----------------------------------------- | --------------------------------------- |
| El. pašto adresai                                 | string(255)               | string(510)                               | 255 baitai                              |
| Trumpas emocijų seka                             | string(255)               | string(1020)                              | 255 baitai                              |
| Santrauka teksto, parašyto nevakarietiškais abėcėlės simboliais | string(500)               | string(2000)                              | 255 baitai                              |
| Arbitražinio ilgo teksto                          | text                      | text                                     | nepastebimas                            |

### Deterministinis ir nedeterministinis užšifravimas

Pagal numatytuosius nustatymus, Active Record Encryption naudoja nedeterministinį užšifravimo būdą. Nedeterministinis, šiuo kontekstu, reiškia, kad tas pats turinys užšifruojant du kartus su tuo pačiu slaptažodžiu duos skirtingus šifrus. Šis būdas pagerina saugumą, padarant šifruotų tekstų kriptoanalizę sunkesnę ir duomenų bazės užklausimą neįmanomą.

Galite naudoti `deterministic:` parinktį, kad būtų galima deterministiškai generuoti pradinius vektorius, efektyviai įgalinant užklausti užšifruotus duomenis.

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # Galite įprastai užklausti modelį
```

Nedeterministinis būdas rekomenduojamas, nebent jums reikia užklausti duomenis.

PASTABA: Nedeterministinėje veiksenoje Active Record naudoja AES-GCM su 256 bitų raktu ir atsitiktiniu pradiniu vektoriumi. Deterministinėje veiksenoje taip pat naudojamas AES-GCM, tačiau pradinis vektorius generuojamas kaip HMAC-SHA-256 maišos funkcijos rezultatas, gautas iš rakto ir užšifruojamo turinio.

PASTABA: Galite išjungti deterministinį užšifravimą, neįvedant `deterministic_key`.

## Funkcijos

### Veiksmo tekstas

Galite užšifruoti Veiksmo teksto atributus, perduodant `encrypted: true` jų deklaracijoje.

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

PASTABA: Veiksmo teksto atributams perduoti atskiri užšifravimo parametrai dar nepalaikomi. Jie naudos nedeterministinį užšifravimą su konfigūruotais globaliais užšifravimo parametrais.

### Fiktyvūros

Galite automatiškai užšifruoti „Rails“ fiktyvūras, pridedami šią parinktį į savo `test.rb`:

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

Įjungus šią funkciją, visi užšifruojami atributai bus užšifruojami pagal modelyje nustatytus užšifravimo parametrus.

#### Veiksmo teksto fiktyvūros

Norėdami užšifruoti Veiksmo teksto fiktyvūras, juos turėtumėte įdėti į `fixtures/action_text/encrypted_rich_texts.yml`.

### Palaikomi tipai

`active_record.encryption` išserializuos reikšmes naudodamas pagrindinį tipą prieš užšifruojant, tačiau *jos turi būti išserializuojamos kaip eilutės*. Struktūrizuoti tipai, pvz., `serialized`, yra palaikomi iš karto.

Jei norite palaikyti pasirinktinį tipą, rekomenduojama naudoti [išserializuotą atributą](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html). Išserializuoto atributo deklaracija turėtų būti **prieš** užšifravimo deklaraciją:

```ruby
# TEISINGA
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# NETEISINGA
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### Didžiosios ir mažosios raidės ignoravimas

Galbūt norėsite ignoruoti didžiąsias ir mažąsias raides, kai užklausiate deterministiškai užšifruotus duomenis. Dvi strategijos palengvina tai padaryti:

Galite naudoti `:downcase` parinktį, kai deklaruoja užšifruotą atributą, kad mažintumėte turinį prieš užšifravimą.

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

Naudodami `:downcase`, prarandamas pradinis dydis. Kai kuriuose atvejuose galite norėti ignoruoti dydį tik užklausiant, tuo pačiu išsaugant pradinį dydį. Tokiais atvejais galite naudoti parinktį `:ignore_case`. Tai reikalauja pridėti naują stulpelį, kurio pavadinimas yra `original_<column_name>`, kad būtų galima išsaugoti turinį su nepakeistu dydžiu:

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # turinys su pradiniu dydžiu bus išsaugotas stulpelyje `original_name`
end
```

### Parametras nepašifruotiems duomenims palaikyti

Norint palengvinti nepašifruotų duomenų migraciją, biblioteka įtraukia parinktį `config.active_record.encryption.support_unencrypted_data`. Nustatant ją į `true`:

* Bandant skaityti nepašifruotus atributus, kurie nėra užšifruoti, jie veiks įprastai, be jokių klaidų.
* Užklausose su deterministiškai užšifruotais atributais bus įtrauktos jų „aiškios teksto“ versijos, kad būtų galima rasti tiek užšifruotą, tiek nepašifruotą turinį. Norėdami tai įjungti, turite nustatyti `config.active_record.encryption.extend_queries = true`.

**Ši parinktis skirta naudoti per perėjimo laikotarpius**, kai aiškūs duomenys ir užšifruoti duomenys turi egzistuoti kartu. Abi parinktys pagal numatytuosius nustatymus yra nustatytos į `false`, kas yra rekomenduojama tikslas bet kuriai programai: klaidos bus iškeltos dirbant su nepašifruotais duomenimis.

### Ankstesnių užšifravimo schemų palaikymas

Atributų užšifravimo savybių keitimas gali sugadinti esamus duomenis. Pavyzdžiui, įsivaizduokite, kad norite padaryti deterministinį atributą nedeterministiniu. Jei tiesiog pakeisite deklaraciją modelyje, skaitymas iš esamų šifruotų tekstų nepavyks, nes dabar užšifravimo metodas yra skirtingas.
Norint palaikyti šias situacijas, galite nurodyti ankstesnes šifravimo schemas, kurios bus naudojamos dviejose scenarijose:

* Skaitydami užšifruotus duomenis, Active Record Encryption išbandys ankstesnes šifravimo schemas, jei dabartinė schema neveikia.
* Užklausiant nustatomus duomenis, ji pridės šifruotus tekstus naudodama ankstesnes schemas, kad užklausos veiktų sklandžiai su skirtingomis šifruotomis schemomis. Norėdami tai įjungti, turite nustatyti `config.active_record.encryption.extend_queries = true`.

Galite konfigūruoti ankstesnes šifravimo schemas:

* Visuotinai
* Atskirai kiekvienam atributui

#### Visuotinės ankstesnės šifravimo schemos

Galite pridėti ankstesnes šifravimo schemas pridedami jas kaip savybių sąrašą naudodami `previous` konfigūracijos savybę savo `application.rb`:

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### Atskirų atributų šifravimo schemos

Nurodykite `:previous`, kai deklaruoja atributą:

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### Šifravimo schemos ir nustatomieji atributai

Pridedant ankstesnes šifravimo schemas:

* Su **nedeterministine šifravimu**, nauja informacija visada bus užšifruota naudojant *naujausią* (dabartinę) šifravimo schemą.
* Su **nustatomuoju šifravimu**, nauja informacija visada bus užšifruota naudojant *seniausią* šifravimo schemą pagal numatytuosius nustatymus.

Įprastai, naudojant nustatomąjį šifravimą, norite, kad šifruoti tekstai išliktų pastovūs. Galite pakeisti šį elgesį nustatydami `deterministic: { fixed: false }`. Tokiu atveju naujiems duomenims šifruoti bus naudojama *naujausia* šifravimo schema.

### Unikalūs apribojimai

PASTABA: Unikalūs apribojimai gali būti naudojami tik su nustatomai šifruotais duomenimis.

#### Unikalių validacijų

Unikalių validacijų palaikymas vyksta įprastai, jei įjungtos išplėstos užklausos (`config.active_record.encryption.extend_queries = true`).

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

Jos taip pat veiks, derinant šifruotus ir nesifruotus duomenis bei konfigūruojant ankstesnes šifravimo schemas.

PASTABA: Jei norite ignoruoti didžiąsias ir mažąsias raides, įsitikinkite, kad naudojate `downcase:` arba `ignore_case:` `encrypts` deklaracijoje. Naudoti `case_sensitive:` parinktį validacijoje neveiks.

#### Unikalių indeksų

Norint palaikyti unikalius indeksus su nustatomai šifruotais stulpeliais, reikia užtikrinti, kad jų šifruotasis tekstas niekada nekeistųsi.

Tam skatinti, nustatomieji atributai pagal numatytuosius nustatymus visada naudos seniausią galimą šifravimo schemą, kai yra konfigūruotos kelios šifravimo schemos. Kitu atveju, jūs turite užtikrinti, kad šių atributų šifravimo savybės nepasikeistų, arba unikalūs indeksai neveiks.

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### Filtruojant parametrus, pavadintus pagal užšifruotus stulpelius

Pagal numatytuosius nustatymus, užšifruoti stulpeliai yra konfigūruoti [automatiškai filtruojami „Rails“ žurnaluose](action_controller_overview.html#parameters-filtering). Galite išjungti šį elgesį pridedami šį kodą į savo `application.rb`:

Generuojant filtro parametrą, jis naudos modelio pavadinimą kaip priešdėlį. Pvz.: „Person#name“ filtro parametras bus „person.name“.

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

Jei norite išskirti tam tikrus stulpelius iš šio automatinio filtravimo, pridėkite juos į `config.active_record.encryption.excluded_from_filter_parameters`.

### Kodavimas

Biblioteka išlaikys kodavimą užšifruotoms neapibrėžtai šifruotoms eilutėms.

Kadangi kodavimas saugomas kartu su užšifruotu duomenų paketu, nustatomai šifruotiems duomenims numatytuosius nustatymus naudojant, pagal numatytuosius nustatymus, bus priverstinai naudojamas UTF-8 kodavimas. Todėl tas pats reikšmės su kitu kodavimu rezultuos skirtingu šifruotu tekstu. Paprastai norite tai išvengti, kad užklausos ir unikalumo apribojimai veiktų, todėl biblioteka automatiškai atliks konversiją jūsų vardu.

Galite konfigūruoti numatytąjį norimą kodavimą nustatomam šifravimui naudodami:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

Ir galite išjungti šį elgesį ir išlaikyti kodavimą visais atvejais naudodami:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## Raktų valdymas

Rakto tiekėjai įgyvendina rakto valdymo strategijas. Galite konfigūruoti rakto tiekėjus visuotinai arba atskirai kiekvienam atributui.

### Įdiegti rakto tiekėjai

#### DerivedSecretKeyProvider

Raktų tiekėjas, kuris teiks išvestus raktus iš pateiktų slaptažodžių, naudodamas PBKDF2.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

PASTABA: Pagal numatytuosius nustatymus, `active_record.encryption` konfigūruoja `DerivedSecretKeyProvider` su raktų, apibrėžtų `active_record.encryption.primary_key`, nustatymais.

#### EnvelopeEncryptionKeyProvider

Įgyvendina paprastą [vokų šifravimo](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping) strategiją:

- Generuoja atsitiktinį raktą kiekvienai duomenų šifravimo operacijai
- Saugo duomenų raktą kartu su pačiais duomenimis, užšifruotais pagal pagrindinį raktą, apibrėžtą paskyros `active_record.encryption.primary_key`.

Galite konfigūruoti „Active Record“, kad naudotų šį rakto tiekėją, pridedami šį kodą į savo `application.rb`:

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

Kaip ir su kitais įdiegtais rakto tiekėjais, galite nurodyti pagrindinių raktų sąrašą `active_record.encryption.primary_key`, kad įgyvendintumėte rakto keitimo schemas.
### Individualūs raktų tiekėjai

Norint naudoti pažangesnes raktų valdymo schemas, galite konfigūruoti individualų raktų tiekėją inicializacijos metu:

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

Raktų tiekėjas turi įgyvendinti šią sąsają:

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

Abu metodai grąžina `ActiveRecord::Encryption::Key` objektus:

- `encryption_key` grąžina raktą, naudojamą užšifruoti tam tikrą turinį
- `decryption_keys` grąžina sąrašą potencialių raktų, skirtų užšifruoto pranešimo iššifruoti

Raktas gali apimti bet kokius žymas, kurie bus saugomi neužšifruoti kartu su pranešimu. Iššifruojant, galite naudoti `ActiveRecord::Encryption::Message#headers` metodą, kad peržiūrėtumėte šias reikšmes.

### Modelio specifiniai raktų tiekėjai

Galite konfigūruoti raktų tiekėją kiekvienai klasės pagrindu naudodami `:key_provider` parinktį:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### Modelio specifiniai raktai

Galite konfigūruoti konkretų raktą kiekvienai klasei naudodami `:key` parinktį:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "kažkoks paslaptis raktas straipsnių santraukoms"
end
```

Active Record naudoja raktą, kad gautų raktą, kuris bus naudojamas duomenims užšifruoti ir iššifruoti.

### Raktų rotacija

`active_record.encryption` gali dirbti su raktų sąrašais, kad palaikytų raktų rotacijos schemas:

- **Paskutinis raktas** bus naudojamas naujam turiniui užšifruoti.
- Visi raktai bus išbandyti, kai bus iššifruojamas turinys, kol bus rastas tinkamas raktas.

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # Ankstesni raktai vis dar gali iššifruoti esamą turinį
    - bc17e7b413fd4720716a7633027f8cc4 # Aktyvus, užšifruoja naują turinį
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

Tai leidžia naudoti darbo eigos, kuriose trumpą raktų sąrašą galite išlaikyti pridedami naujus raktus, vėl užšifruojant turinį ir ištrinant senus raktus.

PASTABA: Raktų rotacija šiuo metu nepalaikoma deterministiniam užšifravimui.

PASTABA: Active Record Encryption dar nesuteikia automatinio raktų rotacijos procesų valdymo. Visi reikalingi komponentai yra, tačiau šis funkcionalumas dar nėra įgyvendintas.

### Raktų nuorodų saugojimas

Galite konfigūruoti `active_record.encryption.store_key_references`, kad `active_record.encryption` saugotų raktų nuorodą paties užšifruoto pranešimo antraštėse.

```ruby
config.active_record.encryption.store_key_references = true
```

Tai padeda greitesniam iššifravimui, nes sistema gali tiesiogiai rasti raktus, o ne bandyti visus raktus iš sąrašo. Tačiau tai padidina saugojimo sąnaudas: užšifruoti duomenys bus šiek tiek didesni.

## API

### Pagrindinė API

ActiveRecord užšifravimas skirtas deklaratyviam naudojimui, tačiau jis taip pat siūlo API pažangesniems naudojimo scenarijams.

#### Užšifruoti ir iššifruoti

```ruby
article.encrypt # užšifruoja arba vėl užšifruoja visus užšifruojamus atributus
article.decrypt # iššifruoja visus užšifruojamus atributus
```

#### Skaityti šifruotą tekstą

```ruby
article.ciphertext_for(:title)
```

#### Patikrinti, ar atributas yra užšifruotas ar ne

```ruby
article.encrypted_attribute?(:title)
```

## Konfigūracija

### Konfigūracijos parinktys

Active Record Encryption konfigūraciją galite nustatyti savo `application.rb` (dažniausias scenarijus) arba konkrečiame aplinkos konfigūracijos faile `config/environments/<env pavadinimas>.rb`, jei norite jas nustatyti aplinkos pagrindu.

ĮSPĖJIMAS: Rekomenduojama naudoti Rails įdiegtą įgaliojimų palaikymą, kad būtų saugomi raktai. Jei norite juos nustatyti rankiniu būdu naudojant konfigūracijos savybes, įsitikinkite, kad jų nesaugojate kartu su savo kodu (pvz., naudokite aplinkos kintamuosius).

#### `config.active_record.encryption.support_unencrypted_data`

Kai `true`, nešifruoti duomenys gali būti skaityti įprastai. Kai `false`, bus iškeltos klaidos. Numatytoji reikšmė: `false`.

#### `config.active_record.encryption.extend_queries`

Kai `true`, užšifruotų atributų užklausos bus modifikuotos, kad būtų įtraukti papildomi reikšmės, jei reikia. Šios papildomos reikšmės bus švarios versijos reikšmė (kai `config.active_record.encryption.support_unencrypted_data` yra `true`) ir reikšmės, užšifruotos naudojant ankstesnes užšifravimo schemas, jei jos yra (kaip nurodyta naudojant `previous:` parinktį). Numatytoji reikšmė: `false` (eksperimentinė).

#### `config.active_record.encryption.encrypt_fixtures`

Kai `true`, užšifruojami atributai fiktyvuose duomenyse bus automatiškai užšifruojami, kai jie bus įkelti. Numatytoji reikšmė: `false`.

#### `config.active_record.encryption.store_key_references`

Kai `true`, nuoroda į užšifravimo raktą bus saugoma užšifruoto pranešimo antraštėse. Tai padeda greitesniam iššifravimui, kai naudojami keli raktai. Numatytoji reikšmė: `false`.

#### `config.active_record.encryption.add_to_filter_parameters`

Kai `true`, užšifruotų atributų pavadinimai automatiškai pridedami prie [`config.filter_parameters`][] ir jie nebus rodomi žurnale. Numatytoji reikšmė: `true`.

#### `config.active_record.encryption.excluded_from_filter_parameters`

Galite konfigūruoti sąrašą parametrų, kurie nebus filtruojami, kai `config.active_record.encryption.add_to_filter_parameters` yra `true`. Numatytoji reikšmė: `[]`.

#### `config.active_record.encryption.validate_column_size`

Prideda validaciją pagrįstą stulpelio dydžiu. Rekomenduojama, kad būtų išvengta saugojimo didelių reikšmių naudojant labai suspaudžiamus duomenis. Numatytoji reikšmė: `true`.

#### `config.active_record.encryption.primary_key`

Raktas arba raktų sąrašai, naudojami išvesti pagrindinius duomenų užšifravimo raktus. Jų naudojimo būdas priklauso nuo konfigūruoto raktų tiekėjo. Pageidautina konfigūruoti naudojant `active_record_encryption.primary_key` įgaliojimą.
#### `config.active_record.encryption.deterministic_key`

Raktas arba raktų sąrašas, naudojamas deterministiniam šifravimui. Pageidautina jį konfigūruoti naudojant `active_record_encryption.deterministic_key` kredencialę.

#### `config.active_record.encryption.key_derivation_salt`

Sūris, naudojamas gaminant raktus. Pageidautina jį konfigūruoti naudojant `active_record_encryption.key_derivation_salt` kredencialę.

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

Numatytasis kodavimas, naudojamas deterministiniam šifruojamiems atributams. Galite išjungti priverstinį kodavimą nustatydami šią parinktį į `nil`. Numatytai tai yra `Encoding::UTF_8`.

#### `config.active_record.encryption.hash_digest_class`

Raktų gavimui naudojamas maišos algoritmas. Numatytai tai yra `OpenSSL::Digest::SHA1`.

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

Palaiko iššifruoti duomenis, šifruotus nedeterministiškai naudojant SHA1 maišos klasę. Numatytai tai yra `false`, tai reiškia, kad bus palaikomas tik maišos algoritmas, nustatytas `config.active_record.encryption.hash_digest_class`.

### Šifravimo kontekstai

Šifravimo kontekstas apibrėžia šifravimo komponentus, kurie naudojami tam tikru momentu. Yra numatytasis šifravimo kontekstas, pagrįstas jūsų globalia konfigūracija, tačiau galite konfigūruoti pasirinktinį kontekstą tam tikram atributui arba vykdant konkretų kodo bloką.

PASTABA: Šifravimo kontekstai yra lankstus, bet sudėtingas konfigūracijos mechanizmas. Dauguma vartotojų neturėtų jais rūpintis.

Pagrindiniai šifravimo konteksto komponentai yra:

* `encryptor`: atskleidžia vidinį API duomenų šifravimui ir iššifravimui. Jis bendrauja su `key_provider`, kuris sukuria užšifruotus pranešimus ir tvarko jų serializaciją. Šifravimas/iššifravimas atliekamas `cipher`, o serializacija - `message_serializer`.
* `cipher`: pati šifravimo algoritmas (AES 256 GCM)
* `key_provider`: teikia šifravimo ir iššifravimo raktus.
* `message_serializer`: serializuoja ir deserializuoja užšifruotus pranešimus (`Message`).

PASTABA: Jei nuspręsite sukurti savo `message_serializer`, svarbu naudoti saugius mechanizmus, kurie negali deserializuoti atsitiktinių objektų. Dažnas palaikomas scenarijus yra užšifruoti esamus nešifruotus duomenis. Įsilaužėlis gali tai panaudoti, kad įterptų pakeistą pranešimą prieš šifravimą ir atliktų RCE atakas. Tai reiškia, kad pasirinktiniai serializatoriai turėtų vengti `Marshal`, `YAML.load` (naudokite `YAML.safe_load` vietoj to) arba `JSON.load` (naudokite `JSON.parse` vietoj to).

#### Globalus šifravimo kontekstas

Globalus šifravimo kontekstas yra numatytasis ir konfigūruojamas kaip kitos konfigūracijos savybės jūsų `application.rb` arba aplinkos konfigūracijos failuose.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### Atributo lygio šifravimo kontekstai

Galite perrašyti šifravimo konteksto parametrus, juos perduodant atributo deklaracijoje:

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### Šifravimo kontekstas vykdant kodo bloką

Galite naudoti `ActiveRecord::Encryption.with_encryption_context` nustatyti šifravimo kontekstą tam tikram kodo blokui:

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### Įdiegti šifravimo kontekstai

##### Išjungti šifravimą

Galite vykdyti kodą be šifravimo:

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

Tai reiškia, kad skaitant užšifruotą tekstą bus grąžinamas šifrograma, o išsaugota turinys bus saugomas nešifruotas.

##### Apsaugoti užšifruotus duomenis

Galite vykdyti kodą be šifravimo, bet užkirsti kelią užšifruoto turinio perrašymui:

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

Tai gali būti naudinga, jei norite apsaugoti užšifruotus duomenis, tuo pačiu metu vykdant bet kokį kodą su jais (pvz., "Rails console").
[`config.filter_parameters`]: configuring.html#config-filter-parameters
