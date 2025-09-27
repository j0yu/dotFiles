# dotFiles
User tools, configurations and setting

## Self-imposed repository rules

- Must be able to install without GUI
  - Able to backup existing files/folder
  - But freely delete symlinks
- Prioritise composition
  - Utilise _include_, _source_, etc to split up into meaningful categories
  - Minimal editing of destination files
    - e.g. `~/.bashrc` should only include 1 simple "source ..." to us where possible
- As much configs should live in `~/.config` (i.e. the `$XDG_CONFIG_HOME`)
- No symlinks, install destination should symlink to us

## Branching

### minimal

For bare-bones/server installs i.e. you just `git clone` this repo from a
tty and haven't even got any GUI going.

- Don't include ANY GUI configs/settings/programs
- Compatible with as much Linux distros as possible
  - Even more basic Arch or server Rockly/RHEL
- Contains configs/settings for CLI/TUI programs
- Scripts/programs **must not** call/utilise non-barebones programs
  i.e. no calling
  - Python
  - fancy CLI/TUI programs like `exa` or `fzf`
- Basic CLI/TUI programs are considered ok (they may need to be installed
  for very bare-bones Linux distros) e.g.:
  - git (again, I assumed you `git clone` this repo to start)
  - ssh
  - find
  - curl
  - terminfo

All other branches then stems off this branch.

### [main-*](https://github.com/j0yu/dotFiles/branches/all?query=main-)

What I'm currently running as daily driver.

- Merge commit of branches/features, plus
- Come changes yet to be tidied and upstreamed

### Everything else

Individual programs and setups (Desktop environment/Window managers)

This allows `main-*` branches to be clean and only contain features
that I actively need, while keeping legacy/inactive configs stored
away incase I want to use them again.
