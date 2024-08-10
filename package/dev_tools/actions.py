### © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com>
# A command to manage existing actions created in notes files.

import click
import shutil
import os
import re

from datetime import datetime
from pathlib import Path

@click.command()
def cli():
    title_notes()

def actions():
    pass