#!/bin/bash
GIT_NAME="$1"
PROJECT_NAME="$2"
PROJECT_PATH="${GIT_NAME}/${PROJECT_NAME}"
ABS_PATH=$(pwd)/"${PROJECT_PATH}"

#############################
### functions definitions ###
#############################


write_nginx_conf(){
# write in /etc/nginx/sites-available
sudo echo "
# mysite_nginx.conf

# the upstream component nginx needs to connect to
upstream django {
	server unix://${ABS_PATH}/${PROJECT_NAME}.sock; # for a file socket
	# server 127.0.0.1:8001; # for a web port socket (we'll use this first)
}

# configuration of the server
server {
    # the port your site will be served on
    listen      8000;
    # the domain name it will serve for
    server_name 127.0.0.1; # substitute your machine's IP address or FQDN
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    # Django media
    location /media  {
        alias ${ABS_PATH}/media;  # your Django project's media files - amend as required
    }

    location /static {
        alias ${ABS_PATH}/static; # your Django project's static files - amend as required
    }

    # Finally, send all non-media requests to the Django server.
    location / {
        uwsgi_pass  django;
        include     ${ABS_PATH}/uwsgi_params; # the uwsgi_params file you installed
    }
}
" > ${PROJECT_NAME}_nginx.conf
sudo cp "${PROJECT_NAME}"_nginx.conf /etc/nginx/sites-available
rm "${PROJECT_NAME}"_nginx.conf
# Symlink to this file from /etc/nginx/sites-enabled so nginx can see it
sudo ln -s /etc/nginx/sites-available/"${PROJECT_NAME}"_nginx.conf /etc/nginx/sites-enabled/
# console message
echo " ${PROJECT_NAME}_nginx.conf writed succesfully "
###end of function 
}


write_uwsgi_params(){
# write inside project folder
echo "
uwsgi_param  QUERY_STRING       \$query_string;
uwsgi_param  REQUEST_METHOD     \$request_method;
uwsgi_param  CONTENT_TYPE       \$content_type;
uwsgi_param  CONTENT_LENGTH     \$content_length;

uwsgi_param  REQUEST_URI        \$request_uri;
uwsgi_param  PATH_INFO          \$document_uri;
uwsgi_param  DOCUMENT_ROOT      \$document_root;
uwsgi_param  SERVER_PROTOCOL    \$server_protocol;
uwsgi_param  REQUEST_SCHEME     \$scheme;
uwsgi_param  HTTPS              \$https if_not_empty;

uwsgi_param  REMOTE_ADDR        \$remote_addr;
uwsgi_param  REMOTE_PORT        \$remote_port;
uwsgi_param  SERVER_PORT        \$server_port;
uwsgi_param  SERVER_NAME        \$server_name;
" > ${PROJECT_PATH}/uwsgi_params
# console message
echo " uwsgi_params writed succesfully "
### end of function
}


write_uwsgi_ini(){
# write .ini 
echo "
# mysite_uwsgi.ini file
[uwsgi]

# Django-related settings
# the base directory (full path)
chdir           = "${ABS_PATH}"
# Django's wsgi file
module          = "${PROJECT_NAME}".wsgi
# the virtualenv (full path)
home            = $(pwd)/venv

# process-related settings
# master
master          = true
# maximum number of worker processes
processes       = 10
# the socket (use the full path to be safe
socket          = "${ABS_PATH}"/"${PROJECT_NAME}".sock
# ... with appropriate permissions - may be needed
 chmod-socket    = 666
# clear environment on exit
vacuum          = true
" > ${PROJECT_NAME}_uwsgi.ini 
echo " ${PROJECT_NAME}_uwsgi.ini writed succesfully "
### end of function
}


write_static_setting(){
# append text to settings.py
echo "import os
STATIC_ROOT = os.path.join(BASE_DIR, "static/")
" >> ${PROJECT_PATH}/${PROJECT_NAME}/settings.py
}


write_init_server(){
# create script to run nginx with django
echo "
#!/bin/bash
# start nginx
sudo /etc/init.d/nginx start
# activate environment
source venv/bin/activate
# run django application 
uwsgi --ini "${PROJECT_NAME}"_uwsgi.ini
" > init_server.sh
# add permission
chmod +x init_server.sh
}

write_stop_server(){
# create script to stop nginx
echo "
#!/bin/bash
sudo /etc/init.d/nginx stop
" > stop_server.sh
# add permissions
chmod +x stop_server.sh
}


#############################
###       main flow       ###
#############################

write_nginx_conf
write_uwsgi_params
write_uwsgi_ini
write_static_setting
write_init_server
write_stop_server
