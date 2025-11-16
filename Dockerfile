# ----------------------------------------------------
# Basis: Debian Trixie
# ----------------------------------------------------
FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# Systempakete: Python, Pip, Fortune, Cowsay, Locales
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    locales \
    fortune-mod cowsay \
    fortunes-de \
    && rm -rf /var/lib/apt/lists/*

# Locale auf de_DE.UTF-8 setzen (wie bei deiner PHP-Variante)
RUN sed -i 's/^# *de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de \
    LC_ALL=de_DE.UTF-8

# ----------------------------------------------------
# Python venv einrichten (=> kein PEP-668-Ärger)
# ----------------------------------------------------
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# ----------------------------------------------------
# App Setup
# ----------------------------------------------------
WORKDIR /app

# Python-Dependencies installieren (requirements.txt liegt neben app.py)
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Rest der App kopieren
COPY . .

# FastAPI läuft standardmäßig auf 8000
EXPOSE 8000

# Uvicorn starten
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]