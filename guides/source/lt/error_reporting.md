**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: e904ad42aee9a68f37b4e79e0b70b685
Klaidų pranešimai „Rails“ programose
========================

Šis vadovas pristato būdus valdyti išimtis, kurios atsiranda „Ruby on Rails“ programose.

Po šio vadovo perskaitymo žinosite:

* Kaip naudoti „Rails“ klaidų pranešėją, kad užfiksuotumėte ir praneštumėte klaidas.
* Kaip kurti pasirinktinus prenumeratorius savo klaidų pranešimo paslaugai.

--------------------------------------------------------------------------------

Klaidų pranešimas
------------------------

„Rails“ [klaidų pranešėjas](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html) suteikia standartinį būdą rinkti išimtis, kurios atsiranda jūsų programoje, ir pranešti apie jas jūsų pasirinktai paslaugai ar vietai.

Klaidų pranešėjas siekia pakeisti standartinį klaidų tvarkymo kodą, panašų į šį:

```ruby
begin
  do_something
rescue SomethingIsBroken => error
  MyErrorReportingService.notify(error)
end
```

naudojant nuoseklią sąsają:

```ruby
Rails.error.handle(SomethingIsBroken) do
  do_something
end
```

„Rails“ apgaubia visus vykdymus (tokius kaip HTTP užklausos, darbai ir `rails runner` kvietimai) klaidų pranešėju, todėl bet kokios neapdorotos klaidos, iškeltos jūsų programoje, automatiškai bus pranešamos jūsų klaidų pranešimo paslaugai per jų prenumeratorius.

Tai reiškia, kad trečiųjų šalių klaidų pranešimo bibliotekoms nebėra reikalinga įterpti „Rack“ tarpinės programinės įrangos ar atlikti jokių „monkey-patching“ veiksmų, kad užfiksuotų neapdorotas išimtis. Bibliotekos, naudojančios „ActiveSupport“, taip pat gali naudoti tai, kad neintruziškai praneštų apie perspėjimus, kurie anksčiau būtų prarasti žurnale.

Naudoti „Rails“ klaidų pranešėją nėra privaloma. Visi kiti būdai užfiksuoti klaidas vis dar veikia.

### Prenumeruojant pranešėją

Norėdami naudoti klaidų pranešėją, jums reikia _prenumeratoriaus_. Prenumeratorius yra bet koks objektas su `report` metodu. Kai įvyksta klaida jūsų programoje arba jos pranešama rankiniu būdu, „Rails“ klaidų pranešėjas šį metodą iškvies su klaidos objektu ir kai kuriais parametrais.

