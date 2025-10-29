# 🐮 Fortune Cowsay API

Ein humorvolles API-Projekt, das **Unix-Fortunes** und **Cowsay-Ausgaben** als JSON oder HTML-Retro-Terminal kombiniert.
Ideal für Chatbots, Home-Dashboards oder einfach zum Schmunzeln.

---

## 🚀 Schnellstart (Docker Compose)

```bash
git clone https://github.com/ewald1976/fortune-cowsay-api.git
cd fortune-cowsay-api
docker compose up -d
```

API erreichbar unter:
👉 [http://localhost:8080/api/quote](http://localhost:8080/api/quote)
Swagger UI unter:
👉 [http://localhost:8080/public/docs/](http://localhost:8080/public/docs/)
Retro UI (Samples):
👉 [http://localhost:8080/public/samples/index.html](http://localhost:8080/public/samples/index.html)

---

## 🧠 API-Beispiele

### 🔹 Curl

```bash
curl -X POST http://localhost:8080/api/quote
```

### 🔹 Postman

POST → `http://localhost:8080/api/quote`
Headers → `Content-Type: application/json`
Body →

```json
{
  "mode": "cowsay",
  "cat": "riddles"
}
```

---

## ⚙️ Beispiel Nginx-Proxy-Konfiguration

Wenn du die Retro-UI als Startseite (z. B. `https://meinekuh.de/`) ausliefern willst:

```nginx
server {
    listen 80;
    server_name meinekuh.de;

    location / {
        proxy_pass http://fortune-cowsay-api:8080/public/samples/;
    }

    location /api/ {
        proxy_pass http://fortune-cowsay-api:8080/api/;
    }
}
```

> 💡 Tipp: Für Reverse-Proxy-Setups mit Nginx Proxy Manager
> den Container ins selben Netzwerk hängen (`npm-network`).

---

## 🐄 Features

✅ JSON-API mit `mode=cowsay` oder `mode=fortunes`
✅ Zufallsmodus („alle“)
✅ Deutsche + englische Fortunes
✅ Swagger-Doku integriert
✅ Retro-Terminal-UI im CRT-Look
✅ Docker-ready (Single-Container mit PHP-FPM + Nginx + Supervisor)

---

## 📦 Healthcheck

```bash
curl http://localhost:8080/api/health
```

Beispiel-Output:

```json
{
  "status": "ok",
  "fortune": "available",
  "cowsay": "available",
  "time": "2025-10-29T16:00:00+0000"
}
```

---

## 🤓 Credits

* Original Unix Fortunes: Debian Maintainers
* Extra English Quotes: [JKirchartz/fortunes](https://github.com/JKirchartz/fortunes)
* Retro-UI Design: DATA & Elmar 🧡
