**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b3af31bbaec1019121ce4667087dc971
Política de Manutenção para Ruby on Rails
===========================================

O suporte ao framework Rails é dividido em quatro grupos: Novos recursos, correções de bugs, problemas de segurança e problemas graves de segurança. Eles são tratados da seguinte forma, todas as versões, exceto as de segurança, no formato `X.Y.Z`.

--------------------------------------------------------------------------------

Versionamento
-------------

O Rails segue uma versão modificada do [semver](https://semver.org/):

**Patch `Z`**

Apenas correções de bugs, sem alterações na API, sem novos recursos.
Exceto quando necessário para correções de segurança.

**Minor `Y`**

Novos recursos, podem conter alterações na API (Servem como versões principais do Semver).
Alterações que quebram a compatibilidade são acompanhadas de avisos de depreciação na versão anterior menor ou principal.

**Major `X`**

Novos recursos, provavelmente conterão alterações na API. A diferença entre as versões menores e principais do Rails é a magnitude das alterações que quebram a compatibilidade, e geralmente são reservadas para ocasiões especiais.

Novos Recursos
--------------

Novos recursos são adicionados apenas ao branch principal e não estarão disponíveis em lançamentos pontuais.

Correções de Bugs
-----------------

Apenas a série de lançamento mais recente receberá correções de bugs. As correções de bugs geralmente são adicionadas ao branch principal e retroportadas para o branch x-y-stable da série de lançamento mais recente, se houver necessidade suficiente. Quando um número suficiente de correções de bugs for adicionado a um branch x-y-stable, um novo lançamento de patch é criado a partir dele. Por exemplo, um lançamento de patch teórico 1.2.2 seria criado a partir do branch 1-2-stable.

Em situações especiais, quando alguém da Equipe Principal concorda em dar suporte a mais séries, elas são incluídas na lista de séries suportadas.

Para séries não suportadas, correções de bugs podem coincidentemente serem incluídas em um branch estável, mas não serão lançadas em uma versão oficial. É recomendado apontar sua aplicação para o branch estável usando o Git para versões não suportadas.

**Séries atualmente incluídas:** `7.1.Z`.

Problemas de Segurança
----------------------

A série de lançamento atual e a série anterior mais recente receberão patches e novas versões em caso de problemas de segurança.

Esses lançamentos são criados pegando a última versão lançada, aplicando os patches de segurança e lançando. Esses patches são então aplicados ao final do branch x-y-stable. Por exemplo, um lançamento de segurança teórico 1.2.2.1 seria criado a partir do 1.2.2 e então adicionado ao final do 1-2-stable. Isso significa que os lançamentos de segurança são fáceis de atualizar se você estiver executando a versão mais recente do Rails.

Apenas patches de segurança diretos serão incluídos nos lançamentos de segurança. Correções para bugs não relacionados à segurança resultantes de um patch de segurança podem ser publicadas no branch x-y-stable de um lançamento e só serão lançadas como uma nova gem de acordo com a política de Correções de Bugs.

Os lançamentos de segurança são cortados a partir do último branch/tag de lançamento de segurança. Caso contrário, pode haver alterações que quebram a compatibilidade no lançamento de segurança. Um lançamento de segurança deve conter apenas as alterações necessárias para garantir que o aplicativo esteja seguro, para que seja mais fácil para as aplicações permanecerem atualizadas.

**Séries atualmente incluídas:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Problemas Graves de Segurança
----------------------------

Para problemas graves de segurança, todas as versões na série principal atual e também a última versão na série principal anterior receberão patches e novas versões. A classificação do problema de segurança é julgada pela equipe principal.

**Séries atualmente incluídas:** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Séries de Lançamento Não Suportadas
-----------------------------------

Quando uma série de lançamento não é mais suportada, é de sua responsabilidade lidar com bugs e problemas de segurança. Podemos fornecer retroportes das correções e mesclá-las, no entanto, não serão lançadas novas versões. Recomendamos apontar sua aplicação para o branch estável usando o Git. Se você não se sentir confortável em manter suas próprias versões, você deve atualizar para uma versão suportada.

Pacotes NPM
-----------

Devido a uma restrição com o npm, não podemos usar o quarto dígito para lançamentos de segurança dos [pacotes NPM][] fornecidos pelo Rails. Isso significa que, em vez da versão equivalente da gem `7.0.1.4`, o pacote NPM será versionado como `7.0.1-4`.

[pacotes NPM]: https://www.npmjs.com/org/rails
