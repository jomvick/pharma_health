# PharmacyManager BF 🏥

Système de Gestion de Pharmacie Fullstack (NestJS + Flutter + Next.js).

## 🚀 Structure du Projet

- `backend/` : API REST (NestJS + MongoDB)
- `PharmaPOS-main/` : Application Mobile Terminal de Vente (Flutter)
- *(À venir)* `client-web/` : Interface de vente Web (Next.js)
- *(À venir)* `panel-admin/` : Administration & Rapports (Next.js)

---

## 🛠️ Installation et Lancement

### 1. Configuration du Backend (NestJS)

1.  Allez dans le dossier backend : `cd backend`
2.  Installez les dépendances : `npm install`
3.  Vérifiez le fichier `.env` (ex: `JWT_SECRET`, `MONGO_URI`, `ALLOWED_ORIGINS`).
4.  Lancez le serveur : `npm run dev`
    - L'API sera sur `http://localhost:5000/api`
    - Swagger : `http://localhost:5000/api/docs`

### 2. Configuration du Mobile (Flutter)

1.  Allez dans le dossier mobile : `cd PharmaPOS-main`
2.  Installez les dépendances : `flutter pub get`
3.  Vérifiez le fichier `lib/.env` :
    - Pour émulateur Android : `API_URL=http://10.0.2.2:5000/api`
    - Pour iOS/Web/Physique : utilisez votre IP locale (`http://192.168.x.x:5000/api`)
4.  Lancez l'application : `flutter run`

### 3. Base de données (MongoDB)

Pour que l'équipe puisse travailler, il y a deux options pour la base de données :

- **Option A : Locale (Individuelle)**
    Chaque membre installe MongoDB localement sur sa machine.
    URL dans `.env` : `MONGO_URI=mongodb://localhost:27017/pharmaci`

- **Option B : Cloud (Partagée - Recommandée pour l'équipe)**
    Utilisez **MongoDB Atlas** (Cluster gratuit). 
    1. Créez un projet sur MongoDB Atlas.
    2. Autorisez les adresses IP (0.0.0.0/0 pour les tests).
    3. Copiez le lien de connexion et remplacez-le dans le fichier `.env`.
    URL dans `.env` : `MONGO_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net/pharmaci`

---

## 🔒 Authentification

Le système utilise des tokens **JWT**.
- Le backend valide les rôles : `Admin`, `Pharmacien`, `Caissier`.
- Le mobile stocke le token de manière sécurisée via `FlutterSecureStorage`.

---


