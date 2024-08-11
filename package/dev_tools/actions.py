### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

import click
import shutil
import os
import re
import json

from datetime import datetime
from pathlib import Path

@click.group(invoke_without_command=True)
@click.pass_context
def cli(ctx):
    if not ctx.invoked_subcommand:
        actions()

@cli.command()
@click.argument(
    'ticket_pattern',
    type=str
)
def close(ticket_pattern):
    print(ticket_pattern)

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
        with open(actions_file_path, 'r') as file:
            actions_file = json.load(file)
        if not hasattr(actions_file, 'closed'):
            actions_file['closed'] = list()
        if not hasattr(actions_file, 'active'):
            actions_file['active'] = list()
        sub_files = notes_dir.glob('**/*.md')
        all_actions = get_all_actions(sub_files)
        actions_file['active'] = list(all_actions.difference(set(actions_file['closed'])))
        with open(actions_file_path, 'w') as file:
            json.dump(actions_file, file)
        for action in actions_file.get('active', list()):
            display(action)
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

def get_all_actions(files):
    return set(get_action_generator(files))

def get_action_generator(files):
    for file in files:
        file_actions = get_actions(file)
        for action in file_actions:
            yield action

def get_actions(file):
    ts_regex = r'^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}'
    if not re.match(ts_regex, file.stem):
        return list()
    with open(file, 'r') as file_reader:
        file_contents = ''.join(file_reader.readlines())
    timestamp = re.match(f"({ts_regex})", file.stem).group(1)
    actions_regex = r'(?<=### Actions\n)(.*\n)*(?=\n### Tags)'
    actions = re.search(actions_regex, file_contents)
    if not actions:
        return list()
    actions = actions.group(1)
    actions = [
        re.match('- (.+)', action_line).group(1)
        for action_line in actions.split('\n')
        if re.match('- (.+)', action_line)
        ]
    actions = [f"{timestamp} | {action}" for action in actions]
    return actions

def display(message, color="bright_cyan"):
    click.echo(click.style(message, fg=color))
