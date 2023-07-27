**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9f9c36972ad6f0627da4da84b0067618
Ruby on Rails Gidų gairės
===============================

Šiame gidui dokumentuojamos gairės, kaip rašyti Ruby on Rails gidus. Šis gidui seka save elegantiškame cikle, pateikdamas save kaip pavyzdį.

Po šio gidų perskaitymo jūs sužinosite:

* Apie konvencijas, kurias reikia naudoti Rails dokumentacijoje.
* Kaip generuoti gidus vietiniame kompiuteryje.

--------------------------------------------------------------------------------

Markdown
-------

Gidai rašomi naudojant [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown). Yra išsamios [Markdown dokumentacijos](https://daringfireball.net/projects/markdown/syntax), taip pat [cheatsheet](https://daringfireball.net/projects/markdown/basics).

Prologas
--------

Kiekvienas gidui turėtų prasidėti motyvuojančiu tekstu viršuje (tai mažas įvado tekstas mėlynajame lauke). Prologas turėtų pasakyti skaitytojui, apie ką yra gidai ir ką jie sužinos. Pavyzdžiui, žr. [Maršrutizavimo gidą](routing.html).

Antraštės
------

Kiekvieno gido pavadinimas naudoja `h1` antraštę; gido skyriai naudoja `h2` antraštes; posekiai naudoja `h3` antraštes; ir t.t. Atkreipkite dėmesį, kad sugeneruotas HTML išvestis naudos antraščių žymas pradedant nuo `<h2>`.

```markdown
Gido pavadinimas
===========

Skyrius
-------

### Po-skyrius
```

Rašant antraštes, didžiosios raides naudojamos visiems žodžiams, išskyrus prielinksnius, jungtukus, vidinius straipsnius ir būdvardžio "būti" formas:

```markdown
#### Teiginiai ir testavimo darbai komponentuose
#### Tarpinės eilutė yra masyvas
#### Kada objektai yra išsaugomi?
```

Naudokite tą patį įterpimo formatavimą kaip ir įprastam tekste:

```markdown
##### `:content_type` parinktis
```

Nuorodos į API
------------------

Nuorodos į API (`api.rubyonrails.org`) yra apdorojamos gidų generatoriumi pagal šią tvarką:

Nuorodos, kuriose yra išleidimo žyma, lieka nepakeistos. Pavyzdžiui

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

nekeičiama.

Prašome naudoti šias nuorodas išleidimo pastabose, nes jos turėtų rodyti į atitinkamą versiją, nepriklausomai nuo generuojamo tikslo.

Jei nuoroda neįtraukia išleidimo žymos ir generuojami kairės gidai, domenas pakeičiamas į `edgeapi.rubyonrails.org`. Pavyzdžiui,

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

tampa

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Jei nuoroda neįtraukia išleidimo žymos ir generuojami išleidimo gidai, įterpiamas Rails versija. Pavyzdžiui, jei generuojame gidus v5.1.0 versijai, nuoroda

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

tampa

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Prašome rankiniu būdu neįtraukti nuorodų į `edgeapi.rubyonrails.org`.

API dokumentacijos gairės
----------------------------

Gidai ir API turėtų būti suderinti ir nuoseklūs, kai tai yra tinkama. Ypač šie [API dokumentacijos gairių](api_documentation_guidelines.html) skyriai taip pat taikomi gidams:

* [Formulavimas](api_documentation_guidelines.html#wording)
* [Anglų kalba](api_documentation_guidelines.html#english)
* [Pavyzdinės kodas](api_documentation_guidelines.html#example-code)
* [Failų pavadinimai](api_documentation_guidelines.html#file-names)
* [Šriftai](api_documentation_guidelines.html#fonts)

HTML gidai
-----------

Prieš generuojant gidus, įsitikinkite, kad jūsų sistemoje įdiegta naujausia Bundler versija. Norėdami įdiegti naujausią Bundler versiją, paleiskite `gem install bundler`.

Jei jau turite įdiegtą Bundler, galite atnaujinti naudodami `gem update bundler`.

### Generavimas

Norėdami sugeneruoti visus gidus, tiesiog pereikite į `guides` katalogą, paleiskite `bundle install` ir vykdykite:

```bash
$ bundle exec rake guides:generate
```

arba

```bash
$ bundle exec rake guides:generate:html
```

Rezultatų HTML failai rasomi `./output` kataloge.

Norėdami apdoroti tik `my_guide.md` ir nieko kito, naudokite `ONLY` aplinkos kintamąjį:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

Pagal numatytuosius nustatymus gidai, kurie nebuvo modifikuoti, neapdorojami, todėl `ONLY` praktiškai retai reikalingas.

Norėdami priversti apdoroti visus gidus, perduokite `ALL=1`.

Jei norite generuoti gidus kitomis nei anglų kalba, galite juos laikyti atskirame kataloge po `source` (pvz., `source/es`) ir naudoti `GUIDES_LANGUAGE` aplinkos kintamąjį:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

Jei norite pamatyti visus aplinkos kintamuosius, kuriuos galite naudoti konfigūruoti generavimo scenarijų, tiesiog paleiskite:

```bash
$ rake
```

### Validacija

Prašome patikrinti sugeneruotą HTML naudojant:

```bash
$ bundle exec rake guides:validate
```

Ypač, pavadinimai gauna ID, kuris yra sugeneruojamas iš jų turinio, ir tai dažnai sukelia dublikatus.

Kindle gidai
-------------

### Generavimas

Norėdami generuoti gidus Kindle, naudokite šią rake užduotį:

```bash
$ bundle exec rake guides:generate:kindle
```
