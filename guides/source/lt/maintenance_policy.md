**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b3af31bbaec1019121ce4667087dc971
Ruby on Rails priežiūros politika
====================================

Rails karkaso palaikymas yra suskirstytas į keturias grupes: naujos funkcijos, klaidų taisymas, saugumo problemos ir rimtos saugumo problemos. Jos yra tvarkomos taip, visos versijos, išskyrus saugumo atnaujinimus, naudojant `X.Y.Z` formatą.

--------------------------------------------------------------------------------

Versijavimas
------------

Rails naudoja pasislinkusį [semver](https://semver.org/) versijavimo modelį:

**Patch `Z`**

Tik klaidų taisymai, be API pakeitimų, be naujų funkcijų.
Išskyrus atvejus, kai tai būtina saugumo taisymams.

**Minor `Y`**

Naujos funkcijos, gali turėti API pakeitimų (tarnauja kaip semver pagrindinės versijos).
Pakeitimai, kurie gali sugriauti suderinamumą, yra pranešami ankstesnės minorinės ar pagrindinės versijos deprecijos pranešimuose.

**Major `X`**

Naujos funkcijos, tikėtina, kad bus API pakeitimų. Skirtumas tarp Rails minorinių ir pagrindinių versijų yra pakeitimų, kurie gali sugriauti suderinamumą, mastas ir paprastai yra skirtas ypatingoms progoms.

Naujos funkcijos
------------

Naujos funkcijos yra pridedamos tik į pagrindinę šaką ir nebus prieinamos taško atnaujinimuose.

Klaidų taisymas
---------

Tik naujausia atnaujinimo serija gaus klaidų taisymus. Klaidų taisymai paprastai yra pridedami į pagrindinę šaką ir atgalinio suderinamumo su naujausia atnaujinimo serijos x-y-stable šaka, jei yra pakankamai poreikio. Kai x-y-stable šakoje yra pakankamai klaidų taisymų, iš jos yra sukuriamas naujas patch atnaujinimas. Pavyzdžiui, teorinis 1.2.2 patch atnaujinimas būtų sukurtas iš 1-2-stable šakos.

Ypatingais atvejais, kai kas nors iš pagrindinės komandos sutinka palaikyti daugiau serijų, jos įtraukiamos į palaikomų serijų sąrašą.

Nepalaikomoms serijoms klaidų taisymai gali atsitiktinai atsidurti stabilioje šakoje, tačiau jie nebus išleisti oficialioje versijoje. Rekomenduojama nukreipti savo programą į stabilią šaką naudojant Git nepalaikomoms versijoms.

**Šiuo metu įtrauktos serijos:** `7.1.Z`.

Saugumo problemos
---------------

Esama atnaujinimo serija ir ankstesnė paskutinė serija gaus taisymus ir naujas versijas, jei yra saugumo problema.

Šios atnaujinimo serijos yra sukuriamos pasiimant paskutinę išleistą versiją, taikant saugumo taisymus ir išleidžiant. Tada šie taisymai yra pridedami prie x-y-stable šakos pabaigos. Pavyzdžiui, teorinis 1.2.2.1 saugumo atnaujinimas būtų sukurtas iš 1.2.2 ir tada pridėtas prie 1-2-stable šakos pabaigos. Tai reiškia, kad saugumo atnaujinimai lengvai atnaujinami, jei naudojate naujausią Rails versiją.

Saugumo atnaujinimuose bus įtraukti tik tiesioginiai saugumo taisymai. Klaidų taisymai, nesusiję su saugumo problemomis, kylančiomis dėl saugumo taisymo, gali būti paskelbti atnaujinimo x-y-stable šakoje ir bus išleisti tik kaip naujas gem pagal Klaidų taisymo politiką.

Saugumo atnaujinimai yra sukurti iš paskutinės saugumo atnaujinimo šakos/žymos. Kitu atveju saugumo atnaujinime gali būti suderinamumo sutrikimų. Saugumo atnaujinime turėtų būti tik tie pakeitimai, kurie užtikrina programos saugumą, kad būtų lengviau atnaujinti programas.

**Šiuo metu įtrauktos serijos:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Rimtos saugumo problemos
----------------------

Rimtoms saugumo problemoms visos esamos pagrindinės serijos ir taip pat paskutinė ankstesnė pagrindinė serija gaus taisymus ir naujas versijas. Saugumo problemos klasifikacija yra vertinama pagal pagrindinės komandos narių nuomones.

**Šiuo metu įtrauktos serijos:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Nepalaikomos atnaujinimo serijos
--------------------------

Kai atnaujinimo serija nebepalaikoma, jūs patys turite susitvarkyti su klaidomis ir saugumo problemomis. Mes galime pateikti klaidų taisymų atgalines versijas ir jas sujungti, tačiau nebus išleistos naujos versijos. Rekomenduojame nukreipti savo programą į stabilią šaką naudojant Git. Jei jums nepatogu palaikyti savo pačių versijų, turėtumėte atnaujinti į palaikomą versiją.

NPM paketai
------------

Dėl apribojimo su npm, negalime naudoti ketvirto skaitmens saugumo atnaujinimams [NPM paketuose][], kurie yra teikiami Rails. Tai reiškia, kad vietoj ekvivalentinės gem versijos `7.0.1.4`, NPM paketas bus su numeracija `7.0.1-4`.

[NPM paketai]: https://www.npmjs.com/org/rails
