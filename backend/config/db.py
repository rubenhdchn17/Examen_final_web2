from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

app = Flask(__name__)

user = "criticasApp"
password = ")2bF7`62"
direc = "criticasApp.mysql.pythonanywhere-services.com"
namebd = "criticasApp$criticasAppDB"
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{user}:{password}@{direc}/{namebd}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = "supersecretkey"

db = SQLAlchemy(app)
ma = Marshmallow(app)
