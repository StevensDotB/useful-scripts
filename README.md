# useful-scripts
Scripts that optimize the steps and processes for development

### Create alias for bash scripts

Craate a `.bash_aliases` file if it does not exists
```bash
touch .bash_aliases
```
Open the `.bash_aliases` file and add the alias for your scripts
```bash
alias django_local="$HOME/.useful-scripts/django/django_local.sh"
```
Note: *I like to keep my `useful-scripts` directory hidden, so, I renamed it as `.useful-scripts`*

Open your `.bashrc` file and find those lines
```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```
if they do not exist, you can add those lines into your `.bashrc` file.

Now, load your changes to keep your aliases alive when you open a new terminal
```bash
source .bashrc
```

Well, it's time to enjoy your script :D 
```bash
~$ django_local -d mysql runserver
Starting mysql service [Done]
Performing system checks

System check identified no issues (0 silenced).
June 27, 2019 - 12:17:39
Django version 2.2, using settings 'core.settings'
Starting development server at http://127.0.0.1:8000
Quit server with CONTROL-C
```

