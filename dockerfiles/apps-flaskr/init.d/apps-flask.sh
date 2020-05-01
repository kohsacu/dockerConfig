#!/usr/bin/env bash

set -u

. /var/opt/vEnv/flask/bin/activate

export FLASK_APP="flaskr"
export FLASK_ENV="development"

flask run --host='0.0.0.0' --port=5000

