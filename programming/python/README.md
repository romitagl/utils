# Python

## Creating Virtual Environments

Official documentation at: <https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-and-using-virtual-environments>.

There are two common tools for creating Python virtual environments:

- [venv](https://docs.python.org/3/library/venv.html) is available by default in Python 3.3 and later, and installs pip and setuptools into created virtual environments in Python 3.4 and later.
- [virtualenv](https://virtualenv.pypa.io/en/stable/index.html) needs to be installed separately, but supports Python 2.7+ and Python 3.3+, and pip, setuptools and wheel are always installed into created virtual environments by default (regardless of Python version).

### venv

```bash
# to enable
export DIR=.venv
python3 -m venv "$DIR"
source "$DIR"/bin/activate
# to disable
deactivate
```

### virtualenv

```bash
export DIR=.venv
python3 -m virtualenv "$DIR"
source "$DIR"/bin/activate
```

### VS Code

Using Python environments in VS Code: <https://code.visualstudio.com/docs/python/environments>.
