<!-- / © Copyright 2024 Frankie Homewood <F.Homewood@outlook.com> -->
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- CHANGELOG.md file to keep track of future changes
- Numerous additions to the readme:
  - Most recent realease in title.
  - PowerShell installation command.
  - Installation script download button.
- Empty CleanEnv script.

### Changed
- Configuration for environment now pulls from the environment variable assigned in dev-tools configuration.
- Scripts now live in a repository subfolder called './scripts/'
- Info Flags in newenv now use separate PowerShell functions with switch cases.

### Fixed
- Added extra condition so newenv doesn't break before returning to initial directory on a failed run.
- Removed incorrect use of $$ causing minor bugs.
- Removed placeholder descriptions for script options.

## [0.1.1] - 2024-01-11

### Changed
- Inverted "InstallDependencies" flag to be "SkipInstallDependencies".
- Inverted "Configure" flag to be "SkipConfiguration.

### Fixed 
- Installation script no longer skips the installation and configuration of the machine by default.

## [0.1.0] - 2024-01-11

### Added
- DevTools - A command to control and standardise develompment machines:
    - Basic setup initialisation.
    - Installs Chocolatey.
    - Installs Development Dependencies.
    - Adds config to environment.
    - Configures git.
    - Installs dev-tools package.
- NewEnv - A command to create new development environments:
    - Creates temporary directory.
    - Builds a configured directory structure.
    - Instantiates new python virtual environment.
    - Installs and initialises [Poetry](https://github.com/python-poetry/poetry) package manager.
    - Initialises project git repository.