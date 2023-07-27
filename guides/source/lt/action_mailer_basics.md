**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 390d20a8bee6232c0ffa7faeb0e9d8e8
Veiksmų siuntimo pagrindai
====================

Šis vadovas suteikia jums viską, ko reikia pradėti siųsti
el. laiškus iš savo programos ir daugelį Action
Mailer vidinių dalykų. Jame taip pat aprašoma, kaip testuoti savo laiškų siuntėjus.

Perskaitę šį vadovą, žinosite:

* Kaip siųsti el. laiškus iš „Rails“ programos.
* Kaip sukurti ir redaguoti „Action Mailer“ klasę ir laiškų siuntėjo rodinį.
* Kaip konfigūruoti „Action Mailer“ savo aplinkai.
* Kaip testuoti savo „Action Mailer“ klases.

--------------------------------------------------------------------------------

Kas yra „Action Mailer“?
----------------------

„Action Mailer“ leidžia siųsti el. laiškus iš savo programos naudojant laiškų siuntėjų klases
ir rodinius.

### Laiškų siuntėjai panašūs į valdiklius

Jie paveldi iš [`ActionMailer::Base`][] ir yra „app/mailers“ kataloge.
Laiškų siuntėjai taip pat veikia labai panašiai kaip valdikliai. Kai kurie panašumų pavyzdžiai yra išvardyti žemiau. Laiškų siuntėjai turi:

* Veiksmus ir taip pat susijusius rodinius, kurie atsiranda „app/views“ kataloge.
* Rodiniuose pasiekiamus objekto kintamuosius.
* Galimybę naudoti išdėstymus ir dalinius rodinius.
* Galimybę pasiekti parametrų maišą.


El. laiškų siuntimas
--------------

Šiame skyriuje pateikiamas palaipsniui vadovas, kaip sukurti laiškų siuntėją ir jo
rodinius.

### Peržiūrėkite, kaip generuoti laiškų siuntėją

#### Sukurkite laiškų siuntėją

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Kaip matote, galite generuoti laiškų siuntėjus taip pat, kaip naudojate kitus generatorius su
„Rails“.

Jei nenorėjote naudoti generatoriaus, galėjote sukurti savo failą „app/mailers“ kataloge,
tik įsitikinkite, kad jis paveldi iš „ActionMailer::Base“:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Redaguokite laiškų siuntėją

Laiškų siuntėjai turi „veiksmus“, ir jie naudoja rodinius, kad struktūrizuotų savo turinį.
Kai valdiklis generuoja turinį, pvz., HTML, kurį siunčia klientui, laiškų siuntėjas
sukuria pranešimą, kuris bus išsiųstas el. paštu.

„app/mailers/user_mailer.rb“ yra tuščias laiškų siuntėjas:

```ruby
class UserMailer < ApplicationMailer
end
```

Pridėkime metodą, vadinamą „welcome_email“, kuris išsiųs el. laišką naudotojo
registruotam el. pašto adresui:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
```

Čia pateikiamas greitas paaiškinimas apie pateiktus metodo elementus. Visiems galimiems parametrams išsamų sąrašą žr. toliau esančiame
Visas „Action Mailer“ vartotojo nustatomus atributus sąrašas skyriuje.

* [`default`][] metodas nustato numatytąsias reikšmes visiems išsiųstiems laiškams iš
  šio laiškų siuntėjo. Šiuo atveju jį naudojame, kad nustatytume „:from“ antraštės reikšmę visiems
  šios klasės pranešimams. Tai galima pakeisti kiekvienam laiškui atskirai.
* [`mail`][] metodas sukuria faktinį el. pašto pranešimą. Jį naudojame, kad nurodytume
  antraštės reikšmes, pvz., „:to“ ir „:subject“, kiekvienam laiškui.


#### Sukurkite laiškų siuntėjo rodinį

Sukurkite failą, vadinamą „welcome_email.html.erb“, „app/views/user_mailer/“ kataloge.
Tai bus šablono naudojamas el. laiškui, suformatuotam HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Sveiki atvykę į example.com, <%= @user.name %></h1>
    <p>
      Jūs sėkmingai užsiregistravote example.com,
      jūsų prisijungimo vardas yra: <%= @user.login %>.<br>
    </p>
    <p>
      Norėdami prisijungti prie svetainės, tiesiog sekite šią nuorodą: <%= @url %>.
    </p>
    <p>Ačiū, kad prisijungėte ir geros dienos!</p>
  </body>
</html>
```

