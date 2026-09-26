# ProcheAidant+ pour Netlify

Application React/Vite avec connexion réelle, base de données et stockage privé Supabase.

## 1. Créer le backend Supabase

1. Créez un projet Supabase.
2. Ouvrez **SQL Editor** et exécutez `supabase/schema.sql`.
3. Dans **Authentication > URL Configuration**, ajoutez votre adresse Netlify dans **Site URL** et **Redirect URLs**.
4. Récupérez **Project URL** et la clé publique **anon/publishable**.

Ne placez jamais la clé `service_role` dans cette application.

## 2. Tester localement

```bash
cp .env.example .env
npm install
npm run dev
```

Remplissez `.env` avec :

```env
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

## 3. Déployer sur Netlify

1. Poussez le dossier dans un dépôt GitHub.
2. Dans Netlify, choisissez **Add new project > Import an existing project**.
3. Sélectionnez le dépôt.
4. Ajoutez les deux variables dans **Environment variables**.
5. Déployez. `netlify.toml` contient déjà la commande `npm run build`, le dossier `dist` et la redirection SPA.

## Fonctions incluses

- Création de compte, connexion, déconnexion et récupération du mot de passe
- Profil administratif persistant
- Création, modification d’état et suppression des démarches
- Alertes avec dates
- Téléversement, consultation par lien temporaire et suppression de documents privés
- Sécurité RLS pour isoler les données de chaque compte
- Interface responsive

## Important

Cette base est fonctionnelle, mais une mise en production traitant des renseignements médicaux ou fiscaux exige une analyse juridique, une politique de confidentialité, une gestion du consentement, des sauvegardes, de la journalisation et des tests de sécurité.

## Connexion Google

1. Dans Google Cloud, créez ou sélectionnez un projet et configurez l’écran de consentement OAuth.
2. Créez un client OAuth de type **Web application**.
3. Dans Supabase, ouvrez **Authentication > Providers > Google**, copiez l’URL de rappel fournie et ajoutez-la aux URI de redirection autorisés dans Google Cloud.
4. Copiez le Client ID et le Client Secret Google dans le fournisseur Google de Supabase, puis activez-le.
5. Ajoutez le domaine Netlify dans la configuration des URL de Supabase et dans les domaines autorisés de Google.

La politique de confidentialité contient des valeurs configurables dans `.env` : `VITE_PRIVACY_EMAIL` et `VITE_LEGAL_NAME`. Faites valider et personnaliser la politique avant le lancement.
