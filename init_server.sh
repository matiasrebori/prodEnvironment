
#!/bin/bash
# start nginx
sudo /etc/init.d/nginx start
# activate environment
source venv/bin/activate
# run django application 
uwsgi --ini SAPA_uwsgi.ini

