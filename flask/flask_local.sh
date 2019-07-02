#!/usr/bin/env bash

###########################################
# Author: Stevens Brito
# Github: stevensdotb
# Email: stevensbrito.tech@gmail.com
###########################################

# Set environment variables
export FLASK_CONFIG="development"
export FLASK_DEBUG="True"
export FLASK_APP="run.py"

# Show usage help
function usage() {
    echo "Usage: $(basename $0) [option [argument]] [run]" >&2
    echo 
    echo "Flag options:"
    echo "   -e [venv-path]             Activate the virtualenv"
    echo "   -r                         Apply 'pip install' packages installation from requirement.txt file"
    echo "   -u                         Make a git pull to update your project with latest changes"
    echo "   -i                         Init alembic migration"
    echo "   -m                         Migrate and upgrade changes to the database"
    echo "   -d [database-service]      Start the database service"
    echo
    echo "Positional Argument:"
    echo "   run                        Run the server"
    echo "   shell                      Enter to Flask shell"
    echo
    echo "Examples:"
    echo "   Activate the virtualenv                               flask_local -e venv/path"
    echo "   Start database service                                flask_local -d mysql "
    echo "   Install all packages from requirements.txt            flask_local -r"
    echo "   flask db init:                                        flask_local -i"
    echo "   flask db migrate and upgrade:                         flask_local -m"
    echo "   flask db init, migrate and upgrade:                   flask_local -im"
    echo "   Git pull to update the project:                       flask_local -e venv/path -u"
    echo "   Git pull, flask db init, migrate and upgrade:         flask_local -e venv/path -uim"
    echo "   flask shell:                                          flask_local shell"
    echo
    echo "   All together:                                         flask_local -e venv/path -uim -d mysql run"
    echo
    echo "Notes:"
    echo " 1. To run the server after use flag options use the positional argument 'run' at the end"
    echo "       e.g: flask_local -e venv/path -d mysql run"
    echo
    echo "    Keep in mind that you can not run the server if you do not have flask installed on your server"
    echo "    or on your virtualenv (user -e option to activate it)"
    echo
    echo " 2. -d flag argument can be use for any database service, such as mysql, postgres, mongodb, etc."
    echo
    echo " 3. To install requirements packages over the virtualenv, the -e option has to be specified."
    echo "    As the packages installation is executed when -u is used the -e option has to be specified as well"
    echo "       e.g: flask_local -e ../venv/ -r"
    echo
    echo " 4. When you apply the -u option, the program asks for new packages installation, so, it is not recommended to"
    echo "    apply the -r option, since the program might ask for packages installation twice"
    echo "       e.g: "
    echo "         - flask_local -e ../venv/ -u   [ Yes ]" 
    echo "         - flask_local -e ../venv/ -ur  [ No ]" 
    echo

    exit 1
}

# Start the db service
function start_db_service() {
    if [ $1 != "" ];
    then
        if [[ "$(service $1 status|grep running|wc -l)" -eq "0" ]]
        then
            echo -n " * Starting $1 service";
            service mysql start;
            echo " [Done]"
        else
            echo " * Service $1 already running";
        fi;
    fi;
}

# Activate the virtualenv
function activate_venv() {
    if [[ $1 =~ /$ ]];
    then
        VPATH="$1bin/activate"
    else
        VPATH="$1/bin/activate"
    fi;
    echo -n " * Activate virtual environment $VPATH";
    source $VPATH
    echo " [Done]";
}

function update_project() {
  git pull
  echo
  echo "[Install new packages]"
  echo "You have applied an update for your project and maybe, there are new packages into"
  echo "your requirements.txt file. If so, you can apply a 'pip install' to install them;"
  echo "otherwise, you can skip this step."
  install_new_packages
}

function install_new_packages() {
  echo
  read -p "Apply 'pip install -r requirements.txt' to install new packages? [y/n]: " -n 1 answer

  if [[ "$answer" =~ [Yy] ]];
  then
    echo " [Installing]"
    pip install -r requirements.txt
  elif [[ "$answer" =~ [Nn] ]];
  then
    echo " [Skiped]"
  else
    echo " [Invalid option]"
    install_new_packages
  fi;
  echo
}

# Parameters 
OPTIND=1;
while getopts "e:d:hurim" opt;
do
  case $opt in
    h)
      usage
      ;;
    e) # Path to activate the virtualenv
      activate_venv $OPTARG
      ;;
    r) # Path to activate the virtualenv
      install_new_packages
      ;;
    d) # Start the database service  
      start_db_service $OPTARG
      ;;
    u) # Make a git pull to update your project with latest changes
      update_project
      ;;
    i) # Init alembic migrations
      flask db init;
      ;;
    m) # Migrate and upgrade changes to the database
      flask db migrate;
      flask db upgrade;
      ;;
    :)
      echo -e "\033[31mError\033[0m: option ${OPTARG} requires an argument" 1>&2
      usage
    ;;
    \?)
      echo
      echo -e "\033[31mError\033[0m: Invalid option" 1>&2
      usage
      ;;
    *) usage ;;
  esac
done
# echo $1 ${OPTIND}; exit 1
if [[ "$1" == "shell" ]];
then
  flask shell
  exit 1;
fi;

# Run the app
if [[ "${@:$OPTIND}" == "run" ]] || [[ "$1" == "run" ]];
then
  flask run
  exit 1;
fi;

# If no arguments option are passed
if [[ "${OPTIND}" -eq "1" ]]
then
  usage;
fi;