Taip pat padarykime tekstą šiam el. laiškui. Ne visi klientai mėgsta HTML laiškus,
todėl geriausia praktika yra juos siųsti abu. Norėdami tai padaryti, sukūrę failą, vadinamą
„welcome_email.text.erb“, „app/views/user_mailer/“ kataloge:

```erb
Sveiki atvykę į example.com, <%= @user.name %>
===============================================

Jūs sėkmingai užsiregistravote example.com,
jūsų prisijungimo vardas yra: <%= @user.login %>.

Norėdami prisijungti prie svetainės, tiesiog sekite šią nuorodą: <%= @url %>.

Ačiū, kad prisijungėte ir geros dienos!
```
Kai dabar iškviečiate `mail` metodą, Action Mailer automatiškai aptiks dvi šablonus (tekstą ir HTML) ir automatiškai sugeneruos `multipart/alternative` el. laišką.

#### Skambinant Mailer

Maileriai yra tik dar vienas būdas atvaizduoti rodinį. Vietoje rodinio atvaizdavimo ir jo siuntimo per HTTP protokolą, jie siunčiami per el. pašto protokolus. Dėl to, turi prasmę, kad jūsų valdiklis pasakytų Maileriui išsiųsti el. laišką, kai naudotojas sėkmingai sukuriamas.

Tai nustatyti yra paprasta.

Pirma, sukūkime `User` skeletą:

```bash
$ bin/rails generate scaffold user name email login
$ bin/rails db:migrate
```

Dabar, kai turime naudotojo modelį, su juo galime žaisti, redaguosime `app/controllers/users_controller.rb` failą, kad jis nurodytų `UserMailer` išsiųsti el. laišką naujai sukurtam naudotojui, redaguodami sukūrimo veiksmą ir įterpdami `UserMailer.with(user: @user).welcome_email` iškvietimą tuoj po to, kai naudotojas sėkmingai išsaugotas.

El. laišką įtrauksime į siuntimą naudodami [`deliver_later`][], kuris yra pagrįstas Active Job. Taip valdiklio veiksmas gali tęstis, nesijaučiant laukiant siuntimo užbaigimo.

```ruby
class UsersController < ApplicationController
  # ...

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Pasakykite UserMailer, kad išsiųstų pasveikinimo el. laišką po išsaugojimo
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'Naudotojas sėkmingai sukurtas.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ...
end
```

PASTABA: Active Job numatytasis veikimas yra vykdyti darbus naudojant `:async` adapterį.
Taigi, galite naudoti `deliver_later` siųsti el. laiškus asinchroniškai.
Active Job numatytasis adapteris vykdo darbus naudojant vidinį gijų rinkinį.
Tai gerai tinka vystymo/testavimo aplinkoms, nes nereikia jokios išorinės infrastruktūros, tačiau tai nėra tinkama gamybai, nes paleidus jis praranda laukiančius darbus.
Jei jums reikia nuolatinės pagrindo, turėsite naudoti Active Job adapterį, turintį nuolatinį pagrindą (Sidekiq, Resque ir kt.).

Jei norite išsiųsti el. laiškus iš karto (pvz., iš cronjob), tiesiog iškvieskite [`deliver_now`][]:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

Bet koks raktas-reikšmės pora, perduota [`with`][], tiesiog tampa parametrais mailerio veiksmui.
Taigi, `with(user: @user, account: @user.account)` leidžia naudoti `params[:user]` ir `params[:account]` mailerio veiksme. Kaip ir valdikliai turi parametrus.

Metodas `welcome_email` grąžina [`ActionMailer::MessageDelivery`][] objektą, kuriam galima pasakyti `deliver_now` arba `deliver_later`, kad jis išsiųstų save. `ActionMailer::MessageDelivery` objektas yra apvalkalas aplink [`Mail::Message`][]. Jei norite peržiūrėti, keisti ar atlikti kitas veiksmus su `Mail::Message` objektu, galite pasiekti jį naudodami [`message`][] metodą `ActionMailer::MessageDelivery` objekte.


### Automatinis kodavimo antraštės reikšmių kodavimas

Action Mailer tvarko daugiabaites simbolius antraštėse ir kūnuose.

