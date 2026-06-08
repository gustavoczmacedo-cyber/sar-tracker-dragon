#!/bin/bash

echo "======================================"
echo "  Provisionando FIWARE Dragon System  "
echo "======================================"

BASE_URL="http://localhost:4041"
HEADERS='-H "Content-Type: application/json" -H "fiware-service: spacex" -H "fiware-servicepath: /dragon"'

echo ""
echo "⏳ Aguardando IoT Agent ficar pronto..."
sleep 5

echo ""
echo "📦 Criando Service Group..."
curl -s -o /dev/null -w "Status: %{http_code}\n" -X POST "$BASE_URL/iot/services" \
  -H "Content-Type: application/json" \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" \
  -d '{
    "services": [{
      "apikey": "dragon2026",
      "cbroker": "http://orion:1026",
      "entity_type": "DragonCapsule",
      "resource": "/iot/json"
    }]
  }'

echo ""
echo "🛸 Registrando Dispositivo Dragon Capsule..."
curl -s -o /dev/null -w "Status: %{http_code}\n" -X POST "$BASE_URL/iot/devices" \
  -H "Content-Type: application/json" \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" \
  -d '{
    "devices": [{
      "device_id": "dragon_capsule_01",
      "entity_name": "urn:ngsi-ld:DragonCapsule:001",
      "entity_type": "DragonCapsule",
      "protocol": "PDI-IoTA-JSON",
      "transport": "MQTT",
      "attributes": [
        {"object_id": "temperature", "name": "temperature", "type": "Number"},
        {"object_id": "oxygen",      "name": "oxygen",      "type": "Number"},
        {"object_id": "docking_distance", "name": "docking_distance", "type": "Number"},
        {"object_id": "radiation",   "name": "radiation",   "type": "Number"}
      ]
    }]
  }'

echo ""
echo "📡 Criando Subscription no Orion para STH-Comet..."
curl -s -o /dev/null -w "Status: %{http_code}\n" -X POST "http://localhost:1026/v2/subscriptions" \
  -H "Content-Type: application/json" \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" \
  -d '{
    "description": "Subscription para STH-Comet",
    "subject": {
      "entities": [{"idPattern": ".*", "type": "DragonCapsule"}],
      "condition": {"attrs": ["temperature","oxygen","docking_distance","radiation"]}
    },
    "notification": {
      "http": {"url": "http://sth-comet:8666/notify"},
      "attrs": ["temperature","oxygen","docking_distance","radiation"],
      "attrsFormat": "legacy"
    },
    "throttling": 5
  }'

echo ""
echo "======================================"
echo "  ✅ Provisionamento concluído!"
echo "======================================"
