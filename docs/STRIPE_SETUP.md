# Configuration Stripe - Use Me

Ce document détaille la configuration complète de Stripe pour les abonnements Use Me.

---

## 1. Produits à Créer dans Stripe Dashboard

### Produit 1: Use Me Pro

| Champ | Valeur |
|-------|--------|
| **Nom** | Use Me Pro |
| **Description** | Abonnement Pro pour studios - Sessions illimitées, analytics, visibilité Discovery |
| **Image** | Logo Use Me (optionnel) |
| **Métadonnées** | `tier_id: pro` |

**Prix à créer pour ce produit:**

| ID suggéré | Type | Montant | Devise | Période |
|------------|------|---------|--------|---------|
| `price_pro_monthly` | Récurrent | 19,00 € | EUR | Mensuel |
| `price_pro_yearly` | Récurrent | 190,00 € | EUR | Annuel |

> 💡 L'annuel = 10 mois payés (2 mois offerts)

---

### Produit 2: Use Me Enterprise

| Champ | Valeur |
|-------|--------|
| **Nom** | Use Me Enterprise |
| **Description** | Abonnement Enterprise pour grands studios - Tout illimité, multi-studios, API, support prioritaire |
| **Image** | Logo Use Me (optionnel) |
| **Métadonnées** | `tier_id: enterprise` |

**Prix à créer pour ce produit:**

| ID suggéré | Type | Montant | Devise | Période |
|------------|------|---------|--------|---------|
| `price_enterprise_monthly` | Récurrent | 79,00 € | EUR | Mensuel |
| `price_enterprise_yearly` | Récurrent | 790,00 € | EUR | Annuel |

> 💡 L'annuel = 10 mois payés (2 mois offerts)

---

## 2. Configuration Webhook

### URL du Webhook
```
https://us-central1-smoothandesign.cloudfunctions.net/api/stripe/webhook
```

### Events à écouter

| Event | Description |
|-------|-------------|
| `customer.subscription.created` | Nouvel abonnement créé |
| `customer.subscription.updated` | Abonnement modifié (upgrade/downgrade) |
| `customer.subscription.deleted` | Abonnement annulé |
| `invoice.payment_failed` | Paiement échoué |
| `invoice.paid` | Facture payée avec succès |
| `checkout.session.completed` | Session checkout terminée |

### Récupérer le Webhook Secret
Après création, copier le `whsec_xxx` pour le configurer dans l'app.

---

## 3. Configuration dans Use Me (DevMaster)

### Accès
1. Se connecter avec un compte DevMaster
2. Aller dans **Admin > Configuration Stripe** (`/admin/stripe-config`)

### Champs à configurer

| Champ | Exemple | Description |
|-------|---------|-------------|
| **Publishable Key** | `pk_live_xxx` | Clé publique Stripe |
| **Secret Key** | `sk_live_xxx` | Clé secrète (sera cryptée AES-256) |
| **Webhook Secret** | `whsec_xxx` | Secret du webhook (sera crypté) |
| **Mode** | `live` / `test` | Environnement Stripe |

### Price IDs à configurer

| Clé | Valeur (exemple) |
|-----|------------------|
| `pro_monthly` | `price_1QxxxProMonthly` |
| `pro_yearly` | `price_1QxxxProYearly` |
| `enterprise_monthly` | `price_1QxxxEntMonthly` |
| `enterprise_yearly` | `price_1QxxxEntYearly` |

---

## 4. Firestore - Structure des données

### Collection `app_config/stripe`
```json
{
  "publishableKey": "pk_live_xxx",
  "encryptedSecretKey": "encrypted_base64...",
  "encryptedWebhookSecret": "encrypted_base64...",
  "isLiveMode": true,
  "priceIds": {
    "pro_monthly": "price_xxx",
    "pro_yearly": "price_xxx",
    "enterprise_monthly": "price_xxx",
    "enterprise_yearly": "price_xxx"
  },
  "updatedAt": "2024-01-15T10:30:00Z",
  "updatedBy": "userId_devmaster"
}
```

