![alt text](<Capture d’écran du 2025-05-11 23-34-48.png>)

# Système de Sécurité pour Enfants

## À propos
Child Security est une application complète de surveillance et de sécurité développée avec Flutter, conçue pour aider les parents à assurer la sécurité de leurs enfants grâce à la détection par intelligence artificielle, au suivi de localisation et à du contenu éducatif.

## Objectif
L'objectif principal de cette application est d'utiliser les technologies modernes pour créer un environnement plus sûr pour les enfants en :

- Détectant les objets potentiellement dangereux à proximité de l'enfant
- Surveillant la localisation et les déplacements des enfants
- Fournissant une surveillance programmée pour des périodes spécifiques
- Éduquant les enfants sur la sécurité grâce à du contenu interactif
- Alertant les parents en cas de risques potentiels pour la sécurité

## Fonctionnalités Principales

### 1. Détection d'Objets Dangereux en Temps Réel
- Détection alimentée par l'IA d'objets potentiellement dangereux (couteaux, ciseaux, etc.)
- Seuil de confiance configurable pour la détection
- Enregistrement vidéo automatique lorsque des objets dangereux sont détectés
- Historique des alertes et capacités d'exportation

### 2. Suivi de Localisation et Géorepérage
- Surveillance en temps réel de la localisation de l'enfant
- Création de "zones de sécurité" (maison, école, etc.)
- Alertes lorsqu'un enfant entre ou quitte les zones de sécurité désignées
- Suivi de l'historique des déplacements

### 3. Contrôles Parentaux et Tableau de Bord
- Tableau de bord analytique de base
- Préférences d'alertes personnalisables
- Options avancées d'abonnement

### 4. Fonctionnalités Sociales et Communautaires
- Structure pour la connexion avec d'autres parents à proximité
- Partage d'alertes communautaires
- Possibilité de demander de l'aide à d'autres parents en cas d'urgence

## Stack Technologique
- Flutter pour le développement multiplateforme mobile
- Flutter Map pour le suivi de localisation et le géorepérage
- Flutter Local Notifications pour la gestion des alertes



## Mise en Route
1. Assurez-vous d'avoir Flutter installé sur votre machine de développement
2. Clonez ce dépôt
3. Exécutez `flutter pub get` pour installer les dépendances
4. Configurez les permissions pour la caméra et la localisation
5. Lancez l'application en utilisant `flutter run`

## Prérequis
- Flutter 3.0 ou supérieur
- iOS 11+ / Android 6.0+
- Permissions pour la caméra et la localisation
- Connexion Internet pour les fonctionnalités de carte



## Architecture de l'Application
Child Security suit une architecture modulaire qui sépare les préoccupations et favorise la maintenabilité :

### Couches Architecturales
1. **Couche de Présentation**
   - Composants UI, Écrans et Widgets
   - Gestion d'État utilisant le modèle Provider
   - Gestion de la navigation

2. **Couche Logique Métier**
   - Services pour la détection d'objets, le suivi de localisation et les notifications
   - Contrôleurs pour faire le lien entre l'UI et les couches de données
   - Traitement en arrière-plan pour la surveillance programmée


### Modèles de Conception Utilisés
- **Modèle Provider** pour la gestion d'état
- **Modèle Repository** pour l'abstraction des données
- **Modèle Factory** pour créer des services de capteurs
- **Modèle Observer** pour les notifications d'événements
- **Modèle Strategy** pour différents algorithmes de détection

## Structure du Projet
```
lib/
├── main.dart                  # Point d'entrée de l'application
├── models/                    # Modèles de données pour l'application
├── views/                     # Composants UI et écrans
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── ...
├── controllers/               # Contrôleurs de logique métier
├── services/                  # Services pour la détection d'objets, la localisation, etc.
├── repositories/              # Dépôts de données
├── utils/                     # Fonctions utilitaires et constantes
└── widgets/                   # Widgets UI réutilisables
```

## Fonctionnalités Sociales et Communautaires
- **Réseau de surveillance de quartier** : Permettre aux parents de se connecter avec d'autres parents à proximité
- **Partage d'alertes communautaires** : Notifier les autres parents d'incidents potentiels dans la zone
- **Système de support entre parents** : Possibilité de demander de l'aide à d'autres parents en cas d'urgence

## Compte Rendu d'Application

### 1. Détection d'Objets Dangereux en Temps Réel

![alt text](<Capture d’écran du 2025-05-11 20-46-45.png>)

- Détection d'objets dangereux en temps réel avec historique des alertes.


### 3. Contrôles Parentaux & Tableau de Bord

![alt text](<Capture d’écran du 2025-05-11 23-28-38.png>)

- Tableau de bord analytique avec préférences d'alerte personnalisables.

### 4. Fonctionnalités Sociales et Communautaires

![alt text](<Capture d’écran du 2025-05-11 20-47-44.png>)


![alt text](<Capture d’écran du 2025-05-11 20-48-10.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-48-27.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-48-41.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-49-09.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-49-49.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-50-03.png>) 

![alt text](<Capture d’écran du 2025-05-11 20-50-34.png>)

- Connexion avec d'autres parents et partage d'alertes communautaires.


Ce rapport d'interface utilisateur complète l'analyse fonctionnelle et permettra de mieux planifier le travail de conception et développement UI restant pour offrir une expérience utilisateur complète et cohérente.# Flutter-UI-security_child_app
