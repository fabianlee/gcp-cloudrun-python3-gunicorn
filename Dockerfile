FROM python:3.10.4-slim-bullseye as builder

# Extra python env
ENV PYTHONDONTWRITEBYTECODE=0
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
# logs written immediately 
ENV PYTHONUNBUFFERED=1

# pip modules determined from 'pip freeze' during local development
COPY requirements.txt /.
RUN set -ex \
  && pip install --no-cache-dir -r requirements.txt

# python configuration for gunicorn app
COPY gunicorn.conf.py /.
# configuration for logging
COPY gunicorn-logging.conf /.
# our package and module that contains Flask app
COPY hellomodule hellomodule/

# default docker port to expose
EXPOSE 8080
ENV PORT 8080

# using Flask
#ENTRYPOINT [ "python", "-m", "hellomodule.app", "run" ]

# prefer WSGI gunicorn for production scenarios
ENTRYPOINT [ "/usr/local/bin/gunicorn", "--config", "gunicorn.conf.py", "--log-config", "gunicorn-logging.conf", "hellomodule.app:app" ]


