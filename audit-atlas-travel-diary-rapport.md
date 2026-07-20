# Audit produit — Atlas Travel Diary
*Réalisé à partir du code source du dépôt (18 fichiers Dart couvrant providers, écrans, widgets, services, thème, données, i18n) et d'un benchmark sectoriel sourcé (avis App Store / Play Store / Product Hunt, 2025-2026).*

---

## 1. Résumé exécutif

Atlas Travel Diary n'est pas, dans son état actuel, un carnet de voyage narratif : c'est un **country tracker** — une carte du monde où l'on marque des pays visités/habités/en envie/en liste rouge, avec un journal réduit à une liste pays + villes + date, sans texte libre ni photo. Le nom du produit ("Travel *Diary*") promet plus que ce que l'app livre aujourd'hui, ce qui crée un décalage d'attente dès la première utilisation.

Techniquement, la base est saine : architecture Provider propre, cache local Hive + synchronisation Firestore bien pensée, typographie éditoriale cohérente (Fraunces/Outfit), gestion correcte des territoires non reconnus (ex. Somaliland) — un vrai point de parité avec le leader du secteur, Been. Mais plusieurs choix product et plusieurs manques techniques plombent l'expérience et la sécurité : connexion Google **obligatoire** dès le lancement alors que le mode invité existe déjà dans le code, aucun mode clair (l'app est figée en dark), traductions incomplètes malgré une infrastructure i18n solide, carte non accessible aux lecteurs d'écran, et surtout un point de sécurité non tranchable en l'état : les règles `firestore.rules` n'ont pas été fournies, ce qui empêche de garantir l'isolation des données entre utilisateurs.

**Trois priorités absolues :**
1. **Vérifier et durcir `firestore.rules`** (isolation stricte par `uid`, restriction des clés API côté Google Cloud Console) — c'est un prérequis de confiance avant tout le reste.
2. **Débloquer l'accès invité** dès l'ouverture de l'app (le code le permet déjà ailleurs) pour supprimer la barrière à l'entrée la plus dure du marché sur ce segment.
3. **Décider du positionnement** : rester un country tracker assumé (auquel cas simplifier la promesse "Travel Diary") ou investir dans un vrai contenu narratif (notes + photos), sachant que l'infrastructure Firebase Storage est déjà en place mais inutilisée.

---

## 2. Scores synthétiques

| Axe | Score /10 | Justification courte |
|---|---|---|
| UI | 6/10 | Typographie et palette cohérentes, mais un seul thème (dark only), tokens de design system contournés par endroits, statut redlist peu lisible |
| UX | 5/10 | Connexion forcée, pas d'onboarding, journal sans contenu narratif, traductions incomplètes, erreurs brutes affichées à l'utilisateur |
| Performance | 6/10 | Cache local bien pensé, mais parsing SVG synchrone redondant et détection de survol non optimisée |
| Sécurité | 5/10 | Architecture Firebase standard, mais `firestore.rules` non vérifiable, données géo envoyées à un tiers sans mention, pas de chiffrement local, pas de monitoring d'erreurs |
| Identité visuelle | 6/10 | Palette propre mais générique (Tailwind par défaut), sans caractère "voyage" affirmé ; bon pairing typographique |

**Moyenne : 5,6/10** — une base technique correcte, un produit à mi-chemin de sa promesse.

---

## 3. Analyse détaillée

### 3.1 UI

