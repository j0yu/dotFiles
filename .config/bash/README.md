# Bash entrypoints

Since `~/.bash_profile` commonly sources `~/.bashrc`, having just the append and prepend script for `~/.bashrc` here should be enough.

The `install.bash` script will, **without checking if they already exist**, append and prepend these lines to `~/.bashrc`

```bash
source "/path/to/repository/.config/bash/bashrc/prepend"
...existing contents of ~/.bashrc...
source "/path/to/repository/.config/bash/bashrc/append"
```
