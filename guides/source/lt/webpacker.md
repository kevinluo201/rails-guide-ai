**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 148ef2d23e16b9e0df83b14e98526736

Webpacker
=========

Šis vadovas parodys, kaip įdiegti ir naudoti Webpacker, kad supakuotumėte „JavaScript“, „CSS“ ir kitus turinius kliento pusėje savo „Rails“ programos, tačiau atkreipkite dėmesį, kad [Webpacker buvo atsiimtas](https://github.com/rails/webpacker#webpacker-has-been-retired-).

Po šio vadovo perskaitymo žinosite:

* Kas yra Webpacker ir kodėl jis skiriasi nuo Sprockets.
* Kaip įdiegti Webpacker ir jį integruoti su pasirinktu karkasu.
* Kaip naudoti Webpacker „JavaScript“ turiniams.
* Kaip naudoti Webpacker „CSS“ turiniams.
* Kaip naudoti Webpacker statiniams turiniams.
* Kaip talpinti svetainę, naudojančią Webpacker.
* Kaip naudoti Webpacker alternatyviose „Rails“ kontekstuose, pvz., „engines“ arba „Docker“ konteineriuose.

-------------------------------------------------- ------------

Kas yra Webpacker?
------------------

Webpacker yra „Rails“ įpakavimo sistema apie [webpack](https://webpack.js.org) kompiliavimo sistemą, kuri teikia standartinę webpack konfigūraciją ir pagrįstus numatytuosius nustatymus.

### Kas yra Webpack?

Webpack, arba bet kokia priekinės kompiliavimo sistema, tikslas yra leisti jums rašyti savo priekinio kodo būdą, patogų programuotojams, ir tada supakuoti tą kodą būdą, patogų naršyklėms. Su webpack galite valdyti „JavaScript“, „CSS“ ir statinius turinius, pvz., Nuotraukas ar šriftus. Webpack leis jums rašyti kodą, kreiptis į kitą kodą savo programoje, transformuoti kodą ir sujungti kodą į lengvai atsisiunčiamus paketus.

Daugiau informacijos rasite [webpack dokumentacijoje](https://webpack.js.org).

### Kaip Webpacker skiriasi nuo Sprockets?

„Rails“ taip pat pristato Sprockets, turinčią funkcijų, kurios sutampa su Webpacker. Abi priemonės kompiliuos jūsų „JavaScript“ į naršyklai draugiškus failus ir taip pat sumažins ir padarys pirštų antspaudus juos naudojant gamyboje. Vystymo aplinkoje Sprockets ir Webpacker leidžia palaipsniui keisti failus.

Sprockets, kuris buvo sukurtas naudoti su „Rails“, yra šiek tiek paprastesnis integruoti. Ypač kodas gali būti pridėtas prie Sprockets per „Ruby“ galiuką. Tačiau webpack geriau integruojasi su naujesniais „JavaScript“ įrankiais ir NPM paketais ir leidžia plačesniam integracijos diapazonui. Naujos „Rails“ programos yra sukonfigūruotos naudoti webpack „JavaScript“ ir Sprockets „CSS“, nors galite tai padaryti ir su CSS.

Jei norite naudoti NPM paketus ir / arba norite pasiekti naujausias „JavaScript“ funkcijas ir įrankius, naujame projekte turėtumėte pasirinkti Webpacker vietoje Sprockets. Jei norite naudoti Sprockets senesnėse programose, kur migracija gali būti brangi, jei norite integruotis naudojant galiukus arba jei turite labai mažai koduoti, turėtumėte pasirinkti Sprockets vietoje Webpacker.

Jei esate susipažinęs su Sprockets, šis vadovas gali jums suteikti tam tikrą vertimą. Atkreipkite dėmesį, kad kiekvienas įrankis turi šiek tiek skirtingą struktūrą, ir sąvokos tiesiogiai neatsiejamos viena nuo kitos.

|Užduotis | Sprockets | Webpacker |
|------------------|----------------------|-------------------|
|Pridėti „JavaScript“ |javascript_include_tag|javascript_pack_tag|
|Pridėti „CSS“        |stylesheet_link_tag   |stylesheet_pack_tag|
|Nuoroda į paveikslėlį  |image_url             |image_pack_tag     |
|Nuoroda į turinį  |asset_url             |asset_pack_tag     |
|Reikalauti scenarijaus  |//= require           |import or require  |

Webpacker įdiegimas
--------------------

Norėdami naudoti Webpacker, turite įdiegti „Yarn“ paketų tvarkytuvę, versiją 1.x ar naujesnę, ir turite įdiegti „Node.js“, versiją 10.13.0 ar naujesnę.

PASTABA: Webpacker priklauso nuo NPM ir Yarn. NPM, „Node“ paketų tvarkytuvės registras, yra pagrindinė saugykla, skirta publikuoti ir atsisiųsti atvirojo kodo „JavaScript“ projektus, tiek „Node.js“, tiek naršyklės vykdymo aplinkoms. Tai analogiška rubygems.org „Ruby“ galiukams. „Yarn“ yra komandinė programa, leidžianti įdiegti ir tvarkyti „JavaScript“ priklausomybes, panašiai kaip „Bundler“ „Ruby“.

Norėdami įtraukti Webpacker į naują projektą, į `rails new` komandą pridėkite `--webpack`. Norėdami pridėti Webpacker prie esamo projekto, į projekto `Gemfile` pridėkite `webpacker` galiuką, paleiskite `bundle install`, o tada paleiskite `bin/rails webpacker:install`.

Įdiegus Webpacker, sukuriama šių vietinių failų:

|Failas                    |Vieta                |Paaiškinimas                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|„JavaScript“ aplankas       | `app/javascript`       |Vieta jūsų priekinio kodo šaltiniams                                                                   |
|Webpacker konfigūracija | `config/webpacker.yml` |Konfigūruokite Webpacker galiuką                                                                         |
|Babel konfigūracija     | `babel.config.js`      |[Babel](https://babeljs.io) JavaScript kompiliatoriaus konfigūracija                               |
|PostCSS konfigūracija   | `postcss.config.js`    |[PostCSS](https://postcss.org) CSS poapdorojimo konfigūracija                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) valdo tikslinių naršyklių konfigūraciją   |


Diegimas taip pat iškviečia „yarn“ paketų tvarkytuvę, sukuria `package.json` failą su pagrindiniu sąrašu išvardytų paketų ir naudoja „Yarn“ įdiegti šias priklausomybes.

Naudingumas
-----

### Naudodami Webpacker „JavaScript“

Įdiegus Webpacker, bet kuris „JavaScript“ failas `app/javascript/packs` kataloge pagal numatytuosius nustatymus bus kompiliuojamas į savo atskirą paketo failą.
Todėl, jei turite failą pavadinimu `app/javascript/packs/application.js`, Webpacker sukurs paketą pavadinimu `application`, ir jį galėsite pridėti prie savo „Rails“ aplikacijos naudodami kodą `<%= javascript_pack_tag "application" %>`. Turint tai, vystymo metu „Rails“ perkompiliuos `application.js` failą kiekvieną kartą, kai jis pasikeis, ir įkeliant puslapį, kuris naudoja tą paketą. Paprastai, failas tikrojoje `packs` direktorijoje bus manifestas, kuris daugiausia įkelia kitus failus, tačiau jame taip pat gali būti bet koks JavaScript kodas.

Numatytasis paketas, kurį jums sukurs Webpacker, susietas su „Rails“ numatytosiomis JavaScript paketomis, jei jos yra įtrauktos į projektą:

```javascript
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

Norint naudoti šias paketas savo „Rails“ aplikacijoje, turėsite įtraukti paketą, kuris juos reikalauja.

Svarbu pažymėti, kad `app/javascript/packs` direktorijoje turėtų būti tik „webpack“ įėjimo failai; „Webpack“ kiekvienam įėjimo taškui sukurs atskirą priklausomybių grafą, todėl didelis paketų skaičius padidins kompiliavimo laiką. Visas jūsų turinio šaltinio kodas turėtų būti už šios direktorijos ribų, nors „Webpacker“ nekelia jokių apribojimų ar nesiūlo jokių rekomendacijų, kaip struktūrizuoti jūsų šaltinio kodą. Štai pavyzdys:

```sh
app/javascript:
  ├── packs:
  │   # tik „webpack“ įėjimo failai čia
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Paprastai, pats paketo failas yra daugiausia manifestas, kuris naudoja `import` arba `require` norint įkelti reikiamus failus ir gali atlikti tam tikrą inicializavimą.

Jei norite pakeisti šias direktorijas, galite keisti `source_path` (numatytoji reikšmė `app/javascript`) ir `source_entry_path` (numatytoji reikšmė `packs`) `config/webpacker.yml` faile.

Šaltinių failuose `import` teiginiai yra išsprendžiami atsižvelgiant į importuojantį failą, todėl `import Bar from "./foo"` ras `foo.js` failą toje pačioje direktorijoje, kaip ir esamas failas, o `import Bar from "../src/foo"` ras failą šalia esančioje gretimoje direktorijoje, pavadinimu `src`.

### „Webpacker“ naudojimas CSS

Iš pradžių „Webpacker“ palaiko CSS ir SCSS naudojant „PostCSS“ procesorių.

Norėdami įtraukti CSS kodą į savo paketus, pirmiausia įtraukite savo CSS failus į viršutinį paketo failą, tarsi tai būtų JavaScript failas. Taigi, jei jūsų viršutinio lygio CSS manifestas yra `app/javascript/styles/styles.scss`, galite jį importuoti su `import styles/styles`. Tai praneša „Webpack“, kad įtraukiate savo CSS failą į atsisiuntimą. Norėdami jį iš tikrųjų įkelti puslapyje, įtraukite `<%= stylesheet_pack_tag "application" %>` į rodinį, kur `application` yra tas pats paketo pavadinimas, kurį naudojote.

Jei naudojate CSS karkasą, galite jį pridėti prie „Webpacker“, laikydamiesi instrukcijų, kaip įkelti karkasą kaip „NPM“ modulį naudojant `yarn`, paprastai `yarn add <karkasas>`. Karkasas turėtų turėti instrukcijas, kaip jį importuoti į CSS ar SCSS failą.

### „Webpacker“ naudojimas statiniams ištekliams

Numatytasis „Webpacker“ [konfigūracija](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) turėtų veikti iškart su statiniais ištekliais.
Konfigūracija apima keletą paveikslėlio ir šrifto failų formatų plėtinių, leidžiančių „Webpack“ juos įtraukti į sugeneruotą `manifest.json` failą.

Su „Webpack“ statiniai ištekliai gali būti tiesiogiai importuojami į JavaScript failus. Importuota reikšmė atitinka ištekliaus URL. Pavyzdžiui:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "Aš esu „Webpacker“ sujungtas paveikslėlis";
document.body.appendChild(myImage);
```

Jei norite nuorodą į „Webpacker“ statinius išteklius iš „Rails“ rodinio, išteklius reikia išreiškiai reikalauti iš „Webpacker“ sujungtų JavaScript failų. Skirtingai nei „Sprockets“, „Webpacker“ pagal numatytąjį neimportuoja jūsų statinių išteklių. Numatytajame `app/javascript/packs/application.js` faile yra šablonas, skirtas failams importuoti iš tam tikros direktorijos, kurį galite atkomentuoti kiekvienai direktorijai, kurioje norite turėti statinius failus. Direktorijos yra santykinės `app/javascript` atžvilgiu. Šablonas naudoja direktoriją `images`, bet galite naudoti bet ką `app/javascript`:

```javascript
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

Statiniai ištekliai bus išvesti į direktoriją `public/packs/media`. Pavyzdžiui, paveikslėlis, esantis ir importuojamas iš `app/javascript/images/my-image.jpg`, bus išvestas į `public/packs/media/images/my-image-abcd1234.jpg`. Norint atvaizduoti paveikslėlio žymą šiam paveikslėliui „Rails“ rodinyje, naudokite `image_pack_tag 'media/images/my-image.jpg`.

„Webpacker“ „ActionView“ pagalbinės funkcijos statiniams ištekliams atitinka išteklių grandinės pagalbininkus pagal šią lentelę:
|ActionView pagalbininkas | Webpacker pagalbininkas |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

Taip pat, bendrinis pagalbininkas `asset_pack_path` priima vietinį failo vietą ir grąžina jo Webpacker vietą naudojimui „Rails“ peržiūrose.

Jūs taip pat galite pasiekti paveikslėlį, tiesiog nurodydami failą iš CSS failo „app/javascript“.

### Webpacker „Rails“ varikliuose

Nuo Webpacker 6 versijos, Webpacker nėra „variklio sąmoningas“, tai reiškia, kad Webpacker neturi funkcijų suderinamumo su „Sprockets“, kai naudojamas „Rails“ varikliuose.

„Rails“ variklio gem autoriai, norintys palaikyti vartotojus, naudojančius „Webpacker“, yra raginami platinant priekinės pabaigos turinį kaip „NPM“ paketą, papildomai prie paties gemo, ir pateikti instrukcijas (arba diegimo programą), kaip integruoti pagrindines programas. Geras šio požiūrio pavyzdys yra [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Karšto modulio pakeitimas (HMR)

Webpacker iš pradžių palaiko HMR su „webpack-dev-server“, ir jį galite įjungti nustatydami dev_server/hmr parinktį „webpacker.yml“.

Daugiau informacijos apie tai galite rasti [„webpack“ dokumentacijoje apie DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot).

Norėdami palaikyti HMR su „React“, turėtumėte pridėti „react-hot-loader“. Peržiūrėkite [„React Hot Loader“ _Pradžios gidas_](https://gaearon.github.io/react-hot-loader/getstarted/).

Nepamirškite išjungti HMR, jei nevykdote „webpack-dev-server“; kitu atveju gausite „nėra rasto klaidos“ stilių lapams.

Webpacker skirtingose aplinkose
-----------------------------------

Webpacker pagal numatytuosius nustatymus turi tris aplinkas: `development`, `test` ir `production`. Galite pridėti papildomas aplinkos konfigūracijas „webpacker.yml“ faile ir nustatyti skirtingus numatytuosius nustatymus kiekvienai aplinkai. Webpacker taip pat įkelia failą `config/webpack/<environment>.js` papildomai aplinkos sąrankai.

## Webpacker paleidimas vystymosi metu

Webpacker pristatomas su dviem „binstub“ failais, skirtais paleisti vystymosi metu: `./bin/webpack` ir `./bin/webpack-dev-server`. Abi yra ploni apvalkalai aplinkos pagrindiniams `webpack.js` ir `webpack-dev-server.js` vykdomiesiems failams ir užtikrina, kad būtų įkelti tinkami konfigūracijos failai ir aplinkos kintamieji pagal jūsų aplinką.

Pagal numatytuosius nustatymus, Webpacker automatiškai kompiliuoja pagal poreikį vystymosi metu, kai įkeliamas „Rails“ puslapis. Tai reiškia, kad jums nereikia paleisti jokių atskirų procesų, o kompiliavimo klaidos bus įrašomos į standartinį „Rails“ žurnalą. Tai galite pakeisti, pakeisdami į `compile: false` „config/webpacker.yml“ faile. Paleidus `bin/webpack`, bus priverstinai kompiliuojami jūsų paketai.

Jei norite naudoti gyvą kodo perkrovimą arba turite pakankamai „JavaScript“, kad kompiliavimas pagal poreikį būtų per lėtas, turėsite paleisti `./bin/webpack-dev-server` arba `ruby ./bin/webpack-dev-server`. Šis procesas stebės pakeitimus `app/javascript/packs/*.js` failuose ir automatiškai rekompiliuos ir perkraus naršyklę, kad atitiktų.

„Windows“ naudotojai turės paleisti šias komandas atskiroje terminaloje, atskiroje nuo `bundle exec rails server`.

Paleidus šį vystymosi serverį, Webpacker automatiškai pradės peradresuoti visus „webpack“ turinio užklausas į šį serverį. Kai sustabdysite serverį, jis grįš prie kompiliavimo pagal poreikį.

[Webpacker dokumentacija](https://github.com/rails/webpacker) suteikia informaciją apie aplinkos kintamuosius, kuriuos galite naudoti, norėdami valdyti `webpack-dev-server`. Peržiūrėkite papildomus užrašus [rails/webpacker dokumentuose apie „webpack-dev-server“ naudojimą](https://github.com/rails/webpacker#development).

### Webpacker diegimas

Webpacker prideda `webpacker:compile` užduotį `bin/rails assets:precompile` užduočiai, todėl bet kokia esama diegimo eiga, naudojusi `assets:precompile`, turėtų veikti. Kompiliavimo užduotis kompiliuos paketus ir juos padės į `public/packs`.

Papildoma dokumentacija
------------------------

Norėdami gauti daugiau informacijos apie pažangesnius temas, pvz., kaip naudoti Webpacker su populiariais karkasais, pasitarkite su [Webpacker dokumentacija](https://github.com/rails/webpacker).
