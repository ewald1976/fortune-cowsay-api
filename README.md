# 🐮 Fortune Cowsay API & UI

> Eine kleine, containerisierte REST-API mit integriertem *Cowsay*- und *Fortune*-Generator
> plus optionaler Retro-UI im Bernstein-Look.

---

## 🚀 Schnellstart (Docker Compose)

```bash
# Repository klonen
git clone https://github.com/ewald1976/fortune-cowsay-api.git
cd fortune-cowsay-api

# Container bauen und starten
docker compose up -d
```

Nach dem Start ist die API erreichbar unter:
👉 **[http://localhost:8080/api/quote](http://localhost:8080/api/quote)**

---

## 🧠 API-Endpunkte

### `/api/health`

Health-Check für Docker.

**Antwort:**

```json
{ "success": true, "timestamp": "2025-10-29T12:00:00+0000" }
```

### `/api/categories`

Listet alle verfügbaren Fortune-Datenbanken.

**Beispiel:**

```bash
curl http://localhost:8080/api/categories | jq .
```

### `/api/quote`

Erzeugt ein zufälliges Zitat oder eine sprechende Kuh.

**POST-Body (optional):**

```json
{
  "mode": "cowsay",     // oder "fortunes"
  "cat": "literature",  // optional, nur für Fortune
  "cow": "tux",         // optional, nur für Cowsay
  "text": "Hallo Welt"  // optional, eigener Text für Cowsay
}
```

**Antwort:**

```json
{
  "success": true,
  "data": {
    "type": "cowsay",
    "category": "literature",
    "output": "<ASCII oder Fortune Text>"
  }
}
```

Wenn keine Parameter angegeben werden, liefert die API standardmäßig eine zufällige Auswahl (50/50 Fortune/Cowsay).

---

## 🧪 Beispiel-Aufrufe

### cURL

```bash
curl -X POST http://localhost:8080/api/quote \
  -H 'Content-Type: application/json' \
  -d '{"mode": "fortunes", "cat": "literature"}' | jq .
```

### Postman

1. POST Request auf `http://localhost:8080/api/quote`
2. Body → raw → JSON:

   ```json
   { "mode": "cowsay", "text": "Moo!" }
   ```
3. Antwort zeigt ASCII-Ausgabe oder Fortune-Zitat.

---

## 🔍 Swagger UI

Swagger ist automatisch enthalten und erreichbar unter:
👉 **[http://localhost:8080/docs/](http://localhost:8080/docs/)**

---

## 💻 Beispiel-UI (Samples)

Im Ordner `samples/` befindet sich eine statische Retro-Demo im CRT-Stil.

**Starten (lokal):**

```bash
cd samples
python3 -m http.server 8081
```

Dann im Browser: [http://localhost:8081](http://localhost:8081)

Oder direkt im Docker-Nginx per Beispiel-Konfiguration:

---

## ⚙️ Beispiel-Nginx-Konfiguration

```nginx
server {
    listen 80;
    server_name meinekuh.domain.de;

    root /var/www/html/samples;
    index index.html;

    location /api/ {
        proxy_pass http://fortune-cowsay-api:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 🌐 Public Deployment

Der Container läuft eigenständig mit PHP-FPM + Nginx.
Deploy auf jedem Server mit Docker:

```bash
docker compose pull
docker compose up -d --build
```

Dann im Browser öffnen:
👉 [http://localhost:8080/docs/](http://localhost:8080/docs/)

---

## 🎉 Credits & Lizenz

* **Cowsay** by Tony Monroe
* **Fortune** (GNU BSD fortune-mod)
* Deutsche Zitate aus diversen Open-Fortune-Repositories

Lizenz: MIT
Autor: Elmar & Data (2025)

---

> „Moo or not to moo – that is the question.“
> — Cowspeare
