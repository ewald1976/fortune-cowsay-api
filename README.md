# 🐮 Fortune Cowsay Python API

Eine kleine REST-API auf Basis von Python/FastAPI, die `fortune`-Sprüche und `cowsay`-Ausgaben als JSON zurückliefert.  
Du kannst die API über eine simple Weboberfläche hier ausprobieren:

https://cowsay.mywire.org/

---

## 🚀 Docker Image

Das fertige Image liegt auf Docker Hub:

`ewald1976/fortune-cowsay-python:latest`

---

## 🧪 Endpoints (Kurzüberblick)

- `GET /api/health` – einfacher Healthcheck  
- `GET /api/categories` – verfügbare Fortune-Kategorien  
- `GET /api/cows` – verfügbare Cowfiles  
- `POST /api/quote` – liefert Fortune oder Cowsay

### Beispiel `POST /api/quote` (JSON)

```json
{
  "mode": "cowsay",        // "cowsay" oder "fortunes"
  "cat": "de/zitate",      // optional, Fortune-Kategorie
  "cow": "default",        // optional, Cowfile-Name
  "text": "Hallo aus Python!"  // optional, eigener Text (für cowsay)
}
```

---

## 🧊 Direktstart mit Docker

```bash
docker run -d \
  --name fortune-cowsay-python \
  -p 8000:8000 \
  ewald1976/fortune-cowsay-python:latest
```

Healthcheck testen:

```bash
curl http://localhost:8000/api/health
```

---

## 📦 docker-compose Beispiel

```yaml
services:
  fortune-cowsay-api:
    image: ewald1976/fortune-cowsay-python:latest
    container_name: fortune-cowsay-api
    restart: unless-stopped
    ports:
      - "8000:8000"
    # optional: zusätzliche ENV-Variablen, falls in Zukunft benötigt
    # environment:
    #   - FORTUNE_BASE_DIR=/usr/share/games/fortunes
```

Starten:

```bash
docker compose up -d
```

Danach ist die API unter `http://localhost:8000` erreichbar.

---