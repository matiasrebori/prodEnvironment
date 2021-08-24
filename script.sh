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
git clone "${REPO_LINK}"
# write neccesary files for nginx
source write_conf_files.sh "${GIT_NAME}" "${PROJECT_NAME}"
# create virtual environment
virtualenv -q -p $PYTHONPATH venv
# activate environment
source venv/bin/activate
# enter project folder
cd "${PROJECT_PATH}"
#pip install -r requirements.txt
#pip install uwsgi
# collect all Django static files before running nginx
python3 manage.py collectstatic
# console message
printf "\n\n\n"
echo " script finished please run init_server.sh, no need chmod "
printf "\n\n\n"
