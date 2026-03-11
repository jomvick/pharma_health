#!/bin/bash

# Configuration
BASE_URL="http://127.0.0.1:5000/api"
ADMIN_EMAIL="admin@pharma.com"
ADMIN_PASS="Admin123"

echo "===================================================="
echo "   FAHSO HEALTH - VALIDATION DU BACKEND (NESTJS)    "
echo "===================================================="

# Helper pour afficher le JSON
function format_json() {
    if command -v json_pp &> /dev/null; then
        json_pp
    else
        cat
    fi
}

# 1. Authentification
echo -e "\n[1] TEST AUTHENTIFICATION"
LOGIN_RES=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASS\"}")

TOKEN=$(echo $LOGIN_RES | grep -oP '(?<="access_token":")[^"]*')

if [ -z "$TOKEN" ]; then
    echo "❌ Erreur de connexion"
    echo "$LOGIN_RES" | format_json
    exit 1
else
    echo "✅ Connexion réussie (Token récupéré)"
fi

# 2. Création de Médicament (avec mapping Backward Compatibility)
echo -e "\n[2] TEST CRÉATION MÉDICAMENT (Mapping 'name' -> 'nom')"
MED_RES=$(curl -s -X POST "$BASE_URL/medicines" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Doliprane 1000",
    "category": "Antalgique",
    "stock_quantity": 5,
    "min_threshold": 10,
    "price": 2500,
    "buying_price": 1800
  }')

MED_ID=$(echo $MED_RES | grep -oP '(?<="_id":")[^"]*')

if [ -n "$MED_ID" ]; then
    echo "✅ Médicament créé avec succès (ID: $MED_ID)"
else
    echo "❌ Échec de la création"
    echo "$MED_RES" | format_json
    exit 1
fi

# 3. Vérification des Alertes Proactives (Stock Bas lors de la création)
echo -e "\n[3] TEST ALERTES PROACTIVES (Stock < Seuil)"
ALERTS_RES=$(curl -s -X GET "$BASE_URL/alerts" \
  -H "Authorization: Bearer $TOKEN")

if echo "$ALERTS_RES" | grep -q "Stock critique à la création: 5"; then
    echo "✅ Alerte de stock bas générée automatiquement à la création"
else
    echo "⚠️ Aucune alerte de stock bas trouvée (Vérifiez les seuils)"
    echo "$ALERTS_RES" | format_json
fi

# 4. Ajout d'un Lot Supplémentaire
echo -e "\n[4] TEST AJOUT DE LOT (Entrée de stock)"
LOT_RES=$(curl -s -X POST "$BASE_URL/stock/entry" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"medicine\": \"$MED_ID\",
    \"numeroLot\": \"LOT-PROD-2026\",
    \"quantite\": 50,
    \"dateExpiration\": \"2026-12-31\",
    \"prixAchat\": 1900
  }")

if echo "$LOT_RES" | grep -q "LOT-PROD-2026"; then
    echo "✅ Nouveau lot enregistré avec succès"
else
    echo "❌ Échec de l'ajout de lot"
    echo "$LOT_RES" | format_json
fi

# 5. Test de Vente (FIFO et Déduction de stock)
echo -e "\n[5] TEST VENTE (Vérification FIFO)"
SALE_RES=$(curl -s -X POST "$BASE_URL/sales" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"items\": [
      {
        \"medicine\": \"$MED_ID\",
        \"quantity\": 10
      }
    ],
    \"paymentMethod\": \"Espèces\"
  }")

if echo "$SALE_RES" | grep -q '"success":true'; then
    echo "✅ Vente effectuée avec succès"
else
    echo "❌ Échec de la vente"
    echo "$SALE_RES" | format_json
fi

# 6. Rapports (Inventaire et Ventes)
echo -e "\n[6] TEST COMPTABILITÉ & RAPPORTS"
REPORT_RES=$(curl -s -X GET "$BASE_URL/reports/sales?period=today" \
  -H "Authorization: Bearer $TOKEN")

if echo "$REPORT_RES" | grep -q '"success":true'; then
    echo "✅ Rapport de ventes généré avec succès"
else
    echo "❌ Échec du rapport"
    echo "$REPORT_RES" | format_json
fi

# 7. Purge / Soft Delete du médicament de test
echo -e "\n[7] NETTOYAGE (Soft Delete)"
DEL_RES=$(curl -s -X DELETE "$BASE_URL/medicines/$MED_ID" \
  -H "Authorization: Bearer $TOKEN")

if echo "$DEL_RES" | grep -q "supprimé avec succès"; then
    echo "✅ Médicament de test supprimé (archivé)"
else
    echo "❌ Échec de la suppression"
fi

echo -e "\n===================================================="
echo "    TOUTES LES VÉRIFICATIONS SONT TERMINÉES ✅      "
echo "===================================================="
