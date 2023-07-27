**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b8e9de3d2aa934a8a6fc3e1dccb4824c
Aktyvaus saugojimo apžvalga
=======================

Šiame vadove aprašoma, kaip pridėti failus prie jūsų Aktyvaus įrašo modelių.

Po šio vadovo perskaitymo žinosite:

* Kaip pridėti vieną ar daug failų prie įrašo.
* Kaip ištrinti pridėtą failą.
* Kaip susieti su pridėtu failu.
* Kaip naudoti variantus, kad pakeistumėte paveikslėlius.
* Kaip generuoti vaizdinį atvaizdą ne paveikslėlio failui, pvz., PDF arba vaizdo įrašui.
* Kaip tiesiogiai iš naršyklių siųsti failų įkėlimus į saugojimo paslaugą, apeinant jūsų taikomosios programos serverius.
* Kaip išvalyti testavimo metu saugomus failus.
* Kaip įgyvendinti papildomų saugojimo paslaugų palaikymą.

--------------------------------------------------------------------------------

Kas yra Aktyvus saugojimas?
-----------------------

Aktyvus saugojimas palengvina failų įkėlimą į debesų saugojimo paslaugą, pvz., Amazon S3, „Google Cloud Storage“ arba „Microsoft Azure Storage“, ir prideda tuos failus prie Aktyvus įrašo objektų. Jis turi vietinės disko pagrindinės paslaugos diegimui ir testavimui ir palaiko failų kopijavimą į pavaldžias paslaugas atsarginėms kopijoms ir migracijoms.

Naudodamas Aktyvų saugojimą, taikomoji programa gali keisti įkeltų paveikslėlių formatą arba generuoti vaizdinį atvaizdą ne paveikslėlių įkėlimams, pvz., PDF ir vaizdo įrašams, ir ištraukti metaduomenis iš bet kokių failų.

### Reikalavimai

Įvairios Aktyvaus saugojimo funkcijos priklauso nuo trečiųjų šalių programinės įrangos, kurią „Rails“ neįdiegs ir kuriai reikia atskirai įdiegti:

