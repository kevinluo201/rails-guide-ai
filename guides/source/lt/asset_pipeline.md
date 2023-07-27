**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 0f0bbb2fd67f1843d30e360c15c03c61
Turtinio turto linija
==================

Šiame vadove aptariama turtinio turto linija.

Po šio vadovo perskaitymo žinosite:

* Kas yra turtinio turto linija ir ką ji daro.
* Kaip tinkamai organizuoti savo programos turto elementus.
* Turtinio turto linijos privalumai.
* Kaip pridėti pirmininką prie linijos.
* Kaip supakuoti turto elementus su gemu.

--------------------------------------------------------------------------------

Kas yra turtinio turto linija?
---------------------------

Turtinio turto linija suteikia pagrindą tvarkyti JavaScript ir CSS turto elementų pristatymą. Tai daroma pasitelkiant technologijas kaip HTTP/2 ir technikas kaip konkatenacija ir sumažinimas. Galiausiai tai leidžia jūsų programai automatiškai sujungti su turto elementais iš kitų gemų.

Turtinio turto liniją įgyvendina [importmap-rails](https://github.com/rails/importmap-rails), [sprockets](https://github.com/rails/sprockets) ir [sprockets-rails](https://github.com/rails/sprockets-rails) gemai ir ji įjungta pagal numatytuosius nustatymus. Galite ją išjungti kuriant naują programą, perduodant `--skip-asset-pipeline` parinktį.

```bash
$ rails new appname --skip-asset-pipeline
```

PASTABA: Šiame vadove dėmesys skiriamas numatytajai turto linijai, naudojančiai tik `sprockets` CSS ir `importmap-rails` JavaScript apdorojimui. Šių dviejų pagrindinis apribojimas yra tai, kad nėra palaikymo transliavimui, todėl negalite naudoti dalykų kaip `Babel`, `Typescript`, `Sass`, `React JSX format` ar `TailwindCSS`. Rekomenduojame perskaityti [Alternatyvių bibliotekų skyrių](#alternative-libraries), jei jums reikia transliavimo savo JavaScript/CSS.

## Pagrindinės funkcijos

Turtinio turto linijos pirmoji funkcija yra įterpti SHA256 pirštų antspaudą į kiekvieno failo pavadinimą, kad failas būtų talpinamas interneto naršyklės ir CDN talpykloje. Šis piršto antspaudas automatiškai atnaujinamas, kai keičiate failo turinį, kas neleidžia talpyklai veikti.

Turtinio turto linijos antroji funkcija yra naudoti [importavimo žemėlapius](https://github.com/WICG/import-maps) teikiant JavaScript failus. Tai leidžia jums kurti modernias programas, naudojant JavaScript bibliotekas, skirtas ES moduliams (ESM), be transliavimo ir rinkinio poreikio. Savo ruožtu, **tai pašalina poreikį naudoti Webpack, yarn, node ar bet kurį kitą JavaScript įrankių grandinės dalį**.

Turtinio turto linijos trečioji funkcija yra sujungti visus CSS failus į vieną pagrindinį `.css` failą, kuris tada yra sumažinamas arba suspaudžiamas. Kaip sužinosite vėliau šiame vadove, galite tinkinti šią strategiją, kad failus grupuotumėte bet kokiu būdu. Producijos metu „Rails“ įterpia SHA256 pirštų antspaudą į kiekvieno failo pavadinimą, kad failas būtų talpinamas interneto naršyklėje. Galite atšaukti talpyklą pakeisdami šį pirštų antspaudą, kas vyksta automatiškai, kai keičiate failo turinį.

Turtinio turto linijos ketvirtoji funkcija yra leisti koduoti turto elementus aukštesnio lygio kalba CSS.

### Kas yra piršto antspaudas ir kodėl man tai rūpi?

Piršto antspaudas yra technika, kuri padaro failo pavadinimą priklausomą nuo failo turinio. Keičiant failo turinį, keičiamas ir failo pavadinimas. Statiniam arba retai keičiamam turiniui tai suteikia paprastą būdą nustatyti, ar du failo versijos yra identiškos, net skirtingose serverių ar diegimo datos aplinkose.

Kai failo pavadinimas yra unikalus ir pagrįstas jo turiniu, HTTP antraštės gali būti nustatytos, kad skatintų talpyklas visur (ar tai būtų CDN, ISP, tinklo įranga ar naršyklės), kad jos išlaikytų savo turinio kopiją. Keičiant turinį, piršto antspaudas pasikeis. Tai privers nuotolinės klientus paprašyti naujos turinio kopijos. Tai paprastai žinoma kaip _talpyklos išardymas_.

Sprockets naudoja piršto antspaudui techniką įterpti turinio maišos funkcijos rezultatą į pavadinimą, paprastai gale. Pavyzdžiui, CSS failas `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

Tai yra „Rails“ turto linijos priimta strategija.

Piršto antspaudas įjungtas pagal numatytuosius nustatymus tiek vystymo, tiek produkcijos aplinkose. Galite įjungti arba išjungti jį savo konfigūracijoje per [`config.assets.digest`][] parinktį.

### Kas yra importavimo žemėlapiai ir kodėl man tai rūpi?

Importavimo žemėlapiai leidžia importuoti JavaScript modulius, naudojant loginius pavadinimus, kurie atitinka versijomis/digestuotus failus - tiesiogiai iš naršyklės. Taigi galite kurti modernias JavaScript programas, naudodami JavaScript bibliotekas, skirtas ES moduliams (ESM), be transliavimo ar rinkinio poreikio.

Šiuo požiūriu siųsite daugybę mažų JavaScript failų vietoj vieno didelio JavaScript failo. Dėka HTTP/2, tai nebešioja materialaus našumo nuostolių per pradinį transportavimą ir iš tikrųjų siūlo didelį pranašumą ilguoju laikotarpiu dėl geresnių talpyklos dinamikos.
Kaip naudoti Import Maps kaip Javascript turinio paleidimo sistemą
-----------------------------

Import Maps yra numatytasis Javascript procesorius, importų žemėlapio generavimo logika yra valdoma [`importmap-rails`](https://github.com/rails/importmap-rails) gem.

ĮSPĖJIMAS: Importų žemėlapiai naudojami tik Javascript failams ir negali būti naudojami CSS pristatymui. Norėdami sužinoti apie CSS, patikrinkite [Sprockets skyrių](#how-to-use-sprockets).

Detalią naudojimo instrukciją galite rasti Gem namų puslapyje, tačiau svarbu suprasti `importmap-rails` pagrindus.

### Kaip tai veikia

Importų žemėlapiai esminiu principu yra eilučių pakeitimas, vadinamų "goliais modulio specifikatoriais". Jie leidžia jums standartizuoti JavaScript modulio importavimo pavadinimus.

Pavyzdžiui, tokia importo apibrėžimas neveiks be importo žemėlapio:

```javascript
import React from "react"
```

Norėdami, kad tai veiktų, turėtumėte apibrėžti taip:

```javascript
import React from "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Čia ateina importo žemėlapis, mes apibrėžiame `react` pavadinimą, kuris yra pririštas prie `https://ga.jspm.io/npm:react@17.0.2/index.js` adreso. Turėdami tokios informacijos, mūsų naršyklė priima supaprastintą `import React from "react"` apibrėžimą. Importo žemėlapį galima laikyti kaip bibliotekos šaltinio adreso sinonimą.

### Naudojimas

Su `importmap-rails` sukuriate importo žemėlapio konfigūracijos failą, kuriame pririšate bibliotekos kelią prie pavadinimo:

```ruby
# config/importmap.rb
pin "application"
pin "react", to: "https://ga.jspm.io/npm:react@17.0.2/index.js"
```

Visi sukonfigūruoti importo žemėlapiai turėtų būti pridėti prie jūsų aplikacijos `<head>` elemento pridedant `<%= javascript_importmap_tags %>` . `javascript_importmap_tags` sugeneruoja keletą skriptų `<head>` elemente:

- JSON su visais sukonfigūruotais importo žemėlapiais:

```html
<script type="importmap">
{
  "imports": {
    "application": "/assets/application-39f16dc3f3....js"
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js"
  }
}
</script>
```

- [`Es-module-shims`](https://github.com/guybedford/es-module-shims) veikiantis kaip polifilas, užtikrinantis `import maps` palaikymą senesnėse naršyklėse:

```html
<script src="/assets/es-module-shims.min" async="async" data-turbo-track="reload"></script>
```

- Įvesties taškas, skirtas įkelti JavaScript iš `app/javascript/application.js`:

```html
<script type="module">import "application"</script>
```

### Naudoti npm paketus per JavaScript CDN

Galite naudoti `./bin/importmap` komandą, kuri yra pridėta kaip dalis `importmap-rails` diegimo, norėdami pririšti, atseikti ar atnaujinti npm paketus savo importo žemėlapyje. Binstub naudoja [`JSPM.org`](https://jspm.org/).

Tai veikia taip:

```sh
./bin/importmap pin react react-dom
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/index.js
Pinning "react-dom" to https://ga.jspm.io/npm:react-dom@17.0.2/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
Pinning "scheduler" to https://ga.jspm.io/npm:scheduler@0.20.2/index.js

./bin/importmap json

{
  "imports": {
    "application": "/assets/application-37f365cbecf1fa2810a8303f4b6571676fa1f9c56c248528bc14ddb857531b95.js",
    "react": "https://ga.jspm.io/npm:react@17.0.2/index.js",
    "react-dom": "https://ga.jspm.io/npm:react-dom@17.0.2/index.js",
    "object-assign": "https://ga.jspm.io/npm:object-assign@4.1.1/index.js",
    "scheduler": "https://ga.jspm.io/npm:scheduler@0.20.2/index.js"
  }
}
```

Kaip matote, du paketai react ir react-dom išsprendžia iš viso keturis priklausomybes, kai jie yra išspręsti naudojant jspm numatytąjį.

Dabar galite naudoti juos savo `application.js` įvesties taške kaip bet kurį kitą modulį:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Taip pat galite priskirti konkretų versiją:

```sh
./bin/importmap pin react@17.0.1
Pinning "react" to https://ga.jspm.io/npm:react@17.0.1/index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Arba netgi pašalinti pririšimus:

```sh
./bin/importmap unpin react
Unpinning "react"
Unpinning "object-assign"
```

Galite valdyti paketo aplinką atskiriems "production" (numatytajam) ir "development" versijoms turintiems paketams:

```sh
./bin/importmap pin react --env development
Pinning "react" to https://ga.jspm.io/npm:react@17.0.2/dev.index.js
Pinning "object-assign" to https://ga.jspm.io/npm:object-assign@4.1.1/index.js
```

Taip pat galite pasirinkti alternatyvų, palaikomą CDN tiekėją, pririšant, pvz., [`unpkg`](https://unpkg.com/) arba [`jsdelivr`](https://www.jsdelivr.com/) ([`jspm`](https://jspm.org/) yra numatytasis):

```sh
./bin/importmap pin react --from jsdelivr
Pinning "react" to https://cdn.jsdelivr.net/npm/react@17.0.2/index.js
```

Tačiau prisiminkite, kad jei pereinate nuo vieno tiekėjo prie kito, gali tekti išvalyti pirmo tiekėjo pridėtas priklausomybes, kurias naudoja antrasis tiekėjas.

Paleiskite `./bin/importmap`, kad pamatytumėte visas galimybes.

Atkreipkite dėmesį, kad ši komanda yra tik patogus apvalkalas, skirtas loginių paketų pavadinimų išsprendimui į CDN URL. Taip pat galite tiesiog patys ieškoti CDN URL ir tuomet pririšti juos. Pavyzdžiui, jei norėtumėte naudoti Skypack bibliotekai React, galėtumėte tiesiog pridėti šį kodą į `config/importmap.rb`:

```ruby
pin "react", to: "https://cdn.skypack.dev/react"
```

### Prikabintų modulių išankstinis įkėlimas

Norint išvengti vandens kritimo efekto, kai naršyklė turi įkelti vieną failą po kito, kol ji galės pasiekti giliausią įdėtą importą, importmap-rails palaiko [modulepreload nuorodas](https://developers.google.com/web/updates/2017/12/modulepreload). Prikabinti moduliai gali būti išankstinio įkėlimo, pridedant `preload: true` prie pririšimo.

Gera mintis yra išankstinio įkėlimo bibliotekos ar karkasai, kurie naudojami visoje jūsų aplikacijoje, nes tai pasakys naršyklei juos atsisiųsti anksčiau.

Pavyzdys:

```ruby
# config/importmap.rb
pin "@github/hotkey", to: "https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js", preload: true
pin "md5", to: "https://cdn.jsdelivr.net/npm/md5@2.3.0/md5.js"

# app/views/layouts/application.html.erb
<%= javascript_importmap_tags %>

# will include the following link before the importmap is setup:
<link rel="modulepreload" href="https://ga.jspm.io/npm:@github/hotkey@1.4.4/dist/index.js">
...
```
PASTABA: Norėdami gauti naujausią dokumentaciją, kreipkitės į [`importmap-rails`](https://github.com/rails/importmap-rails) saugyklą.

Kaip naudoti Sprockets
-----------------------------

Naivus būdas eksponuoti savo aplikacijos išteklius internetui būtų juos saugoti
`public` aplanko subaplankuose, tokiose kaip `images` ir `stylesheets`. Tai daryti rankiniu būdu būtų sunku, nes dauguma šiuolaikinių interneto aplikacijų reikalauja, kad ištekliai būtų apdorojami tam tikru būdu, pvz., suspaudžiant ir pridedant pirštų atspaudus prie išteklių.

Sprockets yra skirtas automatiškai apdoroti jūsų išteklius, saugomus konfigūruotuose aplankuose, ir po apdorojimo juos eksponuoti `public/assets` aplanke su pirštų atspaudais, suspaudimu, šaltinio žemėlapių generavimu ir kitomis konfigūruojamomis funkcijomis.

Ištekliai vis tiek gali būti dedami į `public` hierarchiją. Visi `public` aplanko ištekliai bus aptarnaujami kaip statiniai failai aplikacijos ar interneto serverio, kai [`config.public_file_server.enabled`][] yra nustatytas į `true`. Jūs turite apibrėžti `manifest.js` direktyvas
failams, kurie turi būti apdoroti prieš aptarnavimą.

Produkcijoje „Rails“ pagal numatytuosius nustatymus išankstinai kompiliuoja šiuos failus į `public/assets`. Išankstiniai kopijos tada aptarnaujamos kaip statiniai ištekliai interneto serverio. Failai
`app/assets` niekada nėra tiesiogiai aptarnaujami produkcijoje.


### Manifesto failai ir direktyvos

Kompiliuojant išteklius su Sprockets, Sprockets turi nuspręsti, kuriuos viršutinio lygio tikslus kompiliuoti, paprastai tai yra `application.css` ir paveikslėliai. Viršutinio lygio tikslai yra apibrėžti Sprockets `manifest.js` faile, pagal numatytuosius nustatymus jis atrodo taip:

```js
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../../../vendor/javascript .js
```

Jis turi _direktyvas_ - instrukcijas, kurios pasako Sprockets
kurias failus reikia įtraukti, kad būtų sukurtas vienas CSS ar JavaScript failas.

Tai skirta įtraukti visų failų, rastų `./app/assets/images` aplanke arba bet kuriame subaplanke, turinį, taip pat bet kurį failą, kuris yra JS, tiesiogiai `./app/javascript` ar `./vendor/javascript`.

Tai įkelia bet kokį CSS iš `./app/assets/stylesheets` aaplanko (neįskaitant subaplankų). Tarkime, kad `./app/assets/stylesheets` aplanke turite `application.css` ir `marketing.css` failus, tai leis jums įkelti tuos stilių lapus naudojant `<%= stylesheet_link_tag "application" %>` arba `<%= stylesheet_link_tag "marketing" %>` iš jūsų rodinių.

Pastebėsite, kad mūsų JavaScript failai pagal numatytuosius nustatymus neįkeliami iš `assets` aplanko, tai yra dėl to, kad `./app/javascript` yra numatytasis įėjimo taškas `importmap-rails` grotelėje, o `vendor` aplankas yra vieta, kurioje būtų saugomi atsisiųsti JS paketai.

`manifest.js` faile taip pat galite nurodyti `link` direktyvą, kad įkeltumėte konkretų failą vietoj viso aplanko. `link` direktyva reikalauja nurodyti aiškų failo plėtinį.

Sprockets įkelia nurodytus failus, juos apdoroja, jei
reikia, sujungia į vieną failą ir tada suspaudžia
(priklausomai nuo `config.assets.css_compressor` ar `config.assets.js_compressor` reikšmės).
Suspaudimas sumažina failo dydį, leidžiant naršyklei greičiau atsisiųsti failus.

### Kontrolerio specifiniai ištekliai

Generuojant skeletą arba kontrolerį, „Rails“ taip pat generuoja
kaskadinio stiliaus lapo failą tam kontroleriui. Be to, generuojant skeletą, „Rails“ generuoja failą `scaffolds.css`.

Pavyzdžiui, jei generuojate `ProjectsController`, „Rails“ taip pat pridės naują
failą `app/assets/stylesheets/projects.css`. Pagal numatytuosius nustatymus, šie failai bus
pasiruošę naudoti jūsų aplikacijos, naudojant `link_directory` direktyvą `manifest.js` faile.

Taip pat galite pasirinkti įtraukti tik kontrolerio specifinius stilių lapus
tik atitinkamuose kontroleriuose naudodami šią sintaksę:

```html+erb
<%= stylesheet_link_tag params[:controller] %>
```

Tai darant, įsitikinkite, kad jūsų `application.css` faile nenaudojate `require_tree` direktyvos, nes tai gali lemti jūsų kontrolerio specifinių išteklių įtraukimą daugiau nei vieną kartą.

### Išteklių organizavimas

Aplikacijoje „Pipeline“ ištekliai gali būti dedami į vieną iš trijų vietų: `app/assets`, `lib/assets` arba `vendor/assets`.

* `app/assets` skirtas aplikacijai priklausančių išteklių, tokiais kaip pasirinktiniai paveikslėliai ar stiliaus lapai.

* `app/javascript` skirtas jūsų „JavaScript“ kodui

* `vendor/[assets|javascript]` skirtas išorinių subjektų, tokiais kaip CSS karkasai ar „JavaScript“ bibliotekos, priklausančių išteklių. Atminkite, kad trečiųjų šalių kodas, turintis nuorodas į kitus failus, taip pat apdorojamus „Pipeline“ išteklių (paveikslėliai, stiliaus lapai ir kt.), turės būti perrašytas naudojant pagalbinius įrankius, pvz., `asset_path`.

Kitos vietos gali būti konfigūruojamos `manifest.js` faile, žr. [Manifesto failai ir direktyvos](#manifesto-failai-ir-direktyvos).

#### Paieškos keliai

Kai failas yra nuorodomas iš manifestų ar pagalbinių įrankių, Sprockets ieško jo visose `manifest.js` nurodytose vietose. Galite peržiūrėti paieškos kelią tikrinti
[`Rails.application.config.assets.paths`](configuring.html#config-assets-paths) „Rails“ konsolėje.
#### Indeksinių failų naudojimas kaip aplankų įgaliojimų

Sprockets naudoja failus, kurių pavadinimas yra `index` (su atitinkamais plėtiniais) specialiai paskirčiai.

Pavyzdžiui, jei turite CSS biblioteką su daugybe modulių, kuri yra saugoma `lib/assets/stylesheets/library_name`, failas `lib/assets/stylesheets/library_name/index.css` tarnauja kaip manifestas visiems šios bibliotekos failams. Šis failas gali apimti sąrašą visų reikalingų failų tvarka arba paprastą `require_tree` direktyvą.

Tai taip pat panašu į tai, kaip failas `public/library_name/index.html` gali būti pasiektas užklausoje į `/library_name`. Tai reiškia, kad negalite tiesiogiai naudoti indekso failo.

Visa biblioteka gali būti pasiekiama `.css` failuose taip:

```css
/* ...
*= require library_name
*/
```

Tai supaprastina priežiūrą ir išlaiko tvarką, leisdama susijusį kodą grupuoti prieš įtraukiant jį kitur.

### Nuorodos į turinį koduojimas

Sprockets nepapildo jokių naujų metodų, skirtų pasiekti jūsų turinį - vis tiek naudojate įprastą `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag "application", media: "all" %>
```

Jei naudojate [`turbo-rails`](https://github.com/hotwired/turbo-rails) gemą, kuris pagal numatymą yra įtrauktas į Rails, tada įtraukite `data-turbo-track` parinktį, kuri verčia Turbo patikrinti, ar turinys buvo atnaujintas, ir jei taip, įkelti jį į puslapį:

```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```

Įprastose peržiūrose galite pasiekti vaizdus `app/assets/images` kataloge taip:

```erb
<%= image_tag "rails.png" %>
```

Tiek ilgai, kol jūsų programoje yra įgalinta naudoti procesą (ir neįjungta esamoje aplinkos kontekste), šis failas yra aptarnaujamas Sprockets. Jei failas egzistuoja `public/assets/rails.png`, jis aptarnaujamas interneto serverio.

Alternatyviai, užklausa dėl failo su SHA256 maišos funkcija, pvz., `public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`, yra apdorojama taip pat. Kaip šie maišos funkcijos yra generuojami, aprašoma vėliau šiame vadove [Produkcijoje](#in-production).

Vaizdai taip pat gali būti organizuojami į subkatalogus, jei reikia, ir tada gali būti pasiekti, nurodant katalogo pavadinimą žymėje:

```erb
<%= image_tag "icons/rails.png" %>
```

ĮSPĖJIMAS: Jei išankstinio kompiliavimo savo turinio (žr. [Produkcijoje](#in-production) žemiau), nuoroda į neegzistuojantį turinį sukels išimtį kviečiančiame puslapyje. Tai apima nuorodą į tuščią eilutę. Todėl atsargiai naudokite `image_tag` ir kitus pagalbininkus su vartotojo pateiktais duomenimis.

#### CSS ir ERB

Turinio procesas automatiškai vertina ERB. Tai reiškia, kad jei CSS turiniui pridedate `erb` plėtinį (pvz., `application.css.erb`), tada pagalbininkai, pvz., `asset_path`, yra prieinami jūsų CSS taisyklėse:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

Tai įrašo nuorodą į konkretų turinį, į kurį yra nuorodoma. Šiame pavyzdyje turėtų būti vaizdas viename iš turinio kelių, pvz., `app/assets/images/image.png`, kuris būtų čia nuorodomas. Jei šis vaizdas jau yra prieinamas `public/assets` kaip piršto antspauduotas failas, tada yra nuorodoma į šį kelią.

Jei norite naudoti [duomenų URI](https://en.wikipedia.org/wiki/Data_URI_scheme) - būdą įterpti vaizdo duomenis tiesiogiai į CSS failą - galite naudoti `asset_data_uri` pagalbininką.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

Tai įterpia teisingai suformatuotą duomenų URI į CSS šaltinį.

Atkreipkite dėmesį, kad uždarymo žymė negali būti tokiu stiliaus `-%>`.

### Klaidos iškėlimas, kai turinys nerastas

Jei naudojate sprockets-rails >= 3.2.0, galite konfigūruoti, kas vyksta, kai vykdomas turinio paieška ir nieko nerandama. Jei išjungiate "turinio atsarginę kopiją", tada, kai negalima rasti turinio, bus iškelta klaida.

```ruby
config.assets.unknown_asset_fallback = false
```

Jei "turinio atsarginė kopija" yra įjungta, tada, kai negalima rasti turinio, kelias bus išvestas ir klaida nebus iškelta. Turinio atsarginės kopijos elgesys yra išjungtas pagal numatymą.

### Išjungti pirštų antspaudus

Galite išjungti pirštų antspaudus atnaujindami `config/environments/development.rb`, įtraukdami:

```ruby
config.assets.digest = false
```

Kai ši parinktis yra true, bus generuojami pirštų antspaudai turinio URL.

### Įjungti šaltinių žemėlapius

Galite įjungti šaltinių žemėlapius atnaujindami `config/environments/development.rb`, įtraukdami:

```ruby
config.assets.debug = true
```

Kai įjungtas derinimo režimas, Sprockets generuos šaltinių žemėlapį kiekvienam turiniui. Tai leidžia atskirai derinti kiekvieną failą naršyklės kūrėjo įrankiuose.

Turinys yra kompiliuojamas ir talpinamas keleto užklausų po to, kai serveris yra paleistas. Sprockets nustato `must-revalidate` Cache-Control HTTP antraštę, kad sumažintų užklausų perteklių kitose užklausose - jose naršyklė gauna 304 (Nekeista) atsakymą.
Jei bet kuris failas manifeste pasikeičia tarp užklausų, serveris atsako nauju sukompiliuotu failu.

Produkcijoje
------------

Produkcijos aplinkoje Sprockets naudoja anksčiau aprašytą pirštų atpažinimo schemą. Pagal numatytuosius nustatymus „Rails“ priima, kad turimi ištekliai buvo išankstinio kompiliavimo ir bus aptarnaujami kaip statiniai ištekliai jūsų interneto serverio.

Kompiliuojant, iš kompiliuotų failų turinio generuojamas SHA256 ir įterpiamas į failų pavadinimus, kai jie rašomi į diską. Šie pirštu atpažinti pavadinimai yra naudojami „Rails“ pagalbininkų vietoje manifestų pavadinimo.

Pavyzdžiui:

```erb
<%= stylesheet_link_tag "application" %>
```

generuoja kažką panašaus į tai:

```html
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" rel="stylesheet" />
```

Pirštu atpažinimo elgesį valdo [`config.assets.digest`][] inicijavimo parinktis (pagal numatytuosius nustatymus tai yra `true`).

PASTABA: Įprastomis aplinkybėmis numatytosios `config.assets.digest` parinkties keisti nereikėtų. Jei failų pavadinimuose nėra pirštų atpažinimo, ir nustatomi tolimojo laiko antraštės, nuotoliniai klientai niekada nežinos, kad turinys pasikeitė ir neatsiųs failų iš naujo.


### Išankstinis išteklių kompiliavimas

„Rails“ yra įdiegta komanda, skirta kompiliuoti išteklių manifestus ir kitus failus grandinėje.

Kompiliuoti ištekliai rašomi į vietą, nurodytą [`config.assets.prefix`][].
Pagal numatytuosius nustatymus tai yra `/assets` katalogas.

Galite iškviesti šią komandą serveryje, vykdant diegimą, kad sukurtumėte sukompiliuotas jūsų išteklių versijas tiesiogiai serveryje. Daugiau informacijos apie vietinį kompiliavimą žr. kitą skyrių.

Komanda yra:

```bash
$ RAILS_ENV=production rails assets:precompile
```

Tai susieja `config.assets.prefix` nurodytą aplanką su `shared/assets`. Jei jau naudojate šį bendrinį aplanką, turėsite parašyti savo diegimo komandą.

Svarbu, kad šis aplankas būtų bendrinamas tarp diegimų, kad nuotoliniai talpykloje esantys puslapiai, kurie nuorodo į senus sukompiliuotus išteklius, vis dar veiktų visą talpyklos puslapio gyvavimo laikotarpį.

PASTABA. Visada nurodykite tikėtiną sukompiliuoto failo pavadinimą, kuris baigiasi `.js` arba `.css`.

Komanda taip pat generuoja `.sprockets-manifest-randomhex.json` (kur `randomhex` yra 16 baitų atsitiktinio šešioliktainio skaičiaus eilutė), kuriame yra sąrašas su visais jūsų išteklių ir jų atitinkamų pirštų atpažinimų. Tai naudojama „Rails“ pagalbos metodams, kad nebūtų grąžinamos užklausos sujungimui su Sprockets. Tipiškas manifestų failas atrodo taip:

```json
{"files":{"application-<fingerprint>.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"<fingerprint>","integrity":"sha256-<random-string>"}},
"assets":{"application.js":"application-<fingerprint>.js"}}
```

Jūsų programoje manifeste bus daugiau failų ir išteklių, bus sugeneruoti `<fingerprint>` ir `<random-string>`.

Numatytasis manifestų vieta yra `config.assets.prefix` šaknis (pagal numatytuosius nustatymus '/assets').

PASTABA: Jei produkcijoje trūksta išankstinio kompiliavimo failų, gausite `Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError` išimtį, nurodančią trūkstamų failų pavadinimą(-us).


#### Tolimos ateities galiojimo laiko antraštė

Išankstiniai sukompiliuoti ištekliai yra failų sistemoje ir yra tiesiogiai aptarnaujami jūsų interneto serverio. Pagal numatytuosius nustatymus jie neturi tolimos ateities antraščių, todėl norint gauti pirštų atpažinimo naudą, turite atnaujinti serverio konfigūraciją, kad būtų pridėtos šios antraštės.

Apache:

```apache
# Expires* direktyvoms reikalingas įgalintas Apache modulis
# `mod_expires`.
<Location /assets/>
  # Naudojant Last-Modified, ETag naudojimas nerekomenduojamas
  Header unset ETag
  FileETag None
  # RFC sako, kad talpykai turi būti 1 metai
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

NGINX:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### Vietinis išankstinis kompiliavimas

Kartais gali būti, kad nenorite arba negalite kompiliuoti išteklių ant produkcijos serverio. Pavyzdžiui, galite turėti ribotą rašymo prieigą prie produkcijos failų sistemos arba galite planuoti dažnai diegti, nesikeisdami išteklių.

Tokiais atvejais galite išankstinį kompiliavimą atlikti _lokaliai_ - tai yra, prieš išleidžiant į produkciją, į savo šaltinio kodo saugyklą pridėti galutinį, sukompiliuotą, pasirengusį produkcijai išteklių rinkinį. Taip jie nereikės atskirai kompiliuoti ant produkcijos serverio kiekvieno diegimo metu.

Kaip ir anksčiau, šį žingsnį galite atlikti naudodami

```bash
$ RAILS_ENV=production rails assets:precompile
```

Atkreipkite dėmesį į šiuos apribojimus:

* Jei yra prieinami išankstiniai sukompiliuoti ištekliai, jie bus aptarnaujami - net jei jie nebetinka pradiniam (nesukompiliuotam) ištekliui, netgi vystymo serverio atveju.

    Norint užtikrinti, kad vystymo serveris visada kompiliuotų išteklius dinamiškai (ir visada atspindėtų naujausią kodo būseną), vystymo aplinka _turi būti sukonfigūruota taip, kad išankstiniai sukompiliuoti ištekliai būtų laikomi skirtingoje vietoje nei produkcija._ Kitu atveju, bet kokie produkcijai sukompiliuoti ištekliai perrašys užklausas vystyme (_t. y._, vėlesni pakeitimai, kuriuos atliekate ištekliuose, naršyklėje nebus atspindėti).
Tai galite padaryti pridėdami šią eilutę į `config/environments/development.rb`:

```ruby
config.assets.prefix = "/dev-assets"
```

* Turtų išankstinio kompiliavimo užduotis jūsų diegimo įrankyje (_pvz.,_ Capistrano) turėtų būti išjungta.
* Jūsų plėtros sistemoje turi būti prieinami visi reikalingi suspaudimo arba mažinimo įrankiai.

Taip pat galite nustatyti `ENV["SECRET_KEY_BASE_DUMMY"]`, kad būtų naudojamas atsitiktinai sugeneruotas `secret_key_base`, kuris yra saugomas laikiname faile. Tai naudinga, kai turtai yra išankstinio kompiliavimo produkcijai kaip dalis statinio žingsnio, kuris kitaip neturi prieigos prie produkcijos paslapčių.

```bash
$ SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
```

### Tiesioginio kompiliavimo režimas

Kai kuriomis aplinkybėmis galite norėti naudoti tiesioginį kompiliavimą. Šiuo režimu visi turtų užklausos yra apdorojamos tiesiogiai naudojant Sprockets.

Norėdami įgalinti šią parinktį, nustatykite:

```ruby
config.assets.compile = true
```

Pirmoje užklausoje turtai yra kompiliuojami ir talpinami kaip nurodyta [Turtų talpyklos saugykla](#assets-cache-store), o pagalbininkų naudojami manifestų pavadinimai yra keičiami, įtraukiant SHA256 maišos reikšmę.

Sprockets taip pat nustato `Cache-Control` HTTP antraštę į `max-age=31536000`. Tai signalizuoja visoms talpykloms tarp jūsų serverio ir kliento naršyklės, kad šis turinys (teikiamas failas) gali būti talpinamas 1 metus. Tai sumažina užklausų skaičių šiam turtui iš jūsų serverio; turtas turi didelę tikimybę būti vietinėje naršyklės talpykloje arba kitoje tarpinėje talpykloje.

Šis režimas naudoja daugiau atminties, veikia prasčiau nei numatytasis ir nerekomenduojamas.

### CDN

CDN reiškia [Turinio pristatymo tinklą](https://en.wikipedia.org/wiki/Content_delivery_network), jie yra skirti pagrindinai talpinti turtus visame pasaulyje, todėl, kai naršyklė prašo turto, talpinamos kopijos bus geografiškai arti tos naršyklės. Jei produkcijoje teikiate turtus tiesiogiai iš savo „Rails“ serverio, geriausia praktika yra naudoti CDN prieš savo programą.

Bendras šablono naudojimas CDN yra nustatyti savo produkcijos programą kaip „kilmės“ serverį. Tai reiškia, kad kai naršyklė prašo turto iš CDN ir yra talpyklos praleidimas, ji gaus failą iš jūsų serverio tiesiogiai ir jį talpins. Pavyzdžiui, jei paleidžiate „Rails“ programą „example.com“ ir turite CDN sukonfigūruotą „mycdnsubdomain.fictional-cdn.com“, tada, kai užklausa yra pateikiama „mycdnsubdomain.fictional-cdn.com/assets/smile.png“, CDN vieną kartą užklaus jūsų serverį „example.com/assets/smile.png“ ir talpins užklausą. Kitas užklausas į CDN, kuris ateina į tą pačią URL, pasieks talpinamą kopiją. Kai CDN gali tiesiogiai teikti turtą, užklausa niekada nepalies jūsų „Rails“ serverio. Kadangi CDN turto kopijos yra geografiškai arti naršyklės, užklausa yra greitesnė, ir kadangi jūsų serveriui nereikia skirti laiko teikti turtus, jis gali sutelkti dėmesį į kuo greitesnį programos kodo teikimą.

#### CDN sukonfigūravimas statiniams turtams teikti

Norėdami sukonfigūruoti savo CDN, jūsų programa turi veikti produkcijoje internete, prieinamoje URL, pvz., `example.com`. Toliau turėsite užsiregistruoti pas debesų talpinimo paslaugų teikėją CDN paslaugai gauti. Tai padarius, turite sukonfigūruoti CDN „kilmę“, kad ji rodytų atgal į jūsų svetainę `example.com`. Patikrinkite savo tiekėją dokumentaciją, kaip sukonfigūruoti kilmės serverį.

Jums suteiktas CDN turėtų suteikti jums savo programai pritaikytą subdomeną, pvz., `mycdnsubdomain.fictional-cdn.com` (pastaba: „fictional-cdn.com“ šiuo rašymo metu nėra galiojantis CDN tiekėjas). Dabar, kai sukonfigūravote savo CDN serverį, turite pranešti naršyklėms naudoti jūsų CDN, kad gautų turtus, o ne tiesiogiai iš jūsų „Rails“ serverio. Tai galite padaryti konfigūruodami „Rails“ nustatyti jūsų CDN kaip turto šaltinį, o ne naudoti santykinį kelią. Norėdami nustatyti savo turto šaltinį „Rails“, turite nustatyti [`config.asset_host`][] `config/environments/production.rb`:

```ruby
config.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

PASTABA: Jums tereikia nurodyti „host“ - tai yra subdomenas ir pagrindinė domena, jums nereikia nurodyti protokolo ar „scheme“, pvz., `http://` arba `https://`. Kai užklausa interneto puslapiui yra pateikiama, nuorodoje į jūsų turto generuojamą failą protokolas atitiks, kaip numatyta prieiga prie interneto puslapio.

Taip pat galite nustatyti šią reikšmę per [aplinkos kintamąjį](https://en.wikipedia.org/wiki/Environment_variable), kad būtų lengviau paleisti jūsų svetimojo tinklalapio kopiją:

```ruby
config.asset_host = ENV['CDN_HOST']
```

PASTABA: Norint, kad tai veiktų, jums reikės nustatyti `CDN_HOST` savo serveryje kaip `mycdnsubdomain.fictional-cdn.com`.

Kai jūs sukonfigūruosite savo serverį ir CDN, pagalbininkų pagalba sugeneruoti turinio kelio takai, tokie kaip:

```erb
<%= asset_path('smile.png') %>
```

Bus pateikiami kaip visiški CDN URL, pvz., `http://mycdnsubdomain.fictional-cdn.com/assets/smile.png`
(dėl aiškumo nenurodomas raktas).

Jei CDN turi kopiją `smile.png`, jis ją pateiks naršyklei, ir jūsų serveris net nežinos, kad ji buvo užklausta. Jei CDN neturi kopijos, jis bandys ją rasti "šaltinyje" `example.com/assets/smile.png` ir ją saugoti ateities naudojimui.

Jei norite tarnauti tik kai kurias turinio dalis iš savo CDN, galite naudoti pasirinktinį `:host` parametrą savo turinio pagalbos funkcijoje, kuris perrašo vertę, nustatytą [`config.action_controller.asset_host`][].

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```

#### Adaptuokite CDN talpinimo elgesį

CDN veikia talpinant turinį. Jei CDN turi pasenusį ar blogą turinį, tai kenkia, o ne padeda jūsų programai. Šio skyriaus tikslas yra apibūdinti bendrą daugumos CDN talpinimo elgesį. Jūsų konkretus tiekėjas gali elgtis šiek tiek kitaip.

##### CDN užklausos talpinimas

Nors CDN yra aprašomas kaip geras turinio talpinimui, jis iš tikrųjų talpina visą užklausą. Tai apima turinio kūną ir bet kokius antraštės duomenis. Svarbiausia yra `Cache-Control`, kuris nurodo CDN (ir naršyklėms), kaip talpinti turinį. Tai reiškia, kad jei kas nors užklauso turinį, kurio nėra, pvz., `/assets/i-dont-exist.png`, ir jūsų „Rails“ programa grąžina 404 klaidą, jūsų CDN tikriausiai talpins 404 puslapį, jei yra galiojantis `Cache-Control` antraštė.

##### CDN antraštės derinimas

Vienas būdas patikrinti, ar jūsų CDN tinkamai talpina antraštes, yra naudoti [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com). Galite paprašyti antraščių iš savo serverio ir CDN, kad patikrintumėte, ar jos yra tokios pačios:

```bash
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

Palyginus su CDN kopija:

```bash
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

Patikrinkite savo CDN dokumentaciją dėl papildomos informacijos, kurią jie gali pateikti, pvz., `X-Cache`, arba dėl papildomų antraščių, kuriuos jie gali pridėti.

##### CDN ir „Cache-Control“ antraštė

[`Cache-Control`][] antraštė apibūdina, kaip užklausa gali būti talpinama. Kai nenaudojamas CDN, naršyklė naudoja šią informaciją, kad talpintų turinį. Tai labai naudinga turiniui, kuris nėra keičiamas, kad naršyklė neprivalėtų atsisiųsti svetainės CSS ar JavaScript kiekvienoje užklausoje. Paprastai norime, kad mūsų „Rails“ serveris praneštų mūsų CDN (ir naršyklei), kad turinys yra „viešas“. Tai reiškia, kad bet koks talpinimas gali saugoti užklausą. Taip pat dažnai norime nustatyti `max-age`, tai yra, kiek laiko talpinimas saugos objektą, prieš panaikindamas talpinimą. `max-age` reikšmė nustatoma sekundėmis, o maksimali galima reikšmė yra `31536000`, tai yra vieneri metai. Tai galite padaryti savo „Rails“ programoje, nustatydami

```ruby
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

Dabar, kai jūsų programa tarnauja turinį produkcijoje, CDN saugos turinį iki vienerių metų. Kadangi dauguma CDN taip pat talpina užklausos antraštes, šis `Cache-Control` bus perduotas visoms ateities naršyklėms, ieškančioms šio turinio. Naršyklė tada žino, kad ji gali saugoti šį turinį labai ilgą laiką, prieš reikalaujant jį iš naujo užklausti.

##### CDN ir URL pagrindu vykdomas talpinimo atšaukimas

Dauguma CDN talpina turinio kopijas pagal visą URL. Tai reiškia, kad užklausai

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

Bus visiškai skirtingas talpinimas nei

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

Jei norite nustatyti tolimąjį `max-age` savo `Cache-Control` (ir tai norite), įsitikinkite, kad keisdami savo turinį atšaukiate talpinimą. Pavyzdžiui, keisdami šypsenėlės paveikslėlį nuo geltonos iki mėlynos, norite, kad visi jūsų svetainės lankytojai gautų naują mėlyną veidą. Naudojant „Rails“ turinio grandinėlę, pagal nutylėjimą `config.assets.digest` yra nustatytas kaip `true`, kad kiekvienas turinys turėtų skirtingą failo pavadinimą, kai jis keičiamas. Taip jums nereikia rankiniu būdu atšaukti jokių elementų talpinimo. Vietoje to, naudodami kitą unikalų turinio pavadinimą, jūsų vartotojai gauna naujausią turinį.
Pipelines pritaikymas
------------------------

### CSS suspaudimas

Vienas iš CSS suspaudimo variantų yra YUI. [YUI CSS
suspaudimo įrankis](https://yui.github.io/yuicompressor/css.html) suteikia
minifikavimą.

Ši eilutė įgalina YUI suspaudimą ir reikalauja `yui-compressor`
gem.

```ruby
config.assets.css_compressor = :yui
```

### JavaScript suspaudimas

Galimi JavaScript suspaudimo variantai yra `:terser`, `:closure` ir
`:yui`. Jie reikalauja `terser`, `closure-compiler` arba
`yui-compressor` gem, atitinkamai.

Pavyzdžiui, naudojamas `terser` gem.
Šis gem apgaubia [Terser](https://github.com/terser/terser) (parašytą
Node.js) Ruby. Jis suspaudžia kodą pašalindamas tarpus ir komentarus,
sutrumpindamas vietinių kintamųjų pavadinimus ir atliekant kitas mikrooptimizacijas,
tokias kaip `if` ir `else` sakiniai pakeičiant į ternary operatorius, kai tai įmanoma.

Ši eilutė iškviečia `terser` JavaScript suspaudimui.

```ruby
config.assets.js_compressor = :terser
```

PASTABA: Norėdami naudoti `terser`, jums reikės [ExecJS](https://github.com/rails/execjs#readme)
palaikomo vykdymo aplinkos. Jei naudojate macOS arba
Windows, jūsų operacinėje sistemoje jau yra įdiegta JavaScript vykdymo aplinka.

PASTABA: JavaScript suspaudimas taip pat veiks jūsų JavaScript failams, kai įkeliate savo turinį per `importmap-rails` arba `jsbundling-rails` gem'us.

### Jūsų pačių suspaudimo įrankio naudojimas

CSS ir JavaScript suspaudimo konfigūracijos nustatymai taip pat priima bet kokį objektą.
Šis objektas turi turėti `compress` metodą, kuris priima eilutę kaip vienintelį
argumentą ir turi grąžinti eilutę.

```ruby
class Transformer
  def compress(string)
    padaryti_kažką_gražinant_eilutę(string)
  end
end
```

Norėdami tai įgalinti, perduokite naują objektą konfigūracijos parinkčiai `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```

### _assets_ kelio keitimas

Pagal nutylėjimą, Sprockets naudoja viešąjį kelią `/assets`.

Tai gali būti pakeista į kažką kitą:

```ruby
config.assets.prefix = "/koks_nors_kitas_kelias"
```

Tai patogus pasirinkimas, jei atnaujinat senesnį projektą, kuris nenaudojo
turinio paleidimo ir jau naudoja šį kelią arba norite naudoti šį kelią naujam ištekliui.

### X-Sendfile antraštės

X-Sendfile antraštė yra nurodymas interneto serveriui ignoruoti atsakymą
iš programos ir vietoj to aptarnauti nurodytą failą iš disko. Ši parinktis
pagal nutylėjimą yra išjungta, tačiau ją galima įjungti, jei jūsų serveris ją palaiko. Įjungus
šią parinktį, failo aptarnavimo atsakomybė perduodama interneto serveriui, kas
yra greičiau. Peržiūrėkite [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)
kaip naudoti šią funkciją.

Apache ir NGINX palaiko šią parinktį, kuri gali būti įjungta
`config/environments/production.rb`:

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
```

ĮSPĖJIMAS: Jei atnaujinat esamą programą ir ketinate naudoti šią
parinktį, atidžiai įklijuokite šią konfigūracijos parinktį tik į `production.rb`
ir bet kurias kitas aplinkas, kurias apibrėžiate su produkcinėmis savybėmis (ne
`application.rb`).

PATARIMAS: Norėdami gauti daugiau informacijos, peržiūrėkite savo produkcinio interneto serverio dokumentaciją:

- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

Turinio talpyklos saugojimas
------------------

Pagal nutylėjimą, Sprockets talpina turinį `tmp/cache/assets` vystymo
ir produkcinėse aplinkose. Tai galima pakeisti taip:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

Norėdami išjungti turinio talpyklą:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Turinio pridėjimas į jūsų gem'us
--------------------------

Turinys taip pat gali būti gautas iš išorinių šaltinių, pvz., gem'ų.

Geras pavyzdys yra `jquery-rails` gem'as.
Šis gem'as turi variklio klasę, kuri paveldi iš `Rails::Engine`.
Tai informuoja Rails, kad šio gem'o katalogas gali turėti turinį ir `app/assets`, `lib/assets` ir
`vendor/assets` šio variklio katalogai pridedami prie paieškos kelio
Sprockets.

Padarykite savo biblioteką ar gem'ą pirmininku
------------------------------------------

Sprockets naudoja procesorius, transformatorius, suspaudėjus ir eksportuotojus, kad išplėstų
Sprockets funkcionalumą. Peržiūrėkite
[Sprockets plėtimas](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)
norėdami sužinoti daugiau. Čia mes užregistruojame pirmininką, kad pridėtume komentarą į pabaigą
teksto/css (`.css`) failams.

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

Dabar, kai turite modulį, keičiantį įvesties duomenis, laikas jį užregistruoti
kaip pirmininką savo MIME tipui.
```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```

Alternatyvūs bibliotekos
------------------------------------------

Per metus buvo daugybė numatytų būdų tvarkyti išteklius. Internetas tobulėjo ir pradėjome matyti vis daugiau ir daugiau JavaScript sunkių programų. "The Rails Doctrine" mes tikime, kad [The Menu Is Omakase](https://rubyonrails.org/doctrine#omakase), todėl mes sutelkėme dėmesį į numatytąją sąranką: **Sprockets su Import Maps**.

Mes žinome, kad nėra vieno dydžio sprendimų visiems turimiems JavaScript ir CSS karkasams/plėtiniams. Yra kitų bibliotekų, esančių "Rails" ekosistemoje, kurios turėtų jums suteikti galimybę, jei numatytas sąrankos būdas nepakanka.

### jsbundling-rails

[`jsbundling-rails`](https://github.com/rails/jsbundling-rails) yra priklausoma nuo "Node.js" alternatyva "importmap-rails" būdui susieti JavaScript su [esbuild](https://esbuild.github.io/), [rollup.js](https://rollupjs.org/) arba [Webpack](https://webpack.js.org/).

Gem suteikia `yarn build --watch` procesą, kuris automatiškai generuoja išvestį vystymo metu. Produkcijai jis automatiškai sujungia `javascript:build` užduotį su `assets:precompile` užduotimi, užtikrinant, kad būtų įdiegtos visos jūsų paketo priklausomybės ir būtų sukurta JavaScript visiems įėjimo taškams.

**Kada naudoti vietoj `importmap-rails`?** Jei jūsų JavaScript kodas priklauso nuo transpiliavimo, tai reiškia, kad naudojate [Babel](https://babeljs.io/), [TypeScript](https://www.typescriptlang.org/) arba React `JSX` formatą, tada `jsbundling-rails` yra tinkamas būdas.

### Webpacker/Shakapacker

[`Webpacker`](webpacker.html) buvo numatytasis JavaScript pirmininkas ir susiejiklis "Rails" 5 ir 6 versijoms. Dabar jis yra pasenusi. Egzistuoja paveldėtojas, vadinamas [`shakapacker`](https://github.com/shakacode/shakapacker), tačiau jį neaptarnauja "Rails" komanda ar projektas.

Skirtingai nei kitos bibliotekos šiame sąraše, `webpacker`/`shakapacker` yra visiškai nepriklausoma nuo Sprockets ir gali apdoroti tiek JavaScript, tiek CSS failus. Daugiau informacijos rasite [Webpacker vadove](https://guides.rubyonrails.org/webpacker.html).

PASTABA: Perskaitykite dokumentą [Palyginimas su Webpacker](https://github.com/rails/jsbundling-rails/blob/main/docs/comparison_with_webpacker.md), kad suprastumėte skirtumus tarp `jsbundling-rails` ir `webpacker`/`shakapacker`.

### cssbundling-rails

[`cssbundling-rails`](https://github.com/rails/cssbundling-rails) leidžia susieti ir apdoroti jūsų CSS naudojant [Tailwind CSS](https://tailwindcss.com/), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org/) arba [Dart Sass](https://sass-lang.com/), tada pristato CSS per išteklių grandinę.

Tai veikia panašiai kaip `jsbundling-rails`, todėl prideda "Node.js" priklausomybę jūsų programai su `yarn build:css --watch` procesu, kuris vystymo metu automatiškai atnaujina jūsų stilių lapus ir jungiasi prie `assets:precompile` užduoties produkcijai.

**Kokia skirtumas nuo Sprockets?** Sprockets vienas pats negali transpiliuoti Sass į CSS, reikalingas "Node.js", kad būtų galima generuoti `.css` failus iš jūsų `.sass` failų. Kai `.css` failai yra sugeneruoti, tada `Sprockets` gali juos pristatyti klientams.

PASTABA: `cssbundling-rails` priklauso nuo Node, kad apdorotų CSS. "Dartsass-rails" ir "tailwindcss-rails" gem'ai naudoja atskirus "Tailwind CSS" ir "Dart Sass" versijas, tai reiškia, kad nėra "Node" priklausomybės. Jei naudojate `importmap-rails` tvarkyti savo "Javascripts" ir `dartsass-rails` ar `tailwindcss-rails` CSS, galite visiškai išvengti "Node" priklausomybės, taip sumažindami sprendimo sudėtingumą.

### dartsass-rails

Jei norite naudoti [`Sass`](https://sass-lang.com/) savo programoje, [`dartsass-rails`](https://github.com/rails/dartsass-rails) yra pakeitimas senamodžiui `sassc-rails` gem'ui. `dartsass-rails` naudoja `Dart Sass` įgyvendinimą, o ne 2020 m. pasenusį [`LibSass`](https://sass-lang.com/blog/libsass-is-deprecated), kurį naudoja `sassc-rails`.

Skirtingai nei `sassc-rails`, naujas gem'as nėra tiesiogiai integruotas su `Sprockets`. Norėdami sužinoti daugiau, kreipkitės į [gem'o pagrindinį puslapį](https://github.com/rails/dartsass-rails) dėl diegimo/migracijos instrukcijų.

ĮSPĖJIMAS: Populiarus `sassc-rails` gem'as neaptarnaujamas nuo 2019 m.

### tailwindcss-rails

[`tailwindcss-rails`](https://github.com/rails/tailwindcss-rails) yra apvalkalas gem'ui [atskira vykdoma versija](https://tailwindcss.com/blog/standalone-cli) Tailwind CSS v3 karkasui. Naujiems programoms, kai `--css tailwind` yra pateikiamas `rails new` komandai. Vystymo metu suteikia `watch` procesą, kuris automatiškai generuoja Tailwind išvestį. Produkcijai jis jungiasi prie `assets:precompile` užduoties.
[`config.public_file_server.enabled`]: configuring.html#config-public-file-server-enabled
[`config.assets.digest`]: configuring.html#config-assets-digest
[`config.assets.prefix`]: configuring.html#config-assets-prefix
[`config.action_controller.asset_host`]: configuring.html#config-action-controller-asset-host
[`config.asset_host`]: configuring.html#config-asset-host
[`Cache-Control`]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
