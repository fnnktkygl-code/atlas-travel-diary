# Proposition d'évolution — Atlas Travel Diary, vers un journal narratif

## Principe directeur

Ne pas remplacer le country tracker existant (statuts pays, carte, stats) : c'est la partie qui fonctionne déjà bien et qui fait la force du produit sur son segment. On **ajoute une couche narrative par-dessus**, optionnelle à l'usage : un utilisateur pressé peut continuer à juste "marquer un pays comme visité" en deux clics, comme aujourd'hui ; un utilisateur qui veut documenter peut aller plus loin et créer de vraies entrées de journal.

C'est aussi ce qui distingue le mieux Atlas de Been (simple et rapide) tout en le rapprochant de Polarsteps (riche et narratif), sans perdre la promesse de rapidité qui plaît déjà aux utilisateurs de ce segment.

## Le vrai changement de fond : passer d'un statut à des entrées

Aujourd'hui, un pays visité n'a qu'**une seule date et une liste de villes** (`UserCountryData.date`, `.cities`). C'est la limite structurelle principale : impossible de documenter deux voyages séparés dans le même pays, impossible d'attacher un souvenir à un lieu précis.

Il faut introduire un nouveau concept, l'**entrée de journal** (`JournalEntry`), distincte du statut pays :

```
JournalEntry {
  id
  countryCode
  city            // avec autocomplétion via cities.dart, déjà présent dans le projet
  date
  title           // optionnel, ex. "Road trip Écosse"
  note            // texte libre, multi-lignes
  photoUrls: []   // liste d'URLs Firebase Storage
  coordinates?    // lat/lng optionnelles, capturées automatiquement si géoloc activée au moment de la saisie
}
```

Un pays peut avoir 0, 1 ou plusieurs `JournalEntry`. Le statut du pays (`visited`/`lived`/`wishlist`/`redlist`) reste indépendant et continue de piloter la carte et les stats globales — la richesse narrative vient s'ajouter par-dessus sans rien casser côté tracker.

**Migration** : à la mise à jour, convertir automatiquement les villes existantes en une `JournalEntry` par ville (sans photo, sans note), avec la date déjà connue du pays, pour ne perdre aucune donnée utilisateur.

## Parcours de saisie

- Depuis la carte : le double-tap ouvre déjà un bottom sheet (`_showAddCountryModal`). Ajouter un bouton "Ajouter un souvenir" qui ouvre l'écran de saisie d'entrée, en plus des boutons de statut existants.
- Depuis le `JournalPanel` : un bouton "+" toujours visible, pas seulement accessible via la carte.
- Écran de saisie : titre (optionnel), ville (autocomplétion `cities.dart`), date, note libre, sélection de photos (multi-sélection depuis la galerie), et une case "utiliser ma position actuelle" qui réutilise le `GeolocationService` déjà en place.
- Import automatique optionnel : si l'utilisateur a activé le suivi de position (`GeoProvider`), proposer de pré-remplir la date/ville lors de la création — cohérent avec ce qui existe déjà, pas besoin de suivi GPS continu type Polarsteps pour un premier jet.

## Restitution : de la liste au vrai journal

- `JournalPanel` devient une frise chronologique : chaque entrée affiche une vignette photo (ou une icône neutre si aucune photo), le titre/ville, un extrait de la note (1-2 lignes), la date.
- Écran de détail d'entrée en plein écran : galerie photo (carrousel), texte complet, mini-carte de localisation si coordonnées disponibles, actions modifier/supprimer.
- Le compteur du panneau ("journal · N") continue de fonctionner tel quel, juste sur le nombre d'entrées plutôt que de pays.

## Volet technique — photos

- Le `storageBucket` Firebase est déjà configuré mais inutilisé : c'est le morceau prêt à activer.
- Compression/redimensionnement côté client avant upload (éviter d'envoyer des photos brutes de plusieurs Mo — impact direct sur le coût de stockage et la bande passante).
- Upload en file d'attente offline-first, dans l'esprit de ce qui existe déjà avec Hive : l'entrée et les photos sont créées localement immédiatement (UX réactive), puis synchronisées vers Firestore/Storage dès que la connexion est disponible — c'est exactement le modèle "fonctionne hors ligne, se synchronise ensuite" cité comme point fort chez Polarsteps.
- Nouvelle sous-collection Firestore `users/{uid}/entries` (séparée de `users/{uid}/countries`), avec les URLs de Storage en référence plutôt que les images elles-mêmes en base64.
- Point de vigilance sécurité à traiter en même temps que la vérification de `firestore.rules` déjà identifiée : les règles de la nouvelle sous-collection `entries` et les règles Storage doivent aussi isoler strictement par `uid`, sinon les photos personnelles deviennent le nouveau point faible.

## Ce qu'on ne fait pas tout de suite

Le partage en temps réel, les niveaux de confidentialité (privé/abonnés/public) et l'impression de livre de voyage physique sont les points forts les plus cités de Polarsteps, mais ce sont aussi les plus coûteux à construire (infrastructure de partage, gestion de followers, service d'impression tiers). Les proposer dès la V1 ferait exploser le scope et retarderait la vraie priorité : donner du contenu au journal.

**Recommandation** : garder ces fonctionnalités pour une phase ultérieure, une fois que le socle narratif (notes + photos) est stable et adopté.

## Phasage proposé

| Phase | Contenu | Objectif |
|---|---|---|
| **1 — MVP narratif** | Modèle `JournalEntry`, note texte libre, plusieurs entrées par pays, timeline basique sans photo | Sortir du décalage entre le nom "Travel Diary" et l'absence totale de contenu |
| **2 — Photos** | Upload, compression, galerie dans le détail d'entrée, vignette dans la timeline | Rapprocher visuellement l'expérience de Polarsteps |
| **3 — Export privé** | Génération d'un résumé/export du voyage (PDF ou page partageable en lecture seule via lien) | Premier niveau de partage, sans construire un système social complet |
| **4 — Social** | Niveaux de confidentialité, followers, partage en temps réel | Seulement si les phases précédentes montrent une vraie adoption du contenu narratif |

## Point d'attention produit

Le risque principal de cette évolution est de complexifier une app qui plaît aujourd'hui justement pour sa simplicité ("no tutorial, tapped and it just clicked" — le retour le plus fréquent sur Been). Il faut que l'ajout d'une entrée reste **entièrement optionnel** et jamais interposé entre l'utilisateur et l'action rapide "marquer ce pays comme visité". Un bon test : un utilisateur qui n'ouvre jamais l'écran de saisie d'entrée doit avoir exactement la même expérience qu'aujourd'hui.
