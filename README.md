# 🐮 Fortune Cowsay API & UI

> Eine kleine, containerisierte REST-API mit integriertem *Cowsay*- und *Fortune*-Generator
> plus optionaler Retro-UI im Bernstein-Look.

---

## 🚀 Schnellstart (Docker)

```
# Repository klonen
git clone https://github.com/<dein-repo>/fortune-cowsay-api.git
cd fortune-cowsay-api

# Docker-Container bauen und starten
docker compose up -d
```

Nach dem Start ist die API erreichbar unter
**[http://localhost:8080/api/quote](http://localhost:8080/api/quote)**

---

## 🧠 API-Endpunkte

### GET /api/health

Health-Check für Docker.

**Antwort:**

```
{ "success": true, "timestamp": "2025-10-29T12:00:00+0000" }
```

---

### GET /api/categories

Listet alle verfügbaren Fortune-Datenbanken.

**Beispiel:**

```
curl http://localhost:8080/api/categories | jq .
```

---

### POST /api/quote

Erzeugt ein zufälliges Zitat oder eine sprechende Kuh.

**Request Body (JSON):**

```
{
  "mode": "cowsay",     // oder "fortunes"
  "cat": "literature",  // optional, für Fortune
  "cow": "tux",         // optional, für Cowsay
  "text": "Hallo Welt"  // optional, eigener Text für Cowsay
}
```

**Antwort:**

```
{
  "success": true,
  "data": {
    "type": "cowsay",
    "category": "literature",
    "output": "<ASCII oder Fortune Text>"
  }
}
```

Wenn keine Parameter angegeben werden, liefert die API standardmäßig eine zufällige Kuh oder Fortune (50/50).

---

## 🖊️ Beispiel-Aufrufe

### cURL

```
curl -X POST http://localhost:8080/api/quote \
  -H 'Content-Type: application/json' \
  -d '{"mode": "fortunes", "cat": "literature"}' | jq .
```

### Postman

1. POST Request auf `http://localhost:8080/api/quote`
2. Body -> raw -> JSON:

   ```
   { "mode": "cowsay", "text": "Moo!" }
   ```
3. Response zeigt ASCII-Ausgabe oder Fortune-Zitat.

---

## 🔹 Swagger UI

Swagger ist automatisch enthalten und erreichbar unter:

**[http://localhost:8080/docs/](http://localhost:8080/docs/)**

Die Datei liegt im Container unter:

```
/var/www/html/public/docs/index.html
```

und verwendet die Definition:

```
/var/www/html/public/openapi.yaml
```

---

## 🔗 Example UI (Samples)

Im Ordner `samples/` befindet sich eine statische Demo-UI im CRT-Stil.

**Starten (lokal):**

```
cd samples
python3 -m http.server 8081
```

Dann im Browser:
[http://localhost:8081](http://localhost:8081)

Oder direkt aus Docker heraus (siehe unten Nginx-Beispiel).

---

## 🔧 Beispiel-Nginx-Konfiguration

Wenn du die Retro-UI automatisch ausliefern willst (z. B. unter `meinekuh.domain.de`),
lege diese Config-Datei im Projekt ab:

```
server {
    listen 80;
    server_name meinekuh.domain.de;

    root /var/www/html/samples;
    index index.html;

    location /api/ {
        proxy_pass http://fortune-cowsay-api-php-fpm:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Diese Datei kann in das Image kopiert werden, oder du nutzt sie über eine angepasste `nginx.conf` in deinem Compose-Setup.

---

## 🌐 Public Deploy Hinweis

Der API-Container kann direkt in jede Infrastruktur deployed werden (Docker, Podman, Kubernetes, etc.).

Statische Dateien (z. B. `samples/index.html`) können separat als Website ausgeliefert oder über denselben Nginx-Container integriert werden.

Beispiel:

```
docker build -t fortune-cowsay-api .
docker run -d -p 8080:8080 fortune-cowsay-api
```

Dann im Browser: [http://localhost:8080/docs/](http://localhost:8080/docs/)

---

## 🎉 Credits & Lizenz

* **Cowsay** by Tony Monroe
* **Fortune** (GNU BSD fortune-mod)
* Deutsche Zitate aus diversen Open-Fortune-Repositories

Lizenz: MIT
Autor: Ewald & Data (2025)

---

> „Moo or not to moo – that is the question.“  — Cowspeare
