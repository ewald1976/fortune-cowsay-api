# 🐮 Fortune Cowsay API

Eine charmante kleine REST-API auf Basis von **Lumen + PHP 8.3** unter **Debian 13 (Trixie)**.  
Sie liefert wahlweise klassische `fortune`-Zitate oder `cowsay`-Ausgaben im JSON-Format —  
ideal für Home Assistant, Bots oder einfach als tägliche Portion Nerd-Humor 😄

---

## 🚀 Features

- 🐄 **/api/quote** – gibt zufällige Cowsay- oder Fortune-Texte als JSON zurück  
- 📜 **/api/categories** – listet verfügbare Fortune-Datenbanken auf  
- ❤️ **/api/health** – Health-Check-Endpoint  
- 🌍 Deutsche und englische Fortune-Sammlungen (Debian-Pakete)  
- 🧩 Sauber gekapselt in einem Docker-Container mit Nginx + PHP-FPM + Supervisor  
- 🔧 Multi-Arch-Builds (amd64 & arm64)  
- 🧠 Optionale Swagger-UI unter `/docs`  

---

## 🧰 Verwendung

### Direkt per Docker

```bash
docker run -d -p 8080:8080 ewald1976/fortune-cowsay-api:latest
```

Dann:

```bash
curl -X POST http://localhost:8080/api/quote   -H "Content-Type: application/json"   -d '{"mode":"cowsay"}'
```

### Beispiel-Antwort

```json
{
  "success": true,
  "timestamp": "2025-10-25T18:37:13+0000",
  "data": {
    "type": "cowsay",
    "output": " _______\n< Hallo! >\n -------\n        \\   ^__^\n         \\  (oo)\\_______\n            (__)\\       )\\/\\\n                ||----w |\n                ||     ||"
  }
}
```

---

## 🧩 API Parameter

| Parameter | Typ | Beschreibung | Standard |
|------------|------|--------------|-----------|
| `mode` | `string` | `"fortunes"` oder `"cowsay"` | `"cowsay"` |
| `cat` | `string` | Kategorie der Fortune-Dateien (z. B. `zitate`, `sprichworte`) | zufällig |

---

## 💾 Beispiel: JSON POST (z. B. für Postman)

Ein einfacher Request, um ein `fortune`-Zitat zu erhalten:

```json
POST http://localhost:8080/api/quote
Content-Type: application/json

{
  "mode": "fortunes",
  "cat": "zitate"
}
```

**Antwort:**

```json
{
  "success": true,
  "timestamp": "2025-10-25T19:50:44+0000",
  "data": {
    "type": "fortunes",
    "category": "de/zitate",
    "output": "Es ist am Ende der Religion das beste, daß sie Ketzer hervorruft. — Christian Friedrich Hebbel"
  }
}
```

Tipp: In **Postman** einfach unter „Body → raw → JSON“ einfügen.

---

## 🩺 Health-Check

```bash
curl http://localhost:8080/api/health
```

Antwort:

```json
{"status":"ok","fortune":"available","cowsay":"available"}
```

---

## 🧱 Beispiel docker-compose.yml

Damit kannst du das API-Projekt einfach starten und dauerhaft laufen lassen:

```yaml
version: "3.9"

services:
  fortune-cowsay-api:
    image: ewald1976/fortune-cowsay-api:latest
    container_name: fortune-cowsay-api
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - LANG=de_DE.UTF-8
      - TZ=Europe/Berlin
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

Dann einfach starten mit:

```bash
docker compose up -d
```

und öffnen unter  
👉 `http://localhost:8080/api/quote`

---

## 🧑‍💻 Lokales Development

```bash
git clone https://github.com/ewald1976/fortune-cowsay-api.git
cd fortune-cowsay-api
docker compose up --build
```

Die API ist danach erreichbar unter  
👉 `http://localhost:8080`

---

## 🧠 Technischer Stack

- **Debian 13 (Trixie)** – aktuelles Stable-Release  
- **PHP 8.3 FPM + Lumen 10**  
- **Nginx 1.24 + Supervisor 4.3**  
- **fortune-mod / cowsay**  
- **Swagger UI** (optional)  
- **GitHub Actions** für Build, Tests und Release  

---

## 📦 Docker-Tags

| Tag | Architektur | Beschreibung |
|-----|--------------|--------------|
| `latest` | amd64 / arm64 | aktueller Stable-Build |
| `vX.Y.Z` | amd64 / arm64 | versionierter Release |
| `dev` | amd64 | aktueller Main-Branch-Build |

---

## 🔄 CI / CD Pipeline

Automatisiert via **GitHub Actions**:

1. 🧱 Build & Test – Container wird gebaut und Health-Check geprüft  
2. 🚀 Push – Multi-Arch-Image (amd64 + arm64) wird auf Docker Hub gepusht  
3. 🐮 Sync – README wird automatisch auf Docker Hub aktualisiert  

**Workflow:** `.github/workflows/docker.yml`

---

## 📜 Lizenz

MIT License © 2025 Elmar Leirich

---

## 🧑‍🚀 Autor

**ewald1976**  
[GitHub Profile](https://github.com/ewald1976)  
🐙 [Docker Hub Repository](https://hub.docker.com/r/ewald1976/fortune-cowsay-api)

> _„Kuh-philosophische Weisheiten aus dem Docker-Universum.“_  
> — Lt. Cmdr. Data 🖖
