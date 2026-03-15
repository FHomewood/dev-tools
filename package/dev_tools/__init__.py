import os
from pathlib import Path
from datetime import datetime
from click import echo, style

DEVTOOLS_DIR=Path(__file__).parent.parent.parent

NOTE_DIR = Path(os.environ.get("DEV_TOOLS_NOTE_DIR", Path.home() / "Notes/"))
TEMPLATES_DIR = Path(
    os.environ.get("DEV_TOOLS_TEMPLATES_DIR", DEVTOOLS_DIR / "templates/note/")
)
TEMP_DIR = Path(os.environ.get("DEV_TOOLS_TEMPORARY_DIR", DEVTOOLS_DIR / ".temp/"))
NOTE_TEMPLATES = [obj.stem for obj in TEMPLATES_DIR.iterdir() if obj.is_dir()]
CURRENT_DATETIME = datetime.now()
OPEN_CMD = os.environ.get("DEV_TOOLS_OPEN_CMD", 'code')

if not TEMP_DIR.is_dir():
    os.makedirs(TEMP_DIR)

def display(message, color="bright_cyan"):
    echo(style(message, fg=color))


def progress(message, color="bright_cyan"):
    echo(style(f"  - {message}...", fg=color))