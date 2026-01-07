# AI Assistant Tools Roadmap

Documentation des tools disponibles et prévus pour l'assistant IA de Use Me.

## Tools Existants

### Lecture (tous rôles)
| Tool | Description | Rôles |
|------|-------------|-------|
| `get_sessions` | Récupérer les sessions (filtres: status, date) | Tous |
| `get_session_details` | Détails d'une session spécifique | Tous |
| `get_availability` | Vérifier les créneaux disponibles | Tous |

### Lecture (Studio)
| Tool | Description |
|------|-------------|
| `get_pending_requests` | Demandes de réservation en attente |
| `get_services` | Liste des services du studio |
| `get_team` | Liste des ingénieurs de l'équipe |
| `get_studio_stats` | Statistiques (sessions, revenus) |
| `search_artists` | Rechercher des artistes |

### Lecture (Artiste)
| Tool | Description |
|------|-------------|
| `search_studios` | Rechercher des studios par nom/ville |

### Lecture (Ingénieur)
| Tool | Description |
|------|-------------|
| `get_time_off` | Voir ses indisponibilités |

### Actions (Studio)
| Tool | Description |
|------|-------------|
| `accept_booking` | Accepter une demande de réservation |
| `decline_booking` | Refuser une demande |
| `create_service` | Créer un nouveau service |
| `update_service` | Modifier un service existant |
| `cancel_session` | Annuler une session |
| `assign_engineer` | Assigner un ingénieur à une session |
| `create_session` | Créer une session manuellement |

### Actions (Artiste)
| Tool | Description |
|------|-------------|
| `create_booking_request` | Demander une réservation |
| `cancel_booking` | Annuler sa demande en attente |
| `add_favorite` | Ajouter un studio aux favoris |
| `remove_favorite` | Retirer un studio des favoris |

### Actions (Ingénieur)
| Tool | Description |
|------|-------------|
| `start_session` | Démarrer une session confirmée |
| `complete_session` | Terminer une session en cours |
| `add_time_off` | Ajouter une indisponibilité |
| `remove_time_off` | Supprimer une indisponibilité |

---

## Nouveaux Tools - Haute Priorité

### `send_message`
- **Rôles**: Tous
- **Description**: Envoyer un message à un artiste/studio
- **Paramètres**:
  - `recipient_id` (string): ID du destinataire
  - `message` (string): Contenu du message
- **Retour**: `{success: true, messageId: string}`
- **Status**: ✅ Implémenté

### `get_conversations`
- **Rôles**: Tous
- **Description**: Voir les conversations récentes
- **Paramètres**:
  - `limit` (number, optional): Nombre max (défaut: 10)
- **Retour**: `{conversations: [{id, participantName, lastMessage, unreadCount}]}`
- **Status**: ✅ Implémenté

### `reschedule_session`
- **Rôles**: Studio
- **Description**: Reprogrammer une session à une nouvelle date/heure
- **Paramètres**:
  - `session_id` (string): ID de la session
  - `new_date` (string): Nouvelle date (YYYY-MM-DD)
  - `new_start_time` (string): Nouvelle heure de début (HH:MM)
  - `notify_artist` (boolean, optional): Notifier l'artiste (défaut: true)
- **Retour**: `{success: true, session: {...}}`
- **Status**: ✅ Implémenté

### `get_revenue_report`
- **Rôles**: Studio
- **Description**: Rapport de revenus détaillé
- **Paramètres**:
  - `period` (string): "week", "month", "year", "all"
  - `group_by` (string, optional): "service", "engineer", "day"
- **Retour**: `{totalRevenue, sessionsCount, breakdown: [...]}`
- **Status**: ✅ Implémenté

### `add_studio_unavailability`
- **Rôles**: Studio
- **Description**: Bloquer des créneaux (fermeture exceptionnelle)
- **Paramètres**:
  - `start_date` (string): Date de début (YYYY-MM-DD)
  - `end_date` (string): Date de fin (YYYY-MM-DD)
  - `reason` (string, optional): Raison
- **Retour**: `{success: true, unavailabilityId: string}`
- **Status**: ✅ Implémenté

### `get_favorites`
- **Rôles**: Artiste
- **Description**: Liste des studios favoris avec leurs infos
- **Paramètres**: Aucun
- **Retour**: `{favorites: [{studioId, name, city, rating, servicesCount}]}`
- **Status**: ✅ Implémenté

### `respond_to_proposal`
- **Rôles**: Ingénieur
- **Description**: Accepter ou refuser une proposition de session
- **Paramètres**:
  - `session_id` (string): ID de la session
  - `accept` (boolean): true pour accepter, false pour refuser
  - `reason` (string, optional): Raison du refus
- **Retour**: `{success: true, status: "accepted" | "declined"}`
- **Status**: ✅ Implémenté

---

## Nouveaux Tools - Moyenne Priorité

### `update_studio_profile`
- **Rôles**: Studio
- **Description**: Modifier le profil du studio
- **Status**: 🔜 À venir

### `update_working_hours`
- **Rôles**: Studio
- **Description**: Modifier les horaires d'ouverture
- **Status**: 🔜 À venir

### `invite_engineer`
- **Rôles**: Studio
- **Description**: Inviter un ingénieur par email
- **Status**: 🔜 À venir

### `remove_engineer`
- **Rôles**: Studio
- **Description**: Retirer un ingénieur de l'équipe
- **Status**: 🔜 À venir

### `get_artist_history`
- **Rôles**: Studio
- **Description**: Historique complet d'un artiste
- **Status**: 🔜 À venir

### `duplicate_service`
- **Rôles**: Studio
- **Description**: Dupliquer un service existant
- **Status**: 🔜 À venir

### `update_artist_profile`
- **Rôles**: Artiste
- **Description**: Modifier son profil
- **Status**: 🔜 À venir

### `get_studio_reviews`
- **Rôles**: Artiste
- **Description**: Voir les avis d'un studio
- **Status**: 🔜 À venir

---

## Nouveaux Tools - Avancé (Futures features)

| Tool | Rôle | Description |
|------|------|-------------|
| `generate_invoice` | Studio | Générer une facture PDF |
| `send_reminder` | Studio | Envoyer un rappel de session |
| `suggest_optimal_time` | Artiste | Suggérer le meilleur créneau |
| `get_similar_studios` | Artiste | Studios similaires à un favori |
| `export_sessions` | Tous | Exporter sessions en CSV |
| `set_auto_response` | Studio | Configurer réponse auto vacances |

---

## Format de réponse des tools

Les tools retournent des données JSON que l'AI formate avec des balises spéciales :

```
[SESSIONS_DATA]{"sessions":[...]}[/SESSIONS_DATA]
[SERVICES_DATA]{"services":[...]}[/SERVICES_DATA]
[TEAM_DATA]{"engineers":[...]}[/TEAM_DATA]
[STATS_DATA]{"totalSessions":N,"totalRevenue":N}[/STATS_DATA]
[PENDING_DATA]{"requests":[...]}[/PENDING_DATA]
[AVAILABILITY_DATA]{"slots":[...]}[/AVAILABILITY_DATA]
```

Ces balises sont parsées par le widget `AIMessageContent` dans Flutter pour afficher des cards stylées.

---

## Historique des modifications

- **2024-12-27**: Création du document, ajout des tools haute priorité
- **2024-12-27**: Implémentation des 7 tools haute priorité (send_message, get_conversations, reschedule_session, get_revenue_report, add_studio_unavailability, get_favorites, respond_to_proposal)
