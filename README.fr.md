# Batteries

Complications Apple Watch façon widget Batteries d'iOS : montre, iPhone, AirPods et leur boîtier, directement sur le cadran.

## Complications

| Famille | Contenu |
|---|---|
| Circulaire | Un appareil : anneau, icône et niveau |
| Coin | Un appareil : jauge courbe |
| Inline | Un appareil : icône et niveau |
| Rectangulaire | Jusqu'à 4 anneaux, comme le widget iPhone |

L'anneau passe au jaune en mode économie d'énergie, au rouge à 20 % et moins, et s'ouvre sur un éclair pendant la charge.

## Fonctionnement

| Source | Lecture |
|---|---|
| Apple Watch | `WKInterfaceDevice`, sur la montre |
| iPhone | `UIDevice`, dans l'app iPhone compagnon |
| AirPods et accessoires | Sources d'alimentation IOKit, dans l'app iPhone compagnon |

L'app iPhone envoie ses relevés à la montre via `WatchConnectivity` ; l'app montre et son extension widget les partagent via un App Group.

Les niveaux des AirPods viennent d'une API IOKit privée : l'app ne peut pas être publiée sur l'App Store et s'installe à titre personnel.

## Compilation

Le projet Xcode est généré avec [XcodeGen](https://github.com/yonaskolb/XcodeGen) :

```sh
BUNDLE_ID_PREFIX=com.example DEVELOPMENT_TEAM=XXXXXXXXXX xcodegen generate
```

Nécessite iOS 17 et watchOS 10.
