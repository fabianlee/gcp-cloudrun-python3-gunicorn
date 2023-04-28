import os
import io 
import logging
from flask import Flask, request, render_template, render_template_string, jsonify

# log level mutes every request going to stdout
#log = logging.getLogger('werkzeug')
#log.setLevel(logging.ERROR)
app = Flask(__name__,template_folder='.')
log = app.logger

# returns json response
@app.route('/json/<path:path>')
def show_json(path):
    return jsonify(type='OK',status=200,response=f"this is json called as: /json/{path}"), 200

# returns template file response
@app.route('/template/<path:path>')
def show_template(path):
    return render_template("template.html", message=f"this is a template called as: /template/{path}"), 200

# catch-all with simple text response
@app.route('/', defaults={'path':''})
@app.route('/<path:path>')
def show_default(path):
    return f"{VERSION} {MESSAGE} called as: /{path}"


# message from env var, with fallback
VERSION = os.getenv("VERSION","")
MESSAGE = os.getenv("MESSAGE","Hello, World!")

# called as Flask app
if __name__ == '__main__' or __name__ == "main":
  print("called as Flask app")
  port = int(os.getenv("PORT", 8080))
  print("Starting web server on port {}".format(port))
  app.run(host='0.0.0.0', port=port, debug=True)
# called as WSGI gunicorn app
else:
  print(f"called as WSGI gunicorn app {__name__}")