Dėl sudėtingesnių pavyzdžių, pvz., alternatyvių simbolių rinkinių apibrėžimo ar savarankiško kodavimo teksto pirmiausia, žiūrėkite
[Mail](https://github.com/mikel/mail) biblioteką.

### Visi Action Mailer metodai

Yra tik trys metodai, kuriuos reikia naudoti beveik bet kokiam el. laiško pranešimui:

* [`headers`][] - Nurodo norimą bet kokį antraštės lauką el. laiške. Galite perduoti raktų ir reikšmių porų maišą arba galite iškviesti `headers[:lauko_pavadinimas] = 'reikšmė'`.
* [`attachments`][] - Leidžia pridėti priedus prie el. laiško. Pavyzdžiui, `attachments['failo-pavadinimas.jpg'] = File.read('failo-pavadinimas.jpg')`.
* [`mail`][] - Sukuria patį el. laišką. Galite perduoti antraštės maišą kaip parametrą `mail` metodui. `mail` sukurs el. laišką - arba paprastą tekstą, arba daugialypį - priklausomai nuo to, kokius el. laiško šablonus apibrėžėte.
#### Pridedant priedus

Action Mailer labai paprasta pridėti priedus.

* Pateikite failo pavadinimą ir turinį Action Mailer ir
  [Mail gem](https://github.com/mikel/mail) automatiškai atspės
  `mime_type`, nustatys `encoding` ir sukurs priedą.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  Kai bus iškviečiamas `mail` metodas, bus išsiųsta daugialypė el. laiško kopija su
  priedu, tinkamai įdėta į `multipart/mixed` ir
  pirmoji dalis bus `multipart/alternative`, kurioje bus paprastojo teksto ir
  HTML el. laiško žinutės.

PASTABA: Mail automatiškai Base64 koduoja priedą. Jei norite kažko kito,
užkoduokite savo turinį ir perduokite užkoduotą turinį ir kodavimą
`Hash` pavidalu `attachments` metode.

* Pateikite failo pavadinimą, nurodykite antraštės ir turinio parametrus ir Action Mailer ir Mail
  naudos perduotus nustatymus.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

PASTABA: Jei nurodote kodavimą, Mail priims, kad jūsų turinys jau yra
užkoduotas ir nebandys jį Base64 koduoti.

#### Kuriant vidinius priedus

Action Mailer 3.0 padarė vidinių priedų kūrimą, kuris anksčiau reikalavo daugybės trikdymų, daug paprastesnį ir trivialų, kaip jie ir turėtų būti.

* Pirmiausia, norint pranešti Mail, kad priedą reikia paversti vidiniu priedu, tiesiog iškviečiame `#inline` metodą `attachments` metode savo Mailer klasėje:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Tada savo rodinyje galite tiesiog naudoti `attachments` kaip hash'ą ir nurodyti,
  kurį priedą norite rodyti, iškviesdami `url` metodą ir perduodami
  rezultatą į `image_tag` metodą:

    ```html+erb
    <p>Sveiki, tai mūsų paveikslėlis</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Kadangi tai yra standartinis `image_tag` kvietimas, galite perduoti pasirinktinių parametrų hash'ą
  po priedo URL, kaip ir bet kuriam kitam paveikslėliui:

    ```html+erb
    <p>Sveiki, tai mūsų paveikslėlis</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'Mano nuotrauka', class: 'nuotraukos' %>
    ```

#### El. laiško siuntimas keliems gavėjams

Galima vienu el. laišku siųsti vienam ar keliems gavėjams (pvz., pranešant visiems administratoriams apie naują registraciją), nustatant el. pašto adresų sąrašą `:to` raktiniu žodžiu. El. pašto adresų sąrašas gali būti masyvas arba vienas eilutės tekstas su adresais, atskirtais kableliais.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "Naujas vartotojo registravimas: #{@user.email}")
  end
end
```

Tą patį formatą galima naudoti nustatant kopijos (Cc:) ir slepiamosios kopijos
(Bcc:) gavėjus, naudojant atitinkamai `:cc` ir `:bcc` raktinius žodžius.

#### El. laiško siuntimas su vardu

Kartais norite rodyti asmens vardą, o ne tik jo el. pašto adresą, kai jis gauna el. laišką. Tam galite naudoti [`email_address_with_name`][]:

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(@user.email, @user.name),
    subject: 'Sveiki atvykę į mano nuostabų tinklalapį'
  )
end
```

Tokia pati technika veikia ir nurodant siuntėjo vardą:

```ruby
class UserMailer < ApplicationMailer
  default from: email_address_with_name('notification@example.com', 'Pavyzdžio Įmonės Pranešimai')
end
```

Jei vardas yra tuščias eilutė, grąžinamas tik adresas.


### Mailer rodiniai

Mailer rodiniai yra `app/views/name_of_mailer_class` kataloge.
Konkrečiam mailer rodiniui klasė žinoma, nes jo pavadinimas yra toks pat
kaip mailer metodo pavadinimas. Mūsų pavyzdyje iš viršaus, mūsų mailer rodinys
`welcome_email` metodui bus `app/views/user_mailer/welcome_email.html.erb`
HTML versijai ir `welcome_email.text.erb` paprastojo teksto versijai.

Norint pakeisti numatytąjį mailer rodinį savo veiksmui, galite tai padaryti taip:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Sveiki atvykę į mano nuostabų tinklalapį',
         template_path: 'notifications',
         template_name: 'kitas')
  end
end
```
Šiuo atveju, jis ieškos šablonų `app/views/notifications` su pavadinimu `another`. Taip pat galite nurodyti `template_path` masyvą, ir jie bus ieškomi tvarka.

Jei norite daugiau lankstumo, taip pat galite perduoti bloką ir atvaizduoti konkretų šabloną ar net atvaizduoti tiesioginį ar tekstą, nenaudodami šablonų failo:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Render text' }
    end
  end
end
```

Tai atvaizduos šabloną 'another_template.html.erb' HTML daliai ir naudos atvaizduotą tekstą tekstinei daliai. Atvaizdavimo komanda yra ta pati, kuri naudojama veiksmų valdiklyje, todėl galite naudoti visas tas pačias parinktis, pvz., `:text`, `:inline`, ir tt.

Jei norite atvaizduoti šabloną, esantį už numatytosios `app/views/mailer_name/` direktorijos ribų, galite naudoti [`prepend_view_path`][] taip:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # Tai bandys įkelti "custom/path/to/mailer/view/welcome_email" šabloną
  def welcome_email
    # ...
  end
end
```

Taip pat galite apsvarstyti [`append_view_path`][] metodo naudojimą.


#### Pašto siuntimo peržiūros

Galite atlikti fragmentų talpinimą pašto siuntimo peržiūros kaip ir taikomosios peržiūros, naudodami [`cache`][] metodą.

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

Norint naudoti šią funkciją, turite sukonfigūruoti savo programą taip:

```ruby
config.action_mailer.perform_caching = true
```

Fragmentų talpinimas taip pat palaikomas daugialypėse elektroninio pašto žinutėse.
Daugiau informacijos apie talpinimą galite rasti [Rails talpinimo vadove](caching_with_rails.html).


### Veiksmų pašto išdėstymas

Kaip ir valdiklio rodiniai, taip pat galite turėti pašto išdėstymus. Išdėstymo pavadinimas
turi būti toks pat kaip ir jūsų pašto siuntėjas, pvz., `user_mailer.html.erb` ir
`user_mailer.text.erb`, kad jie būtų automatiškai pripažinti kaip išdėstymas.

Norėdami naudoti kitą failą, iškvieskite [`layout`][] savo pašto siuntėjui:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # naudokite awesome.(html|text).erb kaip išdėstymą
end
```

Kaip ir su valdiklio rodiniais, naudokite `yield`, kad atvaizduotumėte rodinį viduje
išdėstymo.

Taip pat galite perduoti `layout: 'layout_name'` parinktį į render komandą viduje
formato bloko, kad nurodytumėte skirtingus išdėstymus skirtingiems formatams:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Tai atvaizduos HTML dalį naudojant `my_layout.html.erb` failą ir tekstą
su įprastiniu `user_mailer.text.erb` failu, jei jis egzistuoja.


### Pašto siuntimo peržiūra

Veiksmų pašto peržiūros suteikia galimybę peržiūrėti, kaip atrodo elektroninės pašto žinutės, apsilankant
specialioje URL, kuri jas atvaizduoja. Pirmiau pateiktoje pavyzdžio, pašto siuntėjo peržiūros klasė
`UserMailer` turėtų būti pavadinta `UserMailerPreview` ir ji turėtų būti rasta
`test/mailers/previews/user_mailer_preview.rb`. Norėdami pamatyti `welcome_email` peržiūrą, įgyvendinkite metodą, turintį tą pačią pavadinimą ir iškvieskite
`UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Tada peržiūra bus prieinama adresu <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Jei pakeisite kažką `app/views/user_mailer/welcome_email.html.erb`
arba patį pašto siuntėją, jis automatiškai bus perkrautas ir atvaizduotas, kad galėtumėte
vizualiai pamatyti naują stilių iš karto. Peržiūros sąrašas taip pat yra prieinamas
adresu <http://localhost:3000/rails/mailers>.

Pagal numatytuosius nustatymus, šios peržiūros klasės yra `test/mailers/previews`.
Tai galima konfigūruoti naudojant `preview_paths` parinktį. Pavyzdžiui, jei
norite pridėti `lib/mailer_previews`, galite tai sukonfigūruoti
`config/application.rb`:

```ruby
config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
```

### Nuorodų generavimas veiksmų pašto rodiniuose

Skirtingai nuo valdiklių, pašto siuntimo objektas neturi jokios informacijos apie
įeinančią užklausą, todėl turėsite patys nurodyti `:host` parametrą.

Kadangi `:host` paprastai yra nuoseklus visoje programoje, galite jį konfigūruoti
globaliai `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```
Dėl šios el. laiškų elgsenos negalite naudoti jokių `*_path` pagalbininkų. Vietoj to, turėsite naudoti susijusį `*_url` pagalbininką. Pavyzdžiui, vietoj to, kad naudotumėte

```html+erb
<%= link_to 'welcome', welcome_path %>
```

Turėsite naudoti:

```html+erb
<%= link_to 'welcome', welcome_url %>
```

Naudodami visą URL, jūsų nuorodos dabar veiks jūsų el. laiškuose.

#### Generuojant URL su `url_for`

[`url_for`][] pagal numatymą generuoja visą URL šablonuose.

Jei nesukonfigūravote `:host` parinkties globaliai, įsitikinkite, kad ją perduodate
`url_for`.

```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```


#### Generuojant URL su pavadinimais maršrutais

El. pašto klientai neturi interneto konteksto, todėl maršrutai neturi pagrindinio URL, iš kurio būtų galima sudaryti visus interneto adresus. Todėl visada turėtumėte naudoti pavadinimų maršrutų pagalbinių funkcijų `*_url` variantą.

Jei nesukonfigūravote `:host` parinkties globaliai, įsitikinkite, kad ją perduodate
URL pagalbiniui.

```erb
<%= user_url(@user, host: 'example.com') %>
```

PASTABA: ne-`GET` nuorodos reikalauja [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) arba
[jQuery UJS](https://github.com/rails/jquery-ujs) ir neveiks el. pašto šablonuose.
Jos rezultatas bus įprasti `GET` užklausos.

### Paveikslėlių pridėjimas veiksmų laiškų rodiniuose

Skirtingai nei valdikliai, laiško egzempliorius neturi jokios informacijos apie
įeinančią užklausą, todėl turėsite pateikti `:asset_host` parametrą patys.

Kadangi `:asset_host` paprastai yra nuoseklus visoje programoje, galite
konfigūruoti jį globaliai `config/application.rb`:

```ruby
config.asset_host = 'http://example.com'
```

Dabar galite rodyti paveikslėlį savo el. laiške.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Siunčiant daugialypius laiškus

Action Mailer automatiškai siųs daugialypius laiškus, jei turite skirtingus
šablonus tam pačiam veiksmui. Taigi, mūsų `UserMailer` pavyzdžiui, jei turite
`welcome_email.text.erb` ir `welcome_email.html.erb` faile
`app/views/user_mailer`, Action Mailer automatiškai siųs daugialypį laišką
su HTML ir teksto versijomis, kurios bus nustatytos kaip skirtingi dalys.

Dalių įterpimo tvarka nustatoma pagal `:parts_order`
`ActionMailer::Base.default` metode.

### Siunčiant laiškus su dinaminėmis pristatymo parinktimis

Jei norite pakeisti numatytąsias pristatymo parinktis (pvz., SMTP prisijungimo duomenis)
siunčiant laiškus, tai galite padaryti naudodami `delivery_method_options` laiško veiksmui.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### Siunčiant laiškus be šablonų rodymo

Gali būti atvejų, kai norite praleisti šablonų rodymo žingsnį ir
pateikti laiško kūną kaip eilutę. Tai galite padaryti naudodami `:body`
parinktį. Tokiais atvejais nepamirškite pridėti `:content_type` parinkties. Rails
numatytai naudos `text/plain`, jei jos nenurodysite.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Action Mailer atgaliniai iškvietimai
-----------------------

Action Mailer leidžia nurodyti [`before_action`][], [`after_action`][] ir
[`around_action`][] konfigūruoti pranešimą, ir [`before_deliver`][], [`after_deliver`][] ir
[`around_deliver`][] valdyti pristatymą.

* Atgaliniai iškvietimai gali būti nurodyti naudojant bloką arba simbolį, rodantį metodą laiškų
  klasėje, panašiai kaip valdikliuose.

* Galite naudoti `before_action` norėdami nustatyti egzemplioriaus kintamuosius, užpildyti laiško
  objektą numatytosiomis reikšmėmis arba įterpti numatytus antraštės ir priedų failus.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private
    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```
* Jūs galite naudoti `after_action` norėdami atlikti panašų nustatymą kaip ir `before_action`, tačiau naudojant objekto kintamuosius, nustatytus jūsų pašto siuntimo veiksmuose.

* Naudojant `after_action` atgalinį iškvietimą, taip pat galite pakeisti siuntimo metodo nustatymus, atnaujindami `mail.delivery_method.settings`.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private
    def set_delivery_options
      # Čia turite prieigą prie pašto objekto,
      # @business ir @user objektinių kintamųjų
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Jūs galite naudoti `after_delivery` norėdami užregistruoti žinutės pristatymą.

* Pašto siuntimo veiksmų atgaliniai iškvietimai nutraukia tolesnę apdorojimą, jei kūnas nustatytas į ne-nil reikšmę. `before_deliver` gali nutraukti su `throw :abort`.

Naudodami Action Mailer pagalbininkus
-------------------------------------

Action Mailer paveldi iš `AbstractController`, todėl turite prieigą prie daugumos tų pačių pagalbinių funkcijų, kaip ir Action Controller.

Taip pat yra keletas Action Mailer specifinių pagalbinių metodų, prieinamų [`ActionMailer::MailHelper`][] klasėje. Pavyzdžiui, jie leidžia pasiekti pašto siuntimo objektą iš jūsų vaizdoje naudojant [`mailer`][MailHelper#mailer] ir pasiekti žinutę kaip [`message`][MailHelper#message]:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```

Action Mailer konfigūracija
---------------------------

Šios konfigūracijos parinktys geriausiai nustatomos viename iš aplinkos failų (environment.rb, production.rb ir t.t.)

| Konfigūracija | Aprašymas |
|---------------|-------------|
|`logger`|Generuoja informaciją apie pašto siuntimo procesą, jei tai įmanoma. Gali būti nustatyta į `nil`, jei norite išjungti žurnalizavimą. Suderinama su Ruby `Logger` ir `Log4r` žurnalizatoriais.|
|`smtp_settings`|Leidžia išsamiai konfigūruoti `:smtp` siuntimo metodo nustatymus:<ul><li>`:address` - Leidžia naudoti nuotolinį pašto serverį. Tiesiog pakeiskite jį nuo numatytosios `"localhost"` reikšmės.</li><li>`:port` - Jei jūsų pašto serveris neveikia 25-oje prievado, galite tai pakeisti.</li><li>`:domain` - Jei reikia nurodyti HELO domeną, galite tai padaryti čia.</li><li>`:user_name` - Jei jūsų pašto serveris reikalauja autentifikacijos, nustatykite vartotojo vardą šiuose nustatymuose.</li><li>`:password` - Jei jūsų pašto serveris reikalauja autentifikacijos, nustatykite slaptažodį šiuose nustatymuose.</li><li>`:authentication` - Jei jūsų pašto serveris reikalauja autentifikacijos, čia turite nurodyti autentifikacijos tipą. Tai yra simbolis ir vienas iš `:plain` (siųs slaptažodį aiškiai), `:login` (siųs slaptažodį Base64 koduotu) arba `:cram_md5` (sujungia iššūkio/atsakymo mechanizmą, kad būtų mainama informacija, ir kriptografinį žinutės maišos algoritmą).</li><li>`:enable_starttls` - Naudoti STARTTLS, kai jungiamasi prie SMTP serverio ir nepavyksta, jei nepalaikoma. Numatytoji reikšmė yra `false`.</li><li>`:enable_starttls_auto` - Aptinka, ar jūsų SMTP serveris palaiko STARTTLS ir pradeda jį naudoti. Numatytoji reikšmė yra `true`.</li><li>`:openssl_verify_mode` - Naudojant TLS, galite nustatyti, kaip OpenSSL patikrina sertifikatą. Tai yra labai naudinga, jei reikia patvirtinti savarankiškai pasirašytą ir/arba universalų sertifikatą. Galite naudoti OpenSSL patikrinimo konstantos pavadinimą ('none' arba 'peer') arba tiesiogiai konstantą (`OpenSSL::SSL::VERIFY_NONE` arba `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Leidžia SMTP ryšiui naudoti SMTP/TLS (SMTPS: SMTP per tiesioginį TLS ryšį)</li><li>`:open_timeout` - Sekundžių skaičius, laukiant jungiantis prie ryšio.</li><li>`:read_timeout` - Sekundžių skaičius, laukiant, kol vyks laiko limitas skaitymo(2) iškvietimui.</li></ul>|
|`sendmail_settings`|Leidžia pakeisti nustatymus `:sendmail` siuntimo metodui.<ul><li>`:location` - sendmail vykdomojo failo vieta. Numatytoji reikšmė yra `/usr/sbin/sendmail`.</li><li>`:arguments` - sendmail perduodami komandų eilutės argumentai. Numatytoji reikšmė yra `["-i"]`.</li></ul>|
|`raise_delivery_errors`|Nurodo, ar klaidos turėtų būti iškeltos, jei paštas nepavyksta pristatyti. Tai veikia tik tada, jei išorinis pašto serveris sukonfigūruotas nedelsiant pristatyti. Numatytoji reikšmė yra `true`.|
|`delivery_method`|Apibrėžia siuntimo metodą. Galimos reikšmės:<ul><li>`:smtp` (numatytoji), gali būti konfigūruojama naudojant [`config.action_mailer.smtp_settings`][].</li><li>`:sendmail`, gali būti konfigūruojama naudojant [`config.action_mailer.sendmail_settings`][].</li><li>`:file`: išsaugoti laiškus į failus; gali būti konfigūruojama naudojant `config.action_mailer.file_settings`.</li><li>`:test`: išsaugoti laiškus į `ActionMailer::Base.deliveries` masyvą.</li></ul>Daugiau informacijos rasite [API dokumentacijoje](https://api.rubyonrails.org/classes/ActionMailer/Base.html).|
|`perform_deliveries`|Nustato, ar pristatymai iš tikrųjų vykdomi, kai `deliver` metodas yra iškviestas pašto žinutei. Numatytoji reikšmė yra `true`, bet tai gali būti išjungta, norint padėti funkciniams testams. Jei ši reikšmė yra `false`, `deliveries` masyvas nebus užpildytas, net jei `delivery_method` yra `:test`.|
|`deliveries`|Laiko visus per Action Mailer išsiųstus laiškus su `:test` siuntimo metodu. Labiausiai naudinga vienetų ir funkciniams testams.|
|`delivery_job`|Darbo klasė, naudojama su `deliver_later`. Numatytoji reikšmė yra `ActionMailer::MailDeliveryJob`.|
|`deliver_later_queue_name`|Eilės pavadinimas, naudojamas su numatytojo `delivery_job`. Numatytoji reikšmė yra numatytoji Active Job eilė.|
|`default_options`|Leidžia nustatyti numatytąsias reikšmes `mail` metodo parinktims (`:from`, `:reply_to` ir t.t.).|
Norint gauti išsamią konfigūracijos aprašą, žiūrėkite [Konfigūruojant Action Mailer](configuring.html#configuring-action-mailer) mūsų Configuring Rails Applications vadove.


### Pavyzdinė Action Mailer konfigūracija

Pavyzdys būtų pridėti šį kodą į tinkamą `config/environments/$RAILS_ENV.rb` failą:

```ruby
config.action_mailer.delivery_method = :sendmail
# Numatytasis:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: %w[ -i ]
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = { from: 'no-reply@example.com' }
```

### Action Mailer konfigūracija naudojant Gmail

Action Mailer naudoja [Mail gemą](https://github.com/mikel/mail) ir priima panašią konfigūraciją. Norint siųsti per Gmail, pridėkite šį kodą į `config/environments/$RAILS_ENV.rb` failą:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:         'smtp.gmail.com',
  port:            587,
  domain:          'example.com',
  user_name:       '<username>',
  password:        '<password>',
  authentication:  'plain',
  enable_starttls: true,
  open_timeout:    5,
  read_timeout:    5 }
```

Jei naudojate seną Mail gemą (2.6.x arba ankstesnę versiją), vietoj `enable_starttls` naudokite `enable_starttls_auto`.

Pastaba: „Google“ [blokuoja prisijungimus](https://support.google.com/accounts/answer/6010255) iš programų, kurias laiko mažiau saugiomis. Galite pakeisti savo „Gmail“ nustatymus [čia](https://www.google.com/settings/security/lesssecureapps), kad leistumėte bandymus. Jei jūsų „Gmail“ paskyra turi įjungtą dviejų veiksnių autentifikaciją, tuomet turėsite nustatyti [programos slaptažodį](https://myaccount.google.com/apppasswords) ir naudoti jį vietoj įprasto slaptažodžio.

Pašto siuntimo bandomasis testavimas
--------------

Detalius nurodymus, kaip testuoti savo pašto siuntėjus, rasite [testavimo vadove](testing.html#testing-your-mailers).

El. laiškų peržiūra ir stebėjimas
-------------------

Action Mailer teikia priėjimą prie el. laiško stebėtojo ir peržiūros metodų. Tai leidžia registruoti klases, kurios yra iškviečiamos kiekvieno išsiųsto el. laiško siuntimo gyvavimo ciklo metu.

### El. laiškų peržiūra

Peržiūros leidžia jums keisti el. laiškus prieš juos perduodant pristatymo agentams. Peržiūros klasė turi įgyvendinti `::delivering_email(message)` metodą, kuris bus iškviestas prieš el. laiško siuntimą.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Prieš peržiūros klasė galėtų atlikti savo darbą, ją reikia užregistruoti, naudojant `interceptors` konfigūracijos parinktį. Tai galite padaryti inicializavimo faile, pvz., `config/initializers/mail_interceptors.rb`:

```ruby
Rails.application.configure do
  if Rails.env.staging?
    config.action_mailer.interceptors = %w[SandboxEmailInterceptor]
  end
end
```

Pastaba: Pavyzdyje aukščiau naudojamas vartotojo aplinka, vadinama „staging“, kuri yra panaši į produkcijos serverį, tačiau skirta testavimo tikslams. Daugiau informacijos apie vartotojo aplinkas galite rasti [kuriant Rails aplinkas](configuring.html#creating-rails-environments).

### El. laiškų stebėjimas

Stebėtojai suteikia prieigą prie el. laiško žinutės po jos išsiuntimo. Stebėtojo klasė turi įgyvendinti `:delivered_email(message)` metodą, kuris bus iškviestas po el. laiško išsiuntimo.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

Panašiai kaip peržiūros, stebėtojus taip pat reikia registruoti, naudojant `observers` konfigūracijos parinktį. Tai galite padaryti inicializavimo faile, pvz., `config/initializers/mail_observers.rb`:

```ruby
Rails.application.configure do
  config.action_mailer.observers = %w[EmailDeliveryObserver]
end
```
[`ActionMailer::Base`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html
[`default`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-c-default
[`mail`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail
[`ActionMailer::MessageDelivery`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html
[`deliver_later`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_later
[`deliver_now`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-deliver_now
[`Mail::Message`]: https://api.rubyonrails.org/classes/Mail/Message.html
[`message`]: https://api.rubyonrails.org/classes/ActionMailer/MessageDelivery.html#method-i-message
[`with`]: https://api.rubyonrails.org/classes/ActionMailer/Parameterized/ClassMethods.html#method-i-with
[`attachments`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-attachments
[`headers`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-headers
[`email_address_with_name`]: https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-email_address_with_name
[`append_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-append_view_path
[`prepend_view_path`]: https://api.rubyonrails.org/classes/ActionView/ViewPaths/ClassMethods.html#method-i-prepend_view_path
[`cache`]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache
[`layout`]: https://api.rubyonrails.org/classes/ActionView/Layouts/ClassMethods.html#method-i-layout
[`url_for`]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[`after_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-after_action
[`after_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-after_deliver
[`around_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-around_action
[`around_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-around_deliver
[`before_action`]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[`before_deliver`]: https://api.rubyonrails.org/classes/ActionMailer/Callbacks/ClassMethods.html#method-i-before_deliver
[`ActionMailer::MailHelper`]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html
[MailHelper#mailer]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-mailer
[MailHelper#message]: https://api.rubyonrails.org/classes/ActionMailer/MailHelper.html#method-i-message
[`config.action_mailer.sendmail_settings`]: configuring.html#config-action-mailer-sendmail-settings
[`config.action_mailer.smtp_settings`]: configuring.html#config-action-mailer-smtp-settings
