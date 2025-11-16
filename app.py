# app.py
from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from functools import lru_cache
from pathlib import Path
from typing import Optional

import subprocess

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field


# ============================================================
# 🔧 Konfiguration & Konstanten
# ============================================================

FORTUNE_BASE = Path("/usr/share/games/fortunes")
FORTUNE_DIRS: tuple[Path, ...] = (
    FORTUNE_BASE,
    FORTUNE_BASE / "de",
    FORTUNE_BASE / "local",
)

COW_DIR = Path("/usr/share/cowsay/cows")
DEFAULT_CATEGORY = "de/zitate"


class Mode(str, Enum):
    FORTUNES = "fortunes"
    COWSAY = "cowsay"


# ============================================================
# 🧠 Hilfsfunktionen (rein, gut testbar)
# ============================================================

def iso_timestamp() -> str:
    """ISO8601 mit UTC, ähnlich wie das alte PHP-Format."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%z")


@lru_cache(maxsize=1)
def list_fortune_categories() -> list[str]:
    """
    Scannt alle konfigurierten Fortune-Verzeichnisse und liefert
    relative Kategorienamen wie 'de/zitate', 'sprichworte' etc.
    Ergebnis wird gecached (Fortune-Files ändern sich praktisch nie).
    """
    categories: set[str] = set()

    for base in FORTUNE_DIRS:
        if not base.is_dir():
            continue

        for entry in base.iterdir():
            if not entry.is_file():
                continue

            # .dat / .u8 ignorieren
            if entry.suffix in {".dat", ".u8"}:
                continue

            rel = entry.relative_to(FORTUNE_BASE).as_posix()
            categories.add(rel)

    def sort_key(cat: str):
        # deutsche Kategorien bevorzugen
        return (0, cat) if cat.startswith("de/") else (1, cat)

    return sorted(categories, key=sort_key)


@lru_cache(maxsize=1)
def list_cows() -> list[str]:
    """Liefert alle verfügbaren Cow-Namen (ohne .cow)."""
    if not COW_DIR.is_dir():
        return []

    names = [p.stem for p in COW_DIR.glob("*.cow")]
    return sorted(names)


def choose_category(requested: Optional[str]) -> Optional[str]:
    """
    Wählt die effektive Kategorie:
    - wenn gewünschte vorhanden → die
    - sonst DEFAULT_CATEGORY, wenn vorhanden
    - sonst zufällige Kategorie
    - wenn gar keine vorhanden sind → None
    """
    categories = list_fortune_categories()
    if not categories:
        return None

    if requested and requested in categories:
        return requested

    if DEFAULT_CATEGORY in categories:
        return DEFAULT_CATEGORY

    import random
    return random.choice(categories)


def run_fortune(category: Optional[str]) -> str:
    """
    Ruft `fortune` auf. Wenn keine Kategorie vorhanden ist,
    kommt ein generischer Hinweis zurück.
    """
    if not category:
        return "Keine Fortune-Einträge gefunden."

    cat_path = FORTUNE_BASE / category

    try:
        result = subprocess.run(
            ["/usr/games/fortune", str(cat_path)],
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return "fortune ist auf diesem System nicht installiert."
    except Exception:
        return "Fehler beim Ausführen von fortune."

    text = (result.stdout or "").strip()
    return text or "Keine Fortune-Einträge gefunden."


def run_cowsay(text: str, cow: str) -> str:
    """
    Ruft `cowsay` auf und gibt das Ergebnis zurück.
    Fällt bei Fehlern sauber auf den Fortune-Text zurück.
    """
    cmd = ["/usr/games/cowsay"]

    if cow != "default":
        cow_file = COW_DIR / f"{cow}.cow"
        if cow_file.is_file():
            cmd.extend(["-f", cow])

    try:
        result = subprocess.run(
            cmd,
            input=text,
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return f"(cowsay nicht installiert)\n{text}"
    except Exception:
        return text

    out = (result.stdout or "").strip()
    return out or text


# ============================================================
# 📦 API-Modelle (Pydantic)
# ============================================================

class QuoteRequest(BaseModel):
    mode: Mode = Field(default=Mode.COWSAY, description="fortunes oder cowsay")
    cat: Optional[str] = Field(default=None, description="Fortune-Kategorie")
    text: Optional[str] = Field(default=None, description="Eigener Text statt fortune")
    cow: str = Field(default="default", description="Cow-Datei ohne .cow")


# ============================================================
# 🌐 FastAPI Setup
# ============================================================

app = FastAPI(
    title="Fortune Cowsay API (Python)",
    description="Python-Variante der Fortune/Cowsay-API mit FastAPI.",
    version="1.0.0",
)


def json_response(success: bool, data=None, error=None, status_code: int = 200):
    """
    Einheitliches Response-Format wie in deiner PHP-Version,
    nur eben Python-Style gekapselt.
    """
    payload: dict = {
        "success": success,
        "timestamp": iso_timestamp(),
    }
    if success:
        payload["data"] = data
    else:
        payload["error"] = error
    return JSONResponse(status_code=status_code, content=payload)


# ============================================================
# 🔍 Endpoints
# ============================================================

@app.get("/api/health")
def health():
    return {
        "status": "ok",
        "time": iso_timestamp(),
        "fortune_available": (FORTUNE_BASE.exists()),
        "cowsay_available": COW_DIR.exists(),
    }


@app.get("/api/categories")
def api_categories():
    cats = list_fortune_categories()
    return json_response(
        True,
        {
            "count": len(cats),
            "categories": cats,
        },
    )


@app.get("/api/cows")
def api_cows():
    cows = list_cows()
    return json_response(
        True,
        {
            "count": len(cows),
            "cows": cows,
        },
    )


@app.post("/api/quote")
def api_quote(req: QuoteRequest):
    # Kategorie bestimmen
    effective_cat = choose_category(req.cat)

    # Fortune oder Custom-Text
    if req.text and req.text.strip():
        fortune_text = req.text.strip()
    else:
        fortune_text = run_fortune(effective_cat)

    # Modus anwenden
    if req.mode == Mode.COWSAY:
        output = run_cowsay(fortune_text, req.cow or "default")
    else:
        output = fortune_text

    return json_response(
        True,
        {
            "type": req.mode.value,
            "category": effective_cat,
            "cow": req.cow,
            "output": output,
        },
    )