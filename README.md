# 🚀 Dragon Telemetry System — SAR-TRACKER

## FIAP · Global Solution 2026 · Edge Computing & Computer Systems

![FIAP](https://img.shields.io/badge/FIAP-Global%20Solution%202026-red)
![ESP32](https://img.shields.io/badge/Hardware-ESP32-blue)
![FIWARE](https://img.shields.io/badge/Backend-FIWARE-orange)
![MQTT](https://img.shields.io/badge/Protocol-MQTT-green)

---

## 👨‍💻 Integrante

| Nome | RM |
|------|-----|
| Gustavo Macedo Daniel | 567594 |

**Turma:** Engenharia de Software · 1º Ano · FIAP

---

## 📌 Descrição da Solução

Sistema de telemetria em tempo real para a cápsula **Dragon da SpaceX**, desenvolvido com **ESP32**, protocolo **MQTT** e plataforma **FIWARE** como back-end. O sistema monitora continuamente os parâmetros críticos de operação da cápsula durante toda a missão espacial, transmitindo dados à Terra e disparando alertas visuais e sonoros em caso de anomalias.

### 🎯 Problema Resolvido

Durante missões espaciais, o monitoramento contínuo de parâmetros críticos é essencial para a segurança dos tripulantes. Falhas na detecção de anomalias — como queda de oxigênio, superaquecimento ou colisão durante docking — podem ser fatais. Este sistema provê um canal de telemetria robusto, com alertas em tempo real e histórico de dados para a equipe em Terra.

---

## 🏗️ Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                      WOKWI SIMULATOR                             │
│  ESP32 + DHT22 + HC-SR04 + LDR + POT + LEDs + Buzzer            │
└──────────────────────────┬──────────────────────────────────────┘
                           │ MQTT JSON Publish
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              HiveMQ Public Broker (broker.hivemq.com)            │
│              Tópico: spacex/dragon/telemetry                     │
└──────────┬─────────────────────────────────────┬────────────────┘
           │ Subscribe (IoT Agent)                │ Subscribe (Node-RED)
           ▼                                      ▼
┌─────────────────────┐              ┌────────────────────────────┐
│   IoT Agent JSON    │              │         Node-RED            │
│  (FIWARE · :4041)   │              │  Dashboard: localhost:1880  │
└──────────┬──────────┘              │  /ui → Gauges + Charts      │
           │ NGSI v2 Update          └────────────────────────────┘
           ▼
┌─────────────────────┐
│  Orion Context      │
│  Broker (:1026)     │
└──────────┬──────────┘
           │ Subscription Notification
           ▼
┌─────────────────────┐
│   STH-Comet         │
│  (histórico :8666)  │
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│     MongoDB         │
│   (:27017)          │
└─────────────────────┘
```

---

## 📡 Sensores e Parâmetros Monitorados

| Sensor | Parâmetro | Faixa Normal | Pino ESP32 |
|--------|-----------|-------------|------------|
| DHT22 | Temperatura da Cabine (°C) | 18–30°C | GPIO 15 |
| Potenciômetro | Nível de Oxigênio (%) | 20–22% | GPIO 35 |
| HC-SR04 | Distância de Docking (cm) | > 50 cm | GPIO 5 / 18 |
| LDR | Radiação Solar (lux) | < 500 | GPIO 34 |

---

## 🚨 Lógica de Alertas

| Sensor | Normal | Atenção | Crítico |
|--------|--------|---------|---------|
| Temperatura (°C) | 18–30 | 15–18 ou 30–35 | < 15 ou > 35 |
| Oxigênio (%) | 20–22 | 19–20 ou 22–23 | < 19 ou > 23 |
| Docking (cm) | > 50 | 10–50 | < 10 |
| Radiação (lux) | < 500 | 500–800 | > 800 |

| Status | LED | Buzzer | Dashboard |
|--------|-----|--------|-----------|
| NOMINAL | 🟢 Verde | Silencioso | Verde |
| ATENÇÃO | 🟡 Amarelo | Silencioso | Amarelo |
| ALERTA CRÍTICO | 🔴 Vermelho | Ativo (1000Hz) | Vermelho |

---

## 🛠️ Tecnologias Utilizadas

- **Hardware Simulado:** ESP32 no [Wokwi](https://wokwi.com)
- **Sensores:** DHT22, HC-SR04, LDR, Potenciômetro
- **Atuadores:** LED Verde, Amarelo, Vermelho + Buzzer
- **Protocolo IoT:** MQTT via HiveMQ (broker.hivemq.com:1883)
- **Back-end:** FIWARE (Orion Context Broker + IoT Agent JSON + STH-Comet)
- **Banco de Dados:** MongoDB
- **Dashboard:** Node-RED + node-red-dashboard
- **Infraestrutura:** Docker + Docker Compose

---

## 📁 Estrutura de Arquivos

```
projeto/
├── docker-compose.yml     ← Stack FIWARE completa
├── provision.sh           ← Provisiona IoT Agent + Orion + STH-Comet
├── dragon_flow.json       ← Flow do Node-RED (dashboard)
└── README.md              ← Este arquivo
```

---

## ▶️ Como Executar

### Pré-requisitos
- Docker Desktop 24+
- Docker Compose v2
- curl
- Python3 (opcional, para visualizar JSON)

### 1. Subir a stack FIWARE

```bash
docker compose up -d
docker compose ps   # verificar se todos os containers estão "Up"
```

### 2. Provisionar o FIWARE

```bash
chmod +x provision.sh
./provision.sh
```

### 3. Configurar o Node-RED

1. Acesse: http://localhost:1880
2. Instale o pacote `node-red-dashboard` (Menu → Manage palette → Install)
3. Importe o arquivo `dragon_flow.json` (Menu → Import)
4. Clique em **Deploy**
5. Acesse o dashboard: http://localhost:1880/ui

### 4. Iniciar a Simulação

1. Abra o projeto no Wokwi: [Link do Projeto](https://wokwi.com/projects/466147520887131137)
2. Clique em **▶ Start Simulation**
3. Os dados aparecerão no dashboard em tempo real!

---

## 🔍 Verificações

```bash
# Verificar entidade no Orion
curl -s http://localhost:1026/v2/entities \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" | python3 -m json.tool

# Verificar histórico no STH-Comet (últimas 10 leituras)
curl -s "http://localhost:8666/STH/v1/contextEntities/type/DragonCapsule/id/urn:ngsi-ld:DragonCapsule:001/attributes/temperature?lastN=10" \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" | python3 -m json.tool

# Verificar dispositivos no IoT Agent
curl -s http://localhost:4041/iot/devices \
  -H "fiware-service: spacex" \
  -H "fiware-servicepath: /dragon" | python3 -m json.tool
```

---

## 🛑 Encerrar

```bash
# Para os containers (mantém dados)
docker compose stop

# Para e remove tudo
docker compose down -v
```

---

## 🌍 Conexão com ODS

Este projeto contribui para:
- **ODS 9** — Inovação e infraestrutura tecnológica espacial
- **ODS 11** — Cidades e sistemas inteligentes e seguros

---

## 🔗 Links

- 🔬 **Simulação Wokwi:** https://wokwi.com/projects/466147520887131137
- 📊 **Dashboard Node-RED:** http://localhost:1880/ui (local)