* [libvips](https://github.com/libvips/libvips) v8.6+ arba [ImageMagick](https://imagemagick.org/index.php) paveikslėlių analizei ir transformacijoms
* [ffmpeg](http://ffmpeg.org/) v3.4+ vaizdo peržiūroms ir ffprobe vaizdo/garsų analizei
* [poppler](https://poppler.freedesktop.org/) arba [muPDF](https://mupdf.com/) PDF peržiūrai

Paveikslėlių analizei ir transformacijoms taip pat reikalingas `image_processing` grotelė. Jei reikia, ją atkomentuokite savo `Gemfile` arba pridėkite:

```ruby
gem "image_processing", ">= 1.2"
```

PATARIMAS: Palyginti su libvips, ImageMagick yra geriau žinomas ir plačiau prieinamas. Tačiau libvips gali būti [iki 10 kartų greitesnis ir sunaudoja 1/10 atminties](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). JPEG failams tai galima toliau pagerinti pakeičiant `libjpeg-dev` į `libjpeg-turbo-dev`, kuris yra [2-7 kartus greitesnis](https://libjpeg-turbo.org/About/Performance).

ĮSPĖJIMAS: Prieš įdiegdami ir naudodami trečiųjų šalių programinę įrangą, įsitikinkite, kad suprantate jos licencijos reikšmes. Ypač MuPDF licencijuojamas pagal AGPL ir reikalauja komercinės licencijos kai kuriems naudojimo atvejams.

## Diegimas

```bash
$ bin/rails active_storage:install
$ bin/rails db:migrate
```

Tai nustato konfigūraciją ir sukuria tris Aktyvaus saugojimo naudojamas lentas:
`active_storage_blobs`, `active_storage_attachments` ir `active_storage_variant_records`.

| Lentelė      | Paskirtis |
| ------------------- | ----- |
| `active_storage_blobs` | Saugo duomenis apie įkeltus failus, pvz., failo pavadinimą ir turinio tipą. |
| `active_storage_attachments` | Polimorfinė jungtinė lentelė, kuri [jungia jūsų modelius su blobais](#attaching-files-to-records). Jei jūsų modelio klasės pavadinimas pasikeičia, turėsite paleisti migraciją šioje lentelėje, kad atnaujintumėte pagrindinį `record_type` į jūsų modelio naują klasės pavadinimą. |
| `active_storage_variant_records` | Jei [variantų sekimas](#attaching-files-to-records) yra įjungtas, saugo įrašus kiekvienam sugeneruotam variantui. |

ĮSPĖJIMAS: Jei savo modeliuose vietoj sveikųjų skaičių naudojate UUID kaip pirminį raktą, turėtumėte nustatyti `Rails.application.config.generators { |g| g.orm :active_record, primary_key_type: :uuid }` konfigūracijos faile.

Apibrėžkite Aktyvaus saugojimo paslaugas `config/storage.yml` faile. Kiekvienai jūsų taikomosios programos naudojamai paslaugai pateikite pavadinimą ir reikiamą konfigūraciją. Pavyzdys žemiau deklaruoja tris paslaugas, pavadinimu `local`, `test` ir `amazon`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  region: "" # pvz., 'us-east-1'
```

Pasakykite Aktyviam saugojimui, kurią paslaugą naudoti nustatydami
`Rails.application.config.active_storage.service`. Kadangi kiekviena aplinka tikriausiai naudos skirtingą paslaugą, rekomenduojama tai daryti aplinkos pagrindu. Norėdami naudoti ankstesnio pavyzdžio disko paslaugą vystymosi aplinkoje, pridėtumėte šį kodą prie
`config/environments/development.rb`:

```ruby
# Saugoti failus vietiniame diske.
config.active_storage.service = :local
```

Norėdami naudoti S3 paslaugą gamyboje, pridėtumėte šį kodą prie
`config/environments/production.rb`:

```ruby
# Saugoti failus „Amazon S3“.
config.active_storage.service = :amazon
```

Norėdami naudoti testavimo metu, pridėtumėte šį kodą prie
`config/environments/test.rb`:

```ruby
# Saugoti įkeltus failus vietiniame failų sistemos laikinyje aplanke.
config.active_storage.service = :test
```

PASTABA: Aplinkai specifiniai konfigūracijos failai bus pirmenybėje:
pvz., gamyboje, jei egzistuoja `config/storage/production.yml` failas,
jis bus pirmenybėje prieš `config/storage.yml` failą.

Rekomenduojama naudoti `Rails.env` kibirų pavadinimuose, kad dar labiau sumažintumėte riziką atsitiktinai sunaikinti gamybos duomenis.

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: your_container_name-<%= Rails.env %>
```
Toliau skaitykite daugiau informacijos apie įdiegtus paslaugų adapterius (pvz., `Disk` ir `S3`) ir jų konfigūraciją.

### Disko paslauga

Apibrėžkite Disko paslaugą `config/storage.yml` faile:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### S3 paslauga (Amazon S3 ir S3 suderinami API)

Norėdami prisijungti prie Amazon S3, apibrėžkite S3 paslaugą `config/storage.yml` faile:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Galite pasirinktinai nurodyti kliento ir įkėlimo parinktis:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' arba 'AES256'
    cache_control: "private, max-age=<%= 1.day.to_i %>"
```

PATARIMAS: Nustatykite tinkamus kliento HTTP laukimo laikus ir pakartotinio bandymo limitus savo programai. Tam tikrose nesėkmės scenarijose numatyta AWS kliento konfigūracija gali sukelti ryšių laikymąsi iki kelių minučių ir sukelti užklausų eilėjimą.

Pridėkite [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) paketą į savo `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

Pastaba: Pagrindinės Active Storage funkcijos reikalauja šių leidimų: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject` ir `s3:DeleteObject`. [Viešas prieigos](#vieša-prieiga) taip pat reikalauja `s3:PutObjectAcl`. Jei turite papildomų įkėlimo parinkčių, pvz., nustatydami ACL, gali būti reikalingi papildomi leidimai.

Pastaba: Jei norite naudoti aplinkos kintamuosius, standartinius SDK konfigūracijos failus, profilius,
IAM egzempliorių profilius ar užduočių roles, galite pamiršti `access_key_id`, `secret_access_key`
ir `region` raktus aukščiau pateiktame pavyzdyje. S3 paslauga palaiko visus
autentifikavimo parinktis, aprašytas [AWS SDK dokumentacijoje](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Norėdami prisijungti prie S3 suderinamo objektų saugojimo API, pvz., DigitalOcean Spaces, nurodykite `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...ir kitos parinktys
```

Yra daug kitų parinkčių. Jų sąrašą galite rasti [AWS S3 kliento](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method) dokumentacijoje.

### Microsoft Azure Storage paslauga

Apibrėžkite Azure Storage paslaugą `config/storage.yml` faile:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Pridėkite [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) paketą į savo `Gemfile`:

```ruby
gem "azure-storage-blob", "~> 2.0", require: false
```

### Google Cloud Storage paslauga

Apibrėžkite Google Cloud Storage paslaugą `config/storage.yml` faile:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Pasirinktinai pateikite įgaliojimų maišą vietoj raktų failo kelio:

```yaml
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: ""
```

Pasirinktinai nurodykite `Cache-Control` metaduomenis, kurie bus nustatyti įkeltiems ištekliams:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Pasirinktinai naudokite [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) vietoj `credentials` naudojant URL adresus. Tai naudinga, jei autentifikuojate savo GKE programas naudodami darbo apkrovos tapatybę, daugiau informacijos rasite [šiame Google Cloud tinklaraščio įraše](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication-for-your-gke-applications).

```yaml
google:
  service: GCS
  ...
  iam: true
```

Pasirinktinai naudokite konkretų GSA, kai pasirašote URL adresus. Naudojant IAM, [metaduomenų serveris](https://cloud.google.com/compute/docs/storing-retrieving-metadata) bus naudojamas, kad gautų GSA el. paštą, tačiau šis metaduomenų serveris ne visada yra prieinamas (pvz., vietiniai testai), ir galite norėti naudoti ne numatytąjį GSA.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Pridėkite [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) paketą į savo `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Veidročių paslauga

Galite sinchronizuoti kelias paslaugas, apibrėždami veidročių paslaugą. Veidročių paslauga atkuria įkėlimus ir trynimus tarp dviejų ar daugiau pavaldžių paslaugų.

Veidročių paslauga skirta laikinai naudoti per migraciją tarp paslaugų gamyboje. Galite pradėti veidročių kurti naujai paslaugai, nukopijuoti ankstesnius failus iš senosios paslaugos į naująją ir visiškai perjungti į naująją paslaugą.

Pastaba: Veidročių kūrimas nėra atomiškas. Įkėlimas gali sėkmingai įvykti pagrindinėje paslaugoje ir nepavykti vienoje iš pavaldžių paslaugų. Prieš visiškai perjungiant į naują paslaugą, patikrinkite, ar visi failai buvo nukopijuoti.

Apibrėžkite kiekvieną paslaugą, kurias norite veidročiuoti, kaip aprašyta aukščiau. Nuorodą į jas nurodykite, apibrėždami veidročių paslaugą:

```yaml
s3_west_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

s3_east_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

Nors visos antrinės paslaugos gauna įkėlimus, atsisiuntimus visada tvarko pagrindinė paslauga.

Veidročių paslaugos yra suderinamos su tiesioginiais įkėlimais. Nauji failai tiesiogiai įkeliami į pagrindinę paslaugą. Kai tiesiogiai įkeltas failas pridedamas prie įrašo, fone užduotis įtraukiama, kad jį nukopijuotų į antrines paslaugas.
### Viešas prieigos

Pagal numatytuosius nustatymus, Active Storage priima privačią prieigą prie paslaugų. Tai reiškia, kad generuojami pasirašyti, vienkartiniai URL adresai blob'ams. Jei norite, kad blob'ai būtų viešai prieinami, nurodykite `public: true` savo programos `config/storage.yml` failo:

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_key.json") %>
  bucket: ""

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_key.json") %>
  bucket: ""
  public: true
```

Įsitikinkite, kad jūsų kibirai tinkamai sukonfigūruoti viešai prieinamai. Žr. dokumentaciją, kaip įjungti viešą skaitymo leidimą [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets) ir [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal) saugojimo paslaugoms. Amazon S3 taip pat reikalauja, kad turėtumėte `s3:PutObjectAcl` leidimą.

Konvertuojant esamą programą naudojant `public: true`, įsitikinkite, kad prieš perjungiant, kiekvienas atskiras failas kibirėlyje yra viešai skaitomas.

Failų pridėjimas prie įrašų
--------------------------

### `has_one_attached`

[`has_one_attached`][] makro nustato vieno įrašo ir failų vienareikšmį atitikimą. Kiekvienam įrašui gali būti pridėtas vienas failas.

Pavyzdžiui, jei jūsų programa turi `User` modelį ir norite, kad kiekvienas vartotojas turėtų avatarą, apibrėžkite `User` modelį taip:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

arba, jei naudojate Rails 6.0+, galite paleisti modelio generavimo komandą taip:

```ruby
bin/rails generate model User avatar:attachment
```

Galite sukurti vartotoją su avataru:

```erb
<%= form.file_field :avatar %>
```

```ruby
class SignupController < ApplicationController
  def create
    user = User.create!(user_params)
    session[:user_id] = user.id
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :avatar)
    end
end
```

Norėdami pridėti avatarą prie esamo vartotojo, naudokite [`avatar.attach`][Attached::One#attach]:

```ruby
user.avatar.attach(params[:avatar])
```

Norėdami nustatyti, ar konkretus vartotojas turi avatarą, naudokite [`avatar.attached?`][Attached::One#attached?]:

```ruby
user.avatar.attached?
```

Kai kuriais atvejais gali prireikti pakeisti numatytąją paslaugą tam tikram priedui. Galite konfigūruoti konkretesnes paslaugas kiekvienam priedui naudodami `service` parinktį:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Galite konfigūruoti konkretesnius variantus kiekvienam priedui, iškviesdami `variant` metodą perduodamam pridedamam objektui:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

Norėdami gauti miniatiūros variantą iš avatara, naudokite `avatar.variant(:thumb)`:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

Taip pat galite naudoti konkretesnius variantus peržiūrai:

```ruby
class User < ApplicationRecord
  has_one_attached :video do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```

```erb
<%= image_tag user.video.preview(:thumb) %>
```


### `has_many_attached`

[`has_many_attached`][] makro nustato vieno įrašo ir failų vienam daugeliui atitikimą. Kiekvienam įrašui gali būti pridėti daug failų.

Pavyzdžiui, jei jūsų programa turi `Message` modelį ir norite, kad kiekvienas pranešimas turėtų daug paveikslėlių, apibrėžkite `Message` modelį taip:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

arba, jei naudojate Rails 6.0+, galite paleisti modelio generavimo komandą taip:

```ruby
bin/rails generate model Message images:attachments
```

Galite sukurti pranešimą su paveikslėliais:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    redirect_to message
  end

  private
    def message_params
      params.require(:message).permit(:title, :content, images: [])
    end
end
```

Norėdami pridėti naujus paveikslėlius prie esamo pranešimo, naudokite [`images.attach`][Attached::Many#attach]:

```ruby
@message.images.attach(params[:images])
```

Norėdami nustatyti, ar konkretus pranešimas turi paveikslėlių, naudokite [`images.attached?`][Attached::Many#attached?]:

```ruby
@message.images.attached?
```

Numatytosios paslaugos pakeitimas atliekamas taip pat kaip ir `has_one_attached`, naudojant `service` parinktį:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

Konkrečių variantų konfigūravimas atliekamas taip pat kaip ir `has_one_attached`, iškviesdami `variant` metodą perduodamam pridedamam objektui:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end
end
```



### Pridedant failų/IO objektus

Kartais reikia pridėti failą, kuris neatvyksta per HTTP užklausą. Pavyzdžiui, galite norėti pridėti failą, kurį sukūrėte diske arba atsisiuntėte iš vartotojo pateiktos URL. Taip pat galite norėti pridėti fiktyvų failą modelio teste. Tam pateikite `Hash`, kuriame yra bent atidarytas IO objektas ir failo pavadinimas:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Kai įmanoma, nurodykite ir turinio tipą. Active Storage bandys nustatyti failo turinio tipą iš jo duomenų. Jei nepavyksta, bus naudojamas nurodytas turinio tipas.
```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Jei norite apeiti duomenų turinio tipo nustatymą, perduokite `identify: false` kartu su `content_type`.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Jei nenurodysite turinio tipo ir Active Storage negalės automatiškai nustatyti failo turinio tipo, jis pagal nutylėjimą bus nustatytas kaip application/octet-stream.


Failų pašalinimas
--------------

Norėdami pašalinti priedą iš modelio, iškvieskite [`purge`][Attached::One#purge] metodą priedui. Jei jūsų programa sukonfigūruota naudoti Active Job, pašalinimas gali būti atliktas fone, iškviečiant [`purge_later`][Attached::One#purge_later] metodą. Pašalinimas ištrina blobą ir failą iš saugojimo paslaugos.

```ruby
# Sinchroniškai sunaikinkite avatarą ir faktinio resurso failus.
user.avatar.purge

# Asinchroniškai sunaikinkite susijusius modelius ir faktinio resurso failus per Active Job.
user.avatar.purge_later
```


Failų teikimas
-------------

Active Storage palaiko du būdus, kaip teikti failus: nukreipiant ir perkeliant.

ĮSPĖJIMAS: Visi Active Storage valdikliai pagal nutylėjimą yra viešai prieinami. Sugeneruotos URL yra sunkiai atspėjamos, tačiau nuolatios. Jei jūsų failams reikalingas aukštesnis apsaugos lygis, apsvarstykite autentifikuotų valdiklių įgyvendinimą
[Autentifikuoti valdikliai](#authenticated-controllers).

### Nukreipimo režimas

Norėdami sugeneruoti nuolatinį URL blobui, galite perduoti blobą į [`url_for`][ActionView::RoutingUrlFor#url_for] pagalbinį vaizdo valdiklį. Tai sugeneruoja URL su blobo [`signed_id`][ActiveStorage::Blob#signed_id], kuris nukreipiamas į blobo [`RedirectController`][`ActiveStorage::Blobs::RedirectController`]

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

`RedirectController` nukreipia į faktinį paslaugos tašką. Šis nukreipimas atskiria paslaugos URL nuo faktinio URL ir leidžia, pavyzdžiui, atvaizduoti priedus skirtingose paslaugose, siekiant užtikrinti didelį prieinamumą. Nukreipimas turi 5 minučių HTTP galiojimo laiką.

Norėdami sukurti atsisiuntimo nuorodą, naudokite `rails_blob_{path|url}` pagalbinį vaizdo valdiklį. Naudodami šį pagalbinį vaizdo valdiklį, galite nustatyti dispoziciją.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

ĮSPĖJIMAS: Norint apsisaugoti nuo XSS atakų, Active Storage priverčia "Content-Disposition" antraštę būti "attachment" tam tikro tipo failams. Norėdami pakeisti šį elgesį, žr. galimas konfigūracijos parinktis [Rails programų konfigūravimas](configuring.html#configuring-active-storage).

Jei norite sukurti nuorodą iš už valdiklio / vaizdo konteksto (fonas
darbai, Cron darbai ir kt.), galite pasiekti `rails_blob_path` taip:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```


### Perkėlimo režimas

Galite pasirinktinai naudoti failų perkėlimą. Tai reiškia, kad jūsų programos serveriai atsisiųs failo duomenis iš saugojimo paslaugos atsakant į užklausas. Tai gali būti naudinga, jei norite teikti failus iš CDN.

Galite sukonfigūruoti Active Storage naudoti numatytąjį perkėlimo režimą:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Arba, jei norite aiškiai perkelti konkretų priedą, galite naudoti URL pagalbinius vaizdo valdiklius `rails_storage_proxy_path` ir `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### CDN naudojimas su Active Storage

Be to, norint naudoti CDN su Active Storage priedais, turėsite generuoti URL su perkėlimo režimu, kad jie būtų aptarnaujami jūsų programos ir CDN talpykloje be papildomo konfigūravimo. Tai veikia iškart, nes numatytasis Active Storage perkėlimo valdiklis nustato HTTP antraštę, nurodančią CDN talpyklai talpinti atsakymą.

Taip pat turėtumėte įsitikinti, kad sugeneruoti URL naudoja CDN prieglobos vietą, o ne jūsų programos prieglobos vietą. Yra kelios būdų tai pasiekti, bet apskritai tai apima jūsų `config/routes.rb` failo keitimą, kad galėtumėte generuoti tinkamus URL priedams ir jų variantams. Pavyzdžiui, galite pridėti tai:

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id(expires_in: expires_in),
      model.filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  else
    signed_blob_id = model.blob.signed_id(expires_in: expires_in)
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  end
end
```

ir tada generuokite maršrutus taip:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### Autentifikuoti valdikliai

Visi Active Storage valdikliai pagal nutylėjimą yra viešai prieinami. Sugeneruoti
URL naudoja paprastą [`signed_id`][ActiveStorage::Blob#signed_id], todėl jie sunkiai
atspėjami, bet nuolatiniai. Bet kas, kas žino blobo URL, galės jį pasiekti,
net jei `before_action` jūsų `ApplicationController` reikalauja prisijungimo. Jei jūsų failams reikalingas aukštesnis apsaugos lygis, galite
įgyvendinti savo autentifikuotus valdiklius, remiantis
[`ActiveStorage::Blobs::RedirectController`][],
[`ActiveStorage::Blobs::ProxyController`][],
[`ActiveStorage::Representations::RedirectController`][] ir
[`ActiveStorage::Representations::ProxyController`][]

Norėdami leisti prieigą prie savo logotipo tik tam tikram paskyros tipui, galite tai padaryti:
```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # Perjungti ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

Tada turėtumėte išjungti Active Storage numatytuosius maršrutus su:

```ruby
config.active_storage.draw_routes = false
```

kad būtų užkirstas kelias failams būti pasiekiamiems per viešai prieinamus URL.


Failų atsisiuntimas
-----------------

Kartais po to, kai įkeliama byla, ją reikia apdoroti, pavyzdžiui, konvertuoti į kitą formatą. Naudokite priedo [`download`][Blob#download] metodą, kad nuskaitytumėte bylos binarinius duomenis į atmintį:

```ruby
binary = user.avatar.download
```

Galbūt norėsite atsisiųsti bylą į disko failą, kad ją galėtų apdoroti išorinė programa (pvz., virusų skeneris ar medijos transkoderis). Naudokite priedo [`open`][Blob#open] metodą, kad atsisiųstumėte bylą į laikinąjį failą diske:

```ruby
message.video.open do |file|
  system '/path/to/virus/scanner', file.path
  # ...
end
```

Svarbu žinoti, kad byla dar nėra prieinama `after_create` atgaliniame iškvietime, bet tik `after_create_commit`.


Failų analizė
---------------

Active Storage analizuoja bylas, kai jos yra įkeliamos, užduodant užduotį Active Job. Analizuotos bylos saugo papildomą informaciją metaduomenų maiše, įskaitant `analyzed: true`. Galite patikrinti, ar blob'as buvo analizuotas, iškviesdami [`analyzed?`][] jį.

Vaizdo analizė suteikia `width` ir `height` atributus. Vaizdo analizė taip pat suteikia `duration`, `angle`, `display_aspect_ratio` ir `video` bei `audio` boolean reikšmes, nurodančias, ar yra šių kanalų. Garso analizė suteikia `duration` ir `bit_rate` atributus.


Vaizdų, vaizdo įrašų ir PDF failų rodymas
---------------

Active Storage palaiko įvairių failų atvaizdavimą. Galite iškviesti [`representation`][] priedą, kad parodytumėte vaizdo variantą arba vaizdo ar PDF peržiūrą. Prieš iškviesdami `representation`, patikrinkite, ar priedas gali būti atvaizduojamas, iškviesdami [`representable?`]. Kai kurie failų formatai negali būti peržiūrėti naudojant Active Storage iš anksto (pvz., „Word“ dokumentai); jei `representable?` grąžina `false`, galbūt norėsite [nuoroda](#serving-files) į bylą.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

Viduje `representation` iškviečia `variant` vaizdams ir `preview` peržiūrai. Taip pat galite tiesiogiai iškviesti šiuos metodus.


### Tingus vs nedelsiantinis įkėlimas

Pagal numatymą Active Storage bus atliekamas tingiai. Šis kodas:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Sugeneruos `<img>` žymą su `src` nurodytu į
[`ActiveStorage::Representations::RedirectController`][]. Naršyklė
pasiųs užklausą šiam valdikliui, kuris atliks šiuos veiksmus:

1. Apdoros bylą ir įkelia apdorotą bylą, jei reikia.
2. Grąžins `302` nukreipimą į bylą arba į
  * nuotolinį tarnybą (pvz., S3).
  * arba `ActiveStorage::Blobs::ProxyController`, kuris grąžins bylos turinį, jei [proxy režimas](#proxy-mode) yra įjungtas.

Tingus bylos įkėlimas leidžia veikti funkcijoms, pvz., [vienkartinėms nuorodoms](#public-access)
be poveikio pradiniam puslapio įkėlimui.

Tai veikia gerai daugumai atvejų.

Jei norite nedelsiant generuoti URL adresus vaizdams, galite iškviesti `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

Aktyvaus saugojimo varianto sekimo priemonė pagerina šį veikimą, saugodama
įrašą duomenų bazėje, jei prašomas variantas buvo apdorotas anksčiau.
Taigi, aukščiau pateiktas kodas tik vieną kartą padarys API užklausą į nuotolinę tarnybą (pvz., S3),
ir kai variantas bus saugomas, jį naudos. Varianto sekimo priemonė veikia automatiškai, bet gali būti išjungta per [`config.active_storage.track_variants`][].

Jei puslapyje atvaizduojate daugybę vaizdų, aukščiau pateiktas pavyzdys gali sukelti N+1 užklausų, įkeliančių visus varianto įrašus. Norėdami išvengti šių N+1 užklausų, naudokite vardinius taškus [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```


### Vaizdų transformavimas

Vaizdų transformavimas leidžia atvaizduoti vaizdą pasirinktais matmenimis.
Norėdami sukurti vaizdo variantą, iškvieskite [`variant`][] priedą priedui.
Metodui galite perduoti bet kokį varianto apdorojimo palaikomą transformaciją.
Kai naršyklė pasiekia varianto URL, Active Storage tingiai transformuos
pradinį blob'ą į nurodytą formatą ir nukreips į naują tarnybos vietą.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```
Jei yra prašoma varianto, Active Storage automatiškai taikys transformacijas priklausomai nuo paveikslėlio formato:

1. Kintami turinio tipai (kaip nurodyta [`config.active_storage.variable_content_types`][]) ir nelaikomi interneto paveikslėliais (kaip nurodyta [`config.active_storage.web_image_content_types`][]), bus konvertuojami į PNG formatą.

2. Jei nenurodytas `quality`, bus naudojamas varianto apdorojimo proceso numatytasis kokybės lygis tam tikram formate.

Active Storage gali naudoti arba [Vips][] arba MiniMagick kaip varianto apdorojimo procesorių. Numatytasis priklauso nuo jūsų `config.load_defaults` tikslinės versijos, o procesorius gali būti pakeistas nustatant [`config.active_storage.variant_processor`][].

Šie du procesoriai nėra visiškai suderinami, todėl, migruojant esamą programą tarp MiniMagick ir Vips, reikia atlikti keletą pakeitimų, jei naudojami formatui specifiniai parametrai:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

Galimi parametrai apibrėžti [`image_processing`][] gemo ir priklauso nuo naudojamo varianto proceso, tačiau abu palaiko šiuos parametrus:

| Parametras      | Pavyzdys | Aprašymas |
| ------------------- | ---------------- | ----- |
| `resize_to_limit` | `resize_to_limit: [100, 100]` | Sumažina paveikslėlį, kad jis tilptų nurodytuose matmenyse, išlaikant originalų kraštinių santykį. Sumažins paveikslėlį tik tuo atveju, jei jis yra didesnis nei nurodyti matmenys. |
| `resize_to_fit` | `resize_to_fit: [100, 100]` | Sumažina paveikslėlį, kad jis tilptų nurodytuose matmenyse, išlaikant originalų kraštinių santykį. Sumažins paveikslėlį, jei jis yra didesnis nei nurodyti matmenys, arba padidins, jei jis yra mažesnis. |
| `resize_to_fill` | `resize_to_fill: [100, 100]` | Sumažina paveikslėlį, kad jis užimtų nurodytus matmenis, išlaikant originalų kraštinių santykį. Jei reikia, apkirps paveikslėlį didesniame matmenyje. |
| `resize_and_pad` | `resize_and_pad: [100, 100]` | Sumažina paveikslėlį, kad jis tilptų nurodytuose matmenyse, išlaikant originalų kraštinių santykį. Jei reikia, užpildys likusią plotą permatomu spalvos sluoksniu, jei šaltinio paveikslėlyje yra alfa kanalas, arba juoda spalva. |
| `crop` | `crop: [20, 50, 300, 300]` | Ištraukia sritį iš paveikslėlio. Pirmi du argumentai yra ištraukimo srities kairysis ir viršutinis kraštas, o paskutiniai du argumentai yra ištraukimo srities plotis ir aukštis. |
| `rotate` | `rotate: 90` | Pasuka paveikslėlį nurodytu kampu. |

[`image_processing`][] turi daugiau galimybių (pvz., `saver`, kuris leidžia konfigūruoti paveikslėlio suspaudimą) savo dokumentacijoje skirtą [Vips](https://github.com/janko/image_processing/blob/master/doc/vips.md) ir [MiniMagick](https://github.com/janko/image_processing/blob/master/doc/minimagick.md) procesoriams.



### Failų peržiūra

Kai kurie ne paveikslėlių failai gali būti peržiūrimi: tai yra, jie gali būti pateikti kaip paveikslėliai. Pavyzdžiui, vaizdo failas gali būti peržiūrimas išskleidžiant pirmąjį kadro. Iš pradžių Active Storage palaiko vaizdo ir PDF dokumentų peržiūrą. Norėdami sukurti nuorodą į tingiai generuojamą peržiūrą, naudokite prisegimo [`preview`][] metodą:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Norint pridėti palaikymą kitam formatai, pridėkite savo peržiūros įrankį. Daugiau informacijos rasite [`ActiveStorage::Preview`][] dokumentacijoje.


Tiesioginės įkėlimai
--------------

Active Storage, su įtraukta JavaScript biblioteka, palaiko tiesioginį įkėlimą iš kliento į debesį.

### Naudojimas

1. Įtraukite `activestorage.js` į savo programos JavaScript rinkinį.

    Naudojant turinio paleidimo sistemą:

    ```js
    //= require activestorage
    ```

    Naudojant npm paketą:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Į savo [failo lauką](form_helpers.html#uploading-files) pridėkite `direct_upload: true`:

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    Arba, jei nenaudojate `FormBuilder`, pridėkite duomenų atributą tiesiogiai:

    ```erb
    <input type="file" data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Konfigūruokite CORS trečiųjų šalių saugyklų paslaugas, kad leistų tiesioginius įkėlimo užklausas.

4. Tai viskas! Įkėlimai prasideda pateikus formą.

### Cross-Origin Resource Sharing (CORS) konfigūracija

Norint, kad tiesioginiai įkėlimai į trečiųjų šalių paslaugą veiktų, reikės sukonfigūruoti paslaugą, kad ji leistų kryžmines kilmės užklausas iš jūsų programos. Pasitikrinkite savo paslaugos CORS dokumentaciją:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Atkreipkite dėmesį, kad leidžiate:

* Visus kilmės taškus, iš kurių pasiekiamas jūsų programos
* `PUT` užklausos metodą
* Šiuos antraštės laukus:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (išskyrus Azure Storage)
  * `x-ms-blob-content-disposition` (tik Azure Storage)
  * `x-ms-blob-type` (tik Azure Storage)
  * `Cache-Control` (tik GCS, jei nustatytas `cache_control`)
Disko paslaugai nereikia jokios CORS konfigūracijos, nes ji bendrina jūsų programos kilmę.

#### Pavyzdys: S3 CORS konfigūracija

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### Pavyzdys: Google Cloud Storage CORS konfigūracija

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

#### Pavyzdys: Azure Storage CORS konfigūracija

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
</Cors>
```

### Tiesioginio įkėlimo „JavaScript“ įvykiai

| Įvykio pavadinimas | Įvykio tikslas | Įvykio duomenys (`event.detail`) | Aprašymas |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | Nėra | Pateiktas forma, kurioje yra failų tiesioginiam įkėlimui skirtų laukų. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Išsiunčiamas kiekvienam failui po formos pateikimo. |
| `direct-upload:start` | `<input>` | `{id, file}` | Pradedamas tiesioginis įkėlimas. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Prieš siunčiant užklausą į jūsų programą dėl tiesioginio įkėlimo metaduomenų. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Prieš siunčiant užklausą dėl failo saugojimo. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | Kai vyksta užklausos dėl failų saugojimo pažanga. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | Įvyko klaida. Jei šis įvykis nebus atšauktas, bus rodomas įspėjimas. |
| `direct-upload:end` | `<input>` | `{id, file}` | Tiesioginis įkėlimas baigtas. |
| `direct-uploads:end` | `<form>` | Nėra | Visi tiesioginiai įkėlimai baigti. |

### Pavyzdys

Galite naudoti šiuos įvykius, kad parodytumėte įkėlimo pažangą.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Norėdami rodyti įkeltus failus formoje:

```js
// direct_uploads.js

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```

Pridėkite stilių:

```css
/* direct_uploads.css */

.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### Individualūs „drag and drop“ sprendimai

Galite naudoti „DirectUpload“ klasę šiam tikslui. Gavę failą iš pasirinktos bibliotekos, sukurkite „DirectUpload“ objektą ir iškvieskite jo „create“ metodą. „Create“ priima atgalinio iškvietimo funkciją, kuri bus iškviesta baigus įkėlimą.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Susieti su failo nuleidimu - naudoti ondrop ant tėvinio elemento arba naudoti
//  biblioteką kaip Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Susieti su įprastiniu failo pasirinkimu
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // galite išvalyti pasirinktus failus iš įvesties
  input.value = null
})

const uploadFile = (file) => {
  // jūsų formai reikia failo lauko direct_upload: true, kuris
  //  suteikia data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Tvarkyti klaidą
    } else {
      // Pridėti tinkamai pavadintą paslėptąjį įvesties lauką į formą su
      //  blob.signed_id reikšme, kad būtų perduoti blob id įprastame įkėlimo sraute
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

### Sekite failo įkėlimo pažangą

Naudodami „DirectUpload“ konstruktorių, galite įtraukti trečiąjį parametrą.
Tai leis „DirectUpload“ objektui kviečiant „directUploadWillStoreFileWithXHR“ metodą įkėlimo proceso metu.
Tada galite pridėti savo pažangos tvarkyklę prie XHR pagal savo poreikius.
```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Tvarkyti klaidą
      } else {
        // Pridėti tinkamai pavadintą paslėptą įvestį į formą
        // su blob.signed_id reikšme
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Naudokite event.loaded ir event.total, kad atnaujintumėte progreso juostą
  }
}
```

### Integracija su bibliotekomis ar karkasais

Kai gausite failą iš pasirinktos bibliotekos, turite sukurti `DirectUpload` egzempliorių ir naudoti jo "create" metodą, kad pradėtumėte įkėlimo procesą, pridedant reikalingus papildomus antraštės laukus, jei reikia. "Create" metodas taip pat reikalauja, kad būtų pateiktas atgalinio iškvietimo funkcija, kuri bus paleista baigus įkėlimą.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token) {
    const headers = { 'Authentication': `Bearer ${token}` }
    // INFO: Siuntimas antraštės yra neprivalomas parametras. Jei nuspręsite nesiųsti antraščių,
    //       autentifikacija bus atliekama naudojant slapukus arba sesijos duomenis.
    this.upload = new DirectUpload(this.file, this.url, this, headers)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Tvarkyti klaidą
      } else {
        // Naudokite blob.signed_id kaip failo nuorodą kitame užklausoje
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Naudokite event.loaded ir event.total, kad atnaujintumėte progreso juostą
  }
}
```

Norint įgyvendinti pritaikytą autentifikaciją, Rails aplikacijoje reikia sukurti naują valdiklį, panašų į šį:

```ruby
class DirectUploadsController < ActiveStorage::DirectUploadsController
  skip_forgery_protection
  before_action :authenticate!

  def authenticate!
    @token = request.headers['Authorization']&.split&.last

    return head :unauthorized unless valid_token?(@token)
  end
end
```

PASTABA: Naudodami [Tiesioginį įkėlimą](#tiesioginis-ikelimas) kartais gali atsitikti, kad failas įkeliamas, bet niekada nėra pridedamas prie įrašo. Svarstykite [išvalyti nepridėtus įkėlimus](#nepridetu-ikelimu-valymas).

Testavimas
-------------------------------------------

Norint išbandyti failo įkėlimą integracinėje arba valdiklio teste, naudokite [`fixture_file_upload`][] funkciją. Rails tvarko failus kaip bet kokius kitus parametrus.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "can sign up" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```


### Testavimo metu sukurtų failų pašalinimas

#### Sistemos testai

Sistemos testai valo testinius duomenis atšaukdami transakciją. Kadangi `destroy` niekada nėra iškviestas objekte, pridėti failai niekada nebus išvalyti. Jei norite išvalyti failus, galite tai padaryti naudodami `after_teardown` atgalinį iškvietimą. Tai padarys, kad visi testo metu sukurti ryšiai būtų užbaigti ir nebus gauta klaida iš Active Storage, kad negali rasti failo.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

Jei naudojate [lygiagrečius testus][] ir `DiskService`, turėtumėte konfigūruoti kiekvieną procesą naudoti savo aplanką Active Storage. Taip `teardown` atgalinis iškvietimas ištrins failus tik iš atitinkamo proceso testų.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

Jei jūsų sistemos testai patikrina modelio su priedais trynimą ir naudojate Active Job, nustatykite savo testinę aplinką naudoti `inline` eilės adapterį, kad šalinimo darbas būtų vykdomas iš karto, o ne nežinomoje ateityje.

```ruby
# Naudokite inline darbų apdorojimą, kad viskas vyktų iš karto
config.active_job.queue_adapter = :inline
```

[lygiagretūs testai]: testing.html#lygiagretus-testavimas

#### Integraciniai testai

Panašiai kaip sistemos testuose, failai, įkelti integracinių testų metu, nebus automatiškai išvalyti. Jei norite išvalyti failus, galite tai padaryti naudodami `teardown` atgalinį iškvietimą.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Jei naudojate [lygiagrečius testus][] ir `Disk` paslaugą, turėtumėte konfigūruoti kiekvieną procesą naudoti savo aplanką Active Storage. Taip `teardown` atgalinis iškvietimas ištrins failus tik iš atitinkamo proceso testų.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[lygiagretūs testai]: testing.html#lygiagretus-testavimas

### Priedų pridėjimas prie fiktyvių duomenų

Galite pridėti priedus prie jūsų esamų [fiktyvių duomenų][fixtures]. Pirmiausia turėtumėte sukurti atskirą saugyklos paslaugą:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Tai nurodo Active Storage, kur "įkelti" fiktyvius failus, todėl tai turėtų būti laikinas katalogas. Padarydami jį skirtingu katalogu nuo įprastos `test` paslaugos, galite atskirti fiktyvius failus nuo failų, įkeltų testo metu.
Toliau sukurti fiktyvius failus Active Storage klasėms:

```yml
# active_storage/attachments.yml
david_avatar:
  name: avatar
  record: david (User)
  blob: david_avatar_blob
```

```yml
# active_storage/blobs.yml
david_avatar_blob: <%= ActiveStorage::FixtureSet.blob filename: "david.png", service_name: "test_fixtures" %>
```

Tada įdėkite failą į jūsų fiktyvių failų aplanką (numatytasis kelias yra `test/fixtures/files`) su atitinkamu failo pavadinimu.
Daugiau informacijos rasite [`ActiveStorage::FixtureSet`][] dokumentacijoje.

Kai viskas bus sukonfigūruota, galėsite pasiekti priedus savo testuose:

```ruby
class UserTest < ActiveSupport::TestCase
  def test_avatar
    avatar = users(:david).avatar

    assert avatar.attached?
    assert_not_nil avatar.download
    assert_equal 1000, avatar.byte_size
  end
end
```

#### Fiktyvių failų valymas

Nors failai, įkelti testuose, yra valomi [kiekvieno testo pabaigoje](#discarding-files-created-during-tests),
fiktyvių failų reikia valyti tik vieną kartą: kai visi jūsų testai baigiasi.

Jei naudojate lygiagretesnius testus, iškvieskite `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

Jei nenaudojate lygiagretesnių testų, naudokite `Minitest.after_run` arba atitinkamą jūsų testų
karkaso funkciją (pvz., `after(:suite)` RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```


### Paslaugų konfigūravimas

Galite pridėti `config/storage/test.yml` failą, kad konfigūruotumėte paslaugas, naudojamas testavimo aplinkoje.
Tai naudinga, kai naudojama `service` parinktis.

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Be `config/storage/test.yml`, naudojama `s3` paslauga, sukonfigūruota `config/storage.yml` faile - net paleidžiant testus.

Būtų naudojama numatytoji konfigūracija ir failai būtų įkelti į paslaugos tiekėją, sukonfigūruotą `config/storage.yml` faile.

Šiuo atveju galite pridėti `config/storage/test.yml` ir naudoti Disk paslaugą `s3` paslaugai, kad būtų išvengta užklausų siuntimo.

```yaml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

s3:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

Kitų debesų paslaugų palaikymo įgyvendinimas
---------------------------------------------

Jei norite palaikyti kitą debesų paslaugą, turėsite
įgyvendinti paslaugą. Kiekviena paslauga išplečia
[`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html)
įgyvendindama metodus, reikalingus failų įkėlimui ir atsisiuntimui į debesį.

Neprisegti įkėlimai
--------------------------

Yra atvejų, kai failas yra įkeltas, bet niekada neprikabintas prie įrašo. Tai gali atsitikti naudojant [Tiesioginius įkėlimus](#direct-uploads). Galite užklausti neprisegtų įrašų naudodami [neprisegtų ribojimą](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49). Žemiau pateikiamas pavyzdys naudojant [adaptuotą rake užduotį](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Valo neprisegtus Active Storage blob'us. Paleiskite reguliariai."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge_later)
  end
end
```

ĮSPĖJIMAS: `ActiveStorage::Blob.unattached` sugeneruota užklausa gali būti lėta ir potencialiai trukdyti didesnių duomenų bazių programoms.
[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F
[`has_many_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F
[Attached::One#purge]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later
[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id
[`ActiveStorage::Blobs::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/RedirectController.html
[`ActiveStorage::Blobs::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/ProxyController.html
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Representations::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/ProxyController.html
[Blob#download]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open
[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F
[`representable?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation
[`config.active_storage.track_variants`]: configuring.html#config-active-storage-track-variants
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Attachment`]: https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html
[`config.active_storage.variable_content_types`]: configuring.html#config-active-storage-variable-content-types
[`config.active_storage.variant_processor`]: configuring.html#config-active-storage-variant-processor
[`config.active_storage.web_image_content_types`]: configuring.html#config-active-storage-web-image-content-types
[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image
[`image_processing`]: https://github.com/janko/image_processing
[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html
[`fixture_file_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html
[fixtures]: testing.html#the-low-down-on-fixtures
[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html