| Constat | Comparaison secteur | Recommandation | Priorité | Effort |
|---|---|---|---|---|
| App figée en `Brightness.dark`, aucun mode clair, aucun `ThemeMode` | Been, VoyageX/Visited et Country Tracking annoncent tous explicitement un mode clair **et** sombre comme argument produit | Ajouter un thème clair et un sélecteur, au minimum un mode "auto" suivant le système | Haute | Moyen |
| `ColorScheme.dark()` ne définit que `primary`/`surface`, le reste hérite des valeurs Material par défaut | — | Compléter tous les tokens Material 3 (secondary, tertiary, error, onPrimary…) pour éviter des couleurs génériques sur les composants non stylés | Moyenne | Faible |
| Couleurs Flutter en dur (`Colors.grey`, `Colors.red`, `Colors.white`) dans plusieurs widgets au lieu des tokens `AppTheme` | — | Purge systématique : tout passage par `AppTheme` uniquement | Moyenne | Faible |
| Statut `redlist` presque invisible (teintes proches du fond, différenciées par hachurage seul) | — | Revoir la couleur pour un contraste suffisant (WCAG AA minimum) sans dépendre uniquement d'une texture | Moyenne | Faible |
| Palette globale = valeurs par défaut Tailwind CSS (emerald/blue/amber/slate) | Aucun concurrent identifié n'a une identité "dashboard analytics" ; le secteur travel penche vers des teintes plus chaleureuses/évocatrices | Décider consciemment : soit assumer le style "data-driven" comme différenciateur, soit retravailler vers une palette plus évocatrice du voyage | Moyenne | Moyen |
| Carte en `CustomPainter`, aucune alternative accessible (`Semantics`, liste cliquable) | Standard d'accessibilité mobile de base (WCAG, Material) | Ajouter une vue liste alternative des pays, navigable au clavier/lecteur d'écran | Haute | Moyen |
| Pairing typographique Fraunces (titres) / Outfit (UI, chiffres) | Cohérent avec les tendances éditoriales premium du secteur lifestyle | Conserver, c'est un vrai point fort | — | — |

### 3.2 UX

