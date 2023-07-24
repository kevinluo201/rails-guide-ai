**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b3af31bbaec1019121ce4667087dc971
Politique de maintenance pour Ruby on Rails
=============================================

Le support du framework Rails est divisé en quatre groupes : nouvelles fonctionnalités, corrections de bugs, problèmes de sécurité et problèmes de sécurité graves. Ils sont gérés de la manière suivante, pour toutes les versions, sauf les versions de sécurité, au format `X.Y.Z`.

--------------------------------------------------------------------------------

Numérotation des versions
-------------------------

Rails suit une version décalée de [semver](https://semver.org/) :

**Correctif `Z`**

Uniquement des corrections de bugs, pas de modifications de l'API, pas de nouvelles fonctionnalités.
Sauf si nécessaire pour les correctifs de sécurité.

**Mineur `Y`**

Nouvelles fonctionnalités, peut contenir des modifications de l'API (correspond aux versions majeures de Semver).
Les changements majeurs sont accompagnés d'avis de dépréciation dans la version mineure ou majeure précédente.

**Majeur `X`**

Nouvelles fonctionnalités, contiendra probablement des modifications de l'API. La différence entre les versions mineures et majeures de Rails réside dans l'ampleur des changements majeurs, et est généralement réservée à des occasions spéciales.

Nouvelles fonctionnalités
-------------------------

Les nouvelles fonctionnalités ne sont ajoutées qu'à la branche principale et ne seront pas disponibles dans les versions de maintenance.

Corrections de bugs
-------------------

Seule la dernière série de versions recevra des corrections de bugs. Les corrections de bugs sont généralement ajoutées à la branche principale, puis rétroportées vers la branche x-y-stable de la dernière série de versions si nécessaire. Lorsqu'un nombre suffisant de corrections de bugs ont été ajoutées à une branche x-y-stable, une nouvelle version de correctif est construite à partir de celle-ci. Par exemple, une version de correctif théorique 1.2.2 serait construite à partir de la branche 1-2-stable.

Dans des situations particulières, où un membre de l'équipe principale accepte de prendre en charge davantage de séries, elles sont incluses dans la liste des séries prises en charge.

Pour les séries non prises en charge, des corrections de bugs peuvent accidentellement être intégrées à une branche stable, mais ne seront pas publiées dans une version officielle. Il est recommandé de pointer votre application vers la branche stable en utilisant Git pour les versions non prises en charge.

**Séries actuellement incluses :** `7.1.Z`.

Problèmes de sécurité
---------------------

La série de versions actuelle et la précédente recevront des correctifs et de nouvelles versions en cas de problème de sécurité.

Ces versions sont créées en prenant la dernière version publiée, en appliquant les correctifs de sécurité, puis en publiant la version mise à jour. Ces correctifs sont ensuite appliqués à la fin de la branche x-y-stable. Par exemple, une version de sécurité théorique 1.2.2.1 serait construite à partir de la version 1.2.2, puis ajoutée à la fin de la branche 1-2-stable. Cela signifie que les versions de sécurité sont faciles à mettre à jour si vous utilisez la dernière version de Rails.

Seuls les correctifs de sécurité directs seront inclus dans les versions de sécurité. Les corrections de bugs non liées à la sécurité résultant d'un correctif de sécurité peuvent être publiées sur la branche x-y-stable d'une version, et ne seront publiées que sous la forme d'un nouveau gemme conformément à la politique de corrections de bugs.

Les versions de sécurité sont créées à partir de la dernière branche/tag de version de sécurité. Sinon, il pourrait y avoir des changements majeurs dans la version de sécurité. Une version de sécurité ne doit contenir que les modifications nécessaires pour garantir la sécurité de l'application, afin de faciliter la mise à jour des applications.

**Séries actuellement incluses :** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Problèmes de sécurité graves
----------------------------

Pour les problèmes de sécurité graves, toutes les versions de la série majeure actuelle, ainsi que la dernière version de la série majeure précédente, recevront des correctifs et de nouvelles versions. La classification du problème de sécurité est jugée par l'équipe principale.

**Séries actuellement incluses :** `7.1.Z`, `7.0.Z`, `6.1.Z`.

Séries de versions non prises en charge
----------------------------------------

Lorsqu'une série de versions n'est plus prise en charge, il est de votre responsabilité de gérer les bugs et les problèmes de sécurité. Nous pouvons fournir des rétroports des corrections et les fusionner, mais il n'y aura pas de nouvelles versions publiées. Nous vous recommandons de pointer votre application vers la branche stable en utilisant Git. Si vous ne vous sentez pas à l'aise pour maintenir vos propres versions, vous devriez passer à une version prise en charge.

Packages NPM
------------

En raison d'une contrainte avec npm, nous ne pouvons pas utiliser le 4e chiffre pour les versions de sécurité des [packages NPM][] fournis par Rails. Cela signifie qu'au lieu de la version gemme équivalente `7.0.1.4`, le package NPM sera numéroté `7.0.1-4`.

[Packages NPM]: https://www.npmjs.com/org/rails
