### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to rename note files to have suitable titles.

import click
import shutil
import os
import re

from datetime import datetime
from pathlib import Path

@click.command()
def cli():
    title_notes()

def title_notes():
    notes_dir = Path.home() / "Notes/"
    kit_dir = notes_dir / "Meeting Notes" / "Keeping in Touch"

    is_successful = False
    error_message = "There was a failure:\n"
    date = datetime.now()

    try:
        display("~~~ Renaming Meeting Notes ~~~", "green")
        all_notes = notes_dir.glob('**/*')
        for note in all_notes:
            get_name(note)
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

def get_name(note):
    timestamp_regex = r"[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}"
    file_has_timestamp = re.match(timestamp_regex, note.stem)

    if file_has_timestamp and note.suffix == '.md':
        timestamp = re.match(f'({timestamp_regex})', note.stem).group(1)
        with open(note, "r") as file:
            title = re.match("^# (.*) <", "".join(file.readlines())).group(1)
        if title != "_MEETING_":
            meeting_name = ''.join([ i for i in title if i not in r"[{/<:?*|>\}],." ]).strip(' _*')
            new_path = note.parent/ f'{timestamp} - {meeting_name}.md'
            os.rename(note, new_path)
            display(f'{note.stem}')
            display(f'\t-> {new_path.stem}')




def display(message, color="bright_cyan"):
    click.echo(click.style(message, fg=color))
