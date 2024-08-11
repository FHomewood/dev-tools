### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

import click
import os
import re
import json

from pathlib import Path

@click.group(invoke_without_command=True)
@click.pass_context
def cli(ctx):
    if not ctx.invoked_subcommand:
        actions()


@cli.command()
@click.argument(
    'close_pattern',
    type=str
)
def close(close_pattern):
    dev_tools_dir = Path.home() / '.dev-tools'
    notes_dir = Path.home() / "Notes/"

    is_successful = False
    error_message = ''

    try:
        actions_file_path = dev_tools_dir / 'dot-files'/ '.dtactions'
        actions_file = initialise_actions_file(actions_file_path)
        for action in actions_file['active']:
            print(f'current_action={action}')
        matches = [i for i in actions_file['active'] if re.search(close_pattern, i)]
        print(f'{matches=}')
        is_successful = True
    except Exception as e:
        display("There was a failure.", "cyan")
        exception_message = getattr(e, "message", repr(e))
    if not is_successful:
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")


def actions():
    dev_tools_dir = Path.home() / '.dev-tools'
    notes_dir = Path.home() / "Notes/"

    is_successful = False
    error_message = ''
    try:
        actions_file_path = dev_tools_dir / 'dot-files'/ '.dtactions'
        actions_file = initialise_actions_file(actions_file_path)
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
    if not is_successful:
        error_message += exception_message
        if not error_message:
            error_message = "An unknown error occurred"
        display(error_message, "cyan")

def initialise_actions_file(file_path):
    os.makedirs(file_path.parent, exist_ok=True)
    if not file_path.is_file():
        with open(file_path, 'w') as file:
            file.write('{}')
    with open(file_path, 'r') as file:
        actions_file = json.load(file)
    if not actions_file.get('closed'):
        actions_file['closed'] = list()
    if not actions_file.get('active'):
        actions_file['active'] = list()
    return actions_file


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
