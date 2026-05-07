# Refonte simple de WoodyCraft Admin

Objectif : avoir un front Flutter plus facile à comprendre, avec du code fonctionnel, lisible et rangé.

## Structure

```text
lib/
├── config/
│   └── api_config.dart          # URL de l'API
├── core/
│   ├── api_client.dart          # GET / POST / PUT / PATCH / DELETE
│   └── json_helper.dart         # conversions int, double, string, list
├── models/
│   ├── commande.dart            # modèle commande
│   ├── dashboard_resume.dart    # modèle dashboard
│   └── puzzle.dart              # modèle puzzle
├── screens/
│   ├── dashboard_screen.dart    # page statistiques
│   ├── home_screen.dart         # navigation principale
│   ├── login_screen.dart        # connexion
│   ├── register_screen.dart     # inscription
│   ├── orders_screen.dart       # liste commandes
│   ├── order_detail_screen.dart # détail commande
│   ├── puzzles_screen.dart      # liste puzzles
│   ├── puzzle_form_screen.dart  # création / modification puzzle
│   └── stocks_screen.dart       # gestion des stocks
├── services/
│   ├── auth_service.dart        # login / register
│   ├── commande_service.dart    # appels API commandes
│   ├── dashboard_service.dart   # appels API dashboard
│   └── puzzle_service.dart      # appels API puzzles
├── widgets/
│   ├── app_colors.dart          # couleurs communes
│   └── message_views.dart       # loading / erreur / vide
└── main.dart
```

## Point important : URL API

L'URL est centralisée ici :

```text
lib/config/api_config.dart
```

Par défaut :

```text
http://127.0.0.1:8080/api
```

Si ton API Laravel tourne sur le port 8000, lance Flutter comme ça :

```bash
flutter run --dart-define=API_URL=http://127.0.0.1:8000/api
```

Sur émulateur Android, `127.0.0.1` ne pointe pas vers ton PC. Utilise plutôt :

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

## Commandes à lancer

```bash
flutter clean
flutter pub get
flutter run
```

## Endpoints utilisés

```text
POST   /api/login
POST   /api/register
GET    /api/dashboard/resume
GET    /api/puzzles
POST   /api/puzzles
PUT    /api/puzzles/{id}
PATCH  /api/puzzles/{id}
DELETE /api/puzzles/{id}
GET    /api/paniers
GET    /api/paniers/{id}
PUT    /api/paniers/{id}/validate
PUT    /api/paniers/{id}/checkout
DELETE /api/paniers/{id}
```

Si un endpoint ne correspond pas à ton API, il faut modifier uniquement le service concerné dans `lib/services/`.
