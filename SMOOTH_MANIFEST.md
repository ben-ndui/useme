# SMOOTH_MANIFEST.md

## Projet
- Nom: useme (UZME)
- Type: mobile (iOS, Android, macOS, Web)
- Client: Smooth & Design (produit interne)
- Statut: actif

## Stack
- Frontend: Flutter 3.9+ / Dart
- Backend: Firebase (Firestore, Cloud Functions, Storage, Messaging)
- Auth: Firebase Auth (Email, Google Sign-In, Apple Sign-In)
- Base de données: Cloud Firestore
- Autres:
  - Stripe (paiements, abonnements)
  - Google Maps / Geolocator (géolocalisation studios)
  - PDF generation (confirmations de sessions)
  - Deep Links (app_links)
  - Chiffrement (encrypt, crypto, flutter_secure_storage)
  - Notifications push (Firebase Messaging, flutter_local_notifications)
  - i18n / l10n (intl, flutter_localizations)
  - FVM (gestion version Flutter)
  - smoothandesign_package (package métier partagé, chemin local)

## Features implémentées
- Réservation de sessions studio (booking complet avec calendrier)
- Gestion des artistes (profils, favoris, contacts)
- Gestion des studios (profils, salles, services, revendication)
- Gestion des ingénieurs son (disponibilités, propositions)
- Système de paiement Stripe (configuration, abonnements par tier)
- Chat assistant IA (conversation, réponses locales)
- Découverte de studios (recherche géolocalisée, carte)
- Gestion d'équipe et invitations
- Onboarding multi-étapes
- Notifications push et navigation contextuelle
- Génération PDF (confirmations de session)
- Système de favoris
- Gestion des indisponibilités / time off
- Service de blocage/report utilisateurs
- Partage social (share_plus)
- Calendrier intégré (table_calendar)
- Graphiques / analytics (fl_chart)
- Carousel d'images
- Multi-compte (recent accounts)

## Patterns notables
- Architecture: Feature-first + Clean Architecture (core/blocs, core/models, core/services, core/data, screens/, widgets/, routing/, config/)
- State Management: BLoC (flutter_bloc) avec barrel exports
- DI: get_it
- Routing: go_router
- Collections Firestore: users, artists, bookings, sessions, studios, studio_rooms, studio_services, favorites, invitations, studio_claims, payment_methods, stripe_config, subscription_tier_config, time_off, user_contacts, pro_profiles, discovered_studios, engineer_availability
- Conventions de nommage: snake_case pour fichiers, PascalCase pour classes, préfixe "smooth" pour le package partagé

## Réutilisabilité
- Snippets clés:
  - BLoC pattern complet (artist, booking, calendar, session, favorite, map, network, onboarding, pro_profile, service, studio_room, engineer_availability, locale)
  - Service d'encryption (encryption_service.dart)
  - Service de deep links (deep_link_service.dart)
  - Service de notifications push complet
  - Service Stripe complet (config, paiements, abonnements)
  - Chat assistant IA (conversation_service, local_response_helper)
  - smoothandesign_package — logique métier partagée entre projets
  - Build script iOS (build_ios.sh)
