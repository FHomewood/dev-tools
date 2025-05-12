### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create templated meeting notes.

import click
import shutil
import os
import re

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

        display("  - Replacing placeholder filenames...")
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...")
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
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))

    shutil.rmtree(temp_dir)
    if is_successful:
        os.system(
            f'code {today_dir.absolute()} {today_dir / date.strftime("%Y-%m-%d_%H-%M-%S.md")}'
        )
    else:
        display("  - Restoring...")
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def new_kit():
    notes_dir = Path.home() / "Notes"
    kit_dir = notes_dir / "Meeting Notes" / "Keeping in Touch"
    devtools_dir = Path.home() / ".dev-tools"
    ## TODO: switch these to environment variables or config

    is_successful = False
    error_message = "There was a failure:\n"
    date = datetime.now()

    temp_dir = devtools_dir / ".temp/"

    if temp_dir.is_dir():
        shutil.rmtree(temp_dir)
    os.makedirs(kit_dir, exist_ok=True)

    os.makedirs(temp_dir.absolute(), exist_ok=True)
    try:
        is_successful = False
        display("~~~ Loading Meeting Notes ~~~", "green")

        # Copy kit notes into temp
        files_to_copy = (devtools_dir / "templates" / "kit_note").glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, temp_dir)

        # Show team member selection interface
        display("Team Members:", "bright_yellow")

        team_members = list(kit_dir.iterdir())
        for id, team_member in enumerate(team_members):
            display(f"[{id}] - {team_member.name}", "bright_yellow")
        display(f"[N] + New Team Member", "bright_yellow")

        team_member_id = click.prompt(
            click.style(f"Whose KIT is being recorded? - ", fg="bright_yellow"),
            show_choices=True,
        )

        # Read and process result
        if team_member_id in ("n", "N"):
            return new_team_member(kit_dir=kit_dir, date=date, temp_dir=temp_dir)
        elif int(team_member_id) in range(len(team_members)):
            team_member = team_members[int(team_member_id)]
        else:
            display("Could not find team member", "bright_red")

        display("  - Building notes template...")

        display("  - Loading last meeting...")
        most_recent_kit = list(
            (kit_dir / team_member).glob("*")
        )  ## TODO: Change glob argument to only target KIT files
        most_recent_kit.sort()
        most_recent_kit = most_recent_kit[-1]

        # Find information from the most recent kit
        # And extract it into the new one
        display("  - Extracting information from last meeting...")
        with open(most_recent_kit, "r") as file:
            data = "".join(file.readlines())
        regex = "^(?:(?:.*\n)*)### Check-in\n((?:.*\n)*)\n## Goals\n((?:.*\n)*)\n## Actions\n(?:(?:.*\n)*)\n### Actions\n((?:.*\n*)*)\n### Tags"
        match = re.match(regex, data)

        # Define values to replace
        placeholders = (
            ("{{ TIME STAMP }}", date.strftime("%Y-%m-%d_%H-%M-%S")),
            ("{{ LONG DATE }}", date.strftime("%A, %d %b %Y")),
            ("{{ SHORT DATE }}", date.strftime("%Y-%m-%d")),
            ("{{ TEAM MEMBER }}", team_member.name),
            ("{{ LAST WE SPOKE }}", match.group(1).strip()),
            ("{{ GOALS }}", match.group(2).strip()),
            ("{{ PROPOSED ACTIONS }}", match.group(3).strip()),
        )

        display("  - Replacing placeholder filenames...")
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...")
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
            shutil.copy(i, team_member)

        most_recent_kit = list(
            (kit_dir / team_member).glob("*")
        )  ## TODO: Change glob argument to only target KIT files
        most_recent_kit.sort()
        most_recent_kit = most_recent_kit[-1]

        is_successful = True
    except Exception as e:
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))

    display("  - Restoring...")
    shutil.rmtree(temp_dir)
    if is_successful:
        display("  - Opening notes")
        os.system(f'code "{team_member.absolute()}" "{most_recent_kit.absolute()}"')
        display("Done!", "bright_green")
    else:
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def new_team_member(kit_dir, date, temp_dir):
    try:
        team_member = click.prompt(
            click.style(f"New team member name: ", fg="bright_yellow"),
            show_choices=True,
        )
        team_member = kit_dir / team_member.title().strip()
        os.mkdir(team_member.absolute())

        # Define values to replace
        placeholders = (
            ("{{ TIME STAMP }}", date.strftime("%Y-%m-%d_%H-%M-%S")),
            ("{{ LONG DATE }}", date.strftime("%A, %d %b %Y")),
            ("{{ SHORT DATE }}", date.strftime("%Y-%m-%d")),
            ("{{ TEAM MEMBER }}", team_member.name),
            ("{{ LAST WE SPOKE }}", "- "),
            ("{{ GOALS }}", "- "),
            ("{{ PROPOSED ACTIONS }}", "- "),
        )

        display("  - Replacing placeholder filenames...")
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...")
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
            shutil.copy(i, team_member)

        most_recent_kit = list(
            (kit_dir / team_member).glob("*")
        )  ## TODO: Change glob argument to only target KIT files
        most_recent_kit.sort()
        most_recent_kit = most_recent_kit[-1]

        is_successful = True
    except Exception as e:
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))

    display("  - Restoring...")
    shutil.rmtree(temp_dir)
    if is_successful:
        display("  - Opening notes")
        os.system(f'code "{team_member.absolute()}" "{most_recent_kit.absolute()}"')
        display("Done!", "bright_green")
    else:
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def new_daily():
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

        # Copy daily notes into temp
        files_to_copy = (devtools_dir / "templates" / "daily_note").glob("**/*")
        for i in files_to_copy:
            shutil.copy(i, temp_dir)

        # Define values to replace
        placeholders = (
            ("{{ TIME STAMP }}", date.strftime("%Y-%m-%d_%H-%M-%S")),
            ("{{ LONG DATE }}", date.strftime("%A, %d %b %Y")),
        )

        display("  - Replacing placeholder filenames...")
        for path in temp_dir.glob("**/*"):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display("  - Populating previous info...")
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
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))

    shutil.rmtree(temp_dir)
    if is_successful:
        os.system(
            f'code "{today_dir.absolute()}" "{today_dir / date.strftime("%Y-%m-%d_%H-%M-%S - Daily Notes.md")}"'
        )
        display("Done!", "bright_green")
    else:
        display("  - Restoring...")
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def display(message, color="bright_cyan"):
    click.echo(click.style(message, fg=color))
