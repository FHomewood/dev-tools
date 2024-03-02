<!-- / © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com> -->
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Meeting - `-d -daily` flag for making daily notes files.
- Meeting - Daily notes template file.
- Meeting - Individual meeting notes template file.
- Profile - `Time-Stamp` PowerShell function added to command set.
- Title Notes - A command to rename note files to have suitable titles.
- Title Notes - Filters meeting titles and appends them to their timestamp names.
- Config file to build user environment variables.
- Template config file for reference.
- Configuration instructions in the readme.
- Actions script
- Actions - A command to manage existing actions created in notes files.
- Actions - Stores state of all actions in `.dev-tools/.dtactions` file.
- Actions - Shows all unfinished actions.
- Actions - Close function moves actions from active to closed.
- Replace-FileContents function to find and replace text recursively in a directory.
- Replace-FileNames function to find and replace file names recursively in a directory.

### Changed
- Meeting - Keeping in Touch meeting heading now simply 'Keeping in Touch' instead of team member name.
- Meeting - Keeping in Touch meeting heading now formatted in italics.
- Meeting - Notes are stored in directories according to year, month and day that they were generated.
- Commands pull configuration from config file not environment variables.

### Fixed 
- Meeting - Creates meeting notes when no flag provided.
- Template directory now named appropriately `templates/`.
- Conform keeping in touch generation to have full time stamps in line with the Title-Notes command.
- Conform keeping in touch actions heading to match the actions command.


## [0.1.3] - 2024-01-30
### Added
- PowerShell Profile script.
- Functions script groups all shared functions into one file to be sourced in profile.
- Aliases script groups all into one file to be sourced in profile.
- Prompt script stores the prompt into one space to be sourced whenever the prompt needs overriding.
- `activate` alias to be used to jump into a python virtual environment quickly.
- `profile` alias reloads the current profile in the current PowerShell.
- Meeting - A command to create templated meeting notes.
- Meeting - KIT (Keeping in Touch) template file.
- Meeting - KIT notes track information from previous meeting.
- Meeting - Select from available team members.
- Meeting - Add new team members option.


## [0.1.2] - 2024-01-18
### Added
- DelEnv - A command to delete a temporary environment created by newenv.
- DelEnv - Deletes a given environment number.
- DelEnv - Smart identifies if no environment is given.
- DelEnv - Starts background job to delete workspace after close.
- CHANGELOG.md file to keep track of future changes.
- ReadMe - Shows most recent release in title.
- ReadMe - Includes the PowerShell installation command and script download button.
- NewEnv - Adds template directory to directly copy across to new environment.
- NewEnv - Adds experimental EnvName flag for named environments.
- NewEnv files are templated with {{ VARIABLE }} notation. Where variable is one of (YEAR, FIRST_NAME, LAST_NAME, CONTACT, ENV_NAME).
- NewEnv filenames are also templatable.

### Changed
- Configuration for environment now pulls from the environment variable assigned in dev-tools configuration.
- Scripts now live in a repository subfolder called './scripts/'.
- Info Flags in newenv now use separate PowerShell functions with switch cases.
- NewEnv environment can now be non-empty files.

### Fixed
- Added extra condition so newenv doesn't break before returning to initial directory on a failed run.
- Removed incorrect use of $$ causing minor bugs.
- Removed placeholder descriptions for script options.
- Made text colour readable on default PowerShell window colours.


## [0.1.1] - 2024-01-11
### Changed
- Inverted "InstallDependencies" flag to be "SkipInstallDependencies".
- Inverted "Configure" flag to be "SkipConfiguration.

### Fixed
- Installation script no longer skips the installation and configuration of the machine by default.


## [0.1.0] - 2024-01-11
### Added
- DevTools - A command to control and standardise development machines.
- DevTools basic setup initialisation.
- DevTools - Installs [Chocolatey](https://docs.chocolatey.org/en-us/).
- DevTools - Installs development dependencies.
- DevTools - Adds config to environment.
- DevTools - Configures [git](https://git-scm.com/doc).
- DevTools - Installs dev-tools package.
- NewEnv - A command to create new development environments.
- NewEnv - Creates temporary directory.
- NewEnv - Builds a configured directory structure.
- NewEnv - Instantiates new [python](https://docs.python.org/3/) virtual environment.
- NewEnv - Installs and initialises [Poetry](https://github.com/python-poetry/poetry) package manager.
- NewEnv - Initialises project git repository.
