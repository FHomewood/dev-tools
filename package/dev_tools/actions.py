### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

import click
import shutil
import os
import re
import json

from datetime import datetime
from pathlib import Path

@click.command()
def cli():
    actions()

def actions():
    dev_tools_dir = Path.home() / '.dev-tools'
    notes_dir = Path.home() / "Notes/"

    is_successful = False
    error_message = ''
    try:
        actions_file_path = dev_tools_dir / 'dot-files'/ '.dtactions'
        os.makedirs(actions_file_path.parent, exist_ok=True)
        if not actions_file_path.is_file():
            with open(actions_file_path, 'w') as file:
                file.write('{}')
        actions_file = json.load(actions_file_path)
        is_successful = True
    except Exception as e:
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))
    if is_successful:
        display("Done!", "bright_green")
    else:
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def display(message, color="bright_cyan"):
    click.echo(click.style(message, fg=color))