| Constat | Comparaison secteur | Recommandation | Priorité | Effort |
|---|---|---|---|---|
| Connexion Google **obligatoire** dès le lancement (`AuthWrapper`), alors que le mode invité (Hive local) existe déjà et est même géré dans `UserProfileModal` | Been, Visited/VoyageX permettent un usage local complet, sync optionnelle | Laisser entrer directement en mode invité, proposer la connexion comme option de sauvegarde/sync, pas comme porte d'entrée | Haute | Moyen |
| Aucun onboarding | Been est cité comme "no tutorial, tapped and it just clicked" — pas d'onboarding lourd nécessaire, mais l'action principale doit être évidente dès l'écran d'accueil | Un état vide pédagogique sur la carte suffit (pas besoin d'un tutoriel multi-écrans) | Moyenne | Faible |
| Journal = liste pays/villes/date, sans note ni photo, malgré le nom "Travel Diary" | Polarsteps, Day One : le journal narratif (photos + texte) est la valeur centrale attendue par ce nom de produit | Ajouter au moins une note libre par entrée ; les photos peuvent suivre en V2 (l'infra Firebase Storage existe déjà) | Haute | Élevé |
| Traductions incomplètes : `geo_panel.dart` et le bottom sheet de `map_screen.dart` sont en français en dur malgré une infrastructure `LocaleProvider`/`translations.dart` complète en fr/en/es par ailleurs | — | Ajouter les clés manquantes et câbler ces deux écrans au système existant | Moyenne | Faible |
| Message d'erreur Firebase brut affiché à l'utilisateur (`e.toString()`) | — | Mapper les erreurs connues vers des messages génériques compréhensibles | Moyenne | Faible |
| Feedback de géolocalisation non différencié (permission refusée / service désactivé / timeout traités identiquement) | — | Différencier les messages pour guider l'action (ex. "ouvrir les réglages") | Basse | Faible |
| Statut "redlist" original mais wording et logique (exclusion du dénominateur des stats) peu explicités hors d'un tooltip | Fonctionnalité absente chez tous les concurrents identifiés — ni bonne ni mauvaise en soi | Clarifier l'intention (raisons personnelles ? sécurité ? géopolitique ?) dans le texte produit, ou simplifier si le concept reste confus en test utilisateur | Moyenne | Faible |
| Promesse UI non tenue : `color_custom_desc` annonce une personnalisation des couleurs "bientôt disponible" | — | Soit livrer, soit retirer la mention tant que ce n'est pas prêt | Basse | Faible |
| Ajout de ville en texte libre sans autocomplétion, alors qu'un référentiel de 1825 villes (`cities.dart`) existe dans le projet et semble inutilisé | La recherche de pays, elle, utilise `Autocomplete` — incohérence interne | Brancher `cities.dart` sur le champ d'ajout de ville pour réduire doublons/fautes de frappe | Moyenne | Faible |

### 3.3 Performance

| Constat | Recommandation | Priorité | Effort |
|---|---|---|---|
| ~188 tracés SVG reparsés de façon synchrone à chaque montage de `WorldMapWidget` | Parser une seule fois au démarrage et mettre en cache statique | Moyenne | Faible |
| Détection de survol de la carte : boucle sur tous les tracés à chaque mouvement de souris, sans structure d'accélération spatiale | Ajouter un index spatial (bounding boxes) si la carte se complexifie (villes, régions) | Basse | Moyen |
| Cache local Hive-first avec sync Firestore en tâche de fond | Bonne pratique à conserver et à mettre en avant comme argument produit ("fonctionne hors connexion") | — | — |
| Stream Firestore sur toute la collection `countries` par utilisateur | Adapté à l'échelle actuelle (~200 pays max) ; à surveiller si des entrées de journal plus lourdes (photos, texte) sont ajoutées au même modèle | Basse | — |

### 3.4 Sécurité

| Constat | Recommandation | Priorité | Effort |
|---|---|---|---|
| `firestore.rules` non fourni à ce jour — impossible de garantir l'isolation des données par utilisateur | **À vérifier en priorité absolue** avant toute autre action | Haute | Faible (vérification) |
| Clés Firebase en clair dans `firebase_options.dart`, committées sur repo public | Normal pour des clés client Firebase, mais à sécuriser via restrictions Google Cloud Console (référent HTTP web, package+SHA-1 Android) et envisager Firebase App Check | Haute | Moyen |
| `reverse_geocode_service.dart` envoie les coordonnées GPS précises à un service tiers (`api.bigdatacloud.net`) sans mention nulle part dans l'app | Ajouter une mention explicite dans une politique de confidentialité / au premier usage de la géolocalisation | Moyenne | Faible |
| Données locales Hive stockées en clair (pas de box chiffrée) | Chiffrer la box Hive pour les données de géolocalisation/historique | Basse | Faible |
| `debugPrint` utilisé pour les erreurs, aucun outil de monitoring en production | Intégrer Firebase Crashlytics ou équivalent | Moyenne | Faible |
| Migration locale → cloud déclenchée sur "cloud vide + local non vide", sans distinction entre "jamais synchronisé" et "vidé volontairement" | Ajouter un flag serveur explicite de migration déjà effectuée | Basse | Faible |

### 3.5 Thèmes, couleurs, identité visuelle

La palette actuelle (fond `#0B1121`, accents Tailwind emerald/blue/amber) est propre et professionnelle mais **générique** : c'est littéralement la palette par défaut de Tailwind CSS, pas une direction de marque assumée. Pour un produit qui se positionne sur le voyage et le souvenir personnel, deux directions honnêtes sont possibles : soit assumer pleinement l'esthétique "dashboard de données de voyage" (cohérent avec le positionnement country-tracker réel du produit), soit évoluer vers une palette plus évocatrice (tons terre/sable/ocre/teal) si l'ambition est de se rapprocher du carnet de voyage narratif façon Polarsteps. Le choix doit être fait consciemment, pas hérité par défaut du framework.

L'absence de mode clair est le point le plus faible de cet axe : c'est un standard du secteur, pas un bonus.

### 3.6 Architecture produit et fonctionnalités

Voir le tableau roadmap ci-dessous.

---

## 4. Roadmap synthétique

| Catégorie | Éléments |
|---|---|
| **Garder** | Pairing typographique Fraunces/Outfit · Cache Hive + sync Firestore en tâche de fond · Gestion nuancée des territoires non reconnus (ex. Somaliland) · Concept de carte interactive avec hover · Infrastructure i18n fr/en/es (complète pour les clés existantes) |
| **Améliorer** | Vérifier/durcir `firestore.rules` et les restrictions de clés API · Compléter les traductions manquantes (`geo_panel`, bottom sheet d'ajout) · Messages d'erreur utilisateur (auth, géolocalisation) · Performance du parsing de la carte · Accessibilité de la carte (lecteur d'écran) · Contraste du statut redlist · Chiffrement du cache local · Monitoring d'erreurs en production |
| **Supprimer/repenser** | Blocage total de l'app derrière la connexion Google alors que le mode invité existe déjà dans le code · Promesse UI non tenue ("personnalisation des couleurs bientôt disponible") tant qu'elle n'est pas planifiée |
| **Ajouter** | Mode clair / bascule de thème · Contenu narratif dans le journal (note libre a minima, photo en V2 via Firebase Storage déjà configuré) · Autocomplétion des villes en s'appuyant sur `cities.dart` déjà présent dans le projet · Onboarding léger (état vide pédagogique) · Granularité région/ville sur la carte à moyen terme (axe de différenciation chez Been) |

---

## 5. Benchmark comparatif

**Been** (leader du segment country-tracker, 3M+ utilisateurs revendiqués) — Points forts salués par les utilisateurs : prise en main immédiate sans tutoriel, granularité jusqu'aux régions/provinces dans 50+ pays, mode clair et sombre sur toutes les vues, "passeport" de voyage partageable, mode invité avec sync optionnelle. Points de friction récurrents : fonctionnalités avancées (régions, notes privées, vue 3D) payantes, données parfois erronées sur les territoires disputés, bugs occasionnels après mise à jour. → Atlas est structurellement proche de Been (même segment) mais en retard sur mode clair, granularité et absence de barrière de connexion.

**Visited / VoyageX** — Différenciateurs : choix de projection cartographique (Mercator/équirectangulaire), gestion fine de la souveraineté des territoires disputés, mode sombre pensé explicitement pour un usage "vol de nuit". Point faible relevé par les utilisateurs : peu de contenu photo au-delà d'une vignette. → Confirme que le mode sombre/clair est un standard imposé par le marché, pas un luxe.

**Polarsteps** (10M+ utilisateurs revendiqués, référence du carnet de voyage narratif) — Points forts unanimement cités : cartographie automatique du trajet par GPS, photos et notes par étape, trois niveaux de confidentialité (privé / abonnés / public), partage en temps réel avec proches, impression d'un livre de voyage physique en fin de séjour, fonctionnement hors ligne avec synchronisation différée. → C'est la référence à regarder si Atlas veut évoluer vers un vrai journal narratif : le different le plus net avec Atlas aujourd'hui est justement l'absence totale de contenu (texte/photo) par entrée.

**NomadList** — Écarté du comparatif direct : positionnement différent (guide de données de villes pour nomades numériques + communauté sociale), pas un tracker de pays visités à proprement parler. Mentionné pour mémoire mais non pertinent comme référence produit pour Atlas.

---

## 6. Annexe — sources utilisées

- Avis et fiches produit Been : App Store (been: track visited countries, been: countries visited map, been — travel map & tracker), Google Play, site officiel been.app, MWM.ai
- Avis et fiches produit Visited / VoyageX : App Store (Visited: Travel Tracker & Map, VoyageX — Visited Countries)
- Avis et fiches produit Polarsteps : App Store, Google Play, Product Hunt, Trustpilot, wandrly.app
- Fiche et avis NomadList : Product Hunt, Trustpilot (écarté du benchmark final, cité pour transparence de la recherche)
- Code source du dépôt `fnnktkygl-code/atlas-travel-diary` fourni directement (18 fichiers Dart : providers, écrans, widgets, services, thème, données, i18n) — `firestore.rules` non fourni, seule pièce manquante pour clore l'axe sécurité