### Collection `subscription_tiers`
```json
// Document: free
{
  "id": "free",
  "name": "Free",
  "description": "Pour démarrer",
  "priceMonthly": 0,
  "priceYearly": 0,
  "maxSessions": 20,
  "maxRooms": 3,
  "maxServices": 5,
  "maxEngineers": 3,
  "hasDiscoveryVisibility": false,
  "hasAnalytics": false,
  "hasVerifiedBadge": false,
  "isActive": true,
  "sortOrder": 0
}

// Document: pro
{
  "id": "pro",
  "name": "Pro",
  "description": "Pour les studios actifs",
  "priceMonthly": 19,
  "priceYearly": 190,
  "maxSessions": -1,
  "maxRooms": 10,
  "maxServices": -1,
  "maxEngineers": 10,
  "hasDiscoveryVisibility": true,
  "hasAnalytics": true,
  "hasVerifiedBadge": true,
  "isActive": true,
  "sortOrder": 1
}

// Document: enterprise
{
  "id": "enterprise",
  "name": "Enterprise",
  "description": "Pour les grands studios",
  "priceMonthly": 79,
  "priceYearly": 790,
  "maxSessions": -1,
  "maxRooms": -1,
  "maxServices": -1,
  "maxEngineers": -1,
  "hasDiscoveryVisibility": true,
  "hasAnalytics": true,
  "hasAdvancedAnalytics": true,
  "hasMultiStudios": true,
  "hasApiAccess": true,
  "hasPrioritySupport": true,
  "hasVerifiedBadge": true,
  "isActive": true,
  "sortOrder": 2
}
```

### Champ `subscription` dans `users/{userId}`
```json
{
  "subscription": {
    "tierId": "pro",
    "startedAt": "2024-01-15T10:30:00Z",
    "expiresAt": null,
    "stripeSubscriptionId": "sub_xxx",
    "stripeCustomerId": "cus_xxx",
    "sessionsThisMonth": 5,
    "sessionsResetAt": "2024-02-01T00:00:00Z"
  }
}
```

---

## 5. Checklist de Configuration

### Stripe Dashboard
- [ ] Créer le produit "Use Me Pro"
- [ ] Créer le prix mensuel Pro (19€)
- [ ] Créer le prix annuel Pro (190€)
- [ ] Créer le produit "Use Me Enterprise"
- [ ] Créer le prix mensuel Enterprise (79€)
- [ ] Créer le prix annuel Enterprise (790€)
- [ ] Configurer le webhook avec l'URL
- [ ] Ajouter les events à écouter
- [ ] Copier le Webhook Secret

### Firestore
- [ ] Créer les documents dans `subscription_tiers` (free, pro, enterprise)
- [ ] Vérifier les règles de sécurité

### Use Me App (DevMaster)
- [ ] Accéder à `/admin/stripe-config`
- [ ] Entrer la Publishable Key
- [ ] Entrer la Secret Key
- [ ] Entrer le Webhook Secret
- [ ] Configurer les Price IDs

### Test
- [ ] Tester un checkout Pro mensuel (mode test)
- [ ] Vérifier que l'abonnement est créé dans Firestore
- [ ] Tester l'annulation
- [ ] Tester le Customer Portal
- [ ] Passer en mode Live

---

## 6. URLs de Redirection

| Type | URL |
|------|-----|
| **Success** | `useme://subscription/success` |
| **Cancel** | `useme://subscription/cancel` |

Ces URLs utilisent le deep linking de l'app. Configurer dans:
- iOS: `Info.plist` → URL Schemes
- Android: `AndroidManifest.xml` → Intent filters

---

## 7. Support Multi-Devises (Future)

Pour supporter d'autres devises (USD, GBP, etc.):
1. Créer des prix supplémentaires pour chaque produit
2. Ajouter les Price IDs dans la config
3. Modifier le backend pour sélectionner le bon prix selon la locale

Exemple de priceIds étendu:
```json
{
  "pro_monthly_eur": "price_xxx",
  "pro_monthly_usd": "price_yyy",
  "pro_yearly_eur": "price_xxx",
  "pro_yearly_usd": "price_yyy"
}
```
