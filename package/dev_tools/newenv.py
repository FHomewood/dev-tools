### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to create a new development environment under a temporary directory.

import click
import shutil
import subprocess
import os
import re
import virtualenv
import git

from random import randrange
from datetime import datetime
from pathlib import Path

@click.command()
def cli():
    new_environment()

def new_environment(env_name=None):
    dev_tools_dir = Path.home() / '.dev-tools'
    temp_dir = dev_tools_dir/'.temp/'
    env_dir = Path.home() / 'development/'

    is_successful = False
    error_message = ''
    date = datetime.now()

    first_name = 'Frankie'
    last_name = 'Homewood'
    contact = 'fhomewood98@gmail.com'

    env_num = 0 # randrange(10000,99999)

    if not env_name:
        env_name = f'project_{env_num}'
    env_path = env_dir / env_name

    try:
        display(f'~~~ Building Environment #{env_num} ~~~', 'green')
        display('  - Building path...')

        shutil.rmtree(temp_dir, ignore_errors=True)
        os.makedirs(env_path, exist_ok=True)
        os.makedirs(temp_dir, exist_ok=True)

        files_to_copy = (dev_tools_dir / 'templates' / 'newenv').iterdir()
        for i in files_to_copy:
            if i.is_file():
                shutil.copy(i,temp_dir)
            else:
                shutil.copytree(i, temp_dir/i.stem)
        placeholders = (
            ('{{ TIME STAMP }}', date.strftime('%Y-%m-%d_%H-%M-%S')),
            ('{{ LONG DATE }}', date.strftime('%A, %d %b %Y')),
            ('{{ YEAR }}', date.strftime('%Y')),
            ('{{ FIRST_NAME }}', first_name),
            ('{{ LAST_NAME }}', last_name),
            ('{{ CONTACT }}', contact),
            ('{{ ENV_NAME }}', f'project_{env_num}'),
        )

        display('  - Replacing placeholder filenames...')
        for path in temp_dir.glob('**/*'):
            name = path.name
            for placeholder in placeholders:
                name = name.replace(placeholder[0], placeholder[1])
            os.rename(path, path.parent / name)

        display('  - Populating previous info...')
        for path in temp_dir.glob('**/*.*'):
            with open(path, 'r+') as _file:
                contents = ''.join(_file.readlines())
                for placeholder in placeholders:
                    contents = contents.replace(placeholder[0], placeholder[1])
                _file.seek(0)
                _file.write(contents)
                _file.truncate()

        files_to_copy = temp_dir.iterdir()
        for i in files_to_copy:
            if i.is_file():
                shutil.copy(i,env_path)
            else:
                shutil.copytree(i, env_path/i.stem)

        display('  - Initializing git repository...')
        repo = git.Repo.init(env_path)

        display(f'  - Creating ./.{env_name}/ virtual environment...')
        venv_session = virtualenv.cli_run([str(env_path / f'.{env_name}'), '--download', '--quiet'])
        venv_bin = list((env_path / f'.{env_name}' / 'bin').iterdir())
        venv_executable = [i for i in venv_bin if re.match(i.stem,'python[^0-9]')]
        if not venv_executable:
            raise Exception('Could not find python executable for this virtual environment')
        venv_executable = venv_executable[0]
        venv_python_version = subprocess.run([venv_executable, '--version'], capture_output=True)
        venv_python_version = venv_python_version.stdout.decode('utf-8')
        venv_python_version = venv_python_version[7:-1]

        poetry_install_command = [venv_executable, '-m', 'pip', 'install', 'poetry']
        subprocess.run(poetry_install_command)

        os.chdir(env_path)
        subprocess.run([
            venv_executable,
            '-m',
            'poetry',
            'init',
            '--name',
            env_name,
            '--python',
            venv_python_version,
            '--author',
            f'"{ first_name } { last_name } <{ contact }>"',
            '--description',
            f'"Project ID #{ env_num }: Authored by { first_name } { last_name }"'
        ])

        subprocess.run([
            venv_executable,
            '-m',
            'poetry',
            'install'
        ])

        is_successful=True
    except Exception as e:
        display('There was a failure.', 'cyan')
        exception_message = getattr(e, 'message', repr(e))
    if is_successful:
        display('Done!', 'bright_green')
    else:
        error_message += exception_message
        if not error_message:
            error_message = 'An unknown error occurred'
        display(error_message, 'cyan')

def display(message, color='bright_cyan'):
    click.echo(click.style(message, fg=color))
