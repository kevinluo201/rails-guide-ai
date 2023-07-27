**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 4f7308fdab05dc13d399bde6a8ac302c
Action Cable apžvalga
=====================

Šiame vadove sužinosite, kaip veikia Action Cable ir kaip naudoti WebSocketus, kad galėtumėte įtraukti realaus laiko funkcijas į savo „Rails“ programą.

Po šio vadovo perskaitymo žinosite:

* Kas yra Action Cable ir jo integracija su serverio ir kliento pusėmis
* Kaip nustatyti Action Cable
* Kaip nustatyti kanalus
* Kaip diegti ir kurti architektūrą, skirtą Action Cable paleisti

--------------------------------------------------------------------------------

Kas yra Action Cable?
---------------------

Action Cable be jokių problemų integruoja [WebSocketus](https://en.wikipedia.org/wiki/WebSocket) su jūsų „Rails“ programa. Tai leidžia rašyti realaus laiko funkcijas „Ruby“ kalba taip pat, kaip ir visą kitą „Rails“ programą, išlaikant efektyvumą ir skalėjimą. Tai yra visiškai integruota paslauga, kuri teikia tiek kliento pusės „JavaScript“ karkasą, tiek serverio pusės „Ruby“ karkasą. Jūs turite prieigą prie viso savo domeno modelio, kuris yra parašytas naudojant „Active Record“ arba jūsų pasirinktą ORM.

Terminologija
-----------

Action Cable naudoja WebSocketus vietoj HTTP užklausos-atsakymo protokolo. Tie patys Action Cable ir WebSocketai įveda keletą mažiau žinomų terminų:

### Ryšiai

*Ryšiai* sudaro pagrindą kliento-serverio santykiams. Vienas Action Cable serveris gali tvarkyti kelis ryšio pavyzdžius. Jis turi vieną ryšio pavyzdį vienam WebSocket ryšiui. Vienas vartotojas gali turėti kelis atvirus WebSocketus jūsų programoje, jei jie naudoja kelias naršyklės korteles ar įrenginius.

### Vartotojai

WebSocket ryšio klientas vadinamas *vartotoju*. Action Cable vartotojas yra sukurtas kliento pusės „JavaScript“ karkaso.

### Kanalai

Kiekvienas vartotojas gali prenumeruoti kelis *kanalus*. Kiekvienas kanalas apima loginį darbo vienetą, panašų į tai, ką daro valdiklis tipinėje MVC struktūroje. Pavyzdžiui, galite turėti „ChatChannel“ ir „AppearancesChannel“, o vartotojas gali būti prenumeruotas vienam ar abiem šiems kanalams. Bent jau vartotojas turėtų būti prenumeruotas vienam kanalui.

### Prenumeratoriai

Kai vartotojas yra prenumeruotas kanalui, jis veikia kaip *prenumeratorius*. Ryšys tarp prenumeratoriaus ir kanalo yra, kaip ir galima manyti, vadinamas prenumerata. Vartotojas gali veikti kaip prenumeratorius tam tikram kanalui bet kiek kartų. Pavyzdžiui, vartotojas gali prenumeruoti kelias pokalbių kambarius tuo pačiu metu. (Ir prisiminkite, kad fizinis vartotojas gali turėti kelis vartotojus, vieną kiekvienai atvirei kortelei / įrenginiui, kuris yra atviresnis jūsų ryšiui).

### Pub/Sub

[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) arba leidimas-prenumeravimas nurodo žinučių eilės paradigmą, kurioje informacijos siuntėjai (leidėjai) siunčia duomenis abstrakčiai gavėjų kategorijai (prenumeratoriams), nenurodydami individualių gavėjų. Action Cable naudoja šį požiūrį bendrauti tarp serverio ir daugybės klientų.

### Transliacijos

Transliacija yra leidimo-prenumeravimo nuoroda, kuria bet kas, siunčiantis transliuotojo, tiesiogiai siunčia kanalo prenumeratoriams, kurie stebi tą pavadinimą. Kiekvienas kanalas gali stebėti nulį ar daugiau transliacijų.

## Serverio pusės komponentai

### Ryšiai

Kiekvienam WebSocketui, priimtam serverio, sukuriamas ryšio objektas. Šis objektas tampa visų *kanalų prenumeratų* tėvu, kurie yra sukurti nuo to momento. Ryšis pats nesiduria su jokia specifine programos logika, išskyrus autentifikaciją ir autorizaciją. WebSocket ryšio klientas vadinamas ryšio *vartotoju*. Vienas vartotojas sukurs vieną vartotojo-ryšio porą vienam naršyklės skirtuke, langelyje ar įrenginyje, kurį jie turi atvirą.

Ryšiai yra `ApplicationCable::Connection` pavyzdžiai, kurie išplečia [`ActionCable::Connection::Base`][]. `ApplicationCable::Connection` klasėje jūs patvirtinate įeinantį ryšį ir, jei vartotojas gali būti nustatytas, tęsite su jo nustatymu.

#### Ryšio nustatymas

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Čia [`identified_by`][] nurodo ryšio identifikatorių, kuris vėliau gali būti naudojamas rasti konkretų ryšį. Atkreipkite dėmesį, kad bet kas, pažymėta kaip identifikatorius, automatiškai sukurs delegatą su tuo pačiu pavadinimu visiems kanalų pavyzdžiams, sukurtiems iš ryšio.

Šis pavyzdys remiasi tuo, kad jūs jau esate apdorotas vartotojo autentifikacijos kažkur kitur savo programoje ir sėkminga autentifikacija nustato užšifruotą slapuką su vartotojo ID.

Slapukas automatiškai siunčiamas ryšio pavyzdžiui, kai bandote sukurti naują ryšį, ir jį naudojate, kad nustatytumėte `current_user`. Nurodydami ryšį šiuo pačiu dabartiniu vartotoju, taip pat užtikrinate, kad vėliau galėsite gauti visus atvirus ryšius pagal tam tikrą vartotoją (ir galbūt juos visus atjungti, jei vartotojas yra ištrintas arba neturi teisės).
Jei jūsų autentifikavimo metodas apima sesijos naudojimą, naudojate slapukų saugyklą sesijai, jūsų sesijos slapukas yra pavadinimu `_session`, o naudotojo ID raktas yra `user_id`, galite naudoti šį metodą:

```ruby
verified_user = User.find_by(id: cookies.encrypted['_session']['user_id'])
```


#### Išimčių tvarkymas

Pagal nutylėjimą, neapdorotos išimtys yra sugaunamos ir įrašomos į „Rails“ žurnalo failą. Jei norite visuotinai perimti šias išimtis ir pranešti apie jas išoriniam klaidų sekimo paslaugai, pavyzdžiui, galite tai padaryti naudodami [`rescue_from`][]:

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    rescue_from StandardError, with: :report_error

    private
      def report_error(e)
        SomeExternalBugtrackingService.notify(e)
      end
  end
end
```


#### Ryšio atgalinimo iškvietimai

Yra `before_command`, `after_command` ir `around_command` atgalinimo iškvietimai, kurie gali būti iškviesti prieš, po arba aplink kiekvieną kliento gautą komandą atitinkamai.
Čia terminas „komanda“ nurodo bet kokį kliento gautą sąveiką (prenumeravimą, atsisakymą prenumeruoti arba veiksmų vykdymą):

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user

    around_command :set_current_account

    private
      def set_current_account(&block)
        # Dabar visi kanalai gali naudoti Current.account
        Current.set(account: user.account, &block)
      end
  end
end
```

### Kanalai

*Kanalas* apgaubia loginį darbą, panašų į tai, ką daro valdiklis tipinėje MVC konfigūracijoje. Pagal nutylėjimą „Rails“ sukuria pagrindinę `ApplicationCable::Channel` klasę
(kuri išplečia [`ActionCable::Channel::Base`][]) bendrai logikai tarp jūsų kanalų apgaubti.

#### Pagrindinio kanalo konfigūracija

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Tada galėtumėte sukurti savo kanalų klases. Pavyzdžiui, galite turėti
`ChatChannel` ir `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end
```

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```


Vartotojas tada gali būti prenumeruotas vienam ar abiem šiems kanalams.

#### Prenumeratos

Vartotojai prenumeruoja kanalus, veikdami kaip *prenumeratoriai*. Jų ryšys yra
vadinamas *prenumerata*. Gauti pranešimai tada yra nukreipiami į šių kanalų
prenumeratas pagal kanalo prenumeratoriaus siunčiamą identifikatorių.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Iškviečiama, kai vartotojas sėkmingai
  # tampa šio kanalo prenumeratoriumi.
  def subscribed
  end
end
```

#### Išimčių tvarkymas

Kaip ir su `ApplicationCable::Connection`, taip pat galite naudoti [`rescue_from`][] konkrečiame kanale, kad tvarkytumėte iškeltus išimtis:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  private
    def deliver_error_message(e)
      broadcast_to(...)
    end
end
```

#### Kanalo atgalinimo iškvietimai

`ApplicationCable::Channel` teikia keletą atgalinimo iškvietimų, kurie gali būti naudojami, kad būtų galima paleisti logiką
kanalo gyvavimo ciklo metu. Galimi atgalinimo iškvietimai yra:

- `before_subscribe`
- `after_subscribe` (taip pat pavadinimu: `on_subscribe`)
- `before_unsubscribe`
- `after_unsubscribe` (taip pat pavadinimu: `on_unsubscribe`)

PASTABA: `after_subscribe` atgalinimo iškvietimas yra paleidžiamas, kai tik yra iškviesta `subscribed` metodas,
net jei prenumerata buvo atmesta naudojant `reject` metodą. Norėdami paleisti `after_subscribe`
tik sėkmingoms prenumeratoms, naudokite `after_subscribe :send_welcome_message, unless: :subscription_rejected?`

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  after_subscribe :send_welcome_message, unless: :subscription_rejected?
  after_subscribe :track_subscription

  private
    def send_welcome_message
      broadcast_to(...)
    end

    def track_subscription
      # ...
    end
end
```

## Kliento komponentai

### Ryšiai

Vartotojai savo pusėje reikalauja ryšio egzemplioriaus. Tai gali būti
nustatoma naudojant šį numatytąjį „JavaScript“, kurį generuoja „Rails“:

#### Prijungti prenumeratorių

```js
// app/javascript/channels/consumer.js
// „Action Cable“ teikia pagrindą dirbti su „WebSockets“ „Rails“.
// Galite generuoti naujus kanalus, kuriuose gyvena „WebSocket“ funkcijos, naudodami komandą `bin/rails generate channel`.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Tai paruoš šaltinį, kuris pagal nutylėjimą prisijungs prie `/cable` jūsų serverio.
Ryšys nebus nustatytas, kol nebus nurodyta bent viena prenumerata,
kurią norite turėti.

Prenumeratorius galima pasirinktinai perduoti argumentą, kuriame nurodomas URL, prie kurio prisijungti. Tai
gali būti eilutė arba funkcija, kuri grąžina eilutę, kuri bus iškviesta, kai
WebSocket bus atidarytas.

```js
// Nurodyti kitą prisijungimo URL
createConsumer('wss://example.com/cable')
// Arba naudojant WebSocketus per HTTP
createConsumer('https://ws.example.com/cable')

// Naudoti funkciją, kuri dinamiškai generuoja URL
createConsumer(getWebSocketURL)

function getWebSocketURL() {
  const token = localStorage.get('auth-token')
  return `wss://example.com/cable?token=${token}`
}
```

#### Prenumeratorius

Vartotojas tampa prenumeratoriumi, sukurdamas prenumeratą tam tikram kanalui:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Nors tai sukuria prenumeratą, funkcionalumas, reikalingas atsakyti į
gautus duomenis, bus aprašytas vėliau.
Vartotojas gali veikti kaip prenumeratorius tam tikram kanalui bet kiek kartų. Pavyzdžiui, vartotojas gali prenumeruoti kelias pokalbių kambarius tuo pačiu metu:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1-as kambarys" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2-as kambarys" })
```

## Kliento-serverio sąveikos

### Srautai

*Srautai* suteikia mechanizmą, pagal kurį kanalai maršrutizuoja paskelbtą turinį (transliacijas) savo prenumeratoriams. Pavyzdžiui, šis kodas naudoja [`stream_from`][] prenumeruoti transliaciją pavadinimu `chat_Geriausias kambarys`, kai `:room` parametras yra `"Geriausias kambarys"`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Tada, kitur jūsų „Rails“ aplikacijoje, galite transliuoti į tokią patalpą, iškviesdami [`broadcast`][]:

```ruby
ActionCable.server.broadcast("chat_Geriausias kambarys", { body: "Šis kambarys yra geriausias." })
```

Jei turite srautą, susijusį su modeliu, tada transliavimo pavadinimą galima generuoti iš kanalo ir modelio. Pavyzdžiui, šis kodas naudoja [`stream_for`][] prenumeruoti transliaciją kaip `posts:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`, kur `Z2lkOi8vVGVzdEFwcC9Qb3N0LzE` yra „Post“ modelio GlobalID.

```ruby
class PostsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

Tada galite transliuoti į šį kanalą, iškviesdami [`broadcast_to`][]:

```ruby
PostsChannel.broadcast_to(@post, @comment)
```


### Transliacijos

*Transliacija* yra pub/sub nuoroda, kuriai transliuojantys duomenys tiesiogiai nukreipiami į kanalo prenumeratorius, kurie transliuoja tą pavadinimą. Kiekvienas kanalas gali transliuoti nulinį arba daugiau transliacijų.

Transliacijos yra tik internetinė eilė ir priklauso nuo laiko. Jei vartotojas nesistebi (prenumeruoja tam tikrą kanalą), jis negaus transliacijos, jei vėliau prisijungs.

### Prenumeratos

Kai vartotojas prenumeruoja kanalą, jis veikia kaip prenumeratorius. Ši ryšys vadinamas prenumerata. Įeinančios žinutės tada nukreipiamos į šiuos kanalo prenumeratas pagal kabelio vartotojo siunčiamą identifikatorių.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Geriausias kambarys" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Geriausias kambarys']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### Parametrų perdavimas kanalams

Galite perduoti parametrus iš kliento pusės į serverio pusę, kuriant prenumeratą. Pavyzdžiui:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

Objektas, perduotas kaip pirmasis argumentas `subscriptions.create`, tampa parametrų maišu kabelio kanale. Reikalingas raktažodis `channel`:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Geriausias kambarys" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Geriausias kambarys']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# Irgkur jūsų programoje tai yra iškviesta, galbūt
# iš „NewCommentJob“.
ActionCable.server.broadcast(
  "chat_#{room}",
  {
    sent_by: 'Paul',
    body: 'Tai yra nuostabi pokalbių programa.'
  }
)
```

### Pranešimo persiuntimas

Daugelio klientų išsiųsto pranešimo persiuntimas bet kuriems kitoms prisijungusioms klientams yra įprasta naudojimo atvejis.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Geriausias kambarys" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "Tai yra nuostabi pokalbių programa." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "Tai yra nuostabi pokalbių programa." })
```

Persiųstas pranešimas bus gautas visų prisijungusių klientų, _įskaitant_ klientą, kuris išsiuntė pranešimą. Atkreipkite dėmesį, kad parametrai yra tokie patys, kaip ir prenumeruojant kanalą.

## Pilno naudojimo pavyzdžiai

Šie sąrankos žingsniai yra bendri abiem pavyzdžiams:

  1. [Nustatykite savo ryšį](#connection-setup).
  2. [Nustatykite pagrindinį kanalą](#parent-channel-setup).
  3. [Prijunkite savo vartotoją](#connect-consumer).

### Pavyzdys 1: Vartotojų pasirodymai

Štai paprastas kanalo pavyzdys, kuris stebi, ar vartotojas yra prisijungęs ar ne, ir kuriame puslapyje jie yra. (Tai naudinga, jei norite sukurti funkcijas, kurios rodo žalią tašką šalia vartotojo vardo, jei jie yra prisijungę).

Sukurkite serverio pusės pasirodymo kanalą:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```
Kai užsakymas yra pradėtas, `subscribed` atgalinis iškvietimas yra paleidžiamas, ir mes pasinaudojame šia galimybe pasakyti "dabartinis vartotojas tikrai pasirodė". Ši pasirodymo / dingimo API gali būti paremta Redis, duomenų baze ar bet kuo kitu.

Sukurkite klientinį pasirodymo kanalo užsakymą:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Iškviečiama tik kartą, kai užsakymas yra sukurtas.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Iškviečiama, kai užsakymas yra pasiruošęs naudoti serveryje.
  connected() {
    this.install()
    this.update()
  },

  // Iškviečiama, kai WebSocket ryšys yra uždarytas.
  disconnected() {
    this.uninstall()
  },

  // Iškviečiama, kai užsakymas yra atmestas serverio.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Iškviečia `AppearanceChannel#appear(data)` serveryje.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Iškviečia `AppearanceChannel#away` serveryje.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

#### Kliento-Serverio sąveika

1. **Klientas** prisijungia prie **Serverio** per `createConsumer()`. (`consumer.js`). 
   **Serveris** identifikuoja šį ryšį pagal `current_user`.

2. **Klientas** užsiregistruoja pasirodymo kanalui per
   `consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Serveris** atpažįsta, kad buvo pradėtas naujas užsakymas pasirodymo kanalui ir paleidžia savo `subscribed` atgalinį iškvietimą, iškviečiant `appear` metodą `current_user`. (`appearance_channel.rb`)

4. **Klientas** atpažįsta, kad užsakymas buvo įtvirtintas ir iškviečia `connected` (`appearance_channel.js`), kuris savo ruožtu iškviečia `install` ir `appear`. `appear` iškviečia `AppearanceChannel#appear(data)` serveryje ir pateikia duomenų maišą `{ appearing_on: this.appearingOn }`. Tai įmanoma, nes serverio pusės kanalo egzempliorius automatiškai atskleidžia visus viešus metodus, deklaruotus klasėje (minus atgaliniai iškvietimai), kad šie būtų pasiekiami kaip nuotoliniai procedūrų kvietimai per užsakymo `perform` metodą.

5. **Serveris** gauna užklausą dėl `appear` veiksmo pasirodymo kanale, skirtą `current_user` identifikuotam ryšiui (`appearance_channel.rb`). **Serveris** gauna duomenis su `:appearing_on` raktu iš duomenų maišo ir nustato jį kaip reikšmę `:on` rakčiai, kuri perduodama `current_user.appear`.

### Pavyzdys 2: Naujų internetinių pranešimų gavimas

Pasirodymo pavyzdys buvo visiškai apie serverio funkcionalumo atskleidimą klientinio kvietimo per WebSocket ryšį. Bet puikus dalykas apie WebSocket yra tai, kad tai yra dvipusis kelias. Taigi, dabar parodykime pavyzdį, kai serveris iškviečia veiksmą kliente.

Tai yra internetinių pranešimų kanalas, kuris leidžia jums paleisti klientinio pusės internetinius pranešimus, kai jūs transliuojate atitinkamoms srautams:

Sukurkite serverio internetinių pranešimų kanalą:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Sukurkite klientinio pusės internetinių pranešimų kanalo užsakymą:

```js
// app/javascript/channels/web_notifications_channel.js
// Klientinė pusė, kuri priima, kad jau prašėte
// teisės siųsti internetinius pranešimus.
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], { body: data["body"] })
  }
})
```

Transliuokite turinį į internetinių pranešimų kanalo egzempliorių iš kitos vietos jūsų programoje:

```ruby
# Kažkur jūsų programoje tai yra iškviesta, galbūt iš NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'Nauji dalykai!',
  body: 'Visos naujienos tinkamos spausdinimui'
)
```

`WebNotificationsChannel.broadcast_to` kvietimas deda žinutę į dabartinio užsakymo adapterio pubsub eilės po atskiru transliavimo vardu kiekvienam vartotojui. Vartotojui su ID 1, transliavimo vardas būtų `web_notifications:1`.

Kanalas buvo nurodytas transliuoti viską, kas atvyksta į `web_notifications:1` tiesiai į klientą, iškviečiant `received` atgalinį iškvietimą. Duomenys, perduodami kaip argumentas, yra maišas, išsiųstas kaip antrasis parametras į serverio pusės transliavimo iškvietimą, JSON koduotas kelionės metu per laidą ir išpakuotas kaip duomenų argumentas, atvykstantis kaip `received`.

### Išsamūs pavyzdžiai

Norėdami pamatyti, kaip nustatyti Action Cable savo „Rails“ programoje ir pridėti kanalus, žr. [rails/actioncable-examples](https://github.com/rails/actioncable-examples) saugyklą.

## Konfigūracija

Action Cable turi dvi privalomas konfigūracijas: užsakymo adapterį ir leidžiamus užklausos kilmės adresus.

### Užsakymo adapteris

Pagal numatytuosius nustatymus, Action Cable ieško konfigūracijos failo `config/cable.yml`.
Failas turi nurodyti adapterį kiekvienam „Rails“ aplinkai. Daugiau informacijos apie adapterius žr.
[S priklausomybėmis](#dependencies) skyrių.

```yaml
development:
  adapter: async

test:
  adapter: test

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### Adapterio konfigūracija

Žemiau pateikiamas prenumeratos adapterių sąrašas, skirtas galutiniams vartotojams.

##### Async Adapteris

Async adapteris skirtas plėtrai/testavimui ir neturėtų būti naudojamas gamyboje.

##### Redis Adapteris

Redis adapteriui reikia, kad vartotojai pateiktų URL, rodantį į Redis serverį.
Be to, gali būti pateiktas `channel_prefix`, kad būtų išvengta kanalo pavadinimų susidūrimo
naudojant tą patį Redis serverį keliose programose. Daugiau informacijos rasite [Redis Pub/Sub dokumentacijoje](https://redis.io/docs/manual/pubsub/#database--scoping).

Redis adapteris taip pat palaiko SSL/TLS ryšius. Reikalingi SSL/TLS parametrai gali būti perduodami konfigūracijos YAML failo `ssl_params` raktui.

```
production:
  adapter: redis
  url: rediss://10.10.3.153:tls_port
  channel_prefix: appname_production
  ssl_params: {
    ca_file: "/path/to/ca.crt"
  }
```

`ssl_params` parametrams perduodami tiesiogiai į `OpenSSL::SSL::SSLContext#set_params` metodą ir gali būti bet koks SSL konteksto galiojantis atributas.
Daugiau informacijos rasite [OpenSSL::SSL::SSLContext dokumentacijoje](https://docs.ruby-lang.org/en/master/OpenSSL/SSL/SSLContext.html) apie kitus galimus atributus.

Jei naudojate savo parengtus sertifikatus "redis adapter" už ugniasienės ir norite praleisti sertifikato tikrinimą, tada ssl `verify_mode` turėtų būti nustatytas kaip `OpenSSL::SSL::VERIFY_NONE`.

ĮSPĖJIMAS: Nerekomenduojama naudoti `VERIFY_NONE` gamyboje, nebent visiškai suprantate saugumo padarinius. Norėdami nustatyti šią parinktį "Redis adapteriui", konfigūracija turėtų būti `ssl_params: { verify_mode: <%= OpenSSL::SSL::VERIFY_NONE %> }`.

##### PostgreSQL Adapteris

PostgreSQL adapteris naudoja Active Record prisijungimo keitiklį ir todėl
programos `config/database.yml` duomenų bazės konfigūraciją, kaip savo prisijungimą.
Tai gali pasikeisti ateityje. [#27214](https://github.com/rails/rails/issues/27214)

### Leidžiami užklausos kilmės

Action Cable priima užklausas tik iš nurodytų kilmės vietų, kurios yra
perduodamos kaip masyvas į serverio konfigūraciją. Kilmės vietos gali būti
eilučių ar reguliarių išraiškų pavyzdžiai, prieš kuriuos bus tikrinama atitikties sąlyga.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

Norėdami išjungti ir leisti užklausas iš bet kurios kilmės:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

Pagal numatytuosius nustatymus, Action Cable leidžia visus užklausas iš localhost:3000, kai vyksta
plėtros aplinkoje.

### Vartotojo konfigūracija

Norėdami konfigūruoti URL, į savo HTML išdėstymo HEAD pridėkite [`action_cable_meta_tag`][] iškvietimą.
Tai naudoja URL arba kelią, kuris paprastai nustatomas per [`config.action_cable.url`][] aplinkos konfigūracijos failuose.


### Darbinio baseino konfigūracija

Darbinis baseinas naudojamas vykdyti prisijungimo atgalinių iškvietimų ir kanalo veiksmų
atitvėrimą nuo serverio pagrindinės gijos. Action Cable leidžia programai
konfigūruoti vienu metu vykdomų gijų skaičių darbinėje baseine.

```ruby
config.action_cable.worker_pool_size = 4
```

Taip pat atkreipkite dėmesį, kad jūsų serveris turi pateikti bent tiek pat duomenų bazės
prisijungimų, kiek turite darbuotojų. Numatytasis darbinio baseino dydis yra 4, todėl
tai reiškia, kad turite pateikti bent 4 duomenų bazės prisijungimus.
Tai galite pakeisti `config/database.yml` per `pool` atributą.

### Kliento pusės žurnalavimas

Kliento pusės žurnalavimas numatytasis išjungtas. Galite tai įjungti nustatydami `ActionCable.logger.enabled` reikšmę į `true`.

```ruby
import * as ActionCable from '@rails/actioncable'

ActionCable.logger.enabled = true
```

### Kitos konfigūracijos

Kitas bendras pasirinkimas, kurį galima konfigūruoti, yra žurnalo žymės, taikomos
kaskartinei prisijungimo žurnalo įrašiklio. Štai pavyzdys, naudojantis
vartotojo paskyros ID, jei jis yra prieinamas, kitu atveju "no-account" žymėjimui:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

Visų konfigūracijos parinkčių sąrašui žiūrėkite
`ActionCable::Server::Configuration` klasės dokumentacijoje.

## Paleidimas kaip atskiri kabelio serveriai

Action Cable gali veikti kaip jūsų "Rails" programos dalis arba kaip
atskiras serveris. Plėtros metu veikimas kaip jūsų "Rails" programos dalis
paprastai yra gerai, tačiau gamyboje jį turėtumėte paleisti kaip atskirą serverį.

### Programoje

Action Cable gali veikti kartu su jūsų "Rails" programa. Pavyzdžiui, norint
klausyti WebSocket užklausų adresu `/websocket`, nurodykite tą kelią
[`config.action_cable.mount_path`][]:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

Jei iškviečiama [`action_cable_meta_tag`][], galima naudoti `ActionCable.createConsumer()` prisijungti prie kabelio
serverio. Kitu atveju, pirmasis argumentas `createConsumer` yra nurodytas kelias (pvz., `ActionCable.createConsumer("/websocket")`).

Kiekvienai jūsų sukurtai serverio instancijai ir kiekvienam darbuotojui, kurį jūsų serveris
sukuria, taip pat turėsite naują Action Cable instanciją, tačiau "Redis" arba
"PostgreSQL" adapteris sinchronizuoja žinutes tarp prisijungimų.


### Atskirai

Kabelio serveriai gali būti atskirti nuo jūsų įprasto programos serverio. Tai
vis tiek yra "Rack" programa, bet tai yra savarankiška "Rack" programa. Rekomenduojamas
pagrindinis nustatymas yra šis:
```ruby
# cable/config.ru
require_relative "../config/environment"
Rails.application.eager_load!

run ActionCable.server
```

Tada, norint paleisti serverį:

```
bundle exec puma -p 28080 cable/config.ru
```

Tai paleidžia kabelio serverį 28080 prievade. Norėdami pranešti „Rails“, kad naudotų šį
serverį, atnaujinkite savo konfigūraciją:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_cable.mount_path = nil
  config.action_cable.url = "ws://localhost:28080" # naudokite wss:// produkcijoje
end
```

Galų gale, įsitikinkite, kad teisingai [sukonfigūravote vartotoją](#vartotojo-konfigūracija).

### Pastabos

WebSocket serveris neturi prieigos prie sesijos, tačiau jis turi
prieigą prie slapukų. Tai gali būti naudojama, kai reikia tvarkyti
autentifikaciją. Galite pamatyti vieną būdą tai padaryti su „Devise“ šiame [straipsnyje](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## Priklausomybės

„Action Cable“ teikia prenumeratos adapterio sąsają, skirtą apdoroti savo
pubsub vidinius. Pagal numatytuosius nustatymus yra įtraukti asinchroniniai, tiesioginiai, „PostgreSQL“ ir „Redis“
adapteriai. Naujose „Rails“ programose numatytasis adapteris
yra asinchroninis (`async`) adapteris.

Ruby pusės dalykas yra sukurtas viršuje [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) ir [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Diegimas

„Action Cable“ veikia naudojant „WebSocket“ ir gijas. Abi
pagrindinės struktūros ir vartotojo nurodytos kanalo darbo yra apdorojamos viduje
naudojant „Ruby“ natyvų gijų palaikymą. Tai reiškia, kad galite naudoti visus savo esamus
„Rails“ modelius be jokių problemų, jei nesukėlėte jokių gijų saugumo klaidų.

„Action Cable“ serveris įgyvendina „Rack“ lizdų užgrobimo API,
tai leidžia naudoti daugiausiai gijų pagrįstą modelį valdyti ryšius
viduje, nepriklausomai nuo to, ar taikomosios programos serveris turi daugiau nei vieną giją ar ne.

Atitinkamai, „Action Cable“ veikia su populiariais serveriais, tokiais kaip „Unicorn“, „Puma“ ir
„Passenger“.

## Testavimas

Detalią informaciją apie tai, kaip testuoti „Action Cable“ funkcionalumą, rasite
[testavimo vadove](testing.html#testing-action-cable).
[`ActionCable::Connection::Base`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Base.html
[`identified_by`]: https://api.rubyonrails.org/classes/ActionCable/Connection/Identification/ClassMethods.html#method-i-identified_by
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`ActionCable::Channel::Base`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html
[`broadcast`]: https://api.rubyonrails.org/classes/ActionCable/Server/Broadcasting.html#method-i-broadcast
[`broadcast_to`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Broadcasting/ClassMethods.html#method-i-broadcast_to
[`stream_for`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_for
[`stream_from`]: https://api.rubyonrails.org/classes/ActionCable/Channel/Streams.html#method-i-stream_from
[`config.action_cable.url`]: configuring.html#config-action-cable-url
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
[`config.action_cable.mount_path`]: configuring.html#config-action-cable-mount-path
[`action_cable_meta_tag`]: https://api.rubyonrails.org/classes/ActionCable/Helpers/ActionCableHelper.html#method-i-action_cable_meta_tag
