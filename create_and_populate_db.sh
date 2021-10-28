#!/bin/bash


# reemplazar en settings.py el nombre de la base de datos por la de producción
sed -i "s/'ambiente_desarrollo'/'ambiente_produccion'/g" "IS2-GRUPO-07/SAPA/SAPA/settings.py"


# crear y poblar la base de datos

# guardar directorio actual
DIR_ACTUAL=`pwd`

# mudarse a tmp para que el script tenga permisos y pueda crear la DB
echo 'CREATE DATABASE ambiente_produccion;' | sudo -u postgres psql | exit

# volver al directorio original y hacer migrations
cd "$DIR_ACTUAL"

# activar venv
source venv/bin/activate

# loaddata del .json
cd "IS2-GRUPO-07/SAPA/"
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py loaddata poblacion_db.json

# regresar al inicio
cd "$DIR_ACTUAL"
deactivate

