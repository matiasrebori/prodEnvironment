#!/bin/bash

###################
### variables #####
###################

REPO_LINK="git@github.com:Monicaauler/IS2-GRUPO-07.git"
GIT_NAME="IS2-GRUPO-07"
PROJECT_NAME="SAPA"
PROJECT_PATH="${GIT_NAME}/${PROJECT_NAME}"
PYTHONPATH="/usr/bin/python3"

##################
### process ######
##################

# clone tht repository
echo "descargando codigo"
git clone "${REPO_LINK}"
# clear terminal
printf "\033c"
# enter git folder
cd "${GIT_NAME}" || { echo "Error, no se encontro el directorio $PROJECT_PATH"; exit 1; }
# getting last tag
LAST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
# checkout to new branch
echo "checkout al ultimo tag $LAST_TAG"
git checkout "$LAST_TAG" -b ultimo_tag
# go back to main folder
cd ..
# write neccesary files for nginx
echo "configurando nginx"
source write_conf_files.sh "${GIT_NAME}" "${PROJECT_NAME}"
# create virtual environment
echo "creando entorno virtual venv"
virtualenv -q -p $PYTHONPATH venv
# activate environment
echo "activando entorno"
source venv/bin/activate
# enter project folder
cd "${PROJECT_PATH}" || { echo "Error, no se encontro el directorio $PROJECT_PATH"; exit 1; }
# install requirements and silence output
echo "instalando dependencias"
pip install -r requirements.txt
pip install uwsgi
# collect all Django static files before running nginx
echo "recogiendo archivos estaticos"
python3 manage.py collectstatic
# create and populate DB
cd ..
cd ..
source create_and_populate_db.sh
# console message
printf "\n\n\n"
#echo " script finished please run init_server.sh, no need chmod "
echo " script completo, para iniciar el servidor correr init_server.sh, para detenet stop_server.sh"
printf "\n\n\n"