Kai kurios klaidų pranešimo bibliotekos, pvz., [„Sentry“](https://github.com/getsentry/sentry-ruby/blob/e18ce4b6dcce2ebd37778c1e96164684a1e9ebfc/sentry-rails/lib/sentry/rails/error_subscriber.rb) ir [„Honeybadger“](https://docs.honeybadger.io/lib/ruby/integration-guides/rails-exception-tracking/), automatiškai užregistruoja prenumeratorių už jus. Daugiau informacijos rasite paslaugos teikėjo dokumentacijoje.

Taip pat galite sukurti pasirinktinį prenumeratorių. Pavyzdžiui:

```ruby
# config/initializers/error_subscriber.rb
class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    MyErrorReportingService.report_error(error, context: context, handled: handled, level: severity)
  end
end
```

Apibrėžus prenumeratoriaus klasę, užregistruokite ją, iškviesdami [`Rails.error.subscribe`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-subscribe) metodą:

```ruby
Rails.error.subscribe(ErrorSubscriber.new)
```

Galite užregistruoti tiek prenumeratorių, kiek norite. „Rails“ juos iškvies po vieną, pagal registravimo tvarką.

PASTABA: „Rails“ klaidų pranešėjas visada iškvies užregistruotus prenumeratorius, nepriklausomai nuo jūsų aplinkos. Tačiau daugelis klaidų pranešimo paslaugų pagal numatytuosius nustatymus praneša tik apie klaidas, kurios atsiranda gamyboje. Jei reikia, turėtumėte sukonfigūruoti ir išbandyti savo aplinką.

### Naudoti klaidų pranešėją

Yra trys būdai, kaip galite naudoti klaidų pranešėją:

#### Pranešti ir nutylėti klaidas

[`Rails.error.handle`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-handle) praneš apie bet kokią klaidą, kuri iškyla bloke. Tada ji **nutylės** klaidą, ir jūsų kodo likusi dalis už bloko tęsis kaip įprasta.

```ruby
result = Rails.error.handle do
  1 + '1' # iškelia TypeError
end
result # => nil
1 + 1 # Šis bus įvykdytas
```

Jei bloke nekeliamos jokios klaidos, `Rails.error.handle` grąžins bloko rezultatą, kitu atveju grąžins `nil`. Galite pakeisti tai nurodydami „fallback“:

```ruby
user = Rails.error.handle(fallback: -> { User.anonymous }) do
  User.find_by(params[:id])
end
```

#### Pranešti ir pakartotinai iškelti klaidas

[`Rails.error.record`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-record) praneša apie klaidas visiems užregistruotiems prenumeratoriams ir tada pakartotinai iškelia klaidą, tai reiškia, kad jūsų kodo likusi dalis nebus vykdoma.

```ruby
Rails.error.record do
  1 + '1' # iškelia TypeError
end
1 + 1 # Šis nebus įvykdytas
```

Jei bloke nekeliamos jokios klaidos, `Rails.error.record` grąžins bloko rezultatą.

#### Rankiniu būdu pranešti apie klaidas

Taip pat galite rankiniu būdu pranešti apie klaidas, iškviesdami [`Rails.error.report`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-report):

```ruby
begin
  # kodas
rescue StandardError => e
  Rails.error.report(e)
end
```

Visi perduodami parametrai bus perduoti klaidų prenumeratoriams.

### Klaidų pranešimo parinktys

Visi 3 pranešimo API (`#handle`, `#record` ir `#report`) palaiko šias parinktis, kurios tada perduodamos visiems užregistruotiems prenumeratoriams:

- `handled`: `Boolean`, nurodantis, ar klaida buvo apdorota. Pagal numatytuosius nustatymus tai nustatoma kaip `true`. `#record` nustato tai kaip `false`.
- `severity`: `Symbol`, apibūdinantis klaidos sunkumą. Tikimasi, kad reikšmės bus: `:error`, `:warning` ir `:info`. `#handle` nustato tai kaip `:warning`, o `#record` nustato tai kaip `:error`.
- `context`: `Hash`, suteikiantis daugiau konteksto apie klaidą, pvz., užklausos ar naudotojo informaciją
- `source`: `String`, apie klaidos šaltinį. Numatytasis šaltinis yra „application“. Vidinės bibliotekos pranešamos klaidos gali nustatyti kitus šaltinius; pvz., „Redis“ kešo biblioteka gali naudoti „redis_cache_store.active_support“. Jūsų prenumeratorius gali naudoti šaltinį, kad ignoruotų klaidas, kurios jums nėra įdomios.
```ruby
Rails.error.handle(context: { user_id: user.id }, severity: :info) do
  # ...
end
```

### Klaidų filtravimas pagal klasių

Naudojant `Rails.error.handle` ir `Rails.error.record`, taip pat galite pasirinkti pranešti tik apie tam tikrų klasių klaidas. Pavyzdžiui:

```ruby
Rails.error.handle(IOError) do
  1 + '1' # iškelia TypeError klaidą
end
1 + 1 # TypeErrors nėra IOError, todėl šis kodas *nebus* vykdomas
```

Čia `TypeError` nebus užfiksuotas Rails klaidų pranešėju. Tik `IOError` klasės ir jos palikuonys bus pranešami. Kitos klaidos bus iškeliamos kaip įprasta.

### Konteksto nustatymas globaliai

Be konteksto nustatymo per `context` parinktį, galite naudoti [`#set_context`](https://api.rubyonrails.org/classes/ActiveSupport/ErrorReporter.html#method-i-set_context) API. Pavyzdžiui:

```ruby
Rails.error.set_context(section: "checkout", user_id: @user.id)
```

Bet koks šiuo būdu nustatytas kontekstas bus sujungtas su `context` parinktimi

```ruby
Rails.error.set_context(a: 1)
Rails.error.handle(context: { b: 2 }) { raise }
# Pranešamas kontekstas bus: {:a=>1, :b=>2}
Rails.error.handle(context: { b: 3 }) { raise }
# Pranešamas kontekstas bus: {:a=>1, :b=>3}
```

### Bibliotekoms

Klaidų pranešimo bibliotekos gali užsiregistruoti savo prenumeratorius `Railtie`:

```ruby
module MySdk
  class Railtie < ::Rails::Railtie
    initializer "my_sdk.error_subscribe" do
      Rails.error.subscribe(MyErrorSubscriber.new)
    end
  end
end
```

Jei užregistruojate klaidų prenumeratorių, bet vis dar turite kitus klaidų mechanizmus, pvz., Rack middleware, gali atsitikti, kad klaidos bus pranešamos kelis kartus. Turėtumėte pašalinti kitus mechanizmus arba pritaikyti pranešimo funkcionalumą taip, kad jis praleistų klaidą, kurią jau matė.
