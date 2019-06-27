#!/usr/bin/env bash

###########################################
# Author: Stevens Brito
# Github: stevensdotb
# Email: stevensbrito.tech@gmail.com
###########################################

# Show usage help
function usage() {
    echo "Usage: $(basename $0) [option [argument]] [runserver|runsslserver]" >&2
    echo 
    echo "Flag options:"
    echo "   -e  [venv-path]            Activate the virtualenv"
    echo "   -r                         Apply 'pip install' packages installation from requirement.txt file"
    echo "   -u                         Make a git pull to update your project with latest changes"
    echo "   -m  [all|app-name]         Make migrations of model changes to the database"
    echo "   -d  [database-service]     Start the database service"
    echo
    echo "Positional Arguments:"
    echo "   runserver                        Run the Server"
    echo "   runsslserver                     Run the SSL Server"
    echo
    echo "Examples:"
    echo "   Activate the virtualenv                               ./django_local.sh -e venv/path"
    echo "   Start database service                                ./django_local.sh -d mysql "
    echo "   Install all packages from requirements.txt            ./django_local.sh -r"
    echo "   Apply makemigrations and migrate for all:             ./django_local.sh -m all"
    echo "   Apply makemigrations and migrate for an app:          ./django_local.sh -m myapp"
    echo "   Git pull to update the project:                       ./django_local.sh -e venv/path -u"
    echo "   Git pull, makemigrations and migrate                  ./django_local.sh -e venv/path -um"
    echo
    echo "   All together:                                         ./django_local.sh -e venv/path -u -m all -d mysql run"
    echo
    echo "Notes:"
    echo " 1. To run the server after use flag options use the positional argument 'runserver' or 'runsslserver at the end"
    echo "       e.g: ./django_local.sh -e venv/path -d mysql runserver"
    echo
    echo "    Keep in mind that you can not run the server if you do not have Django installed on your server"
    echo "    or on your virtualenv (user -e option to activate it)"
    echo
    echo " 2. -d flag argument can be used for any database service, such as mysql, postgres, mongodb, etc."
    echo
    echo " 3. To install requirements packages over the virtualenv, the -e option has to be specified if virtualenv is not activated."
    echo
    echo " 4. As the packages installation is executed when -u is used, the -e option has to be specified as well if the virtualenv"
    echo "    is not activated."
    echo "       e.g: ./django_local.sh -e ../venv/ -r"
    echo
    echo " 5. When you apply the -u option, the program asks for new packages installation, so, it is not recommended to"
    echo "    apply the -r option, since the program might ask for packages installation twice"
    echo "       e.g: "
    echo "         - ./django_local.sh -e ../venv/ -u   [ Yes ]"
    echo "         - ./django_local.sh -e ../venv/ -ur  [ No ]"
    echo

    exit 1
}

# Start the db service
function start_db_service() {
    if [[ $1 != "" ]];
    then
        if [[ "$(service $1 status|grep running|wc -l)" -eq "0" ]]
        then
            echo -n "Starting $1 service";
            service mysql start;
            echo " [Done]"
        else
            echo "Service $1 already running";
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
    echo -n "Activate virtual environment $VPATH";
    source $VPATH
    echo " [Done]"
    echo
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
  # install packages from requirements.txt by default
  local pkg=${1:--r requirements.txt}

  echo
  read -p "Apply 'pip install $pkg'? [y/n]: " -n 1 answer

  if [[ "$answer" =~ [Yy] ]];
  then
    echo " [Installing]..."
    pip install ${pkg}
    
    if [[ $1 != "" ]];
    then # If new packages update the requirements.txt file
        echo "Updating the requirements.txt file"
        pip freeze > requirements.txt
    fi;
    
  elif [[ "$answer" =~ [Nn] ]];
  then
    echo " [Skiped]"
  else
    echo " [Invalid option]"
    install_new_packages
  fi;
  echo
}

# Make migrations by an app or in general
function make_migrations() {
  if [[ "$1" == "all" ]];
  then
    ./manage.py makemigrations
  else
    ./manage.py makemigrations $1
  fi;
  ./manage.py migrate
}

# Parameters 
OPTIND=1;
while getopts "e:d:m:hur" opt;
do
  case $opt in
    h)
      usage
      ;;
    e) # Path to activate the virtualenv
      activate_venv $OPTARG
      ;;
    r) # Install requirements.txt packages
      install_new_packages
      ;;
    d) # Start the database service  
      start_db_service $OPTARG
      ;;
    u) # Make a git pull to update your project with latest changes
      update_project
      ;;
    m) # makemigrations and migrate changes to the database
      make_migrations $OPTARG
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

# Run the app
if [ "${@:$OPTIND}" == "runserver" ] || [ "$1" == "runserver" ];
then
  ./manage.py runserver
fi;
if [ "${@:$OPTIND}" == "runsslserver" ] || [ "$1" == "runsslserver" ];
then
  if [[ "$(cat requirements.txt | grep django-sslserver | wc -l)" -eq "0" ]];
  then
    echo "Django SSL Server is not in the requirements.txt file. Make sure that it is installed"
    echo "on your server or virtualenv. In case it is not installed, proceed to apply a pip installation."
    install_new_packages django-sslserver
  fi;
  ./manage.py runsslserver
fi;

# If no arguments option are passed
if [[ "${OPTIND}" -eq "1" ]]
then
  usage;
fi;
