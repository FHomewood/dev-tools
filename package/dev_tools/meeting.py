### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create templated meeting notes.

from dev_tools import *
import click, shutil, os, re


@click.command()
@click.argument("template", type=click.Choice(NOTE_TEMPLATES), default="note")
def cli(template):
    try:
        display("~~~ Loading Notes ~~~", "green")
        clone_dir_contents(from_dir=TEMPLATES_DIR / template, to_dir=TEMP_DIR)
        result = dict(
            kit=new_kit,
        ).get(template, new_note)()

        display("Done!", "bright_green")

    except Exception as e:
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))
        progress("Restoring")
        if not exception_message:
            exception_message = "An unknown error occurred"
        display(exception_message, "cyan")
        raise

    finally:
        shutil.rmtree(TEMP_DIR)


def new_note():
    # Formats directory as Notes/2000/01-January/01-Monday
    today_dir = (
        NOTE_DIR
        / CURRENT_DATETIME.strftime("%Y")
        / CURRENT_DATETIME.strftime("%m-%B")
        / CURRENT_DATETIME.strftime("%d-%A")
    )
    if not today_dir.is_dir():
        os.makedirs(today_dir)

    replace_template_values()

    clone_dir_contents(from_dir=TEMP_DIR, to_dir=today_dir)

    progress("Opening notes")
    file_to_open = next(
        today_dir.glob(f"{CURRENT_DATETIME.strftime('%Y-%m-%d_%H-%M-%S')}*.md")
    )
    os.system(f'{OPEN_CMD} "{today_dir.absolute()}" "{file_to_open.absolute()}"')
    return True


def new_kit():
    kit_dir = NOTE_DIR / "Meeting Notes" / "Keeping in Touch"
    ## TODO: switch this to environment variable or config

    if not kit_dir.is_dir():
        os.makedirs(kit_dir)


    team_members = list(kit_dir.iterdir())
    
    # Show team member selection interface
    display("Team Members:", "bright_yellow")
    for id, team_member in enumerate(team_members):
        display(f"[{id}] - {team_member.name}", "bright_yellow")
    display(f"[N] + New Team Member", "bright_yellow")

    team_member_id = click.prompt(
        click.style(f"Whose KIT is being recorded? - ", fg="bright_yellow"),
        show_choices=True,
    )

    # Read and process result
    if team_member_id in ("n", "N"):
        return new_team_member(kit_dir=kit_dir)
    elif int(team_member_id) in range(len(team_members)):
        team_member = team_members[int(team_member_id)]
    else:
        display("Could not find team member", "bright_red")

    progress("Building notes template")

    progress("Loading last meeting")
    most_recent_kit = list(
        (kit_dir / team_member).glob("*")
    )  ## TODO: Change glob argument to only target KIT files
    if len(most_recent_kit) == 0:
        progress("No previous KIT found", "bright_red")
        progress(f"Rebuilding {team_member.name}'s KIT folder")
        shutil.rmtree(team_member)
        return new_team_member(kit_dir, team_member.name)
    most_recent_kit.sort()
    most_recent_kit = most_recent_kit[-1]

    # Find information from the most recent kit
    # And extract it into the new one
    progress("Extracting information from last meeting")
    with open(most_recent_kit, "r") as file:
        data = "".join(file.readlines())
    regex = "".join(
        (
            "^(?:(?:.*\n)*)",  # Ignore initial preamble
            "### Check-in\n((?:.*\n)*)\n",  # Group #1 - Last we spoke
            "## Goals\n((?:.*\n)*)\n",  # Group #2 - Goals discussion
            "## Actions\n(?:(?:.*\n)*)\n",  # Group #3 - Proposed Actions
            "### Actions\n((?:.*\n*)*)\n",  # Group #4 - New Actions
            "### Tags",  # End reference is the Tags section
        )
    )
    match = re.match(regex, data)

    replace_template_values(
        team_member=team_member.name,
        last_we_spoke=match.group(1).strip(),
        goals=match.group(2).strip(),
        proposed_actions=match.group(3).strip(),
    )

    clone_dir_contents(from_dir=TEMP_DIR, to_dir=team_member)

    most_recent_kit = list(
        (kit_dir / team_member).glob("*")
    )  ## TODO: Change glob argument to only target KIT files
    most_recent_kit.sort()
    most_recent_kit = most_recent_kit[-1]

    progress("Opening notes")
    os.system(f'{OPEN_CMD} "{team_member.absolute()}" "{most_recent_kit.absolute()}"')
    return True


def new_team_member(kit_dir, team_member=None):
    if team_member is None:
        team_member = click.prompt(
            click.style(f"New team member name: ", fg="bright_yellow"),
            show_choices=True,
        )
    team_member = kit_dir / team_member.title().strip()
    os.mkdir(team_member.absolute())

    replace_template_values(
        team_member=team_member.name,
    )

    clone_dir_contents(from_dir=TEMP_DIR, to_dir=team_member)

    most_recent_kit = list(
        (kit_dir / team_member).glob("*")
    )  ## TODO: Change glob argument to only target KIT files
    most_recent_kit.sort()
    most_recent_kit = most_recent_kit[-1]

    progress("Opening notes")
    os.system(f'{OPEN_CMD} "{team_member.absolute()}" "{most_recent_kit.absolute()}"')
    return True


def reset_temporary_directory():
    if TEMP_DIR.is_dir():
        shutil.rmtree(TEMP_DIR)

    os.mkdir(TEMP_DIR.absolute())


def replace_template_values(
    team_member: str = "Anonymous",
    last_we_spoke: str = "- ",
    goals: str = "- ",
    proposed_actions: str = "- ",
) -> None:
    # Define values to replace
    placeholders = (
        ("{{ TIME STAMP }}", CURRENT_DATETIME.strftime("%Y-%m-%d_%H-%M-%S")),
        ("{{ LONG DATE }}", CURRENT_DATETIME.strftime("%A, %d %b %Y")),
        ("{{ SHORT DATE }}", CURRENT_DATETIME.strftime("%Y-%m-%d")),
        ("{{ TEAM MEMBER }}", team_member),
        ("{{ LAST WE SPOKE }}", last_we_spoke),
        ("{{ GOALS }}", goals),
        ("{{ PROPOSED ACTIONS }}", proposed_actions),
    )
    rename_templated_filenames(placeholders=placeholders)
    replace_templated_file_contents(placeholders=placeholders)


def rename_templated_filenames(placeholders):
    progress("Generating filenames")
    for path in TEMP_DIR.glob("**/*"):
        name = path.name
        for placeholder in placeholders:
            name = name.replace(placeholder[0], placeholder[1])
        os.rename(path, path.parent / name)


def replace_templated_file_contents(placeholders):
    progress("Generating file contents")
    for path in TEMP_DIR.glob("**/*"):
        with open(path, "r+") as _file:
            contents = "".join(_file.readlines())
            for placeholder in placeholders:
                contents = contents.replace(placeholder[0], placeholder[1])
            _file.seek(0)
            _file.write(contents)
            _file.truncate()


def clone_dir_contents(from_dir, to_dir):
    files_to_copy = from_dir.glob("**/*")
    for i in files_to_copy:
        shutil.copy(i, to_dir)
