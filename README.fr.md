# Batteries

Complications Apple Watch façon widget Batteries d'iOS : montre, iPhone, AirPods et boîtier.

- **Circulaire / coin / inline** : un appareil au choix (Apple Watch, iPhone, AirPods, boîtier).
- **Rectangulaire** : jusqu'à 4 anneaux, comme le widget iPhone.

## Fonctionnement

| Source | Lecture |
|---|---|
| Apple Watch | `WKInterfaceDevice`, directement sur la montre |
| iPhone | `UIDevice`, dans l'app iPhone, envoyé via `WatchConnectivity` |
| AirPods et accessoires | IOKit `IOPSCopyPowerSourcesByType` (API privée chargée par `dlopen`), dans l'app iPhone |

Les valeurs de l'iPhone se rafraîchissent au mieux toutes les ~15 min : iOS décide quand l'app tourne en arrière-plan. Ouvrir l'app sur la montre force une mise à jour.

L'API privée interdit l'App Store et TestFlight : l'app s'installe en **Ad Hoc** (ou en développement).

## Prérequis

- Compte Apple Developer payant.
- Un dépôt GitHub (le build tourne sur un runner macOS de GitHub Actions).

## Mise en place (une fois)

1. **Appareils** : sur [developer.apple.com](https://developer.apple.com/account/resources/devices/list), enregistrer l'UDID de l'iPhone **et** celui de la montre.
2. **Clé API** : App Store Connect → Utilisateurs et accès → Intégrations → clé avec le rôle **Admin**. Noter le Key ID, l'Issuer ID et télécharger le `.p8`.
3. **Certificat de développement**, depuis Git Bash sous Windows :
   ```sh
   openssl req -new -newkey rsa:2048 -nodes -keyout dev.key -out dev.csr -subj "/CN=Batteries"
   ```
   Envoyer `dev.csr` dans Certificates → Apple Development, télécharger `development.cer`, puis :
   ```sh
   openssl x509 -inform der -in development.cer -out dev.pem
   openssl pkcs12 -export -legacy -inkey dev.key -in dev.pem -out dev.p12
   ```
4. **Secrets GitHub** (Settings → Secrets and variables → Actions) :

   | Nom | Valeur |
   |---|---|
   | `APPLE_TEAM_ID` | Team ID (10 caractères) |
   | `ASC_KEY_ID` | Key ID de la clé API |
   | `ASC_ISSUER_ID` | Issuer ID |
   | `ASC_KEY_P8` | `base64 -w0 AuthKey_XXXX.p8` |
   | `DEV_CERT_P12` | `base64 -w0 dev.p12` |
   | `DEV_CERT_PASSWORD` | mot de passe du `.p12` |

   Variable `BUNDLE_ID_PREFIX` : un préfixe à toi, ex. `com.tonpseudo`.

## Build et installation

1. Actions → **Build** → *Run workflow* (`release-testing` = Ad Hoc).
2. Télécharger l'artefact `Batteries` (`.ipa`).
3. Installer l'`.ipa` sur l'iPhone depuis Windows (Sideloadly en mode sans re-signature, ou iMazing).
4. App Watch sur l'iPhone → Batteries → **Installer**.
5. Ouvrir l'app une fois sur l'iPhone et une fois sur la montre, puis ajouter la complication en modifiant le cadran.

Chaque push lance aussi une compilation sans signature, pour vérifier le code.

## Calibrage des AirPods

L'écran de l'app iPhone liste les **sources détectées** avec leurs clés brutes : c'est ce qui sert à reconnaître écouteurs et boîtier. Si les AirPods sont mal classés, ces informations permettent d'ajuster `PowerSourceReader`.
