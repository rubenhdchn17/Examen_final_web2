from flask import Flask, request, jsonify
from flask_jwt_extended import JWTManager, create_access_token, jwt_required
from config.db import app, db
from flask_cors import CORS

from api.user import ruta_user
from api.site import ruta_site
from api.review import ruta_review

app.config['JWT_SECRET_KEY'] = 'supersecretkey'
jwt = JWTManager(app)
CORS(app)

app.register_blueprint(ruta_user, url_prefix="/api")
app.register_blueprint(ruta_site, url_prefix="/api")
app.register_blueprint(ruta_review, url_prefix="/api")

@app.route("/")
def index():
    return "Bienvenido a la aplicación de críticas de sitios"

if __name__ == "__main__":
    app.run(debug=True, port=5000, host="0.0.0.0")
