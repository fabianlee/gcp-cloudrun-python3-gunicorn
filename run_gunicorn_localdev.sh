#!/bin/bash
#
# Run Flask application via WYSGI gunicorn
#
# Used for production scenarios
#

# without conf file, need to specify command line settings
# https://docs.gunicorn.org/en/latest/settings.html
#gunicorn -w 2 -b 0.0.0.0:8080 --log-config=gunicorn-logging.conf hellomodule.app:app

# python file for app settings
# conf file for log settings
gunicorn --config gunicorn.conf.py --log-config=gunicorn-logging.conf hellomodule.app:app
