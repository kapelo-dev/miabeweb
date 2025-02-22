# miabe_pharmacie : Guide de Collaboration

Bienvenue dans le projet Flutter ! Ce guide vous aidera à démarrer avec le projet, en vous expliquant comment configurer votre environnement, travailler avec l'architecture MVVM, utiliser Firestore et interagir avec l'API GraphQL.

## Table des Matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Configuration du Projet](#configuration-du-projet)
4. [Architecture MVVM](#architecture-mvvm)
5. [Base de Données Firestore](#base-de-données-firestore)
6. [API GraphQL](#api-graphql)
7. [Contribution](#contribution)
8. [Support](#support)

## Introduction

Ce projet Flutter utilise l'architecture MVVM pour structurer le code de manière organisée et maintenable. Nous utilisons Firestore comme base de données et une API GraphQL pour certaines tâches spécifiques.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants :

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Un éditeur de code (par exemple, Visual Studio Code)
- Un compte Firebase pour accéder à Firestore

## Configuration du Projet

1. **Forker le Projet :**
   - Forker ce dépôt sur votre compte GitHub.
   - Cloner votre fork localement :
     ```bash
     git clone https://github.com/VOTRE_UTILISATEUR/miabePharmacie.git
     ```

2. **Configurer Firebase :**
   - Créer un projet Firebase sur la [console Firebase](https://console.firebase.google.com/).
   - Ajouter une application Android/iOS et suivre les instructions pour télécharger le fichier `google-services.json` ou `GoogleService-Info.plist`.
   - Placer ce fichier dans le répertoire `android/app` ou `ios/Runner` respectivement.

3. **Installer les Dépendances :**
   - Exécuter `flutter pub get` pour installer les dépendances nécessaires.

## Architecture MVVM

Le projet suit l'architecture MVVM (Model-View-ViewModel) pour séparer les préoccupations et rendre le code plus testable et maintenable. Voici une brève description des composants :

- **Model :** Représente les données et la logique métier.
- **View :** Représente l'interface utilisateur.
- **ViewModel :** Gère l'état de l'interface utilisateur et interagit avec le modèle.

## Base de Données Firestore

Firestore est déjà configuré dans le projet. Vous pouvez interagir avec la base de données en utilisant les services définis dans le répertoire `lib/services`.

- **Ajouter des Données :** Utilisez les méthodes fournies pour ajouter des documents à Firestore.
- **Lire des Données :** Utilisez les méthodes de lecture pour récupérer des documents ou des collections.

## API GraphQL

L'API GraphQL sert de pont entre l'application et Firestore pour certaines tâches spécifiques. Vous pouvez trouver les requêtes GraphQL dans le répertoire `lib/graphql`.

- **Requêtes :** Utilisez les requêtes définies pour interagir avec l'API.
- **Mutations :** Utilisez les mutations pour modifier les données.

## Contribution

1. **Créer une Branche :**
   - Créer une nouvelle branche pour votre fonctionnalité ou correction de bug :
     ```bash
     git checkout -b nom-de-la-branche
     ```

2. **Développer :**
   - Implémentez votre fonctionnalité ou correction.
   - Assurez-vous de suivre les bonnes pratiques de codage et d'ajouter des tests si nécessaire.

3. **Commit :**
   - Faire des commits avec des messages clairs et concis.

4. **Pull Request :**
   - Pousser votre branche vers votre fork :
     ```bash
     git push origin nom-de-la-branche
     ```
   - Ouvrir une pull request vers le dépôt principal.

## Support

Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à ouvrir une issue ou à contacter l'équipe de développement.

---

Merci de contribuer à ce projet ! Votre aide est précieuse pour améliorer et faire évoluer cette application.
