<!-- / © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com> -->
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Empty CleanEnv script.


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
- DevTools - A command to control and standardise develompment machines.
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
