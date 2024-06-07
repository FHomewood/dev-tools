### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create templated meeting notes.

import click
import shutil
import os

from datetime import datetime
from pathlib import Path


@click.command()
@click.option("--kit", is_flag=True, help="Keeping in Touch.")
@click.option("--daily", is_flag=True, help="Daily tracker.")
def cli(kit, daily):
    if kit:
        new_kit()
    elif daily:
        new_daily()
    else:
        new_meeting()


def new_meeting():
    notes_dir = Path.home() / "Notes/"
    devtools_dir = Path.home() / ".dev-tools/"
    ## TODO: switch these to environment variables or config

    is_successful = False
    error_message = ""
    date = datetime.now()

    temp_dir = devtools_dir / ".temp/"

    if temp_dir.is_dir():
        shutil.rmtree(temp_dir)

    os.mkdir(temp_dir.absolute())

    try:
        display("~~~ Loading Meeting Notes ~~~", "green")

        today_dir = (
            notes_dir
            / date.strftime("%Y")
            / date.strftime("%m-%B")
            / date.strftime("%d-%A")
        )
        if not today_dir.is_dir():
            os.makedirs(today_dir)

        files_to_copy = (devtools_dir / "templates" / "meeting_note").glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, temp_dir)

        placeholders = (
            ("{{ TIME STAMP }}", date.strftime("%Y-%m-%d_%H-%M-%S")),
            ("{{ LONG DATE }}", date.strftime("%A, %d %b %Y")),
        )

        click.echo(
            click.style("  - Replacing placeholder filenames...", fg="bright_cyan")
        )
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...", "bright_cyan")
        for path in temp_dir.glob("**/*"):
            with open(path, "r+") as _file:
                contents = "".join(_file.readlines())
                for placeholder in placeholders:
                    contents = contents.replace(placeholder[0], placeholder[1])
                _file.seek(0)
                _file.write(contents)
                _file.truncate()

        files_to_copy = temp_dir.glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, today_dir)

        is_successful = True
    except Exception as e:
        display('There was a failure.', 'cyan')
        exception_message = getattr(e, "message", repr(e))

    shutil.rmtree(temp_dir)
    if is_successful:
        os.system(
            f'code {today_dir.absolute()} {today_dir / date.strftime("%Y-%m-%d_%H-%M-%S.md")}'
        )
    else:
        display("  - Restoring...", "bright_cyan")
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def new_kit():
    notes_dir = Path.home() / "Notes/"
    kit_dir = notes_dir / "Keeping_in_touch/"
    devtools_dir = Path.home() / ".dev-tools/"
    ## TODO: switch these to environment variables or config

    is_successful = False
    error_message = "There was a failure:\n"
    date = datetime.now()

    temp_dir = devtools_dir / ".temp/"

    if temp_dir.is_dir():
        shutil.rmtree(temp_dir)
    if not kit_dir.is_dir():
        os.mkdir(kit_dir)

    os.mkdir(temp_dir.absolute())
    try:
        is_successful = False
        display("~~~ Loading Meeting Notes ~~~", "green")

        files_to_copy = (devtools_dir / "templates" / "kit_note").glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, temp_dir)

        display("Team Members:", "bright_yellow")

        team_members = kit_dir.iterdir()
        for id, team_member in enumerate(team_members):
            display(f"[{id}] - {team_member}", "bright_yellow")
        display(f"[N] + New Team Member", "bright_yellow")

        team_member_id = click.prompt(
            click.style(f"Whose KIT is being recorded? - ", fg="bright_yellow"),
            show_choices=True
        )

            # set(range(len(list(team_members)))).union({'n'})
        placeholders = (
            ("{{ TIME STAMP }}", date.strftime("%Y-%m-%d_%H-%M-%S")),
            ("{{ LONG DATE }}", date.strftime("%A, %d %b %Y")),
        )

        display("  - Replacing placeholder filenames...", "bright_cyan")
        
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...", "bright_cyan")
        for path in temp_dir.glob("**/*"):
            with open(path, "r+") as _file:
                contents = "".join(_file.readlines())
                for placeholder in placeholders:
                    contents = contents.replace(placeholder[0], placeholder[1])
                _file.seek(0)
                _file.write(contents)
                _file.truncate()

        files_to_copy = temp_dir.glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, today_dir)

        is_successful = True
    except Exception as e:
        exception_message = getattr(e, "message", repr(e))
    shutil.rmtree(temp_dir)
    if is_successful:
        os.system(
            f'code {today_dir.absolute()} {today_dir / date.strftime("%Y-%m-%d_%H-%M-%S.md")}'
        )
    else:
        display("  - Restoring...", "bright_cyan")
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def new_daily():
    pass


def display(message, color):
    click.echo(click.style(message, fg=color))
