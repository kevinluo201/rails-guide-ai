**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: c1e56036aa9fd68276daeec5a9407096
Dirbant su JavaScript „Rails“
================================

Šiame vadove aptariamos galimybės integruoti JavaScript funkcionalumą į jūsų „Rails“ aplikaciją,
įskaitant galimybes naudoti išorines JavaScript paketus ir kaip naudoti „Turbo“ su
„Rails“.

Po šio vadovo perskaitymo žinosite:

* Kaip naudoti „Rails“ be poreikio naudoti „Node.js“, „Yarn“ arba JavaScript rinkinį.
* Kaip sukurti naują „Rails“ aplikaciją, naudojant importavimo žemėlapius, esbuild, rollup arba webpack,
  savo JavaScript rinkinį.
* Kas yra „Turbo“ ir kaip jį naudoti.
* Kaip naudoti „Rails“ teikiamus „Turbo“ HTML pagalbininkus.

--------------------------------------------------------------------------------

Importavimo žemėlapiai
-----------

[Importavimo žemėlapiai](https://github.com/rails/importmap-rails) leidžia importuoti JavaScript modulius,
naudojant loginius pavadinimus, kurie tiesiogiai atitinka versijuotus failus iš naršyklės. Importavimo žemėlapiai yra numatyti
nuo „Rails“ 7 versijos, leidžiantys kiekvienam kurti modernias JavaScript aplikacijas, naudojant daugumą NPM paketų
be transpiliavimo ar rinkinio poreikio.

Aplikacijos, naudojančios importavimo žemėlapius, nebereikia [Node.js](https://nodejs.org/en/)
ar [Yarn](https://yarnpkg.com/) . Jei planuojate naudoti „Rails“ su `importmap-rails` savo JavaScript priklausomybėms valdyti,
nereikia įdiegti „Node.js“ ar „Yarn“.

Naudodami importavimo žemėlapius, nereikia atskiro kompiliavimo proceso, tiesiog paleiskite serverį su
`bin/rails server` ir galite pradėti.

### importmap-rails įdiegimas

Importmap „Rails“ automatiškai įtrauktas į naujas „Rails“ 7+ aplikacijas, tačiau jį taip pat galite įdiegti rankiniu būdu esančiose aplikacijose:

```bash
$ bin/bundle add importmap-rails
```

Paleiskite įdiegimo užduotį:

```bash
$ bin/rails importmap:install
```

### NPM paketų pridėjimas su importmap-rails

Norėdami pridėti naujus paketus prie savo importavimo žemėlapio valdomos aplikacijos, paleiskite `bin/importmap pin` komandą
iš terminalo:

```bash
$ bin/importmap pin react react-dom
```

Tada, kaip įprasta, importuokite paketą į `application.js`:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

NPM paketų pridėjimas su JavaScript rinkiniais
--------

Importavimo žemėlapiai yra numatyti naujoms „Rails“ aplikacijoms, tačiau jei pageidaujate tradicinio JavaScript
rinkinio, galite kurti naujas „Rails“ aplikacijas pasirinkdami vieną iš
[esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/) arba
[rollup.js](https://rollupjs.org/guide/en/) rinkinių.

Norėdami naudoti rinkinį vietoje importavimo žemėlapių naujoje „Rails“ aplikacijoje, perduokite `—javascript` arba `-j`
parinktį į `rails new`:

```bash
$ rails new my_new_app --javascript=webpack
ARBA
$ rails new my_new_app -j webpack
```

Kiekvienas rinkinio pasirinkimas turi paprastą konfigūraciją ir integraciją su turto eilute per
[jsbundling-rails](https://github.com/rails/jsbundling-rails) juostelė.

Naudodami rinkinio pasirinkimą, naudokite `bin/dev`, kad paleistumėte „Rails“ serverį ir sukurtumėte JavaScript
vystymui.

### Node.js ir Yarn įdiegimas

Jei savo „Rails“ aplikacijoje naudojate JavaScript rinkinį, būtina įdiegti „Node.js“ ir „Yarn“.

Raskite diegimo instrukcijas [Node.js svetainėje](https://nodejs.org/en/download/) ir
patikrinkite, ar jis įdiegtas teisingai, naudodami šią komandą:

```bash
$ node --version
```

Jūsų „Node.js“ vykdymo versija turėtų būti atspausdinta. Įsitikinkite, kad ji yra didesnė nei `8.16.0`.

Norėdami įdiegti „Yarn“, sekitės įdiegimo instrukcijas
[Yarn svetainėje](https://classic.yarnpkg.com/en/docs/install). Paleidus šią komandą turėtų būti atspausdinta
„Yarn“ versija:

```bash
$ yarn --version
```

Jei jis sako kažką panašaus į `1.22.0`, „Yarn“ buvo sėkmingai įdiegtas.

Pasirinkimas tarp importavimo žemėlapių ir JavaScript rinkinio
-----------------------------------------------------

Kuriant naują „Rails“ aplikaciją, turėsite pasirinkti tarp importavimo žemėlapių ir
JavaScript rinkinio sprendimo. Kiekviena aplikacija turi skirtingus reikalavimus, ir turėtumėte
atidžiai apsvarstyti savo reikalavimus prieš pasirinkdami JavaScript pasirinkimą, nes migracija iš vieno
pasirinkimo į kitą gali užtrukti ilgą laiką didelėms, sudėtingoms aplikacijoms.

Importavimo žemėlapiai yra numatytas pasirinkimas, nes „Rails“ komanda tiki importavimo žemėlapių potencialu
sumažinti sudėtingumą, pagerinti programuotojo patirtį ir suteikti naudos veikimo atžvilgiu.

Daugeliui aplikacijų, ypač tiems, kurie pagrįsti pagrindinai [Hotwire](https://hotwired.dev/)
steku savo JavaScript poreikiams, importavimo žemėlapiai bus tinkamas pasirinkimas ilgam laikui. Jūs
galite sužinoti daugiau apie pagrindimą, kodėl importavimo žemėlapiai yra numatytasis „Rails“ 7 pasirinkimas
[čia](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

Kitos aplikacijos gali vis dar reikėti tradicinio JavaScript rinkinio. Reikalavimai, rodantys
kad turėtumėte pasirinkti tradicinį rinkinį, apima:

* Jei jūsų kodas reikalauja transpiliavimo žingsnio, pvz., JSX ar TypeScript.
* Jei norite naudoti JavaScript bibliotekas, kurios įtraukia CSS ar kitaip priklauso nuo
  [Webpack pakrovėjų](https://webpack.js.org/loaders/).
* Jei esate visiškai tikri, kad jums reikia
  [medžio išpjovos](https://webpack.js.org/guides/tree-shaking/).
* Jei įdiegsite „Bootstrap“, „Bulma“, „PostCSS“ ar „Dart CSS“ per [cssbundling-rails gem](https://github.com/rails/cssbundling-rails). Visi šio gemo pasiūlyti variantai, išskyrus „Tailwind“ ir „Sass“, automatiškai įdiegs `esbuild` jums, jei nenurodysite kito pasirinkimo `rails new`.
Turbo
-----

Nepriklausomai nuo to, ar pasirenkate importo žemėlapius, ar tradicinį paketų tvarkyklę, „Rails“ yra įdiegtas
[Turbo](https://turbo.hotwired.dev/), kuris pagreitina jūsų programą ir žymiai sumažina
JavaScript kiekį, kurį turėsite parašyti.

Turbo leidžia jūsų serveriui tiesiogiai pristatyti HTML, kaip alternatyvą dominuojantiems priekinio galo
karkasams, kurie sumažina jūsų „Rails“ programos serverio pusę iki beveik tik JSON API.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) pagreitina puslapių įkėlimą, vengiant visiško puslapio
išardymo ir atkūrimo kiekvieno naršymo užklausos metu. Turbo Drive yra tobulinimas ir
Turbolinks pakeitimas.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) leidžia atnaujinti iš anksto nustatytas puslapio dalis
užklausoje, nepaveikiant kitos puslapio turinio dalies.

Galite naudoti Turbo Frames, kad kurtumėte vietinį redagavimą be jokio papildomo JavaScript, tingiai įkeltumėte
turinį ir lengvai kurtumėte serverio sugeneruotas skirtukų sąsajas.

„Rails“ teikia HTML pagalbines funkcijas, kurios palengvina Turbo Frames naudojimą per
[turbo-rails](https://github.com/hotwired/turbo-rails) grotelę.

Naudodami šią grotelę, galite pridėti Turbo Frame prie savo programos naudodami `turbo_frame_tag` pagalbininką
kaip šiuo pavyzdžiu:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(post) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) perduoda puslapio pakeitimus kaip HTML fragmentus,
apgaubtus savo vykdomaisiais `<turbo-stream>` elementais. Turbo Streams leidžia jums transliuoti
kitų vartotojų atliktus pakeitimus per WebSocket ir atnaujinti puslapio dalis po formos pateikimo
be reikalavimo visiškai perkrauti puslapį.

„Rails“ teikia HTML ir serverio pagalbines funkcijas, kurios palengvina Turbo Streams naudojimą per
[turbo-rails](https://github.com/hotwired/turbo-rails) grotelę.

Naudodami šią grotelę, galite sugeneruoti Turbo Streams iš valdiklio veiksmo:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

„Rails“ automatiškai ieškos `.turbo_stream.erb` peržiūros failo ir jį atvaizduos, kai jis bus rastas.

Turbo Stream atsakymus taip pat galima atvaizduoti tiesiogiai valdiklio veiksme:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Galiausiai, Turbo Streams gali būti inicijuojami iš modelio ar fono darbo naudojant įdiegtas pagalbines funkcijas.
Šie transliavimai gali būti naudojami atnaujinti turinį per WebSocket ryšį visiems vartotojams, išlaikant
puslapio turinį šviežią ir suteikiant jūsų programai gyvybę.

Norėdami transliuoti Turbo Stream iš modelio, sujunkite modelio atgalinį iškvietimą taip:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

Su WebSocket ryšiu, nustatytu puslapyje, kuris turėtų gauti atnaujinimus, kaip šiuo pavyzdžiu:

```erb
<%= turbo_stream_from "posts" %>
```

Pakeitimai „Rails/UJS“ funkcionalumui
----------------------------------------

„Rails“ 6 buvo pristatytas įrankis, vadinamas UJS (Nepastebimas JavaScript). UJS leidžia
programuotojams pakeisti `<a>` žymės HTTP užklausos metodą, pridėti patvirtinimo
dialogus prieš vykdant veiksmą ir kt. UJS buvo numatytas kaip numatytasis prieš „Rails“
7 versiją, tačiau dabar rekomenduojama naudoti Turbo.

### Metodas

Paspaudus nuorodas visada vykdoma HTTP GET užklausa. Jei jūsų programa yra
[RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer), kai kurios nuorodos iš tikrųjų yra
veiksmai, kurie keičia duomenis serveryje, ir turėtų būti atliekami naudojant ne GET
užklausas. `data-turbo-method` atributas leidžia pažymėti tokią nuorodą
konkrečiu metodu, pvz., „post“, „put“ arba „delete“.

Turbo nuskaitys `<a>` žymes jūsų programoje, ieškos `turbo-method` duomenų atributo ir naudos
nurodytą metodą, kai jis yra, pakeisdamas numatytąjį GET veiksmą.

Pavyzdžiui:

```erb
<%= link_to "Ištrinti įrašą", post_path(post), data: { turbo_method: "delete" } %>
```

Tai sugeneruos:

```html
<a data-turbo-method="delete" href="...">Ištrinti įrašą</a>
```

Alternatyva pakeisti nuorodos metodą naudojant `data-turbo-method` yra naudoti „Rails“
`button_to` pagalbininką. Dėl prieinamumo priežasčių tikri mygtukai ir formos yra pageidaujami bet kokiam
ne GET veiksmui.

### Patvirtinimai

Galite paprašyti papildomo patvirtinimo iš vartotojo, pridedant `data-turbo-confirm`
atributą prie nuorodų ir formų. Paspaudus nuorodą arba pateikus formą, vartotojui bus
pateiktas JavaScript `confirm()` dialogas, kuriame bus rodomas atributo tekstas.
Jei vartotojas pasirenka atšaukti, veiksmas nevykdomas.

Pavyzdžiui, naudojant `link_to` pagalbininką:

```erb
<%= link_to "Ištrinti įrašą", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Ar tikrai?" } %>
```

Kas generuoja:

```html
<a href="..." data-turbo-confirm="Ar tikrai?" data-turbo-method="delete">Ištrinti įrašą</a>
```
Kai naudotojas spusteli "Ištrinti įrašą" nuorodą, jam bus rodomas patvirtinimo dialogo langas "Ar tikrai?".

Atributas taip pat gali būti naudojamas su `button_to` pagalbininku, tačiau jis turi būti pridėtas prie formos, kurią `button_to` pagalbininkas sugeneruoja viduje:

```erb
<%= button_to "Ištrinti įrašą", post, method: :delete, form: { data: { turbo_confirm: "Ar tikrai?" } } %>
```

### Ajax užklausos

Kai iš JavaScript atliekamos ne-GET užklausos, reikalingas `X-CSRF-Token` antraštė. Be šios antraštės, užklausos nebus priimamos Rails.

PASTABA: Šis žetonas reikalingas Rails, kad būtų išvengta kryžminės svetainės užklausos sukčiavimo (CSRF) atakų. Daugiau informacijos rasite saugumo vadove [security guide](security.html#cross-site-request-forgery-csrf).

[Rails Request.JS](https://github.com/rails/request.js) apgaubia logiką, kurią reikia pridėti prie užklausos antraštės, kurių reikalauja Rails. Tiesiog importuokite `FetchRequest` klasę iš paketo ir sukurkite jos egzempliorių, perduodami užklausos metodą, URL, parinktis, tada iškvieskite `await request.perform()` ir atlikite norimus veiksmus su atsakymu.

Pavyzdžiui:

```javascript
import { FetchRequest } from '@rails/request.js'

....

async myMethod () {
  const request = new FetchRequest('post', 'localhost:3000/posts', {
    body: JSON.stringify({ name: 'Request.JS' })
  })
  const response = await request.perform()
  if (response.ok) {
    const body = await response.text
  }
}
```

Kai naudojama kita biblioteka, kad atliktumėte Ajax užklausas, būtina patys pridėti saugumo žetoną kaip numatytąją antraštę. Norėdami gauti žetoną, pažiūrėkite į `<meta name='csrf-token' content='THE-TOKEN'>` žymą, kurią spausdina [`csrf_meta_tags`][] jūsų aplikacijos rodinyje. Galite padaryti kažką panašaus:

```javascript
document.head.querySelector("meta[name=csrf-token]")?.content
```
[`csrf_meta_tags`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html#method-i-csrf_meta_tags
